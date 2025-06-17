//
//  CategoriesService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

final class CategoriesService {
    
    private let mockCategories = [
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true),
        Category(id: 2, name: "Фриланс", emoji: "💻", isIncome: true),
        Category(id: 3, name: "Продукты", emoji: "🛒", isIncome: false),
        Category(id: 4, name: "Транспорт", emoji: "🚗", isIncome: false)
    ]
    
    func getAllCategories() async -> [Category] {
        return mockCategories
    }
    
    func getCategories(by direction: Direction) async -> [Category] {
        let all = await getAllCategories()
        return all.filter { $0.direction == direction }
    }
}
