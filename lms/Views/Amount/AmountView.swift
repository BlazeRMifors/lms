//
//  AmountView.swift
//  lms
//
//  Created by Ivan Isaev on 20.06.2025.
//

import SwiftUI

struct AmountView: View {
  let amount: Decimal
  let currency: Currency
  
  var body: some View {
    Text(formattedAmount)
  }
  
  private var formattedAmount: String {
    let number = amount as NSNumber
    let formattedNumber = Self.formatter.string(from: number) ?? "0"
    return "\(formattedNumber) \(currency.symbol)"
  }
  
  // MARK: - Static Formatter
  private static let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ru_RU_POSIX")
    return formatter
  }()
}

#Preview {
  List {
    AmountView(amount: 1000000.25, currency: .rub)
    AmountView(amount: 1000000.25, currency: .usd)
    AmountView(amount: 1000000.25, currency: .eur)
  }
}
