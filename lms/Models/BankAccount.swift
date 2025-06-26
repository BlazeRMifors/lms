//
//  BankAccount.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

/**
 Структура содержит ряд дополнительных полей, которые были намерено пропущенны
 Предполагается, что эти данные не понадобятся далее по коду.
 При уточнении ТЗ, структура может быть пересмотрена.
 
 Исключенные свойства:
 
 let userId: Int
 - Все данные принадлежат только текущему пользователю, нет смешения с чужими данными
 
 let name: String
 - В макетах используется только название экрана "Мой счет" и нет формы, чтобы изменить данное поле
 
 let createdAt: Date
 let updatedAt: Date
 - Никак не отображены в макетах
 
 TODO: LMS - Доработать, когда будут известны новые подробности по домашкам
 */
struct BankAccount: Identifiable {
  let id: Int
  let balance: Decimal
  let currency: Currency
}

enum Currency: String, CaseIterable, Identifiable {
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
}
