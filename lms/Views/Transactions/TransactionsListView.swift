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
                viewModel: viewModel.makeHistoryModel()
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
  TransactionsListView(viewModel: previewIncomeViewModel)
}

let previewIncomeViewModel = TransactionsListViewModel(
  direction: .income,
  currency: .rub
)

let previewOutcomeViewModel = TransactionsListViewModel(
  direction: .income,
  currency: .rub
)

// MARK: - ViewModel

enum TransactionSortType {
  case date
  case amount
}

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
    endDate: Date = Date(),
    sortType: TransactionSortType = .date,
    service: TransactionsService = TransactionsService()
  ) {
    self.direction = direction
    self.currency = currency
    self.startDate = startDate
    self.endDate = endDate.advanced(by: 1)
    self.sortType = sortType
    self.service = service
  }
  
  func onViewAppear() {
    loadTransactions()
  }
  
  func loadTransactions() {
    Task {
      let result = await service.getTransactions(
        for: direction,
        in: DateInterval(start: startDate, end: endDate)
      )
      await MainActor.run {
        self.transactions = sortedTransactions(result)
      }
    }
  }
  
  func makeHistoryModel() -> TransactionsListViewModel {
    Self.init(
      direction: direction,
      currency: currency,
      startDate: Calendar.current.startOfDay(for: Date()).advanced(by: -30 * 86400),
      service: service
    )
  }
  
  func updateStartDate(_ newValue: Date) {
    let adjustedStartDate = Calendar.current.startOfDay(for: newValue)
    if adjustedStartDate > endDate {
      // Если начало стало больше конца — выравниваем конец на начало
      endDate = adjustedStartDate
    }
    startDate = adjustedStartDate
    loadTransactions()
  }
  
  func updateEndDate(_ newValue: Date) {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
    components.hour = 23
    components.minute = 59
    components.second = 59
    guard let endOfDay = Calendar.current.date(from: components) else { return }
    
    if endOfDay < startDate {
      // Если конец стал меньше начала — выравниваем начало на конец
      startDate = Calendar.current.startOfDay(for: newValue)
    } else {
      endDate = endOfDay
    }
    loadTransactions()
  }
  
  func toggleSortType(_ sortType: TransactionSortType) {
    self.sortType = sortType
    transactions = sortedTransactions(transactions)
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
