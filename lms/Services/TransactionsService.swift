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
        var syncedLocalIds: [UUID] = []
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
                    // Удаляем временную транзакцию из storage (если она там есть)
                    await storage.findAndRemove(
                        accountId: record.transaction.accountId,
                        categoryId: record.transaction.category.id,
                        amount: record.transaction.amount,
                        transactionDate: record.transaction.transactionDate,
                        comment: record.transaction.comment
                    )
                    // НЕ вставляем серверную транзакцию - она будет загружена ниже
                case .update:
                    _ = try await api.updateTransaction(record.transaction)
                case .delete:
                    try await api.deleteTransaction(id: record.transaction.id)
                    // Удаляем транзакцию из storage
                    await storage.remove(id: record.transaction.id)
                }
                syncedLocalIds.append(record.localId)
            } catch {
                // не удалось синхронизировать — оставляем в бекапе
            }
        }
        // Удаляем синхронизированные из бекапа
        for localId in syncedLocalIds { backup.remove(localId: localId) }
        backup.save()
        
        // 2. Полностью очищаем storage и загружаем актуальные данные с сервера
        do {
            let transactions = try await api.getTransactions(accountId: accountId, startDate: period.start, endDate: period.end)
            
            // Полностью очищаем storage от транзакций данного аккаунта в данном периоде
            let existingTransactions = await storage.all()
            for tx in existingTransactions {
                if tx.accountId == accountId &&
                   tx.transactionDate >= period.start &&
                   tx.transactionDate <= period.end {
                    await storage.remove(id: tx.id)
                }
            }
            
            // Вставляем актуальные транзакции с сервера (без дублей)
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
            // 3. При ошибке — мержим storage и backup, удаляя дубли
            let local = await storage.all()
            let backupTx = backup.all()
                .filter { $0.action != .delete } // Исключаем транзакции, помеченные для удаления
                .map { $0.transaction }
            
            // Объединяем и удаляем дубли по id
            var transactionById: [Int: Transaction] = [:]
            for tx in (local + backupTx) {
                transactionById[tx.id] = tx
            }
            
            let merged = Array(transactionById.values)
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
            // Не добавляем в storage - транзакция будет загружена при следующем getTransactions()
            // await storage.insert(transaction)
            // await storage.save()
            backup.save()
            return transaction
        } catch {
            // fallback: добавляем в backup
            let tempId = Int(Date().timeIntervalSince1970 * 1000000) + Int.random(in: 100000...999999) // микросекунды + случайный компонент
            let tx = Transaction(id: tempId, accountId: accountId, category: category, amount: amount, transactionDate: transactionDate, comment: comment)
            let record = TransactionBackupRecord(localId: UUID(), transaction: tx, action: .create)
            backup.insert(record)
            backup.save()
            // Добавляем в storage для немедленного отображения
            await storage.insert(tx)
            await storage.save()
            return tx
        }
    }
    
    func update(transaction: Transaction) async throws -> Transaction {
        do {
            let updated = try await api.updateTransaction(transaction)
            // Не обновляем storage - транзакция будет загружена при следующем getTransactions()
            // await storage.update(updated)
            // await storage.save()
            backup.save()
            return updated
        } catch {
            let record = TransactionBackupRecord(localId: UUID(), transaction: transaction, action: .update)
            backup.insert(record)
            backup.save()
            return transaction
        }
    }
    
    func delete(withId id: Int) async throws {
        do {
            try await api.deleteTransaction(id: id)
            // Удаляем из storage сразу для немедленного отображения изменений
            await storage.remove(id: id)
            await storage.save()
            backup.save()
        } catch {
            if let tx = await storage.get(id: id) {
                let record = TransactionBackupRecord(localId: UUID(), transaction: tx, action: .delete)
                backup.insert(record)
                backup.save()
                // Удаляем из storage локально для немедленного отображения
                await storage.remove(id: id)
                await storage.save()
            }
        }
    }
}
