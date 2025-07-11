//
//  AnalysisDateCell.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import UIKit

class AnalysisDateCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let bg = UIView()
    private let spacer = UIView()
    var onTap: (() -> Void)?
    private let stack: UIStackView
    private var pickerContainer: UIView?
    private var picker: UIDatePicker?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        stack = UIStackView(arrangedSubviews: [titleLabel, spacer, bg])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16)
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textAlignment = .right
        bg.layer.cornerRadius = 8
        bg.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: bg.topAnchor, constant: 2),
            dateLabel.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -2),
            dateLabel.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -8),
            bg.heightAnchor.constraint(equalToConstant: 32)
        ])
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
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
    func configure(title: String, date: Date, accent: UIColor) {
        titleLabel.text = title
        dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        bg.backgroundColor = accent.withAlphaComponent(0.2)
        // Удаляем picker если был
        pickerContainer?.removeFromSuperview()
        pickerContainer = nil
        picker = nil
    }
    func configureWithPicker(title: String, picker: UIDatePicker, accent: UIColor) {
        titleLabel.text = title
        bg.backgroundColor = .clear
        dateLabel.text = nil
        // Удаляем старый picker если был
        pickerContainer?.removeFromSuperview()
        pickerContainer = UIView()
        pickerContainer!.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        pickerContainer!.addSubview(picker)
        picker.tintColor = accent
        picker.backgroundColor = accent.withAlphaComponent(0.2)
        picker.layer.cornerRadius = 8
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: pickerContainer!.topAnchor),
            picker.bottomAnchor.constraint(equalTo: pickerContainer!.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: pickerContainer!.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: pickerContainer!.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 32),
            picker.widthAnchor.constraint(equalToConstant: 140)
        ])
        // Удаляем bg из stack если был
        if stack.arrangedSubviews.contains(bg) {
            stack.removeArrangedSubview(bg)
            bg.removeFromSuperview()
        }
        stack.addArrangedSubview(pickerContainer!)
    }
    @objc private func tapAction() { onTap?() }
}
