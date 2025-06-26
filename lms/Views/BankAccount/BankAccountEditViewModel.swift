//
//  BankAccountEditViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

class BankAccountEditViewModel: ObservableObject {
  @Published var balanceText = ""
  @Published var selectedCurrency: Currency = .rub
  
  private let originalBalance: Decimal
  private let originalCurrency: Currency
  private let service: BankAccountsServiceProtocol
  
  init(service: BankAccountsServiceProtocol, initialBalance: Decimal, initialCurrency: Currency) {
    self.service = service
    self.originalBalance = initialBalance
    self.originalCurrency = initialCurrency
    self.balanceText = formatDecimal(initialBalance)
    self.selectedCurrency = initialCurrency
  }
  
  private func formatDecimal(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: Double(truncating: originalBalance as NSNumber))) ?? "0"
  }
  
  func updateBalance(_ text: String) {
    let filteredText = text.filter { "0123456789.".contains($0) }
    balanceText = filteredText
  }
  
  func saveChanges() async {
    guard let newBalance = Decimal(string: balanceText) else { return }
    try? await service.updateAccount(balance: newBalance, currency: selectedCurrency)
  }
  
  func cancelChanges() {
    balanceText = formatDecimal(originalBalance)
    selectedCurrency = originalCurrency
  }
}
