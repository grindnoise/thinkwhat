//
//  Megaphone.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.07.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class Megaphone: UIView {
    override func draw(_ rect: CGRect) {
        MegaphoneStyleKit.drawMegaphone_2(frame: rect, resizing: .aspectFit)
    }
}

public class MegaphoneStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawMegaphone(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 337, height: 337), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 337, height: 337), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 337, y: resizedFrame.height / 337)
        
        
        //// Color Declarations
        let fillColor = K_COLOR_RED//UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 276.71, y: 0.26))
        bezierPath.addCurve(to: CGPoint(x: 266.13, y: 8.81), controlPoint1: CGPoint(x: 272.66, y: 1.31), controlPoint2: CGPoint(x: 268.38, y: 4.76))
        bezierPath.addLine(to: CGPoint(x: 263.96, y: 12.71))
        bezierPath.addLine(to: CGPoint(x: 263.96, y: 150.33))
        bezierPath.addLine(to: CGPoint(x: 263.96, y: 287.96))
        bezierPath.addLine(to: CGPoint(x: 266.06, y: 291.71))
        bezierPath.addCurve(to: CGPoint(x: 280.23, y: 300.86), controlPoint1: CGPoint(x: 269.06, y: 297.11), controlPoint2: CGPoint(x: 274.08, y: 300.41))
        bezierPath.addCurve(to: CGPoint(x: 288.03, y: 300.41), controlPoint1: CGPoint(x: 282.86, y: 301.08), controlPoint2: CGPoint(x: 286.31, y: 300.86))
        bezierPath.addCurve(to: CGPoint(x: 299.28, y: 290.28), controlPoint1: CGPoint(x: 292.16, y: 299.28), controlPoint2: CGPoint(x: 297.18, y: 294.78))
        bezierPath.addLine(to: CGPoint(x: 301.08, y: 286.46))
        bezierPath.addLine(to: CGPoint(x: 301.08, y: 244.31))
        bezierPath.addLine(to: CGPoint(x: 301.08, y: 202.16))
        bezierPath.addLine(to: CGPoint(x: 307.98, y: 198.63))
        bezierPath.addCurve(to: CGPoint(x: 334.61, y: 167.21), controlPoint1: CGPoint(x: 320.36, y: 192.18), controlPoint2: CGPoint(x: 330.18, y: 180.56))
        bezierPath.addCurve(to: CGPoint(x: 335.58, y: 137.13), controlPoint1: CGPoint(x: 337.31, y: 158.88), controlPoint2: CGPoint(x: 337.76, y: 145.76))
        bezierPath.addCurve(to: CGPoint(x: 308.06, y: 102.11), controlPoint1: CGPoint(x: 331.83, y: 121.98), controlPoint2: CGPoint(x: 321.63, y: 109.08))
        bezierPath.addLine(to: CGPoint(x: 301.16, y: 98.51))
        bezierPath.addLine(to: CGPoint(x: 300.93, y: 55.23))
        bezierPath.addLine(to: CGPoint(x: 300.71, y: 11.96))
        bezierPath.addLine(to: CGPoint(x: 298.53, y: 8.51))
        bezierPath.addCurve(to: CGPoint(x: 292.83, y: 2.66), controlPoint1: CGPoint(x: 297.33, y: 6.63), controlPoint2: CGPoint(x: 294.78, y: 4.01))
        bezierPath.addCurve(to: CGPoint(x: 284.13, y: -0.04), controlPoint1: CGPoint(x: 289.91, y: 0.71), controlPoint2: CGPoint(x: 288.41, y: 0.18))
        bezierPath.addCurve(to: CGPoint(x: 276.71, y: 0.26), controlPoint1: CGPoint(x: 281.28, y: -0.19), controlPoint2: CGPoint(x: 277.91, y: -0.12))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 248.13, y: 27.86))
        bezier2Path.addCurve(to: CGPoint(x: 227.13, y: 49.08), controlPoint1: CGPoint(x: 243.41, y: 33.78), controlPoint2: CGPoint(x: 233.58, y: 43.68))
        bezier2Path.addCurve(to: CGPoint(x: 151.91, y: 80.96), controlPoint1: CGPoint(x: 206.51, y: 66.41), controlPoint2: CGPoint(x: 183.86, y: 76.01))
        bezier2Path.addCurve(to: CGPoint(x: 88.46, y: 84.78), controlPoint1: CGPoint(x: 135.11, y: 83.58), controlPoint2: CGPoint(x: 123.18, y: 84.26))
        bezier2Path.addCurve(to: CGPoint(x: 43.08, y: 89.28), controlPoint1: CGPoint(x: 55.46, y: 85.31), controlPoint2: CGPoint(x: 51.03, y: 85.68))
        bezier2Path.addCurve(to: CGPoint(x: 29.13, y: 103.38), controlPoint1: CGPoint(x: 37.68, y: 91.68), controlPoint2: CGPoint(x: 31.76, y: 97.68))
        bezier2Path.addLine(to: CGPoint(x: 27.33, y: 107.36))
        bezier2Path.addLine(to: CGPoint(x: 22.23, y: 107.73))
        bezier2Path.addCurve(to: CGPoint(x: 2.51, y: 120.48), controlPoint1: CGPoint(x: 13.68, y: 108.33), controlPoint2: CGPoint(x: 6.63, y: 112.91))
        bezier2Path.addLine(to: CGPoint(x: -0.04, y: 125.21))
        bezier2Path.addLine(to: CGPoint(x: -0.04, y: 150.33))
        bezier2Path.addLine(to: CGPoint(x: -0.04, y: 175.46))
        bezier2Path.addLine(to: CGPoint(x: 1.98, y: 179.36))
        bezier2Path.addCurve(to: CGPoint(x: 21.56, y: 192.93), controlPoint1: CGPoint(x: 6.11, y: 187.08), controlPoint2: CGPoint(x: 13.16, y: 192.03))
        bezier2Path.addCurve(to: CGPoint(x: 26.96, y: 196.46), controlPoint1: CGPoint(x: 25.98, y: 193.46), controlPoint2: CGPoint(x: 26.06, y: 193.46))
        bezier2Path.addCurve(to: CGPoint(x: 53.96, y: 216.78), controlPoint1: CGPoint(x: 30.78, y: 209.36), controlPoint2: CGPoint(x: 38.81, y: 215.36))
        bezier2Path.addCurve(to: CGPoint(x: 59.43, y: 217.46), controlPoint1: CGPoint(x: 56.88, y: 217.08), controlPoint2: CGPoint(x: 59.28, y: 217.38))
        bezier2Path.addCurve(to: CGPoint(x: 71.21, y: 292.46), controlPoint1: CGPoint(x: 60.93, y: 218.81), controlPoint2: CGPoint(x: 68.13, y: 264.63))
        bezier2Path.addCurve(to: CGPoint(x: 71.96, y: 299.21), controlPoint1: CGPoint(x: 71.51, y: 294.93), controlPoint2: CGPoint(x: 71.81, y: 297.93))
        bezier2Path.addCurve(to: CGPoint(x: 73.46, y: 312.71), controlPoint1: CGPoint(x: 72.86, y: 306.63), controlPoint2: CGPoint(x: 73.08, y: 308.66))
        bezier2Path.addCurve(to: CGPoint(x: 80.58, y: 332.81), controlPoint1: CGPoint(x: 74.58, y: 323.88), controlPoint2: CGPoint(x: 76.53, y: 329.43))
        bezier2Path.addCurve(to: CGPoint(x: 109.31, y: 337.08), controlPoint1: CGPoint(x: 84.93, y: 336.48), controlPoint2: CGPoint(x: 88.83, y: 337.08))
        bezier2Path.addCurve(to: CGPoint(x: 134.36, y: 332.28), controlPoint1: CGPoint(x: 130.08, y: 337.08), controlPoint2: CGPoint(x: 132.11, y: 336.71))
        bezier2Path.addCurve(to: CGPoint(x: 131.06, y: 292.16), controlPoint1: CGPoint(x: 136.91, y: 327.33), controlPoint2: CGPoint(x: 135.86, y: 313.98))
        bezier2Path.addCurve(to: CGPoint(x: 128.28, y: 278.36), controlPoint1: CGPoint(x: 129.56, y: 285.33), controlPoint2: CGPoint(x: 128.36, y: 279.11))
        bezier2Path.addCurve(to: CGPoint(x: 133.08, y: 274.91), controlPoint1: CGPoint(x: 128.21, y: 277.38), controlPoint2: CGPoint(x: 129.56, y: 276.41))
        bezier2Path.addCurve(to: CGPoint(x: 154.08, y: 256.83), controlPoint1: CGPoint(x: 142.98, y: 270.71), controlPoint2: CGPoint(x: 150.11, y: 264.63))
        bezier2Path.addCurve(to: CGPoint(x: 151.83, y: 228.48), controlPoint1: CGPoint(x: 157.76, y: 249.71), controlPoint2: CGPoint(x: 156.86, y: 237.78))
        bezier2Path.addLine(to: CGPoint(x: 149.73, y: 224.58))
        bezier2Path.addLine(to: CGPoint(x: 151.61, y: 224.58))
        bezier2Path.addCurve(to: CGPoint(x: 181.53, y: 231.41), controlPoint1: CGPoint(x: 155.43, y: 224.58), controlPoint2: CGPoint(x: 172.61, y: 228.48))
        bezier2Path.addCurve(to: CGPoint(x: 245.21, y: 270.26), controlPoint1: CGPoint(x: 207.18, y: 239.73), controlPoint2: CGPoint(x: 226.98, y: 251.81))
        bezier2Path.addCurve(to: CGPoint(x: 252.11, y: 276.33), controlPoint1: CGPoint(x: 248.51, y: 273.63), controlPoint2: CGPoint(x: 251.58, y: 276.33))
        bezier2Path.addCurve(to: CGPoint(x: 253.08, y: 150.33), controlPoint1: CGPoint(x: 252.93, y: 276.33), controlPoint2: CGPoint(x: 253.08, y: 251.88))
        bezier2Path.addCurve(to: CGPoint(x: 252.03, y: 24.33), controlPoint1: CGPoint(x: 253.08, y: 43.76), controlPoint2: CGPoint(x: 252.93, y: 24.33))
        bezier2Path.addCurve(to: CGPoint(x: 248.13, y: 27.86), controlPoint1: CGPoint(x: 251.51, y: 24.33), controlPoint2: CGPoint(x: 249.71, y: 25.91))
        bezier2Path.close()
        fillColor.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    
    @objc public dynamic class func drawMegaphone_2(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
        let fillColor = K_COLOR_RED
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 124.26, y: 32.1))
        bezierPath.addCurve(to: CGPoint(x: 73.55, y: 54.9), controlPoint1: CGPoint(x: 115.45, y: 41.42), controlPoint2: CGPoint(x: 96.17, y: 50.12))
        bezierPath.addCurve(to: CGPoint(x: 62.36, y: 54.41), controlPoint1: CGPoint(x: 64.14, y: 56.86), controlPoint2: CGPoint(x: 64.02, y: 56.86))
        bezierPath.addCurve(to: CGPoint(x: 39.38, y: 51.84), controlPoint1: CGPoint(x: 60.81, y: 51.96), controlPoint2: CGPoint(x: 59.62, y: 51.84))
        bezierPath.addLine(to: CGPoint(x: 17.95, y: 51.84))
        bezierPath.addLine(to: CGPoint(x: 13.9, y: 56.01))
        bezierPath.addCurve(to: CGPoint(x: 9.86, y: 66.43), controlPoint1: CGPoint(x: 10.33, y: 59.68), controlPoint2: CGPoint(x: 9.86, y: 60.91))
        bezierPath.addCurve(to: CGPoint(x: 6.52, y: 72.68), controlPoint1: CGPoint(x: 9.86, y: 72.44), controlPoint2: CGPoint(x: 9.74, y: 72.68))
        bezierPath.addCurve(to: CGPoint(x: 0.33, y: 86.78), controlPoint1: CGPoint(x: 1.17, y: 72.68), controlPoint2: CGPoint(x: 0.33, y: 74.64))
        bezierPath.addCurve(to: CGPoint(x: 6.52, y: 100.88), controlPoint1: CGPoint(x: 0.33, y: 98.92), controlPoint2: CGPoint(x: 1.17, y: 100.88))
        bezierPath.addCurve(to: CGPoint(x: 9.86, y: 105.79), controlPoint1: CGPoint(x: 9.62, y: 100.88), controlPoint2: CGPoint(x: 9.86, y: 101.25))
        bezierPath.addCurve(to: CGPoint(x: 22.71, y: 121.24), controlPoint1: CGPoint(x: 9.86, y: 114.98), controlPoint2: CGPoint(x: 13.9, y: 119.77))
        bezierPath.addLine(to: CGPoint(x: 27.36, y: 121.97))
        bezierPath.addLine(to: CGPoint(x: 34.26, y: 146.13))
        bezierPath.addCurve(to: CGPoint(x: 42.83, y: 172.98), controlPoint1: CGPoint(x: 38.07, y: 159.37), controlPoint2: CGPoint(x: 42, y: 171.39))
        bezierPath.addCurve(to: CGPoint(x: 48.9, y: 175.43), controlPoint1: CGPoint(x: 44.14, y: 175.31), controlPoint2: CGPoint(x: 45.33, y: 175.8))
        bezierPath.addCurve(to: CGPoint(x: 53.19, y: 146.86), controlPoint1: CGPoint(x: 56.17, y: 174.82), controlPoint2: CGPoint(x: 56.52, y: 172.49))
        bezierPath.addCurve(to: CGPoint(x: 50.33, y: 123.2), controlPoint1: CGPoint(x: 51.64, y: 134.72), controlPoint2: CGPoint(x: 50.33, y: 124.06))
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: 121.73), controlPoint1: CGPoint(x: 50.33, y: 122.34), controlPoint2: CGPoint(x: 52, y: 121.73))
        bezierPath.addCurve(to: CGPoint(x: 61.88, y: 118.54), controlPoint1: CGPoint(x: 57.48, y: 121.73), controlPoint2: CGPoint(x: 59.74, y: 120.75))
        bezierPath.addCurve(to: CGPoint(x: 72.6, y: 116.7), controlPoint1: CGPoint(x: 64.98, y: 115.35), controlPoint2: CGPoint(x: 65.21, y: 115.23))
        bezierPath.addCurve(to: CGPoint(x: 122.36, y: 137.67), controlPoint1: CGPoint(x: 91.05, y: 120.13), controlPoint2: CGPoint(x: 120.81, y: 132.76))
        bezierPath.addCurve(to: CGPoint(x: 133.67, y: 146.25), controlPoint1: CGPoint(x: 123.55, y: 141.35), controlPoint2: CGPoint(x: 129.98, y: 146.25))
        bezierPath.addCurve(to: CGPoint(x: 148.31, y: 126.88), controlPoint1: CGPoint(x: 138.67, y: 146.25), controlPoint2: CGPoint(x: 144.62, y: 138.4))
        bezierPath.addCurve(to: CGPoint(x: 138.9, y: 28.66), controlPoint1: CGPoint(x: 158.67, y: 94.75), controlPoint2: CGPoint(x: 153.43, y: 40.43))
        bezierPath.addCurve(to: CGPoint(x: 124.26, y: 32.1), controlPoint1: CGPoint(x: 133.9, y: 24.62), controlPoint2: CGPoint(x: 130.57, y: 25.35))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 136.64, y: 55.88))
        bezierPath.addCurve(to: CGPoint(x: 135.21, y: 122.1), controlPoint1: CGPoint(x: 140.93, y: 74.28), controlPoint2: CGPoint(x: 140.21, y: 104.93))
        bezierPath.addLine(to: CGPoint(x: 133.31, y: 128.47))
        bezierPath.addLine(to: CGPoint(x: 131.05, y: 121.73))
        bezierPath.addCurve(to: CGPoint(x: 128.79, y: 99.66), controlPoint1: CGPoint(x: 128.19, y: 113.27), controlPoint2: CGPoint(x: 126.76, y: 99.66))
        bezierPath.addCurve(to: CGPoint(x: 132.48, y: 95.61), controlPoint1: CGPoint(x: 129.5, y: 99.66), controlPoint2: CGPoint(x: 131.17, y: 97.82))
        bezierPath.addCurve(to: CGPoint(x: 129.02, y: 72.8), controlPoint1: CGPoint(x: 136.64, y: 88.5), controlPoint2: CGPoint(x: 134.86, y: 75.99))
        bezierPath.addCurve(to: CGPoint(x: 127.83, y: 65.33), controlPoint1: CGPoint(x: 127.12, y: 71.7), controlPoint2: CGPoint(x: 127, y: 70.72))
        bezierPath.addCurve(to: CGPoint(x: 133.67, y: 46.32), controlPoint1: CGPoint(x: 129.26, y: 55.88), controlPoint2: CGPoint(x: 132.48, y: 45.58))
        bezierPath.addCurve(to: CGPoint(x: 136.64, y: 55.88), controlPoint1: CGPoint(x: 134.14, y: 46.69), controlPoint2: CGPoint(x: 135.57, y: 50.98))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 177.12, y: 55.64))
        bezier2Path.addCurve(to: CGPoint(x: 162.48, y: 66.31), controlPoint1: CGPoint(x: 163.07, y: 61.52), controlPoint2: CGPoint(x: 162, y: 62.26))
        bezier2Path.addCurve(to: CGPoint(x: 189.38, y: 63.36), controlPoint1: CGPoint(x: 163.31, y: 73.17), controlPoint2: CGPoint(x: 169.02, y: 72.56))
        bezier2Path.addCurve(to: CGPoint(x: 195.57, y: 56.86), controlPoint1: CGPoint(x: 194.86, y: 60.91), controlPoint2: CGPoint(x: 195.57, y: 60.18))
        bezier2Path.addCurve(to: CGPoint(x: 193.31, y: 51.84), controlPoint1: CGPoint(x: 195.57, y: 54.41), controlPoint2: CGPoint(x: 194.74, y: 52.7))
        bezier2Path.addCurve(to: CGPoint(x: 177.12, y: 55.64), controlPoint1: CGPoint(x: 190.21, y: 50.12), controlPoint2: CGPoint(x: 190.57, y: 50.12))
        bezier2Path.close()
        fillColor.setFill()
        bezier2Path.fill()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 167.95, y: 81.39))
        bezier3Path.addCurve(to: CGPoint(x: 168.07, y: 91.07), controlPoint1: CGPoint(x: 164.98, y: 83.1), controlPoint2: CGPoint(x: 165.1, y: 89.36))
        bezier3Path.addCurve(to: CGPoint(x: 183.55, y: 92.3), controlPoint1: CGPoint(x: 169.38, y: 91.69), controlPoint2: CGPoint(x: 176.29, y: 92.3))
        bezier3Path.addCurve(to: CGPoint(x: 200.33, y: 86.29), controlPoint1: CGPoint(x: 197.24, y: 92.3), controlPoint2: CGPoint(x: 200.33, y: 91.2))
        bezier3Path.addCurve(to: CGPoint(x: 182.95, y: 80.04), controlPoint1: CGPoint(x: 200.33, y: 81.39), controlPoint2: CGPoint(x: 196.76, y: 80.04))
        bezier3Path.addCurve(to: CGPoint(x: 167.95, y: 81.39), controlPoint1: CGPoint(x: 175.81, y: 80.04), controlPoint2: CGPoint(x: 169.02, y: 80.65))
        bezier3Path.close()
        fillColor.setFill()
        bezier3Path.fill()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 164.14, y: 102.84))
        bezier4Path.addCurve(to: CGPoint(x: 163.9, y: 110.57), controlPoint1: CGPoint(x: 161.76, y: 105.17), controlPoint2: CGPoint(x: 161.64, y: 108.73))
        bezier4Path.addCurve(to: CGPoint(x: 190.81, y: 121.73), controlPoint1: CGPoint(x: 166.17, y: 112.53), controlPoint2: CGPoint(x: 188.43, y: 121.73))
        bezier4Path.addCurve(to: CGPoint(x: 193.9, y: 112.04), controlPoint1: CGPoint(x: 195.1, y: 121.73), controlPoint2: CGPoint(x: 197.36, y: 114.98))
        bezier4Path.addCurve(to: CGPoint(x: 167.48, y: 100.88), controlPoint1: CGPoint(x: 191.88, y: 110.32), controlPoint2: CGPoint(x: 169.5, y: 100.88))
        bezier4Path.addCurve(to: CGPoint(x: 164.14, y: 102.84), controlPoint1: CGPoint(x: 166.64, y: 100.88), controlPoint2: CGPoint(x: 165.1, y: 101.74))
        bezier4Path.close()
        fillColor.setFill()
        bezier4Path.fill()
        
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

