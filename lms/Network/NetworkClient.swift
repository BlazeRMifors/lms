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
            urlRequest.httpBody = try JSONEncoder().encode(body)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "NetworkClient", code: code, userInfo: [NSLocalizedDescriptionKey: "HTTP ошибка: \(code)"])
        }
        
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded
    }
} 
