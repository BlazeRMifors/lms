//
//  BankAccount.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

struct BankAccount: Identifiable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: Currency
}

enum Currency: String, CaseIterable, Identifiable, CustomStringConvertible {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
            case .rub: return "₽"
            case .usd: return "$"
            case .eur: return "€"
        }
    }
    
    var description: String {
        switch self {
            case .rub: return "Российский рубль ₽"
            case .usd: return "Американский доллар $"
            case .eur: return "Евро €"
        }
    }
}
