//
//  TransactionsHistoryView.swift
//  lms
//
//  Created by Ivan Isaev on 19.06.2025.
//

import SwiftUI
import Combine

struct TransactionsHistoryView: View {
  
  let direction: Direction
  @State var viewModel = TransactionsHistoryViewModel()
  
  @State private var startDate: Date = Calendar.current.startOfDay(
    for: Date()
  ).advanced(by: -30 * 86400)
  @State private var endDate: Date = Date()
  
  var body: some View {
    VStack {
      List {
        
        startDateRow
        endDateRow
        sumRow
        
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
                  
                  if let comment = transaction.comment {
                    Text(comment)
                      .font(.callout)
                      .foregroundColor(Color.gray)
                      .lineLimit(1)
                  }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                  Text("\(transaction.amount)")
                }
              }
              .frame(height: 44)
              .alignmentGuide(.listRowSeparatorLeading) { _ in
                42
              }
            }
          }
        }
      }
      .navigationTitle("Моя история")
    }
    .task {
      await viewModel.loadTransactions()
    }
  }
  
  private var startDateRow: some View {
    HStack {
      Text("Начало")
      Spacer()
      DatePicker("", selection: $startDate, displayedComponents: .date)
        .labelsHidden()
        .background(.accent.opacity(0.2))
        .cornerRadius(8)
        .onChange(of: startDate, { oldValue, newValue in
          let adjustedStartDate = Calendar.current.startOfDay(for: newValue)
          if adjustedStartDate > endDate {
            // Если начало стало больше конца — выравниваем конец на начало
            endDate = adjustedStartDate
          }
          startDate = adjustedStartDate
        })
    }
  }
  
  private var endDateRow: some View {
    HStack {
      Text("Конец")
      Spacer()
      DatePicker("", selection: $endDate, displayedComponents: .date)
        .labelsHidden()
        .background(.accent.opacity(0.2))
        .cornerRadius(8)
        .onChange(of: endDate) { oldValue, newValue in
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
        }
    }
  }
  
  private var sumRow: some View {
    HStack {
      Text("Сумма")
      Spacer()
      Text("\(viewModel.totalAmount)")
    }
  }
}

#Preview {
  NavigationStack {
    TransactionsHistoryView(
      direction: .income
    )
  }
}

// MARK: - ViewModel

@Observable
final class TransactionsHistoryViewModel {
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
    transactions = await service.getTransactions(for: .income, in: interval)
    //    }
  }
}
