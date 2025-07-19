//
//  AccountCoordinatorView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

struct BankAccountCoordinatorView: View {
  @StateObject private var coordinatorVM: BankAccountCoordinatorViewModel
  @State private var overviewVM: BankAccountOverviewViewModel?
  @State private var editVM: BankAccountEditViewModel?
  
  init(service: BankAccountsServiceProtocol) {
    _coordinatorVM = StateObject(wrappedValue: BankAccountCoordinatorViewModel(service: service))
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        switch coordinatorVM.currentState {
        case .overview:
          if let overviewVM = overviewVM {
            BankAccountOverviewView(viewModel: overviewVM)
              .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                  Button {
                    // Создаем editVM с колбэком для сохранения
                    editVM = BankAccountEditViewModel(
                      balance: coordinatorVM.account?.balance ?? 0,
                      currency: coordinatorVM.account?.currency ?? .rub,
                      onSave: { balance, currency in
                        Task {
                          await coordinatorVM.saveChanges(balance: balance, currency: currency)
                          // Обновляем данные в overviewVM
                          self.overviewVM?.updateData(balance: balance, currency: currency)
                        }
                      }
                    )
                    coordinatorVM.enterEditMode()
                  } label: {
                    Text("Редактировать")
                  }
                }
              }
          }
        case .edit:
          if let editVM = editVM {
            BankAccountEditView(viewModel: editVM)
              .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                  Button {
                    editVM.save()
                  } label: {
                    Text("Сохранить")
                  }
                }
              }
          }
        }
      }
      .refreshable {
        print("Coordinator pull to refresh triggered")
        await coordinatorVM.loadAccount()
        // Обновляем данные в overviewVM
        if let account = coordinatorVM.account {
          overviewVM?.updateData(balance: account.balance, currency: account.currency)
        }
        print("Coordinator pull to refresh completed")
      }
      .navigationTitle("Мой счет")
      .background(.bg)
      .gesture(
        DragGesture()
          .onEnded { _ in
            hideKeyboard()
          }
      )
    }
    .tint(.navigationBar)
    .task {
      if coordinatorVM.account == nil {
        await coordinatorVM.loadAccount()
      }
      // Создаем overviewVM после загрузки данных
      if overviewVM == nil {
        overviewVM = BankAccountOverviewViewModel(
          service: coordinatorVM.service,
          balance: coordinatorVM.account?.balance ?? 0,
          currency: coordinatorVM.account?.currency ?? .rub
        )
      }
    }
    .onAppear {
      Task {
        await coordinatorVM.loadAccount()
        if let account = coordinatorVM.account {
          overviewVM?.updateData(balance: account.balance, currency: account.currency)
        }
      }
    }
  }
  
  private func hideKeyboard() {
    print("hideKeyboard")
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
  }
}

#Preview {
  BankAccountCoordinatorView(service: BankAccountsService())
}
