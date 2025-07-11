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
                    NavigationLink(isActive: $showCategorySelection) {
                        CategorySelectionView(
                            categories: viewModel.categories,
                            selected: viewModel.selectedCategory,
                            onSelect: { cat in
                                viewModel.selectedCategory = cat
                                showCategorySelection = false
                            }
                        )
                    } label: {
                        HStack {
                            Text("Статья")
                            Spacer()
                            if let category = viewModel.selectedCategory {
                                Text(category.name)
//                                    .foregroundColor(.primary)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Выберите статью")
                                    .foregroundColor(.gray)
                            }
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.accentColor)
                        }
                    }
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
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(mode == .edit ? "Редактировать операцию" : "Создать операцию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.save()
                            onSave?()
                            dismiss()
                        }
                    }) {
                        Text(mode == .edit ? "Сохранить" : "Создать")
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear { viewModel.loadCategories() }
        }
        .interactiveDismissDisabled()
    }

    private var amountField: some View {
        HStack {
            Text("Сумма")
            Spacer()
            TextField("0", text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
        }
    }

    private var dateRow: some View {
        HStack {
            Text("Дата")
            Spacer()
            DatePicker("", selection: Binding(
                get: { viewModel.date },
                set: { newDate in viewModel.updateDateOnly(newDate) }
            ), displayedComponents: [.date])
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

// MARK: - CategorySelectionView

struct CategorySelectionView: View {
    let categories: [Category]
    let selected: Category?
    let onSelect: (Category) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(categories) { category in
            Button(action: {
                onSelect(category)
                dismiss()
            }) {
                HStack {
                    Text("\(category.emoji)")
                    Text(category.name)
                    Spacer()
                    if selected?.id == category.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .foregroundColor(.primary)
        }
        .navigationTitle("Выберите статью")
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
    private let direction: Direction
    private let currency: Currency
    private let service: TransactionsService
    private let categoriesService: CategoriesService
    private let bankAccountsService: BankAccountsService

    var canSave: Bool {
        selectedCategory != nil && Decimal(string: amount.replacingOccurrences(of: ",", with: ".")) != nil
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
