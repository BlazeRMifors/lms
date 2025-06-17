//
//  BankAccountsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

final class BankAccountsService {
    
    private var mockAccount = BankAccount(
        id: 1,
        balance: 1000.00,
        currency: .rub
    )
    
    func getUserAccount() async -> BankAccount {
        return mockAccount
    }
    
    func updateAccount(balance: Decimal, currency: Currency) async {
        mockAccount = BankAccount(
            id: mockAccount.id,
            balance: balance,
            currency: currency
        )
    }
}
