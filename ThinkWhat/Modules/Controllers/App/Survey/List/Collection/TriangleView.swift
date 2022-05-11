//
//  TriangleView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TriangleMark: UIView {
    var color: UIColor = K_COLOR_RED {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        TriangleMarkStyleKit.drawCanvas1(frame: rect, resizing: .aspectFit, color: color)
    }
}

public class TriangleMarkStyleKit : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50), resizing: ResizingBehavior = .aspectFit, color: UIColor = .systemBlue) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 50, height: 50), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 50, y: resizedFrame.height / 50)


        //// Color Declarations
        let mainColor = color

        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 39.4, y: 30.97))
        bezier2Path.addCurve(to: CGPoint(x: 39.65, y: 31.51), controlPoint1: CGPoint(x: 39.57, y: 31.11), controlPoint2: CGPoint(x: 39.65, y: 31.29))
        bezier2Path.addCurve(to: CGPoint(x: 39.58, y: 31.85), controlPoint1: CGPoint(x: 39.65, y: 31.63), controlPoint2: CGPoint(x: 39.63, y: 31.74))
        bezier2Path.addCurve(to: CGPoint(x: 39.41, y: 32.16), controlPoint1: CGPoint(x: 39.52, y: 31.96), controlPoint2: CGPoint(x: 39.47, y: 32.06))
        bezier2Path.addLine(to: CGPoint(x: 34.82, y: 39.4))
        bezier2Path.addCurve(to: CGPoint(x: 34.46, y: 39.75), controlPoint1: CGPoint(x: 34.72, y: 39.55), controlPoint2: CGPoint(x: 34.6, y: 39.67))
        bezier2Path.addCurve(to: CGPoint(x: 34, y: 39.86), controlPoint1: CGPoint(x: 34.32, y: 39.83), controlPoint2: CGPoint(x: 34.17, y: 39.86))
        bezier2Path.addCurve(to: CGPoint(x: 33.54, y: 39.76), controlPoint1: CGPoint(x: 33.83, y: 39.86), controlPoint2: CGPoint(x: 33.68, y: 39.83))
        bezier2Path.addCurve(to: CGPoint(x: 33.14, y: 39.4), controlPoint1: CGPoint(x: 33.4, y: 39.69), controlPoint2: CGPoint(x: 33.27, y: 39.56))
        bezier2Path.addLine(to: CGPoint(x: 30.69, y: 36.39))
        bezier2Path.addCurve(to: CGPoint(x: 30.52, y: 36.08), controlPoint1: CGPoint(x: 30.62, y: 36.29), controlPoint2: CGPoint(x: 30.56, y: 36.19))
        bezier2Path.addCurve(to: CGPoint(x: 30.46, y: 35.75), controlPoint1: CGPoint(x: 30.48, y: 35.97), controlPoint2: CGPoint(x: 30.46, y: 35.86))
        bezier2Path.addCurve(to: CGPoint(x: 30.68, y: 35.18), controlPoint1: CGPoint(x: 30.46, y: 35.53), controlPoint2: CGPoint(x: 30.53, y: 35.34))
        bezier2Path.addCurve(to: CGPoint(x: 31.24, y: 34.94), controlPoint1: CGPoint(x: 30.83, y: 35.02), controlPoint2: CGPoint(x: 31.01, y: 34.94))
        bezier2Path.addCurve(to: CGPoint(x: 31.62, y: 35.03), controlPoint1: CGPoint(x: 31.38, y: 34.94), controlPoint2: CGPoint(x: 31.51, y: 34.97))
        bezier2Path.addCurve(to: CGPoint(x: 31.98, y: 35.36), controlPoint1: CGPoint(x: 31.74, y: 35.09), controlPoint2: CGPoint(x: 31.85, y: 35.2))
        bezier2Path.addLine(to: CGPoint(x: 33.96, y: 37.92))
        bezier2Path.addLine(to: CGPoint(x: 38.13, y: 31.22))
        bezier2Path.addCurve(to: CGPoint(x: 38.83, y: 30.77), controlPoint1: CGPoint(x: 38.31, y: 30.92), controlPoint2: CGPoint(x: 38.55, y: 30.77))
        bezier2Path.addCurve(to: CGPoint(x: 39.4, y: 30.97), controlPoint1: CGPoint(x: 39.04, y: 30.77), controlPoint2: CGPoint(x: 39.23, y: 30.84))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 35.09, y: 24))
        bezier2Path.addCurve(to: CGPoint(x: 33.29, y: 24.93), controlPoint1: CGPoint(x: 34.51, y: 24), controlPoint2: CGPoint(x: 33.91, y: 24.31))
        bezier2Path.addLine(to: CGPoint(x: 31.78, y: 26.43))
        bezier2Path.addCurve(to: CGPoint(x: 31.29, y: 26.62), controlPoint1: CGPoint(x: 31.65, y: 26.56), controlPoint2: CGPoint(x: 31.49, y: 26.62))
        bezier2Path.addLine(to: CGPoint(x: 29.18, y: 26.62))
        bezier2Path.addCurve(to: CGPoint(x: 27.24, y: 27.24), controlPoint1: CGPoint(x: 28.3, y: 26.62), controlPoint2: CGPoint(x: 27.66, y: 26.83))
        bezier2Path.addCurve(to: CGPoint(x: 26.62, y: 29.18), controlPoint1: CGPoint(x: 26.83, y: 27.66), controlPoint2: CGPoint(x: 26.62, y: 28.3))
        bezier2Path.addLine(to: CGPoint(x: 26.62, y: 31.3))
        bezier2Path.addCurve(to: CGPoint(x: 26.42, y: 31.79), controlPoint1: CGPoint(x: 26.62, y: 31.49), controlPoint2: CGPoint(x: 26.55, y: 31.65))
        bezier2Path.addLine(to: CGPoint(x: 24.93, y: 33.29))
        bezier2Path.addCurve(to: CGPoint(x: 24.41, y: 33.91), controlPoint1: CGPoint(x: 24.72, y: 33.5), controlPoint2: CGPoint(x: 24.55, y: 33.7))
        bezier2Path.addCurve(to: CGPoint(x: 24, y: 35.1), controlPoint1: CGPoint(x: 24.14, y: 34.31), controlPoint2: CGPoint(x: 24, y: 34.71))
        bezier2Path.addCurve(to: CGPoint(x: 24.93, y: 36.9), controlPoint1: CGPoint(x: 24, y: 35.68), controlPoint2: CGPoint(x: 24.31, y: 36.28))
        bezier2Path.addLine(to: CGPoint(x: 26.42, y: 38.4))
        bezier2Path.addCurve(to: CGPoint(x: 26.62, y: 38.9), controlPoint1: CGPoint(x: 26.55, y: 38.54), controlPoint2: CGPoint(x: 26.62, y: 38.7))
        bezier2Path.addLine(to: CGPoint(x: 26.62, y: 41.01))
        bezier2Path.addCurve(to: CGPoint(x: 27.24, y: 42.94), controlPoint1: CGPoint(x: 26.62, y: 41.88), controlPoint2: CGPoint(x: 26.83, y: 42.52))
        bezier2Path.addCurve(to: CGPoint(x: 29.18, y: 43.57), controlPoint1: CGPoint(x: 27.66, y: 43.36), controlPoint2: CGPoint(x: 28.3, y: 43.57))
        bezier2Path.addLine(to: CGPoint(x: 31.29, y: 43.57))
        bezier2Path.addCurve(to: CGPoint(x: 31.78, y: 43.77), controlPoint1: CGPoint(x: 31.49, y: 43.57), controlPoint2: CGPoint(x: 31.65, y: 43.63))
        bezier2Path.addLine(to: CGPoint(x: 33.29, y: 45.26))
        bezier2Path.addCurve(to: CGPoint(x: 35.09, y: 46.19), controlPoint1: CGPoint(x: 33.91, y: 45.88), controlPoint2: CGPoint(x: 34.51, y: 46.19))
        bezier2Path.addCurve(to: CGPoint(x: 36.89, y: 45.26), controlPoint1: CGPoint(x: 35.68, y: 46.18), controlPoint2: CGPoint(x: 36.28, y: 45.88))
        bezier2Path.addLine(to: CGPoint(x: 38.39, y: 43.77))
        bezier2Path.addCurve(to: CGPoint(x: 38.89, y: 43.57), controlPoint1: CGPoint(x: 38.53, y: 43.63), controlPoint2: CGPoint(x: 38.7, y: 43.57))
        bezier2Path.addLine(to: CGPoint(x: 41, y: 43.57))
        bezier2Path.addCurve(to: CGPoint(x: 42.94, y: 42.95), controlPoint1: CGPoint(x: 41.87, y: 43.57), controlPoint2: CGPoint(x: 42.52, y: 43.36))
        bezier2Path.addCurve(to: CGPoint(x: 43.56, y: 41.01), controlPoint1: CGPoint(x: 43.35, y: 42.53), controlPoint2: CGPoint(x: 43.56, y: 41.89))
        bezier2Path.addLine(to: CGPoint(x: 43.56, y: 38.9))
        bezier2Path.addCurve(to: CGPoint(x: 43.77, y: 38.4), controlPoint1: CGPoint(x: 43.56, y: 38.7), controlPoint2: CGPoint(x: 43.63, y: 38.54))
        bezier2Path.addLine(to: CGPoint(x: 45.26, y: 36.9))
        bezier2Path.addCurve(to: CGPoint(x: 46.18, y: 35.1), controlPoint1: CGPoint(x: 45.88, y: 36.28), controlPoint2: CGPoint(x: 46.19, y: 35.68))
        bezier2Path.addCurve(to: CGPoint(x: 45.26, y: 33.29), controlPoint1: CGPoint(x: 46.18, y: 34.51), controlPoint2: CGPoint(x: 45.87, y: 33.91))
        bezier2Path.addLine(to: CGPoint(x: 43.77, y: 31.79))
        bezier2Path.addCurve(to: CGPoint(x: 43.56, y: 31.3), controlPoint1: CGPoint(x: 43.63, y: 31.65), controlPoint2: CGPoint(x: 43.56, y: 31.49))
        bezier2Path.addLine(to: CGPoint(x: 43.56, y: 29.18))
        bezier2Path.addCurve(to: CGPoint(x: 42.94, y: 27.25), controlPoint1: CGPoint(x: 43.56, y: 28.31), controlPoint2: CGPoint(x: 43.35, y: 27.67))
        bezier2Path.addCurve(to: CGPoint(x: 41, y: 26.62), controlPoint1: CGPoint(x: 42.53, y: 26.83), controlPoint2: CGPoint(x: 41.88, y: 26.62))
        bezier2Path.addLine(to: CGPoint(x: 38.89, y: 26.62))
        bezier2Path.addCurve(to: CGPoint(x: 38.39, y: 26.43), controlPoint1: CGPoint(x: 38.7, y: 26.62), controlPoint2: CGPoint(x: 38.53, y: 26.56))
        bezier2Path.addLine(to: CGPoint(x: 36.89, y: 24.93))
        bezier2Path.addCurve(to: CGPoint(x: 35.09, y: 24), controlPoint1: CGPoint(x: 36.28, y: 24.31), controlPoint2: CGPoint(x: 35.68, y: 24))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 50, y: 0))
        bezier2Path.addCurve(to: CGPoint(x: 50, y: 50), controlPoint1: CGPoint(x: 50, y: 0), controlPoint2: CGPoint(x: 50, y: 50))
        bezier2Path.addLine(to: CGPoint(x: 0, y: 50))
        bezier2Path.addLine(to: CGPoint(x: 50, y: 0))
        bezier2Path.addLine(to: CGPoint(x: 50, y: 0))
        bezier2Path.close()
        mainColor.setFill()
        bezier2Path.fill()
        
        context.restoreGState()

    }




    @objc(TriangleMarkStyleKitResizingBehavior)
    public enum ResizingBehavior: Int {
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
