//
//  TransactionsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation  

protocol TransactionsServiceProtocol {
  func getTransactions(for direction: Direction, in period: DateInterval) async -> [Transaction]
  func create(transaction: Transaction) async
  func update(transaction: Transaction) async
  func delete(withId id: Int) async
}

final class TransactionsService {
  
  // MARK: - Свойства инстанса
  
  private var cache = TransactionsFileCache()
  private let cacheName = "defaultTransactionCache"
  
  init() {
    cache.load(from: cacheName)
    cache.generateTransactions()
  }
  
  func getTransactions(for direction: Direction, in period: DateInterval) async -> [Transaction] {
    cache.transactions.filter {
      $0.category.direction == direction && period.contains($0.transactionDate)
    }
  }
  
  func create(transaction: Transaction) async {
    cache.insert(transaction)
    cache.save(to: cacheName)
  }
  
  func update(transaction: Transaction) async {
    cache.insert(transaction)
    cache.save(to: cacheName)
    print("🆑 update and save transaction")
  }
  
  func delete(withId id: Int) async {
    cache.remove(withId: id)
    cache.save(to: cacheName)
  }
}
