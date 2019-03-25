//
//  ValidSign.swift
//  Burb
//
//  Created by Pavel Bukharov on 19.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
final class ValidSign: UIView {
    override func draw(_ rect: CGRect) {
        ValidSignStyleKit.drawValidSign(frame: rect, resizing: .aspectFit)
    }
}

public class ValidSignStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawValidSign(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 60, height: 60), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 60, height: 60), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 60, y: resizedFrame.height / 60)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 0.751, green: 0.254, blue: 0.272, alpha: 1.000)
        let strokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        //// Group
        //// Rounded_Rectangle_3_копия_copy_2 Drawing
        let rounded_Rectangle_3__copy_2Path = UIBezierPath(roundedRect: CGRect(x: 10, y: 10, width: 40, height: 40), cornerRadius: 20)
        fillColor.setFill()
        rounded_Rectangle_3__copy_2Path.fill()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 19.81, y: 31.07))
        bezierPath.addLine(to: CGPoint(x: 26.25, y: 37.4))
        bezierPath.addLine(to: CGPoint(x: 39.13, y: 23.84))
        strokeColor.setStroke()
        bezierPath.lineWidth = 4
        bezierPath.miterLimit = 4
        bezierPath.lineCapStyle = .round
        bezierPath.stroke()
        
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

