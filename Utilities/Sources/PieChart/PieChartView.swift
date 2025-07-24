//
//  PieChartView.swift
//  Utilities
//
//  Created by Ivan Isaev on 24.07.2025.
//

import UIKit
import Foundation

public class PieChartView: UIView {
    
    // MARK: - Public Properties
    public var entities: [PieChartEntity] = [] {
        didSet {
            processEntities()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private Properties
    private var segments: [PieSegment] = []
    private let margin: CGFloat = 0
    private let legendSpacing: CGFloat = 8
    private let ringWidth: CGFloat = 8
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public convenience init(entities: [PieChartEntity]) {
        self.init(frame: .zero)
        self.entities = entities
        processEntities()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = PieChartConstants.backgroundColor
        contentMode = .redraw
    }
    
    // MARK: - Drawing
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let chartSize = min(rect.width, rect.height) - margin * 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = chartSize / 2 - ringWidth / 2
        
        drawPieRing(in: context, center: center, radius: radius)
        drawLegendInside(center: center, radius: radius - ringWidth / 2 - 10)
    }
    
    // MARK: - Private Methods
    private func processEntities() {
        guard !entities.isEmpty else {
            segments = []
            return
        }
        
        let totalValue = entities.reduce(Decimal.zero) { $0 + $1.value }
        guard totalValue > 0 else {
            segments = []
            return
        }
        
        var currentAngle: CGFloat = -CGFloat.pi / 2
      
        segments = entities.enumerated().map { index, entity in
            let percentage = (entity.value as NSDecimalNumber).doubleValue / (totalValue as NSDecimalNumber).doubleValue
            let angle = CGFloat(percentage * 2 * Double.pi)
            let startAngle = currentAngle
            let endAngle = currentAngle + angle
            currentAngle = endAngle
            
            let color = PieChartConstants.segmentColors[index % PieChartConstants.segmentColors.count]
            
            return PieSegment(
                value: entity.value,
                label: entity.label,
                color: color,
                percentage: percentage * 100,
                startAngle: startAngle,
                endAngle: endAngle
            )
        }
    }
    
    private func drawPieRing(in context: CGContext, center: CGPoint, radius: CGFloat) {
        for segment in segments {
            let path = UIBezierPath()
            path.addArc(withCenter: center,
                       radius: radius,
                       startAngle: segment.startAngle,
                       endAngle: segment.endAngle,
                       clockwise: true)
            
            context.setStrokeColor(segment.color.cgColor)
            context.setLineWidth(ringWidth)
            context.setLineCap(.butt)
            context.addPath(path.cgPath)
            context.strokePath()
        }
    }
    
    private func drawLegendInside(center: CGPoint, radius: CGFloat) {
        let lineHeight = PieChartConstants.legendFont.lineHeight
        let totalHeight = CGFloat(segments.count) * lineHeight + CGFloat(segments.count - 1) * legendSpacing
        
        var currentY = center.y - totalHeight / 2
        
        for segment in segments {
            let percentageText = String(format: "%.0f%% %@", segment.percentage, segment.label)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: PieChartConstants.legendFont,
                .foregroundColor: PieChartConstants.legendTextColor,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    return style
                }()
            ]
            
            let textSize = percentageText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: center.x - textSize.width / 2,
                y: currentY,
                width: textSize.width,
                height: lineHeight
            )
            
            // Проверка, что текст точно не выходит за рамки
            if textRect.maxY <= center.y + radius - 10 && textRect.minY >= center.y - radius + 10 {
                percentageText.draw(in: textRect, withAttributes: attributes)
            }
            
            currentY += lineHeight + legendSpacing
        }
    }
    
    // MARK: - Public Methods
    public func updateEntities(_ newEntities: [PieChartEntity]) {
        entities = newEntities
    }
}

// MARK: - Convenience Methods
extension PieChartView {
    public static func create(with entities: [PieChartEntity]) -> PieChartView {
        let view = PieChartView(entities: entities)
        return view
    }
} 
