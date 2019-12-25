//
//  CameraIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CameraIcon: UIView {
    override func draw(_ rect: CGRect) {
        CameraGalleryStyleKit.drawCamera(frame: rect, resizing: .aspectFit)
    }
}

class GalleryIcon: UIView {
    override func draw(_ rect: CGRect) {
        CameraGalleryStyleKit.drawGallery(frame: rect, resizing: .aspectFit)
    }
}

class PlusIcon: UIView {
    override func draw(_ rect: CGRect) {
        CameraGalleryStyleKit.drawPlus(frame: rect, resizing: .aspectFit)
    }
}

public class CameraGalleryStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawCamera(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
        let color2 = UIColor(red: 0.604, green: 0.604, blue: 0.604, alpha: 1.000)
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 130, y: 104.5))
        bezier2Path.addCurve(to: CGPoint(x: 99.5, y: 135), controlPoint1: CGPoint(x: 130, y: 121.34), controlPoint2: CGPoint(x: 116.34, y: 135))
        bezier2Path.addCurve(to: CGPoint(x: 69, y: 104.5), controlPoint1: CGPoint(x: 82.66, y: 135), controlPoint2: CGPoint(x: 69, y: 121.34))
        bezier2Path.addCurve(to: CGPoint(x: 99.5, y: 74), controlPoint1: CGPoint(x: 69, y: 87.66), controlPoint2: CGPoint(x: 82.66, y: 74))
        bezier2Path.addCurve(to: CGPoint(x: 130, y: 104.5), controlPoint1: CGPoint(x: 116.34, y: 74), controlPoint2: CGPoint(x: 130, y: 87.66))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 100, y: 59))
        bezier2Path.addCurve(to: CGPoint(x: 84.92, y: 61.59), controlPoint1: CGPoint(x: 94.71, y: 59), controlPoint2: CGPoint(x: 89.63, y: 59.91))
        bezier2Path.addCurve(to: CGPoint(x: 55, y: 104), controlPoint1: CGPoint(x: 67.48, y: 67.79), controlPoint2: CGPoint(x: 55, y: 84.44))
        bezier2Path.addCurve(to: CGPoint(x: 100, y: 149), controlPoint1: CGPoint(x: 55, y: 128.85), controlPoint2: CGPoint(x: 75.15, y: 149))
        bezier2Path.addCurve(to: CGPoint(x: 145, y: 104), controlPoint1: CGPoint(x: 124.85, y: 149), controlPoint2: CGPoint(x: 145, y: 128.85))
        bezier2Path.addCurve(to: CGPoint(x: 100, y: 59), controlPoint1: CGPoint(x: 145, y: 79.15), controlPoint2: CGPoint(x: 124.85, y: 59))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 112.84, y: 1))
        bezier2Path.addCurve(to: CGPoint(x: 126.51, y: 3.16), controlPoint1: CGPoint(x: 113.03, y: 1), controlPoint2: CGPoint(x: 120.11, y: 1.05))
        bezier2Path.addLine(to: CGPoint(x: 127.78, y: 3.47))
        bezier2Path.addCurve(to: CGPoint(x: 147.82, y: 29), controlPoint1: CGPoint(x: 138.86, y: 7.5), controlPoint2: CGPoint(x: 146.56, y: 17.47))
        bezier2Path.addLine(to: CGPoint(x: 170.96, y: 29))
        bezier2Path.addCurve(to: CGPoint(x: 179.47, y: 29.09), controlPoint1: CGPoint(x: 174.42, y: 29), controlPoint2: CGPoint(x: 177.17, y: 29))
        bezier2Path.addCurve(to: CGPoint(x: 187.27, y: 30.24), controlPoint1: CGPoint(x: 182.72, y: 29.21), controlPoint2: CGPoint(x: 185.06, y: 29.52))
        bezier2Path.addLine(to: CGPoint(x: 188, y: 30.42))
        bezier2Path.addCurve(to: CGPoint(x: 198.58, y: 41), controlPoint1: CGPoint(x: 192.92, y: 32.21), controlPoint2: CGPoint(x: 196.79, y: 36.08))
        bezier2Path.addCurve(to: CGPoint(x: 200, y: 58.04), controlPoint1: CGPoint(x: 200, y: 45.5), controlPoint2: CGPoint(x: 200, y: 49.68))
        bezier2Path.addLine(to: CGPoint(x: 200, y: 142.96))
        bezier2Path.addCurve(to: CGPoint(x: 198.76, y: 159.27), controlPoint1: CGPoint(x: 200, y: 151.32), controlPoint2: CGPoint(x: 200, y: 155.5))
        bezier2Path.addLine(to: CGPoint(x: 198.58, y: 160))
        bezier2Path.addCurve(to: CGPoint(x: 188, y: 170.58), controlPoint1: CGPoint(x: 196.79, y: 164.92), controlPoint2: CGPoint(x: 192.92, y: 168.79))
        bezier2Path.addCurve(to: CGPoint(x: 170.96, y: 172), controlPoint1: CGPoint(x: 183.5, y: 172), controlPoint2: CGPoint(x: 179.32, y: 172))
        bezier2Path.addLine(to: CGPoint(x: 29.04, y: 172))
        bezier2Path.addCurve(to: CGPoint(x: 12.73, y: 170.76), controlPoint1: CGPoint(x: 20.68, y: 172), controlPoint2: CGPoint(x: 16.5, y: 172))
        bezier2Path.addLine(to: CGPoint(x: 12, y: 170.58))
        bezier2Path.addCurve(to: CGPoint(x: 1.42, y: 160), controlPoint1: CGPoint(x: 7.08, y: 168.79), controlPoint2: CGPoint(x: 3.21, y: 164.92))
        bezier2Path.addCurve(to: CGPoint(x: 0, y: 142.96), controlPoint1: CGPoint(x: 0, y: 155.5), controlPoint2: CGPoint(x: 0, y: 151.32))
        bezier2Path.addLine(to: CGPoint(x: 0, y: 58.04))
        bezier2Path.addCurve(to: CGPoint(x: 1.24, y: 41.73), controlPoint1: CGPoint(x: 0, y: 49.68), controlPoint2: CGPoint(x: -0, y: 45.5))
        bezier2Path.addLine(to: CGPoint(x: 1.42, y: 41))
        bezier2Path.addCurve(to: CGPoint(x: 12, y: 30.42), controlPoint1: CGPoint(x: 3.21, y: 36.08), controlPoint2: CGPoint(x: 7.08, y: 32.21))
        bezier2Path.addCurve(to: CGPoint(x: 29.04, y: 29), controlPoint1: CGPoint(x: 16.5, y: 29), controlPoint2: CGPoint(x: 20.68, y: 29))
        bezier2Path.addLine(to: CGPoint(x: 53.18, y: 29))
        bezier2Path.addCurve(to: CGPoint(x: 73.22, y: 3.47), controlPoint1: CGPoint(x: 54.44, y: 17.47), controlPoint2: CGPoint(x: 62.14, y: 7.5))
        bezier2Path.addLine(to: CGPoint(x: 96.3, y: 1.01))
        bezier2Path.addCurve(to: CGPoint(x: 102.83, y: 1), controlPoint1: CGPoint(x: 98.31, y: 1), controlPoint2: CGPoint(x: 100.47, y: 1))
        bezier2Path.addLine(to: CGPoint(x: 112.84, y: 1))
        bezier2Path.close()
        color2.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawGallery(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
        let color = UIColor(red: 0.604, green: 0.604, blue: 0.604, alpha: 1.000)
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 80, y: 78))
        bezier2Path.addCurve(to: CGPoint(x: 39.3, y: 140.25), controlPoint1: CGPoint(x: 79.75, y: 78.37), controlPoint2: CGPoint(x: 39.3, y: 140.25))
        bezier2Path.addLine(to: CGPoint(x: 120.69, y: 140.23))
        bezier2Path.addCurve(to: CGPoint(x: 161.28, y: 140.23), controlPoint1: CGPoint(x: 136.86, y: 140.23), controlPoint2: CGPoint(x: 161.28, y: 140.23))
        bezier2Path.addLine(to: CGPoint(x: 134, y: 98.42))
        bezier2Path.addCurve(to: CGPoint(x: 113.7, y: 129.54), controlPoint1: CGPoint(x: 134, y: 98.42), controlPoint2: CGPoint(x: 121.78, y: 117.15))
        bezier2Path.addCurve(to: CGPoint(x: 80, y: 78), controlPoint1: CGPoint(x: 102.06, y: 111.74), controlPoint2: CGPoint(x: 80, y: 78))
        bezier2Path.addLine(to: CGPoint(x: 80, y: 78))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 187.27, y: 30.24))
        bezier2Path.addLine(to: CGPoint(x: 188, y: 30.42))
        bezier2Path.addCurve(to: CGPoint(x: 198.58, y: 41), controlPoint1: CGPoint(x: 192.92, y: 32.21), controlPoint2: CGPoint(x: 196.79, y: 36.08))
        bezier2Path.addCurve(to: CGPoint(x: 200, y: 58.04), controlPoint1: CGPoint(x: 200, y: 45.5), controlPoint2: CGPoint(x: 200, y: 49.68))
        bezier2Path.addLine(to: CGPoint(x: 200, y: 142.96))
        bezier2Path.addCurve(to: CGPoint(x: 198.76, y: 159.27), controlPoint1: CGPoint(x: 200, y: 151.32), controlPoint2: CGPoint(x: 200, y: 155.5))
        bezier2Path.addLine(to: CGPoint(x: 198.58, y: 160))
        bezier2Path.addCurve(to: CGPoint(x: 188, y: 170.58), controlPoint1: CGPoint(x: 196.79, y: 164.92), controlPoint2: CGPoint(x: 192.92, y: 168.79))
        bezier2Path.addCurve(to: CGPoint(x: 170.96, y: 172), controlPoint1: CGPoint(x: 183.5, y: 172), controlPoint2: CGPoint(x: 179.32, y: 172))
        bezier2Path.addLine(to: CGPoint(x: 29.04, y: 172))
        bezier2Path.addCurve(to: CGPoint(x: 12.73, y: 170.76), controlPoint1: CGPoint(x: 20.68, y: 172), controlPoint2: CGPoint(x: 16.5, y: 172))
        bezier2Path.addLine(to: CGPoint(x: 12, y: 170.58))
        bezier2Path.addCurve(to: CGPoint(x: 1.42, y: 160), controlPoint1: CGPoint(x: 7.08, y: 168.79), controlPoint2: CGPoint(x: 3.21, y: 164.92))
        bezier2Path.addCurve(to: CGPoint(x: 0, y: 142.96), controlPoint1: CGPoint(x: 0, y: 155.5), controlPoint2: CGPoint(x: 0, y: 151.32))
        bezier2Path.addLine(to: CGPoint(x: 0, y: 58.04))
        bezier2Path.addCurve(to: CGPoint(x: 1.24, y: 41.73), controlPoint1: CGPoint(x: 0, y: 49.68), controlPoint2: CGPoint(x: -0, y: 45.5))
        bezier2Path.addLine(to: CGPoint(x: 1.42, y: 41))
        bezier2Path.addCurve(to: CGPoint(x: 12, y: 30.42), controlPoint1: CGPoint(x: 3.21, y: 36.08), controlPoint2: CGPoint(x: 7.08, y: 32.21))
        bezier2Path.addCurve(to: CGPoint(x: 29.04, y: 29), controlPoint1: CGPoint(x: 16.5, y: 29), controlPoint2: CGPoint(x: 20.68, y: 29))
        bezier2Path.addLine(to: CGPoint(x: 170.96, y: 29))
        bezier2Path.addCurve(to: CGPoint(x: 187.27, y: 30.24), controlPoint1: CGPoint(x: 179.32, y: 29), controlPoint2: CGPoint(x: 183.5, y: 29))
        bezier2Path.close()
        color.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawPlus(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
        let color = UIColor(red: 0.604, green: 0.604, blue: 0.604, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 116.69, y: 21.72))
        bezierPath.addCurve(to: CGPoint(x: 118, y: 37.42), controlPoint1: CGPoint(x: 118, y: 25.87), controlPoint2: CGPoint(x: 118, y: 29.72))
        bezierPath.addCurve(to: CGPoint(x: 118, y: 83), controlPoint1: CGPoint(x: 118, y: 37.42), controlPoint2: CGPoint(x: 118, y: 58.06))
        bezierPath.addLine(to: CGPoint(x: 169.13, y: 83))
        bezierPath.addCurve(to: CGPoint(x: 177.6, y: 84.15), controlPoint1: CGPoint(x: 170.28, y: 83), controlPoint2: CGPoint(x: 174.13, y: 83))
        bezierPath.addLine(to: CGPoint(x: 178.28, y: 84.31))
        bezierPath.addCurve(to: CGPoint(x: 189, y: 99.63), controlPoint1: CGPoint(x: 184.71, y: 86.65), controlPoint2: CGPoint(x: 189, y: 92.77))
        bezierPath.addCurve(to: CGPoint(x: 189, y: 100.5), controlPoint1: CGPoint(x: 189, y: 100.5), controlPoint2: CGPoint(x: 189, y: 100.5))
        bezierPath.addLine(to: CGPoint(x: 189, y: 101.37))
        bezierPath.addCurve(to: CGPoint(x: 178.28, y: 116.69), controlPoint1: CGPoint(x: 189, y: 108.23), controlPoint2: CGPoint(x: 184.71, y: 114.35))
        bezierPath.addCurve(to: CGPoint(x: 162.58, y: 118), controlPoint1: CGPoint(x: 174.13, y: 118), controlPoint2: CGPoint(x: 170.28, y: 118))
        bezierPath.addLine(to: CGPoint(x: 118, y: 118))
        bezierPath.addCurve(to: CGPoint(x: 118, y: 169.13), controlPoint1: CGPoint(x: 118, y: 145.35), controlPoint2: CGPoint(x: 118, y: 169.13))
        bezierPath.addCurve(to: CGPoint(x: 116.85, y: 177.6), controlPoint1: CGPoint(x: 118, y: 170.28), controlPoint2: CGPoint(x: 118, y: 174.13))
        bezierPath.addLine(to: CGPoint(x: 116.69, y: 178.28))
        bezierPath.addCurve(to: CGPoint(x: 101.37, y: 189), controlPoint1: CGPoint(x: 114.35, y: 184.71), controlPoint2: CGPoint(x: 108.23, y: 189))
        bezierPath.addCurve(to: CGPoint(x: 100.5, y: 189), controlPoint1: CGPoint(x: 100.5, y: 189), controlPoint2: CGPoint(x: 100.5, y: 189))
        bezierPath.addLine(to: CGPoint(x: 99.62, y: 189))
        bezierPath.addCurve(to: CGPoint(x: 84.31, y: 178.28), controlPoint1: CGPoint(x: 92.77, y: 189), controlPoint2: CGPoint(x: 86.65, y: 184.71))
        bezierPath.addCurve(to: CGPoint(x: 83.05, y: 169.13), controlPoint1: CGPoint(x: 83.44, y: 175.51), controlPoint2: CGPoint(x: 83.14, y: 172.87))
        bezierPath.addCurve(to: CGPoint(x: 83.01, y: 166.04), controlPoint1: CGPoint(x: 83.02, y: 168.17), controlPoint2: CGPoint(x: 83.01, y: 167.15))
        bezierPath.addCurve(to: CGPoint(x: 83, y: 162.58), controlPoint1: CGPoint(x: 83, y: 164.97), controlPoint2: CGPoint(x: 83, y: 163.83))
        bezierPath.addCurve(to: CGPoint(x: 83, y: 118), controlPoint1: CGPoint(x: 83, y: 155.41), controlPoint2: CGPoint(x: 83, y: 137.95))
        bezierPath.addLine(to: CGPoint(x: 30.87, y: 118))
        bezierPath.addCurve(to: CGPoint(x: 22.4, y: 116.85), controlPoint1: CGPoint(x: 29.72, y: 118), controlPoint2: CGPoint(x: 25.87, y: 118))
        bezierPath.addLine(to: CGPoint(x: 21.72, y: 116.69))
        bezierPath.addCurve(to: CGPoint(x: 11, y: 101.37), controlPoint1: CGPoint(x: 15.29, y: 114.35), controlPoint2: CGPoint(x: 11, y: 108.23))
        bezierPath.addCurve(to: CGPoint(x: 11, y: 100.5), controlPoint1: CGPoint(x: 11, y: 100.5), controlPoint2: CGPoint(x: 11, y: 100.5))
        bezierPath.addLine(to: CGPoint(x: 11, y: 99.62))
        bezierPath.addCurve(to: CGPoint(x: 21.72, y: 84.31), controlPoint1: CGPoint(x: 11, y: 92.77), controlPoint2: CGPoint(x: 15.29, y: 86.65))
        bezierPath.addCurve(to: CGPoint(x: 30.87, y: 83.05), controlPoint1: CGPoint(x: 24.49, y: 83.44), controlPoint2: CGPoint(x: 27.13, y: 83.14))
        bezierPath.addCurve(to: CGPoint(x: 33.96, y: 83.01), controlPoint1: CGPoint(x: 31.83, y: 83.02), controlPoint2: CGPoint(x: 32.85, y: 83.01))
        bezierPath.addCurve(to: CGPoint(x: 37.42, y: 83), controlPoint1: CGPoint(x: 35.03, y: 83), controlPoint2: CGPoint(x: 36.17, y: 83))
        bezierPath.addLine(to: CGPoint(x: 83, y: 83))
        bezierPath.addCurve(to: CGPoint(x: 83, y: 30.87), controlPoint1: CGPoint(x: 83, y: 55.08), controlPoint2: CGPoint(x: 83, y: 30.87))
        bezierPath.addCurve(to: CGPoint(x: 84.15, y: 22.4), controlPoint1: CGPoint(x: 83, y: 29.72), controlPoint2: CGPoint(x: 83, y: 25.87))
        bezierPath.addLine(to: CGPoint(x: 84.31, y: 21.72))
        bezierPath.addCurve(to: CGPoint(x: 99.63, y: 11), controlPoint1: CGPoint(x: 86.65, y: 15.29), controlPoint2: CGPoint(x: 92.77, y: 11))
        bezierPath.addCurve(to: CGPoint(x: 100.5, y: 11), controlPoint1: CGPoint(x: 100.5, y: 11), controlPoint2: CGPoint(x: 100.5, y: 11))
        bezierPath.addLine(to: CGPoint(x: 101.37, y: 11))
        bezierPath.addCurve(to: CGPoint(x: 116.69, y: 21.72), controlPoint1: CGPoint(x: 108.23, y: 11), controlPoint2: CGPoint(x: 114.35, y: 15.29))
        bezierPath.close()
        color.setFill()
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
