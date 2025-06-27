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
    ZStack {
      VStack(spacing: 16) {
        balanceField
        currencyPicker
      }
      .padding()
      
      if showingCurrencyPicker {
        CustomActionSheet(
          title: "Валюта",
          options: Currency.allCases.map { currency in
            ActionSheetOption(
              title: currency.description,
              isSelected: currency == viewModel.currency
            ) {
              guard currency != viewModel.currency else { return }
              viewModel.currency = currency
            }
          },
          isPresented: $showingCurrencyPicker
        )
      }
    }
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
  }
}

// MARK: - Custom ActionSheet Components

struct ActionSheetOption {
  let title: String
  let isSelected: Bool
  let action: () -> Void
}

struct CustomActionSheet: View {
  let title: String
  let options: [ActionSheetOption]
  @Binding var isPresented: Bool
  @State private var dragOffset: CGFloat = 0
  
  var body: some View {
    ZStack {
      // Background overlay
      Color.black.opacity(0.3)
        .ignoresSafeArea()
        .onTapGesture {
          dismissWithAnimation()
        }
      
      // Action sheet content
      VStack {
        Spacer()
        actionSheetContent
      }
      .transition(.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .bottom).combined(with: .opacity)
      ))
    }
  }
  
  private var actionSheetContent: some View {
    VStack(spacing: 0) {
      actionSheetHeader
      actionSheetOptions
    }
    .background(Color(.systemBackground))
    .cornerRadius(13)
    .padding(.horizontal, 16)
    .padding(.bottom, 34)
    .offset(y: dragOffset)
    .gesture(dragGesture)
  }
  
  private var actionSheetHeader: some View {
    Text(title)
      .font(.headline)
      .padding(.top, 20)
      .padding(.bottom, 10)
  }
  
  private var actionSheetOptions: some View {
    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
      VStack(spacing: 0) {
        Button(action: {
          option.action()
          dismissWithAnimation()
        }) {
          Text(option.title)
            .font(.system(size: 17))
            .foregroundColor(Color("ActionColor"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        
        if index < options.count - 1 {
          Divider()
            .padding(.horizontal)
        }
      }
    }
  }
  
  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        if value.translation.height > 0 {
          dragOffset = value.translation.height
        }
      }
      .onEnded { value in
        if value.translation.height > 100 || value.velocity.height > 500 {
          dismissWithAnimation()
        } else {
          withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = 0
          }
        }
      }
  }
  
  private func dismissWithAnimation() {
    withAnimation(.easeInOut(duration: 0.3)) {
      isPresented = false
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
