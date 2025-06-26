//
//  InputViewController.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import UIKit

class InputViewController: UIViewController, UITextFieldDelegate {
  private let textField = UITextField()
  private let doneButton = UIButton(type: .system)
  private let pasteButton = UIButton(type: .system)
  
  var onCommit: (String) -> Void = { _ in }
  
  init(onCommit: @escaping (String) -> Void) {
    self.onCommit = onCommit
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    textField.delegate = self
    textField.autocorrectionType = .no
    textField.returnKeyType = .done
    
    doneButton.setTitle("Готово", for: .normal)
    doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    
    pasteButton.setTitle("Вставить", for: .normal)
    pasteButton.addTarget(self, action: #selector(pasteTapped), for: .touchUpInside)
    
    let stack = UIStackView(arrangedSubviews: [textField, pasteButton, doneButton])
    stack.axis = .vertical
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
    ])
    
    textField.becomeFirstResponder()
  }
  
  @objc private func doneTapped() {
    onCommit(textField.text ?? "")
    dismiss(animated: true)
  }
  
  @objc private func pasteTapped() {
    textField.text = UIPasteboard.general.string
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    doneTapped()
    return true
  }
}
