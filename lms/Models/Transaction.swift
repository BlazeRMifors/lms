//
//  Transaction.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

/**
 Структура содержит ряд дополнительных полей, которые были намерено пропущенны.
 Предполагается, что эти данные не понадобятся далее по коду.
 При уточнении ТЗ, структура может быть пересмотрена.
 
 Исключенные свойства:
 
 let account: BankAccount
 - По условию счет будет только один, соответсвенно мы изначально знаем куда привязаны все транзакции
 
 let createdAt: Date
 let updatedAt: Date
 - Никак не отображены в макетах
 
 TODO: LMS - Доработать, когда будут известны новые подробности по домашкам
 */
struct Transaction: Identifiable, Hashable {
  let id: Int
  let category: Category
  let amount: Decimal
  let transactionDate: Date
  let comment: String?
}
