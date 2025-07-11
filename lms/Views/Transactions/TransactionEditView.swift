import SwiftUI

enum TransactionEditMode {
  case create
  case edit
}

struct TransactionEditView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: TransactionEditViewModel
  let mode: TransactionEditMode
  let onSave: (() -> Void)?
  let onDelete: (() -> Void)?
  @State private var showCategorySelection = false
  @State private var showValidationAlert = false
  
  init(
    mode: TransactionEditMode,
    transaction: Transaction? = nil,
    direction: Direction,
    currency: Currency,
    service: TransactionsService = TransactionsService(),
    categoriesService: CategoriesService = CategoriesService(),
    bankAccountsService: BankAccountsService = BankAccountsService(),
    onSave: (() -> Void)? = nil,
    onDelete: (() -> Void)? = nil
  ) {
    _viewModel = StateObject(wrappedValue: TransactionEditViewModel(
      mode: mode,
      transaction: transaction,
      direction: direction,
      currency: currency,
      service: service,
      categoriesService: categoriesService,
      bankAccountsService: bankAccountsService
    ))
    self.mode = mode
    self.onSave = onSave
    self.onDelete = onDelete
  }
  
  var body: some View {
    NavigationView {
      List {
        Section {
          categoryRow
          amountField
          dateRow
          timeRow
          commentField
        }
        if mode == .edit {
          Section {
            Button(role: .destructive, action: {
              Task {
                await viewModel.delete()
                onDelete?()
                dismiss()
              }
            }) {
              Text("Удалить операцию")
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle(viewModel.direction == .outcome ? "Мои расходы" : "Мои доходы")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Отмена") { dismiss() }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            if viewModel.isValid {
              Task {
                await viewModel.save()
                onSave?()
                dismiss()
              }
            } else {
              showValidationAlert = true
            }
          }) {
            Text(mode == .edit ? "Сохранить" : "Создать")
          }
        }
      }
      .onAppear { viewModel.loadCategories() }
      .alert("Заполните все поля", isPresented: $showValidationAlert) {
        Button("OK") { }
      } message: {
        Text("Пожалуйста, заполните все обязательные поля перед сохранением операции.")
      }
      .sheet(isPresented: $showCategorySelection) {
        CategorySelectionSheet(
          categories: viewModel.categories,
          selected: viewModel.selectedCategory,
          onSelect: { category in
            viewModel.selectedCategory = category
            showCategorySelection = false
          }
        )
      }
    }
    .interactiveDismissDisabled()
  }
  
  private var categoryRow: some View {
    Button(action: {
      showCategorySelection = true
    }) {
      HStack {
        Text("Статья")
        Spacer()
        if let category = viewModel.selectedCategory {
          HStack(spacing: 8) {
            Text(category.name)
              .foregroundColor(.gray)
          }
        } else {
          Text("Выберите статью")
            .foregroundColor(.gray)
        }
        Image(systemName: "chevron.right")
          .foregroundColor(.gray)
          .font(.system(size: 14))
      }
    }
    .foregroundColor(.primary)
  }
  
  private var amountField: some View {
    HStack {
      Text("Сумма")
      Spacer()
      HStack(spacing: 4) {
        TextField("0", text: $viewModel.amount)
          .keyboardType(.decimalPad)
          .multilineTextAlignment(.trailing)
          .frame(width: 120)
          .onChange(of: viewModel.amount) { newValue in
            viewModel.validateAmountInput(newValue)
          }
        Text(viewModel.currencySymbol)
          .foregroundColor(.gray)
          .font(.system(size: 16))
      }
    }
  }
  
  private var dateRow: some View {
    HStack {
      Text("Дата")
      Spacer()
      DatePicker("", selection: Binding(
        get: { viewModel.date },
        set: { newDate in viewModel.updateDateOnly(newDate) }
      ), in: ...Date(), displayedComponents: [.date])
      .labelsHidden()
      .background(.accent.opacity(0.2))
      .cornerRadius(8)
      .tint(.accent)
    }
  }
  
  private var timeRow: some View {
    HStack {
      Text("Время")
      Spacer()
      DatePicker("", selection: Binding(
        get: { viewModel.date },
        set: { newDate in viewModel.updateTimeOnly(newDate) }
      ), displayedComponents: [.hourAndMinute])
      .labelsHidden()
      .background(.accent.opacity(0.2))
      .cornerRadius(8)
      .tint(.accent)
    }
  }
  
  private var commentField: some View {
    HStack {
      TextField("Комментарий", text: $viewModel.comment)
        .foregroundColor(viewModel.comment.isEmpty ? .gray : .primary)
    }
  }
}

// MARK: - CategorySelectionSheet

struct CategorySelectionSheet: View {
  let categories: [Category]
  let selected: Category?
  let onSelect: (Category) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var searchText = ""
  
  var filteredCategories: [Category] {
    if searchText.isEmpty {
      return categories
    } else {
      return categories.filter { category in
        category.name.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Search bar
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
          TextField("Поиск статей", text: $searchText)
            .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        
        // Categories list
        List {
          ForEach(filteredCategories) { category in
            Button(action: {
              onSelect(category)
            }) {
              HStack {
                Text("\(category.emoji)")
                  .font(.title2)
                Text(category.name)
                  .foregroundColor(.primary)
                Spacer()
                if selected?.id == category.id {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 20))
                }
              }
              .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
        .listStyle(PlainListStyle())
      }
      .navigationTitle("Выберите статью")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Отмена") {
            dismiss()
          }
        }
      }
    }
  }
}

// MARK: - ViewModel

final class TransactionEditViewModel: ObservableObject {
  @Published var selectedCategory: Category?
  @Published var amount: String = ""
  @Published var date: Date = Date()
  @Published var comment: String = ""
  @Published var categories: [Category] = []
  
  private let mode: TransactionEditMode
  private let transaction: Transaction?
  let direction: Direction
  private let currency: Currency
  private let service: TransactionsService
  private let categoriesService: CategoriesService
  private let bankAccountsService: BankAccountsService
  
  private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }()
  
  var canSave: Bool {
    selectedCategory != nil && Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) != nil
  }
  
  var isValid: Bool {
    selectedCategory != nil &&
    !amount.isEmpty &&
    Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) != nil
  }
  
  var currencySymbol: String {
    currency.symbol
  }
  
  init(
    mode: TransactionEditMode,
    transaction: Transaction?,
    direction: Direction,
    currency: Currency,
    service: TransactionsService,
    categoriesService: CategoriesService,
    bankAccountsService: BankAccountsService
  ) {
    self.mode = mode
    self.transaction = transaction
    self.direction = direction
    self.currency = currency
    self.service = service
    self.categoriesService = categoriesService
    self.bankAccountsService = bankAccountsService
    
    if let transaction {
      self.selectedCategory = transaction.category
      self.amount = Self.formatDecimal(transaction.amount)
      self.date = transaction.transactionDate
      self.comment = transaction.comment ?? ""
    }
  }
  
  func loadCategories() {
    Task {
      let cats = await categoriesService.getCategories(by: direction)
      await MainActor.run {
        self.categories = cats
      }
    }
  }
  
  func validateAmountInput(_ input: String) {
    let decimalSeparator = numberFormatter.decimalSeparator ?? "."
    let allowedCharacters = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
    
    let filtered = input.filter { char in
      allowedCharacters.contains(char.unicodeScalars.first!)
    }
    
    let components = filtered.components(separatedBy: decimalSeparator)
    if components.count > 2 {
      let beforeSeparator = components[0]
      let afterSeparator = components.dropFirst().joined()
      amount = beforeSeparator + decimalSeparator + afterSeparator
    } else {
      amount = filtered
    }
  }
  
  func save() async {
    guard let category = selectedCategory,
          let amountDecimal = Decimal(string: amount.replacingOccurrences(of: ",", with: "."))
    else { return }
    let newTransaction = Transaction(
      id: transaction?.id ?? Int(Date().timeIntervalSince1970),
      category: category,
      amount: amountDecimal,
      transactionDate: date,
      comment: comment.isEmpty ? nil : comment
    )
    switch mode {
    case .create:
      _ = try? await bankAccountsService.getUserAccount() // just to simulate account fetch
      await service.create(transaction: newTransaction)
    case .edit:
      await service.update(transaction: newTransaction)
    }
  }
  
  func delete() async {
    guard let id = transaction?.id else { return }
    await service.delete(withId: id)
  }
  
  func updateDateOnly(_ newDate: Date) {
    let calendar = Calendar.current
    let time = calendar.dateComponents([.hour, .minute, .second], from: date)
    var components = calendar.dateComponents([.year, .month, .day], from: newDate)
    components.hour = time.hour
    components.minute = time.minute
    components.second = time.second
    if let combined = calendar.date(from: components) {
      date = combined
    }
  }
  
  func updateTimeOnly(_ newTime: Date) {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let time = calendar.dateComponents([.hour, .minute, .second], from: newTime)
    var components = dateComponents
    components.hour = time.hour
    components.minute = time.minute
    components.second = time.second
    if let combined = calendar.date(from: components) {
      date = combined
    }
  }
  
  private static func formatDecimal(_ value: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: value as NSNumber) ?? "0"
  }
}

// MARK: - Preview

#Preview {
  TransactionEditView(
    mode: .create,
    direction: .outcome,
    currency: .rub
  )
}
