//
//  Transaction+JSON.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

extension Transaction {
    
    // MARK: - JSON Parsing
    
    static func parse(jsonObject: Any) -> Transaction? {
        
        // Проверка корневого объекта
        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        // Парсинг основных данных транзакции
        guard
            let id = dict["id"] as? Int,
            let amountStr = dict["amount"] as? String,
            let amount = Decimal(string: amountStr)
        else {
            return nil
        }
        
        // Парсинг даты (UTC)
        guard
            let transactionDateStr = dict["transactionDate"] as? String,
            let transactionDate = ISO8601DateFormatter().date(from: transactionDateStr)
        else {
            return nil
        }
        
        // Парсинг комментария (необязательное поле)
        let comment = dict["comment"] as? String
        
        // Создание связанных объектов
        // Парсинг категории
        guard
            let categoryDict = dict["category"],
            let category = Category.parse(jsonObject: categoryDict)
        else {
            return nil
        }
        
        return Transaction(
            id: id,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment
        )
    }
    
    // MARK: - JSON Serialization
    
    var jsonObject: Any {
        [
            "id": id as NSNumber,
            "amount": amount.description,
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment as Any? ?? NSNull(),
            "category": [
                "id": category.id as NSNumber,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.isIncome
            ]
        ] as [String: Any]
    }
}
