//
//  BankAccountEditView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

struct BankAccountEditView: View {
  @ObservedObject var viewModel: BankAccountEditViewModel
  
  var body: some View {
    Form {
      balanceField
      currencyPicker
    }
    .navigationTitle("Редактирование")
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button("Отмена") {
          viewModel.cancelChanges()
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Сохранить") {
          Task {
            await viewModel.saveChanges()
          }
        }
      }
    }
  }
  
  private var balanceField: some View {
    HStack {
      Text("💰 Баланс")
      Spacer()
      TextField("", text: $viewModel.balanceText)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .onTapGesture {
          showKeyboardInput()
        }
    }
  }
  
  private var currencyPicker: some View {
    Picker("Валюта", selection: $viewModel.selectedCurrency) {
      ForEach(Currency.allCases) { currency in
        Text(currency.rawValue).tag(currency)
      }
    }
  }
  
  private func showKeyboardInput() {
    let controller = InputViewController { input in
      viewModel.updateBalance(input)
    }
    DispatchQueue.main.async {
      UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
    }
  }
}
