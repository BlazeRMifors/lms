//
//  BankAccountEditViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

@Observable
final class BankAccountEditViewModel {
  var balance: String = "0"
  var currency: Currency = .rub
  
  init(balance: Decimal, currency: Currency) {
    self.balance = formatDecimal(balance)
    self.currency = currency
  }
  
  private func formatDecimal(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: value as NSNumber) ?? "0"
  }
  
  func updateBalance(_ text: String) {
    let filteredText = text.filter { "-0123456789.".contains($0) }
    let value = Decimal(string: filteredText) ?? 0
    balance = formatDecimal(value)
  }
}
