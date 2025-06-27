//
//  BankAccountCoordinatorViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import Foundation
import SwiftUI

enum BankAccountViewState: Equatable {
  case overview
  case edit
}

class BankAccountCoordinatorViewModel: ObservableObject {
  @Published var currentState: BankAccountViewState = .overview
  @Published var errorMessage: String? = nil
  
  private(set) var service: BankAccountsServiceProtocol
  private(set) var account: BankAccount?
  
  init(service: BankAccountsServiceProtocol) {
    self.service = service
  }
  
  // MARK: - Load Account
  func loadAccount() async {
    do {
      let loadedAccount = try await service.getUserAccount()
      await MainActor.run {
        account = loadedAccount
      }
    } catch {
      await MainActor.run {
        errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
      }
    }
  }
  
  // MARK: - Switch to Edit Mode
  func enterEditMode() {
//    guard let account = account else { return }
    currentState = .edit
  }
  
  // MARK: - Save Changes
  func saveChanges(balance: Decimal, currency: Currency) async {
    print("balance: \(balance), currency: \(currency)")
    do {
      try await service.updateAccount(balance: balance, currency: currency)
      await MainActor.run {
        account = BankAccount(id: account?.id ?? 1, balance: balance, currency: currency)
        currentState = .overview
      }
    } catch {
      await MainActor.run {
        errorMessage = "Ошибка сохранения: \(error.localizedDescription)"
      }
    }
  }
  
  // MARK: - Cancel Edit
  func cancelEdit() {
    currentState = .overview
  }
}
