//
//  Transaction+CSV.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

extension Transaction {
    
    // Точное количество полей
    private static let csvFieldCount = 9
    
    
    // MARK: - CSV Parsing
    
    static func parse(csvLine: String) -> Transaction? {
        // Разделение строки на компоненты
        let components = csvLine.components(separatedBy: ",")
        
        // Проверка количества полей
        guard components.count == Self.csvFieldCount else {
            return nil
        }
        
        // Парсинг основных данных транзакции
        guard let id = Int(components[0]),
              let accountId = Int(components[1]),
              let amount = Decimal(string: components[2]),
              let transactionDate = ISO8601DateFormatter().date(from: components[3])
        else {
            return nil
        }
        
        // Парсинг комментария (необязательное поле)
        let comment = components[4]
        
        // Парсинг данных категории
        let categoryLine = components[5...8].joined(separator: ",")
        guard let category = Category.parse(csvLine: categoryLine) else {
            return nil
        }
        
        // Создание объекта транзакции
        return Transaction(
            id: id,
            accountId: accountId,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment
        )
    }
    
    // MARK: - CSV Serialization
    
    var csvLine: String {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.string(from: transactionDate)
        let commentValue = comment ?? ""
        
        return "\(id),\(accountId),\(amount),\(date),\(commentValue),\(category.csvLine)"
    }
}
