//
//  BankAccountOverviewView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI

struct BankAccountOverviewView: View {
  @ObservedObject var viewModel: BankAccountOverviewViewModel
  
  var body: some View {
    NavigationStack {
      List {
        if viewModel.isLoading {
          ProgressView()
        } else {
          balanceRow
          currencyRow
        }
      }
//      .navigationTitle("Мой счет")
      .refreshable {
        await viewModel.refreshData()
      }
//      .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//          NavigationLink("Редактировать") {
//            BankAccountEditView(viewModel: BankAccountEditViewModel(
//              service: BankAccountsService(),
//              initialBalance: viewModel.balance,
//              initialCurrency: viewModel.currency
//            ))
//          }
//        }
//      }
      .onShake {
        viewModel.toggleBalanceVisibility()
      }
      .task {
        await viewModel.loadAccount()
      }
    }
  }
  
  private var balanceRow: some View {
    HStack {
      Text("💰 Баланс")
        .fontWeight(.medium)
      Spacer()
      if viewModel.isBalanceHidden {
        spoilerText("••••••")
      } else {
        Text(viewModel.formattedBalance)
      }
    }
  }
  
  private var currencyRow: some View {
    HStack {
      Text("💱 Валюта")
        .fontWeight(.medium)
      Spacer()
      Text(viewModel.currency.symbol)
        .foregroundColor(.gray)
    }
  }
  
  private func spoilerText(_ text: String) -> some View {
    Text(text)
      .font(.headline)
      .padding(4)
      .background(Color.gray.opacity(0.3))
      .cornerRadius(4)
  }
}
