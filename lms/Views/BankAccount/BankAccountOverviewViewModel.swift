//
//  BankAccountOverviewViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI
import Foundation

struct DailyBalance: Identifiable {
  let id = UUID()
  let date: Date
  let balance: Decimal
  
  var isPositive: Bool {
    balance >= 0
  }
}

@Observable
final class BankAccountOverviewViewModel {
  private let service: BankAccountsServiceProtocol
  private let transactionsService: TransactionsServiceProtocol
  
  var balance: Decimal = 0
  var currency: Currency = .rub
  private(set) var isBalanceHidden = false
  private(set) var isLoading = false
  private(set) var dailyBalances: [DailyBalance] = []
  
  init(service: BankAccountsServiceProtocol, transactionsService: TransactionsServiceProtocol, balance: Decimal, currency: Currency, isBalanceHidden: Bool = false) {
    self.service = service
    self.transactionsService = transactionsService
    self.balance = balance
    self.currency = currency
    self.isBalanceHidden = isBalanceHidden
  }
  
  func toggleBalanceVisibility() {
    isBalanceHidden.toggle()
  }
  
  func updateData(balance: Decimal, currency: Currency) {
    self.balance = balance
    self.currency = currency
  }
  
  @MainActor
  func refreshData() async {
    isLoading = true
    
    do {
      let account = try await service.getUserAccount()
      balance = account.balance
      currency = account.currency
      await loadBalanceHistory(for: account.id)
    } catch {
      // TODO: Показать ошибку пользователю
    }
    
    isLoading = false
  }
  
  @MainActor
  private func loadBalanceHistory(for accountId: Int) async {
    let calendar = Calendar.current
    let endDate = Date()
    guard let startDate = calendar.date(byAdding: .day, value: -29, to: endDate) else { return }
    
    let period = DateInterval(start: startDate, end: endDate)
    
    do {
      let incomeTransactions = try await transactionsService.getTransactions(for: accountId, with: .income, in: period)
      let outcomeTransactions = try await transactionsService.getTransactions(for: accountId, with: .outcome, in: period)
      
      let allTransactions = incomeTransactions + outcomeTransactions
      let sortedTransactions = allTransactions.sorted { $0.transactionDate < $1.transactionDate }
      
      let groupedTransactions = Dictionary(grouping: sortedTransactions) { transaction in
        calendar.startOfDay(for: transaction.transactionDate)
      }
      
      var dailyBalances: [DailyBalance] = []
      var runningBalance = balance
      
      for dayOffset in 0...29 {
        guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: endDate) else { continue }
        let dayStart = calendar.startOfDay(for: dayDate)
        
        if dayOffset == 0 {
          dailyBalances.insert(DailyBalance(date: dayStart, balance: runningBalance), at: 0)
        } else {
          let nextDayDate = calendar.date(byAdding: .day, value: -dayOffset + 1, to: endDate)!
          let nextDayStart = calendar.startOfDay(for: nextDayDate)
          let nextDayTransactions = groupedTransactions[nextDayStart] ?? []
          
          for transaction in nextDayTransactions {
            if transaction.category.direction == .income {
              runningBalance -= transaction.amount
            } else {
              runningBalance += transaction.amount
            }
          }
          
          dailyBalances.insert(DailyBalance(date: dayStart, balance: runningBalance), at: 0)
        }
      }
      
      self.dailyBalances = dailyBalances
    } catch {
      var testBalances: [DailyBalance] = []
      for dayOffset in 0...29 {
        guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: endDate) else { continue }
        let dayStart = calendar.startOfDay(for: dayDate)
        let testBalance = balance + Decimal(Int.random(in: -10000...10000))
        testBalances.insert(DailyBalance(date: dayStart, balance: testBalance), at: 0)
      }
      self.dailyBalances = testBalances
    }
  }
}
