//
//  TransactionsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

final class TransactionsService {
    
    // MARK: - Свойства инстанса
    
    private var cache = TransactionsFileCache()
    private let cacheName = "defaultTransactionCache"
    
    init() {
        cache.load(from: cacheName)
    }
    
    func getTransactions(for period: DateInterval) async -> [Transaction] {
//        cache.getAll().filter {
//            period.contains($0.transactionDate)
//        }
      await [
        Transaction(id: 1, category: CategoriesService().getAllCategories()[0], amount: 1000, transactionDate: Date(), comment: "Test"),
        Transaction(id: 2, category: CategoriesService().getAllCategories()[1], amount: 1500, transactionDate: Date(), comment: nil),
      ]
    }
    
    func create(transaction: Transaction) async {
        cache.insert(transaction)
        cache.save(to: cacheName)
    }
    
    func update(transaction: Transaction) async {
        cache.insert(transaction)
        cache.save(to: cacheName)
    }
    
    func delete(withId id: Int) async {
        cache.remove(withId: id)
        cache.save(to: cacheName)
    }
}
