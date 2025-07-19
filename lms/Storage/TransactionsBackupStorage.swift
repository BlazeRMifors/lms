//
//  TransactionsBackupStorage.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation

enum TransactionBackupAction {
    case create
    case update
    case delete
}

struct TransactionBackupRecord {
    let transaction: Transaction
    let action: TransactionBackupAction
}

protocol TransactionsBackupStorage {
    func all() -> [TransactionBackupRecord]
    func insert(_ record: TransactionBackupRecord)
    func remove(id: Int)
    func save()
} 