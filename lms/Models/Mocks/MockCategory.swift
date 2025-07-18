//
//  MockCategory.swift
//  lms
//
//  Created by Ivan Isaev on 18.07.2025.
//

enum MockCategory {
    static let salary = Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income)
    static let freelance = Category(id: 2, name: "Фриланс", emoji: "💻", direction: .income)
    static let products = Category(id: 3, name: "Продукты", emoji: "🛒", direction: .outcome)
    static let transport = Category(id: 4, name: "Транспорт", emoji: "🚗", direction: .outcome)
    static let animal = Category(id: 5, name: "На собачек", emoji: "🐕", direction: .outcome)
    static let repair = Category(id: 6, name: "На ремонт", emoji: "🔨", direction: .outcome)
    
    static let all: [Category] = [salary, freelance, products, transport, animal, repair]
}
