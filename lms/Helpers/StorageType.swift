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