//
//  BankAccountOverviewViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

@Observable
final class BankAccountOverviewViewModel {
  private let service: BankAccountsServiceProtocol
  
  var balance: Decimal = 0
  var currency: Currency = .rub
  private(set) var isBalanceHidden = false
  private(set) var isLoading = false
  
  init(service: BankAccountsServiceProtocol, balance: Decimal, currency: Currency, isBalanceHidden: Bool = false) {
    self.service = service
    self.balance = balance
    self.currency = currency
    self.isBalanceHidden = isBalanceHidden
  }
  
  func toggleBalanceVisibility() {
    isBalanceHidden.toggle()
  }
  
  func updateData(balance: Decimal, currency: Currency) {
    self.balance = balance
    self.currency = currency
  }
  
  @MainActor
  func refreshData() async {
    print("refreshData started")
    isLoading = true
    
    do {
      let account = try await service.getUserAccount()
      print("Received account: balance=\(account.balance), currency=\(account.currency)")
      balance = account.balance
      currency = account.currency
    } catch {
      // В реальном приложении здесь можно показать ошибку
      print("Ошибка при обновлении данных: \(error)")
    }
    
    isLoading = false
    print("refreshData completed")
  }
}
