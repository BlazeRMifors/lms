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
    titleLabel.text = "Сумма"
  }
  
  private func addSubviews() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(amountLabel)
  }
  
  private func setupLayout() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    amountLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
    ])
    
    NSLayoutConstraint.activate([
      amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ])
  }
  
  func configure(with viewModel: AnalysisSumItemViewModel) {
    amountLabel.text = BaseConverter.toPrettySum(viewModel.amount, currency: viewModel.currency)
  }
}
