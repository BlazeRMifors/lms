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
    viewModel = MainTabViewModel(transactionService: TransactionsService())
  }
  
  var body: some Scene {
    WindowGroup {
      MainTabView(viewModel: viewModel)
    }
  }
}
