//
//  CompletedSign.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CompletionSign: UIView {
    override func draw(_ rect: CGRect) {
        CompletedSignStyleKit.drawCompletedSign(frame: rect, resizing: .aspectFit)
    }
}

public class CompletedSignStyleKit : NSObject {
    
    //// Drawing Methods
    
    @ objc public dynamic class func drawCompletedSign(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 400, height: 400), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 400, height: 400), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 400, y: resizedFrame.height / 400)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.444, green: 0.737, blue: 0.352, alpha: 1.000)
        
        //// Combined-Shape Drawing
        let combinedShapePath = UIBezierPath()
        combinedShapePath.move(to: CGPoint(x: 200, y: 400))
        combinedShapePath.addCurve(to: CGPoint(x: 400, y: 200), controlPoint1: CGPoint(x: 310.46, y: 400), controlPoint2: CGPoint(x: 400, y: 310.46))
        combinedShapePath.addCurve(to: CGPoint(x: 200, y: 0), controlPoint1: CGPoint(x: 400, y: 89.54), controlPoint2: CGPoint(x: 310.46, y: 0))
        combinedShapePath.addCurve(to: CGPoint(x: 0, y: 200), controlPoint1: CGPoint(x: 89.54, y: 0), controlPoint2: CGPoint(x: 0, y: 89.54))
        combinedShapePath.addCurve(to: CGPoint(x: 200, y: 400), controlPoint1: CGPoint(x: 0, y: 310.46), controlPoint2: CGPoint(x: 89.54, y: 400))
        combinedShapePath.close()
        combinedShapePath.move(to: CGPoint(x: 174.67, y: 265.92))
        combinedShapePath.addLine(to: CGPoint(x: 103.67, y: 194.92))
        combinedShapePath.addLine(to: CGPoint(x: 80, y: 218.58))
        combinedShapePath.addLine(to: CGPoint(x: 162.83, y: 301.42))
        combinedShapePath.addLine(to: CGPoint(x: 174.67, y: 313.25))
        combinedShapePath.addLine(to: CGPoint(x: 346.25, y: 141.67))
        combinedShapePath.addLine(to: CGPoint(x: 322.59, y: 118))
        combinedShapePath.addLine(to: CGPoint(x: 174.67, y: 265.92))
        combinedShapePath.close()
        combinedShapePath.usesEvenOddFillRule = true
        fillColor.setFill()
        combinedShapePath.fill()
        
        context.restoreGState()
        
    }
    
    
    
    
    @objc public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}

