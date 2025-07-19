//
//  TransactionsSwiftDataStorage.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryModel {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool

    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }

    func toDomain() -> Category {
        Category(id: id, name: name, emoji: emoji.first ?? " ", direction: isIncome ? .income : .outcome)
    }

    static func from(_ category: Category) -> CategoryModel {
        CategoryModel(id: category.id, name: category.name, emoji: String(category.emoji), isIncome: category.direction == .income)
    }
}

@Model
final class TransactionModel {
    @Attribute(.unique) var id: Int
    var accountId: Int
    @Relationship var category: CategoryModel
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    
    init(id: Int, accountId: Int, category: CategoryModel, amount: Decimal, transactionDate: Date, comment: String?) {
        self.id = id
        self.accountId = accountId
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
    }
    
    func toDomain() -> Transaction {
        Transaction(id: id, accountId: accountId, category: category.toDomain(), amount: amount, transactionDate: transactionDate, comment: comment)
    }
    
    static func from(_ tx: Transaction) -> TransactionModel {
        TransactionModel(id: tx.id, accountId: tx.accountId, category: CategoryModel.from(tx.category), amount: tx.amount, transactionDate: tx.transactionDate, comment: tx.comment)
    }
}

final class TransactionsSwiftDataStorage: TransactionsStorage {
    private let container: ModelContainer
    
    init() {
        let schema = Schema([TransactionModel.self, CategoryModel.self])
        container = try! ModelContainer(for: schema)
    }
    
    func all() async -> [Transaction] {
        return await MainActor.run {
            let context = container.mainContext
            let models = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            return models.map { $0.toDomain() }
        }
    }
    
    func get(id: Int) async -> Transaction? {
        return await MainActor.run {
            let context = container.mainContext
            let allModels = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            return allModels.first { $0.id == id }?.toDomain()
        }
    }
    
    func insert(_ transaction: Transaction) async {
        await MainActor.run {
            let context = container.mainContext
            let model = TransactionModel.from(transaction)
            context.insert(model)
        }
    }
    
    func update(_ transaction: Transaction) async {
        await MainActor.run {
            let context = container.mainContext
            let allModels = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            if let model = allModels.first(where: { $0.id == transaction.id }) {
                model.accountId = transaction.accountId
                model.category = CategoryModel.from(transaction.category)
                model.amount = transaction.amount
                model.transactionDate = transaction.transactionDate
                model.comment = transaction.comment
            }
        }
    }
    
    func remove(id: Int) async {
        await MainActor.run {
            let context = container.mainContext
            let allModels = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            if let model = allModels.first(where: { $0.id == id }) {
                context.delete(model)
            }
        }
    }
    
    func save() async {
        await MainActor.run {
            let context = container.mainContext
            try? context.save()
        }
    }
} 
