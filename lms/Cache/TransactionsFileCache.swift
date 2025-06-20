//
//  TransactionsFileCache.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol TransactionsFileCacheProtocol {
  var transactions: [Transaction] { get }
  
  func insert(_ transaction: Transaction)
  func remove(withId id: Int)
  
  func load(from cacheName: String)
  func save(to cacheName: String)
}

final class TransactionsFileCache {
  
  // MARK: - Свойства инстанса
  
  private(set) var transactions: [Transaction] = []
  
  private var currentFileURL: URL?
  private var currentCacheName: String?
  
  // MARK: - Операции с транзакциями
  
  func insert(_ transaction: Transaction) {
    if let idx = transactions.firstIndex(where: { $0.id == transaction.id }) {
      transactions[idx] = transaction
    } else {
      transactions.append(transaction)
    }
  }
  
  func remove(withId id: Int) {
    transactions.removeAll { $0.id == id }
  }
  
  // MARK: - Работа с файлами
  
  func load(from cacheName: String) {
    guard cacheName != currentCacheName else { return }
    
    saveCache()
    switchToCache(cacheName)
    loadCache()
  }
  
  func save(to cacheName: String?) {
    if let cacheName, cacheName != currentCacheName {
      switchToCache(cacheName)
    }
    saveCache()
  }
  
  // MARK: - приватные функции
  
  private func switchToCache(_ cacheName: String) {
    currentCacheName = cacheName
    
    if let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      currentFileURL = directory.appendingPathComponent("\(cacheName).json")
    }
  }
  
  private func loadCache() {
    guard let url = currentFileURL else { return }
    guard FileManager.default.fileExists(atPath: url.path) else { return }
    
    do {
      let data = try Data(contentsOf: url)
      let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
      transactions = jsonArray.compactMap(Transaction.parse(jsonObject:))
    } catch {
      print("Ошибка загрузки транзакций: \(error)")
      transactions = []
    }
  }
  
  private func saveCache() {
    guard let url = currentFileURL else { return }
    
    do {
      let jsonArray = transactions.map { $0.jsonObject }
      let data = try JSONSerialization.data(withJSONObject: jsonArray)
      try data.write(to: url)
    } catch {
      print("Ошибка сохранения файла: \(error)")
    }
  }
  
  // MARK: - Хуки жизненного цикла
  
  deinit {
    saveCache()
  }
}

//MARK: - Extension

extension TransactionsFileCache {
  func generateTransactions() {
    transactions = [
      makeSampleTransaction(id: 1, category: MockCategory.animal, amount: 1000, comment: "Корма для кошки"),
      makeSampleTransaction(id: 2, category: MockCategory.salary, amount: 150000),
      makeSampleTransaction(id: 3, category: MockCategory.freelance, amount: 28000, daysAgo: 4),
      makeSampleTransaction(id: 4, category: MockCategory.repair, amount: 100000, daysAgo: 2, comment: "Ремонт - фурнитура для дверей"),
      makeSampleTransaction(id: 5, category: MockCategory.transport, amount: 30000, daysAgo: 3, comment: "Техобслуживание"),
      makeSampleTransaction(id: 6, category: MockCategory.products, amount: 5700, daysAgo: 2, comment: "Для праздника"),
      makeSampleTransaction(id: 7, category: MockCategory.freelance, amount: 100000, comment: "Закрыли этап"),
      makeSampleTransaction(id: 8, category: MockCategory.products, amount: 3800),
    ]
    .sorted { $0.transactionDate > $1.transactionDate }
  }
  
  func makeSampleTransaction(
    id: Int,
    category: Category,
    amount: Decimal = 100,
    daysAgo: Int = 0,
    comment: String? = "Тестовая транзакция"
  ) -> Transaction {
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    
    return Transaction(
      id: id,
      category: category,
      amount: amount,
      transactionDate: date,
      comment: comment
    )
  }
}
