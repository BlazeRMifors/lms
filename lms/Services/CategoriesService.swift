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

    init(api: CategoriesAPIProtocol = CategoriesAPI(client: Client())) {
        self.api = api
    }
    
    func getAllCategories() async -> [Category] {
        do {
            return try await api.fetchAllCategories()
        } catch {
            return []
        }
    }
    
    func getCategories(by direction: Direction) async -> [Category] {
        let all = await getAllCategories()
        return all.filter { $0.direction == direction }
    }
}
