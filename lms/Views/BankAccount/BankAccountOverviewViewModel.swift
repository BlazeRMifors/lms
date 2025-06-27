//
//  BankAccountOverviewViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

@Observable
final class BankAccountOverviewViewModel {
  private(set) var balance: Decimal = 0
  private(set) var currency: Currency = .rub
  private(set) var isBalanceHidden = false
  
  init(balance: Decimal, currency: Currency, isBalanceHidden: Bool = false) {
    self.balance = balance
    self.currency = currency
    self.isBalanceHidden = isBalanceHidden
  }
  
  func toggleBalanceVisibility() {
    isBalanceHidden.toggle()
  }
}
