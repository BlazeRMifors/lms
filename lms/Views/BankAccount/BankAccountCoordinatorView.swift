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
                    coordinatorVM.enterEditMode()
                  } label: {
                    Text("Редактировать")
                  }
                }
              }
          }
        case .edit:
          BankAccountEditView(
            viewModel: BankAccountEditViewModel(
              balance: coordinatorVM.account?.balance ?? 0,
              currency: coordinatorVM.account?.currency ?? .rub
            )
          )
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                // TODO: Получить данные из BankAccountEditViewModel и сохранить
                coordinatorVM.cancelEdit()
              } label: {
                Text("Сохранить")
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
