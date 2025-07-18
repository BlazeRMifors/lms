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
    private let client: NetworkClient
    private var cachedCategories: [Category]? = nil
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchAllCategories() async throws -> [Category] {
        if let cached = cachedCategories {
            return cached
        }
        let request = Request.get(url: ApiEndpoints.categoriesURL)
        let dtos: [CategoryDTO] = try await client.send(request)
        let categories = dtos.map { $0.toDomain() }
        self.cachedCategories = categories
        return categories
    }
}

// Пример мок-реализации для отладки:
// final class MockCategoriesAPI: CategoriesAPIProtocol {
//     func fetchAllCategories() async throws -> [Category] {
//         return [Category(...), ...]
//     }
// } 
