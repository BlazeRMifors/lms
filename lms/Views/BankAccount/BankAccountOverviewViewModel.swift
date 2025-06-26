//
//  BankAccountOverviewViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

class BankAccountOverviewViewModel: ObservableObject {
  @Published private(set) var balance: Decimal = 0
  @Published private(set) var currency: Currency = .rub
  @Published private(set) var isBalanceHidden = false
  @Published private(set) var isLoading = false
  
  private let service: BankAccountsServiceProtocol
  
  init(service: BankAccountsServiceProtocol) {
    self.service = service
  }
  
  func loadAccount() async {
    isLoading = true
    let account = try? await service.getUserAccount()
    if let account = account {
      balance = account.balance
      currency = account.currency
    }
    isLoading = false
  }
  
  func toggleBalanceVisibility() {
    withAnimation {
      isBalanceHidden.toggle()
    }
  }
  
  func refreshData() async {
    await loadAccount()
  }
  
  // Для отображения
  var formattedBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: Double(truncating: balance as NSNumber))) ?? "0"
  }
}
