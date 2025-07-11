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
  
  private enum Section: Int, CaseIterable {
    case setting = 0
    case operations
  }
  
  private enum SettingRow: Int, CaseIterable {
    case start = 0
    case end
    case sort
    case sum
  }
  
  // MARK: - UI
  private let tableView = UITableView(frame: .zero, style: .insetGrouped)
  private var viewModel: AnalysisViewModel?
  
  private var transactions: [Transaction] { viewModel?.transactions ?? [] }
  private var totalAmount: Decimal { viewModel?.totalAmount ?? 0 }
  private var currency: Currency { viewModel?.currency ?? .rub }
  
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
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(AnalysisTransactionCell.self, forCellReuseIdentifier: "TransactionCell")
    tableView.register(AnalysisSumCell.self, forCellReuseIdentifier: "SumCell")
    tableView.register(AnalysisDateCell.self, forCellReuseIdentifier: "DateCell")
    tableView.register(AnalysisSortCell.self, forCellReuseIdentifier: "SortCell")
  }
  
  private func reloadData() {
    tableView.reloadData()
  }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    section == Section.setting.rawValue ? SettingRow.allCases.count : transactions.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    section == Section.operations.rawValue ? "Операции" : nil
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    indexPath.section == Section.setting.rawValue ? 44 : 60
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      switch indexPath.row {
      case 0:
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! AnalysisDateCell
        let vm = AnalysisDateItemViewModel(title: "Начало", date: viewModel?.startDate ?? Date()) { [weak self] newDate in
          self?.viewModel?.updateStartDate(newDate)
          self?.reloadData()
        }
        cell.configure(with: vm)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.selectionStyle = .none
        return cell
      case 1:
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! AnalysisDateCell
        let vm = AnalysisDateItemViewModel(title: "Конец", date: viewModel?.endDate ?? Date()) { [weak self] newDate in
          self?.viewModel?.updateEndDate(newDate)
          self?.reloadData()
        }
        cell.configure(with: vm)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.selectionStyle = .none
        return cell
      case 2:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as! AnalysisSortCell
        let sortType = viewModel?.sortType ?? .date
        let viewModel = AnalysisSortItemViewModel(sortType: sortType) { [weak self] newType in
          self?.viewModel?.toggleSortType(newType)
          self?.reloadData()
        }
        cell.configure(with: viewModel)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.selectionStyle = .none
        return cell
      case 3:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SumCell", for: indexPath) as! AnalysisSumCell
        let viewModel = AnalysisSumItemViewModel(amount: totalAmount, currency: currency)
        cell.configure(with: viewModel)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.selectionStyle = .none
        return cell
      default:
        return UITableViewCell()
      }
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? AnalysisTransactionCell, let viewModel else {
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
}
