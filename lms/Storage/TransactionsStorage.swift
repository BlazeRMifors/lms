//
//  TransactionsStorage.swift
//  lms
//
//  Created by Ivan Isaev on 19.07.2025.
//

import Foundation

protocol TransactionsStorage {
    func all() async -> [Transaction]
    func get(id: Int) async -> Transaction?
    func insert(_ transaction: Transaction) async
    func update(_ transaction: Transaction) async
    func remove(id: Int) async
    func findAndRemove(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?) async
    func save() async
} 
