//
//  AccountCoordinatorView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

struct BankAccountCoordinatorView: View {
  @StateObject private var coordinatorVM: BankAccountCoordinatorViewModel
  
  init(service: BankAccountsServiceProtocol) {
    _coordinatorVM = StateObject(wrappedValue: BankAccountCoordinatorViewModel(service: service))
  }
  
  var body: some View {
    NavigationStack {
      switch coordinatorVM.currentState {
      case .overview:
        BankAccountOverviewView(viewModel: BankAccountOverviewViewModel(service: coordinatorVM.service))
          .environmentObject(coordinatorVM)
      case .edit:
        if let account = coordinatorVM.account {
          BankAccountEditView(viewModel: BankAccountEditViewModel(
            service: coordinatorVM.service,
            initialBalance: account.balance,
            initialCurrency: account.currency
          ))
          .environmentObject(coordinatorVM)
        } else {
          Text("Загрузка данных...")
        }
      }
    }
    .navigationTitle("Мой счет")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          coordinatorVM.enterEditMode()
        } label: {
          Text("Редактировать")
        }
      }
    }
//    .alert(item: $coordinatorVM.errorMessage) { error in
//      Alert(title: Text("Ошибка"), message: Text(error), dismissButton: .default(Text("OK")))
//    }
    .task {
      if coordinatorVM.account == nil {
        await coordinatorVM.loadAccount()
      }
    }
  }
}

#Preview {
  NavigationStack {  
    BankAccountCoordinatorView(service: BankAccountsService())
  }
}
