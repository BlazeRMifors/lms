//
//  TransactionsListView.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI
import Combine

struct TransactionsListView: View {
  
  @State var viewModel: TransactionsListViewModel
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          HStack {
            Text("Всего")
            Spacer()
            AmountView(amount: viewModel.totalAmount, currency: viewModel.currency)
          }
          
          Section(
            header: Text("Операции")
              .font(.subheadline)
              .padding(.leading, 0)
          ) {
            ForEach(viewModel.transactions) { transaction in
              NavigationLink(
                destination: Text("Экран в разработке")
              ) {
                HStack {
                  Text("\(transaction.category.emoji)")
                    .padding(6)
                    .background(
                      Circle().fill(Color.accent.opacity(0.12))
                    )
                  
                  VStack(alignment: .leading) {
                    Text(transaction.category.name)
                      .background()
                    
                    if let comment = transaction.comment {
                      Text(comment)
                        .font(.callout)
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                    }
                  }
                  
                  Spacer()
                  
                  AmountView(amount: transaction.amount, currency: viewModel.currency)
                }
                .frame(height: 44)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                  42
                }
              }
            }
          }
        }
        .navigationTitle(viewModel.direction == .income ? "Доходы сегодня" : "Расходы сегодня")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink(
              destination: TransactionsHistoryView(
                direction: viewModel.direction,
                currency: viewModel.currency
              )
            ) {
              Image(systemName: "clock")
                .tint(.navigationBar)
            }
          }
        }
      }
      .onAppear {
        viewModel.onViewAppear()
      }
    }
    .tint(.navigationBar)
  }
}

#Preview {
  TransactionsListView(viewModel: previewViewModel)
}

fileprivate let previewViewModel = TransactionsListViewModel(
  direction: .income,
  currency: .rub
)

// MARK: - ViewModel

@Observable
final class TransactionsListViewModel {
  
  let direction: Direction
  let currency: Currency
  
  var startDate: Date = Calendar.current.startOfDay(
    for: Date()
  )
  var endDate: Date = Date()
  var sortType: TransactionSortType = .date
  
  private let service: TransactionsService
  
  private(set) var transactions: [Transaction] = []
  
  var totalAmount: Decimal {
    transactions.reduce(0) { result, transaction in
      result + transaction.amount
    }
  }
  
  init(
    direction: Direction,
    currency: Currency,
    startDate: Date = Calendar.current.startOfDay(for: Date()),
    endDate: Date = Date().advanced(by: 1),
    sortType: TransactionSortType = .date,
    service: TransactionsService = TransactionsService()
  ) {
    self.direction = direction
    self.currency = currency
    self.startDate = startDate
    self.endDate = endDate
    self.sortType = sortType
    self.service = service
  }
  
  func onViewAppear() {
    Task {
      await loadTransactions()
    }
  }
  
  func loadTransactions() async {
    let result = await service.getTransactions(
      for: direction,
      in: DateInterval(start: startDate, end: endDate)
    )
    await MainActor.run {
      self.transactions = sortedTransactions(result)
    }
  }
  
  private func sortedTransactions(_ transactions: [Transaction]) -> [Transaction] {
    switch sortType {
    case .date:
      return transactions.sorted { $0.transactionDate > $1.transactionDate }
    case .amount:
      return transactions.sorted { abs($0.amount) > abs($1.amount) }
    }
  }
  
  // MARK: - Static Formatter
  private let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ru_RU_POSIX")
    return formatter
  }()
}
