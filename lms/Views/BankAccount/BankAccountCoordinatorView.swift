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
  
  private let transactionsService: TransactionsServiceProtocol
  
  init(service: BankAccountsServiceProtocol, transactionsService: TransactionsServiceProtocol = TransactionsService()) {
    _coordinatorVM = StateObject(wrappedValue: BankAccountCoordinatorViewModel(service: service))
    self.transactionsService = transactionsService
  }
  
  var body: some View {
    NavigationStack {
      ZStack {
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
          await coordinatorVM.loadAccount()

          if let account = coordinatorVM.account {
            overviewVM?.updateData(balance: account.balance, currency: account.currency)
            await overviewVM?.refreshData()
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
        if coordinatorVM.isLoading {
          Color.black.opacity(0.2).ignoresSafeArea()
          ProgressView().scaleEffect(1.5)
        }
      }
      .alert(isPresented: Binding(get: { coordinatorVM.errorMessage != nil }, set: { _ in coordinatorVM.errorMessage = nil })) {
        Alert(title: Text("Ошибка"), message: Text(coordinatorVM.errorMessage ?? ""), dismissButton: .default(Text("OK")))
      }
    }
    .tint(.navigationBar)
    .task {
      if coordinatorVM.account == nil {
        await coordinatorVM.loadAccount()
      }
      if overviewVM == nil {
        overviewVM = BankAccountOverviewViewModel(
          service: coordinatorVM.service,
          transactionsService: transactionsService,
          balance: coordinatorVM.account?.balance ?? 0,
          currency: coordinatorVM.account?.currency ?? .rub
        )
        await overviewVM?.refreshData()
      }
    }
    .onAppear {
      Task {
        await coordinatorVM.loadAccount()
        if let account = coordinatorVM.account {
          overviewVM?.updateData(balance: account.balance, currency: account.currency)
          await overviewVM?.refreshData()
        }
      }
    }
  }
  
  private func hideKeyboard() {
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
