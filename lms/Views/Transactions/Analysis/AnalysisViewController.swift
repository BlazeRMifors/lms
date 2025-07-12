import UIKit
import SwiftUI

final class AnalysisViewController: UIViewController {
  
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
  private var viewModel: AnalysisViewModel
  
  init(viewModel: AnalysisViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    self.viewModel.onUpdate = { [weak self] in
      self?.reloadData()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupTableView()
  }
  
  private func setupUI() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    tableView.backgroundColor = .clear
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.loadTransactions()
    reloadData()
  }
  
  private func setupTableView() {
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
  
  private func presentTransactionEditView(for transaction: Transaction) {
    let transactionEditView = TransactionEditView(
      mode: .edit,
      transaction: transaction,
      direction: viewModel.direction,
      currency: viewModel.currency,
      service: viewModel.service,
      onSave: { [weak self] in
        self?.viewModel.loadTransactions()
      },
      onDelete: { [weak self] in
        self?.viewModel.loadTransactions()
      }
    )
    
    let hostingController = UIHostingController(rootView: transactionEditView)
    hostingController.modalPresentationStyle = .formSheet
    present(hostingController, animated: true)
  }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    section == Section.setting.rawValue ? SettingRow.allCases.count : viewModel.transactions.count
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
        let vm = AnalysisDateItemViewModel(title: "Начало", date: viewModel.startDate) { [weak self] newDate in
          self?.viewModel.updateStartDate(newDate)
          self?.reloadData()
        }
        cell.configure(with: vm)
        cell.selectionStyle = .none
        return cell
      case 1:
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! AnalysisDateCell
        let vm = AnalysisDateItemViewModel(title: "Конец", date: viewModel.endDate) { [weak self] newDate in
          self?.viewModel.updateEndDate(newDate)
          self?.reloadData()
        }
        cell.configure(with: vm)
        cell.selectionStyle = .none
        return cell
      case 2:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as! AnalysisSortCell
        let sortType = viewModel.sortType
        let viewModel = AnalysisSortItemViewModel(sortType: sortType) { [weak self] newType in
          self?.viewModel.toggleSortType(newType)
          self?.reloadData()
        }
        cell.configure(with: viewModel)
        cell.selectionStyle = .none
        return cell
      case 3:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SumCell", for: indexPath) as! AnalysisSumCell
        let viewModel = AnalysisSumItemViewModel(amount: viewModel.totalAmount, currency: viewModel.currency)
        cell.configure(with: viewModel)
        cell.selectionStyle = .none
        return cell
      default:
        return UITableViewCell()
      }
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? AnalysisTransactionCell else {
        return UITableViewCell()
      }
      let transaction = viewModel.transactions[indexPath.row]
      let percent = viewModel.percent(for: transaction)
      let vm = AnalysisTransactionItemViewModel(
        icon: "\(transaction.category.emoji)",
        name: transaction.category.name,
        amount: BaseConverter.toPrettySum(transaction.amount, currency: viewModel.currency),
        percent: String(format: "%.1f%%", percent),
        comment: transaction.comment
      )
      cell.configure(with: vm)
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    // Обрабатываем только ячейки транзакций
    guard indexPath.section == Section.operations.rawValue else { return }
    
    let transaction = viewModel.transactions[indexPath.row]
    presentTransactionEditView(for: transaction)
  }
}
