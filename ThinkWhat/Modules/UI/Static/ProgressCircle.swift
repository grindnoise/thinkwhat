//
//  ProgressCircle.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressCircle: UIView {
    
    private var bgColor: UIColor = UIColor(red: 0.516, green: 0.516, blue: 0.516, alpha: 0.207)
    private var fgColor: UIColor = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.000)
    private var textColor: UIColor = .label
    private var lineWidth: CGFloat = 13
    private var progress: CGFloat = 0
    
    public func setupUI(foregroundColor: UIColor,
                        backgroundColor: UIColor = UIColor(red: 0.516, green: 0.516, blue: 0.516, alpha: 0.207),
                        textColor _textColor: UIColor = .label,
                        progress _progress: CGFloat) {
        fgColor = foregroundColor
        bgColor = backgroundColor
        textColor = _textColor
        progress = _progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
//        ProgressCircleStyleKit.drawCanvas1(frame: rect, resizing: .aspectFit, width: 13, progress: 0.6)
        ProgressCircleStyleKit.drawCanvas1(frame: rect,
                                           resizing: .aspectFit,
                                           width: lineWidth,
                                           progress: progress,
                                           foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : fgColor,
                                           backgroundColor: bgColor,
                                           textColor: textColor,
                                           lineWidth: lineWidth)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
    }
    
    override var frame: CGRect {
        didSet {
            lineWidth = frame.width * 0.15
        }
    }
    
    override var bounds: CGRect {
        didSet {
            lineWidth = frame.width * 0.15
        }
    }
}

public class ProgressCircleStyleKit : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawCanvas1(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 115, height: 115), resizing: ResizingBehavior = .aspectFit, width: CGFloat = 13, progress: CGFloat = 0.655, foregroundColor: UIColor = .systemRed, backgroundColor: UIColor = .systemGray, textColor _textColor: UIColor = .label, lineWidth: CGFloat) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 115, height: 115), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 115, y: resizedFrame.height / 115)


        //// Color Declarations
        let bg = backgroundColor
        let fg = foregroundColor
        let textColor = _textColor

        //// Variable Declarations
        let fontSize: CGFloat = width * 2
        let resultAngle: CGFloat = -1 * progress * 360 + 90
        let percent: CGFloat = progress * 100
        let formattedText = "\(Int(round(percent)))" + "%"
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 10.5, y: 12, width: 93, height: 93))
        bg.setStroke()
        ovalPath.lineWidth = width
        ovalPath.stroke()
        
        
        //// Oval 2 Drawing
        let oval2Rect = CGRect(x: 10.5, y: 12, width: 93, height: 93)
        let oval2Path = UIBezierPath()
        oval2Path.addArc(withCenter: CGPoint(x: oval2Rect.midX, y: oval2Rect.midY), radius: oval2Rect.width / 2, startAngle: -90 * CGFloat.pi/180, endAngle: -resultAngle * CGFloat.pi/180, clockwise: true)
        
        fg.setStroke()
        oval2Path.lineWidth = width
        oval2Path.lineCapStyle = .round
        oval2Path.stroke()


        //// Text Drawing
        let textRect = CGRect(x: 0, y: 0, width: 115, height: 115)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes = [
            .font: UIFont(name: "OpenSans-Bold", size: fontSize)!,
            .foregroundColor: textColor,
            .paragraphStyle: textStyle,
        ] as [NSAttributedString.Key: Any]

        let textTextHeight: CGFloat = formattedText.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: textRect)
        formattedText.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context.restoreGState()

        context.restoreGState()

    }




        @objc//(ProgressCircleStyleKitResizingBehavior)
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

