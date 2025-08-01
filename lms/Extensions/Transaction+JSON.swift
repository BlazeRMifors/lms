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
        
        // Парсинг accountId
        let accountId: Int
        if let accIdInt = dict["accountId"] as? Int {
            accountId = accIdInt
        } else if let accIdStr = dict["accountId"] as? String, let accIdInt = Int(accIdStr) {
            accountId = accIdInt
        } else {
            return nil
        }
        
        // Парсинг категории
        guard
            let categoryDict = dict["category"],
            let category = Category.parse(jsonObject: categoryDict)
        else {
            return nil
        }
        
        return Transaction(
            id: id,
            accountId: accountId,
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
            "accountId": accountId,
            "amount": amount.description,
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment as Any? ?? NSNull(),
            "category": [
                "id": category.id as NSNumber,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.direction == .income
            ]
        ] as [String: Any]
    }
}
