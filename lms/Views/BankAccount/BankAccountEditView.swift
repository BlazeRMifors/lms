//
//  BankAccountEditView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

struct BankAccountEditView: View {
  @State var viewModel: BankAccountEditViewModel
  @State private var showingCurrencyPicker = false
  
  var body: some View {
    VStack(spacing: 16) {
      balanceField
      currencyPicker
    }
    .padding()
  }
  
  private var balanceField: some View {
    HStack {
      Text("💰")
      Text("Баланс").padding(.leading, 10)
      Spacer()
      TextField("", text: $viewModel.balance)
        .keyboardType(.numbersAndPunctuation)
        .multilineTextAlignment(.trailing)
        .onChange(of: viewModel.balance) { oldValue, newValue in
          viewModel.updateBalance(newValue)
        }
        .tint(.gray)
        .foregroundColor(.gray)
        .font(.title3)
    }
    .padding()
    .background(.white)
    .cornerRadius(10)
  }
  
  private var currencyPicker: some View {
    HStack {
      Text("Валюта")
      Spacer()
      Button(action: {
        showingCurrencyPicker = true
      }) {
        HStack {
          Text(viewModel.currency.symbol)
            .font(.title3)
            .foregroundColor(.gray)
          Image(systemName: "chevron.right")
            .padding(.leading, 10)
            .tint(.gray)
        }
      }
    }
    .padding()
    .background(.white)
    .cornerRadius(10)
    .actionSheet(isPresented: $showingCurrencyPicker) {
      ActionSheet(
        title: Text("Валюта"),
        buttons: Currency.allCases.map { currency in
            .default(
              Text(currency.description)
            ) {
              guard currency != viewModel.currency else { return }
              viewModel.currency = currency
            }
        }
      )
    }
  }
}

#Preview {
  let vm = BankAccountEditViewModel(
    balance: -670000,
    currency: .rub
  )
  ZStack {
    Rectangle().fill(.gray.opacity(0.15))
    BankAccountEditView(viewModel: vm)
  }
}
