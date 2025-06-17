//
//  Category+CSV.swift
//  lms
//
//  Created by Ivan Isaev on 13.06.2025.
//

import Foundation

extension Category {
    
    // Точное количество полей
    private static let csvFieldCount = 4
    
    // MARK: - CSV Parsing
    
    static func parse(csvLine: String) -> Category? {
        // Разделение строки на компоненты
        let components = csvLine.components(separatedBy: ",")
        
        // Проверка количества полей
        guard components.count == Self.csvFieldCount else {
            return nil
        }
        
        // Парсинг данных категории
        guard
            let id = Int(components[0]),
            let name = components[1].isEmpty ? nil : components[1],
            let emoji = components[2].first,
            let isIncome = Bool(components[3])
        else {
            return nil
        }
        
        // Создание объекта категории
        return Category(
            id: id,
            name: name,
            emoji: emoji,
            isIncome: isIncome
        )
    }
    
    // MARK: - CSV Serialization
    
    var csvLine: String {
        "\(id),\(name),\(emoji),\(isIncome)"
    }
}
