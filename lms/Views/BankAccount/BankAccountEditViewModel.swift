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
  
  var onSave: ((Decimal, Currency) -> Void)?
  
  init(balance: Decimal, currency: Currency, onSave: ((Decimal, Currency) -> Void)? = nil) {
    self.balance = formatDecimal(balance)
    self.currency = currency
    self.onSave = onSave
  }
  
  private func formatDecimal(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: value as NSNumber) ?? "0"
  }
  
  func updateBalance(_ text: String) {
    let filteredText = text.filter { "-0123456789., ".contains($0) }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let value = formatter.number(from: filteredText)?.decimalValue ?? 0
    balance = formatDecimal(value)
  }
  
  func save() {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let balanceValue = formatter.number(from: balance)?.decimalValue ?? 0
    onSave?(balanceValue, currency)
  }
}
