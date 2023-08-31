//
//  ScrollArrow.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ScrollArrow: UIView {
    override func draw(_ rect: CGRect) {
        ScrollArrowStyleKit.drawScrolArrow(frame: rect, resizing: .aspectFit)
    }
}

public class ScrollArrowStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawScrolArrow(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
      let fillColor = Colors.main.withAlphaComponent(0.5)//UIColor(red: 0.538, green: 0.538, blue: 0.538, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 150.63, y: 128.78))
        bezierPath.addLine(to: CGPoint(x: 99.71, y: 77.86))
        bezierPath.addLine(to: CGPoint(x: 48.79, y: 128.78))
        bezierPath.addCurve(to: CGPoint(x: 37.49, y: 128.78), controlPoint1: CGPoint(x: 45.68, y: 131.89), controlPoint2: CGPoint(x: 40.61, y: 131.9))
        bezierPath.addLine(to: CGPoint(x: 34.65, y: 125.94))
        bezierPath.addCurve(to: CGPoint(x: 34.65, y: 114.64), controlPoint1: CGPoint(x: 31.53, y: 122.82), controlPoint2: CGPoint(x: 31.53, y: 117.76))
        bezierPath.addLine(to: CGPoint(x: 94.06, y: 55.23))
        bezierPath.addCurve(to: CGPoint(x: 99.71, y: 52.89), controlPoint1: CGPoint(x: 95.62, y: 53.67), controlPoint2: CGPoint(x: 97.66, y: 52.89))
        bezierPath.addCurve(to: CGPoint(x: 105.36, y: 55.23), controlPoint1: CGPoint(x: 101.76, y: 52.89), controlPoint2: CGPoint(x: 103.8, y: 53.67))
        bezierPath.addLine(to: CGPoint(x: 164.77, y: 114.64))
        bezierPath.addCurve(to: CGPoint(x: 164.77, y: 125.94), controlPoint1: CGPoint(x: 167.88, y: 117.75), controlPoint2: CGPoint(x: 167.89, y: 122.82))
        bezierPath.addLine(to: CGPoint(x: 161.93, y: 128.78))
        bezierPath.addCurve(to: CGPoint(x: 150.63, y: 128.78), controlPoint1: CGPoint(x: 158.81, y: 131.9), controlPoint2: CGPoint(x: 153.75, y: 131.9))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 200, y: 100))
        bezierPath.addCurve(to: CGPoint(x: 100, y: 0), controlPoint1: CGPoint(x: 200, y: 44.77), controlPoint2: CGPoint(x: 155.23, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 100), controlPoint1: CGPoint(x: 44.77, y: 0), controlPoint2: CGPoint(x: 0, y: 44.77))
        bezierPath.addCurve(to: CGPoint(x: 39.79, y: 179.85), controlPoint1: CGPoint(x: 0, y: 132.62), controlPoint2: CGPoint(x: 15.62, y: 161.59))
        bezierPath.addCurve(to: CGPoint(x: 100, y: 200), controlPoint1: CGPoint(x: 56.54, y: 192.5), controlPoint2: CGPoint(x: 77.39, y: 200))
        bezierPath.addCurve(to: CGPoint(x: 200, y: 100), controlPoint1: CGPoint(x: 155.23, y: 200), controlPoint2: CGPoint(x: 200, y: 155.23))
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

