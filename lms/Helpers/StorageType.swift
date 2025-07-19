//
//  StorageType.swift
//  lms
//
//  Created by AI on 2025-07-19.
//

import Foundation

enum StorageType: String {
    case file
    case swiftdata
    case coredata
    
    static func current() -> StorageType {
        let raw = UserDefaults.standard.string(forKey: "storage_type") ?? "file"
        return StorageType(rawValue: raw) ?? .file
    }
}

func makeTransactionsStorage() -> TransactionsStorage {
    switch StorageType.current() {
    case .file:
        return TransactionsSwiftDataStorage() // если есть файловая реализация, заменить
    case .swiftdata:
        return TransactionsSwiftDataStorage()
    case .coredata:
        return TransactionsCoreDataStorage()
    }
}

func migrateTransactionsStorageIfNeeded() async {
    let lastType = UserDefaults.standard.string(forKey: "last_storage_type") ?? "file"
    let currentType = StorageType.current().rawValue
    guard lastType != currentType else { return }
    
    let oldType = StorageType(rawValue: lastType) ?? .file
    let newType = StorageType.current()
    
    let oldStorage: TransactionsStorage = {
        switch oldType {
        case .file: return TransactionsSwiftDataStorage() // заменить на файловую реализацию, если есть
        case .swiftdata: return TransactionsSwiftDataStorage()
        case .coredata: return TransactionsCoreDataStorage()
        }
    }()
    let newStorage: TransactionsStorage = makeTransactionsStorage()
    
    let allOld = await oldStorage.all()
    for tx in allOld {
        await newStorage.insert(tx)
    }
    await newStorage.save()
    // Очищаем старое хранилище
    for tx in allOld {
        await oldStorage.remove(id: tx.id)
    }
    await oldStorage.save()
    UserDefaults.standard.set(currentType, forKey: "last_storage_type")
} 