//
//  lmsApp.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI

@main
struct lmsApp: App {
  
  let viewModel: MainTabViewModel
  
  init() {
    UITabBar.appearance().backgroundColor = .white
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .action
    UISearchBar.appearance().tintColor = .action
    
    Task {
      await migrateTransactionsStorageIfNeeded()
    }
    
    viewModel = MainTabViewModel(
      transactionService: TransactionsService(storage: makeTransactionsStorage()),
      bankAccountService: BankAccountsService()
    )
  }
  
  var body: some Scene {
    WindowGroup {
      MainTabView(viewModel: viewModel)
    }
  }
}
