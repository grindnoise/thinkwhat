//
//  WebIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class WebIcon: UIView {
    override func draw(_ rect: CGRect) {
        WebStyleKit.drawCanvas1(frame: rect, resizing: .aspectFit)
    }
}

public class WebStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 168, height: 168), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 168, height: 168), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 168, y: resizedFrame.height / 168)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.604, green: 0.604, blue: 0.604, alpha: 1.000)
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 72.75, y: 0.45))
        bezierPath.addCurve(to: CGPoint(x: 7.42, y: 48.67), controlPoint1: CGPoint(x: 44.85, y: 4.2), controlPoint2: CGPoint(x: 19.28, y: 23.1))
        bezierPath.addCurve(to: CGPoint(x: 7.05, y: 118.2), controlPoint1: CGPoint(x: -2.55, y: 70.27), controlPoint2: CGPoint(x: -2.7, y: 96.15))
        bezierPath.addCurve(to: CGPoint(x: 51.53, y: 161.7), controlPoint1: CGPoint(x: 15.45, y: 137.32), controlPoint2: CGPoint(x: 32.25, y: 153.75))
        bezierPath.addCurve(to: CGPoint(x: 142.73, y: 144.07), controlPoint1: CGPoint(x: 82.88, y: 174.67), controlPoint2: CGPoint(x: 118.35, y: 167.77))
        bezierPath.addCurve(to: CGPoint(x: 142.43, y: 23.62), controlPoint1: CGPoint(x: 176.7, y: 111.07), controlPoint2: CGPoint(x: 176.55, y: 56.4))
        bezierPath.addCurve(to: CGPoint(x: 100.65, y: 1.42), controlPoint1: CGPoint(x: 130.2, y: 11.85), controlPoint2: CGPoint(x: 117.15, y: 4.95))
        bezierPath.addCurve(to: CGPoint(x: 72.75, y: 0.45), controlPoint1: CGPoint(x: 93.9, y: -0), controlPoint2: CGPoint(x: 79.65, y: -0.53))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 96.23, y: 16.42))
        bezierPath.addCurve(to: CGPoint(x: 105.83, y: 29.25), controlPoint1: CGPoint(x: 99.3, y: 20.17), controlPoint2: CGPoint(x: 103.65, y: 25.95))
        bezierPath.addCurve(to: CGPoint(x: 114.9, y: 46.65), controlPoint1: CGPoint(x: 110.1, y: 35.85), controlPoint2: CGPoint(x: 115.43, y: 46.05))
        bezierPath.addCurve(to: CGPoint(x: 90.6, y: 51.37), controlPoint1: CGPoint(x: 113.7, y: 47.77), controlPoint2: CGPoint(x: 95.48, y: 51.37))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 51.37))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 29.55))
        bezierPath.addCurve(to: CGPoint(x: 96.23, y: 16.42), controlPoint1: CGPoint(x: 88.12, y: 4.42), controlPoint2: CGPoint(x: 87.23, y: 5.77))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 79.5, y: 51.22))
        bezierPath.addCurve(to: CGPoint(x: 54.23, y: 46.95), controlPoint1: CGPoint(x: 78.53, y: 52.27), controlPoint2: CGPoint(x: 55.88, y: 48.37))
        bezierPath.addCurve(to: CGPoint(x: 64.5, y: 27.07), controlPoint1: CGPoint(x: 53.48, y: 46.27), controlPoint2: CGPoint(x: 59.7, y: 34.2))
        bezierPath.addCurve(to: CGPoint(x: 74.03, y: 14.62), controlPoint1: CGPoint(x: 66.75, y: 23.77), controlPoint2: CGPoint(x: 71.03, y: 18.15))
        bezierPath.addLine(to: CGPoint(x: 79.5, y: 8.25))
        bezierPath.addLine(to: CGPoint(x: 79.73, y: 29.55))
        bezierPath.addCurve(to: CGPoint(x: 79.5, y: 51.22), controlPoint1: CGPoint(x: 79.8, y: 41.25), controlPoint2: CGPoint(x: 79.73, y: 51))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 64.35, y: 13.65))
        bezierPath.addCurve(to: CGPoint(x: 49.43, y: 36.9), controlPoint1: CGPoint(x: 59.55, y: 19.35), controlPoint2: CGPoint(x: 53.1, y: 29.4))
        bezierPath.addCurve(to: CGPoint(x: 45.3, y: 43.87), controlPoint1: CGPoint(x: 47.55, y: 40.72), controlPoint2: CGPoint(x: 45.68, y: 43.87))
        bezierPath.addCurve(to: CGPoint(x: 29.4, y: 35.85), controlPoint1: CGPoint(x: 44.33, y: 43.87), controlPoint2: CGPoint(x: 33.15, y: 38.25))
        bezierPath.addLine(to: CGPoint(x: 26.48, y: 33.97))
        bezierPath.addLine(to: CGPoint(x: 30.08, y: 30.22))
        bezierPath.addCurve(to: CGPoint(x: 47.48, y: 17.1), controlPoint1: CGPoint(x: 34.73, y: 25.5), controlPoint2: CGPoint(x: 41.25, y: 20.62))
        bezierPath.addCurve(to: CGPoint(x: 66.98, y: 9.75), controlPoint1: CGPoint(x: 52.28, y: 14.4), controlPoint2: CGPoint(x: 66.38, y: 9.07))
        bezierPath.addCurve(to: CGPoint(x: 64.35, y: 13.65), controlPoint1: CGPoint(x: 67.2, y: 9.9), controlPoint2: CGPoint(x: 66, y: 11.7))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 112.12, y: 13.27))
        bezierPath.addCurve(to: CGPoint(x: 137.93, y: 30.22), controlPoint1: CGPoint(x: 121.65, y: 17.02), controlPoint2: CGPoint(x: 130.95, y: 23.1))
        bezierPath.addLine(to: CGPoint(x: 141.53, y: 33.97))
        bezierPath.addLine(to: CGPoint(x: 138.6, y: 35.85))
        bezierPath.addCurve(to: CGPoint(x: 123, y: 43.72), controlPoint1: CGPoint(x: 135, y: 38.17), controlPoint2: CGPoint(x: 123.3, y: 44.02))
        bezierPath.addCurve(to: CGPoint(x: 119.25, y: 36.6), controlPoint1: CGPoint(x: 122.93, y: 43.57), controlPoint2: CGPoint(x: 121.2, y: 40.35))
        bezierPath.addCurve(to: CGPoint(x: 104.4, y: 13.57), controlPoint1: CGPoint(x: 115.35, y: 28.87), controlPoint2: CGPoint(x: 109.05, y: 19.12))
        bezierPath.addLine(to: CGPoint(x: 101.33, y: 9.97))
        bezierPath.addLine(to: CGPoint(x: 103.95, y: 10.5))
        bezierPath.addCurve(to: CGPoint(x: 112.12, y: 13.27), controlPoint1: CGPoint(x: 105.3, y: 10.8), controlPoint2: CGPoint(x: 109.05, y: 12))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 27.53, y: 44.1))
        bezierPath.addCurve(to: CGPoint(x: 38.18, y: 49.57), controlPoint1: CGPoint(x: 30.68, y: 45.9), controlPoint2: CGPoint(x: 35.48, y: 48.3))
        bezierPath.addCurve(to: CGPoint(x: 42.75, y: 53.25), controlPoint1: CGPoint(x: 42.38, y: 51.37), controlPoint2: CGPoint(x: 43.05, y: 51.97))
        bezierPath.addCurve(to: CGPoint(x: 38.62, y: 75.9), controlPoint1: CGPoint(x: 41.18, y: 58.72), controlPoint2: CGPoint(x: 38.62, y: 72.67))
        bezierPath.addLine(to: CGPoint(x: 38.62, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 23.25, y: 79.87))
        bezierPath.addCurve(to: CGPoint(x: 7.88, y: 78.45), controlPoint1: CGPoint(x: 8.7, y: 79.87), controlPoint2: CGPoint(x: 7.88, y: 79.8))
        bezierPath.addCurve(to: CGPoint(x: 12.38, y: 57.97), controlPoint1: CGPoint(x: 7.88, y: 74.85), controlPoint2: CGPoint(x: 10.35, y: 63.52))
        bezierPath.addCurve(to: CGPoint(x: 21.38, y: 40.87), controlPoint1: CGPoint(x: 14.55, y: 51.97), controlPoint2: CGPoint(x: 20.4, y: 40.87))
        bezierPath.addCurve(to: CGPoint(x: 27.53, y: 44.1), controlPoint1: CGPoint(x: 21.68, y: 40.87), controlPoint2: CGPoint(x: 24.45, y: 42.3))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 150.15, y: 46.27))
        bezierPath.addCurve(to: CGPoint(x: 158.55, y: 69.15), controlPoint1: CGPoint(x: 154.43, y: 53.92), controlPoint2: CGPoint(x: 156.75, y: 60.3))
        bezierPath.addCurve(to: CGPoint(x: 145.57, y: 79.87), controlPoint1: CGPoint(x: 161.03, y: 81.15), controlPoint2: CGPoint(x: 162.53, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 131.02, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 130.5, y: 74.77))
        bezierPath.addCurve(to: CGPoint(x: 126.08, y: 52.87), controlPoint1: CGPoint(x: 130.05, y: 70.05), controlPoint2: CGPoint(x: 127.05, y: 55.35))
        bezierPath.addCurve(to: CGPoint(x: 132.45, y: 48.37), controlPoint1: CGPoint(x: 125.7, y: 51.97), controlPoint2: CGPoint(x: 127.28, y: 50.85))
        bezierPath.addCurve(to: CGPoint(x: 142.43, y: 42.97), controlPoint1: CGPoint(x: 136.2, y: 46.5), controlPoint2: CGPoint(x: 140.7, y: 44.1))
        bezierPath.addCurve(to: CGPoint(x: 146.32, y: 40.87), controlPoint1: CGPoint(x: 144.07, y: 41.77), controlPoint2: CGPoint(x: 145.88, y: 40.87))
        bezierPath.addCurve(to: CGPoint(x: 150.15, y: 46.27), controlPoint1: CGPoint(x: 146.7, y: 40.87), controlPoint2: CGPoint(x: 148.43, y: 43.35))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 119.25, y: 58.27))
        bezierPath.addCurve(to: CGPoint(x: 122.62, y: 77.32), controlPoint1: CGPoint(x: 120.75, y: 63.22), controlPoint2: CGPoint(x: 122.62, y: 74.02))
        bezierPath.addLine(to: CGPoint(x: 122.62, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 105.38, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 69.82))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 59.77))
        bezierPath.addLine(to: CGPoint(x: 93.23, y: 59.25))
        bezierPath.addCurve(to: CGPoint(x: 114.75, y: 55.2), controlPoint1: CGPoint(x: 98.7, y: 58.65), controlPoint2: CGPoint(x: 111.15, y: 56.32))
        bezierPath.addCurve(to: CGPoint(x: 117.53, y: 54.45), controlPoint1: CGPoint(x: 116.03, y: 54.82), controlPoint2: CGPoint(x: 117.23, y: 54.45))
        bezierPath.addCurve(to: CGPoint(x: 119.25, y: 58.27), controlPoint1: CGPoint(x: 117.83, y: 54.37), controlPoint2: CGPoint(x: 118.58, y: 56.17))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 62.25, y: 57.22))
        bezierPath.addCurve(to: CGPoint(x: 74.85, y: 59.25), controlPoint1: CGPoint(x: 66.38, y: 58.05), controlPoint2: CGPoint(x: 72, y: 58.95))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 59.77))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 69.82))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 79.87))
        bezierPath.addLine(to: CGPoint(x: 63, y: 79.87))
        bezierPath.addCurve(to: CGPoint(x: 46.12, y: 78.9), controlPoint1: CGPoint(x: 50.03, y: 79.87), controlPoint2: CGPoint(x: 46.12, y: 79.65))
        bezierPath.addCurve(to: CGPoint(x: 49.58, y: 58.95), controlPoint1: CGPoint(x: 46.12, y: 76.42), controlPoint2: CGPoint(x: 48.53, y: 62.55))
        bezierPath.addCurve(to: CGPoint(x: 52.73, y: 55.35), controlPoint1: CGPoint(x: 50.62, y: 55.2), controlPoint2: CGPoint(x: 50.85, y: 54.97))
        bezierPath.addCurve(to: CGPoint(x: 62.25, y: 57.22), controlPoint1: CGPoint(x: 53.85, y: 55.57), controlPoint2: CGPoint(x: 58.12, y: 56.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 38.85, y: 94.27))
        bezierPath.addCurve(to: CGPoint(x: 43.5, y: 116.77), controlPoint1: CGPoint(x: 39.23, y: 99.6), controlPoint2: CGPoint(x: 42, y: 112.87))
        bezierPath.addCurve(to: CGPoint(x: 37.43, y: 121.05), controlPoint1: CGPoint(x: 43.88, y: 117.75), controlPoint2: CGPoint(x: 42.68, y: 118.65))
        bezierPath.addCurve(to: CGPoint(x: 27.23, y: 126.37), controlPoint1: CGPoint(x: 33.83, y: 122.77), controlPoint2: CGPoint(x: 29.25, y: 125.17))
        bezierPath.addCurve(to: CGPoint(x: 22.88, y: 128.62), controlPoint1: CGPoint(x: 25.28, y: 127.65), controlPoint2: CGPoint(x: 23.25, y: 128.62))
        bezierPath.addCurve(to: CGPoint(x: 13.95, y: 114), controlPoint1: CGPoint(x: 21.68, y: 128.62), controlPoint2: CGPoint(x: 16.43, y: 119.92))
        bezierPath.addCurve(to: CGPoint(x: 8.25, y: 92.77), controlPoint1: CGPoint(x: 11.25, y: 107.62), controlPoint2: CGPoint(x: 9, y: 99.15))
        bezierPath.addLine(to: CGPoint(x: 7.72, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 23.1, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 38.4, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 38.85, y: 94.27))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 79.88, y: 99.3))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 110.47))
        bezierPath.addLine(to: CGPoint(x: 77.1, y: 110.92))
        bezierPath.addCurve(to: CGPoint(x: 69.75, y: 111.75), controlPoint1: CGPoint(x: 75.53, y: 111.15), controlPoint2: CGPoint(x: 72.23, y: 111.52))
        bezierPath.addCurve(to: CGPoint(x: 59.03, y: 113.7), controlPoint1: CGPoint(x: 67.28, y: 112.05), controlPoint2: CGPoint(x: 62.48, y: 112.87))
        bezierPath.addCurve(to: CGPoint(x: 52.12, y: 115.12), controlPoint1: CGPoint(x: 55.58, y: 114.45), controlPoint2: CGPoint(x: 52.43, y: 115.12))
        bezierPath.addCurve(to: CGPoint(x: 46.5, y: 92.02), controlPoint1: CGPoint(x: 50.85, y: 115.12), controlPoint2: CGPoint(x: 47.62, y: 101.85))
        bezierPath.addLine(to: CGPoint(x: 46.05, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 63, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 99.3))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 122.62, y: 90.67))
        bezierPath.addCurve(to: CGPoint(x: 118.88, y: 110.92), controlPoint1: CGPoint(x: 122.62, y: 94.42), controlPoint2: CGPoint(x: 120.6, y: 105.15))
        bezierPath.addCurve(to: CGPoint(x: 116.03, y: 115.5), controlPoint1: CGPoint(x: 117.53, y: 115.12), controlPoint2: CGPoint(x: 117.08, y: 115.87))
        bezierPath.addCurve(to: CGPoint(x: 95.18, y: 111.37), controlPoint1: CGPoint(x: 113.78, y: 114.6), controlPoint2: CGPoint(x: 97.58, y: 111.37))
        bezierPath.addCurve(to: CGPoint(x: 90.45, y: 110.92), controlPoint1: CGPoint(x: 93.9, y: 111.37), controlPoint2: CGPoint(x: 91.73, y: 111.15))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 110.4))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 99.3))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 105.38, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 122.62, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 122.62, y: 90.67))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 159.75, y: 92.4))
        bezierPath.addCurve(to: CGPoint(x: 154.43, y: 112.87), controlPoint1: CGPoint(x: 159.07, y: 98.4), controlPoint2: CGPoint(x: 156.82, y: 107.1))
        bezierPath.addCurve(to: CGPoint(x: 145.57, y: 128.32), controlPoint1: CGPoint(x: 152.03, y: 118.72), controlPoint2: CGPoint(x: 146.85, y: 127.8))
        bezierPath.addCurve(to: CGPoint(x: 138.75, y: 125.25), controlPoint1: CGPoint(x: 145.12, y: 128.47), controlPoint2: CGPoint(x: 142.05, y: 127.12))
        bezierPath.addCurve(to: CGPoint(x: 128.85, y: 120.22), controlPoint1: CGPoint(x: 135.45, y: 123.37), controlPoint2: CGPoint(x: 131.02, y: 121.12))
        bezierPath.addCurve(to: CGPoint(x: 125.25, y: 117.45), controlPoint1: CGPoint(x: 125.85, y: 119.02), controlPoint2: CGPoint(x: 124.95, y: 118.27))
        bezierPath.addCurve(to: CGPoint(x: 130.2, y: 95.55), controlPoint1: CGPoint(x: 126.83, y: 113.47), controlPoint2: CGPoint(x: 129.45, y: 101.85))
        bezierPath.addLine(to: CGPoint(x: 131.1, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 145.73, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 160.28, y: 88.12))
        bezierPath.addLine(to: CGPoint(x: 159.75, y: 92.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 79.88, y: 139.28))
        bezierPath.addLine(to: CGPoint(x: 79.8, y: 159.75))
        bezierPath.addLine(to: CGPoint(x: 77.55, y: 157.12))
        bezierPath.addCurve(to: CGPoint(x: 63.68, y: 139.5), controlPoint1: CGPoint(x: 70.58, y: 149.25), controlPoint2: CGPoint(x: 67.2, y: 144.9))
        bezierPath.addCurve(to: CGPoint(x: 55.12, y: 123.45), controlPoint1: CGPoint(x: 59.78, y: 133.42), controlPoint2: CGPoint(x: 55.12, y: 124.72))
        bezierPath.addCurve(to: CGPoint(x: 77.48, y: 118.95), controlPoint1: CGPoint(x: 55.12, y: 122.32), controlPoint2: CGPoint(x: 70.58, y: 119.25))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 118.87))
        bezierPath.addLine(to: CGPoint(x: 79.88, y: 139.28))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 99, y: 120))
        bezierPath.addCurve(to: CGPoint(x: 110.4, y: 122.25), controlPoint1: CGPoint(x: 103.12, y: 120.6), controlPoint2: CGPoint(x: 108.3, y: 121.65))
        bezierPath.addLine(to: CGPoint(x: 114.38, y: 123.45))
        bezierPath.addLine(to: CGPoint(x: 111.68, y: 128.85))
        bezierPath.addCurve(to: CGPoint(x: 90.08, y: 158.55), controlPoint1: CGPoint(x: 106.95, y: 138.07), controlPoint2: CGPoint(x: 96.38, y: 152.7))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 160.35))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 139.65))
        bezierPath.addLine(to: CGPoint(x: 88.12, y: 118.87))
        bezierPath.addLine(to: CGPoint(x: 89.85, y: 118.87))
        bezierPath.addCurve(to: CGPoint(x: 99, y: 120), controlPoint1: CGPoint(x: 90.75, y: 118.87), controlPoint2: CGPoint(x: 94.88, y: 119.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 49.95, y: 131.77))
        bezierPath.addCurve(to: CGPoint(x: 63.45, y: 153.07), controlPoint1: CGPoint(x: 53.7, y: 139.27), controlPoint2: CGPoint(x: 58.5, y: 146.85))
        bezierPath.addCurve(to: CGPoint(x: 67.12, y: 158.1), controlPoint1: CGPoint(x: 65.48, y: 155.62), controlPoint2: CGPoint(x: 67.12, y: 157.88))
        bezierPath.addCurve(to: CGPoint(x: 50.93, y: 152.55), controlPoint1: CGPoint(x: 67.12, y: 158.85), controlPoint2: CGPoint(x: 56.78, y: 155.32))
        bezierPath.addCurve(to: CGPoint(x: 30.45, y: 138.15), controlPoint1: CGPoint(x: 44.48, y: 149.55), controlPoint2: CGPoint(x: 34.73, y: 142.65))
        bezierPath.addLine(to: CGPoint(x: 27.98, y: 135.53))
        bezierPath.addLine(to: CGPoint(x: 31.2, y: 133.42))
        bezierPath.addCurve(to: CGPoint(x: 46.65, y: 125.62), controlPoint1: CGPoint(x: 33.83, y: 131.77), controlPoint2: CGPoint(x: 45.83, y: 125.77))
        bezierPath.addCurve(to: CGPoint(x: 49.95, y: 131.77), controlPoint1: CGPoint(x: 46.8, y: 125.62), controlPoint2: CGPoint(x: 48.23, y: 128.4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 129.75, y: 129.6))
        bezierPath.addCurve(to: CGPoint(x: 137.1, y: 133.65), controlPoint1: CGPoint(x: 132.15, y: 130.8), controlPoint2: CGPoint(x: 135.53, y: 132.67))
        bezierPath.addLine(to: CGPoint(x: 140.03, y: 135.53))
        bezierPath.addLine(to: CGPoint(x: 137.93, y: 137.78))
        bezierPath.addCurve(to: CGPoint(x: 104.03, y: 157.5), controlPoint1: CGPoint(x: 129.9, y: 146.18), controlPoint2: CGPoint(x: 114.08, y: 155.4))
        bezierPath.addLine(to: CGPoint(x: 101.48, y: 158.03))
        bezierPath.addLine(to: CGPoint(x: 105.08, y: 153.6))
        bezierPath.addCurve(to: CGPoint(x: 119.18, y: 131.77), controlPoint1: CGPoint(x: 109.8, y: 147.82), controlPoint2: CGPoint(x: 115.8, y: 138.52))
        bezierPath.addCurve(to: CGPoint(x: 129.75, y: 129.6), controlPoint1: CGPoint(x: 122.33, y: 125.55), controlPoint2: CGPoint(x: 121.88, y: 125.62))
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

