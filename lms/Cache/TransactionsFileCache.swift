//
//  TransactionsFileCache.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

class TransactionsFileCache {
    
    // MARK: - Свойства инстанса
    
    private var transactions: [Transaction] = []
    
    private var currentFileURL: URL?
    private var currentCacheName: String?
    
    // MARK: - Операции с транзакциями
    
    func getAll() -> [Transaction] {
        transactions
    }
    
    func insert(_ transaction: Transaction) {
        if transactions.contains(where: { $0.id == transaction.id }) {
            transactions = transactions.map { $0.id == transaction.id ? transaction : $0 }
        } else {
            transactions.append(transaction)
        }
    }
    
    func remove(withId id: Int) {
        transactions.removeAll { $0.id == id }
    }
    
    func replaceAll(_ transactions: [Transaction]) {
        self.transactions = transactions
    }
    
    func reset() {
        self.transactions = []
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
        // Так как это кэш, нет особого смысла хранить его в основной директории для документов пользователя
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        currentFileURL = directory.appendingPathComponent("\(cacheName).json")
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
