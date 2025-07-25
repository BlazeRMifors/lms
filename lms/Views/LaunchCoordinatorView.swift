//
//  LaunchCoordinatorView.swift
//  lms
//
//  Created by Ivan Isaev on 25.07.2025.
//

import SwiftUI

struct LaunchCoordinatorView: View {
    @State private var isAnimationCompleted = false
    @State private var showMainInterface = false
    
    let viewModel: MainTabViewModel
    
    var body: some View {
        ZStack {
            if showMainInterface {
                MainTabView(viewModel: viewModel)
                    .transition(.opacity)
            } else {
                LaunchAnimationView(isAnimationCompleted: $isAnimationCompleted)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showMainInterface)
        .onChange(of: isAnimationCompleted) { completed in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMainInterface = true
                }
            }
        }
    }
}

#Preview {
    let previewViewModel = MainTabViewModel(
        transactionService: TransactionsService(storage: makeTransactionsStorage()),
        bankAccountService: BankAccountsService(),
        categoriesService: CategoriesService()
    )
    return LaunchCoordinatorView(viewModel: previewViewModel)
} 