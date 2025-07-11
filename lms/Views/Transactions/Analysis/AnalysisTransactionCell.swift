//
//  AnalysisTransactionCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

class AnalysisTransactionCell: UITableViewCell {
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
