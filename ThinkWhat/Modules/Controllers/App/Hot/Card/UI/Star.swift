//
//  Star.swift
//  Burb
//
//  Created by Pavel Bukharov on 12.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class Star: UIView {
    
    public enum StarState: String {
        case Full, Half, Empty
    }
    
    let state: StarState
    
    init(frame: CGRect, state: StarState) {
        self.state = state
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let stateString = aDecoder.decodeObject(forKey: "state") as? String,
            let frame = aDecoder.decodeCGRect(forKey: "frame") as? CGRect {
            self.state = StarState(rawValue: stateString)!
            super.init(frame: frame)
            self.layer.isOpaque = false
        } else {
            fatalError("Decoding failed")
        }
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.state.rawValue, forKey: "state")
        aCoder.encode(self.frame, forKey: "frame")
    }
    
    override func draw(_ rect: CGRect) {
        if state == .Full {
            StarStyleKit.drawFullStar(frame: rect, resizing: .aspectFit)
        } else if state == .Half {
            StarStyleKit.drawHalfStar(frame: rect, resizing: .aspectFit)
        } else if state == .Empty {
            StarStyleKit.drawEmptyStar(frame: rect, resizing: .aspectFit)
        }
    }
}

public class StarStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawFullStar(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 100, height: 100), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 100, y: resizedFrame.height / 100)
        
        
        //// Color Declarations
        let main = UIColor.systemYellow
//        let main = UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)
        
        //// Star Drawing
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 50, y: 4.5))
        starPath.addLine(to: CGPoint(x: 62.19, y: 36.88))
        starPath.addLine(to: CGPoint(x: 96.13, y: 38.7))
        starPath.addLine(to: CGPoint(x: 69.72, y: 60.54))
        starPath.addLine(to: CGPoint(x: 78.51, y: 94.05))
        starPath.addLine(to: CGPoint(x: 50, y: 75.16))
        starPath.addLine(to: CGPoint(x: 21.49, y: 94.05))
        starPath.addLine(to: CGPoint(x: 30.28, y: 60.54))
        starPath.addLine(to: CGPoint(x: 3.87, y: 38.7))
        starPath.addLine(to: CGPoint(x: 37.81, y: 36.88))
        starPath.close()
        main.setFill()
        starPath.fill()
        main.setStroke()
        starPath.lineWidth = 3
        starPath.stroke()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawEmptyStar(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 100, height: 100), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 100, y: resizedFrame.height / 100)
        
        
        //// Color Declarations
        let main = UIColor.systemYellow
//        let main = UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)
        
        //// Star Drawing
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x: 50, y: 4.5))
        starPath.addLine(to: CGPoint(x: 62.19, y: 36.88))
        starPath.addLine(to: CGPoint(x: 96.13, y: 38.7))
        starPath.addLine(to: CGPoint(x: 69.72, y: 60.54))
        starPath.addLine(to: CGPoint(x: 78.51, y: 94.05))
        starPath.addLine(to: CGPoint(x: 50, y: 75.16))
        starPath.addLine(to: CGPoint(x: 21.49, y: 94.05))
        starPath.addLine(to: CGPoint(x: 30.28, y: 60.54))
        starPath.addLine(to: CGPoint(x: 3.87, y: 38.7))
        starPath.addLine(to: CGPoint(x: 37.81, y: 36.88))
        starPath.close()
        main.setStroke()
        starPath.lineWidth = 3
        starPath.stroke()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawHalfStar(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 100, height: 100), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 100, y: resizedFrame.height / 100)
        
        
        //// Color Declarations
        let main = UIColor.systemYellow
//        let main = UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 49, y: 7.5))
        bezierPath.addCurve(to: CGPoint(x: 49, y: 75.76), controlPoint1: CGPoint(x: 49, y: 7.5), controlPoint2: CGPoint(x: 49, y: 47.5))
        bezierPath.addLine(to: CGPoint(x: 21.19, y: 94))
        bezierPath.addLine(to: CGPoint(x: 29.76, y: 61.63))
        bezierPath.addLine(to: CGPoint(x: 4, y: 40.54))
        bezierPath.addLine(to: CGPoint(x: 37.11, y: 38.78))
        bezierPath.addCurve(to: CGPoint(x: 43.33, y: 22.41), controlPoint1: CGPoint(x: 37.11, y: 38.78), controlPoint2: CGPoint(x: 40.27, y: 30.46))
        bezierPath.addCurve(to: CGPoint(x: 49, y: 7.5), controlPoint1: CGPoint(x: 46.21, y: 14.84), controlPoint2: CGPoint(x: 49, y: 7.5))
        bezierPath.addLine(to: CGPoint(x: 49, y: 7.5))
        bezierPath.close()
        main.setFill()
        bezierPath.fill()
        main.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 52, y: 7.5))
        bezier2Path.addCurve(to: CGPoint(x: 52, y: 75.76), controlPoint1: CGPoint(x: 52, y: 7.5), controlPoint2: CGPoint(x: 52, y: 47.5))
        bezier2Path.addLine(to: CGPoint(x: 78.88, y: 94))
        bezier2Path.addLine(to: CGPoint(x: 70.6, y: 61.63))
        bezier2Path.addLine(to: CGPoint(x: 95.5, y: 40.54))
        bezier2Path.addLine(to: CGPoint(x: 63.49, y: 38.78))
        bezier2Path.addCurve(to: CGPoint(x: 57.48, y: 22.41), controlPoint1: CGPoint(x: 63.49, y: 38.78), controlPoint2: CGPoint(x: 60.44, y: 30.46))
        bezier2Path.addCurve(to: CGPoint(x: 52, y: 7.5), controlPoint1: CGPoint(x: 54.7, y: 14.84), controlPoint2: CGPoint(x: 52, y: 7.5))
        bezier2Path.addLine(to: CGPoint(x: 52, y: 7.5))
        bezier2Path.close()
        main.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.stroke()
        
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
