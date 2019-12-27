//
//  YoutubeIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class YoutubeIcon: UIView {
    override func draw(_ rect: CGRect) {
        YoutubeStyleKit.drawCanvas1(frame: rect, resizing: .aspectFit)
    }
}

public class YoutubeStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.986, green: 0.000, blue: 0.027, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 80.19, y: 71.75))
        bezierPath.addLine(to: CGPoint(x: 80.13, y: 131.44))
        bezierPath.addLine(to: CGPoint(x: 132.07, y: 101.55))
        bezierPath.addLine(to: CGPoint(x: 80.19, y: 71.75))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 100.01, y: 31))
        bezierPath.addCurve(to: CGPoint(x: 178.25, y: 35.25), controlPoint1: CGPoint(x: 100, y: 31), controlPoint2: CGPoint(x: 162.6, y: 31))
        bezierPath.addCurve(to: CGPoint(x: 195.88, y: 52.75), controlPoint1: CGPoint(x: 186.82, y: 37.54), controlPoint2: CGPoint(x: 193.57, y: 44.25))
        bezierPath.addCurve(to: CGPoint(x: 200, y: 100.66), controlPoint1: CGPoint(x: 200.16, y: 68.28), controlPoint2: CGPoint(x: 200, y: 100.66))
        bezierPath.addCurve(to: CGPoint(x: 195.88, y: 148.41), controlPoint1: CGPoint(x: 200, y: 100.66), controlPoint2: CGPoint(x: 200, y: 132.88))
        bezierPath.addCurve(to: CGPoint(x: 178.25, y: 165.91), controlPoint1: CGPoint(x: 193.57, y: 156.92), controlPoint2: CGPoint(x: 186.82, y: 163.62))
        bezierPath.addCurve(to: CGPoint(x: 100, y: 170), controlPoint1: CGPoint(x: 162.6, y: 170), controlPoint2: CGPoint(x: 100, y: 170))
        bezierPath.addCurve(to: CGPoint(x: 21.75, y: 165.75), controlPoint1: CGPoint(x: 100, y: 170), controlPoint2: CGPoint(x: 37.56, y: 170))
        bezierPath.addCurve(to: CGPoint(x: 4.12, y: 148.25), controlPoint1: CGPoint(x: 13.18, y: 163.46), controlPoint2: CGPoint(x: 6.43, y: 156.75))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 100.5), controlPoint1: CGPoint(x: -0, y: 132.88), controlPoint2: CGPoint(x: 0, y: 100.5))
        bezierPath.addCurve(to: CGPoint(x: 4.12, y: 52.75), controlPoint1: CGPoint(x: 0, y: 100.5), controlPoint2: CGPoint(x: -0, y: 68.28))
        bezierPath.addCurve(to: CGPoint(x: 21.75, y: 35.09), controlPoint1: CGPoint(x: 6.43, y: 44.25), controlPoint2: CGPoint(x: 13.34, y: 37.38))
        bezierPath.addCurve(to: CGPoint(x: 27.78, y: 33.98), controlPoint1: CGPoint(x: 23.32, y: 34.68), controlPoint2: CGPoint(x: 25.37, y: 34.31))
        bezierPath.addCurve(to: CGPoint(x: 100, y: 31), controlPoint1: CGPoint(x: 49.35, y: 31), controlPoint2: CGPoint(x: 100, y: 31))
        bezierPath.addLine(to: CGPoint(x: 100.01, y: 31))
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

