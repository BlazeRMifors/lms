//
//  AnalysisViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import Foundation
import PieChart

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
  
  let service: TransactionsService
  let bankAccountsService: BankAccountsService
    
  private(set) var transactions: [Transaction] = []
  var isLoading: Bool = false
  var errorMessage: String? = nil
  
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
    service: TransactionsService = TransactionsService(),
    bankAccountsService: BankAccountsService = BankAccountsService()
  ) {
    self.direction = direction
    self.currency = currency
    self.startDate = startDate
    self.endDate = endDate.advanced(by: 1)
    self.sortType = sortType
    self.service = service
    self.bankAccountsService = bankAccountsService
    self.totalAmount = 0
  }
  
  func onViewAppear() {
    loadTransactions()
  }
  
  func loadTransactions() {
    isLoading = true
    errorMessage = nil
    Task {
      do {
          guard let accountId = try? await bankAccountsService.getAccountId() else { isLoading = false; return }
          let result = try await service.getTransactions(
            for: accountId,
            with: direction,
            in: DateInterval(start: startDate, end: endDate)
          )
        await MainActor.run {
          self.transactions = sortedTransactions(result)
          self.totalAmount = self.transactions.reduce(0) { $0 + $1.amount }
          self.isLoading = false
          self.onUpdate?()
        }
      } catch {
        await MainActor.run {
          self.transactions = []
          self.errorMessage = error.localizedDescription
          self.isLoading = false
          self.onUpdate?()
        }
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
  
  // MARK: - PieChart Data
  func createPieChartEntities() -> [PieChartEntity] {
    let groupedTransactions = Dictionary(grouping: transactions) { $0.category.name }
    
    let categoryEntities: [PieChartEntity] = groupedTransactions.compactMap { categoryName, transactions in
      let categoryTotal = transactions.reduce(Decimal.zero) { $0 + abs($1.amount) }
      guard categoryTotal > 0 else { return nil }
      return PieChartEntity(value: categoryTotal, label: categoryName)
    }
    
    let sortedEntities = categoryEntities.sorted { $0.value > $1.value }
    
    let maxIndividualSegments = 5
    var result = Array(sortedEntities.prefix(maxIndividualSegments))
    
    if sortedEntities.count > maxIndividualSegments {
      let remainingEntities = Array(sortedEntities.dropFirst(maxIndividualSegments))
      let othersValue = remainingEntities.reduce(Decimal.zero) { $0 + $1.value }
      if othersValue > 0 {
        let othersEntity = PieChartEntity(value: othersValue, label: "Остальные")
        result.append(othersEntity)
      }
    }
    
    return result
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
