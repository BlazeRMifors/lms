//
//  BankAccountFileCache.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation

protocol BankAccountCacheProtocol {
    func save(account: BankAccount)
    func load() -> BankAccount?
    func delete(id: Int)
}

final class BankAccountFileCache: BankAccountCacheProtocol {
    private let fileName = "bank_account_cache.json"
    
    func save(account: BankAccount) {
        guard let url = getFileURL() else { return }
        let dict: [String: Any] = [
            "id": account.id,
            "name": account.name,
            "balance": account.balance.description,
            "currency": account.currency.rawValue
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            try data.write(to: url)
        } catch {
            print("[BankAccountFileCache] Ошибка сохранения: \(error)")
        }
    }
    
    func load() -> BankAccount? {
        guard let url = getFileURL() else { return nil }
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
            guard let id = dict["id"] as? Int,
                  let name = dict["name"] as? String,
                  let balanceStr = dict["balance"] as? String,
                  let balance = Decimal(string: balanceStr),
                  let currencyRaw = dict["currency"] as? String,
                  let currency = Currency(rawValue: currencyRaw)
            else { return nil }
            return BankAccount(id: id, name: name, balance: balance, currency: currency)
        } catch {
            print("[BankAccountFileCache] Ошибка загрузки: \(error)")
            return nil
        }
    }
    
    func delete(id: Int) {
        guard let url = getFileURL() else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("[BankAccountFileCache] Ошибка удаления: \(error)")
            }
        }
    }
    
    private func getFileURL() -> URL? {
        let fileManager = FileManager.default
        do {
            let appSupportURLs = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            guard let appSupportURL = appSupportURLs.first else { return nil }
            let cacheDirectory = appSupportURL.appendingPathComponent("BankAccountCache", isDirectory: true)
            if !fileManager.fileExists(atPath: cacheDirectory.path) {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            return cacheDirectory.appendingPathComponent(fileName)
        } catch {
            print("[BankAccountFileCache] Ошибка при получении или создании директории: \(error)")
            return nil
        }
    }
} 
