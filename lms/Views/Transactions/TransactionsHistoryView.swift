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
  
  @State var startDate = Date()
  @State var endDate = Date()
  
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
      DatePicker("", selection: $startDate)
    }
  }
  
  private var endDateRow: some View {
    HStack {
      Text("Конец")
      DatePicker("", selection: $startDate)
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
    transactions = await service.getTransactions(for: interval)
    //    }
  }
}
