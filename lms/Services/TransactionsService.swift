//
//  TransactionsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol TransactionsServiceProtocol {
    func getTransactions(for direction: Direction, in period: DateInterval) async -> [Transaction]
    func getTransactions(for accountId: Int, with direction: Direction, in period: DateInterval) async throws -> [Transaction]
    func create(accountId: Int, category: Category, amount: Decimal, transactionDate: Date, comment: String?) async throws -> Transaction
    func update(transaction: Transaction) async throws -> Transaction
    func delete(withId id: Int) async throws
}

final class TransactionsService: TransactionsServiceProtocol {
    private let api: TransactionsAPIProtocol
    private let storage: TransactionsStorage
    private let backup: TransactionsBackupStorage
    
    init(
        api: TransactionsAPIProtocol = TransactionsAPI(client: Client()),
        storage: TransactionsStorage? = nil,
        backup: TransactionsBackupStorage = TransactionsBackupFileStorage()
    ) {
        self.api = api
        self.storage = storage ?? TransactionsSwiftDataStorage()
        self.backup = backup
    }
    
    func getTransactions(for direction: Direction, in period: DateInterval) async -> [Transaction] {
        []
    }
    
    func getTransactions(for accountId: Int, with direction: Direction, in period: DateInterval) async throws -> [Transaction] {
        // 1. Попытка выгрузить бекап на бэкенд
        let backupRecords = backup.all()
        var syncedIds: [Int] = []
        for record in backupRecords {
            do {
                switch record.action {
                case .create:
                    _ = try await api.createTransaction(
                        accountId: record.transaction.accountId,
                        categoryId: record.transaction.category.id,
                        amount: record.transaction.amount,
                        transactionDate: record.transaction.transactionDate,
                        comment: record.transaction.comment
                    )
                case .update:
                    _ = try await api.updateTransaction(record.transaction)
                case .delete:
                    try await api.deleteTransaction(id: record.transaction.id)
                }
                syncedIds.append(record.transaction.id)
            } catch {
                // не удалось синхронизировать — оставляем в бекапе
            }
        }
        // Удаляем синхронизированные из бекапа
        for id in syncedIds { backup.remove(id: id) }
        backup.save()
        
        // 2. Пробуем получить с сервера
        do {
            let transactions = try await api.getTransactions(accountId: accountId, startDate: period.start, endDate: period.end)
            for tx in transactions {
                await storage.insert(tx)
            }
            await storage.save()
            return transactions
                .filter { tx in
                    tx.accountId == accountId &&
                    tx.category.direction == direction &&
                    tx.transactionDate >= period.start &&
                    tx.transactionDate <= period.end
                }
        } catch {
            // 4. При ошибке — мержим storage и backup
            let local = await storage.all()
            let backupTx = backup.all().map { $0.transaction }
            let merged = (local + backupTx)
                .filter { tx in
                    tx.accountId == accountId &&
                    tx.category.direction == direction &&
                    tx.transactionDate >= period.start &&
                    tx.transactionDate <= period.end
                }
            return merged
        }
    }
    
    func create(accountId: Int, category: Category, amount: Decimal, transactionDate: Date, comment: String?) async throws -> Transaction {
        do {
            let transaction = try await api.createTransaction(
                accountId: accountId,
                categoryId: category.id,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment
            )
            await storage.insert(transaction)
            await storage.save()
            backup.remove(id: transaction.id)
            backup.save()
            return transaction
        } catch {
            // fallback: добавляем в backup
            let tempId = Int(Date().timeIntervalSince1970)
            let tx = Transaction(id: tempId, accountId: accountId, category: category, amount: amount, transactionDate: transactionDate, comment: comment)
            backup.insert(TransactionBackupRecord(transaction: tx, action: .create))
            backup.save()
            return tx
        }
    }
    
    func update(transaction: Transaction) async throws -> Transaction {
        do {
            let updated = try await api.updateTransaction(transaction)
            await storage.update(updated)
            await storage.save()
            backup.remove(id: updated.id)
            backup.save()
            return updated
        } catch {
            backup.insert(TransactionBackupRecord(transaction: transaction, action: .update))
            backup.save()
            return transaction
        }
    }
    
    func delete(withId id: Int) async throws {
        do {
            try await api.deleteTransaction(id: id)
            await storage.remove(id: id)
            await storage.save()
            backup.remove(id: id)
            backup.save()
        } catch {
            if let tx = await storage.get(id: id) {
                backup.insert(TransactionBackupRecord(transaction: tx, action: .delete))
                backup.save()
            }
        }
    }
}
