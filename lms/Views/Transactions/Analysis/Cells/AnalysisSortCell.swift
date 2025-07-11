//
//  AnalysisSortCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

struct AnalysisSortItemViewModel {
  let sortType: TransactionSortType
  let onChange: ((TransactionSortType) -> Void)
}

final class AnalysisSortCell: UITableViewCell {
  
  private var viewModel: AnalysisSortItemViewModel?
  
  private let titleLabel = UILabel()
  private let sortButton = UIButton(type: .system)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    setupSubviews()
    addSubviews()
    setupLayout()
  }
  
  private func setupSubviews() {
    titleLabel.text = "Сортировка"
    
    let chevron = UIImage(
      systemName: "chevron.up.chevron.down",
      withConfiguration: UIImage.SymbolConfiguration(
        pointSize: 16,
        weight: .regular,
        scale: .small
      )
    )
    
    var config = UIButton.Configuration.filled()
    config.image = chevron
    config.imagePadding = 4
    config.baseBackgroundColor = .clear
    config.baseForegroundColor = .label
    config.titleAlignment = .trailing
    config.contentInsets.leading = .zero
    
    sortButton.configuration = config
    sortButton.semanticContentAttribute = .forceRightToLeft
  }
  
  private func setupMenu() {
    let dateAction = UIAction(title: "По дате", state: viewModel?.sortType == .date ? .on : .off) { [weak self] _ in
      self?.selectSortType(.date)
    }
    let amountAction = UIAction(title: "По сумме", state: viewModel?.sortType == .amount ? .on : .off) { [weak self] _ in
      self?.selectSortType(.amount)
    }
    let menu = UIMenu(options: .singleSelection, children: [dateAction, amountAction])
    sortButton.menu = menu
    sortButton.showsMenuAsPrimaryAction = true
  }
  
  private func addSubviews() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(sortButton)
  }
  
  private func setupLayout() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    sortButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
    ])
    
    NSLayoutConstraint.activate([
      sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ])
  }
  
  func configure(with viewModel: AnalysisSortItemViewModel) {
    self.viewModel = viewModel
    sortButton.setTitle(title(by: viewModel.sortType), for: .normal)
    setupMenu()
  }
  
  private func selectSortType(_ type: TransactionSortType) {
    guard type != viewModel?.sortType else { return }
    sortButton.setTitle(title(by: type), for: .normal)
    viewModel?.onChange(type)
  }
  
  private func title(by sortType: TransactionSortType) -> String {
    switch sortType {
    case .date: return "По дате"
    case .amount: return "По сумме"
    }
  }
}
