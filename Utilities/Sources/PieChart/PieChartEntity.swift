//
//  PieChartEntity.swift
//  Utilities
//
//  Created by Ivan Isaev on 24.07.2025.
//

import Foundation
import UIKit

public struct PieChartEntity {
  
    public let value: Decimal
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

internal struct PieSegment {
    let value: Decimal
    let label: String
    let color: UIColor
    let percentage: Double
    let startAngle: CGFloat
    let endAngle: CGFloat
} 
