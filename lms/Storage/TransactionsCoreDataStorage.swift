//
//  TransactionsCoreDataStorage.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation
import CoreData

final class TransactionsCoreDataStorage: TransactionsStorage {
    private let container: NSPersistentContainer
    
    init(modelName: String = "TransactionsModel") {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("[TransactionsCoreDataStorage] Ошибка инициализации: \(error)")
            }
        }
    }
    
    private var context: NSManagedObjectContext { container.viewContext }
    
    func all() async -> [Transaction] {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        do {
            let result = try context.fetch(request)
            return result.compactMap { $0.toDomain() }
        } catch {
            print("[TransactionsCoreDataStorage] Ошибка получения всех: \(error)")
            return []
        }
    }
    
    func get(id: Int) async -> Transaction? {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try context.fetch(request)
            return result.first?.toDomain()
        } catch {
            print("[TransactionsCoreDataStorage] Ошибка получения по id: \(error)")
            return nil
        }
    }
    
    func insert(_ transaction: Transaction) async {
        let entity = TransactionEntity(context: context)
        entity.fromDomain(transaction)
        await save()
    }
    
    func update(_ transaction: Transaction) async {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %d", transaction.id)
        do {
            let result = try context.fetch(request)
            if let entity = result.first {
                entity.fromDomain(transaction)
                await save()
            }
        } catch {
            print("[TransactionsCoreDataStorage] Ошибка обновления: \(error)")
        }
    }
    
    func remove(id: Int) async {
        let context = container.viewContext
        await context.perform {
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Transaction")
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let results = try context.fetch(request)
                for object in results {
                    context.delete(object)
                }
            } catch {
                print("[TransactionsCoreDataStorage] Ошибка удаления: \(error)")
            }
        }
    }
    
    func findAndRemove(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?) async {
        let context = container.viewContext
        await context.perform {
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Transaction")
            
            // Создаем составной предикат для поиска по параметрам
            var predicates: [NSPredicate] = [
                NSPredicate(format: "accountId == %d", accountId),
                NSPredicate(format: "categoryId == %d", categoryId),
                NSPredicate(format: "amount == %@", amount as NSDecimalNumber),
                NSPredicate(format: "ABS(transactionDate.timeIntervalSinceDate:%@) < 60", transactionDate as NSDate)
            ]
            
            if let comment = comment {
                predicates.append(NSPredicate(format: "comment == %@", comment))
            } else {
                predicates.append(NSPredicate(format: "comment == nil"))
            }
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            do {
                let results = try context.fetch(request)
                for object in results {
                    context.delete(object)
                }
            } catch {
                print("[TransactionsCoreDataStorage] Ошибка поиска и удаления: \(error)")
            }
        }
    }
    
    func save() async {
        let context = container.viewContext
        await context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("[TransactionsCoreDataStorage] Ошибка сохранения: \(error)")
                }
            }
        }
    }
}

// MARK: - CoreData Entity

@objc(TransactionEntity)
final class TransactionEntity: NSManagedObject {
    @NSManaged var id: Int32
    @NSManaged var accountId: Int32
    @NSManaged var categoryId: Int32
    @NSManaged var amount: String
    @NSManaged var transactionDate: Date
    @NSManaged var comment: String?
    // Для простоты: categoryId, categoryName, categoryEmoji, categoryIsIncome
    @NSManaged var categoryName: String
    @NSManaged var categoryEmoji: String
    @NSManaged var categoryIsIncome: Bool
    
    func toDomain() -> Transaction? {
        guard let amountDecimal = Decimal(string: amount) else { return nil }
        let category = Category(
            id: Int(categoryId),
            name: categoryName,
            emoji: categoryEmoji.first ?? " ",
            direction: categoryIsIncome ? .income : .outcome
        )
        return Transaction(
            id: Int(id),
            accountId: Int(accountId),
            category: category,
            amount: amountDecimal,
            transactionDate: transactionDate,
            comment: comment
        )
    }
    
    func fromDomain(_ tx: Transaction) {
        id = Int32(tx.id)
        accountId = Int32(tx.accountId)
        categoryId = Int32(tx.category.id)
        amount = tx.amount.description
        transactionDate = tx.transactionDate
        comment = tx.comment
        categoryName = tx.category.name
        categoryEmoji = String(tx.category.emoji)
        categoryIsIncome = tx.category.direction == .income
    }
} 