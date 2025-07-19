//
//  TransactionsBackupFileStorage.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation

final class TransactionsBackupFileStorage: TransactionsBackupStorage {
    private var records: [TransactionBackupRecord] = []
    
    func all() -> [TransactionBackupRecord] {
        records
    }
    
    func insert(_ record: TransactionBackupRecord) {
        records.append(record)
    }
    
    func remove(id: Int) {
        records.removeAll { $0.transaction.id == id }
    }
    
    func save() {
        // TODO: persist to file/SwiftData
    }
} 