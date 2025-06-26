//
//  BankAccountsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
  func getUserAccount() async throws -> BankAccount
  func updateAccount(balance: Decimal, currency: Currency) async throws
}

final class BankAccountsService: BankAccountsServiceProtocol {
  
  private var mockAccount = BankAccount(
    id: 1,
    balance: 1000.00,
    currency: .rub
  )
  
  func getUserAccount() async throws -> BankAccount {
    try await randomDelay()
    return mockAccount
  }
  
  func updateAccount(balance: Decimal, currency: Currency) async throws {
    try await randomDelay()
    mockAccount = BankAccount(
      id: mockAccount.id,
      balance: balance,
      currency: currency
    )
  }
  
  private func randomDelay(min: UInt64 = 1_000_000_000, max: UInt64 = 3_000_000_000) async throws {
    let delay = UInt64.random(in: min...max)
    try await Task.sleep(nanoseconds: delay)
  }
}
