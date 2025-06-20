//
//  Transaction+CSV.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

extension Transaction {
  
  // Точное количество полей
  private static let csvFieldCount = 8
  
  
  // MARK: - CSV Parsing
  
  static func parse(csvLine: String) -> Transaction? {
    // Разделение строки на компоненты
    let components = csvLine.components(separatedBy: ",")
    
    // Проверка количества полей
    guard components.count == Self.csvFieldCount else {
      return nil
    }
    
    // Парсинг основных данных транзакции
    guard
      let id = Int(components[0]),
      let amount = Decimal(string: components[1]),
      let transactionDate = ISO8601DateFormatter().date(from: components[2])
    else {
      return nil
    }
    
    // Парсинг комментария (необязательное поле)
    let comment = components[3]
    
    // Парсинг данных категории
    let categoryLine = components[4...7].joined(separator: ",")
    guard let category = Category.parse(csvLine: categoryLine) else {
      return nil
    }
    
    // Создание объекта транзакции
    return Transaction(
      id: id,
      category: category,
      amount: amount,
      transactionDate: transactionDate,
      comment: comment
    )
  }
  
  // MARK: - CSV Serialization
  
  var csvLine: String {
    let dateFormatter = ISO8601DateFormatter()
    let date = dateFormatter.string(from: transactionDate)
    let commentValue = comment ?? ""
    
    return "\(id),\(amount),\(date),\(commentValue),\(category.csvLine)"
  }
}
