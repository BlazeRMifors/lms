//
//  TransactionsListView.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI
import Combine

struct TransactionsListView: View {
  
  let direction: Direction
  @State var viewModel = TransactionsListViewModel()
  
  @State
  private var screens: [TransactionsListItemViewModel] = []
  
  var body: some View {
    NavigationStack(path: $screens) {
      VStack {
        List {
          HStack {
            Text("Всего")
            Spacer()
            Text("\(viewModel.totalAmount) ₽")
          }
//          OperationListView(operations: MockOperation.allCases)
          
          Section(
            header: Text("Операции")
              .font(.subheadline)
              .padding(.leading, 0)
          ) {
            ForEach(viewModel.transactions) { transaction in
              NavigationLink(destination: Text("Экран в разработке").accentColor(.orange)) {
                HStack {
                  Text("\(transaction.category.emoji)")
                    .padding(6)
                    .background(
                      Circle().fill(Color.accent.opacity(0.2))
                    )
                  
                  VStack(alignment: .leading) {
                    Text(transaction.category.name)
                      .background()
//                    
                    if let comment = transaction.comment {
                      Text(comment)
                        .font(.callout)
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                    }
                  }
//                  
                  Spacer()
//                  
                  VStack(alignment: .trailing) {
                    Text("\(transaction.amount)")
                  }
                }
//                OperationItemView(operation: operation)
                  .frame(height: 44)
                  .alignmentGuide(.listRowSeparatorLeading) { _ in
                    42
                  }
              }
            }
          }
        }
          .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
//          .navigationDestination(for: TransactionsListItemViewModel.self) { transaction in
//            AccountView()
//          }
      }
      .task {
        await viewModel.loadTransactions()
      }
      
    }
  }
}

#Preview {
  TransactionsListView(
    direction: .income
  )
}

// MARK: - ViewModel

@Observable
final class TransactionsListViewModel {
  var transactions: [Transaction] = []
  var totalAmount: Decimal {
    transactions.reduce(0) { result, transaction in
      result + transaction.amount
    }
  }
  
  private let service: TransactionsService
  
  init(service: TransactionsService = TransactionsService()) {
    self.service = service
    
//    Task {
//      await loadTransactions()
//    }
  }
  
  func loadTransactions() async {
    let startDate = Calendar.current.startOfDay(for: Date())
    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
    let interval = DateInterval(start: startDate, end: endDate)
    
//    MainActor.run {
      transactions = await service.getTransactions(for: interval)
//    }
  }
}
