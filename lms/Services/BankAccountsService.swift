//
//  BankAccountsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
    func getUserAccount() async throws -> BankAccount
    func updateAccount(balance: Decimal, currency: Currency) async throws -> BankAccount
}

final class BankAccountsService: BankAccountsServiceProtocol {
    private let api: BankAccountsAPIProtocol
    private var myAccount: BankAccount? = nil
    
    init(api: BankAccountsAPIProtocol = BankAccountsAPI(client: Client())) {
        self.api = api
    }
    
    func getUserAccount() async throws -> BankAccount {
        if let cached = myAccount {
            return cached
        }
        let account = try await api.fetchAccount()
        self.myAccount = account
        return account
    }
    
    @discardableResult
    func updateAccount(balance: Decimal, currency: Currency) async throws -> BankAccount {
        guard let account = myAccount else {
            throw NetworkError.unknown(NSError(domain: "BankAccountsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить текущий счет для обновления. Попробуйте позже."]))
        }
        let updated = try await api.updateAccount(account, balance: balance, currency: currency)
        self.myAccount = updated
        return updated
    }
}
