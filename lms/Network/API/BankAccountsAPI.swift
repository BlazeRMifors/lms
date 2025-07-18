//
//  BankAccountsAPI.swift
//  lms
//
//  Created by Ivan Isaev on 20.07.2025.
//

import Foundation

protocol BankAccountsAPIProtocol {
    func fetchAccount() async throws -> BankAccount
    func updateAccount(_ account: BankAccount, balance: Decimal, currency: Currency) async throws -> BankAccount
}

final class BankAccountsAPI: BankAccountsAPIProtocol {
    private let networkClient: NetworkClient
    
    init(client: NetworkClient) {
        self.networkClient = client
    }
    
    func fetchAccount() async throws -> BankAccount {
        let request = Request.get(url: ApiEndpoints.accounts)
        let dtos: [BankAccountResponseDTO] = try await networkClient.send(request)
        guard let first = dtos.first, let account = first.toDomain() else {
            throw NetworkError.decodingError(NSError(domain: "BankAccountsAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет доступных счетов"]))
        }
        return account
    }
    
    func updateAccount(_ account: BankAccount, balance: Decimal, currency: Currency) async throws -> BankAccount {
        let dto = BankAccountUpdateDTO.from(account: account, balance: balance, currency: currency)
        let request = Request.put(url: ApiEndpoints.account(id: account.id), body: dto)
        let response: BankAccountResponseDTO = try await networkClient.send(request)
        guard let updated = response.toDomain() else {
            throw NetworkError.decodingError(NSError(domain: "BankAccountsAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка обновления счета"]))
        }
        return updated
    }
} 
