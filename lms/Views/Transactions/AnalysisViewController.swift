import UIKit

class AnalysisViewModel {
    private let baseViewModel: TransactionsListViewModel
    
    var transactions: [Transaction] { baseViewModel.transactions }
    var startDate: Date { baseViewModel.startDate }
    var endDate: Date { baseViewModel.endDate }
    var sortType: TransactionSortType { baseViewModel.sortType }
    var totalAmount: Decimal { baseViewModel.totalAmount }
    var currency: Currency { baseViewModel.currency }
    
    init(baseViewModel: TransactionsListViewModel) {
        self.baseViewModel = baseViewModel
    }
    
    func updateStartDate(_ date: Date) { baseViewModel.updateStartDate(date) }
    func updateEndDate(_ date: Date) { baseViewModel.updateEndDate(date) }
    func toggleSortType(_ type: TransactionSortType) { baseViewModel.toggleSortType(type) }
    func reload() { baseViewModel.loadTransactions() }
    
    func percent(for transaction: Transaction) -> Double {
        guard totalAmount != 0 else { return 0 }
        return (transaction.amount as NSDecimalNumber).doubleValue / (totalAmount as NSDecimalNumber).doubleValue * 100
    }
}

class AnalysisViewController: UIViewController {
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let accentColor = UIColor(named: "AccentColor") ?? UIColor.systemBlue
    private var viewModel: AnalysisViewModel?
    
    private var transactions: [Transaction] { viewModel?.transactions ?? [] }
    private var totalAmount: Decimal { viewModel?.totalAmount ?? 0 }
    private var currency: Currency { viewModel?.currency ?? .rub }
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale(identifier: "ru_RU")
        return df
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 42, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
    }

    func configure(with viewModel: AnalysisViewModel) {
        self.viewModel = viewModel
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func setupBindings() {
        guard let viewModel else { return }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.register(SumCell.self, forCellReuseIdentifier: "SumCell")
        tableView.register(DateCell.self, forCellReuseIdentifier: "DateCell")
        tableView.register(SortCell.self, forCellReuseIdentifier: "SortCell")
    }
    
    private func reloadData() {
        guard let viewModel else { return }
        tableView.reloadData()
    }
    
    private func formattedAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU_POSIX")
        return formatter.string(from: amount as NSDecimalNumber) ?? "0"
    }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4 // start, end, sort, sum
        } else {
            return transactions.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
                let date = viewModel?.startDate ?? Date()
                cell.configure(title: "Начало", date: date, accent: accentColor)
                cell.onTap = { [weak self] in self?.showDatePicker(for: .start) }
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
                let date = viewModel?.endDate ?? Date()
                cell.configure(title: "Конец", date: date, accent: accentColor)
                cell.onTap = { [weak self] in self?.showDatePicker(for: .end) }
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as! SortCell
                let sortType = viewModel?.sortType ?? .date
                cell.configure(selected: sortType, menuStyle: true) { [weak self] newType in
                    self?.viewModel?.toggleSortType(newType)
                    self?.reloadData()
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SumCell", for: indexPath) as! SumCell
                cell.configure(amount: totalAmount, currency: currency)
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell, let viewModel else {
                return UITableViewCell()
            }
            let transaction = transactions[indexPath.row]
            let percent = viewModel.percent(for: transaction)
            cell.configure(with: transaction, currency: currency, percent: percent)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
            cell.contentLeadingInset = 8
            cell.contentTrailingInset = 8
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return "Операции" }
        return nil
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = .preferredFont(forTextStyle: .subheadline)
            header.textLabel?.textColor = .label
            header.textLabel?.textAlignment = .left
            header.textLabel?.frame = CGRect(x: 16, y: 0, width: header.bounds.width - 16, height: header.bounds.height)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 44 }
        if indexPath.section == 1 { return 60 }
        return UITableView.automaticDimension
    }
}

class TransactionCell: UITableViewCell {
    private let emojiLabel = UILabel()
    private let emojiBg = UIView()
    private let nameLabel = UILabel()
    private let commentLabel = UILabel()
    private let amountLabel = UILabel()
    private let percentLabel = UILabel()
    private let rightVStack = UIStackView()
    private let stack = UIStackView()
    var contentLeadingInset: CGFloat = 0 {
        didSet { stack.layoutMargins = UIEdgeInsets(top: 0, left: contentLeadingInset, bottom: 0, right: stack.layoutMargins.right) }
    }
    var contentTrailingInset: CGFloat = 0 {
        didSet { stack.layoutMargins = UIEdgeInsets(top: 0, left: stack.layoutMargins.left, bottom: 0, right: contentTrailingInset) }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        emojiLabel.font = .systemFont(ofSize: 20)
        emojiLabel.textAlignment = .center
        let accent = UIColor(named: "AccentColor") ?? UIColor.systemBlue
        emojiBg.backgroundColor = accent.withAlphaComponent(0.2)
        emojiBg.layer.cornerRadius = 16
        emojiBg.translatesAutoresizingMaskIntoConstraints = false
        emojiBg.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBg.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBg.centerYAnchor),
            emojiBg.widthAnchor.constraint(equalToConstant: 32),
            emojiBg.heightAnchor.constraint(equalToConstant: 32)
        ])

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        commentLabel.font = .systemFont(ofSize: 13)
        commentLabel.textColor = .gray
        amountLabel.font = .systemFont(ofSize: 16, weight: .regular)
        percentLabel.font = .systemFont(ofSize: 13)
        percentLabel.textColor = .gray
        percentLabel.textAlignment = .right
        rightVStack.axis = .vertical
        rightVStack.spacing = 0
        rightVStack.alignment = .trailing
        rightVStack.addArrangedSubview(percentLabel)
        rightVStack.addArrangedSubview(amountLabel)

        let vStack = UIStackView(arrangedSubviews: [nameLabel, commentLabel])
        vStack.axis = .vertical
        vStack.spacing = 2

        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(emojiBg)
        stack.addArrangedSubview(vStack)
        stack.addArrangedSubview(UIView()) // Spacer
        stack.addArrangedSubview(rightVStack)

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        contentView.backgroundColor = .clear
        stack.isLayoutMarginsRelativeArrangement = true
    }

    func configure(with transaction: Transaction, currency: Currency, percent: Double) {
        emojiLabel.text = "\(transaction.category.emoji)"
        nameLabel.text = transaction.category.name
        commentLabel.text = transaction.comment
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU_POSIX")
        let amountString = formatter.string(from: transaction.amount as NSDecimalNumber) ?? "0"
        amountLabel.text = "\(amountString) \(currency.symbol)"
        percentLabel.text = String(format: "%.1f%%", percent)
        commentLabel.isHidden = transaction.comment == nil
    }
}

class FilterCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let container = UIView()
    private var customView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        container.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [titleLabel, container])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(title: String, customView: UIView) {
        titleLabel.text = title
        self.customView?.removeFromSuperview()
        self.customView = customView
        customView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(customView)
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: container.topAnchor),
            customView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
}

class SumCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.text = "Сумма"
        titleLabel.font = .systemFont(ofSize: 16)
        amountLabel.font = .systemFont(ofSize: 16, weight: .regular)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(amountLabel)
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(amount: Decimal, currency: Currency) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU_POSIX")
        let amountString = formatter.string(from: amount as NSDecimalNumber) ?? "0"
        amountLabel.text = "\(amountString) \(currency.symbol)"
    }
}

class DateCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let bg = UIView()
    private let spacer = UIView()
    var onTap: (() -> Void)?
    private let stack: UIStackView
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        stack = UIStackView(arrangedSubviews: [titleLabel, spacer, bg])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16)
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textAlignment = .right
        bg.layer.cornerRadius = 8
        bg.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: bg.topAnchor, constant: 2),
            dateLabel.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -2),
            dateLabel.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            bg.heightAnchor.constraint(equalToConstant: 32)
        ])
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    func configure(title: String, date: Date, accent: UIColor) {
        titleLabel.text = title
        dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        bg.backgroundColor = accent.withAlphaComponent(0.2)
    }
    @objc private func tapAction() { onTap?() }
}

class SortCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private var onSelect: ((TransactionSortType) -> Void)?
    private let stack: UIStackView
    private var menuStyle: Bool = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16)
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textAlignment = .right
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    func configure(selected: TransactionSortType, menuStyle: Bool = false, onSelect: @escaping (TransactionSortType) -> Void) {
        titleLabel.text = "Сортировка"
        valueLabel.text = selected == .date ? "По дате" : "По сумме"
        self.onSelect = onSelect
        self.menuStyle = menuStyle
    }
    @objc private func tapAction() {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "По дате", style: .default, handler: { [weak self] _ in self?.onSelect?(.date) }))
        alert.addAction(UIAlertAction(title: "По сумме", style: .default, handler: { [weak self] _ in self?.onSelect?(.amount) }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let vc = self.parentViewController {
            if let popover = alert.popoverPresentationController {
                popover.sourceView = self
                popover.sourceRect = self.bounds
            }
            vc.present(alert, animated: true)
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let vc = responder as? UIViewController {
                return vc
            }
            parentResponder = responder.next
        }
        return nil
    }
}

extension AnalysisViewController {
    private enum DateType { case start, end }
    private func showDatePicker(for type: DateType) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU")
        switch type {
        case .start:
            picker.date = viewModel?.startDate ?? Date()
        case .end:
            picker.date = viewModel?.endDate ?? Date()
        }
        let alert = UIAlertController(title: type == .start ? "Начало" : "Конец", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 216)
        ])
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            switch type {
            case .start:
                self?.viewModel?.updateStartDate(picker.date)
            case .end:
                self?.viewModel?.updateEndDate(picker.date)
            }
            self?.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let popover = alert.popoverPresentationController, let cell = tableView.cellForRow(at: IndexPath(row: type == .start ? 0 : 1, section: 0)) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }
} 
