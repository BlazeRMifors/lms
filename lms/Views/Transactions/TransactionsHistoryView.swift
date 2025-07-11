//
//  TransactionsHistoryView.swift
//  lms
//
//  Created by Ivan Isaev on 19.06.2025.
//

import SwiftUI
import Combine

struct TransactionsHistoryView: View {
  
  @State var viewModel: TransactionsListViewModel
  @State private var showAnalysis = false
  @State private var showEditSheet = false
  @State private var selectedTransaction: Transaction? = nil
  
  var body: some View {
    VStack {
      List {
        
        startDateRow
        endDateRow
        sortRow
        sumRow
        
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
      .navigationTitle("Моя история")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            NavigationLink(
              destination:
                AnalysisViewControllerRepresentable(viewModel: viewModel)
                .navigationTitle("Анализ")
                .background(.bg)
            ) {
              Image(systemName: "document")
                .tint(.navigationBar)
            }
          }
        }
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
    }
    .onAppear {
      viewModel.onViewAppear()
    }
  }
  
  private var startDateRow: some View {
    HStack {
      Text("Начало")
      Spacer()
      DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
        .labelsHidden()
        .background(.accent.opacity(0.2))
        .cornerRadius(8)
        .tint(.accent)
        .onChange(of: viewModel.startDate, { oldValue, newValue in
          viewModel.updateStartDate(newValue)
        })
    }
  }
  
  private var endDateRow: some View {
    HStack {
      Text("Конец")
      Spacer()
      DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
        .labelsHidden()
        .background(.accent.opacity(0.2))
        .cornerRadius(8)
        .tint(.accent)
        .onChange(of: viewModel.endDate) { oldValue, newValue in
          viewModel.updateEndDate(newValue)
        }
    }
  }
  
  private var sortRow: some View {
    HStack {
      Picker("Сортировка", selection: $viewModel.sortType) {
        Text("По дате").tag(TransactionSortType.date)
        Text("По сумме").tag(TransactionSortType.amount)
      }
      .pickerStyle(.menu)
      .tint(.primary)
      .onChange(of: viewModel.sortType) { oldValue, newValue in
        viewModel.toggleSortType(newValue)
      }
    }
  }
  
  private var sumRow: some View {
    HStack {
      Text("Сумма")
      Spacer()
      AmountView(amount: viewModel.totalAmount, currency: viewModel.currency)
    }
  }
}

#Preview {
  NavigationStack {
    TransactionsHistoryView(viewModel: previewIncomeViewModel)
  }
}
