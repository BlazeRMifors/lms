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
      ScrollView {
        switch coordinatorVM.currentState {
        case .overview:
          BankAccountOverviewView(viewModel: BankAccountOverviewViewModel(
            balance: 1000,
            currency: .rub
          ))
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                coordinatorVM.enterEditMode()
              } label: {
                Text("Редактировать")
              }
            }
          }
        case .edit:
          BankAccountEditView(
            viewModel: BankAccountEditViewModel(
              balance: 1000,
              currency: .rub
            )
          )
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                coordinatorVM.cancelEdit()
              } label: {
                Text("Сохранить")
              }
            }
          }
        }
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
