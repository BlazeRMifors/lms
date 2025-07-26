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
  @State private var selectedDate: Date?
  
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
      statisticsControl
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
  
  private var statisticsControl: some View {
    Picker("Период статистики", selection: Binding(
      get: { viewModel.selectedPeriod },
      set: { newValue in
        selectedDate = nil
        withAnimation(.easeInOut(duration: 0.3)) {
          viewModel.changePeriod(to: newValue)
        }
      }
    )) {
      ForEach(StatisticsPeriod.allCases, id: \.self) { period in
        Text(period.rawValue).tag(period)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
  
  private var balanceHistoryChart: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let errorMessage = viewModel.errorMessage {
        VStack(spacing: 8) {
          Text(errorMessage)
            .font(.caption)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
          
          Button("Повторить") {
            Task {
              await viewModel.refreshData()
            }
          }
          .font(.caption)
          .foregroundColor(.blue)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
      } else if viewModel.dailyBalances.isEmpty {
        Text("Нет данных для отображения")
          .font(.caption)
          .foregroundColor(.secondary)
          .frame(height: 200)
          .frame(maxWidth: .infinity)
      } else {
        VStack(spacing: 8) {
          Chart(viewModel.dailyBalances) { dailyBalance in
            BarMark(
              x: .value("Date", dailyBalance.date, unit: viewModel.selectedPeriod == .daily ? .day : .month),
              y: .value("Balance", dailyBalance.balance.doubleValue),
              width: .ratio(0.6)
            )
            .foregroundStyle(dailyBalance.isPositive ? .green : .red)
            .cornerRadius(2)
            .opacity(selectedDate == nil ? 1.0 : (isDaySelected(dailyBalance.date) ? 1.0 : 0.6))
          }
          .frame(height: 200)
          .chartXSelection(value: $selectedDate)
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .chartBackground { chartProxy in
            GeometryReader { geometry in
              if let selectedDate = selectedDate,
                 let selectedBalance = getBalance(for: selectedDate) {
                tooltipView(for: selectedBalance, date: selectedDate, in: geometry, chartProxy: chartProxy)
              }
            }
          }
          .chartPlotStyle { plotArea in
            plotArea
              .background(.clear)
          }
          .animation(.easeInOut(duration: 0.3), value: viewModel.selectedPeriod)
          .id(viewModel.selectedPeriod)
          .onTapGesture {
            selectedDate = nil
          }
          
          dateLabels
        }
      }
    }
    .padding()
    .cornerRadius(10)
  }
  
  private var dateLabels: some View {
    HStack {
      if let firstDate = viewModel.dailyBalances.first?.date {
        Text(formatDateForChart(firstDate))
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      if viewModel.dailyBalances.count > 1 {
        let middleIndex = viewModel.dailyBalances.count / 2
        let middleDate = viewModel.dailyBalances[middleIndex].date
        Text(formatDateForChart(middleDate))
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      if let lastDate = viewModel.dailyBalances.last?.date {
        Text(formatDateForChart(lastDate))
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
  }
  
  private func formatDateForChart(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = viewModel.selectedPeriod == .daily ? "dd.MM" : "MMM yy"
    return formatter.string(from: date)
  }
  
  private func isDaySelected(_ date: Date) -> Bool {
    guard let selectedDate = selectedDate else { return false }
    let calendar = Calendar.current
    
    if viewModel.selectedPeriod == .daily {
      return calendar.isDate(date, inSameDayAs: selectedDate)
    } else {
      let dateComponents = calendar.dateComponents([.year, .month], from: date)
      let selectedComponents = calendar.dateComponents([.year, .month], from: selectedDate)
      return dateComponents.year == selectedComponents.year && dateComponents.month == selectedComponents.month
    }
  }
  
  private func getBalance(for date: Date) -> Decimal? {
    return viewModel.dailyBalances.first { balance in
      isDaySelected(balance.date)
    }?.balance
  }
  
  private func tooltipView(for balance: Decimal, date: Date, in geometry: GeometryProxy, chartProxy: ChartProxy) -> some View {
    let dateX = chartProxy.position(forX: date) ?? 0
    let clampedX = min(max(dateX - 50, 10), geometry.size.width - 110)
    
    return VStack(spacing: 4) {
      Text(formatDateForChart(date))
        .font(.caption2)
        .fontWeight(.medium)
      Text(balance.formatted(.currency(code: viewModel.currency.rawValue)))
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(balance >= 0 ? .green : .red)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 6)
        .fill(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    )
    .position(x: clampedX + 50, y: 30)
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
