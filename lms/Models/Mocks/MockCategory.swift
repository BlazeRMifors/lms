//
//  MockCategory.swift
//  lms
//
//  Created by Ivan Isaev on 18.07.2025.
//

enum MockCategory {
  static let salary = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
  static let freelance = Category(id: 2, name: "Фриланс", emoji: "💻", isIncome: true)
  static let products = Category(id: 3, name: "Продукты", emoji: "🛒", isIncome: false)
  static let transport = Category(id: 4, name: "Транспорт", emoji: "🚗", isIncome: false)
  static let animal = Category(id: 5, name: "На собачек", emoji: "🐕", isIncome: false)
  static let repair = Category(id: 6, name: "На ремонт", emoji: "🔨", isIncome: false)
  
  static let all: [Category] = [salary, freelance, products, transport, animal, repair]
}
