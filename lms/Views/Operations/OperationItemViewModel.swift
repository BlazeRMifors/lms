//
//  OperationItemViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 18.06.2025.
//

import Foundation

struct OperationItemViewModel: Identifiable {
  var id: UUID = UUID()
  var icon: String
  var title: String
  var comment: String?
  var sum: String
  var time: String?
}


enum MockOperation {
  static let withComment = OperationItemViewModel(
    icon: "🐕",
    title: "На собачку",
    comment: "Джек",
    sum: "5 000 ₽"
  )
  
  static let withoutComment = OperationItemViewModel(
    icon: "🏠",
    title: "Аренда квартиры",
    sum: "100 000 ₽"
  )
  
  static let withLongCommentAndTime = OperationItemViewModel(
    icon: "🔨",
    title: "Ремонт квартиры",
    comment: "Ремонт - фурнитура для дверей",
    sum: "10 000 ₽",
    time: "21:00"
  )
  
  static let allCases: [OperationItemViewModel] = [
    Self.withComment,
    Self.withoutComment,
    Self.withLongCommentAndTime
  ]
}
