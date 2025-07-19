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
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static func from(_ transaction: Transaction) -> TransactionUpdateDTO {
        TransactionUpdateDTO(
            accountId: transaction.accountId,
            categoryId: transaction.category.id,
            amount: NSDecimalNumber(decimal: transaction.amount).stringValue,
            transactionDate: iso8601Formatter.string(from: transaction.transactionDate),
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
    
    private static let iso8601FormatterWithMs: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func toDomain() -> Transaction? {
        guard let amountDecimal = Decimal(string: amount) else { return nil }
        let date = Self.iso8601FormatterWithMs.date(from: transactionDate)
            ?? Self.iso8601Formatter.date(from: transactionDate)
        guard let parsedDate = date else { return nil }
        
        return Transaction(
            id: id,
            accountId: account.id,
            category: category.toDomain(),
            amount: amountDecimal,
            transactionDate: parsedDate,
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
