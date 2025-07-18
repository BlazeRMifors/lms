//
//  CategoryDTO.swift
//  lms
//
//  Created by Ivan Isaev on 17.07.2025.
//

import Foundation

struct CategoryResponseDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    func toDomain() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji.first ?? " ",
            direction: isIncome ? .income : .outcome
        )
    }
} 
