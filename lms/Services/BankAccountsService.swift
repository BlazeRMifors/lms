//
//  BankAccountsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
    func getAccountId() async throws -> Int
    func getUserAccount() async throws -> BankAccount
    func updateAccount(balance: Decimal, currency: Currency) async throws -> BankAccount
}

final class BankAccountsService: BankAccountsServiceProtocol {
    private let api: BankAccountsAPIProtocol
    private let cache: BankAccountCacheProtocol
    private let backup: BankAccountBackupStorageProtocol
    private var myAccount: BankAccount? = nil
    
    init(
        api: BankAccountsAPIProtocol = BankAccountsAPI(client: Client()),
        cache: BankAccountCacheProtocol = BankAccountFileCache(),
        backup: BankAccountBackupStorageProtocol = BankAccountBackupFileCache()
    ) {
        self.api = api
        self.cache = cache
        self.backup = backup
    }
    
    func getAccountId() async throws -> Int {
        if let cached = myAccount {
            return cached.id
        }
        return try await getUserAccount().id
    }
    
    func getUserAccount() async throws -> BankAccount {
        do {
            let account = try await api.fetchAccount()
            self.myAccount = account
            cache.save(account: account)
            backup.removeBackup(id: account.id)
            return account
        } catch {
            // Если не удалось получить из сети — пробуем из кэша
            if let cached = cache.load() {
                self.myAccount = cached
                return cached
            }
            throw error
        }
    }
    
    @discardableResult
    func updateAccount(balance: Decimal, currency: Currency) async throws -> BankAccount {
        guard let account = myAccount ?? cache.load() else {
            throw NetworkError.unknown(NSError(domain: "BankAccountsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить текущий счет для обновления. Попробуйте позже."]))
        }
        do {
            let updated = try await api.updateAccount(account, balance: balance, currency: currency)
            self.myAccount = updated
            cache.save(account: updated)
            backup.removeBackup(id: updated.id)
            return updated
        } catch {
            // При ошибке — добавляем в бэкап
            let backupItem = BankAccountBackupItem(id: account.id, account: account, action: .update)
            backup.saveBackup(backupItem)
            throw error
        }
    }
}
