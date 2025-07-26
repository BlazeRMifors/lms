//
//  BankAccountOverviewView.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI
import Charts

struct BankAccountOverviewView: View {
  @State var viewModel: BankAccountOverviewViewModel
  
  init(viewModel: BankAccountOverviewViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    VStack(spacing: 16) {
      balanceRow
        .onShake {
          viewModel.toggleBalanceVisibility()
        }
      currencyRow
      balanceHistoryChart
    }
    .padding()
    .onAppear {
      Task {
        await viewModel.refreshData()
      }
    }
  }
  
  private var balanceRow: some View {
    HStack {
      Text("💰")
      Text("Баланс")
        .padding(.leading, 10)
      Spacer()
      AmountView(amount: viewModel.balance, currency: viewModel.currency)
        .spoiler(isOn: viewModel.isBalanceHidden)
    }
    .padding()
    .background(.accent)
    .cornerRadius(10)
  }
  
  private var currencyRow: some View {
    HStack {
      Text("Валюта")
      Spacer()
      Text(viewModel.currency.symbol)
        .font(.title3)
    }
    .padding()
    .background(.accent.opacity(0.3))
    .cornerRadius(10)
  }
  
  private var balanceHistoryChart: some View {
    VStack(alignment: .leading, spacing: 12) {
      if viewModel.dailyBalances.isEmpty {
        Text("Нет данных для отображения")
          .font(.caption)
          .foregroundColor(.secondary)
          .frame(height: 200)
          .frame(maxWidth: .infinity)
      } else {
        Chart(viewModel.dailyBalances) { dailyBalance in
          BarMark(
            x: .value("Date", dailyBalance.date, unit: .day),
            y: .value("Balance", dailyBalance.balance.doubleValue),
            width: .ratio(0.6)
          )
          .foregroundStyle(dailyBalance.isPositive ? .green : .red)
          .cornerRadius(2)
        }
        .frame(height: 200)
        .chartXAxis {
          AxisMarks(values: .stride(by: .day, count: 7)) { value in
            if let date = value.as(Date.self) {
              AxisValueLabel {
                Text(formatDateForChart(date))
                  .font(.caption2)
                  .foregroundColor(.secondary)
              }
              AxisGridLine()
              AxisTick()
            }
          }
        }
        .chartYAxis(.hidden)
        .chartPlotStyle { plotArea in
          plotArea
            .background(.clear)
        }
      }
    }
    .padding()
    .cornerRadius(10)
  }
  
  private func formatDateForChart(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM"
    return formatter.string(from: date)
  }
}

extension Decimal {
  var doubleValue: Double {
    return (self as NSDecimalNumber).doubleValue
  }
}

#Preview {
  let service = BankAccountsService()
  let transactionsService = TransactionsService()
  let viewModel = BankAccountOverviewViewModel(
    service: service,
    transactionsService: transactionsService,
    balance: -670000,
    currency: .rub,
    isBalanceHidden: true
  )
  
  BankAccountOverviewView(viewModel: viewModel)
}
