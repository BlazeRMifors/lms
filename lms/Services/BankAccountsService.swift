//
//  BankAccountsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
  var myAccount: BankAccount? { get }
  func getUserAccount() async throws -> BankAccount
  func updateAccount(balance: Decimal, currency: Currency) async throws
}

final class BankAccountsService: BankAccountsServiceProtocol {
  
  private(set) var myAccount: BankAccount?
  
  func getUserAccount() async throws -> BankAccount {
    try await randomDelay()
    
    return BankAccount(
      id: 1,
      balance: Decimal(Int.random(in: 10_000...100_000)),
      currency: .rub
    )
  }
  
  func updateAccount(balance: Decimal, currency: Currency) async throws {
    try await randomDelay()
    
    myAccount = BankAccount(
      id: 1,
      balance: balance,
      currency: currency
    )
  }
  
  private func randomDelay(min: UInt64 = 1_000_000_000, max: UInt64 = 3_000_000_000) async throws {
    let delay = UInt64.random(in: min...max)
    try await Task.sleep(nanoseconds: delay)
  }
}
