//
//  Transaction.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

struct Transaction: Identifiable, Hashable {
    let id: Int
    let accountId: Int
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
}
