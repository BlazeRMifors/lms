//
//  MainView.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI

struct MainTabView: View {
  
  @State var viewModel: MainTabViewModel
  
  var body: some View {
    TabView {
      TransactionsListView(viewModel: viewModel.outcomeModel)
        .tabItem {
          Label("Расходы", image: "downtrend-icon")
        }
      
      TransactionsListView(viewModel: viewModel.incomeModel)
        .tabItem {
          Label("Доходы", image: "uptrend-icon")
        }
      
      NavigationStack {
        Text("Экран в разработке")
          .navigationTitle("Мой счет")
      }
        .tabItem {
          Label("Счет", image: "account-icon")
        }
      
      NavigationStack {
        Text("Экран в разработке")
          .navigationTitle("Мои статьи")
      }
        .tabItem {
          Label("Статьи", image: "categories-icon")
        }
      
      NavigationStack {
        Text("Экран в разработке")
          .navigationTitle("Настройки")
      }
        .tabItem {
          Label("Настройки", image: "settings-icon")
        }
    }
  }
}

#Preview {
  MainTabView(viewModel: previewMainTabViewModel)
}

@Observable
final class MainTabViewModel {
  
  var currency = Currency.rub
  var transactionService: TransactionsService
  
  let incomeModel: TransactionsListViewModel
  let outcomeModel: TransactionsListViewModel
  
  init(
    transactionService: TransactionsService,
    currency: Currency = .rub
  ) {
    self.transactionService = transactionService
    self.currency = currency
    self.incomeModel = TransactionsListViewModel(direction: .income, currency: currency)
    self.outcomeModel = TransactionsListViewModel(direction: .outcome, currency: currency)
  }
}

fileprivate let previewMainTabViewModel = MainTabViewModel(
  transactionService: TransactionsService()
)
