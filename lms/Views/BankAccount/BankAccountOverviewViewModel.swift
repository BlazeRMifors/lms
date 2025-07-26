//
//  BankAccountOverviewViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI
import Foundation

enum StatisticsPeriod: String, CaseIterable {
  case daily = "Дни"
  case monthly = "Месяцы"
}

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
  private(set) var errorMessage: String?
  var selectedPeriod: StatisticsPeriod = .daily
  
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
  
  func clearError() {
    errorMessage = nil
  }
  
  func changePeriod(to period: StatisticsPeriod) {
    selectedPeriod = period
    Task {
      await refreshData()
    }
  }
  
  @MainActor
  func refreshData() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let account = try await service.getUserAccount()
      balance = account.balance
      currency = account.currency
      await loadBalanceHistory(for: account.id)
    } catch {
      errorMessage = "Failed to load account data: \(error.localizedDescription)"
    }
    
    isLoading = false
  }
  
  @MainActor
  private func loadBalanceHistory(for accountId: Int) async {
    let calendar = Calendar.current
    let endDate = Date()
    
    let period = selectedPeriod == .daily 
      ? DateInterval(start: calendar.date(byAdding: .day, value: -29, to: endDate)!, end: endDate)
      : DateInterval(start: calendar.date(byAdding: .month, value: -23, to: endDate)!, end: endDate)
    
    do {
      let incomeTransactions = try await transactionsService.getTransactions(for: accountId, with: .income, in: period)
      let outcomeTransactions = try await transactionsService.getTransactions(for: accountId, with: .outcome, in: period)
      
      let allTransactions = incomeTransactions + outcomeTransactions
      let sortedTransactions = allTransactions.sorted { $0.transactionDate < $1.transactionDate }
      
      if selectedPeriod == .daily {
        await calculateDailyBalances(transactions: sortedTransactions, endDate: endDate, calendar: calendar)
      } else {
        await calculateMonthlyBalances(transactions: sortedTransactions, endDate: endDate, calendar: calendar)
      }
      
    } catch {
      errorMessage = "Failed to load balance history: \(error.localizedDescription)"
    }
  }
  
  @MainActor
  private func calculateDailyBalances(transactions: [Transaction], endDate: Date, calendar: Calendar) async {
    let groupedTransactions = Dictionary(grouping: transactions) { transaction in
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
  }
  
  @MainActor
  private func calculateMonthlyBalances(transactions: [Transaction], endDate: Date, calendar: Calendar) async {
    let groupedTransactions = Dictionary(grouping: transactions) { transaction in
      let components = calendar.dateComponents([.year, .month], from: transaction.transactionDate)
      return calendar.date(from: components)!
    }
    
    var monthlyBalances: [DailyBalance] = []
    var runningBalance = balance
    
    for monthOffset in 0...23 {
      guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: endDate) else { continue }
      let monthComponents = calendar.dateComponents([.year, .month], from: monthDate)
      let monthStart = calendar.date(from: monthComponents)!
      
      if monthOffset == 0 {
        monthlyBalances.insert(DailyBalance(date: monthStart, balance: runningBalance), at: 0)
      } else {
        let nextMonthDate = calendar.date(byAdding: .month, value: -monthOffset + 1, to: endDate)!
        let nextMonthComponents = calendar.dateComponents([.year, .month], from: nextMonthDate)
        let nextMonthStart = calendar.date(from: nextMonthComponents)!
        let nextMonthTransactions = groupedTransactions[nextMonthStart] ?? []
        
        for transaction in nextMonthTransactions {
          if transaction.category.direction == .income {
            runningBalance -= transaction.amount
          } else {
            runningBalance += transaction.amount
          }
        }
        
        monthlyBalances.insert(DailyBalance(date: monthStart, balance: runningBalance), at: 0)
      }
    }
    
    self.dailyBalances = monthlyBalances
  }
}
