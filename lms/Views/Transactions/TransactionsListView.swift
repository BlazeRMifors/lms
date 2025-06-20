//
//  TransactionsListView.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI
import Combine

struct TransactionsListView: View {
  
  let direction: Direction
  let currency: Currency
  
  @State var viewModel = TransactionsListViewModel()
  
  @State
  private var screens: [TransactionsListItemViewModel] = []
  
  private var formatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.decimalSeparator = ","
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
  }
  
  var body: some View {
    NavigationStack(path: $screens) {
      VStack {
        List {
          HStack {
            Text("Всего")
            Spacer()
            AmountView(amount: viewModel.totalAmount, currency: currency)
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

                  AmountView(amount: transaction.amount, currency: currency)
                }
                .frame(height: 44)
//                  .frame(height: 36)
//                  .padding(.vertical, 4)
                  .alignmentGuide(.listRowSeparatorLeading) { _ in
                    42
                  }
              }
            }
          }
        }
          .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              NavigationLink(
                destination: TransactionsHistoryView(
                  direction: direction,
                  currency: currency
                )
              ) {
                Image(systemName: "clock")
                  .tint(.navigationBar)
              }
            }
          }
      }
      .onAppear {
        
      }
      .task {
        await viewModel.loadTransactions(for: direction)
      }
    }
    .tint(.navigationBar)
//    .tint(.secondary)
  }
}

#Preview {
  TransactionsListView(
    direction: .income,
    currency: .rub
  )
}

// MARK: - ViewModel

@Observable
final class TransactionsListViewModel {
  
  var startDate: Date = Calendar.current.startOfDay(
    for: Date()
  )
  var endDate: Date = Date()
  
  private(set) var transactions: [Transaction] = []
  var totalAmount: Decimal {
    transactions.reduce(0) { result, transaction in
      result + transaction.amount
    }
  }
  
  private let service: TransactionsService
  
  init(service: TransactionsService = TransactionsService()) {
    self.service = service
  }
  
  func loadTransactions(for direction: Direction) async {
    let interval = DateInterval(start: startDate, end: endDate)
    transactions = await service.getTransactions(for: direction, in: interval)
  }
}
