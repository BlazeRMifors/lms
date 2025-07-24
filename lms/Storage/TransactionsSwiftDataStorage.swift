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
            let transactions = models.map { $0.toDomain() }
            
            // Дедупликация по id на всякий случай
            var uniqueTransactions: [Int: Transaction] = [:]
            for tx in transactions {
                uniqueTransactions[tx.id] = tx
            }
            
            return Array(uniqueTransactions.values)
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
            
            // Проверяем, есть ли уже транзакция с таким id
            let allModels = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            if let existingModel = allModels.first(where: { $0.id == transaction.id }) {
                // Обновляем существующую транзакцию
                // Ищем существующую категорию или создаём новую
                let categoryModels = (try? context.fetch(FetchDescriptor<CategoryModel>())) ?? []
                let categoryModel = categoryModels.first { $0.id == transaction.category.id } ?? {
                    let newCategory = CategoryModel.from(transaction.category)
                    context.insert(newCategory)
                    return newCategory
                }()
                
                existingModel.accountId = transaction.accountId
                existingModel.category = categoryModel
                existingModel.amount = transaction.amount
                existingModel.transactionDate = transaction.transactionDate
                existingModel.comment = transaction.comment
            } else {
                // Создаём новую транзакцию
                // Ищем существующую категорию или создаём новую
                let categoryModels = (try? context.fetch(FetchDescriptor<CategoryModel>())) ?? []
                let categoryModel = categoryModels.first { $0.id == transaction.category.id } ?? {
                    let newCategory = CategoryModel.from(transaction.category)
                    context.insert(newCategory)
                    return newCategory
                }()
                
                // Создаём TransactionModel с существующей CategoryModel
                let model = TransactionModel(
                    id: transaction.id,
                    accountId: transaction.accountId,
                    category: categoryModel,
                    amount: transaction.amount,
                    transactionDate: transaction.transactionDate,
                    comment: transaction.comment
                )
                context.insert(model)
            }
        }
    }
    
    func update(_ transaction: Transaction) async {
        await MainActor.run {
            let context = container.mainContext
            let allModels = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            if let model = allModels.first(where: { $0.id == transaction.id }) {
                // Ищем существующую категорию или создаём новую
                let categoryModels = (try? context.fetch(FetchDescriptor<CategoryModel>())) ?? []
                let categoryModel = categoryModels.first { $0.id == transaction.category.id } ?? {
                    let newCategory = CategoryModel.from(transaction.category)
                    context.insert(newCategory)
                    return newCategory
                }()
                
                model.accountId = transaction.accountId
                model.category = categoryModel
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
    
    func findAndRemove(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?) async {
        await MainActor.run {
            let context = container.mainContext
            let allModels = (try? context.fetch(FetchDescriptor<TransactionModel>())) ?? []
            
            // Находим транзакции с совпадающими параметрами
            let matchingModels = allModels.filter { model in
                model.accountId == accountId &&
                model.category.id == categoryId &&
                model.amount == amount &&
                abs(model.transactionDate.timeIntervalSince(transactionDate)) < 60 && // разница меньше минуты
                model.comment == comment
            }
            
            // Удаляем найденные транзакции
            for model in matchingModels {
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
