//
//  Category+JSON.swift
//  lms
//
//  Created by Ivan Isaev on 13.06.2025.
//

import Foundation

extension Category {
  
  // MARK: - JSON Parsing
  
  static func parse(jsonObject: Any) -> Category? {
    
    // Проверка корневого объекта
    guard let dict = jsonObject as? [String: Any] else {
      return nil
    }
    
    // Парсинг основных данных
    guard
      let categoryId = dict["id"] as? Int,
      let categoryName = dict["name"] as? String,
      let categoryIconStr = dict["emoji"] as? String,
      let categoryIcon = categoryIconStr.first,
      let categoryIsIncome = dict["isIncome"] as? Bool
    else {
      return nil
    }
    
    return Category(
      id: categoryId,
      name: categoryName,
      emoji: categoryIcon,
      direction: categoryIsIncome ? .income : .outcome
    )
  }
  
  // MARK: - JSON Serialization
  
  var jsonObject: Any {
    [
      "id": id as NSNumber,
      "name": name,
      "emoji": String(emoji),
      "isIncome": direction == .income
    ] as [String: Any]
  }
}

