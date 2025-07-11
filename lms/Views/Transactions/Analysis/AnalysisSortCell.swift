//
//  AnalysisSortCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

class AnalysisSortCell: UITableViewCell {
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
