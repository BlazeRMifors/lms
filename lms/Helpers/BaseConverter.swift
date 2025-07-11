//
//  BaseConverter.swift
//  lms
//
//  Created by Ivan Isaev on 11.07.2025.
//

import Foundation

final class BaseConverter {
  static let amountFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ru_RU_POSIX")
    return formatter
  }()
  
  static func toPrettyAmount(_ amount: Decimal) -> String {
    return amountFormatter.string(from: amount as NSDecimalNumber) ?? "0"
  }
  
  static func toPrettySum(_ amount: Decimal, currency: Currency) -> String {
    return "\(toPrettyAmount(amount)) \(currency.symbol)"
  }
}
