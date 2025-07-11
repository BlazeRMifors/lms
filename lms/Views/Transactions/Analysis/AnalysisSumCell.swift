//
//  AnalysisSumCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

struct AnalysisSumItemViewModel {
  let amount: Decimal
  let currency: Currency
}

final class AnalysisSumCell: UITableViewCell {
  
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
    addSubviews()
    setupLayout()
  }
  
  private func addSubviews() {
    titleLabel.text = "Сумма"
    titleLabel.font = .systemFont(ofSize: 16)
    amountLabel.font = .systemFont(ofSize: 16, weight: .regular)
    stack.axis = .horizontal
    stack.spacing = 8
    stack.alignment = .center
    stack.addArrangedSubview(titleLabel)
    stack.addArrangedSubview(UIView())
    stack.addArrangedSubview(amountLabel)
    contentView.addSubview(stack)
  }
  
  private func setupLayout() {
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ])
  }
  
  func configure(with viewModel: AnalysisSumItemViewModel) {
    amountLabel.text = BaseConverter.toPrettySum(viewModel.amount, currency: viewModel.currency)
  }
}
