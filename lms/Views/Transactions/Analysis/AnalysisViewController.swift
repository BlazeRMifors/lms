import UIKit
import SwiftUI
import PieChart

final class AnalysisViewController: UIViewController {
  
  private enum Section: Int, CaseIterable {
    case setting = 0
    case chart
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
  private var loaderView: UIActivityIndicatorView?
  private var errorAlert: UIAlertController?
  private var pieChartView: PieChartView?
  
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
    setupObservers()
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
    reloadData(animated: false)
  }
  
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(AnalysisTransactionCell.self, forCellReuseIdentifier: "TransactionCell")
    tableView.register(AnalysisSumCell.self, forCellReuseIdentifier: "SumCell")
    tableView.register(AnalysisDateCell.self, forCellReuseIdentifier: "DateCell")
    tableView.register(AnalysisSortCell.self, forCellReuseIdentifier: "SortCell")
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PieChartCell")
  }
  
  private func setupObservers() {
    viewModel.onUpdate = { [weak self] in
      self?.reloadData()
      self?.updateLoading()
      self?.updateErrorAlert()
    }
    
    updateLoading()
    updateErrorAlert()
  }

  private func updateLoading() {
    if viewModel.isLoading {
      if loaderView == nil {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = .gray
        view.addSubview(loader)
        NSLayoutConstraint.activate([
          loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loader.startAnimating()
        loaderView = loader
      }
    } else {
      loaderView?.removeFromSuperview()
      loaderView = nil
    }
  }

  private func updateErrorAlert() {
    if let message = viewModel.errorMessage, !message.isEmpty, errorAlert == nil {
      let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
        self?.viewModel.errorMessage = nil
        self?.errorAlert = nil
      })
      present(alert, animated: true)
      errorAlert = alert
    } else if viewModel.errorMessage == nil, let alert = errorAlert {
      alert.dismiss(animated: true)
      errorAlert = nil
    }
  }
  
  private func reloadData() {
    reloadData(animated: true)
  }
  
  private func reloadData(animated: Bool = true) {
    tableView.reloadData()
    
    if let pieChartView = pieChartView {
      let entities = viewModel.createPieChartEntities()
      if animated {
        pieChartView.updateEntitiesAnimated(entities)
      } else {
        pieChartView.updateEntities(entities)
      }
    }
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
    switch Section(rawValue: section) {
    case .setting:
      return SettingRow.allCases.count
    case .chart:
      return viewModel.transactions.isEmpty ? 0 : 1
    case .operations:
      return viewModel.transactions.count
    case .none:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch Section(rawValue: section) {
    case .operations:
      return "Операции"
    case .setting, .chart:
      return nil
    case .none:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch Section(rawValue: indexPath.section) {
    case .setting:
      return 44
    case .chart:
      return 185
    case .operations:
      return 60
    case .none:
      return 44
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch Section(rawValue: indexPath.section) {
    case .setting:
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
      
    case .chart:
      let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartCell", for: indexPath)
      setupPieChartCell(cell)
      return cell
      
    case .operations:
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
      
    case .none:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard indexPath.section == Section.operations.rawValue else { return }
    
    let transaction = viewModel.transactions[indexPath.row]
    presentTransactionEditView(for: transaction)
  }
  
  // MARK: - PieChart Setup
  private func setupPieChartCell(_ cell: UITableViewCell) {
    pieChartView?.removeFromSuperview()
    
    let entities = viewModel.createPieChartEntities()
    pieChartView = PieChartView(entities: entities)
    
    guard let pieChartView = pieChartView else { return }
    
    pieChartView.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addSubview(pieChartView)
    
    NSLayoutConstraint.activate([
      pieChartView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0),
      pieChartView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
      pieChartView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
      pieChartView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0)
    ])
    
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    cell.selectionStyle = .none
  }
}
