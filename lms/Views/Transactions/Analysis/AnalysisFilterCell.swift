//
//  AnalysisFilterCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

class AnalysisFilterCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let container = UIView()
    private var customView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        container.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [titleLabel, container])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(title: String, customView: UIView) {
        titleLabel.text = title
        self.customView?.removeFromSuperview()
        self.customView = customView
        customView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(customView)
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: container.topAnchor),
            customView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
}
