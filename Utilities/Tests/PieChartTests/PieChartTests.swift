//
//  PieChartTests.swift
//  Utilities
//
//  Created by Ivan Isaev on 24.07.2025.
//

import XCTest
import UIKit
@testable import PieChart

final class PieChartTests: XCTestCase {
    
    func testPieChartViewInitialization() {
        let entities = [
            PieChartEntity(value: 30, label: "Category A"),
            PieChartEntity(value: 70, label: "Category B")
        ]
        let pieChartView = PieChartView(entities: entities)
        
        XCTAssertEqual(pieChartView.entities.count, 2)
        XCTAssertEqual(pieChartView.entities[0].value, 30)
        XCTAssertEqual(pieChartView.entities[1].value, 70)
    }
    
    func testEmptyEntities() {
        let entities: [PieChartEntity] = []
        let pieChartView = PieChartView(entities: entities)
      
        XCTAssertTrue(pieChartView.entities.isEmpty)
    }
    
    func testUpdateEntities() {
        let initialEntities = [PieChartEntity(value: 50, label: "Initial")]
        let pieChartView = PieChartView(entities: initialEntities)
        
        let newEntities = [
            PieChartEntity(value: 30, label: "New 1"),
            PieChartEntity(value: 70, label: "New 2")
        ]
        
        pieChartView.updateEntities(newEntities)
        
        XCTAssertEqual(pieChartView.entities.count, 2)
        XCTAssertEqual(pieChartView.entities[0].label, "New 1")
        XCTAssertEqual(pieChartView.entities[1].label, "New 2")
    }
} 
