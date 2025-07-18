//
//  NetworkClient.swift
//  lms
//
//  Created by Ivan Isaev on 16.07.2025.
//

import Foundation

protocol NetworkClient {
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response
}

final class Client: NetworkClient {
    
    // Инструкция по настройке переменной окружения API_TOKEN — см. README.md в этой папке.
    private let token = ProcessInfo.processInfo.environment["API_TOKEN"] ?? ""
    
    func send<Response: Decodable>(
        _ request: NetworkRequest
    ) async throws -> Response {
        var urlRequest = URLRequest(url: request.url)
        
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if !token.isEmpty {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = request.payload {
            do {
                let encodedBody: Data = try await Task.detached(priority: .background) {
                    try JSONEncoder().encode(body)
                }.value
                urlRequest.httpBody = encodedBody
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw NetworkError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NetworkError.httpError(code: code, data: data)
        }
        
        do {
            let decoded: Response = try await Task.detached(priority: .background) {
                try JSONDecoder().decode(Response.self, from: data)
            }.value
            return decoded
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
} 

enum NetworkError: Error, LocalizedError {
    case httpError(code: Int, data: Data?)
    case encodingError(Error)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .httpError:
            return "Не удалось загрузить данные. Проверьте подключение к интернету или попробуйте позже."
        case .encodingError:
            return "Ошибка подготовки данных для отправки. Попробуйте позже."
        case .decodingError:
            return "Ошибка обработки ответа от сервера. Попробуйте позже."
        case .unknown:
            return "Произошла неизвестная ошибка. Попробуйте позже."
        }
    }
}

// Заглушка для пустого ответа
struct EmptyResponse: Decodable {} 
