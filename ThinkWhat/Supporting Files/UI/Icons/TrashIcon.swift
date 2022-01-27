//
//  TrashIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.12.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
final class TrashIcon: UIView {
    @IBInspectable var color: UIColor = K_COLOR_RED {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        TrashIconStyleKit.drawTrashIcon(frame: rect, resizing: .aspectFit, color: color)
    }
}

public class TrashIconStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawTrashIcon(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 216, height: 216), resizing: ResizingBehavior = .aspectFit, color: UIColor) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 216, height: 216), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 216, y: resizedFrame.height / 216)
        
        
        //// Group 2
        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 101.12, y: 13.98))
        bezier6Path.addCurve(to: CGPoint(x: 79.58, y: 32.31), controlPoint1: CGPoint(x: 91.76, y: 15.87), controlPoint2: CGPoint(x: 83.21, y: 23.15))
        bezier6Path.addLine(to: CGPoint(x: 78.2, y: 35.88))
        bezier6Path.addLine(to: CGPoint(x: 66.38, y: 35.93))
        bezier6Path.addCurve(to: CGPoint(x: 46.64, y: 36.33), controlPoint1: CGPoint(x: 59.89, y: 35.93), controlPoint2: CGPoint(x: 50.99, y: 36.13))
        bezier6Path.addCurve(to: CGPoint(x: 35.74, y: 38.01), controlPoint1: CGPoint(x: 39.58, y: 36.64), controlPoint2: CGPoint(x: 38.4, y: 36.84))
        bezier6Path.addCurve(to: CGPoint(x: 25.51, y: 48.04), controlPoint1: CGPoint(x: 31.65, y: 39.9), controlPoint2: CGPoint(x: 27.56, y: 43.97))
        bezier6Path.addCurve(to: CGPoint(x: 23.88, y: 57.26), controlPoint1: CGPoint(x: 23.98, y: 51.25), controlPoint2: CGPoint(x: 23.88, y: 51.71))
        bezier6Path.addCurve(to: CGPoint(x: 25.26, y: 66.01), controlPoint1: CGPoint(x: 23.88, y: 62.55), controlPoint2: CGPoint(x: 24.03, y: 63.42))
        bezier6Path.addCurve(to: CGPoint(x: 33.29, y: 75.03), controlPoint1: CGPoint(x: 26.84, y: 69.43), controlPoint2: CGPoint(x: 29.96, y: 72.89))
        bezier6Path.addCurve(to: CGPoint(x: 108.84, y: 78.03), controlPoint1: CGPoint(x: 38.35, y: 78.28), controlPoint2: CGPoint(x: 35.03, y: 78.13))
        bezier6Path.addLine(to: CGPoint(x: 175.8, y: 77.88))
        bezier6Path.addLine(to: CGPoint(x: 179.23, y: 76.15))
        bezier6Path.addCurve(to: CGPoint(x: 179.38, y: 38.37), controlPoint1: CGPoint(x: 195.14, y: 68.2), controlPoint2: CGPoint(x: 195.19, y: 46.16))
        bezier6Path.addCurve(to: CGPoint(x: 167.21, y: 36.33), controlPoint1: CGPoint(x: 176.11, y: 36.79), controlPoint2: CGPoint(x: 175.7, y: 36.74))
        bezier6Path.addCurve(to: CGPoint(x: 147.05, y: 35.93), controlPoint1: CGPoint(x: 162.35, y: 36.13), controlPoint2: CGPoint(x: 153.29, y: 35.93))
        bezier6Path.addCurve(to: CGPoint(x: 135.65, y: 35.01), controlPoint1: CGPoint(x: 136.62, y: 35.88), controlPoint2: CGPoint(x: 135.65, y: 35.82))
        bezier6Path.addCurve(to: CGPoint(x: 133.5, y: 29.77), controlPoint1: CGPoint(x: 135.65, y: 34.5), controlPoint2: CGPoint(x: 134.67, y: 32.16))
        bezier6Path.addCurve(to: CGPoint(x: 101.12, y: 13.98), controlPoint1: CGPoint(x: 127.62, y: 18.01), controlPoint2: CGPoint(x: 114.11, y: 11.39))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 112.12, y: 28.04))
        bezier6Path.addCurve(to: CGPoint(x: 117.85, y: 31.8), controlPoint1: CGPoint(x: 114.21, y: 28.65), controlPoint2: CGPoint(x: 115.54, y: 29.51))
        bezier6Path.addCurve(to: CGPoint(x: 120.81, y: 35.32), controlPoint1: CGPoint(x: 119.48, y: 33.43), controlPoint2: CGPoint(x: 120.81, y: 35.01))
        bezier6Path.addCurve(to: CGPoint(x: 107, y: 35.88), controlPoint1: CGPoint(x: 120.81, y: 35.72), controlPoint2: CGPoint(x: 116.57, y: 35.88))
        bezier6Path.addCurve(to: CGPoint(x: 93.19, y: 35.47), controlPoint1: CGPoint(x: 99.43, y: 35.88), controlPoint2: CGPoint(x: 93.19, y: 35.67))
        bezier6Path.addCurve(to: CGPoint(x: 94.98, y: 32.97), controlPoint1: CGPoint(x: 93.19, y: 35.21), controlPoint2: CGPoint(x: 94.01, y: 34.09))
        bezier6Path.addCurve(to: CGPoint(x: 112.12, y: 28.04), controlPoint1: CGPoint(x: 99.38, y: 27.88), controlPoint2: CGPoint(x: 105.52, y: 26.1))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 174.01, y: 50.74))
        bezier6Path.addCurve(to: CGPoint(x: 173.81, y: 63.06), controlPoint1: CGPoint(x: 178.67, y: 53.95), controlPoint2: CGPoint(x: 178.56, y: 59.55))
        bezier6Path.addCurve(to: CGPoint(x: 158, y: 64.49), controlPoint1: CGPoint(x: 172.48, y: 64.08), controlPoint2: CGPoint(x: 171.45, y: 64.13))
        bezier6Path.addCurve(to: CGPoint(x: 93.19, y: 64.54), controlPoint1: CGPoint(x: 150.07, y: 64.64), controlPoint2: CGPoint(x: 120.91, y: 64.69))
        bezier6Path.addCurve(to: CGPoint(x: 38.76, y: 61.33), controlPoint1: CGPoint(x: 38.45, y: 64.23), controlPoint2: CGPoint(x: 41.37, y: 64.39))
        bezier6Path.addCurve(to: CGPoint(x: 37.43, y: 56.9), controlPoint1: CGPoint(x: 37.69, y: 60.01), controlPoint2: CGPoint(x: 37.43, y: 59.19))
        bezier6Path.addCurve(to: CGPoint(x: 39.68, y: 51.86), controlPoint1: CGPoint(x: 37.43, y: 54.25), controlPoint2: CGPoint(x: 37.58, y: 53.95))
        bezier6Path.addLine(to: CGPoint(x: 41.88, y: 49.62))
        bezier6Path.addLine(to: CGPoint(x: 107.1, y: 49.62))
        bezier6Path.addLine(to: CGPoint(x: 172.32, y: 49.62))
        bezier6Path.addLine(to: CGPoint(x: 174.01, y: 50.74))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 43.06, y: 84.09))
        bezier6Path.addCurve(to: CGPoint(x: 39.73, y: 133.88), controlPoint1: CGPoint(x: 39.53, y: 85.87), controlPoint2: CGPoint(x: 39.73, y: 83.17))
        bezier6Path.addLine(to: CGPoint(x: 39.73, y: 179.69))
        bezier6Path.addLine(to: CGPoint(x: 40.91, y: 183.11))
        bezier6Path.addCurve(to: CGPoint(x: 56.77, y: 200.92), controlPoint1: CGPoint(x: 43.52, y: 190.64), controlPoint2: CGPoint(x: 49.61, y: 197.46))
        bezier6Path.addLine(to: CGPoint(x: 61.12, y: 203.01))
        bezier6Path.addLine(to: CGPoint(x: 70.89, y: 203.42))
        bezier6Path.addCurve(to: CGPoint(x: 116.77, y: 203.47), controlPoint1: CGPoint(x: 76.26, y: 203.67), controlPoint2: CGPoint(x: 96.92, y: 203.67))
        bezier6Path.addLine(to: CGPoint(x: 152.89, y: 203.11))
        bezier6Path.addLine(to: CGPoint(x: 157.44, y: 200.87))
        bezier6Path.addCurve(to: CGPoint(x: 171.4, y: 187.08), controlPoint1: CGPoint(x: 163.68, y: 197.82), controlPoint2: CGPoint(x: 168.39, y: 193.13))
        bezier6Path.addCurve(to: CGPoint(x: 174.01, y: 177.91), controlPoint1: CGPoint(x: 173.24, y: 183.36), controlPoint2: CGPoint(x: 173.65, y: 181.99))
        bezier6Path.addCurve(to: CGPoint(x: 174.52, y: 130.01), controlPoint1: CGPoint(x: 174.27, y: 175.27), controlPoint2: CGPoint(x: 174.52, y: 153.73))
        bezier6Path.addLine(to: CGPoint(x: 174.52, y: 86.99))
        bezier6Path.addLine(to: CGPoint(x: 172.84, y: 85.36))
        bezier6Path.addCurve(to: CGPoint(x: 161.94, y: 86.38), controlPoint1: CGPoint(x: 169.61, y: 82.25), controlPoint2: CGPoint(x: 163.83, y: 82.76))
        bezier6Path.addCurve(to: CGPoint(x: 160.81, y: 132.86), controlPoint1: CGPoint(x: 161.07, y: 87.96), controlPoint2: CGPoint(x: 160.97, y: 91.06))
        bezier6Path.addLine(to: CGPoint(x: 160.61, y: 177.66))
        bezier6Path.addLine(to: CGPoint(x: 159.43, y: 180.25))
        bezier6Path.addCurve(to: CGPoint(x: 151.91, y: 188.4), controlPoint1: CGPoint(x: 157.9, y: 183.72), controlPoint2: CGPoint(x: 155.24, y: 186.52))
        bezier6Path.addLine(to: CGPoint(x: 149.2, y: 189.88))
        bezier6Path.addLine(to: CGPoint(x: 107.61, y: 190.03))
        bezier6Path.addLine(to: CGPoint(x: 66.08, y: 190.18))
        bezier6Path.addLine(to: CGPoint(x: 63.16, y: 188.81))
        bezier6Path.addCurve(to: CGPoint(x: 55.03, y: 181.12), controlPoint1: CGPoint(x: 59.89, y: 187.23), controlPoint2: CGPoint(x: 56.46, y: 184.02))
        bezier6Path.addCurve(to: CGPoint(x: 53.34, y: 124.97), controlPoint1: CGPoint(x: 53.7, y: 178.37), controlPoint2: CGPoint(x: 53.39, y: 169.11))
        bezier6Path.addCurve(to: CGPoint(x: 52.27, y: 86.43), controlPoint1: CGPoint(x: 53.29, y: 89.38), controlPoint2: CGPoint(x: 53.24, y: 88.01))
        bezier6Path.addCurve(to: CGPoint(x: 47.05, y: 83.43), controlPoint1: CGPoint(x: 51.09, y: 84.44), controlPoint2: CGPoint(x: 49.91, y: 83.78))
        bezier6Path.addCurve(to: CGPoint(x: 43.06, y: 84.09), controlPoint1: CGPoint(x: 45.51, y: 83.22), controlPoint2: CGPoint(x: 44.34, y: 83.43))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 71.24, y: 90.45))
        bezier6Path.addCurve(to: CGPoint(x: 68.94, y: 92.54), controlPoint1: CGPoint(x: 70.58, y: 90.81), controlPoint2: CGPoint(x: 69.5, y: 91.77))
        bezier6Path.addCurve(to: CGPoint(x: 67.71, y: 134.33), controlPoint1: CGPoint(x: 67.87, y: 93.96), controlPoint2: CGPoint(x: 67.87, y: 94.27))
        bezier6Path.addCurve(to: CGPoint(x: 68.23, y: 176.64), controlPoint1: CGPoint(x: 67.61, y: 166.1), controlPoint2: CGPoint(x: 67.71, y: 175.11))
        bezier6Path.addCurve(to: CGPoint(x: 77.69, y: 179.95), controlPoint1: CGPoint(x: 69.5, y: 180.46), controlPoint2: CGPoint(x: 74.16, y: 182.09))
        bezier6Path.addCurve(to: CGPoint(x: 81.32, y: 135.2), controlPoint1: CGPoint(x: 81.32, y: 177.76), controlPoint2: CGPoint(x: 81.07, y: 180.81))
        bezier6Path.addLine(to: CGPoint(x: 81.58, y: 94.07))
        bezier6Path.addLine(to: CGPoint(x: 79.79, y: 92.13))
        bezier6Path.addCurve(to: CGPoint(x: 75.23, y: 89.99), controlPoint1: CGPoint(x: 78.2, y: 90.45), controlPoint2: CGPoint(x: 77.69, y: 90.15))
        bezier6Path.addCurve(to: CGPoint(x: 71.24, y: 90.45), controlPoint1: CGPoint(x: 73.6, y: 89.89), controlPoint2: CGPoint(x: 71.96, y: 90.04))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 104.19, y: 90.35))
        bezier6Path.addCurve(to: CGPoint(x: 101.73, y: 92.28), controlPoint1: CGPoint(x: 103.62, y: 90.55), controlPoint2: CGPoint(x: 102.5, y: 91.42))
        bezier6Path.addLine(to: CGPoint(x: 100.3, y: 93.76))
        bezier6Path.addLine(to: CGPoint(x: 100.45, y: 135.2))
        bezier6Path.addCurve(to: CGPoint(x: 103.98, y: 180.41), controlPoint1: CGPoint(x: 100.61, y: 181.27), controlPoint2: CGPoint(x: 100.45, y: 179.19))
        bezier6Path.addCurve(to: CGPoint(x: 112.73, y: 177.81), controlPoint1: CGPoint(x: 107.56, y: 181.63), controlPoint2: CGPoint(x: 110.63, y: 180.71))
        bezier6Path.addLine(to: CGPoint(x: 113.91, y: 176.13))
        bezier6Path.addLine(to: CGPoint(x: 113.91, y: 135.4))
        bezier6Path.addCurve(to: CGPoint(x: 110.58, y: 90.76), controlPoint1: CGPoint(x: 113.91, y: 90.3), controlPoint2: CGPoint(x: 114.06, y: 92.49))
        bezier6Path.addCurve(to: CGPoint(x: 104.19, y: 90.35), controlPoint1: CGPoint(x: 108.69, y: 89.79), controlPoint2: CGPoint(x: 105.93, y: 89.64))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 136.31, y: 90.6))
        bezier6Path.addCurve(to: CGPoint(x: 133.19, y: 135.4), controlPoint1: CGPoint(x: 133.19, y: 91.93), controlPoint2: CGPoint(x: 133.34, y: 89.89))
        bezier6Path.addLine(to: CGPoint(x: 133.04, y: 177.15))
        bezier6Path.addLine(to: CGPoint(x: 134.83, y: 178.88))
        bezier6Path.addCurve(to: CGPoint(x: 145.62, y: 177.71), controlPoint1: CGPoint(x: 138.05, y: 181.99), controlPoint2: CGPoint(x: 143.17, y: 181.43))
        bezier6Path.addCurve(to: CGPoint(x: 146.75, y: 139.63), controlPoint1: CGPoint(x: 146.39, y: 176.54), controlPoint2: CGPoint(x: 146.49, y: 172.67))
        bezier6Path.addCurve(to: CGPoint(x: 146.64, y: 98.24), controlPoint1: CGPoint(x: 146.9, y: 119.37), controlPoint2: CGPoint(x: 146.9, y: 100.79))
        bezier6Path.addCurve(to: CGPoint(x: 144.34, y: 91.77), controlPoint1: CGPoint(x: 146.29, y: 93.86), controlPoint2: CGPoint(x: 146.18, y: 93.61))
        bezier6Path.addCurve(to: CGPoint(x: 140.2, y: 89.84), controlPoint1: CGPoint(x: 142.71, y: 90.09), controlPoint2: CGPoint(x: 142.09, y: 89.84))
        bezier6Path.addCurve(to: CGPoint(x: 136.31, y: 90.6), controlPoint1: CGPoint(x: 138.97, y: 89.89), controlPoint2: CGPoint(x: 137.23, y: 90.2))
        bezier6Path.close()
        color.setFill()
        bezier6Path.fill()
        
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
