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
  @FocusState private var isBalanceFieldFocused: Bool
  
  var body: some View {
    VStack(spacing: 16) {
      balanceField
      currencyPicker
    }
    .padding()
    .contentShape(Rectangle())
    .ignoresSafeArea(.all, edges: .all)
    .simultaneousGesture(
      DragGesture()
        .onEnded { _ in
          // Скрываем клавиатуру при свайпе по экрану
          isBalanceFieldFocused = false
        }
    )
    .confirmationDialog("Валюта", isPresented: $showingCurrencyPicker, titleVisibility: .visible) {
      ForEach(Currency.allCases, id: \.self) { currency in
        Button(currency.description) {
          viewModel.currency = currency
        }
      }
    }
  }
  
  private var balanceField: some View {
    HStack {
      Text("💰")
      Text("Баланс").padding(.leading, 10)
      Spacer()
      TextField("", text: $viewModel.balance)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .focused($isBalanceFieldFocused)
        .onTapGesture {
          // При нажатии на текстовое поле фокусируемся на нем
          isBalanceFieldFocused = true
        }
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
    .onTapGesture {
      // При нажатии на всю ячейку также фокусируемся на текстовом поле
      isBalanceFieldFocused = true
    }
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
