//
//  BankAccountBackupFileCache.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation

enum BankAccountBackupAction: String, Codable {
    case create
    case update
    case delete
}

struct BankAccountBackupItem: Codable, Identifiable {
    let id: Int
    let account: BankAccount
    let action: BankAccountBackupAction
}

protocol BankAccountBackupStorageProtocol {
    func saveBackup(_ item: BankAccountBackupItem)
    func loadBackups() -> [BankAccountBackupItem]
    func removeBackup(id: Int)
}

final class BankAccountBackupFileCache: BankAccountBackupStorageProtocol {
    private let fileName = "bank_account_backup.json"
    
    func saveBackup(_ item: BankAccountBackupItem) {
        var items = loadBackups()
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
        } else {
            items.append(item)
        }
        save(items: items)
    }
    
    func loadBackups() -> [BankAccountBackupItem] {
        guard let url = getFileURL(), FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([BankAccountBackupItem].self, from: data)
            return items
        } catch {
            print("[BankAccountBackupFileCache] Ошибка загрузки: \(error)")
            return []
        }
    }
    
    func removeBackup(id: Int) {
        var items = loadBackups()
        items.removeAll { $0.id == id }
        save(items: items)
    }
    
    private func save(items: [BankAccountBackupItem]) {
        guard let url = getFileURL() else { return }
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url)
        } catch {
            print("[BankAccountBackupFileCache] Ошибка сохранения: \(error)")
        }
    }
    
    private func getFileURL() -> URL? {
        let fileManager = FileManager.default
        do {
            let appSupportURLs = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            guard let appSupportURL = appSupportURLs.first else { return nil }
            let cacheDirectory = appSupportURL.appendingPathComponent("BankAccountBackup", isDirectory: true)
            if !fileManager.fileExists(atPath: cacheDirectory.path) {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            return cacheDirectory.appendingPathComponent(fileName)
        } catch {
            print("[BankAccountBackupFileCache] Ошибка при получении или создании директории: \(error)")
            return nil
        }
    }
} 