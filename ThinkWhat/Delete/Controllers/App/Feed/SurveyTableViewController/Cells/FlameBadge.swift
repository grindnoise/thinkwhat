//
//  FlameBadge.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 09.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class FlameBadge: UIView {
    override func draw(_ rect: CGRect) {
        FlameStyleKit.drawFlame(frame: rect, resizing: .aspectFit)
    }
}

public class FlameStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawFlame(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 240), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 240, height: 240), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 240, y: resizedFrame.height / 240)
        
        
        //// Color Declarations
        let fillColor = Colors.System.Red.rawValue//Colors.UpperButtons.MaximumRed.withAlphaComponent(0.65)//UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 113.31, y: 3.75))
        bezierPath.addCurve(to: CGPoint(x: 80.87, y: 38.68), controlPoint1: CGPoint(x: 96.27, y: 12.3), controlPoint2: CGPoint(x: 86.06, y: 23.23))
        bezierPath.addCurve(to: CGPoint(x: 77.91, y: 57.18), controlPoint1: CGPoint(x: 79.22, y: 43.62), controlPoint2: CGPoint(x: 78.56, y: 47.89))
        bezierPath.addCurve(to: CGPoint(x: 73.38, y: 86.85), controlPoint1: CGPoint(x: 76.92, y: 72.96), controlPoint2: CGPoint(x: 75.93, y: 79.29))
        bezierPath.addCurve(to: CGPoint(x: 61.6, y: 106.99), controlPoint1: CGPoint(x: 71.07, y: 93.76), controlPoint2: CGPoint(x: 65.47, y: 103.29))
        bezierPath.addLine(to: CGPoint(x: 59.05, y: 109.46))
        bezierPath.addLine(to: CGPoint(x: 59.05, y: 105.76))
        bezierPath.addCurve(to: CGPoint(x: 48.26, y: 80.03), controlPoint1: CGPoint(x: 59.05, y: 97.37), controlPoint2: CGPoint(x: 55.02, y: 87.67))
        bezierPath.addCurve(to: CGPoint(x: 33.85, y: 69.01), controlPoint1: CGPoint(x: 44.8, y: 76.17), controlPoint2: CGPoint(x: 34.59, y: 68.36))
        bezierPath.addCurve(to: CGPoint(x: 34.43, y: 71.81), controlPoint1: CGPoint(x: 33.69, y: 69.26), controlPoint2: CGPoint(x: 33.94, y: 70.49))
        bezierPath.addCurve(to: CGPoint(x: 35.25, y: 82.17), controlPoint1: CGPoint(x: 34.92, y: 73.12), controlPoint2: CGPoint(x: 35.34, y: 77.81))
        bezierPath.addCurve(to: CGPoint(x: 25.46, y: 118.58), controlPoint1: CGPoint(x: 35.17, y: 90.71), controlPoint2: CGPoint(x: 34.92, y: 91.95))
        bezierPath.addCurve(to: CGPoint(x: 18.29, y: 157.62), controlPoint1: CGPoint(x: 19.44, y: 135.59), controlPoint2: CGPoint(x: 18.29, y: 141.51))
        bezierPath.addCurve(to: CGPoint(x: 29.9, y: 202.5), controlPoint1: CGPoint(x: 18.29, y: 178.17), controlPoint2: CGPoint(x: 21.17, y: 189.27))
        bezierPath.addCurve(to: CGPoint(x: 87.79, y: 238.18), controlPoint1: CGPoint(x: 41.35, y: 219.85), controlPoint2: CGPoint(x: 62.01, y: 232.59))
        bezierPath.addCurve(to: CGPoint(x: 95.03, y: 239.49), controlPoint1: CGPoint(x: 91.66, y: 239.08), controlPoint2: CGPoint(x: 94.95, y: 239.65))
        bezierPath.addCurve(to: CGPoint(x: 90.34, y: 235.46), controlPoint1: CGPoint(x: 95.2, y: 239.41), controlPoint2: CGPoint(x: 93.06, y: 237.52))
        bezierPath.addCurve(to: CGPoint(x: 71.24, y: 205.21), controlPoint1: CGPoint(x: 81.03, y: 228.23), controlPoint2: CGPoint(x: 74.45, y: 217.79))
        bezierPath.addCurve(to: CGPoint(x: 72.22, y: 177.51), controlPoint1: CGPoint(x: 69.01, y: 196.09), controlPoint2: CGPoint(x: 69.42, y: 184.01))
        bezierPath.addLine(to: CGPoint(x: 74.12, y: 173.08))
        bezierPath.addLine(to: CGPoint(x: 76.75, y: 178.75))
        bezierPath.addCurve(to: CGPoint(x: 81.61, y: 186.97), controlPoint1: CGPoint(x: 78.15, y: 181.79), controlPoint2: CGPoint(x: 80.38, y: 185.49))
        bezierPath.addCurve(to: CGPoint(x: 89.93, y: 192.8), controlPoint1: CGPoint(x: 83.75, y: 189.51), controlPoint2: CGPoint(x: 89.27, y: 193.46))
        bezierPath.addCurve(to: CGPoint(x: 89.52, y: 186.8), controlPoint1: CGPoint(x: 90.09, y: 192.64), controlPoint2: CGPoint(x: 89.93, y: 189.93))
        bezierPath.addCurve(to: CGPoint(x: 89.93, y: 164.53), controlPoint1: CGPoint(x: 88.44, y: 178.42), controlPoint2: CGPoint(x: 88.53, y: 172.75))
        bezierPath.addCurve(to: CGPoint(x: 105.98, y: 133.05), controlPoint1: CGPoint(x: 92.15, y: 151.79), controlPoint2: CGPoint(x: 97.09, y: 142.09))
        bezierPath.addCurve(to: CGPoint(x: 121.13, y: 121.46), controlPoint1: CGPoint(x: 110.51, y: 128.36), controlPoint2: CGPoint(x: 119.57, y: 121.46))
        bezierPath.addCurve(to: CGPoint(x: 121.63, y: 128.77), controlPoint1: CGPoint(x: 121.38, y: 121.46), controlPoint2: CGPoint(x: 121.63, y: 124.74))
        bezierPath.addCurve(to: CGPoint(x: 127.23, y: 150.31), controlPoint1: CGPoint(x: 121.63, y: 137.16), controlPoint2: CGPoint(x: 123.52, y: 144.39))
        bezierPath.addCurve(to: CGPoint(x: 137.68, y: 162.55), controlPoint1: CGPoint(x: 128.63, y: 152.36), controlPoint2: CGPoint(x: 133.24, y: 157.87))
        bezierPath.addCurve(to: CGPoint(x: 154.89, y: 200.36), controlPoint1: CGPoint(x: 151.93, y: 177.6), controlPoint2: CGPoint(x: 154.89, y: 184.17))
        bezierPath.addCurve(to: CGPoint(x: 153, y: 215.16), controlPoint1: CGPoint(x: 154.81, y: 208.01), controlPoint2: CGPoint(x: 154.48, y: 210.89))
        bezierPath.addCurve(to: CGPoint(x: 140.24, y: 235.05), controlPoint1: CGPoint(x: 150.36, y: 222.64), controlPoint2: CGPoint(x: 146.16, y: 229.3))
        bezierPath.addLine(to: CGPoint(x: 135.21, y: 239.98))
        bezierPath.addLine(to: CGPoint(x: 138.1, y: 239.41))
        bezierPath.addCurve(to: CGPoint(x: 196.39, y: 209.57), controlPoint1: CGPoint(x: 160.99, y: 235.05), controlPoint2: CGPoint(x: 181.24, y: 224.69))
        bezierPath.addCurve(to: CGPoint(x: 213.68, y: 184.34), controlPoint1: CGPoint(x: 201.74, y: 204.23), controlPoint2: CGPoint(x: 211.05, y: 190.67))
        bezierPath.addCurve(to: CGPoint(x: 219.69, y: 158.77), controlPoint1: CGPoint(x: 216.24, y: 178.17), controlPoint2: CGPoint(x: 218.62, y: 167.9))
        bezierPath.addCurve(to: CGPoint(x: 194.17, y: 81.18), controlPoint1: CGPoint(x: 222.74, y: 132.06), controlPoint2: CGPoint(x: 212.61, y: 101.24))
        bezierPath.addLine(to: CGPoint(x: 190.05, y: 76.66))
        bezierPath.addLine(to: CGPoint(x: 190.63, y: 80.77))
        bezierPath.addCurve(to: CGPoint(x: 191.12, y: 96.8), controlPoint1: CGPoint(x: 190.96, y: 82.99), controlPoint2: CGPoint(x: 191.2, y: 90.22))
        bezierPath.addCurve(to: CGPoint(x: 188.82, y: 115.29), controlPoint1: CGPoint(x: 191.12, y: 107.57), controlPoint2: CGPoint(x: 190.88, y: 109.37))
        bezierPath.addCurve(to: CGPoint(x: 183.55, y: 126.39), controlPoint1: CGPoint(x: 187.58, y: 118.91), controlPoint2: CGPoint(x: 185.28, y: 123.92))
        bezierPath.addLine(to: CGPoint(x: 180.58, y: 130.91))
        bezierPath.addLine(to: CGPoint(x: 179.18, y: 122.44))
        bezierPath.addCurve(to: CGPoint(x: 149.71, y: 69.67), controlPoint1: CGPoint(x: 175.56, y: 100.66), controlPoint2: CGPoint(x: 170.95, y: 92.36))
        bezierPath.addCurve(to: CGPoint(x: 135.71, y: 54.14), controlPoint1: CGPoint(x: 144.44, y: 64), controlPoint2: CGPoint(x: 138.1, y: 57.01))
        bezierPath.addCurve(to: CGPoint(x: 119.9, y: 6.38), controlPoint1: CGPoint(x: 120.72, y: 35.97), controlPoint2: CGPoint(x: 115.62, y: 20.52))
        bezierPath.addCurve(to: CGPoint(x: 121.38, y: 0.13), controlPoint1: CGPoint(x: 120.89, y: 3.09), controlPoint2: CGPoint(x: 121.55, y: 0.3))
        bezierPath.addCurve(to: CGPoint(x: 113.31, y: 3.75), controlPoint1: CGPoint(x: 121.22, y: -0.03), controlPoint2: CGPoint(x: 117.59, y: 1.53))
        bezierPath.close()
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

