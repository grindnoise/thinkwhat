//
//  HideKeyboardIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.01.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class HideKeyboardIcon: UIView {
    override func draw(_ rect: CGRect) {
        HideKBStyleKit.drawCanvas1(frame: rect, resizing: .aspectFit)
    }
}

public class HideKBStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 167, height: 167), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 167, height: 167), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 167, y: resizedFrame.height / 167)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Group 2
        //// Bezier 9 Drawing
        let bezier9Path = UIBezierPath()
        bezier9Path.move(to: CGPoint(x: 62.21, y: 100.45))
        bezier9Path.addCurve(to: CGPoint(x: 58.51, y: 104.61), controlPoint1: CGPoint(x: 60.32, y: 101), controlPoint2: CGPoint(x: 58.79, y: 102.71))
        bezier9Path.addCurve(to: CGPoint(x: 68.14, y: 118.21), controlPoint1: CGPoint(x: 58.19, y: 106.74), controlPoint2: CGPoint(x: 59.44, y: 108.54))
        bezier9Path.addCurve(to: CGPoint(x: 77.49, y: 128.76), controlPoint1: CGPoint(x: 72.03, y: 122.56), controlPoint2: CGPoint(x: 76.24, y: 127.28))
        bezier9Path.addCurve(to: CGPoint(x: 88.74, y: 128.72), controlPoint1: CGPoint(x: 81.48, y: 133.44), controlPoint2: CGPoint(x: 84.76, y: 133.39))
        bezier9Path.addCurve(to: CGPoint(x: 95.41, y: 121.22), controlPoint1: CGPoint(x: 89.95, y: 127.28), controlPoint2: CGPoint(x: 92.96, y: 123.9))
        bezier9Path.addCurve(to: CGPoint(x: 107.26, y: 107.2), controlPoint1: CGPoint(x: 102.13, y: 113.82), controlPoint2: CGPoint(x: 106.48, y: 108.68))
        bezier9Path.addCurve(to: CGPoint(x: 103.65, y: 100.4), controlPoint1: CGPoint(x: 108.65, y: 104.47), controlPoint2: CGPoint(x: 106.99, y: 101.33))
        bezier9Path.addCurve(to: CGPoint(x: 62.21, y: 100.45), controlPoint1: CGPoint(x: 101.71, y: 99.84), controlPoint2: CGPoint(x: 64.21, y: 99.84))
        bezier9Path.close()
        fillColor.setFill()
        bezier9Path.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 61.66, y: 36.55))
        bezier2Path.addCurve(to: CGPoint(x: 58.79, y: 46.13), controlPoint1: CGPoint(x: 59.34, y: 37.98), controlPoint2: CGPoint(x: 58.79, y: 39.84))
        bezier2Path.addCurve(to: CGPoint(x: 61.06, y: 55.98), controlPoint1: CGPoint(x: 58.79, y: 52.61), controlPoint2: CGPoint(x: 59.25, y: 54.69))
        bezier2Path.addCurve(to: CGPoint(x: 69.53, y: 56.91), controlPoint1: CGPoint(x: 62.26, y: 56.82), controlPoint2: CGPoint(x: 63.09, y: 56.91))
        bezier2Path.addCurve(to: CGPoint(x: 80.55, y: 46.13), controlPoint1: CGPoint(x: 80.04, y: 56.91), controlPoint2: CGPoint(x: 80.55, y: 56.4))
        bezier2Path.addCurve(to: CGPoint(x: 77.68, y: 36.55), controlPoint1: CGPoint(x: 80.55, y: 39.84), controlPoint2: CGPoint(x: 79.99, y: 37.98))
        bezier2Path.addCurve(to: CGPoint(x: 69.67, y: 35.62), controlPoint1: CGPoint(x: 76.34, y: 35.76), controlPoint2: CGPoint(x: 75.36, y: 35.62))
        bezier2Path.addCurve(to: CGPoint(x: 61.66, y: 36.55), controlPoint1: CGPoint(x: 63.97, y: 35.62), controlPoint2: CGPoint(x: 63, y: 35.76))
        bezier2Path.close()
        fillColor.setFill()
        bezier2Path.fill()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 88.82, y: 36.55))
        bezierPath.addCurve(to: CGPoint(x: 85.95, y: 46.13), controlPoint1: CGPoint(x: 86.51, y: 37.98), controlPoint2: CGPoint(x: 85.95, y: 39.84))
        bezierPath.addCurve(to: CGPoint(x: 88.22, y: 55.98), controlPoint1: CGPoint(x: 85.95, y: 52.61), controlPoint2: CGPoint(x: 86.41, y: 54.69))
        bezierPath.addCurve(to: CGPoint(x: 96.69, y: 56.91), controlPoint1: CGPoint(x: 89.42, y: 56.82), controlPoint2: CGPoint(x: 90.26, y: 56.91))
        bezierPath.addCurve(to: CGPoint(x: 107.71, y: 46.13), controlPoint1: CGPoint(x: 107.2, y: 56.91), controlPoint2: CGPoint(x: 107.71, y: 56.4))
        bezierPath.addCurve(to: CGPoint(x: 104.84, y: 36.55), controlPoint1: CGPoint(x: 107.71, y: 39.84), controlPoint2: CGPoint(x: 107.16, y: 37.98))
        bezierPath.addCurve(to: CGPoint(x: 96.83, y: 35.62), controlPoint1: CGPoint(x: 103.5, y: 35.76), controlPoint2: CGPoint(x: 102.53, y: 35.62))
        bezierPath.addCurve(to: CGPoint(x: 88.82, y: 36.55), controlPoint1: CGPoint(x: 91.14, y: 35.62), controlPoint2: CGPoint(x: 90.16, y: 35.76))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 115.98, y: 36.55))
        bezier3Path.addCurve(to: CGPoint(x: 113.11, y: 46.13), controlPoint1: CGPoint(x: 113.67, y: 37.98), controlPoint2: CGPoint(x: 113.11, y: 39.84))
        bezier3Path.addCurve(to: CGPoint(x: 115.38, y: 55.98), controlPoint1: CGPoint(x: 113.11, y: 52.61), controlPoint2: CGPoint(x: 113.58, y: 54.69))
        bezier3Path.addCurve(to: CGPoint(x: 123.86, y: 56.91), controlPoint1: CGPoint(x: 116.59, y: 56.82), controlPoint2: CGPoint(x: 117.42, y: 56.91))
        bezier3Path.addCurve(to: CGPoint(x: 134.87, y: 46.13), controlPoint1: CGPoint(x: 134.37, y: 56.91), controlPoint2: CGPoint(x: 134.87, y: 56.4))
        bezier3Path.addCurve(to: CGPoint(x: 132, y: 36.55), controlPoint1: CGPoint(x: 134.87, y: 39.84), controlPoint2: CGPoint(x: 134.32, y: 37.98))
        bezier3Path.addCurve(to: CGPoint(x: 123.99, y: 35.62), controlPoint1: CGPoint(x: 130.66, y: 35.76), controlPoint2: CGPoint(x: 129.69, y: 35.62))
        bezier3Path.addCurve(to: CGPoint(x: 115.98, y: 36.55), controlPoint1: CGPoint(x: 118.3, y: 35.62), controlPoint2: CGPoint(x: 117.33, y: 35.76))
        bezier3Path.close()
        fillColor.setFill()
        bezier3Path.fill()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 34.5, y: 36.55))
        bezier4Path.addCurve(to: CGPoint(x: 31.62, y: 46.13), controlPoint1: CGPoint(x: 32.18, y: 37.98), controlPoint2: CGPoint(x: 31.62, y: 39.84))
        bezier4Path.addCurve(to: CGPoint(x: 33.89, y: 55.98), controlPoint1: CGPoint(x: 31.62, y: 52.61), controlPoint2: CGPoint(x: 32.09, y: 54.69))
        bezier4Path.addCurve(to: CGPoint(x: 42.37, y: 56.91), controlPoint1: CGPoint(x: 35.1, y: 56.82), controlPoint2: CGPoint(x: 35.93, y: 56.91))
        bezier4Path.addCurve(to: CGPoint(x: 53.39, y: 46.13), controlPoint1: CGPoint(x: 52.88, y: 56.91), controlPoint2: CGPoint(x: 53.39, y: 56.4))
        bezier4Path.addCurve(to: CGPoint(x: 50.52, y: 36.55), controlPoint1: CGPoint(x: 53.39, y: 39.84), controlPoint2: CGPoint(x: 52.83, y: 37.98))
        bezier4Path.addCurve(to: CGPoint(x: 42.51, y: 35.62), controlPoint1: CGPoint(x: 49.17, y: 35.76), controlPoint2: CGPoint(x: 48.2, y: 35.62))
        bezier4Path.addCurve(to: CGPoint(x: 34.5, y: 36.55), controlPoint1: CGPoint(x: 36.81, y: 35.62), controlPoint2: CGPoint(x: 35.84, y: 35.76))
        bezier4Path.close()
        fillColor.setFill()
        bezier4Path.fill()
        
        
        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 61.66, y: 68.63))
        bezier5Path.addCurve(to: CGPoint(x: 58.79, y: 78.21), controlPoint1: CGPoint(x: 59.34, y: 70.06), controlPoint2: CGPoint(x: 58.79, y: 71.91))
        bezier5Path.addCurve(to: CGPoint(x: 61.06, y: 88.06), controlPoint1: CGPoint(x: 58.79, y: 84.68), controlPoint2: CGPoint(x: 59.25, y: 86.77))
        bezier5Path.addCurve(to: CGPoint(x: 69.53, y: 88.99), controlPoint1: CGPoint(x: 62.26, y: 88.89), controlPoint2: CGPoint(x: 63.09, y: 88.99))
        bezier5Path.addCurve(to: CGPoint(x: 80.55, y: 78.21), controlPoint1: CGPoint(x: 80.04, y: 88.99), controlPoint2: CGPoint(x: 80.55, y: 88.48))
        bezier5Path.addCurve(to: CGPoint(x: 77.68, y: 68.63), controlPoint1: CGPoint(x: 80.55, y: 71.91), controlPoint2: CGPoint(x: 79.99, y: 70.06))
        bezier5Path.addCurve(to: CGPoint(x: 69.67, y: 67.7), controlPoint1: CGPoint(x: 76.34, y: 67.84), controlPoint2: CGPoint(x: 75.36, y: 67.7))
        bezier5Path.addCurve(to: CGPoint(x: 61.66, y: 68.63), controlPoint1: CGPoint(x: 63.97, y: 67.7), controlPoint2: CGPoint(x: 63, y: 67.84))
        bezier5Path.close()
        fillColor.setFill()
        bezier5Path.fill()
        
        
        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 88.82, y: 68.63))
        bezier6Path.addCurve(to: CGPoint(x: 85.95, y: 78.21), controlPoint1: CGPoint(x: 86.51, y: 70.06), controlPoint2: CGPoint(x: 85.95, y: 71.91))
        bezier6Path.addCurve(to: CGPoint(x: 88.22, y: 88.06), controlPoint1: CGPoint(x: 85.95, y: 84.68), controlPoint2: CGPoint(x: 86.41, y: 86.77))
        bezier6Path.addCurve(to: CGPoint(x: 96.69, y: 88.99), controlPoint1: CGPoint(x: 89.42, y: 88.89), controlPoint2: CGPoint(x: 90.26, y: 88.99))
        bezier6Path.addCurve(to: CGPoint(x: 107.71, y: 78.21), controlPoint1: CGPoint(x: 107.2, y: 88.99), controlPoint2: CGPoint(x: 107.71, y: 88.48))
        bezier6Path.addCurve(to: CGPoint(x: 104.84, y: 68.63), controlPoint1: CGPoint(x: 107.71, y: 71.91), controlPoint2: CGPoint(x: 107.16, y: 70.06))
        bezier6Path.addCurve(to: CGPoint(x: 96.83, y: 67.7), controlPoint1: CGPoint(x: 103.5, y: 67.84), controlPoint2: CGPoint(x: 102.53, y: 67.7))
        bezier6Path.addCurve(to: CGPoint(x: 88.82, y: 68.63), controlPoint1: CGPoint(x: 91.14, y: 67.7), controlPoint2: CGPoint(x: 90.16, y: 67.84))
        bezier6Path.close()
        fillColor.setFill()
        bezier6Path.fill()
        
        
        //// Bezier 8 Drawing
        let bezier8Path = UIBezierPath()
        bezier8Path.move(to: CGPoint(x: 115.98, y: 68.63))
        bezier8Path.addCurve(to: CGPoint(x: 113.11, y: 78.21), controlPoint1: CGPoint(x: 113.67, y: 70.06), controlPoint2: CGPoint(x: 113.11, y: 71.91))
        bezier8Path.addCurve(to: CGPoint(x: 115.38, y: 88.06), controlPoint1: CGPoint(x: 113.11, y: 84.68), controlPoint2: CGPoint(x: 113.58, y: 86.77))
        bezier8Path.addCurve(to: CGPoint(x: 123.86, y: 88.99), controlPoint1: CGPoint(x: 116.59, y: 88.89), controlPoint2: CGPoint(x: 117.42, y: 88.99))
        bezier8Path.addCurve(to: CGPoint(x: 134.87, y: 78.21), controlPoint1: CGPoint(x: 134.37, y: 88.99), controlPoint2: CGPoint(x: 134.87, y: 88.48))
        bezier8Path.addCurve(to: CGPoint(x: 132, y: 68.63), controlPoint1: CGPoint(x: 134.87, y: 71.91), controlPoint2: CGPoint(x: 134.32, y: 70.06))
        bezier8Path.addCurve(to: CGPoint(x: 123.99, y: 67.7), controlPoint1: CGPoint(x: 130.66, y: 67.84), controlPoint2: CGPoint(x: 129.69, y: 67.7))
        bezier8Path.addCurve(to: CGPoint(x: 115.98, y: 68.63), controlPoint1: CGPoint(x: 118.3, y: 67.7), controlPoint2: CGPoint(x: 117.33, y: 67.84))
        bezier8Path.close()
        fillColor.setFill()
        bezier8Path.fill()
        
        
        //// Bezier 10 Drawing
        let bezier10Path = UIBezierPath()
        bezier10Path.move(to: CGPoint(x: 34.5, y: 68.63))
        bezier10Path.addCurve(to: CGPoint(x: 31.62, y: 78.21), controlPoint1: CGPoint(x: 32.18, y: 70.06), controlPoint2: CGPoint(x: 31.62, y: 71.91))
        bezier10Path.addCurve(to: CGPoint(x: 33.89, y: 88.06), controlPoint1: CGPoint(x: 31.62, y: 84.68), controlPoint2: CGPoint(x: 32.09, y: 86.77))
        bezier10Path.addCurve(to: CGPoint(x: 42.37, y: 88.99), controlPoint1: CGPoint(x: 35.1, y: 88.89), controlPoint2: CGPoint(x: 35.93, y: 88.99))
        bezier10Path.addCurve(to: CGPoint(x: 53.39, y: 78.21), controlPoint1: CGPoint(x: 52.88, y: 88.99), controlPoint2: CGPoint(x: 53.39, y: 88.48))
        bezier10Path.addCurve(to: CGPoint(x: 50.52, y: 68.63), controlPoint1: CGPoint(x: 53.39, y: 71.91), controlPoint2: CGPoint(x: 52.83, y: 70.06))
        bezier10Path.addCurve(to: CGPoint(x: 42.51, y: 67.7), controlPoint1: CGPoint(x: 49.17, y: 67.84), controlPoint2: CGPoint(x: 48.2, y: 67.7))
        bezier10Path.addCurve(to: CGPoint(x: 34.5, y: 68.63), controlPoint1: CGPoint(x: 36.81, y: 67.7), controlPoint2: CGPoint(x: 35.84, y: 67.84))
        bezier10Path.close()
        fillColor.setFill()
        bezier10Path.fill()
        
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
