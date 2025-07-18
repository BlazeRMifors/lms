//
//  CategoriesAPI.swift
//  lms
//
//  Created by Ivan Isaev on 17.07.2025.
//

import Foundation

protocol CategoriesAPIProtocol {
    func fetchAllCategories() async throws -> [Category]
}

final class CategoriesAPI: CategoriesAPIProtocol {
    private let networkClient: NetworkClient
    
    init(client: NetworkClient) {
        self.networkClient = client
    }
    
    func fetchAllCategories() async throws -> [Category] {
        let request = Request.get(url: ApiEndpoints.categories)
        let dtos: [CategoryDTO] = try await networkClient.send(request)
        let categories = dtos.map { $0.toDomain() }
        return categories
    }
}

// Пример мок-реализации для отладки:
// final class MockCategoriesAPI: CategoriesAPIProtocol {
//     func fetchAllCategories() async throws -> [Category] {
//         return [Category(...), ...]
//     }
// } 
