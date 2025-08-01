//
//  MainView.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI

struct MainTabView: View {
  
  @State var viewModel: MainTabViewModel
  @State private var isOffline: Bool = false

  var body: some View {
    VStack(spacing: 0) {
      if isOffline {
        Text("Offline mode")
          .frame(maxWidth: .infinity)
          .padding(8)
          .background(Color.red)
          .foregroundColor(.white)
          .font(.headline)
          .transition(.move(edge: .top))
      }
      TabView {
        TransactionsListView(viewModel: viewModel.outcomeModel)
          .tabItem {
            Label("Расходы", image: "downtrend-icon")
          }
        
        TransactionsListView(viewModel: viewModel.incomeModel)
          .tabItem {
            Label("Доходы", image: "uptrend-icon")
          }
        
        BankAccountCoordinatorView(service: viewModel.bankAccountService)
          .tabItem {
            Label("Счет", image: "account-icon")
          }
        
        CategoriesView(viewModel: CategoriesViewModel(categoriesService: viewModel.categoriesService))
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
      .tint(.accent)
      .onAppear {
        viewModel.onAppear()
        isOffline = !NetworkMonitor.shared.isConnected
      }
      .onChange(of: NetworkMonitor.shared.isConnected) { isConnected in
        isOffline = !isConnected
      }
    }
  }
}

#Preview {
  MainTabView(viewModel: previewMainTabViewModel)
}

@Observable
final class MainTabViewModel {
  
  private(set) var currency = Currency.rub
  private(set) var transactionService: TransactionsService
  private(set) var bankAccountService: BankAccountsService
  private(set) var categoriesService: CategoriesService
  var isOffline: Bool = false
  
  let incomeModel: TransactionsListViewModel
  let outcomeModel: TransactionsListViewModel
  
  init(
    transactionService: TransactionsService,
    bankAccountService: BankAccountsService,
    categoriesService: CategoriesService = CategoriesService()
  ) {
    self.transactionService = transactionService
    self.bankAccountService = bankAccountService
    self.categoriesService = categoriesService
    
    let currency: Currency = .rub 
    self.currency = currency
    self.incomeModel = TransactionsListViewModel(direction: .income, currency: currency)
    self.outcomeModel = TransactionsListViewModel(direction: .outcome, currency: currency)
  }
  
  func onAppear() {
    Task {
      let account = try? await bankAccountService.getUserAccount()
      if let account {
        await MainActor.run { [weak self] in
          guard let self else { return }
          self.currency = account.currency
        }
      }
    }
  }
}

fileprivate let previewMainTabViewModel = MainTabViewModel(
  transactionService: TransactionsService(),
  bankAccountService: BankAccountsService(),
  categoriesService: CategoriesService()
)
