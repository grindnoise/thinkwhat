//
//  WikiIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class WikiIcon: UIView {
    override func draw(_ rect: CGRect) {
        WikiStyleKit.drawCanvas1(frame: rect, resizing: .aspectFit)
    }
}

public class WikiStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 114, height: 114), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 114, height: 114), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 114, y: resizedFrame.height / 114)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 113.85, y: 22.21))
        bezierPath.addCurve(to: CGPoint(x: 113.47, y: 23.33), controlPoint1: CGPoint(x: 113.85, y: 22.62), controlPoint2: CGPoint(x: 113.72, y: 22.99))
        bezierPath.addCurve(to: CGPoint(x: 112.63, y: 23.83), controlPoint1: CGPoint(x: 113.21, y: 23.66), controlPoint2: CGPoint(x: 112.94, y: 23.83))
        bezierPath.addCurve(to: CGPoint(x: 106.51, y: 26.24), controlPoint1: CGPoint(x: 110.14, y: 24.07), controlPoint2: CGPoint(x: 108.09, y: 24.87))
        bezierPath.addCurve(to: CGPoint(x: 101.6, y: 34.05), controlPoint1: CGPoint(x: 104.92, y: 27.6), controlPoint2: CGPoint(x: 103.29, y: 30.21))
        bezierPath.addLine(to: CGPoint(x: 75.8, y: 92.19))
        bezierPath.addCurve(to: CGPoint(x: 74.38, y: 93), controlPoint1: CGPoint(x: 75.63, y: 92.73), controlPoint2: CGPoint(x: 75.16, y: 93))
        bezierPath.addCurve(to: CGPoint(x: 72.96, y: 92.19), controlPoint1: CGPoint(x: 73.77, y: 93), controlPoint2: CGPoint(x: 73.3, y: 92.73))
        bezierPath.addLine(to: CGPoint(x: 58.49, y: 61.93))
        bezierPath.addLine(to: CGPoint(x: 41.85, y: 92.19))
        bezierPath.addCurve(to: CGPoint(x: 40.43, y: 93), controlPoint1: CGPoint(x: 41.51, y: 92.73), controlPoint2: CGPoint(x: 41.04, y: 93))
        bezierPath.addCurve(to: CGPoint(x: 38.96, y: 92.19), controlPoint1: CGPoint(x: 39.69, y: 93), controlPoint2: CGPoint(x: 39.2, y: 92.73))
        bezierPath.addLine(to: CGPoint(x: 13.61, y: 34.05))
        bezierPath.addCurve(to: CGPoint(x: 8.6, y: 26.49), controlPoint1: CGPoint(x: 12.03, y: 30.44), controlPoint2: CGPoint(x: 10.36, y: 27.92))
        bezierPath.addCurve(to: CGPoint(x: 1.27, y: 23.83), controlPoint1: CGPoint(x: 6.85, y: 25.06), controlPoint2: CGPoint(x: 4.4, y: 24.17))
        bezierPath.addCurve(to: CGPoint(x: 0.51, y: 23.4), controlPoint1: CGPoint(x: 1, y: 23.83), controlPoint2: CGPoint(x: 0.74, y: 23.69))
        bezierPath.addCurve(to: CGPoint(x: 0.15, y: 22.42), controlPoint1: CGPoint(x: 0.27, y: 23.12), controlPoint2: CGPoint(x: 0.15, y: 22.79))
        bezierPath.addCurve(to: CGPoint(x: 0.96, y: 21), controlPoint1: CGPoint(x: 0.15, y: 21.47), controlPoint2: CGPoint(x: 0.42, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 8.05, y: 21.3), controlPoint1: CGPoint(x: 3.22, y: 21), controlPoint2: CGPoint(x: 5.58, y: 21.1))
        bezierPath.addCurve(to: CGPoint(x: 14.52, y: 21.61), controlPoint1: CGPoint(x: 10.34, y: 21.51), controlPoint2: CGPoint(x: 12.5, y: 21.61))
        bezierPath.addCurve(to: CGPoint(x: 21.81, y: 21.3), controlPoint1: CGPoint(x: 16.58, y: 21.61), controlPoint2: CGPoint(x: 19.01, y: 21.51))
        bezierPath.addCurve(to: CGPoint(x: 29.6, y: 21), controlPoint1: CGPoint(x: 24.74, y: 21.1), controlPoint2: CGPoint(x: 27.34, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 30.41, y: 22.42), controlPoint1: CGPoint(x: 30.14, y: 21), controlPoint2: CGPoint(x: 30.41, y: 21.47))
        bezierPath.addCurve(to: CGPoint(x: 29.91, y: 23.83), controlPoint1: CGPoint(x: 30.41, y: 23.36), controlPoint2: CGPoint(x: 30.24, y: 23.83))
        bezierPath.addCurve(to: CGPoint(x: 24.57, y: 25.55), controlPoint1: CGPoint(x: 27.65, y: 24), controlPoint2: CGPoint(x: 25.87, y: 24.58))
        bezierPath.addCurve(to: CGPoint(x: 22.62, y: 29.4), controlPoint1: CGPoint(x: 23.27, y: 26.53), controlPoint2: CGPoint(x: 22.62, y: 27.81))
        bezierPath.addCurve(to: CGPoint(x: 23.43, y: 32.43), controlPoint1: CGPoint(x: 22.62, y: 30.21), controlPoint2: CGPoint(x: 22.89, y: 31.22))
        bezierPath.addLine(to: CGPoint(x: 44.38, y: 79.74))
        bezierPath.addLine(to: CGPoint(x: 56.27, y: 57.28))
        bezierPath.addLine(to: CGPoint(x: 45.19, y: 34.05))
        bezierPath.addCurve(to: CGPoint(x: 40.28, y: 26.03), controlPoint1: CGPoint(x: 43.2, y: 29.91), controlPoint2: CGPoint(x: 41.56, y: 27.23))
        bezierPath.addCurve(to: CGPoint(x: 34.46, y: 23.83), controlPoint1: CGPoint(x: 39, y: 24.84), controlPoint2: CGPoint(x: 37.06, y: 24.1))
        bezierPath.addCurve(to: CGPoint(x: 33.78, y: 23.4), controlPoint1: CGPoint(x: 34.22, y: 23.83), controlPoint2: CGPoint(x: 34, y: 23.69))
        bezierPath.addCurve(to: CGPoint(x: 33.45, y: 22.42), controlPoint1: CGPoint(x: 33.56, y: 23.12), controlPoint2: CGPoint(x: 33.45, y: 22.79))
        bezierPath.addCurve(to: CGPoint(x: 34.16, y: 21), controlPoint1: CGPoint(x: 33.45, y: 21.47), controlPoint2: CGPoint(x: 33.68, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 40.38, y: 21.3), controlPoint1: CGPoint(x: 36.42, y: 21), controlPoint2: CGPoint(x: 38.49, y: 21.1))
        bezierPath.addCurve(to: CGPoint(x: 46.2, y: 21.61), controlPoint1: CGPoint(x: 42.2, y: 21.51), controlPoint2: CGPoint(x: 44.14, y: 21.61))
        bezierPath.addCurve(to: CGPoint(x: 52.62, y: 21.3), controlPoint1: CGPoint(x: 48.22, y: 21.61), controlPoint2: CGPoint(x: 50.36, y: 21.51))
        bezierPath.addCurve(to: CGPoint(x: 59.5, y: 21), controlPoint1: CGPoint(x: 54.95, y: 21.1), controlPoint2: CGPoint(x: 57.24, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 60.31, y: 22.42), controlPoint1: CGPoint(x: 60.04, y: 21), controlPoint2: CGPoint(x: 60.31, y: 21.47))
        bezierPath.addCurve(to: CGPoint(x: 59.81, y: 23.83), controlPoint1: CGPoint(x: 60.31, y: 23.36), controlPoint2: CGPoint(x: 60.15, y: 23.83))
        bezierPath.addCurve(to: CGPoint(x: 53.03, y: 27.68), controlPoint1: CGPoint(x: 55.29, y: 24.14), controlPoint2: CGPoint(x: 53.03, y: 25.42))
        bezierPath.addCurve(to: CGPoint(x: 54.6, y: 32.38), controlPoint1: CGPoint(x: 53.03, y: 28.69), controlPoint2: CGPoint(x: 53.55, y: 30.26))
        bezierPath.addLine(to: CGPoint(x: 61.93, y: 47.26))
        bezierPath.addLine(to: CGPoint(x: 69.22, y: 33.65))
        bezierPath.addCurve(to: CGPoint(x: 70.74, y: 28.79), controlPoint1: CGPoint(x: 70.23, y: 31.73), controlPoint2: CGPoint(x: 70.74, y: 30.11))
        bezierPath.addCurve(to: CGPoint(x: 63.96, y: 23.83), controlPoint1: CGPoint(x: 70.74, y: 25.69), controlPoint2: CGPoint(x: 68.48, y: 24.04))
        bezierPath.addCurve(to: CGPoint(x: 63.35, y: 22.42), controlPoint1: CGPoint(x: 63.55, y: 23.83), controlPoint2: CGPoint(x: 63.35, y: 23.36))
        bezierPath.addCurve(to: CGPoint(x: 63.65, y: 21.46), controlPoint1: CGPoint(x: 63.35, y: 22.08), controlPoint2: CGPoint(x: 63.45, y: 21.76))
        bezierPath.addCurve(to: CGPoint(x: 64.26, y: 21), controlPoint1: CGPoint(x: 63.86, y: 21.15), controlPoint2: CGPoint(x: 64.06, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 70.23, y: 21.3), controlPoint1: CGPoint(x: 65.88, y: 21), controlPoint2: CGPoint(x: 67.87, y: 21.1))
        bezierPath.addCurve(to: CGPoint(x: 75.8, y: 21.61), controlPoint1: CGPoint(x: 72.49, y: 21.51), controlPoint2: CGPoint(x: 74.35, y: 21.61))
        bezierPath.addCurve(to: CGPoint(x: 80.4, y: 21.35), controlPoint1: CGPoint(x: 76.84, y: 21.61), controlPoint2: CGPoint(x: 78.38, y: 21.52))
        bezierPath.addCurve(to: CGPoint(x: 86.83, y: 21), controlPoint1: CGPoint(x: 82.96, y: 21.12), controlPoint2: CGPoint(x: 85.11, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 87.43, y: 22.21), controlPoint1: CGPoint(x: 87.23, y: 21), controlPoint2: CGPoint(x: 87.43, y: 21.4))
        bezierPath.addCurve(to: CGPoint(x: 86.32, y: 23.83), controlPoint1: CGPoint(x: 87.43, y: 23.29), controlPoint2: CGPoint(x: 87.06, y: 23.83))
        bezierPath.addCurve(to: CGPoint(x: 79.97, y: 26.01), controlPoint1: CGPoint(x: 83.69, y: 24.1), controlPoint2: CGPoint(x: 81.57, y: 24.83))
        bezierPath.addCurve(to: CGPoint(x: 73.98, y: 34.05), controlPoint1: CGPoint(x: 78.37, y: 27.19), controlPoint2: CGPoint(x: 76.37, y: 29.87))
        bezierPath.addLine(to: CGPoint(x: 64.26, y: 52.02))
        bezierPath.addLine(to: CGPoint(x: 77.42, y: 78.83))
        bezierPath.addLine(to: CGPoint(x: 96.85, y: 33.65))
        bezierPath.addCurve(to: CGPoint(x: 97.86, y: 29.1), controlPoint1: CGPoint(x: 97.52, y: 32), controlPoint2: CGPoint(x: 97.86, y: 30.48))
        bezierPath.addCurve(to: CGPoint(x: 91.08, y: 23.83), controlPoint1: CGPoint(x: 97.86, y: 25.79), controlPoint2: CGPoint(x: 95.6, y: 24.04))
        bezierPath.addCurve(to: CGPoint(x: 90.47, y: 22.42), controlPoint1: CGPoint(x: 90.67, y: 23.83), controlPoint2: CGPoint(x: 90.47, y: 23.36))
        bezierPath.addCurve(to: CGPoint(x: 91.38, y: 21), controlPoint1: CGPoint(x: 90.47, y: 21.47), controlPoint2: CGPoint(x: 90.77, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 97.25, y: 21.3), controlPoint1: CGPoint(x: 93.03, y: 21), controlPoint2: CGPoint(x: 94.99, y: 21.1))
        bezierPath.addCurve(to: CGPoint(x: 102.51, y: 21.61), controlPoint1: CGPoint(x: 99.34, y: 21.51), controlPoint2: CGPoint(x: 101.1, y: 21.61))
        bezierPath.addCurve(to: CGPoint(x: 107.67, y: 21.3), controlPoint1: CGPoint(x: 104, y: 21.61), controlPoint2: CGPoint(x: 105.72, y: 21.51))
        bezierPath.addCurve(to: CGPoint(x: 113.14, y: 21), controlPoint1: CGPoint(x: 109.7, y: 21.1), controlPoint2: CGPoint(x: 111.52, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 113.85, y: 22.21), controlPoint1: CGPoint(x: 113.61, y: 21), controlPoint2: CGPoint(x: 113.85, y: 21.4))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        fillColor.setFill()
        bezierPath.fill()
        
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

