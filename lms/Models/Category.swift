//
//  Category.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

enum Direction {
    case income
    case outcome
}

struct Category: Identifiable {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
}
