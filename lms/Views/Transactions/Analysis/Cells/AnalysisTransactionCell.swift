//
//  AnalysisTransactionCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

struct AnalysisTransactionItemViewModel {
  let icon: String
  let name: String
  let amount: String
  let percent: String
  let comment: String?
}

final class AnalysisTransactionCell: UITableViewCell {
  
  private let emojiLabel = UILabel()
  private let emojiBg = UIView()
  private let nameLabel = UILabel()
  private let commentLabel = UILabel()
  private let amountLabel = UILabel()
  private let percentLabel = UILabel()
  private let stack = UIStackView()
  
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
    separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
    accessoryType = .disclosureIndicator
    
    emojiBg.backgroundColor = .accent.withAlphaComponent(0.2)
    emojiBg.layer.cornerRadius = 11
    
    emojiLabel.font = .systemFont(ofSize: 12)
    
    commentLabel.font = .systemFont(ofSize: 15)
    commentLabel.textColor = .gray
    
    stack.spacing = 16
    stack.alignment = .center
  }
  
  private func addSubviews() {
    emojiBg.addSubview(emojiLabel)
    
    let leftVStack = UIStackView(arrangedSubviews: [nameLabel, commentLabel])
    leftVStack.axis = .vertical
    
    let rightVStack = UIStackView(arrangedSubviews: [percentLabel, amountLabel])
    rightVStack.axis = .vertical
    rightVStack.alignment = .trailing
    
    stack.addArrangedSubview(emojiBg)
    stack.addArrangedSubview(leftVStack)
    stack.addArrangedSubview(rightVStack)
    
    contentView.addSubview(stack)
  }
  
  private func setupLayout() {
    emojiBg.translatesAutoresizingMaskIntoConstraints = false
    emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      emojiLabel.centerXAnchor.constraint(equalTo: emojiBg.centerXAnchor),
      emojiLabel.centerYAnchor.constraint(equalTo: emojiBg.centerYAnchor),
      emojiBg.widthAnchor.constraint(equalToConstant: 22),
      emojiBg.heightAnchor.constraint(equalToConstant: 22)
    ])
    
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.isLayoutMarginsRelativeArrangement = true
    
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: contentView.topAnchor),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ])
  }
  
  func configure(with viewModel: AnalysisTransactionItemViewModel) {
    emojiLabel.text = viewModel.icon
    nameLabel.text = viewModel.name
    commentLabel.text = viewModel.comment
    amountLabel.text = viewModel.amount
    percentLabel.text = viewModel.percent
  }
}
