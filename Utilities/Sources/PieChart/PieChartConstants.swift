//
//  PieChartConstants.swift
//  Utilities
//
//  Created by Ivan Isaev on 24.07.2025.
//

import UIKit

internal struct PieChartConstants {
    
    static let segmentColors: [UIColor] = [
        UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),  // Green
        UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),  // Yellow
        UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0),  // Red
        UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),  // Blue
        UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),  // Orange
        UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)   // Purple
    ]
  
    static let legendFont = UIFont.systemFont(ofSize: 7, weight: .medium)
    static let legendTextColor = UIColor.label
    static let backgroundColor = UIColor.clear
} 
