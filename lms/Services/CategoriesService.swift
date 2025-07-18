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
    private let cache: CategoriesCacheProtocol
    private var cachedCategories: [Category]? = nil
    
    init(api: CategoriesAPIProtocol = CategoriesAPI(client: Client()), cache: CategoriesCacheProtocol = CategoriesFileCache()) {
        self.api = api
        self.cache = cache
    }
    
    func getAllCategories() async -> [Category] {
        if let cached = cachedCategories {
            return cached
        }
        do {
            let categories = try await api.fetchAllCategories()
            self.cachedCategories = categories
            cache.save(categories: categories)
            return categories
        } catch {
            let local = cache.load()
            self.cachedCategories = local
            return local
        }
    }
    
    func getCategories(by direction: Direction) async -> [Category] {
        let all = await getAllCategories()
        return all.filter { $0.direction == direction }
    }
}
