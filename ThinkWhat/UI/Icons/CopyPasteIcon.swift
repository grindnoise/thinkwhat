//
//  CopyPasteSign.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
final class CopyPasteIcon: UIView {
    override func draw(_ rect: CGRect) {
        CopyPasteStyleKit.drawPaste(frame: rect, resizing: .aspectFit)
    }
}

public class CopyPasteStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawPaste(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 216, height: 216), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 216, height: 216), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 216, y: resizedFrame.height / 216)
        
        
        //// Color Declarations
        let color2 = UIColor(red: 0.800, green: 0.800, blue: 0.800, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 184.6, y: 31.4))
        bezierPath.addLine(to: CGPoint(x: 60.06, y: 31.4))
        bezierPath.addCurve(to: CGPoint(x: 60.06, y: 46.65), controlPoint1: CGPoint(x: 60.06, y: 31.4), controlPoint2: CGPoint(x: 60.06, y: 37.35))
        bezierPath.addLine(to: CGPoint(x: 153.81, y: 46.65))
        bezierPath.addCurve(to: CGPoint(x: 162.54, y: 47.32), controlPoint1: CGPoint(x: 158.28, y: 46.65), controlPoint2: CGPoint(x: 160.52, y: 46.65))
        bezierPath.addLine(to: CGPoint(x: 162.93, y: 47.41))
        bezierPath.addCurve(to: CGPoint(x: 168.59, y: 53.07), controlPoint1: CGPoint(x: 165.56, y: 48.37), controlPoint2: CGPoint(x: 167.63, y: 50.44))
        bezierPath.addCurve(to: CGPoint(x: 169.35, y: 62.19), controlPoint1: CGPoint(x: 169.35, y: 55.48), controlPoint2: CGPoint(x: 169.35, y: 57.72))
        bezierPath.addCurve(to: CGPoint(x: 169.35, y: 155.94), controlPoint1: CGPoint(x: 169.35, y: 62.19), controlPoint2: CGPoint(x: 169.35, y: 119.82))
        bezierPath.addLine(to: CGPoint(x: 184.6, y: 155.94))
        bezierPath.addLine(to: CGPoint(x: 184.6, y: 31.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 154.94, y: 61.06))
        bezierPath.addLine(to: CGPoint(x: 30.4, y: 61.06))
        bezierPath.addLine(to: CGPoint(x: 30.4, y: 185.6))
        bezierPath.addLine(to: CGPoint(x: 154.94, y: 185.6))
        bezierPath.addLine(to: CGPoint(x: 154.94, y: 61.06))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 192.19, y: 17.67))
        bezierPath.addLine(to: CGPoint(x: 192.58, y: 17.76))
        bezierPath.addCurve(to: CGPoint(x: 198.24, y: 23.42), controlPoint1: CGPoint(x: 195.21, y: 18.72), controlPoint2: CGPoint(x: 197.28, y: 20.79))
        bezierPath.addCurve(to: CGPoint(x: 199, y: 32.54), controlPoint1: CGPoint(x: 199, y: 25.83), controlPoint2: CGPoint(x: 199, y: 28.07))
        bezierPath.addLine(to: CGPoint(x: 199, y: 154.81))
        bezierPath.addCurve(to: CGPoint(x: 198.33, y: 163.54), controlPoint1: CGPoint(x: 199, y: 159.28), controlPoint2: CGPoint(x: 199, y: 161.52))
        bezierPath.addLine(to: CGPoint(x: 198.24, y: 163.93))
        bezierPath.addCurve(to: CGPoint(x: 192.58, y: 169.59), controlPoint1: CGPoint(x: 197.28, y: 166.56), controlPoint2: CGPoint(x: 195.21, y: 168.63))
        bezierPath.addCurve(to: CGPoint(x: 183.46, y: 170.35), controlPoint1: CGPoint(x: 190.17, y: 170.35), controlPoint2: CGPoint(x: 187.93, y: 170.35))
        bezierPath.addLine(to: CGPoint(x: 169.35, y: 170.35))
        bezierPath.addCurve(to: CGPoint(x: 169.35, y: 184.46), controlPoint1: CGPoint(x: 169.35, y: 178.98), controlPoint2: CGPoint(x: 169.35, y: 184.46))
        bezierPath.addCurve(to: CGPoint(x: 168.68, y: 193.19), controlPoint1: CGPoint(x: 169.35, y: 188.93), controlPoint2: CGPoint(x: 169.35, y: 191.17))
        bezierPath.addLine(to: CGPoint(x: 168.59, y: 193.58))
        bezierPath.addCurve(to: CGPoint(x: 162.93, y: 199.24), controlPoint1: CGPoint(x: 167.63, y: 196.21), controlPoint2: CGPoint(x: 165.56, y: 198.28))
        bezierPath.addCurve(to: CGPoint(x: 153.81, y: 200), controlPoint1: CGPoint(x: 160.52, y: 200), controlPoint2: CGPoint(x: 158.28, y: 200))
        bezierPath.addLine(to: CGPoint(x: 31.54, y: 200))
        bezierPath.addCurve(to: CGPoint(x: 22.81, y: 199.33), controlPoint1: CGPoint(x: 27.07, y: 200), controlPoint2: CGPoint(x: 24.83, y: 200))
        bezierPath.addLine(to: CGPoint(x: 22.42, y: 199.24))
        bezierPath.addCurve(to: CGPoint(x: 16.76, y: 193.58), controlPoint1: CGPoint(x: 19.79, y: 198.28), controlPoint2: CGPoint(x: 17.72, y: 196.21))
        bezierPath.addCurve(to: CGPoint(x: 16, y: 184.46), controlPoint1: CGPoint(x: 16, y: 191.17), controlPoint2: CGPoint(x: 16, y: 188.93))
        bezierPath.addLine(to: CGPoint(x: 16, y: 62.19))
        bezierPath.addCurve(to: CGPoint(x: 16.67, y: 53.46), controlPoint1: CGPoint(x: 16, y: 57.72), controlPoint2: CGPoint(x: 16, y: 55.48))
        bezierPath.addLine(to: CGPoint(x: 16.76, y: 53.07))
        bezierPath.addCurve(to: CGPoint(x: 22.42, y: 47.41), controlPoint1: CGPoint(x: 17.72, y: 50.44), controlPoint2: CGPoint(x: 19.79, y: 48.37))
        bezierPath.addCurve(to: CGPoint(x: 31.54, y: 46.65), controlPoint1: CGPoint(x: 24.83, y: 46.65), controlPoint2: CGPoint(x: 27.07, y: 46.65))
        bezierPath.addLine(to: CGPoint(x: 45.65, y: 46.65))
        bezierPath.addCurve(to: CGPoint(x: 45.65, y: 32.54), controlPoint1: CGPoint(x: 45.65, y: 38.02), controlPoint2: CGPoint(x: 45.65, y: 32.54))
        bezierPath.addCurve(to: CGPoint(x: 46.32, y: 23.81), controlPoint1: CGPoint(x: 45.65, y: 28.07), controlPoint2: CGPoint(x: 45.65, y: 25.83))
        bezierPath.addLine(to: CGPoint(x: 46.41, y: 23.42))
        bezierPath.addCurve(to: CGPoint(x: 48.03, y: 20.61), controlPoint1: CGPoint(x: 46.79, y: 22.39), controlPoint2: CGPoint(x: 47.34, y: 21.44))
        bezierPath.addCurve(to: CGPoint(x: 52.07, y: 17.76), controlPoint1: CGPoint(x: 49.09, y: 19.33), controlPoint2: CGPoint(x: 50.48, y: 18.34))
        bezierPath.addCurve(to: CGPoint(x: 61.19, y: 17), controlPoint1: CGPoint(x: 54.48, y: 17), controlPoint2: CGPoint(x: 56.72, y: 17))
        bezierPath.addLine(to: CGPoint(x: 183.46, y: 17))
        bezierPath.addCurve(to: CGPoint(x: 192.19, y: 17.67), controlPoint1: CGPoint(x: 187.93, y: 17), controlPoint2: CGPoint(x: 190.17, y: 17))
        bezierPath.close()
        UIColor.gray.setFill()
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

