//
//  BankAccountOverviewView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

struct BankAccountOverviewView: View {
  @State var viewModel: BankAccountOverviewViewModel
  
  var body: some View {
    VStack(spacing: 16) {
      balanceRow
        .onShake {
          viewModel.toggleBalanceVisibility()
        }
      currencyRow
    }
    .padding()
  }
  
  private var balanceRow: some View {
    HStack {
      Text("💰")
      Text("Баланс")
        .padding(.leading, 10)
      Spacer()
      AmountView(amount: viewModel.balance, currency: viewModel.currency)
        .spoiler(isOn: viewModel.isBalanceHidden)
    }
    .padding()
    .background(.accent)
    .cornerRadius(10)
  }
  
  private var currencyRow: some View {
    HStack {
      Text("Валюта")
      Spacer()
      Text(viewModel.currency.symbol)
        .font(.title3)
    }
    .padding()
    .background(.accent.opacity(0.3))
    .cornerRadius(10)
  }
}

#Preview {
  let service = BankAccountsService()
  let viewModel = BankAccountOverviewViewModel(
    service: service,
    balance: -670000,
    currency: .rub,
    isBalanceHidden: true
  )
  BankAccountOverviewView(viewModel: viewModel)
  
  Button {
    viewModel.toggleBalanceVisibility()
  } label: {
    Text("Спойлер Вкл/Выкл")
  }
}
