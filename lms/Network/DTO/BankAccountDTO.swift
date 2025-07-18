//
//  BankAccountResponseDTO.swift
//  lms
//
//  Created by Ivan Isaev on 18.07.2025.
//

import Foundation

struct BankAccountResponseDTO: Codable, Identifiable {
    let id: Int
    let userId: Int
    let name: String
    let balance: String
    let currency: String
    let createdAt: String
    let updatedAt: String
    
    func toDomain() -> BankAccount? {
        guard let decimalBalance = Decimal(string: balance) else { return nil }
        return BankAccount(
            id: id,
            name: name,
            balance: decimalBalance,
            currency: Currency(rawValue: currency) ?? .rub
        )
    }
}

struct BankAccountUpdateDTO: Encodable {
    let name: String
    let balance: String
    let currency: String
    
    static func from(account: BankAccount, balance: Decimal, currency: Currency) -> BankAccountUpdateDTO {
        BankAccountUpdateDTO(
            name: account.name,
            balance: NSDecimalNumber(decimal: balance).stringValue,
            currency: currency.rawValue
        )
    }
} 
