//
//  BackRoundedButton.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class BackRoundedButton: UIView {
    var color: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        BackRoundedButtonStyleKit.drawBack(frame: rect, resizing: .aspectFit, color: color)
    }
}

public class BackRoundedButtonStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawBack(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 600, height: 600), resizing: ResizingBehavior = .aspectFit, color: UIColor?) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 600, height: 600), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 600, y: resizedFrame.height / 600)
        
        
        //// Color Declarations
        let fillColor = color ?? K_COLOR_RED//UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 178.43, y: 9.12))
        bezierPath.addCurve(to: CGPoint(x: 164.63, y: 18.65), controlPoint1: CGPoint(x: 173.41, y: 10.47), controlPoint2: CGPoint(x: 170.63, y: 12.42))
        bezierPath.addCurve(to: CGPoint(x: 4.28, y: 197.6), controlPoint1: CGPoint(x: 152.41, y: 31.4), controlPoint2: CGPoint(x: 6.23, y: 194.52))
        bezierPath.addCurve(to: CGPoint(x: 4.28, y: 224.82), controlPoint1: CGPoint(x: -1.34, y: 206.6), controlPoint2: CGPoint(x: -1.34, y: 215.9))
        bezierPath.addCurve(to: CGPoint(x: 156.08, y: 394.62), controlPoint1: CGPoint(x: 6.08, y: 227.67), controlPoint2: CGPoint(x: 55.36, y: 282.72))
        bezierPath.addCurve(to: CGPoint(x: 177.98, y: 413.15), controlPoint1: CGPoint(x: 168.76, y: 408.65), controlPoint2: CGPoint(x: 171.61, y: 411.12))
        bezierPath.addCurve(to: CGPoint(x: 208.06, y: 378.42), controlPoint1: CGPoint(x: 198.46, y: 419.6), controlPoint2: CGPoint(x: 217.36, y: 397.77))
        bezierPath.addCurve(to: CGPoint(x: 196.81, y: 363.8), controlPoint1: CGPoint(x: 206.41, y: 375.12), controlPoint2: CGPoint(x: 202.96, y: 370.55))
        bezierPath.addCurve(to: CGPoint(x: 88.58, y: 243.12), controlPoint1: CGPoint(x: 165.68, y: 329.45), controlPoint2: CGPoint(x: 88.58, y: 243.42))
        bezierPath.addCurve(to: CGPoint(x: 418.96, y: 243.57), controlPoint1: CGPoint(x: 88.58, y: 242.38), controlPoint2: CGPoint(x: 409.81, y: 242.75))
        bezierPath.addCurve(to: CGPoint(x: 531.83, y: 339.05), controlPoint1: CGPoint(x: 473.71, y: 248.3), controlPoint2: CGPoint(x: 518.48, y: 286.17))
        bezierPath.addCurve(to: CGPoint(x: 535.36, y: 391.02), controlPoint1: CGPoint(x: 535.28, y: 352.7), controlPoint2: CGPoint(x: 535.81, y: 359.75))
        bezierPath.addCurve(to: CGPoint(x: 533.11, y: 427.62), controlPoint1: CGPoint(x: 535.06, y: 417.88), controlPoint2: CGPoint(x: 534.91, y: 419.83))
        bezierPath.addCurve(to: CGPoint(x: 523.21, y: 456.35), controlPoint1: CGPoint(x: 530.63, y: 438.57), controlPoint2: CGPoint(x: 528.01, y: 446.15))
        bezierPath.addCurve(to: CGPoint(x: 433.21, y: 526.4), controlPoint1: CGPoint(x: 506.03, y: 492.42), controlPoint2: CGPoint(x: 473.78, y: 517.55))
        bezierPath.addLine(to: CGPoint(x: 425.71, y: 528.05))
        bezierPath.addLine(to: CGPoint(x: 226.81, y: 528.27))
        bezierPath.addLine(to: CGPoint(x: 27.83, y: 528.5))
        bezierPath.addLine(to: CGPoint(x: 27.83, y: 560.38))
        bezierPath.addLine(to: CGPoint(x: 27.83, y: 592.25))
        bezierPath.addLine(to: CGPoint(x: 227.18, y: 592.02))
        bezierPath.addLine(to: CGPoint(x: 426.46, y: 591.88))
        bezierPath.addLine(to: CGPoint(x: 436.21, y: 590.23))
        bezierPath.addCurve(to: CGPoint(x: 543.68, y: 536), controlPoint1: CGPoint(x: 479.33, y: 583.02), controlPoint2: CGPoint(x: 514.28, y: 565.4))
        bezierPath.addCurve(to: CGPoint(x: 598.66, y: 417.42), controlPoint1: CGPoint(x: 575.63, y: 504.05), controlPoint2: CGPoint(x: 594.38, y: 463.47))
        bezierPath.addCurve(to: CGPoint(x: 597.61, y: 343.62), controlPoint1: CGPoint(x: 599.86, y: 404.07), controlPoint2: CGPoint(x: 599.18, y: 353.67))
        bezierPath.addCurve(to: CGPoint(x: 579.91, y: 286.55), controlPoint1: CGPoint(x: 594.31, y: 322.7), controlPoint2: CGPoint(x: 588.68, y: 304.47))
        bezierPath.addCurve(to: CGPoint(x: 431.26, y: 180.88), controlPoint1: CGPoint(x: 551.11, y: 227.97), controlPoint2: CGPoint(x: 496.21, y: 188.97))
        bezierPath.addCurve(to: CGPoint(x: 255.31, y: 179.75), controlPoint1: CGPoint(x: 423.23, y: 179.9), controlPoint2: CGPoint(x: 400.21, y: 179.75))
        bezierPath.addCurve(to: CGPoint(x: 88.58, y: 179.38), controlPoint1: CGPoint(x: 163.58, y: 179.75), controlPoint2: CGPoint(x: 88.58, y: 179.6))
        bezierPath.addCurve(to: CGPoint(x: 146.78, y: 114.27), controlPoint1: CGPoint(x: 88.58, y: 179.15), controlPoint2: CGPoint(x: 114.76, y: 149.82))
        bezierPath.addCurve(to: CGPoint(x: 206.86, y: 46.77), controlPoint1: CGPoint(x: 178.81, y: 78.72), controlPoint2: CGPoint(x: 205.81, y: 48.35))
        bezierPath.addCurve(to: CGPoint(x: 193.06, y: 9.5), controlPoint1: CGPoint(x: 215.41, y: 33.35), controlPoint2: CGPoint(x: 208.36, y: 14.22))
        bezierPath.addCurve(to: CGPoint(x: 178.43, y: 9.12), controlPoint1: CGPoint(x: 187.51, y: 7.77), controlPoint2: CGPoint(x: 183.53, y: 7.7))
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
