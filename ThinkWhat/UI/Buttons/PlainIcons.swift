//
//  CategoryPlainIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CategoryPlainIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawCategory(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class PrivacyPlainIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawPrivacy(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class AnonPlainIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawAnon(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class CapacityPlainIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawCapacity(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class FilmIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawFilm(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class ManTalikngIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawManTalking(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class SurveysIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawSurveys(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class VotesIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawVotes(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class FavoriteIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawFavorite(frame: rect, resizing: .aspectFit)
    }
}

@IBDesignable
class NotificationIcon: UIView {
    override func draw(_ rect: CGRect) {
        PlainIconsStyleKit.drawNotification(frame: rect, resizing: .aspectFit)
    }
}

public class PlainIconsStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawCategory(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: -1, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 150.84, y: 113.61))
        bezierPath.addCurve(to: CGPoint(x: 112.83, y: 152.54), controlPoint1: CGPoint(x: 132.32, y: 117.57), controlPoint2: CGPoint(x: 116.28, y: 134.04))
        bezierPath.addCurve(to: CGPoint(x: 111.76, y: 192.11), controlPoint1: CGPoint(x: 112.3, y: 155.64), controlPoint2: CGPoint(x: 111.76, y: 173.5))
        bezierPath.addCurve(to: CGPoint(x: 117.57, y: 243.45), controlPoint1: CGPoint(x: 111.76, y: 228.59), controlPoint2: CGPoint(x: 112.3, y: 232.97))
        bezierPath.addCurve(to: CGPoint(x: 137.7, y: 263.88), controlPoint1: CGPoint(x: 121.55, y: 251.15), controlPoint2: CGPoint(x: 130.06, y: 259.82))
        bezierPath.addCurve(to: CGPoint(x: 191.43, y: 270.3), controlPoint1: CGPoint(x: 149.22, y: 269.98), controlPoint2: CGPoint(x: 151.81, y: 270.3))
        bezierPath.addCurve(to: CGPoint(x: 232.99, y: 268.8), controlPoint1: CGPoint(x: 218.56, y: 270.3), controlPoint2: CGPoint(x: 228.9, y: 269.87))
        bezierPath.addCurve(to: CGPoint(x: 269.59, y: 232.54), controlPoint1: CGPoint(x: 250.86, y: 264.09), controlPoint2: CGPoint(x: 264.86, y: 250.19))
        bezierPath.addCurve(to: CGPoint(x: 269.48, y: 150.19), controlPoint1: CGPoint(x: 271.85, y: 224.2), controlPoint2: CGPoint(x: 271.75, y: 158.75))
        bezierPath.addCurve(to: CGPoint(x: 229.65, y: 113.08), controlPoint1: CGPoint(x: 264.53, y: 131.04), controlPoint2: CGPoint(x: 248.38, y: 116.07))
        bezierPath.addCurve(to: CGPoint(x: 150.84, y: 113.61), controlPoint1: CGPoint(x: 219.64, y: 111.47), controlPoint2: CGPoint(x: 158.91, y: 111.9))
        bezierPath.close()
        UIColor.white.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 149.98, y: 282.49))
        bezier2Path.addCurve(to: CGPoint(x: 113.37, y: 319.18), controlPoint1: CGPoint(x: 132.43, y: 286.77), controlPoint2: CGPoint(x: 118.11, y: 301.1))
        bezier2Path.addCurve(to: CGPoint(x: 113.37, y: 401.1), controlPoint1: CGPoint(x: 111, y: 328.05), controlPoint2: CGPoint(x: 111, y: 392.23))
        bezier2Path.addCurve(to: CGPoint(x: 149.98, y: 437.68), controlPoint1: CGPoint(x: 118.11, y: 419.39), controlPoint2: CGPoint(x: 131.68, y: 432.87))
        bezier2Path.addCurve(to: CGPoint(x: 232.88, y: 437.68), controlPoint1: CGPoint(x: 159.24, y: 440.03), controlPoint2: CGPoint(x: 223.62, y: 440.03))
        bezier2Path.addCurve(to: CGPoint(x: 269.59, y: 401.53), controlPoint1: CGPoint(x: 251.07, y: 432.98), controlPoint2: CGPoint(x: 264.75, y: 419.5))
        bezier2Path.addCurve(to: CGPoint(x: 269.92, y: 320.35), controlPoint1: CGPoint(x: 271.53, y: 394.47), controlPoint2: CGPoint(x: 271.75, y: 329.12))
        bezier2Path.addCurve(to: CGPoint(x: 231.48, y: 282.17), controlPoint1: CGPoint(x: 266.04, y: 301.96), controlPoint2: CGPoint(x: 250, y: 286.02))
        bezier2Path.addCurve(to: CGPoint(x: 149.98, y: 282.49), controlPoint1: CGPoint(x: 223.4, y: 280.46), controlPoint2: CGPoint(x: 157.08, y: 280.78))
        bezier2Path.close()
        UIColor.white.setFill()
        bezier2Path.fill()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 320.62, y: 282.17))
        bezier3Path.addCurve(to: CGPoint(x: 288.65, y: 305.81), controlPoint1: CGPoint(x: 308.78, y: 284.42), controlPoint2: CGPoint(x: 295.75, y: 294.04))
        bezier3Path.addCurve(to: CGPoint(x: 281.87, y: 360.14), controlPoint1: CGPoint(x: 282.4, y: 316.07), controlPoint2: CGPoint(x: 281.87, y: 320.25))
        bezier3Path.addCurve(to: CGPoint(x: 283.05, y: 400.68), controlPoint1: CGPoint(x: 281.87, y: 380.35), controlPoint2: CGPoint(x: 282.4, y: 398))
        bezier3Path.addCurve(to: CGPoint(x: 321.49, y: 438.11), controlPoint1: CGPoint(x: 287.14, y: 418.43), controlPoint2: CGPoint(x: 303.51, y: 434.37))
        bezier3Path.addCurve(to: CGPoint(x: 361.86, y: 439.29), controlPoint1: CGPoint(x: 324.93, y: 438.86), controlPoint2: CGPoint(x: 340.65, y: 439.29))
        bezier3Path.addCurve(to: CGPoint(x: 415.58, y: 432.65), controlPoint1: CGPoint(x: 400.19, y: 439.29), controlPoint2: CGPoint(x: 403.96, y: 438.86))
        bezier3Path.addCurve(to: CGPoint(x: 435.39, y: 412.44), controlPoint1: CGPoint(x: 422.91, y: 428.8), controlPoint2: CGPoint(x: 431.52, y: 419.93))
        bezier3Path.addCurve(to: CGPoint(x: 441.21, y: 361.1), controlPoint1: CGPoint(x: 440.67, y: 401.96), controlPoint2: CGPoint(x: 441.21, y: 397.57))
        bezier3Path.addCurve(to: CGPoint(x: 440.13, y: 321.53), controlPoint1: CGPoint(x: 441.21, y: 342.49), controlPoint2: CGPoint(x: 440.67, y: 324.74))
        bezier3Path.addCurve(to: CGPoint(x: 401.59, y: 282.17), controlPoint1: CGPoint(x: 436.47, y: 302.49), controlPoint2: CGPoint(x: 420.43, y: 286.13))
        bezier3Path.addCurve(to: CGPoint(x: 320.62, y: 282.17), controlPoint1: CGPoint(x: 394.81, y: 280.78), controlPoint2: CGPoint(x: 327.95, y: 280.78))
        bezier3Path.close()
        UIColor.white.setFill()
        bezier3Path.fill()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 320.62, y: 112.47))
        bezier4Path.addCurve(to: CGPoint(x: 288.65, y: 136.11), controlPoint1: CGPoint(x: 308.78, y: 114.72), controlPoint2: CGPoint(x: 295.75, y: 124.34))
        bezier4Path.addCurve(to: CGPoint(x: 281.87, y: 190.44), controlPoint1: CGPoint(x: 282.4, y: 146.37), controlPoint2: CGPoint(x: 281.87, y: 150.55))
        bezier4Path.addCurve(to: CGPoint(x: 283.05, y: 230.97), controlPoint1: CGPoint(x: 281.87, y: 210.65), controlPoint2: CGPoint(x: 282.4, y: 228.3))
        bezier4Path.addCurve(to: CGPoint(x: 321.49, y: 268.41), controlPoint1: CGPoint(x: 287.14, y: 248.73), controlPoint2: CGPoint(x: 303.51, y: 264.67))
        bezier4Path.addCurve(to: CGPoint(x: 361.86, y: 269.59), controlPoint1: CGPoint(x: 324.93, y: 269.16), controlPoint2: CGPoint(x: 340.65, y: 269.59))
        bezier4Path.addCurve(to: CGPoint(x: 415.58, y: 262.95), controlPoint1: CGPoint(x: 400.19, y: 269.59), controlPoint2: CGPoint(x: 403.96, y: 269.16))
        bezier4Path.addCurve(to: CGPoint(x: 435.39, y: 242.74), controlPoint1: CGPoint(x: 422.91, y: 259.1), controlPoint2: CGPoint(x: 431.52, y: 250.23))
        bezier4Path.addCurve(to: CGPoint(x: 441.21, y: 191.4), controlPoint1: CGPoint(x: 440.67, y: 232.26), controlPoint2: CGPoint(x: 441.21, y: 227.87))
        bezier4Path.addCurve(to: CGPoint(x: 440.13, y: 151.83), controlPoint1: CGPoint(x: 441.21, y: 172.79), controlPoint2: CGPoint(x: 440.67, y: 155.04))
        bezier4Path.addCurve(to: CGPoint(x: 401.59, y: 112.47), controlPoint1: CGPoint(x: 436.47, y: 132.79), controlPoint2: CGPoint(x: 420.43, y: 116.43))
        bezier4Path.addCurve(to: CGPoint(x: 320.62, y: 112.47), controlPoint1: CGPoint(x: 394.81, y: 111.08), controlPoint2: CGPoint(x: 327.95, y: 111.08))
        bezier4Path.close()
        UIColor.white.setFill()
        bezier4Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawPrivacy(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 257.59, y: 97.58))
        bezierPath.addCurve(to: CGPoint(x: 181.79, y: 145.15), controlPoint1: CGPoint(x: 227.17, y: 102.7), controlPoint2: CGPoint(x: 199.86, y: 119.81))
        bezierPath.addCurve(to: CGPoint(x: 162.55, y: 188.43), controlPoint1: CGPoint(x: 172.71, y: 157.9), controlPoint2: CGPoint(x: 166.08, y: 172.83))
        bezierPath.addCurve(to: CGPoint(x: 160.45, y: 236.34), controlPoint1: CGPoint(x: 160.87, y: 195.99), controlPoint2: CGPoint(x: 160.7, y: 199.26))
        bezierPath.addLine(to: CGPoint(x: 160.11, y: 276.1))
        bezierPath.addLine(to: CGPoint(x: 164.06, y: 275.52))
        bezierPath.addCurve(to: CGPoint(x: 191.37, y: 275.01), controlPoint1: CGPoint(x: 166.24, y: 275.26), controlPoint2: CGPoint(x: 178.51, y: 275.01))
        bezierPath.addLine(to: CGPoint(x: 214.73, y: 275.01))
        bezierPath.addLine(to: CGPoint(x: 214.98, y: 237.85))
        bezierPath.addLine(to: CGPoint(x: 215.24, y: 200.77))
        bezierPath.addLine(to: CGPoint(x: 217.59, y: 194.06))
        bezierPath.addCurve(to: CGPoint(x: 249.69, y: 157.14), controlPoint1: CGPoint(x: 223.22, y: 177.44), controlPoint2: CGPoint(x: 234.15, y: 164.86))
        bezierPath.addCurve(to: CGPoint(x: 277, y: 150.85), controlPoint1: CGPoint(x: 258.77, y: 152.61), controlPoint2: CGPoint(x: 266.33, y: 150.85))
        bezierPath.addCurve(to: CGPoint(x: 304.32, y: 157.14), controlPoint1: CGPoint(x: 287.68, y: 150.85), controlPoint2: CGPoint(x: 295.24, y: 152.61))
        bezierPath.addCurve(to: CGPoint(x: 336.42, y: 194.06), controlPoint1: CGPoint(x: 319.86, y: 164.86), controlPoint2: CGPoint(x: 330.79, y: 177.44))
        bezierPath.addLine(to: CGPoint(x: 338.77, y: 200.77))
        bezierPath.addLine(to: CGPoint(x: 339.02, y: 237.85))
        bezierPath.addLine(to: CGPoint(x: 339.27, y: 275.01))
        bezierPath.addLine(to: CGPoint(x: 362.64, y: 275.01))
        bezierPath.addCurve(to: CGPoint(x: 389.95, y: 275.52), controlPoint1: CGPoint(x: 375.49, y: 275.01), controlPoint2: CGPoint(x: 387.76, y: 275.26))
        bezierPath.addLine(to: CGPoint(x: 393.9, y: 276.1))
        bezierPath.addLine(to: CGPoint(x: 393.56, y: 236.34))
        bezierPath.addCurve(to: CGPoint(x: 391.46, y: 188.43), controlPoint1: CGPoint(x: 393.31, y: 199.26), controlPoint2: CGPoint(x: 393.14, y: 195.99))
        bezierPath.addCurve(to: CGPoint(x: 295.91, y: 97.58), controlPoint1: CGPoint(x: 380.79, y: 140.95), controlPoint2: CGPoint(x: 343.31, y: 105.3))
        bezierPath.addCurve(to: CGPoint(x: 257.59, y: 97.58), controlPoint1: CGPoint(x: 286.75, y: 96.07), controlPoint2: CGPoint(x: 266.5, y: 96.07))
        bezierPath.close()
        UIColor.white.setFill()
        bezierPath.fill()
        
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 113, y: 229, width: 328, height: 228), cornerRadius: 40)
        UIColor.white.setFill()
        rectanglePath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 269.79, y: 289.21))
        bezier2Path.addCurve(to: CGPoint(x: 242.82, y: 322.58), controlPoint1: CGPoint(x: 254.25, y: 292.55), controlPoint2: CGPoint(x: 242.82, y: 306.7))
        bezier2Path.addCurve(to: CGPoint(x: 257.91, y: 350.87), controlPoint1: CGPoint(x: 242.82, y: 333.89), controlPoint2: CGPoint(x: 248.53, y: 344.63))
        bezier2Path.addCurve(to: CGPoint(x: 261.44, y: 354.34), controlPoint1: CGPoint(x: 260.03, y: 352.22), controlPoint2: CGPoint(x: 261.44, y: 353.63))
        bezier2Path.addCurve(to: CGPoint(x: 258.81, y: 373.7), controlPoint1: CGPoint(x: 261.44, y: 354.98), controlPoint2: CGPoint(x: 260.29, y: 363.67))
        bezier2Path.addCurve(to: CGPoint(x: 259.77, y: 396.91), controlPoint1: CGPoint(x: 255.92, y: 393.82), controlPoint2: CGPoint(x: 255.98, y: 394.59))
        bezier2Path.addCurve(to: CGPoint(x: 276.41, y: 398.13), controlPoint1: CGPoint(x: 261.57, y: 398), controlPoint2: CGPoint(x: 263.24, y: 398.13))
        bezier2Path.addCurve(to: CGPoint(x: 296.51, y: 394.08), controlPoint1: CGPoint(x: 292.98, y: 398.13), controlPoint2: CGPoint(x: 294.78, y: 397.74))
        bezier2Path.addCurve(to: CGPoint(x: 294.91, y: 373.31), controlPoint1: CGPoint(x: 297.54, y: 391.96), controlPoint2: CGPoint(x: 297.48, y: 391.06))
        bezier2Path.addCurve(to: CGPoint(x: 292.27, y: 353.96), controlPoint1: CGPoint(x: 293.49, y: 363.09), controlPoint2: CGPoint(x: 292.27, y: 354.41))
        bezier2Path.addCurve(to: CGPoint(x: 295.81, y: 350.87), controlPoint1: CGPoint(x: 292.27, y: 353.51), controlPoint2: CGPoint(x: 293.88, y: 352.16))
        bezier2Path.addCurve(to: CGPoint(x: 300.62, y: 298.4), controlPoint1: CGPoint(x: 313.73, y: 338.91), controlPoint2: CGPoint(x: 316.1, y: 313.58))
        bezier2Path.addCurve(to: CGPoint(x: 283.6, y: 289.14), controlPoint1: CGPoint(x: 295.61, y: 293.45), controlPoint2: CGPoint(x: 290.28, y: 290.56))
        bezier2Path.addCurve(to: CGPoint(x: 269.79, y: 289.21), controlPoint1: CGPoint(x: 278.14, y: 287.98), controlPoint2: CGPoint(x: 275.25, y: 287.98))
        bezier2Path.close()
        color4.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawAnon(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: -1, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 192.95, y: 134.62))
        bezierPath.addCurve(to: CGPoint(x: 167.53, y: 198.67), controlPoint1: CGPoint(x: 181.42, y: 141.02), controlPoint2: CGPoint(x: 178.87, y: 147.63))
        bezierPath.addLine(to: CGPoint(x: 156.97, y: 246.82))
        bezierPath.addLine(to: CGPoint(x: 150.12, y: 245.38))
        bezierPath.addCurve(to: CGPoint(x: 142.5, y: 243.52), controlPoint1: CGPoint(x: 146.21, y: 244.55), controlPoint2: CGPoint(x: 142.89, y: 243.72))
        bezierPath.addCurve(to: CGPoint(x: 144.84, y: 230.08), controlPoint1: CGPoint(x: 142.3, y: 243.1), controlPoint2: CGPoint(x: 143.28, y: 237.11))
        bezierPath.addCurve(to: CGPoint(x: 127.05, y: 222.65), controlPoint1: CGPoint(x: 148.17, y: 215), controlPoint2: CGPoint(x: 148.75, y: 215.41))
        bezierPath.addCurve(to: CGPoint(x: 109.25, y: 272.03), controlPoint1: CGPoint(x: 85.19, y: 236.49), controlPoint2: CGPoint(x: 78.15, y: 255.91))
        bezierPath.addCurve(to: CGPoint(x: 182, y: 292.28), controlPoint1: CGPoint(x: 126.46, y: 280.92), controlPoint2: CGPoint(x: 145.43, y: 286.29))
        bezierPath.addCurve(to: CGPoint(x: 275.1, y: 296.83), controlPoint1: CGPoint(x: 206.25, y: 296.21), controlPoint2: CGPoint(x: 217.6, y: 296.83))
        bezierPath.addCurve(to: CGPoint(x: 410.04, y: 284.43), controlPoint1: CGPoint(x: 346.68, y: 297.04), controlPoint2: CGPoint(x: 370.15, y: 294.76))
        bezierPath.addCurve(to: CGPoint(x: 456.59, y: 264.18), controlPoint1: CGPoint(x: 433.51, y: 278.23), controlPoint2: CGPoint(x: 447.59, y: 272.24))
        bezierPath.addCurve(to: CGPoint(x: 444.66, y: 230.29), controlPoint1: CGPoint(x: 468.52, y: 253.43), controlPoint2: CGPoint(x: 463.63, y: 239.8))
        bezierPath.addCurve(to: CGPoint(x: 407.11, y: 217.89), controlPoint1: CGPoint(x: 435.08, y: 225.54), controlPoint2: CGPoint(x: 408.28, y: 216.65))
        bezierPath.addCurve(to: CGPoint(x: 411.22, y: 240.42), controlPoint1: CGPoint(x: 406.33, y: 218.51), controlPoint2: CGPoint(x: 408.87, y: 232.77))
        bezierPath.addCurve(to: CGPoint(x: 404.96, y: 245.17), controlPoint1: CGPoint(x: 411.8, y: 243.1), controlPoint2: CGPoint(x: 410.43, y: 244.14))
        bezierPath.addCurve(to: CGPoint(x: 397.14, y: 246), controlPoint1: CGPoint(x: 401.05, y: 246), controlPoint2: CGPoint(x: 397.53, y: 246.41))
        bezierPath.addCurve(to: CGPoint(x: 385.79, y: 197.02), controlPoint1: CGPoint(x: 396.74, y: 245.58), controlPoint2: CGPoint(x: 391.66, y: 223.47))
        bezierPath.addCurve(to: CGPoint(x: 360.37, y: 134), controlPoint1: CGPoint(x: 374.25, y: 146.19), controlPoint2: CGPoint(x: 371.71, y: 139.78))
        bezierPath.addCurve(to: CGPoint(x: 316.75, y: 136.27), controlPoint1: CGPoint(x: 350.98, y: 129.45), controlPoint2: CGPoint(x: 341.4, y: 129.86))
        bezierPath.addCurve(to: CGPoint(x: 237.35, y: 136.27), controlPoint1: CGPoint(x: 287.81, y: 143.71), controlPoint2: CGPoint(x: 265.9, y: 143.71))
        bezierPath.addCurve(to: CGPoint(x: 192.95, y: 134.62), controlPoint1: CGPoint(x: 212.32, y: 129.66), controlPoint2: CGPoint(x: 202.15, y: 129.24))
        bezierPath.close()
        UIColor.white.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 143.28, y: 308.61))
        bezier2Path.addCurve(to: CGPoint(x: 137.41, y: 354.69), controlPoint1: CGPoint(x: 142.69, y: 312.53), controlPoint2: CGPoint(x: 139.95, y: 333.2))
        bezier2Path.addCurve(to: CGPoint(x: 165.57, y: 415.65), controlPoint1: CGPoint(x: 130.76, y: 408.83), controlPoint2: CGPoint(x: 132.13, y: 411.72))
        bezier2Path.addCurve(to: CGPoint(x: 242.63, y: 419.16), controlPoint1: CGPoint(x: 192.56, y: 418.75), controlPoint2: CGPoint(x: 236.57, y: 420.81))
        bezier2Path.addCurve(to: CGPoint(x: 258.47, y: 407.59), controlPoint1: CGPoint(x: 245.37, y: 418.54), controlPoint2: CGPoint(x: 252.6, y: 413.17))
        bezier2Path.addCurve(to: CGPoint(x: 299.54, y: 407.59), controlPoint1: CGPoint(x: 275.49, y: 391.26), controlPoint2: CGPoint(x: 282.53, y: 391.26))
        bezier2Path.addCurve(to: CGPoint(x: 315.38, y: 419.16), controlPoint1: CGPoint(x: 305.41, y: 413.17), controlPoint2: CGPoint(x: 312.65, y: 418.54))
        bezier2Path.addCurve(to: CGPoint(x: 391.46, y: 415.65), controlPoint1: CGPoint(x: 321.45, y: 420.81), controlPoint2: CGPoint(x: 366.82, y: 418.75))
        bezier2Path.addCurve(to: CGPoint(x: 416.11, y: 348.9), controlPoint1: CGPoint(x: 422.95, y: 411.93), controlPoint2: CGPoint(x: 423.73, y: 409.66))
        bezier2Path.addCurve(to: CGPoint(x: 409.46, y: 302.82), controlPoint1: CGPoint(x: 412.98, y: 324.11), controlPoint2: CGPoint(x: 409.85, y: 303.44))
        bezier2Path.addCurve(to: CGPoint(x: 393.03, y: 305.1), controlPoint1: CGPoint(x: 408.87, y: 302.41), controlPoint2: CGPoint(x: 401.44, y: 303.24))
        bezier2Path.addCurve(to: CGPoint(x: 295.24, y: 313.98), controlPoint1: CGPoint(x: 364.67, y: 311.09), controlPoint2: CGPoint(x: 346.68, y: 312.74))
        bezier2Path.addCurve(to: CGPoint(x: 150.51, y: 303.03), controlPoint1: CGPoint(x: 233.05, y: 315.43), controlPoint2: CGPoint(x: 195.11, y: 312.53))
        bezier2Path.addCurve(to: CGPoint(x: 143.28, y: 308.61), controlPoint1: CGPoint(x: 144.65, y: 301.79), controlPoint2: CGPoint(x: 144.26, y: 302.2))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 225.42, y: 348.7))
        bezier2Path.addCurve(to: CGPoint(x: 245.17, y: 364.81), controlPoint1: CGPoint(x: 237.35, y: 352.42), controlPoint2: CGPoint(x: 246.93, y: 360.27))
        bezier2Path.addCurve(to: CGPoint(x: 233.63, y: 373.91), controlPoint1: CGPoint(x: 244.59, y: 366.67), controlPoint2: CGPoint(x: 239.31, y: 370.81))
        bezier2Path.addCurve(to: CGPoint(x: 189.04, y: 373.49), controlPoint1: CGPoint(x: 218.77, y: 381.97), controlPoint2: CGPoint(x: 203.71, y: 381.76))
        bezier2Path.addCurve(to: CGPoint(x: 184.94, y: 355.31), controlPoint1: CGPoint(x: 176.33, y: 366.05), controlPoint2: CGPoint(x: 175.16, y: 361.3))
        bezier2Path.addCurve(to: CGPoint(x: 225.42, y: 348.7), controlPoint1: CGPoint(x: 200.58, y: 345.39), controlPoint2: CGPoint(x: 210.36, y: 343.94))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 362.71, y: 351.59))
        bezier2Path.addCurve(to: CGPoint(x: 375.62, y: 365.02), controlPoint1: CGPoint(x: 372.49, y: 356.96), controlPoint2: CGPoint(x: 376.99, y: 361.51))
        bezier2Path.addCurve(to: CGPoint(x: 364.47, y: 373.7), controlPoint1: CGPoint(x: 375.03, y: 366.47), controlPoint2: CGPoint(x: 369.95, y: 370.39))
        bezier2Path.addCurve(to: CGPoint(x: 321.25, y: 374.53), controlPoint1: CGPoint(x: 350.78, y: 381.55), controlPoint2: CGPoint(x: 334.94, y: 381.97))
        bezier2Path.addCurve(to: CGPoint(x: 313.23, y: 356.76), controlPoint1: CGPoint(x: 307.56, y: 367.09), controlPoint2: CGPoint(x: 305.8, y: 363.16))
        bezier2Path.addCurve(to: CGPoint(x: 362.71, y: 351.59), controlPoint1: CGPoint(x: 326.73, y: 345.18), controlPoint2: CGPoint(x: 346.87, y: 343.12))
        bezier2Path.close()
        UIColor.white.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawCapacity(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: -1, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 268.38, y: 113.53))
        bezierPath.addCurve(to: CGPoint(x: 261.76, y: 114.06), controlPoint1: CGPoint(x: 267.66, y: 113.6), controlPoint2: CGPoint(x: 264.67, y: 113.87))
        bezierPath.addCurve(to: CGPoint(x: 154.65, y: 159.16), controlPoint1: CGPoint(x: 223.15, y: 117.04), controlPoint2: CGPoint(x: 183.56, y: 133.68))
        bezierPath.addCurve(to: CGPoint(x: 92.99, y: 270.99), controlPoint1: CGPoint(x: 121.95, y: 187.93), controlPoint2: CGPoint(x: 99.92, y: 227.89))
        bezierPath.addCurve(to: CGPoint(x: 91.22, y: 308.38), controlPoint1: CGPoint(x: 91.18, y: 282.18), controlPoint2: CGPoint(x: 90.46, y: 297.38))
        bezierPath.addCurve(to: CGPoint(x: 135.95, y: 419.34), controlPoint1: CGPoint(x: 94.13, y: 351.48), controlPoint2: CGPoint(x: 109.16, y: 388.75))
        bezierPath.addCurve(to: CGPoint(x: 152.3, y: 435.75), controlPoint1: CGPoint(x: 141.44, y: 425.58), controlPoint2: CGPoint(x: 149.96, y: 434.12))
        bezierPath.addCurve(to: CGPoint(x: 156.5, y: 436.84), controlPoint1: CGPoint(x: 154.01, y: 436.92), controlPoint2: CGPoint(x: 154.35, y: 436.99))
        bezierPath.addCurve(to: CGPoint(x: 173.04, y: 423.5), controlPoint1: CGPoint(x: 160.89, y: 436.58), controlPoint2: CGPoint(x: 164.53, y: 433.63))
        bezierPath.addCurve(to: CGPoint(x: 194.84, y: 399.91), controlPoint1: CGPoint(x: 177.89, y: 417.75), controlPoint2: CGPoint(x: 181.75, y: 413.59))
        bezierPath.addCurve(to: CGPoint(x: 208.73, y: 379.83), controlPoint1: CGPoint(x: 208.09, y: 386.07), controlPoint2: CGPoint(x: 208.77, y: 385.09))
        bezierPath.addCurve(to: CGPoint(x: 202.75, y: 367.96), controlPoint1: CGPoint(x: 208.7, y: 374.73), controlPoint2: CGPoint(x: 206.77, y: 370.95))
        bezierPath.addCurve(to: CGPoint(x: 190.41, y: 365.47), controlPoint1: CGPoint(x: 199.61, y: 365.65), controlPoint2: CGPoint(x: 194.24, y: 364.56))
        bezierPath.addCurve(to: CGPoint(x: 172.17, y: 381.31), controlPoint1: CGPoint(x: 187.77, y: 366.11), controlPoint2: CGPoint(x: 185.76, y: 367.85))
        bezierPath.addLine(to: CGPoint(x: 161.27, y: 392.04))
        bezierPath.addLine(to: CGPoint(x: 159.68, y: 390.23))
        bezierPath.addCurve(to: CGPoint(x: 152.83, y: 380.93), controlPoint1: CGPoint(x: 157.26, y: 387.47), controlPoint2: CGPoint(x: 155.94, y: 385.65))
        bezierPath.addCurve(to: CGPoint(x: 131.94, y: 332.95), controlPoint1: CGPoint(x: 142.88, y: 365.62), controlPoint2: CGPoint(x: 136.22, y: 350.31))
        bezierPath.addCurve(to: CGPoint(x: 128.5, y: 313.78), controlPoint1: CGPoint(x: 131.07, y: 329.4), controlPoint2: CGPoint(x: 128.31, y: 313.97))
        bezierPath.addCurve(to: CGPoint(x: 143.67, y: 313.29), controlPoint1: CGPoint(x: 128.53, y: 313.75), controlPoint2: CGPoint(x: 135.38, y: 313.52))
        bezierPath.addCurve(to: CGPoint(x: 167.74, y: 310.31), controlPoint1: CGPoint(x: 162.14, y: 312.8), controlPoint2: CGPoint(x: 164.26, y: 312.54))
        bezierPath.addCurve(to: CGPoint(x: 174.52, y: 298.51), controlPoint1: CGPoint(x: 170.81, y: 308.38), controlPoint2: CGPoint(x: 174.52, y: 301.91))
        bezierPath.addCurve(to: CGPoint(x: 171.57, y: 290.38), controlPoint1: CGPoint(x: 174.52, y: 296.7), controlPoint2: CGPoint(x: 173.04, y: 292.69))
        bezierPath.addCurve(to: CGPoint(x: 166.08, y: 285.32), controlPoint1: CGPoint(x: 169.67, y: 287.55), controlPoint2: CGPoint(x: 168.35, y: 286.3))
        bezierPath.addCurve(to: CGPoint(x: 143.71, y: 283.16), controlPoint1: CGPoint(x: 162.26, y: 283.62), controlPoint2: CGPoint(x: 159.68, y: 283.35))
        bezierPath.addLine(to: CGPoint(x: 128.65, y: 282.97))
        bezierPath.addLine(to: CGPoint(x: 128.87, y: 280.63))
        bezierPath.addCurve(to: CGPoint(x: 138.3, y: 244.3), controlPoint1: CGPoint(x: 129.71, y: 273.26), controlPoint2: CGPoint(x: 135.08, y: 252.5))
        bezierPath.addCurve(to: CGPoint(x: 149.12, y: 222.82), controlPoint1: CGPoint(x: 140, y: 239.91), controlPoint2: CGPoint(x: 146.02, y: 228))
        bezierPath.addCurve(to: CGPoint(x: 155.29, y: 213.41), controlPoint1: CGPoint(x: 150.56, y: 220.4), controlPoint2: CGPoint(x: 153.36, y: 216.17))
        bezierPath.addCurve(to: CGPoint(x: 159.08, y: 208.04), controlPoint1: CGPoint(x: 157.22, y: 210.69), controlPoint2: CGPoint(x: 158.93, y: 208.27))
        bezierPath.addCurve(to: CGPoint(x: 169.22, y: 216.28), controlPoint1: CGPoint(x: 159.49, y: 207.4), controlPoint2: CGPoint(x: 162.03, y: 209.48))
        bezierPath.addCurve(to: CGPoint(x: 188.41, y: 231.29), controlPoint1: CGPoint(x: 183.38, y: 229.63), controlPoint2: CGPoint(x: 184.21, y: 230.31))
        bezierPath.addCurve(to: CGPoint(x: 197.23, y: 230.01), controlPoint1: CGPoint(x: 191.82, y: 232.12), controlPoint2: CGPoint(x: 193.4, y: 231.9))
        bezierPath.addCurve(to: CGPoint(x: 205.63, y: 218.67), controlPoint1: CGPoint(x: 201.85, y: 227.74), controlPoint2: CGPoint(x: 204.8, y: 223.81))
        bezierPath.addCurve(to: CGPoint(x: 196.28, y: 201.77), controlPoint1: CGPoint(x: 206.54, y: 213.37), controlPoint2: CGPoint(x: 205.14, y: 210.84))
        bezierPath.addCurve(to: CGPoint(x: 181.33, y: 185.66), controlPoint1: CGPoint(x: 187.08, y: 192.31), controlPoint2: CGPoint(x: 181.33, y: 186.15))
        bezierPath.addCurve(to: CGPoint(x: 189.58, y: 178.59), controlPoint1: CGPoint(x: 181.33, y: 184.94), controlPoint2: CGPoint(x: 184.96, y: 181.8))
        bezierPath.addCurve(to: CGPoint(x: 252.26, y: 152.43), controlPoint1: CGPoint(x: 209, y: 164.98), controlPoint2: CGPoint(x: 230.8, y: 155.91))
        bezierPath.addCurve(to: CGPoint(x: 260.21, y: 152.51), controlPoint1: CGPoint(x: 259.79, y: 151.22), controlPoint2: CGPoint(x: 259.9, y: 151.22))
        bezierPath.addCurve(to: CGPoint(x: 260.81, y: 167.74), controlPoint1: CGPoint(x: 260.32, y: 153.11), controlPoint2: CGPoint(x: 260.58, y: 159.95))
        bezierPath.addCurve(to: CGPoint(x: 261.61, y: 184.38), controlPoint1: CGPoint(x: 261, y: 175.53), controlPoint2: CGPoint(x: 261.38, y: 183.01))
        bezierPath.addCurve(to: CGPoint(x: 265.32, y: 190.92), controlPoint1: CGPoint(x: 262.06, y: 187.29), controlPoint2: CGPoint(x: 262.82, y: 188.57))
        bezierPath.addCurve(to: CGPoint(x: 288.55, y: 187.36), controlPoint1: CGPoint(x: 272.81, y: 197.91), controlPoint2: CGPoint(x: 284.24, y: 196.21))
        bezierPath.addCurve(to: CGPoint(x: 290.33, y: 164.11), controlPoint1: CGPoint(x: 289.99, y: 184.45), controlPoint2: CGPoint(x: 290.3, y: 180.29))
        bezierPath.addLine(to: CGPoint(x: 290.33, y: 150.84))
        bezierPath.addLine(to: CGPoint(x: 294.04, y: 151.33))
        bezierPath.addCurve(to: CGPoint(x: 352.21, y: 171.33), controlPoint1: CGPoint(x: 314.29, y: 154.13), controlPoint2: CGPoint(x: 336.2, y: 161.65))
        bezierPath.addCurve(to: CGPoint(x: 367.92, y: 182.86), controlPoint1: CGPoint(x: 359.41, y: 175.68), controlPoint2: CGPoint(x: 367.92, y: 181.92))
        bezierPath.addCurve(to: CGPoint(x: 358.8, y: 192.58), controlPoint1: CGPoint(x: 367.92, y: 183.01), controlPoint2: CGPoint(x: 363.83, y: 187.4))
        bezierPath.addCurve(to: CGPoint(x: 344, y: 213.67), controlPoint1: CGPoint(x: 344.87, y: 206.91), controlPoint2: CGPoint(x: 343.96, y: 208.23))
        bezierPath.addCurve(to: CGPoint(x: 354.45, y: 227.66), controlPoint1: CGPoint(x: 344.04, y: 220.52), controlPoint2: CGPoint(x: 348.01, y: 225.81))
        bezierPath.addCurve(to: CGPoint(x: 363.61, y: 227.13), controlPoint1: CGPoint(x: 357.25, y: 228.49), controlPoint2: CGPoint(x: 361.07, y: 228.23))
        bezierPath.addCurve(to: CGPoint(x: 379.54, y: 213.49), controlPoint1: CGPoint(x: 366.56, y: 225.81), controlPoint2: CGPoint(x: 368.68, y: 224))
        bezierPath.addLine(to: CGPoint(x: 390.02, y: 203.35))
        bezierPath.addLine(to: CGPoint(x: 392.07, y: 205.85))
        bezierPath.addCurve(to: CGPoint(x: 417.24, y: 252.27), controlPoint1: CGPoint(x: 401.49, y: 217.34), controlPoint2: CGPoint(x: 412.54, y: 237.68))
        bezierPath.addCurve(to: CGPoint(x: 423.18, y: 279.23), controlPoint1: CGPoint(x: 420.23, y: 261.42), controlPoint2: CGPoint(x: 423.18, y: 274.92))
        bezierPath.addLine(to: CGPoint(x: 423.18, y: 281.8))
        bezierPath.addLine(to: CGPoint(x: 415.72, y: 282.03))
        bezierPath.addCurve(to: CGPoint(x: 402.02, y: 282.29), controlPoint1: CGPoint(x: 411.64, y: 282.18), controlPoint2: CGPoint(x: 405.47, y: 282.29))
        bezierPath.addCurve(to: CGPoint(x: 386.35, y: 283.73), controlPoint1: CGPoint(x: 393.47, y: 282.33), controlPoint2: CGPoint(x: 388.51, y: 282.78))
        bezierPath.addCurve(to: CGPoint(x: 379.92, y: 290.53), controlPoint1: CGPoint(x: 383.93, y: 284.83), controlPoint2: CGPoint(x: 381.32, y: 287.55))
        bezierPath.addCurve(to: CGPoint(x: 378.75, y: 296.47), controlPoint1: CGPoint(x: 378.82, y: 292.8), controlPoint2: CGPoint(x: 378.71, y: 293.41))
        bezierPath.addCurve(to: CGPoint(x: 382.34, y: 306.3), controlPoint1: CGPoint(x: 378.78, y: 300.82), controlPoint2: CGPoint(x: 379.73, y: 303.43))
        bezierPath.addCurve(to: CGPoint(x: 391.2, y: 311.02), controlPoint1: CGPoint(x: 384.57, y: 308.72), controlPoint2: CGPoint(x: 387.87, y: 310.5))
        bezierPath.addCurve(to: CGPoint(x: 408.91, y: 311.4), controlPoint1: CGPoint(x: 392.45, y: 311.21), controlPoint2: CGPoint(x: 400.39, y: 311.4))
        bezierPath.addCurve(to: CGPoint(x: 424.31, y: 311.97), controlPoint1: CGPoint(x: 422.19, y: 311.4), controlPoint2: CGPoint(x: 424.31, y: 311.48))
        bezierPath.addCurve(to: CGPoint(x: 422.19, y: 325.96), controlPoint1: CGPoint(x: 424.31, y: 313.18), controlPoint2: CGPoint(x: 423.07, y: 321.35))
        bezierPath.addCurve(to: CGPoint(x: 395.36, y: 387.2), controlPoint1: CGPoint(x: 417.96, y: 347.96), controlPoint2: CGPoint(x: 409.06, y: 368.23))
        bezierPath.addCurve(to: CGPoint(x: 391.2, y: 391.93), controlPoint1: CGPoint(x: 392.94, y: 390.53), controlPoint2: CGPoint(x: 391.73, y: 391.93))
        bezierPath.addCurve(to: CGPoint(x: 378.25, y: 380.66), controlPoint1: CGPoint(x: 390.1, y: 391.93), controlPoint2: CGPoint(x: 388.06, y: 390.11))
        bezierPath.addCurve(to: CGPoint(x: 357.32, y: 366.41), controlPoint1: CGPoint(x: 364.82, y: 367.66), controlPoint2: CGPoint(x: 363, y: 366.45))
        bezierPath.addCurve(to: CGPoint(x: 347.1, y: 370.99), controlPoint1: CGPoint(x: 353.12, y: 366.41), controlPoint2: CGPoint(x: 350.74, y: 367.47))
        bezierPath.addCurve(to: CGPoint(x: 343.13, y: 381.38), controlPoint1: CGPoint(x: 343.62, y: 374.31), controlPoint2: CGPoint(x: 343.13, y: 375.64))
        bezierPath.addCurve(to: CGPoint(x: 344.11, y: 387.24), controlPoint1: CGPoint(x: 343.13, y: 385.46), controlPoint2: CGPoint(x: 343.21, y: 385.84))
        bezierPath.addCurve(to: CGPoint(x: 364.44, y: 409.24), controlPoint1: CGPoint(x: 345.74, y: 389.7), controlPoint2: CGPoint(x: 351.04, y: 395.45))
        bezierPath.addCurve(to: CGPoint(x: 381.36, y: 426.9), controlPoint1: CGPoint(x: 371.44, y: 416.47), controlPoint2: CGPoint(x: 379.09, y: 424.44))
        bezierPath.addCurve(to: CGPoint(x: 387.34, y: 433.25), controlPoint1: CGPoint(x: 383.67, y: 429.4), controlPoint2: CGPoint(x: 386.35, y: 432.27))
        bezierPath.addCurve(to: CGPoint(x: 395.78, y: 437.52), controlPoint1: CGPoint(x: 389.49, y: 435.41), controlPoint2: CGPoint(x: 393.13, y: 437.22))
        bezierPath.addCurve(to: CGPoint(x: 399.49, y: 436.5), controlPoint1: CGPoint(x: 397.44, y: 437.71), controlPoint2: CGPoint(x: 397.82, y: 437.6))
        bezierPath.addCurve(to: CGPoint(x: 424.65, y: 409.93), controlPoint1: CGPoint(x: 403.65, y: 433.7), controlPoint2: CGPoint(x: 418.83, y: 417.71))
        bezierPath.addCurve(to: CGPoint(x: 461.67, y: 294.58), controlPoint1: CGPoint(x: 449.45, y: 376.88), controlPoint2: CGPoint(x: 462.77, y: 335.45))
        bezierPath.addCurve(to: CGPoint(x: 391.65, y: 153.83), controlPoint1: CGPoint(x: 460.16, y: 239.04), controlPoint2: CGPoint(x: 434.99, y: 188.42))
        bezierPath.addCurve(to: CGPoint(x: 333.67, y: 122.68), controlPoint1: CGPoint(x: 374.85, y: 140.45), controlPoint2: CGPoint(x: 354.56, y: 129.52))
        bezierPath.addCurve(to: CGPoint(x: 299.8, y: 115), controlPoint1: CGPoint(x: 323.37, y: 119.31), controlPoint2: CGPoint(x: 311, y: 116.51))
        bezierPath.addCurve(to: CGPoint(x: 268.38, y: 113.53), controlPoint1: CGPoint(x: 289.92, y: 113.72), controlPoint2: CGPoint(x: 274.47, y: 113))
        bezierPath.close()
        UIColor.white.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 337.64, y: 235.64))
        bezier2Path.addCurve(to: CGPoint(x: 322.16, y: 242.07), controlPoint1: CGPoint(x: 336.92, y: 235.98), controlPoint2: CGPoint(x: 329.96, y: 238.85))
        bezier2Path.addCurve(to: CGPoint(x: 275.57, y: 262.6), controlPoint1: CGPoint(x: 296.39, y: 252.69), controlPoint2: CGPoint(x: 287.91, y: 256.43))
        bezier2Path.addCurve(to: CGPoint(x: 248.66, y: 281.61), controlPoint1: CGPoint(x: 259.45, y: 270.65), controlPoint2: CGPoint(x: 253.02, y: 275.19))
        bezier2Path.addCurve(to: CGPoint(x: 243.74, y: 300.25), controlPoint1: CGPoint(x: 245.11, y: 286.83), controlPoint2: CGPoint(x: 243.7, y: 292.05))
        bezier2Path.addCurve(to: CGPoint(x: 246.01, y: 312.39), controlPoint1: CGPoint(x: 243.74, y: 306.45), controlPoint2: CGPoint(x: 244.08, y: 308.19))
        bezier2Path.addCurve(to: CGPoint(x: 263.2, y: 329.78), controlPoint1: CGPoint(x: 249.76, y: 320.33), controlPoint2: CGPoint(x: 255.48, y: 326.11))
        bezier2Path.addCurve(to: CGPoint(x: 277.62, y: 332.12), controlPoint1: CGPoint(x: 267.85, y: 331.97), controlPoint2: CGPoint(x: 269.86, y: 332.27))
        bezier2Path.addCurve(to: CGPoint(x: 287.31, y: 330.76), controlPoint1: CGPoint(x: 284.35, y: 331.97), controlPoint2: CGPoint(x: 284.5, y: 331.97))
        bezier2Path.addCurve(to: CGPoint(x: 315.27, y: 296.28), controlPoint1: CGPoint(x: 299.15, y: 325.69), controlPoint2: CGPoint(x: 304.03, y: 319.68))
        bezier2Path.addCurve(to: CGPoint(x: 339.95, y: 238.63), controlPoint1: CGPoint(x: 323.53, y: 279.12), controlPoint2: CGPoint(x: 337.04, y: 247.55))
        bezier2Path.addCurve(to: CGPoint(x: 337.64, y: 235.64), controlPoint1: CGPoint(x: 341.12, y: 235.07), controlPoint2: CGPoint(x: 340.56, y: 234.35))
        bezier2Path.close()
        bezier2Path.move(to: CGPoint(x: 280.87, y: 287.85))
        bezier2Path.addCurve(to: CGPoint(x: 287.31, y: 293.22), controlPoint1: CGPoint(x: 283.14, y: 288.57), controlPoint2: CGPoint(x: 286.25, y: 291.18))
        bezier2Path.addCurve(to: CGPoint(x: 288.44, y: 301.2), controlPoint1: CGPoint(x: 288.4, y: 295.41), controlPoint2: CGPoint(x: 288.89, y: 298.81))
        bezier2Path.addCurve(to: CGPoint(x: 281.89, y: 310.16), controlPoint1: CGPoint(x: 287.65, y: 305.32), controlPoint2: CGPoint(x: 285.49, y: 308.3))
        bezier2Path.addCurve(to: CGPoint(x: 276.86, y: 311.21), controlPoint1: CGPoint(x: 280.23, y: 311.02), controlPoint2: CGPoint(x: 279.43, y: 311.21))
        bezier2Path.addCurve(to: CGPoint(x: 271.18, y: 309.89), controlPoint1: CGPoint(x: 274.1, y: 311.21), controlPoint2: CGPoint(x: 273.53, y: 311.1))
        bezier2Path.addCurve(to: CGPoint(x: 267.66, y: 291.63), controlPoint1: CGPoint(x: 264.14, y: 306.3), controlPoint2: CGPoint(x: 262.44, y: 297.53))
        bezier2Path.addCurve(to: CGPoint(x: 280.87, y: 287.85), controlPoint1: CGPoint(x: 271.18, y: 287.62), controlPoint2: CGPoint(x: 275.95, y: 286.26))
        bezier2Path.close()
        UIColor.white.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawFilm(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 220, height: 220), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 220, height: 220), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 220, y: resizedFrame.height / 220)
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 199.1, y: 32))
        bezierPath.addCurve(to: CGPoint(x: 206.97, y: 32.45), controlPoint1: CGPoint(x: 203.25, y: 32), controlPoint2: CGPoint(x: 205.2, y: 32))
        bezierPath.addLine(to: CGPoint(x: 207.32, y: 32.51))
        bezierPath.addCurve(to: CGPoint(x: 212.33, y: 36.3), controlPoint1: CGPoint(x: 209.64, y: 33.15), controlPoint2: CGPoint(x: 211.48, y: 34.54))
        bezierPath.addCurve(to: CGPoint(x: 213, y: 42.42), controlPoint1: CGPoint(x: 213, y: 37.92), controlPoint2: CGPoint(x: 213, y: 39.42))
        bezierPath.addLine(to: CGPoint(x: 213, y: 177.58))
        bezierPath.addCurve(to: CGPoint(x: 212.41, y: 183.43), controlPoint1: CGPoint(x: 213, y: 180.58), controlPoint2: CGPoint(x: 213, y: 182.08))
        bezierPath.addLine(to: CGPoint(x: 212.33, y: 183.7))
        bezierPath.addCurve(to: CGPoint(x: 207.32, y: 187.49), controlPoint1: CGPoint(x: 211.48, y: 185.46), controlPoint2: CGPoint(x: 209.64, y: 186.85))
        bezierPath.addCurve(to: CGPoint(x: 199.24, y: 188), controlPoint1: CGPoint(x: 205.18, y: 188), controlPoint2: CGPoint(x: 203.2, y: 188))
        bezierPath.addLine(to: CGPoint(x: 195, y: 188))
        bezierPath.addCurve(to: CGPoint(x: 195, y: 177.4), controlPoint1: CGPoint(x: 195, y: 182.92), controlPoint2: CGPoint(x: 195, y: 177.4))
        bezierPath.addLine(to: CGPoint(x: 169, y: 177.4))
        bezierPath.addCurve(to: CGPoint(x: 169, y: 188), controlPoint1: CGPoint(x: 169, y: 177.4), controlPoint2: CGPoint(x: 169, y: 182.92))
        bezierPath.addLine(to: CGPoint(x: 54, y: 188))
        bezierPath.addCurve(to: CGPoint(x: 54, y: 177.4), controlPoint1: CGPoint(x: 54, y: 182.92), controlPoint2: CGPoint(x: 54, y: 177.4))
        bezierPath.addLine(to: CGPoint(x: 28, y: 177.4))
        bezierPath.addCurve(to: CGPoint(x: 28, y: 188), controlPoint1: CGPoint(x: 28, y: 177.4), controlPoint2: CGPoint(x: 28, y: 182.92))
        bezierPath.addLine(to: CGPoint(x: 20.76, y: 188))
        bezierPath.addCurve(to: CGPoint(x: 13.03, y: 187.55), controlPoint1: CGPoint(x: 16.8, y: 188), controlPoint2: CGPoint(x: 14.82, y: 188))
        bezierPath.addLine(to: CGPoint(x: 12.68, y: 187.49))
        bezierPath.addCurve(to: CGPoint(x: 7.67, y: 183.7), controlPoint1: CGPoint(x: 10.36, y: 186.85), controlPoint2: CGPoint(x: 8.52, y: 185.46))
        bezierPath.addCurve(to: CGPoint(x: 7, y: 177.58), controlPoint1: CGPoint(x: 7, y: 182.08), controlPoint2: CGPoint(x: 7, y: 180.58))
        bezierPath.addLine(to: CGPoint(x: 7, y: 42.42))
        bezierPath.addCurve(to: CGPoint(x: 7.59, y: 36.57), controlPoint1: CGPoint(x: 7, y: 39.42), controlPoint2: CGPoint(x: 7, y: 37.92))
        bezierPath.addLine(to: CGPoint(x: 7.67, y: 36.3))
        bezierPath.addCurve(to: CGPoint(x: 12.68, y: 32.51), controlPoint1: CGPoint(x: 8.52, y: 34.54), controlPoint2: CGPoint(x: 10.36, y: 33.15))
        bezierPath.addCurve(to: CGPoint(x: 20.76, y: 32), controlPoint1: CGPoint(x: 14.82, y: 32), controlPoint2: CGPoint(x: 16.8, y: 32))
        bezierPath.addLine(to: CGPoint(x: 28, y: 32))
        bezierPath.addCurve(to: CGPoint(x: 28, y: 44.12), controlPoint1: CGPoint(x: 28, y: 37.43), controlPoint2: CGPoint(x: 28, y: 44.12))
        bezierPath.addLine(to: CGPoint(x: 54, y: 44.12))
        bezierPath.addCurve(to: CGPoint(x: 54, y: 32), controlPoint1: CGPoint(x: 54, y: 44.12), controlPoint2: CGPoint(x: 54, y: 37.43))
        bezierPath.addCurve(to: CGPoint(x: 169, y: 32), controlPoint1: CGPoint(x: 54, y: 32), controlPoint2: CGPoint(x: 126.44, y: 32))
        bezierPath.addCurve(to: CGPoint(x: 169, y: 44.12), controlPoint1: CGPoint(x: 169, y: 37.43), controlPoint2: CGPoint(x: 169, y: 44.12))
        bezierPath.addLine(to: CGPoint(x: 195, y: 44.12))
        bezierPath.addCurve(to: CGPoint(x: 195, y: 32), controlPoint1: CGPoint(x: 195, y: 44.12), controlPoint2: CGPoint(x: 195, y: 37.43))
        bezierPath.addCurve(to: CGPoint(x: 199.14, y: 32), controlPoint1: CGPoint(x: 197.32, y: 32), controlPoint2: CGPoint(x: 198.76, y: 32))
        bezierPath.addLine(to: CGPoint(x: 199.1, y: 32))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 195, y: 63.05))
        bezierPath.addLine(to: CGPoint(x: 169, y: 63.05))
        bezierPath.addLine(to: CGPoint(x: 169, y: 81.98))
        bezierPath.addLine(to: CGPoint(x: 195, y: 81.98))
        bezierPath.addLine(to: CGPoint(x: 195, y: 63.05))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 54, y: 63.05))
        bezierPath.addLine(to: CGPoint(x: 28, y: 63.05))
        bezierPath.addLine(to: CGPoint(x: 28, y: 81.98))
        bezierPath.addLine(to: CGPoint(x: 54, y: 81.98))
        bezierPath.addLine(to: CGPoint(x: 54, y: 63.05))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 195, y: 100.91))
        bezierPath.addLine(to: CGPoint(x: 169, y: 100.91))
        bezierPath.addLine(to: CGPoint(x: 169, y: 119.84))
        bezierPath.addLine(to: CGPoint(x: 195, y: 119.84))
        bezierPath.addLine(to: CGPoint(x: 195, y: 100.91))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 54, y: 100.91))
        bezierPath.addLine(to: CGPoint(x: 28, y: 100.91))
        bezierPath.addLine(to: CGPoint(x: 28, y: 119.84))
        bezierPath.addLine(to: CGPoint(x: 54, y: 119.84))
        bezierPath.addLine(to: CGPoint(x: 54, y: 100.91))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 195, y: 138.78))
        bezierPath.addLine(to: CGPoint(x: 169, y: 138.78))
        bezierPath.addLine(to: CGPoint(x: 169, y: 157.71))
        bezierPath.addLine(to: CGPoint(x: 195, y: 157.71))
        bezierPath.addLine(to: CGPoint(x: 195, y: 138.78))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 54, y: 138.78))
        bezierPath.addLine(to: CGPoint(x: 28, y: 138.78))
        bezierPath.addLine(to: CGPoint(x: 28, y: 157.71))
        bezierPath.addLine(to: CGPoint(x: 54, y: 157.71))
        bezierPath.addLine(to: CGPoint(x: 54, y: 138.78))
        bezierPath.close()
        K_COLOR_RED.setFill()
        bezierPath.fill()
        
        context.restoreGState()
        
    }

    @objc public dynamic class func drawManTalking(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 200, height: 200), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 200, y: resizedFrame.height / 200)
        
        
        //// Color Declarations
        let color2 = K_COLOR_RED//UIColor(red: 0.604, green: 0.604, blue: 0.604, alpha: 1.000)
        
        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 150.3, y: 111.05))
        bezier6Path.addCurve(to: CGPoint(x: 138.5, y: 117.7), controlPoint1: CGPoint(x: 144.04, y: 114.48), controlPoint2: CGPoint(x: 138.73, y: 117.48))
        bezier6Path.addCurve(to: CGPoint(x: 152.04, y: 114), controlPoint1: CGPoint(x: 137.91, y: 118.29), controlPoint2: CGPoint(x: 138.73, y: 118.07))
        bezier6Path.addCurve(to: CGPoint(x: 164.65, y: 109.79), controlPoint1: CGPoint(x: 158.45, y: 112.01), controlPoint2: CGPoint(x: 164.13, y: 110.13))
        bezier6Path.addCurve(to: CGPoint(x: 164.9, y: 106.25), controlPoint1: CGPoint(x: 165.71, y: 109.09), controlPoint2: CGPoint(x: 165.79, y: 108.09))
        bezier6Path.addCurve(to: CGPoint(x: 150.3, y: 111.05), controlPoint1: CGPoint(x: 163.72, y: 103.81), controlPoint2: CGPoint(x: 163.1, y: 104.03))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 149.82, y: 118.95))
        bezier6Path.addCurve(to: CGPoint(x: 138.1, y: 120.32), controlPoint1: CGPoint(x: 143.52, y: 119.58), controlPoint2: CGPoint(x: 138.25, y: 120.21))
        bezier6Path.addCurve(to: CGPoint(x: 150.27, y: 121.98), controlPoint1: CGPoint(x: 137.8, y: 120.62), controlPoint2: CGPoint(x: 139.02, y: 120.8))
        bezier6Path.addCurve(to: CGPoint(x: 167.04, y: 120.69), controlPoint1: CGPoint(x: 167.08, y: 123.72), controlPoint2: CGPoint(x: 167.04, y: 123.72))
        bezier6Path.addCurve(to: CGPoint(x: 149.82, y: 118.95), controlPoint1: CGPoint(x: 167.04, y: 117.22), controlPoint2: CGPoint(x: 167.08, y: 117.22))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 89.98, y: 53.28))
        bezier6Path.addCurve(to: CGPoint(x: 76.84, y: 56.96), controlPoint1: CGPoint(x: 84.46, y: 54.07), controlPoint2: CGPoint(x: 80.34, y: 55.2))
        bezier6Path.addCurve(to: CGPoint(x: 71.99, y: 60.07), controlPoint1: CGPoint(x: 75.1, y: 57.84), controlPoint2: CGPoint(x: 73.52, y: 58.86))
        bezier6Path.addCurve(to: CGPoint(x: 67.38, y: 67.57), controlPoint1: CGPoint(x: 69.52, y: 61.99), controlPoint2: CGPoint(x: 67.9, y: 64.69))
        bezier6Path.addCurve(to: CGPoint(x: 65.76, y: 70.42), controlPoint1: CGPoint(x: 67.01, y: 69.79), controlPoint2: CGPoint(x: 66.9, y: 69.97))
        bezier6Path.addCurve(to: CGPoint(x: 56.73, y: 84.27), controlPoint1: CGPoint(x: 62.3, y: 71.64), controlPoint2: CGPoint(x: 58.39, y: 77.69))
        bezier6Path.addCurve(to: CGPoint(x: 56.54, y: 102.92), controlPoint1: CGPoint(x: 55.62, y: 88.74), controlPoint2: CGPoint(x: 55.55, y: 98.16))
        bezier6Path.addCurve(to: CGPoint(x: 66.54, y: 126.23), controlPoint1: CGPoint(x: 58.24, y: 110.68), controlPoint2: CGPoint(x: 62.33, y: 120.32))
        bezier6Path.addCurve(to: CGPoint(x: 75.13, y: 129.7), controlPoint1: CGPoint(x: 69.34, y: 130.15), controlPoint2: CGPoint(x: 71.18, y: 130.89))
        bezier6Path.addCurve(to: CGPoint(x: 77.38, y: 134.65), controlPoint1: CGPoint(x: 76.45, y: 129.3), controlPoint2: CGPoint(x: 77.19, y: 130.92))
        bezier6Path.addCurve(to: CGPoint(x: 76.2, y: 142.34), controlPoint1: CGPoint(x: 77.49, y: 137.46), controlPoint2: CGPoint(x: 77.34, y: 138.35))
        bezier6Path.addCurve(to: CGPoint(x: 74.87, y: 147.07), controlPoint1: CGPoint(x: 75.46, y: 144.81), controlPoint2: CGPoint(x: 74.87, y: 146.95))
        bezier6Path.addCurve(to: CGPoint(x: 96.62, y: 147.25), controlPoint1: CGPoint(x: 74.87, y: 147.18), controlPoint2: CGPoint(x: 84.68, y: 147.25))
        bezier6Path.addCurve(to: CGPoint(x: 118.37, y: 147.03), controlPoint1: CGPoint(x: 108.6, y: 147.25), controlPoint2: CGPoint(x: 118.37, y: 147.14))
        bezier6Path.addCurve(to: CGPoint(x: 117.23, y: 142.08), controlPoint1: CGPoint(x: 118.37, y: 146.88), controlPoint2: CGPoint(x: 117.86, y: 144.66))
        bezier6Path.addCurve(to: CGPoint(x: 121.84, y: 135.24), controlPoint1: CGPoint(x: 115.42, y: 134.88), controlPoint2: CGPoint(x: 115.87, y: 134.21))
        bezier6Path.addCurve(to: CGPoint(x: 129.4, y: 134.17), controlPoint1: CGPoint(x: 126.08, y: 135.98), controlPoint2: CGPoint(x: 127.96, y: 135.69))
        bezier6Path.addCurve(to: CGPoint(x: 129.99, y: 128.82), controlPoint1: CGPoint(x: 130.54, y: 132.95), controlPoint2: CGPoint(x: 130.84, y: 130.41))
        bezier6Path.addCurve(to: CGPoint(x: 131.2, y: 126.49), controlPoint1: CGPoint(x: 129.29, y: 127.41), controlPoint2: CGPoint(x: 129.66, y: 126.67))
        bezier6Path.addCurve(to: CGPoint(x: 132.68, y: 125.34), controlPoint1: CGPoint(x: 131.87, y: 126.42), controlPoint2: CGPoint(x: 132.35, y: 126.05))
        bezier6Path.addCurve(to: CGPoint(x: 130.58, y: 121.24), controlPoint1: CGPoint(x: 133.45, y: 123.72), controlPoint2: CGPoint(x: 132.83, y: 122.5))
        bezier6Path.addCurve(to: CGPoint(x: 131.83, y: 119.18), controlPoint1: CGPoint(x: 128.33, y: 120.03), controlPoint2: CGPoint(x: 128.44, y: 119.88))
        bezier6Path.addCurve(to: CGPoint(x: 134.52, y: 118.36), controlPoint1: CGPoint(x: 133.05, y: 118.92), controlPoint2: CGPoint(x: 134.26, y: 118.55))
        bezier6Path.addCurve(to: CGPoint(x: 134.56, y: 114.6), controlPoint1: CGPoint(x: 135.08, y: 117.88), controlPoint2: CGPoint(x: 135.11, y: 115.81))
        bezier6Path.addCurve(to: CGPoint(x: 136.55, y: 110.83), controlPoint1: CGPoint(x: 133.82, y: 113.01), controlPoint2: CGPoint(x: 134.41, y: 111.9))
        bezier6Path.addCurve(to: CGPoint(x: 139.13, y: 109.28), controlPoint1: CGPoint(x: 137.58, y: 110.31), controlPoint2: CGPoint(x: 138.76, y: 109.61))
        bezier6Path.addCurve(to: CGPoint(x: 138.1, y: 102.92), controlPoint1: CGPoint(x: 140.24, y: 108.32), controlPoint2: CGPoint(x: 139.91, y: 106.36))
        bezier6Path.addCurve(to: CGPoint(x: 137.63, y: 102.03), controlPoint1: CGPoint(x: 137.94, y: 102.62), controlPoint2: CGPoint(x: 137.78, y: 102.32))
        bezier6Path.addCurve(to: CGPoint(x: 133.82, y: 88.92), controlPoint1: CGPoint(x: 133.9, y: 94.94), controlPoint2: CGPoint(x: 133.11, y: 92.19))
        bezier6Path.addCurve(to: CGPoint(x: 131.98, y: 73.26), controlPoint1: CGPoint(x: 134.71, y: 84.79), controlPoint2: CGPoint(x: 133.79, y: 76.95))
        bezier6Path.addLine(to: CGPoint(x: 131.09, y: 71.49))
        bezier6Path.addLine(to: CGPoint(x: 131.94, y: 70.12))
        bezier6Path.addCurve(to: CGPoint(x: 134.45, y: 61.07), controlPoint1: CGPoint(x: 134.12, y: 66.61), controlPoint2: CGPoint(x: 134.93, y: 63.66))
        bezier6Path.addLine(to: CGPoint(x: 134.23, y: 59.78))
        bezier6Path.addLine(to: CGPoint(x: 131.35, y: 59.81))
        bezier6Path.addCurve(to: CGPoint(x: 121.32, y: 57.75), controlPoint1: CGPoint(x: 128.96, y: 59.85), controlPoint2: CGPoint(x: 127.41, y: 59.52))
        bezier6Path.addCurve(to: CGPoint(x: 103.44, y: 53.61), controlPoint1: CGPoint(x: 112.22, y: 55.12), controlPoint2: CGPoint(x: 108.75, y: 54.31))
        bezier6Path.addCurve(to: CGPoint(x: 89.98, y: 53.28), controlPoint1: CGPoint(x: 99.61, y: 53.13), controlPoint2: CGPoint(x: 92.42, y: 52.94))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 138.28, y: 122.5))
        bezier6Path.addCurve(to: CGPoint(x: 138.14, y: 122.83), controlPoint1: CGPoint(x: 137.95, y: 122.5), controlPoint2: CGPoint(x: 137.91, y: 122.61))
        bezier6Path.addCurve(to: CGPoint(x: 162.1, y: 136.54), controlPoint1: CGPoint(x: 139.02, y: 123.72), controlPoint2: CGPoint(x: 161.47, y: 136.54))
        bezier6Path.addCurve(to: CGPoint(x: 164.24, y: 134.8), controlPoint1: CGPoint(x: 163.1, y: 136.54), controlPoint2: CGPoint(x: 163.54, y: 136.17))
        bezier6Path.addCurve(to: CGPoint(x: 163.94, y: 131.44), controlPoint1: CGPoint(x: 165.05, y: 133.18), controlPoint2: CGPoint(x: 164.98, y: 132.29))
        bezier6Path.addCurve(to: CGPoint(x: 138.28, y: 122.5), controlPoint1: CGPoint(x: 163.06, y: 130.78), controlPoint2: CGPoint(x: 139.39, y: 122.5))
        bezier6Path.close()
        bezier6Path.move(to: CGPoint(x: 179.47, y: 29.09))
        bezier6Path.addCurve(to: CGPoint(x: 187.27, y: 30.24), controlPoint1: CGPoint(x: 182.72, y: 29.21), controlPoint2: CGPoint(x: 185.06, y: 29.52))
        bezier6Path.addLine(to: CGPoint(x: 188, y: 30.42))
        bezier6Path.addCurve(to: CGPoint(x: 198.58, y: 41), controlPoint1: CGPoint(x: 192.92, y: 32.21), controlPoint2: CGPoint(x: 196.79, y: 36.08))
        bezier6Path.addCurve(to: CGPoint(x: 200, y: 58.04), controlPoint1: CGPoint(x: 200, y: 45.5), controlPoint2: CGPoint(x: 200, y: 49.68))
        bezier6Path.addLine(to: CGPoint(x: 200, y: 142.96))
        bezier6Path.addCurve(to: CGPoint(x: 198.76, y: 159.27), controlPoint1: CGPoint(x: 200, y: 151.32), controlPoint2: CGPoint(x: 200, y: 155.5))
        bezier6Path.addLine(to: CGPoint(x: 198.58, y: 160))
        bezier6Path.addCurve(to: CGPoint(x: 188, y: 170.58), controlPoint1: CGPoint(x: 196.79, y: 164.92), controlPoint2: CGPoint(x: 192.92, y: 168.79))
        bezier6Path.addCurve(to: CGPoint(x: 170.96, y: 172), controlPoint1: CGPoint(x: 183.5, y: 172), controlPoint2: CGPoint(x: 179.32, y: 172))
        bezier6Path.addLine(to: CGPoint(x: 29.04, y: 172))
        bezier6Path.addCurve(to: CGPoint(x: 12.73, y: 170.76), controlPoint1: CGPoint(x: 20.68, y: 172), controlPoint2: CGPoint(x: 16.5, y: 172))
        bezier6Path.addLine(to: CGPoint(x: 12, y: 170.58))
        bezier6Path.addCurve(to: CGPoint(x: 1.42, y: 160), controlPoint1: CGPoint(x: 7.08, y: 168.79), controlPoint2: CGPoint(x: 3.21, y: 164.92))
        bezier6Path.addCurve(to: CGPoint(x: 0, y: 142.96), controlPoint1: CGPoint(x: 0, y: 155.5), controlPoint2: CGPoint(x: 0, y: 151.32))
        bezier6Path.addLine(to: CGPoint(x: 0, y: 58.04))
        bezier6Path.addCurve(to: CGPoint(x: 1.24, y: 41.73), controlPoint1: CGPoint(x: 0, y: 49.68), controlPoint2: CGPoint(x: -0, y: 45.5))
        bezier6Path.addLine(to: CGPoint(x: 1.42, y: 41))
        bezier6Path.addCurve(to: CGPoint(x: 12, y: 30.42), controlPoint1: CGPoint(x: 3.21, y: 36.08), controlPoint2: CGPoint(x: 7.08, y: 32.21))
        bezier6Path.addCurve(to: CGPoint(x: 29.04, y: 29), controlPoint1: CGPoint(x: 16.5, y: 29), controlPoint2: CGPoint(x: 20.68, y: 29))
        bezier6Path.addLine(to: CGPoint(x: 170.96, y: 29))
        bezier6Path.addCurve(to: CGPoint(x: 179.47, y: 29.09), controlPoint1: CGPoint(x: 174.42, y: 29), controlPoint2: CGPoint(x: 177.17, y: 29))
        bezier6Path.close()
        K_COLOR_RED.setFill()
        bezier6Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawVotes(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: -1, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 252.36, y: 127.64))
        bezierPath.addCurve(to: CGPoint(x: 195.7, y: 149.02), controlPoint1: CGPoint(x: 226.35, y: 131.36), controlPoint2: CGPoint(x: 210.21, y: 137.51))
        bezierPath.addCurve(to: CGPoint(x: 181.18, y: 172.61), controlPoint1: CGPoint(x: 187.92, y: 155.06), controlPoint2: CGPoint(x: 182.81, y: 163.54))
        bezierPath.addCurve(to: CGPoint(x: 176.07, y: 181.55), controlPoint1: CGPoint(x: 180.02, y: 179.58), controlPoint2: CGPoint(x: 179.67, y: 180.16))
        bezierPath.addCurve(to: CGPoint(x: 147.63, y: 225.13), controlPoint1: CGPoint(x: 165.16, y: 185.39), controlPoint2: CGPoint(x: 152.85, y: 204.45))
        bezierPath.addCurve(to: CGPoint(x: 147.05, y: 283.81), controlPoint1: CGPoint(x: 144.14, y: 239.19), controlPoint2: CGPoint(x: 143.91, y: 268.82))
        bezierPath.addCurve(to: CGPoint(x: 178.51, y: 357.13), controlPoint1: CGPoint(x: 152.39, y: 308.21), controlPoint2: CGPoint(x: 165.28, y: 338.54))
        bezierPath.addCurve(to: CGPoint(x: 205.57, y: 368.06), controlPoint1: CGPoint(x: 187.34, y: 369.45), controlPoint2: CGPoint(x: 193.14, y: 371.77))
        bezierPath.addCurve(to: CGPoint(x: 212.65, y: 383.63), controlPoint1: CGPoint(x: 209.75, y: 366.78), controlPoint2: CGPoint(x: 212.07, y: 371.89))
        bezierPath.addCurve(to: CGPoint(x: 208.94, y: 407.8), controlPoint1: CGPoint(x: 213, y: 392.46), controlPoint2: CGPoint(x: 212.53, y: 395.25))
        bezierPath.addCurve(to: CGPoint(x: 204.76, y: 422.67), controlPoint1: CGPoint(x: 206.61, y: 415.58), controlPoint2: CGPoint(x: 204.76, y: 422.32))
        bezierPath.addCurve(to: CGPoint(x: 273.26, y: 423.25), controlPoint1: CGPoint(x: 204.76, y: 423.02), controlPoint2: CGPoint(x: 235.64, y: 423.25))
        bezierPath.addCurve(to: CGPoint(x: 341.77, y: 422.55), controlPoint1: CGPoint(x: 311, y: 423.25), controlPoint2: CGPoint(x: 341.77, y: 422.9))
        bezierPath.addCurve(to: CGPoint(x: 338.17, y: 406.98), controlPoint1: CGPoint(x: 341.77, y: 422.09), controlPoint2: CGPoint(x: 340.14, y: 415.12))
        bezierPath.addCurve(to: CGPoint(x: 352.69, y: 385.49), controlPoint1: CGPoint(x: 332.48, y: 384.32), controlPoint2: CGPoint(x: 333.87, y: 382.23))
        bezierPath.addCurve(to: CGPoint(x: 376.49, y: 382.12), controlPoint1: CGPoint(x: 366.04, y: 387.81), controlPoint2: CGPoint(x: 371.96, y: 386.88))
        bezierPath.addCurve(to: CGPoint(x: 378.35, y: 365.27), controlPoint1: CGPoint(x: 380.09, y: 378.28), controlPoint2: CGPoint(x: 381.02, y: 370.26))
        bezierPath.addCurve(to: CGPoint(x: 382.18, y: 357.95), controlPoint1: CGPoint(x: 376.14, y: 360.85), controlPoint2: CGPoint(x: 377.3, y: 358.53))
        bezierPath.addCurve(to: CGPoint(x: 386.82, y: 354.34), controlPoint1: CGPoint(x: 384.27, y: 357.71), controlPoint2: CGPoint(x: 385.78, y: 356.55))
        bezierPath.addCurve(to: CGPoint(x: 380.2, y: 341.45), controlPoint1: CGPoint(x: 389.26, y: 349.23), controlPoint2: CGPoint(x: 387.29, y: 345.4))
        bezierPath.addCurve(to: CGPoint(x: 384.15, y: 334.94), controlPoint1: CGPoint(x: 373.12, y: 337.61), controlPoint2: CGPoint(x: 373.47, y: 337.15))
        bezierPath.addCurve(to: CGPoint(x: 392.63, y: 332.38), controlPoint1: CGPoint(x: 387.98, y: 334.12), controlPoint2: CGPoint(x: 391.82, y: 332.96))
        bezierPath.addCurve(to: CGPoint(x: 392.74, y: 320.53), controlPoint1: CGPoint(x: 394.37, y: 330.87), controlPoint2: CGPoint(x: 394.49, y: 324.36))
        bezierPath.addCurve(to: CGPoint(x: 399.01, y: 308.68), controlPoint1: CGPoint(x: 390.42, y: 315.53), controlPoint2: CGPoint(x: 392.28, y: 312.05))
        bezierPath.addCurve(to: CGPoint(x: 407.14, y: 303.8), controlPoint1: CGPoint(x: 402.27, y: 307.05), controlPoint2: CGPoint(x: 405.98, y: 304.84))
        bezierPath.addCurve(to: CGPoint(x: 403.89, y: 283.81), controlPoint1: CGPoint(x: 410.63, y: 300.78), controlPoint2: CGPoint(x: 409.58, y: 294.62))
        bezierPath.addCurve(to: CGPoint(x: 390.42, y: 239.77), controlPoint1: CGPoint(x: 390.89, y: 259.41), controlPoint2: CGPoint(x: 388.1, y: 250.46))
        bezierPath.addCurve(to: CGPoint(x: 384.62, y: 190.5), controlPoint1: CGPoint(x: 393.21, y: 226.76), controlPoint2: CGPoint(x: 390.31, y: 202.12))
        bezierPath.addLine(to: CGPoint(x: 381.83, y: 184.92))
        bezierPath.addLine(to: CGPoint(x: 384.5, y: 180.63))
        bezierPath.addCurve(to: CGPoint(x: 392.4, y: 152.16), controlPoint1: CGPoint(x: 391.35, y: 169.59), controlPoint2: CGPoint(x: 393.91, y: 160.29))
        bezierPath.addLine(to: CGPoint(x: 391.7, y: 148.09))
        bezierPath.addLine(to: CGPoint(x: 382.64, y: 148.21))
        bezierPath.addCurve(to: CGPoint(x: 351.06, y: 141.7), controlPoint1: CGPoint(x: 375.1, y: 148.32), controlPoint2: CGPoint(x: 370.22, y: 147.28))
        bezierPath.addCurve(to: CGPoint(x: 294.74, y: 128.68), controlPoint1: CGPoint(x: 322.38, y: 133.45), controlPoint2: CGPoint(x: 311.46, y: 130.89))
        bezierPath.addCurve(to: CGPoint(x: 252.36, y: 127.64), controlPoint1: CGPoint(x: 282.67, y: 127.17), controlPoint2: CGPoint(x: 260.03, y: 126.59))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 438.33, y: 309.37))
        bezier2Path.addCurve(to: CGPoint(x: 401.17, y: 330.29), controlPoint1: CGPoint(x: 418.59, y: 320.18), controlPoint2: CGPoint(x: 401.87, y: 329.59))
        bezier2Path.addCurve(to: CGPoint(x: 443.78, y: 318.67), controlPoint1: CGPoint(x: 399.31, y: 332.15), controlPoint2: CGPoint(x: 401.87, y: 331.45))
        bezier2Path.addCurve(to: CGPoint(x: 483.49, y: 305.42), controlPoint1: CGPoint(x: 463.99, y: 312.4), controlPoint2: CGPoint(x: 481.87, y: 306.47))
        bezier2Path.addCurve(to: CGPoint(x: 484.31, y: 294.27), controlPoint1: CGPoint(x: 486.86, y: 303.22), controlPoint2: CGPoint(x: 487.09, y: 300.08))
        bezier2Path.addCurve(to: CGPoint(x: 438.33, y: 309.37), controlPoint1: CGPoint(x: 480.59, y: 286.6), controlPoint2: CGPoint(x: 478.62, y: 287.3))
        bezier2Path.close()
        fillColor.setFill()
        bezier2Path.fill()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 436.82, y: 334.24))
        bezier3Path.addCurve(to: CGPoint(x: 399.89, y: 338.54), controlPoint1: CGPoint(x: 416.96, y: 336.22), controlPoint2: CGPoint(x: 400.36, y: 338.19))
        bezier3Path.addCurve(to: CGPoint(x: 438.21, y: 343.77), controlPoint1: CGPoint(x: 398.96, y: 339.47), controlPoint2: CGPoint(x: 402.79, y: 340.05))
        bezier3Path.addCurve(to: CGPoint(x: 491.04, y: 339.7), controlPoint1: CGPoint(x: 491.16, y: 349.23), controlPoint2: CGPoint(x: 491.04, y: 349.23))
        bezier3Path.addCurve(to: CGPoint(x: 436.82, y: 334.24), controlPoint1: CGPoint(x: 491.04, y: 328.78), controlPoint2: CGPoint(x: 491.16, y: 328.78))
        bezier3Path.close()
        fillColor.setFill()
        bezier3Path.fill()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 400.01, y: 346.44))
        bezier4Path.addCurve(to: CGPoint(x: 475.48, y: 389.55), controlPoint1: CGPoint(x: 402.79, y: 349.23), controlPoint2: CGPoint(x: 473.51, y: 389.55))
        bezier4Path.addCurve(to: CGPoint(x: 482.22, y: 384.09), controlPoint1: CGPoint(x: 478.62, y: 389.55), controlPoint2: CGPoint(x: 480.01, y: 388.39))
        bezier4Path.addCurve(to: CGPoint(x: 481.29, y: 373.52), controlPoint1: CGPoint(x: 484.77, y: 378.98), controlPoint2: CGPoint(x: 484.54, y: 376.19))
        bezier4Path.addCurve(to: CGPoint(x: 400.47, y: 345.4), controlPoint1: CGPoint(x: 478.5, y: 371.42), controlPoint2: CGPoint(x: 403.96, y: 345.4))
        bezier4Path.addCurve(to: CGPoint(x: 400.01, y: 346.44), controlPoint1: CGPoint(x: 399.43, y: 345.4), controlPoint2: CGPoint(x: 399.31, y: 345.74))
        bezier4Path.close()
        fillColor.setFill()
        bezier4Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawFavorite(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: -1, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 232.89, y: 147.17))
        bezier2Path.addCurve(to: CGPoint(x: 271.35, y: 174.91), controlPoint1: CGPoint(x: 242.87, y: 152.12), controlPoint2: CGPoint(x: 261.37, y: 165.5))
        bezier2Path.addLine(to: CGPoint(x: 276.5, y: 179.73))
        bezier2Path.addLine(to: CGPoint(x: 280.6, y: 175.76))
        bezier2Path.addCurve(to: CGPoint(x: 322.49, y: 146.01), controlPoint1: CGPoint(x: 291.99, y: 164.77), controlPoint2: CGPoint(x: 310.37, y: 151.69))
        bezier2Path.addCurve(to: CGPoint(x: 361.57, y: 137.15), controlPoint1: CGPoint(x: 336.7, y: 139.23), controlPoint2: CGPoint(x: 346.32, y: 137.09))
        bezier2Path.addCurve(to: CGPoint(x: 420.18, y: 153.95), controlPoint1: CGPoint(x: 385.03, y: 137.21), controlPoint2: CGPoint(x: 405.12, y: 143.02))
        bezier2Path.addCurve(to: CGPoint(x: 444.56, y: 182.54), controlPoint1: CGPoint(x: 429.62, y: 160.79), controlPoint2: CGPoint(x: 439.29, y: 172.1))
        bezier2Path.addCurve(to: CGPoint(x: 453.99, y: 236.24), controlPoint1: CGPoint(x: 451.79, y: 196.96), controlPoint2: CGPoint(x: 455.4, y: 217.55))
        bezier2Path.addCurve(to: CGPoint(x: 423.25, y: 302.95), controlPoint1: CGPoint(x: 452.34, y: 257.99), controlPoint2: CGPoint(x: 441.87, y: 280.78))
        bezier2Path.addCurve(to: CGPoint(x: 373.21, y: 353.11), controlPoint1: CGPoint(x: 414.49, y: 313.4), controlPoint2: CGPoint(x: 410.75, y: 317.13))
        bezier2Path.addCurve(to: CGPoint(x: 315.63, y: 408.34), controlPoint1: CGPoint(x: 355.2, y: 370.4), controlPoint2: CGPoint(x: 329.29, y: 395.26))
        bezier2Path.addCurve(to: CGPoint(x: 280.97, y: 440.41), controlPoint1: CGPoint(x: 285.56, y: 437.23), controlPoint2: CGPoint(x: 282.99, y: 439.68))
        bezier2Path.addCurve(to: CGPoint(x: 271.23, y: 440.1), controlPoint1: CGPoint(x: 278.64, y: 441.32), controlPoint2: CGPoint(x: 273.5, y: 441.14))
        bezier2Path.addCurve(to: CGPoint(x: 212.06, y: 384.08), controlPoint1: CGPoint(x: 270.19, y: 439.55), controlPoint2: CGPoint(x: 243.55, y: 414.38))
        bezier2Path.addCurve(to: CGPoint(x: 146.41, y: 321.04), controlPoint1: CGPoint(x: 180.58, y: 353.78), controlPoint2: CGPoint(x: 151.06, y: 325.43))
        bezier2Path.addCurve(to: CGPoint(x: 118.29, y: 287.99), controlPoint1: CGPoint(x: 136.73, y: 311.87), controlPoint2: CGPoint(x: 125.52, y: 298.68))
        bezier2Path.addCurve(to: CGPoint(x: 98.51, y: 233.92), controlPoint1: CGPoint(x: 107.09, y: 271.25), controlPoint2: CGPoint(x: 99.92, y: 251.7))
        bezier2Path.addCurve(to: CGPoint(x: 98.37, y: 227.27), controlPoint1: CGPoint(x: 98.36, y: 231.91), controlPoint2: CGPoint(x: 98.32, y: 229.67))
        bezier2Path.addCurve(to: CGPoint(x: 98, y: 219.67), controlPoint1: CGPoint(x: 98.13, y: 224.76), controlPoint2: CGPoint(x: 98, y: 222.23))
        bezier2Path.addCurve(to: CGPoint(x: 125.06, y: 160.3), controlPoint1: CGPoint(x: 98, y: 196.37), controlPoint2: CGPoint(x: 108.37, y: 175.33))
        bezier2Path.addCurve(to: CGPoint(x: 144.24, y: 147.14), controlPoint1: CGPoint(x: 125.08, y: 160.28), controlPoint2: CGPoint(x: 144.24, y: 147.14))
        bezier2Path.addCurve(to: CGPoint(x: 157.75, y: 141.56), controlPoint1: CGPoint(x: 148.54, y: 144.95), controlPoint2: CGPoint(x: 153.06, y: 143.08))
        bezier2Path.addCurve(to: CGPoint(x: 187.01, y: 136.99), controlPoint1: CGPoint(x: 166.91, y: 138.6), controlPoint2: CGPoint(x: 176.76, y: 136.99))
        bezier2Path.addCurve(to: CGPoint(x: 187.9, y: 136.99), controlPoint1: CGPoint(x: 187.31, y: 136.99), controlPoint2: CGPoint(x: 187.6, y: 136.99))
        bezier2Path.addCurve(to: CGPoint(x: 232.89, y: 147.17), controlPoint1: CGPoint(x: 204.59, y: 136.5), controlPoint2: CGPoint(x: 217.68, y: 139.53))
        bezier2Path.close()
        UIColor.white.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawSurveys(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: -1, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 344.9, y: 148.17))
        bezierPath.addCurve(to: CGPoint(x: 247.27, y: 190.52), controlPoint1: CGPoint(x: 327.94, y: 165.47), controlPoint2: CGPoint(x: 290.81, y: 181.64))
        bezierPath.addCurve(to: CGPoint(x: 225.73, y: 189.61), controlPoint1: CGPoint(x: 229.17, y: 194.16), controlPoint2: CGPoint(x: 228.94, y: 194.16))
        bezierPath.addCurve(to: CGPoint(x: 181.5, y: 184.82), controlPoint1: CGPoint(x: 222.75, y: 185.05), controlPoint2: CGPoint(x: 220.46, y: 184.82))
        bezierPath.addLine(to: CGPoint(x: 140.25, y: 184.82))
        bezierPath.addLine(to: CGPoint(x: 132.46, y: 192.57))
        bezierPath.addCurve(to: CGPoint(x: 124.67, y: 211.92), controlPoint1: CGPoint(x: 125.58, y: 199.4), controlPoint2: CGPoint(x: 124.67, y: 201.67))
        bezierPath.addCurve(to: CGPoint(x: 118.25, y: 223.53), controlPoint1: CGPoint(x: 124.67, y: 223.08), controlPoint2: CGPoint(x: 124.44, y: 223.53))
        bezierPath.addCurve(to: CGPoint(x: 106.33, y: 249.72), controlPoint1: CGPoint(x: 107.94, y: 223.53), controlPoint2: CGPoint(x: 106.33, y: 227.18))
        bezierPath.addCurve(to: CGPoint(x: 118.25, y: 275.9), controlPoint1: CGPoint(x: 106.33, y: 272.26), controlPoint2: CGPoint(x: 107.94, y: 275.9))
        bezierPath.addCurve(to: CGPoint(x: 124.67, y: 285.01), controlPoint1: CGPoint(x: 124.21, y: 275.9), controlPoint2: CGPoint(x: 124.67, y: 276.58))
        bezierPath.addCurve(to: CGPoint(x: 149.42, y: 313.7), controlPoint1: CGPoint(x: 124.67, y: 302.09), controlPoint2: CGPoint(x: 132.46, y: 310.97))
        bezierPath.addLine(to: CGPoint(x: 158.35, y: 315.06))
        bezierPath.addLine(to: CGPoint(x: 171.65, y: 359.92))
        bezierPath.addCurve(to: CGPoint(x: 188.15, y: 409.78), controlPoint1: CGPoint(x: 178.98, y: 384.51), controlPoint2: CGPoint(x: 186.54, y: 406.82))
        bezierPath.addCurve(to: CGPoint(x: 199.83, y: 414.34), controlPoint1: CGPoint(x: 190.67, y: 414.11), controlPoint2: CGPoint(x: 192.96, y: 415.02))
        bezierPath.addCurve(to: CGPoint(x: 208.08, y: 361.29), controlPoint1: CGPoint(x: 213.81, y: 413.2), controlPoint2: CGPoint(x: 214.5, y: 408.87))
        bezierPath.addCurve(to: CGPoint(x: 202.58, y: 317.34), controlPoint1: CGPoint(x: 205.1, y: 338.74), controlPoint2: CGPoint(x: 202.58, y: 318.94))
        bezierPath.addCurve(to: CGPoint(x: 210.6, y: 314.61), controlPoint1: CGPoint(x: 202.58, y: 315.75), controlPoint2: CGPoint(x: 205.79, y: 314.61))
        bezierPath.addCurve(to: CGPoint(x: 224.81, y: 308.69), controlPoint1: CGPoint(x: 216.33, y: 314.61), controlPoint2: CGPoint(x: 220.69, y: 312.79))
        bezierPath.addCurve(to: CGPoint(x: 245.44, y: 305.27), controlPoint1: CGPoint(x: 230.77, y: 302.77), controlPoint2: CGPoint(x: 231.23, y: 302.54))
        bezierPath.addCurve(to: CGPoint(x: 341.23, y: 344.21), controlPoint1: CGPoint(x: 280.96, y: 311.65), controlPoint2: CGPoint(x: 338.25, y: 335.1))
        bezierPath.addCurve(to: CGPoint(x: 363, y: 360.15), controlPoint1: CGPoint(x: 343.52, y: 351.04), controlPoint2: CGPoint(x: 355.9, y: 360.15))
        bezierPath.addCurve(to: CGPoint(x: 391.19, y: 324.17), controlPoint1: CGPoint(x: 372.63, y: 360.15), controlPoint2: CGPoint(x: 384.08, y: 345.57))
        bezierPath.addCurve(to: CGPoint(x: 373.08, y: 141.79), controlPoint1: CGPoint(x: 411.12, y: 264.52), controlPoint2: CGPoint(x: 401.04, y: 163.65))
        bezierPath.addCurve(to: CGPoint(x: 344.9, y: 148.17), controlPoint1: CGPoint(x: 363.46, y: 134.28), controlPoint2: CGPoint(x: 357.04, y: 135.64))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 368.73, y: 192.34))
        bezierPath.addCurve(to: CGPoint(x: 365.98, y: 315.29), controlPoint1: CGPoint(x: 376.98, y: 226.49), controlPoint2: CGPoint(x: 375.6, y: 283.42))
        bezierPath.addLine(to: CGPoint(x: 362.31, y: 327.13))
        bezierPath.addLine(to: CGPoint(x: 357.96, y: 314.61))
        bezierPath.addCurve(to: CGPoint(x: 353.6, y: 273.62), controlPoint1: CGPoint(x: 352.46, y: 298.9), controlPoint2: CGPoint(x: 349.71, y: 273.62))
        bezierPath.addCurve(to: CGPoint(x: 360.71, y: 266.11), controlPoint1: CGPoint(x: 354.98, y: 273.62), controlPoint2: CGPoint(x: 358.19, y: 270.21))
        bezierPath.addCurve(to: CGPoint(x: 354.06, y: 223.76), controlPoint1: CGPoint(x: 368.73, y: 252.9), controlPoint2: CGPoint(x: 365.29, y: 229.68))
        bezierPath.addCurve(to: CGPoint(x: 351.77, y: 209.87), controlPoint1: CGPoint(x: 350.4, y: 221.71), controlPoint2: CGPoint(x: 350.17, y: 219.89))
        bezierPath.addCurve(to: CGPoint(x: 363, y: 174.58), controlPoint1: CGPoint(x: 354.52, y: 192.34), controlPoint2: CGPoint(x: 360.71, y: 173.21))
        bezierPath.addCurve(to: CGPoint(x: 368.73, y: 192.34), controlPoint1: CGPoint(x: 363.92, y: 175.26), controlPoint2: CGPoint(x: 366.67, y: 183.23))
        bezierPath.close()
        UIColor.white.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 446.65, y: 191.88))
        bezier2Path.addCurve(to: CGPoint(x: 418.46, y: 211.69), controlPoint1: CGPoint(x: 419.6, y: 202.81), controlPoint2: CGPoint(x: 417.54, y: 204.18))
        bezier2Path.addCurve(to: CGPoint(x: 470.25, y: 206.23), controlPoint1: CGPoint(x: 420.06, y: 224.44), controlPoint2: CGPoint(x: 431.06, y: 223.3))
        bezier2Path.addCurve(to: CGPoint(x: 482.17, y: 194.16), controlPoint1: CGPoint(x: 480.79, y: 201.67), controlPoint2: CGPoint(x: 482.17, y: 200.31))
        bezier2Path.addCurve(to: CGPoint(x: 477.81, y: 184.82), controlPoint1: CGPoint(x: 482.17, y: 189.61), controlPoint2: CGPoint(x: 480.56, y: 186.42))
        bezier2Path.addCurve(to: CGPoint(x: 446.65, y: 191.88), controlPoint1: CGPoint(x: 471.85, y: 181.64), controlPoint2: CGPoint(x: 472.54, y: 181.64))
        bezier2Path.close()
        UIColor.white.setFill()
        bezier2Path.fill()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 429, y: 239.7))
        bezier3Path.addCurve(to: CGPoint(x: 429.23, y: 257.69), controlPoint1: CGPoint(x: 423.27, y: 242.89), controlPoint2: CGPoint(x: 423.5, y: 254.5))
        bezier3Path.addCurve(to: CGPoint(x: 459.02, y: 259.96), controlPoint1: CGPoint(x: 431.75, y: 258.82), controlPoint2: CGPoint(x: 445.04, y: 259.96))
        bezier3Path.addCurve(to: CGPoint(x: 491.33, y: 248.81), controlPoint1: CGPoint(x: 485.38, y: 259.96), controlPoint2: CGPoint(x: 491.33, y: 257.91))
        bezier3Path.addCurve(to: CGPoint(x: 457.88, y: 237.19), controlPoint1: CGPoint(x: 491.33, y: 239.7), controlPoint2: CGPoint(x: 484.46, y: 237.19))
        bezier3Path.addCurve(to: CGPoint(x: 429, y: 239.7), controlPoint1: CGPoint(x: 444.13, y: 237.19), controlPoint2: CGPoint(x: 431.06, y: 238.33))
        bezier3Path.close()
        UIColor.white.setFill()
        bezier3Path.fill()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 421.67, y: 279.54))
        bezier4Path.addCurve(to: CGPoint(x: 421.21, y: 293.89), controlPoint1: CGPoint(x: 417.08, y: 283.87), controlPoint2: CGPoint(x: 416.85, y: 290.47))
        bezier4Path.addCurve(to: CGPoint(x: 473, y: 314.61), controlPoint1: CGPoint(x: 425.56, y: 297.53), controlPoint2: CGPoint(x: 468.42, y: 314.61))
        bezier4Path.addCurve(to: CGPoint(x: 478.96, y: 296.62), controlPoint1: CGPoint(x: 481.25, y: 314.61), controlPoint2: CGPoint(x: 485.6, y: 302.09))
        bezier4Path.addCurve(to: CGPoint(x: 428.08, y: 275.9), controlPoint1: CGPoint(x: 475.06, y: 293.43), controlPoint2: CGPoint(x: 431.98, y: 275.9))
        bezier4Path.addCurve(to: CGPoint(x: 421.67, y: 279.54), controlPoint1: CGPoint(x: 426.48, y: 275.9), controlPoint2: CGPoint(x: 423.5, y: 277.5))
        bezier4Path.close()
        UIColor.white.setFill()
        bezier4Path.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawNotification(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 553, height: 553), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 553, height: 553), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 553, y: resizedFrame.height / 553)
        
        
        //// Color Declarations
        let color4 = K_COLOR_RED//UIColor(red: 0.678, green: 0.161, blue: 0.208, alpha: 1.000)
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 553, height: 553), cornerRadius: 120)
        color4.setFill()
        rectangle2Path.fill()
        
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 306.93, y: 104.1))
        bezierPath.addCurve(to: CGPoint(x: 302.45, y: 126.61), controlPoint1: CGPoint(x: 298.98, y: 107.27), controlPoint2: CGPoint(x: 296.52, y: 119.68))
        bezierPath.addCurve(to: CGPoint(x: 324.57, y: 130.79), controlPoint1: CGPoint(x: 305.77, y: 130.36), controlPoint2: CGPoint(x: 306.21, y: 130.5))
        bezierPath.addCurve(to: CGPoint(x: 355.08, y: 134.83), controlPoint1: CGPoint(x: 339.61, y: 131.08), controlPoint2: CGPoint(x: 345.54, y: 131.8))
        bezierPath.addCurve(to: CGPoint(x: 423.33, y: 194.84), controlPoint1: CGPoint(x: 385.59, y: 144.06), controlPoint2: CGPoint(x: 411.33, y: 166.71))
        bezierPath.addCurve(to: CGPoint(x: 431.43, y: 237.55), controlPoint1: CGPoint(x: 430.42, y: 211.58), controlPoint2: CGPoint(x: 431.43, y: 216.48))
        bezierPath.addCurve(to: CGPoint(x: 426.66, y: 271.31), controlPoint1: CGPoint(x: 431.43, y: 256.73), controlPoint2: CGPoint(x: 431.14, y: 258.32))
        bezierPath.addCurve(to: CGPoint(x: 433.74, y: 299.73), controlPoint1: CGPoint(x: 419.86, y: 290.2), controlPoint2: CGPoint(x: 421.89, y: 297.85))
        bezierPath.addCurve(to: CGPoint(x: 456.16, y: 273.32), controlPoint1: CGPoint(x: 444.88, y: 301.46), controlPoint2: CGPoint(x: 449.22, y: 296.41))
        bezierPath.addCurve(to: CGPoint(x: 460.21, y: 237.55), controlPoint1: CGPoint(x: 459.63, y: 261.93), controlPoint2: CGPoint(x: 460.06, y: 258.18))
        bezierPath.addCurve(to: CGPoint(x: 456.88, y: 202.2), controlPoint1: CGPoint(x: 460.35, y: 217.49), controlPoint2: CGPoint(x: 459.92, y: 212.88))
        bezierPath.addCurve(to: CGPoint(x: 355.81, y: 105.54), controlPoint1: CGPoint(x: 443.14, y: 152.86), controlPoint2: CGPoint(x: 404.82, y: 116.36))
        bezierPath.addCurve(to: CGPoint(x: 306.93, y: 104.1), controlPoint1: CGPoint(x: 342.5, y: 102.51), controlPoint2: CGPoint(x: 312.72, y: 101.65))
        bezierPath.close()
        UIColor.white.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 307.51, y: 146.95))
        bezier2Path.addCurve(to: CGPoint(x: 307.22, y: 166.86), controlPoint1: CGPoint(x: 301.87, y: 152.72), controlPoint2: CGPoint(x: 301.87, y: 161.95))
        bezier2Path.addCurve(to: CGPoint(x: 322.11, y: 170.46), controlPoint1: CGPoint(x: 310.69, y: 170.03), controlPoint2: CGPoint(x: 312.43, y: 170.46))
        bezier2Path.addCurve(to: CGPoint(x: 374.75, y: 192.82), controlPoint1: CGPoint(x: 343.23, y: 170.46), controlPoint2: CGPoint(x: 360.72, y: 177.96))
        bezier2Path.addCurve(to: CGPoint(x: 388.92, y: 256.59), controlPoint1: CGPoint(x: 390.22, y: 209.13), controlPoint2: CGPoint(x: 396, y: 235.67))
        bezier2Path.addCurve(to: CGPoint(x: 399.91, y: 282.99), controlPoint1: CGPoint(x: 382.7, y: 274.91), controlPoint2: CGPoint(x: 386.03, y: 282.99))
        bezier2Path.addCurve(to: CGPoint(x: 417.69, y: 260.34), controlPoint1: CGPoint(x: 410.03, y: 282.99), controlPoint2: CGPoint(x: 412.92, y: 279.53))
        bezier2Path.addCurve(to: CGPoint(x: 355.52, y: 146.51), controlPoint1: CGPoint(x: 429.98, y: 211.87), controlPoint2: CGPoint(x: 403.67, y: 163.97))
        bezier2Path.addCurve(to: CGPoint(x: 330.21, y: 143.49), controlPoint1: CGPoint(x: 351.32, y: 144.93), controlPoint2: CGPoint(x: 342.36, y: 143.92))
        bezier2Path.addLine(to: CGPoint(x: 311.41, y: 142.76))
        bezier2Path.addLine(to: CGPoint(x: 307.51, y: 146.95))
        bezier2Path.close()
        UIColor.white.setFill()
        bezier2Path.fill()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 171.01, y: 154.45))
        bezier3Path.addCurve(to: CGPoint(x: 157.71, y: 175.8), controlPoint1: CGPoint(x: 162.33, y: 158.34), controlPoint2: CGPoint(x: 158.43, y: 164.84))
        bezier3Path.addCurve(to: CGPoint(x: 160.02, y: 190.37), controlPoint1: CGPoint(x: 157.27, y: 182.87), controlPoint2: CGPoint(x: 157.71, y: 186.04))
        bezier3Path.addLine(to: CGPoint(x: 162.91, y: 196))
        bezier3Path.addLine(to: CGPoint(x: 158.43, y: 198.59))
        bezier3Path.addCurve(to: CGPoint(x: 134.28, y: 224.42), controlPoint1: CGPoint(x: 151.63, y: 202.63), controlPoint2: CGPoint(x: 139.05, y: 216.05))
        bezier3Path.addCurve(to: CGPoint(x: 127.63, y: 242.45), controlPoint1: CGPoint(x: 131.97, y: 228.46), controlPoint2: CGPoint(x: 128.93, y: 236.54))
        bezier3Path.addCurve(to: CGPoint(x: 130.67, y: 310.4), controlPoint1: CGPoint(x: 124.16, y: 257.6), controlPoint2: CGPoint(x: 125.61, y: 287.9))
        bezier3Path.addCurve(to: CGPoint(x: 129.37, y: 397.68), controlPoint1: CGPoint(x: 143.54, y: 368.25), controlPoint2: CGPoint(x: 143.54, y: 371.86))
        bezier3Path.addCurve(to: CGPoint(x: 127.05, y: 411.96), controlPoint1: CGPoint(x: 127.92, y: 400.57), controlPoint2: CGPoint(x: 127.05, y: 405.47))
        bezier3Path.addCurve(to: CGPoint(x: 130.81, y: 426.82), controlPoint1: CGPoint(x: 127.05, y: 420.48), controlPoint2: CGPoint(x: 127.63, y: 422.64))
        bezier3Path.addCurve(to: CGPoint(x: 188.8, y: 424.52), controlPoint1: CGPoint(x: 140.5, y: 439.52), controlPoint2: CGPoint(x: 148.45, y: 439.09))
        bezier3Path.addCurve(to: CGPoint(x: 222.92, y: 412.11), controlPoint1: CGPoint(x: 206.15, y: 418.17), controlPoint2: CGPoint(x: 221.47, y: 412.54))
        bezier3Path.addCurve(to: CGPoint(x: 225.38, y: 414.13), controlPoint1: CGPoint(x: 224.8, y: 411.39), controlPoint2: CGPoint(x: 225.38, y: 411.82))
        bezier3Path.addCurve(to: CGPoint(x: 244.18, y: 432.02), controlPoint1: CGPoint(x: 225.38, y: 418.02), controlPoint2: CGPoint(x: 236.08, y: 428.41))
        bezier3Path.addCurve(to: CGPoint(x: 278.59, y: 433.89), controlPoint1: CGPoint(x: 253.29, y: 436.06), controlPoint2: CGPoint(x: 269.19, y: 436.92))
        bezier3Path.addCurve(to: CGPoint(x: 303.75, y: 411.53), controlPoint1: CGPoint(x: 287.99, y: 430.72), controlPoint2: CGPoint(x: 299.7, y: 420.48))
        bezier3Path.addCurve(to: CGPoint(x: 307.08, y: 393.21), controlPoint1: CGPoint(x: 306.21, y: 406.48), controlPoint2: CGPoint(x: 306.93, y: 402.15))
        bezier3Path.addLine(to: CGPoint(x: 307.08, y: 381.52))
        bezier3Path.addLine(to: CGPoint(x: 338.16, y: 370.27))
        bezier3Path.addCurve(to: CGPoint(x: 382.85, y: 348.63), controlPoint1: CGPoint(x: 373.59, y: 357.43), controlPoint2: CGPoint(x: 379.23, y: 354.84))
        bezier3Path.addCurve(to: CGPoint(x: 363.32, y: 308.38), controlPoint1: CGPoint(x: 392.53, y: 332.91), controlPoint2: CGPoint(x: 384.44, y: 316.46))
        bezier3Path.addCurve(to: CGPoint(x: 322.26, y: 264.96), controlPoint1: CGPoint(x: 346.7, y: 302.18), controlPoint2: CGPoint(x: 336.43, y: 291.21))
        bezier3Path.addCurve(to: CGPoint(x: 311.85, y: 246.49), controlPoint1: CGPoint(x: 318.79, y: 258.61), controlPoint2: CGPoint(x: 314.16, y: 250.24))
        bezier3Path.addCurve(to: CGPoint(x: 307.8, y: 238.85), controlPoint1: CGPoint(x: 309.68, y: 242.74), controlPoint2: CGPoint(x: 307.8, y: 239.28))
        bezier3Path.addCurve(to: CGPoint(x: 298.54, y: 223.99), controlPoint1: CGPoint(x: 307.8, y: 238.41), controlPoint2: CGPoint(x: 303.61, y: 231.78))
        bezier3Path.addCurve(to: CGPoint(x: 220.03, y: 178.54), controlPoint1: CGPoint(x: 276.71, y: 190.95), controlPoint2: CGPoint(x: 250.54, y: 175.8))
        bezier3Path.addLine(to: CGPoint(x: 209.47, y: 179.41))
        bezier3Path.addLine(to: CGPoint(x: 209.47, y: 175.8))
        bezier3Path.addCurve(to: CGPoint(x: 194, y: 153.73), controlPoint1: CGPoint(x: 209.47, y: 167.14), controlPoint2: CGPoint(x: 202.68, y: 157.33))
        bezier3Path.addCurve(to: CGPoint(x: 171.01, y: 154.45), controlPoint1: CGPoint(x: 187.49, y: 150.99), controlPoint2: CGPoint(x: 178.1, y: 151.28))
        bezier3Path.close()
        UIColor.white.setFill()
        bezier3Path.fill()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 311.56, y: 186.77))
        bezier4Path.addCurve(to: CGPoint(x: 311.7, y: 206.82), controlPoint1: CGPoint(x: 306.21, y: 192.1), controlPoint2: CGPoint(x: 306.35, y: 201.19))
        bezier4Path.addCurve(to: CGPoint(x: 322.84, y: 210.86), controlPoint1: CGPoint(x: 314.88, y: 210.14), controlPoint2: CGPoint(x: 316.76, y: 210.86))
        bezier4Path.addCurve(to: CGPoint(x: 344.96, y: 219.66), controlPoint1: CGPoint(x: 331.08, y: 210.86), controlPoint2: CGPoint(x: 340.19, y: 214.61))
        bezier4Path.addCurve(to: CGPoint(x: 350.46, y: 230.33), controlPoint1: CGPoint(x: 346.7, y: 221.53), controlPoint2: CGPoint(x: 349.15, y: 226.44))
        bezier4Path.addCurve(to: CGPoint(x: 350.46, y: 243.89), controlPoint1: CGPoint(x: 352.48, y: 236.97), controlPoint2: CGPoint(x: 352.48, y: 238.12))
        bezier4Path.addCurve(to: CGPoint(x: 352.48, y: 262.94), controlPoint1: CGPoint(x: 347.13, y: 253.42), controlPoint2: CGPoint(x: 347.71, y: 258.03))
        bezier4Path.addCurve(to: CGPoint(x: 372.43, y: 263.8), controlPoint1: CGPoint(x: 357.97, y: 268.42), controlPoint2: CGPoint(x: 367.81, y: 268.85))
        bezier4Path.addCurve(to: CGPoint(x: 378.07, y: 221.68), controlPoint1: CGPoint(x: 379.23, y: 256.59), controlPoint2: CGPoint(x: 381.98, y: 236.1))
        bezier4Path.addCurve(to: CGPoint(x: 364.92, y: 198.59), controlPoint1: CGPoint(x: 375.47, y: 211.43), controlPoint2: CGPoint(x: 372.15, y: 205.66))
        bezier4Path.addCurve(to: CGPoint(x: 329.2, y: 183.74), controlPoint1: CGPoint(x: 354.5, y: 188.06), controlPoint2: CGPoint(x: 345.68, y: 184.46))
        bezier4Path.addCurve(to: CGPoint(x: 311.56, y: 186.77), controlPoint1: CGPoint(x: 315.75, y: 183.16), controlPoint2: CGPoint(x: 315.03, y: 183.3))
        bezier4Path.close()
        UIColor.white.setFill()
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

