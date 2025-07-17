import Foundation

final class NetworkClient {
    private let baseURL = URL(string: "https://shmr-finance.ru")!
    private let token = "pIRb9cJ29GD14UI4imJJaNqH"
    
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case httpError(Int)
        case decodingError(Error)
        case encodingError(Error)
        case unknown(Error)
        case noData
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Некорректный URL."
            case .httpError(let code):
                return "Ошибка HTTP: код \(code)"
            case .decodingError(let error):
                return "Ошибка декодирования: \(error.localizedDescription)"
            case .encodingError(let error):
                return "Ошибка кодирования: \(error.localizedDescription)"
            case .unknown(let error):
                return "Неизвестная ошибка: \(error.localizedDescription)"
            case .noData:
                return "Нет данных в ответе."
            }
        }
    }

    func request<Request: Encodable, Response: Decodable>(
        path: String,
        method: String = "GET",
        requestBody: Request? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> Response {
        // Формируем URL
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = requestBody {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            do {
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
} 