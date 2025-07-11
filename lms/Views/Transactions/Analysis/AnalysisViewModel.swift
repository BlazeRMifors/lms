//
//  AnalysisViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import Foundation

@Observable
final class AnalysisViewModel {
  
  var onUpdate: (() -> Void)?
  
  var totalAmount: Decimal
  let direction: Direction
  let currency: Currency
  
  var startDate: Date = Calendar.current.startOfDay(
    for: Date()
  )
  var endDate: Date = Date()
  var sortType: TransactionSortType = .date
  
  private let service: TransactionsService
  private(set) var transactions: [Transaction] = []
  
  convenience init(viewModel: TransactionsListViewModel) {
    self.init(
      direction: viewModel.direction,
      currency: viewModel.currency,
      startDate: Calendar.current.startOfDay(for: Date()).advanced(by: -30 * 86400),
      service: viewModel.service
    )
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
    self.totalAmount = 0
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
        self.totalAmount = self.transactions.reduce(0) { $0 + $1.amount }
        self.onUpdate?()
      }
    }
  }
  
  func updateStartDate(_ newValue: Date) {
    let adjustedStartDate = Calendar.current.startOfDay(for: newValue)
    if adjustedStartDate > endDate {
      // Если начало стало больше конца — выравниваем конец на начало
      endDate = adjustedStartDate.addingTimeInterval(86_400 - 1)
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
    }
    endDate = endOfDay
    loadTransactions()
  }
  
  func toggleSortType(_ sortType: TransactionSortType) {
    self.sortType = sortType
    transactions = sortedTransactions(transactions)
  }
  
  func percent(for transaction: Transaction) -> Double {
    guard totalAmount != 0 else { return 0 }
    return (transaction.amount as NSDecimalNumber).doubleValue / (totalAmount as NSDecimalNumber).doubleValue * 100
  }
  
  private func sortedTransactions(_ transactions: [Transaction]) -> [Transaction] {
    switch sortType {
    case .date:
      return transactions.sorted { $0.transactionDate > $1.transactionDate }
    case .amount:
      return transactions.sorted { abs($0.amount) > abs($1.amount) }
    }
  }
}
