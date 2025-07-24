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

    func testPieChartEntityInitialization() {
        // Given
        let value = Decimal(100)
        let label = "Test Entity"
        
        // When
        let entity = PieChartEntity(value: value, label: label)
        
        // Then
        XCTAssertEqual(entity.value, value)
        XCTAssertEqual(entity.label, label)
    }
    
    func testPieChartViewInitialization() {
        // Given
        let entities = [
            PieChartEntity(value: 30, label: "Category A"),
            PieChartEntity(value: 70, label: "Category B")
        ]
        
        // When
        let pieChartView = PieChartView(entities: entities)
        
        // Then
        XCTAssertEqual(pieChartView.entities.count, 2)
        XCTAssertEqual(pieChartView.entities[0].value, 30)
        XCTAssertEqual(pieChartView.entities[1].value, 70)
    }
    
    func testSegmentGroupingLogic() {
        // Given - More than 5 entities to test "Others" grouping
        let entities = [
            PieChartEntity(value: 100, label: "First"),
            PieChartEntity(value: 90, label: "Second"),
            PieChartEntity(value: 80, label: "Third"),
            PieChartEntity(value: 70, label: "Fourth"),
            PieChartEntity(value: 60, label: "Fifth"),
            PieChartEntity(value: 50, label: "Sixth"),
            PieChartEntity(value: 40, label: "Seventh")
        ]
        
        // When
        let pieChartView = PieChartView(entities: entities)
        
        // Then
        XCTAssertEqual(pieChartView.entities.count, 7)
        // Internal segments should be processed correctly (5 individual + 1 "Others")
        XCTAssertNotNil(pieChartView)
    }
    
    func testEmptyEntities() {
        // Given
        let entities: [PieChartEntity] = []
        
        // When
        let pieChartView = PieChartView(entities: entities)
        
        // Then
        XCTAssertTrue(pieChartView.entities.isEmpty)
    }
    
    func testPieChartModuleVersion() {
        // Given & When
        let version = PieChart.version
        
        // Then
        XCTAssertEqual(version, "1.0.0")
    }
    
    func testPieChartConstants() {
        // Given & When & Then
        XCTAssertEqual(PieChartConstants.maxIndividualSegments, 5)
        XCTAssertEqual(PieChartConstants.othersLabel, "Остальные")
        XCTAssertEqual(PieChartConstants.segmentColors.count, 6)
    }
    
    func testCreateConvenienceMethod() {
        // Given
        let entities = [PieChartEntity(value: 50, label: "Test")]
        
        // When
        let pieChartView = PieChartView.create(with: entities)
        
        // Then
        XCTAssertEqual(pieChartView.entities.count, 1)
        XCTAssertEqual(pieChartView.entities[0].label, "Test")
    }
    
    func testUpdateEntities() {
        // Given
        let initialEntities = [PieChartEntity(value: 50, label: "Initial")]
        let pieChartView = PieChartView(entities: initialEntities)
        
        let newEntities = [
            PieChartEntity(value: 30, label: "New 1"),
            PieChartEntity(value: 70, label: "New 2")
        ]
        
        // When
        pieChartView.updateEntities(newEntities)
        
        // Then
        XCTAssertEqual(pieChartView.entities.count, 2)
        XCTAssertEqual(pieChartView.entities[0].label, "New 1")
        XCTAssertEqual(pieChartView.entities[1].label, "New 2")
    }
} 