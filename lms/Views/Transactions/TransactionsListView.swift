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
  @State private var showEditSheet = false
  @State private var showCreateSheet = false
  @State private var selectedTransaction: Transaction? = nil
  
  var body: some View {
    NavigationStack {
      ZStack {
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
                Button(action: {
                  selectedTransaction = transaction
                  showEditSheet = true
                }) {
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
                    Image(systemName: "chevron.right")
                      .foregroundColor(.gray)
                      .font(.system(size: 16, weight: .semibold))
                  }
                  .frame(height: 44)
                  .alignmentGuide(.listRowSeparatorLeading) { _ in 42 }
                }
                .buttonStyle(.plain)
              }
            }
          }
          .navigationTitle(viewModel.direction == .income ? "Мои доходы" : "Мои расходы")
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
        fabButton
      }
      .safeAreaInset(edge: .bottom, spacing: 0) {
        Color.clear.frame(height: 0)
      }
      .onAppear {
        viewModel.onViewAppear()
      }
      .sheet(isPresented: $showEditSheet) {
        if let transaction = selectedTransaction {
          TransactionEditView(
            mode: .edit,
            transaction: transaction,
            direction: viewModel.direction,
            currency: viewModel.currency,
            service: viewModel.service,
            onSave: { viewModel.loadTransactions() },
            onDelete: { viewModel.loadTransactions() }
          )
        }
      }
      .id(selectedTransaction?.id)
      .sheet(isPresented: $showCreateSheet) {
        TransactionEditView(
          mode: .create,
          direction: viewModel.direction,
          currency: viewModel.currency,
          service: viewModel.service,
          onSave: { viewModel.loadTransactions() }
        )
      }
    }
    .tint(.navigationBar)
  }
  
  private var fabButton: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Button(action: {
          showCreateSheet = true
        }) {
          Image(systemName: "plus")
            .font(.title2)
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
            .background(Circle().fill(.accent))
        }
        .padding(.trailing, 24)
        .padding(.bottom, 24)
        .accessibilityLabel("Добавить операцию")
      }
    }
  }
}

#Preview {
  TransactionsListView(viewModel: previewIncomeViewModel)
}

let previewIncomeViewModel = TransactionsListViewModel(
  direction: .income,
  currency: .rub,
  startDate: Calendar.current.startOfDay(for: Date()),
  endDate: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86399),
  service: TransactionsService(),
  bankAccountsService: BankAccountsService()
)

let previewOutcomeViewModel = TransactionsListViewModel(
  direction: .income,
  currency: .rub,
  startDate: Calendar.current.startOfDay(for: Date()),
  endDate: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86399),
  service: TransactionsService(),
  bankAccountsService: BankAccountsService()
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
  
  let service: TransactionsService
  let bankAccountsService: BankAccountsService
  
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
    service: TransactionsService = TransactionsService(),
    bankAccountsService: BankAccountsService = BankAccountsService()
  ) {
    self.direction = direction
    self.currency = currency
    self.startDate = startDate
    self.endDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)
    self.sortType = sortType
    self.service = service
    self.bankAccountsService = bankAccountsService
  }
  
  func onViewAppear() {
    loadTransactions()
  }
  
  func loadTransactions() {
    Task {
      do {
        guard let accountId = try? await bankAccountsService.getUserAccount().id else { return }
        
        let result = try await service.getTransactions(
          for: accountId,
          with: direction,
          in: DateInterval(start: startDate, end: endDate)
        )
        await MainActor.run {
          self.transactions = sortedTransactions(result)
        }
      } catch {
        await MainActor.run {
          self.transactions = []
        }
      }
    }
  }
  
  func makeHistoryModel() -> TransactionsListViewModel {
    Self.init(
      direction: direction,
      currency: currency,
      startDate: Calendar.current.startOfDay(for: Date()).advanced(by: -30 * 86400),
      service: service,
      bankAccountsService: bankAccountsService
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
