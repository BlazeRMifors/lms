//
//  TransactionDTO.swift
//  lms
//
//  Created by Ivan Isaev on 18.07.2025.
//

import Foundation

struct TransactionCreateDTO: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}

struct TransactionUpdateDTO: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    
    static func from(_ transaction: Transaction, dateFormatter: DateFormatter) -> TransactionUpdateDTO {
        TransactionUpdateDTO(
            accountId: transaction.accountId,
            categoryId: transaction.category.id,
            amount: NSDecimalNumber(decimal: transaction.amount).stringValue,
            transactionDate: dateFormatter.string(from: transaction.transactionDate),
            comment: transaction.comment
        )
    }
}

struct TransactionResponseDTO: Decodable, Identifiable {
    let id: Int
    let account: TransactionAccountDTO
    let category: TransactionCategoryDTO
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
    
    func toDomain() -> Transaction? {
        guard let amountDecimal = Decimal(string: amount),
              let date = ISO8601DateFormatter().date(from: transactionDate) else {
            return nil
        }
        
        return Transaction(
            id: id,
            accountId: account.id,
            category: category.toDomain(),
            amount: amountDecimal,
            transactionDate: date,
            comment: comment == "" ? nil : comment
        )
    }
}

struct TransactionCategoryDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    func toDomain() -> Category {
        return Category(id: id, name: name, emoji: emoji.first ?? " ", direction: isIncome ? .income : .outcome)
    }
}

struct TransactionAccountDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}

typealias TransactionListResponseDTO = [TransactionResponseDTO] 
