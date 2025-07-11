//
//  AnalysisDateCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

struct AnalysisDateItemViewModel {
  let title: String
  let date: Date
  let onChange: ((Date) -> Void)
}

final class AnalysisDateCell: UITableViewCell {
  
  private var viewModel: AnalysisDateItemViewModel?
  
  private let titleLabel = UILabel()
  private var picker = UIDatePicker()
  
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
    picker.datePickerMode = .date
    picker.preferredDatePickerStyle = .compact
    picker.locale = Locale(identifier: "ru_RU")
    picker.addTarget(self, action: #selector(onChangeDate(_:)), for: .valueChanged)
    
    picker.tintColor = .accent
    picker.backgroundColor = .accent.withAlphaComponent(0.2)
    picker.layer.cornerRadius = 8
    picker.layer.masksToBounds = true
  }
  
  private func addSubviews() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(picker)
  }
  
  private func setupLayout() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    picker.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
    ])
    
    NSLayoutConstraint.activate([
      picker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      picker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ])
  }
  
  func configure(with viewModel: AnalysisDateItemViewModel) {
    self.viewModel = viewModel
    titleLabel.text = viewModel.title
    picker.date = viewModel.date
  }
  
  @objc private func onChangeDate(_ sender: UIDatePicker) {
    viewModel?.onChange(sender.date)
  }
}
