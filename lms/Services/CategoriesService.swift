//
//  CategoriesService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol CategoriesServiceProtocol {
  func getAllCategories() async -> [Category]
  func getCategories(by direction: Direction) async -> [Category]
}

final class CategoriesService: CategoriesServiceProtocol {
    private let api: CategoriesAPIProtocol
    private var cachedCategories: [Category]? = nil

    init(api: CategoriesAPIProtocol = CategoriesAPI(client: Client())) {
        self.api = api
    }
    
    func getAllCategories() async -> [Category] {
        if let cached = cachedCategories {
            return cached
        }
        
        do {
            let categories = try await api.fetchAllCategories()
            self.cachedCategories = categories
            return categories
        } catch {
            return []
        }
    }
    
    func getCategories(by direction: Direction) async -> [Category] {
        let all = await getAllCategories()
        return all.filter { $0.direction == direction }
    }
}
