//
//  ClaimBarButton.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.06.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ClaimBarButton: UIView {
    override func draw(_ rect: CGRect) {
        WarningStyleKit.drawWarning(frame: rect, resizing: .aspectFit)
    }
}

public class WarningStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawWarning(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 120, height: 120), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 120, height: 120), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 120, y: resizedFrame.height / 120)
        
        
        //// Color Declarations
        let fillColor = K_COLOR_RED//UIColor(red: 1.000, green: 0.538, blue: 0.000, alpha: 1.000)

        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 57.54, y: 30.77))
        bezier3Path.addCurve(to: CGPoint(x: 55.98, y: 32.53), controlPoint1: CGPoint(x: 56.97, y: 31.18), controlPoint2: CGPoint(x: 56.44, y: 31.76))
        bezier3Path.addLine(to: CGPoint(x: 21.33, y: 89.72))
        bezier3Path.addCurve(to: CGPoint(x: 24.7, y: 95.71), controlPoint1: CGPoint(x: 19.32, y: 93.03), controlPoint2: CGPoint(x: 20.83, y: 95.71))
        bezier3Path.addLine(to: CGPoint(x: 94.51, y: 95.71))
        bezier3Path.addCurve(to: CGPoint(x: 97.88, y: 89.72), controlPoint1: CGPoint(x: 98.37, y: 95.71), controlPoint2: CGPoint(x: 99.89, y: 93.03))
        bezier3Path.addLine(to: CGPoint(x: 63.23, y: 32.53))
        bezier3Path.addCurve(to: CGPoint(x: 57.54, y: 30.77), controlPoint1: CGPoint(x: 61.69, y: 29.99), controlPoint2: CGPoint(x: 59.42, y: 29.4))
        bezier3Path.close()
        bezier3Path.move(to: CGPoint(x: 67.26, y: 23.1))
        bezier3Path.addLine(to: CGPoint(x: 108.43, y: 91.16))
        bezier3Path.addCurve(to: CGPoint(x: 101.2, y: 104), controlPoint1: CGPoint(x: 112.72, y: 98.26), controlPoint2: CGPoint(x: 109.48, y: 104))
        bezier3Path.addLine(to: CGPoint(x: 17.8, y: 104))
        bezier3Path.addCurve(to: CGPoint(x: 10.57, y: 91.16), controlPoint1: CGPoint(x: 9.52, y: 104), controlPoint2: CGPoint(x: 6.28, y: 98.25))
        bezier3Path.addLine(to: CGPoint(x: 51.74, y: 23.1))
        bezier3Path.addCurve(to: CGPoint(x: 52.8, y: 21.55), controlPoint1: CGPoint(x: 52.07, y: 22.54), controlPoint2: CGPoint(x: 52.43, y: 22.02))
        bezier3Path.addCurve(to: CGPoint(x: 67.26, y: 23.1), controlPoint1: CGPoint(x: 57.11, y: 16.04), controlPoint2: CGPoint(x: 63.31, y: 16.56))
        bezier3Path.close()
        bezier3Path.move(to: CGPoint(x: 59.5, y: 42))
        bezier3Path.addLine(to: CGPoint(x: 59.5, y: 42))
        bezier3Path.addLine(to: CGPoint(x: 59.5, y: 42))
        bezier3Path.addLine(to: CGPoint(x: 59.78, y: 42))
        bezier3Path.addCurve(to: CGPoint(x: 64.59, y: 45.37), controlPoint1: CGPoint(x: 61.93, y: 42), controlPoint2: CGPoint(x: 63.85, y: 43.35))
        bezier3Path.addCurve(to: CGPoint(x: 65, y: 50.3), controlPoint1: CGPoint(x: 65, y: 46.67), controlPoint2: CGPoint(x: 65, y: 47.88))
        bezier3Path.addLine(to: CGPoint(x: 65, y: 69.59))
        bezier3Path.addCurve(to: CGPoint(x: 64.64, y: 74.42), controlPoint1: CGPoint(x: 65, y: 72.12), controlPoint2: CGPoint(x: 65, y: 73.33))
        bezier3Path.addLine(to: CGPoint(x: 64.59, y: 74.63))
        bezier3Path.addCurve(to: CGPoint(x: 59.77, y: 78), controlPoint1: CGPoint(x: 63.85, y: 76.65), controlPoint2: CGPoint(x: 61.93, y: 78))
        bezier3Path.addCurve(to: CGPoint(x: 59.5, y: 78), controlPoint1: CGPoint(x: 59.5, y: 78), controlPoint2: CGPoint(x: 59.5, y: 78))
        bezier3Path.addLine(to: CGPoint(x: 59.5, y: 78))
        bezier3Path.addLine(to: CGPoint(x: 59.5, y: 78))
        bezier3Path.addLine(to: CGPoint(x: 59.22, y: 78))
        bezier3Path.addCurve(to: CGPoint(x: 54.41, y: 74.63), controlPoint1: CGPoint(x: 57.07, y: 78), controlPoint2: CGPoint(x: 55.15, y: 76.65))
        bezier3Path.addCurve(to: CGPoint(x: 54, y: 69.7), controlPoint1: CGPoint(x: 54, y: 73.33), controlPoint2: CGPoint(x: 54, y: 72.12))
        bezier3Path.addLine(to: CGPoint(x: 54, y: 69.59))
        bezier3Path.addCurve(to: CGPoint(x: 54.36, y: 45.58), controlPoint1: CGPoint(x: 54, y: 47.88), controlPoint2: CGPoint(x: 54, y: 46.67))
        bezier3Path.addLine(to: CGPoint(x: 54.41, y: 45.37))
        bezier3Path.addCurve(to: CGPoint(x: 59.22, y: 42), controlPoint1: CGPoint(x: 55.15, y: 43.35), controlPoint2: CGPoint(x: 57.07, y: 42))
        bezier3Path.addCurve(to: CGPoint(x: 59.5, y: 42), controlPoint1: CGPoint(x: 59.5, y: 42), controlPoint2: CGPoint(x: 59.5, y: 42))
        bezier3Path.addLine(to: CGPoint(x: 59.5, y: 42))
        bezier3Path.close()
        bezier3Path.move(to: CGPoint(x: 65, y: 86.5))
        bezier3Path.addCurve(to: CGPoint(x: 59.5, y: 92), controlPoint1: CGPoint(x: 65, y: 89.54), controlPoint2: CGPoint(x: 62.54, y: 92))
        bezier3Path.addCurve(to: CGPoint(x: 54, y: 86.5), controlPoint1: CGPoint(x: 56.46, y: 92), controlPoint2: CGPoint(x: 54, y: 89.54))
        bezier3Path.addCurve(to: CGPoint(x: 59.5, y: 81), controlPoint1: CGPoint(x: 54, y: 83.46), controlPoint2: CGPoint(x: 56.46, y: 81))
        bezier3Path.addCurve(to: CGPoint(x: 65, y: 86.5), controlPoint1: CGPoint(x: 62.54, y: 81), controlPoint2: CGPoint(x: 65, y: 83.46))
        bezier3Path.close()
        fillColor.setFill()
        bezier3Path.fill()
        
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

@IBDesignable
class ClaimBarButtonAnimated: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var endColor : UIColor!
    var startColor : UIColor!
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProperties()
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupProperties()
        setupLayers()
    }
    
    
    
    func setupProperties(){
        self.endColor = UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
        self.startColor = UIColor(red:1.00, green: 0.83, blue:0.47, alpha:1.0)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
        let warning_sign = CALayer()
        warning_sign.frame = CGRect(x: -0.83, y: 6.89, width: 101.65, height: 86.22)
        self.layer.addSublayer(warning_sign)
        layers["warning_sign"] = warning_sign
        let Group2 = CALayer()
        Group2.frame = CGRect(x: 0, y: 0, width: 101.65, height: 86.22)
        warning_sign.addSublayer(Group2)
        layers["Group2"] = Group2
        let Rectangle = CAShapeLayer()
        Rectangle.frame = CGRect(x: 0, y: 0, width: 101.65, height: 86.22)
        Rectangle.path = RectanglePath().cgPath
        Group2.addSublayer(Rectangle)
        layers["Rectangle"] = Rectangle
        let RectangleCopy = CAShapeLayer()
        RectangleCopy.frame = CGRect(x: 11.56, y: 12.27, width: 78.33, height: 65.66)
        RectangleCopy.path = RectangleCopyPath().cgPath
        Group2.addSublayer(RectangleCopy)
        layers["RectangleCopy"] = RectangleCopy
        let Rectangle2 = CAShapeLayer()
        Rectangle2.frame = CGRect(x: 45.33, y: 24.22, width: 11, height: 36)
        Rectangle2.path = Rectangle2Path().cgPath
        Group2.addSublayer(Rectangle2)
        layers["Rectangle2"] = Rectangle2
        let Oval = CAShapeLayer()
        Oval.frame = CGRect(x: 45.33, y: 63.22, width: 11, height: 11)
        Oval.path = OvalPath().cgPath
        Group2.addSublayer(Oval)
        layers["Oval"] = Oval
        
        resetLayerProperties(forLayerIdentifiers: nil)
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("Rectangle"){
            let Rectangle = layers["Rectangle"] as! CAShapeLayer
            Rectangle.fillColor   = self.startColor.cgColor
            Rectangle.strokeColor = UIColor.black.cgColor
            Rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("RectangleCopy"){
            let RectangleCopy = layers["RectangleCopy"] as! CAShapeLayer
            RectangleCopy.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            RectangleCopy.strokeColor = UIColor.black.cgColor
            RectangleCopy.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("Rectangle2"){
            let Rectangle2 = layers["Rectangle2"] as! CAShapeLayer
            Rectangle2.fillColor   = self.startColor.cgColor
            Rectangle2.strokeColor = UIColor.black.cgColor
            Rectangle2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("Oval"){
            let Oval = layers["Oval"] as! CAShapeLayer
            Oval.fillColor   = self.startColor.cgColor
            Oval.strokeColor = UIColor.black.cgColor
            Oval.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.4
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Rectangle animation
        let RectangleFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleFillColorAnim.values         = [self.startColor.cgColor,
                                                 self.endColor.cgColor]
        RectangleFillColorAnim.keyTimes       = [0, 1]
        RectangleFillColorAnim.duration       = 0.4
        RectangleFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let RectangleEnableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleFillColorAnim], fillMode:fillMode)
        layers["Rectangle"]?.add(RectangleEnableAnim, forKey:"RectangleEnableAnim")
        
        ////Rectangle2 animation
        let Rectangle2FillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        Rectangle2FillColorAnim.values         = [self.startColor.cgColor,
                                                  self.endColor.cgColor]
        Rectangle2FillColorAnim.keyTimes       = [0, 1]
        Rectangle2FillColorAnim.duration       = 0.4
        Rectangle2FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let Rectangle2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [Rectangle2FillColorAnim], fillMode:fillMode)
        layers["Rectangle2"]?.add(Rectangle2EnableAnim, forKey:"Rectangle2EnableAnim")
        
        ////Oval animation
        let OvalFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        OvalFillColorAnim.values         = [self.startColor.cgColor,
                                            self.endColor.cgColor]
        OvalFillColorAnim.keyTimes       = [0, 1]
        OvalFillColorAnim.duration       = 0.4
        OvalFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let OvalEnableAnim : CAAnimationGroup = QCMethod.group(animations: [OvalFillColorAnim], fillMode:fillMode)
        layers["Oval"]?.add(OvalEnableAnim, forKey:"OvalEnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.4
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Rectangle animation
        let RectangleFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleFillColorAnim.values         = [self.endColor.cgColor,
                                                 self.startColor.cgColor]
        RectangleFillColorAnim.keyTimes       = [0, 1]
        RectangleFillColorAnim.duration       = 0.4
        RectangleFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let RectangleDisableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleFillColorAnim], fillMode:fillMode)
        layers["Rectangle"]?.add(RectangleDisableAnim, forKey:"RectangleDisableAnim")
        
        ////Rectangle2 animation
        let Rectangle2FillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        Rectangle2FillColorAnim.values         = [self.endColor.cgColor,
                                                  self.startColor.cgColor]
        Rectangle2FillColorAnim.keyTimes       = [0, 1]
        Rectangle2FillColorAnim.duration       = 0.4
        Rectangle2FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let Rectangle2DisableAnim : CAAnimationGroup = QCMethod.group(animations: [Rectangle2FillColorAnim], fillMode:fillMode)
        layers["Rectangle2"]?.add(Rectangle2DisableAnim, forKey:"Rectangle2DisableAnim")
        
        ////Oval animation
        let OvalFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        OvalFillColorAnim.values         = [self.endColor.cgColor,
                                            self.startColor.cgColor]
        OvalFillColorAnim.keyTimes       = [0, 1]
        OvalFillColorAnim.duration       = 0.4
        OvalFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let OvalDisableAnim : CAAnimationGroup = QCMethod.group(animations: [OvalFillColorAnim], fillMode:fillMode)
        layers["Oval"]?.add(OvalDisableAnim, forKey:"OvalDisableAnim")
    }
    
    //MARK: - Animation Cleanup
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if let completionBlock = completionBlocks[anim]{
            completionBlocks.removeValue(forKey: anim)
            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
            }
            completionBlock(flag)
        }
    }
    
    func updateLayerValues(forAnimationId identifier: String){
        if identifier == "enable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Rectangle"]!.animation(forKey: "RectangleEnableAnim"), theLayer:layers["Rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Rectangle2"]!.animation(forKey: "Rectangle2EnableAnim"), theLayer:layers["Rectangle2"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Oval"]!.animation(forKey: "OvalEnableAnim"), theLayer:layers["Oval"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Rectangle"]!.animation(forKey: "RectangleDisableAnim"), theLayer:layers["Rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Rectangle2"]!.animation(forKey: "Rectangle2DisableAnim"), theLayer:layers["Rectangle2"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Oval"]!.animation(forKey: "OvalDisableAnim"), theLayer:layers["Oval"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["Rectangle"]?.removeAnimation(forKey: "RectangleEnableAnim")
            layers["Rectangle2"]?.removeAnimation(forKey: "Rectangle2EnableAnim")
            layers["Oval"]?.removeAnimation(forKey: "OvalEnableAnim")
        }
        else if identifier == "disable"{
            layers["Rectangle"]?.removeAnimation(forKey: "RectangleDisableAnim")
            layers["Rectangle2"]?.removeAnimation(forKey: "Rectangle2DisableAnim")
            layers["Oval"]?.removeAnimation(forKey: "OvalDisableAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func RectanglePath() -> UIBezierPath{
        let RectanglePath = UIBezierPath()
        RectanglePath.move(to: CGPoint(x: 43.062, y: 5.32))
        RectanglePath.addCurve(to: CGPoint(x: 58.59, y: 5.32), controlPoint1:CGPoint(x: 47.35, y: -1.77), controlPoint2:CGPoint(x: 54.298, y: -1.777))
        RectanglePath.addLine(to: CGPoint(x: 99.756, y: 73.387))
        RectanglePath.addCurve(to: CGPoint(x: 92.521, y: 86.225), controlPoint1:CGPoint(x: 104.044, y: 80.477), controlPoint2:CGPoint(x: 100.808, y: 86.225))
        RectanglePath.addLine(to: CGPoint(x: 9.13, y: 86.225))
        RectanglePath.addCurve(to: CGPoint(x: 1.896, y: 73.387), controlPoint1:CGPoint(x: 0.847, y: 86.225), controlPoint2:CGPoint(x: -2.397, y: 80.484))
        RectanglePath.addLine(to: CGPoint(x: 43.062, y: 5.32))
        RectanglePath.close()
        RectanglePath.move(to: CGPoint(x: 43.062, y: 5.32))
        
        return RectanglePath
    }
    
    func RectangleCopyPath() -> UIBezierPath{
        let RectangleCopyPath = UIBezierPath()
        RectangleCopyPath.move(to: CGPoint(x: 35.537, y: 2.48))
        RectangleCopyPath.addCurve(to: CGPoint(x: 42.791, y: 2.48), controlPoint1:CGPoint(x: 37.54, y: -0.826), controlPoint2:CGPoint(x: 40.787, y: -0.827))
        RectangleCopyPath.addLine(to: CGPoint(x: 77.442, y: 59.675))
        RectangleCopyPath.addCurve(to: CGPoint(x: 74.068, y: 65.662), controlPoint1:CGPoint(x: 79.445, y: 62.981), controlPoint2:CGPoint(x: 77.937, y: 65.662))
        RectangleCopyPath.addLine(to: CGPoint(x: 4.26, y: 65.662))
        RectangleCopyPath.addCurve(to: CGPoint(x: 0.886, y: 59.675), controlPoint1:CGPoint(x: 0.393, y: 65.662), controlPoint2:CGPoint(x: -1.118, y: 62.982))
        RectangleCopyPath.addLine(to: CGPoint(x: 35.537, y: 2.48))
        RectangleCopyPath.close()
        RectangleCopyPath.move(to: CGPoint(x: 35.537, y: 2.48))
        
        return RectangleCopyPath
    }
    
    func Rectangle2Path() -> UIBezierPath{
        let Rectangle2Path = UIBezierPath()
        Rectangle2Path.move(to: CGPoint(x: 11, y: 18))
        Rectangle2Path.addLine(to: CGPoint(x: 11, y: 30.5))
        Rectangle2Path.addCurve(to: CGPoint(x: 5.5, y: 36), controlPoint1:CGPoint(x: 11, y: 33.538), controlPoint2:CGPoint(x: 8.538, y: 36))
        Rectangle2Path.addLine(to: CGPoint(x: 5.5, y: 36))
        Rectangle2Path.addCurve(to: CGPoint(x: 0, y: 30.5), controlPoint1:CGPoint(x: 2.462, y: 36), controlPoint2:CGPoint(x: 0, y: 33.538))
        Rectangle2Path.addLine(to: CGPoint(x: 0, y: 5.5))
        Rectangle2Path.addCurve(to: CGPoint(x: 5.5, y: 0), controlPoint1:CGPoint(x: 0, y: 2.462), controlPoint2:CGPoint(x: 2.462, y: 0))
        Rectangle2Path.addLine(to: CGPoint(x: 5.5, y: 0))
        Rectangle2Path.addCurve(to: CGPoint(x: 11, y: 5.5), controlPoint1:CGPoint(x: 8.538, y: 0), controlPoint2:CGPoint(x: 11, y: 2.462))
        Rectangle2Path.close()
        Rectangle2Path.move(to: CGPoint(x: 11, y: 18))
        
        return Rectangle2Path
    }
    
    func OvalPath() -> UIBezierPath{
        let OvalPath = UIBezierPath()
        OvalPath.move(to: CGPoint(x: 11, y: 5.5))
        OvalPath.addCurve(to: CGPoint(x: 5.5, y: 11), controlPoint1:CGPoint(x: 11, y: 8.538), controlPoint2:CGPoint(x: 8.538, y: 11))
        OvalPath.addCurve(to: CGPoint(x: 0, y: 5.5), controlPoint1:CGPoint(x: 2.462, y: 11), controlPoint2:CGPoint(x: 0, y: 8.538))
        OvalPath.addCurve(to: CGPoint(x: 5.5, y: 0), controlPoint1:CGPoint(x: 0, y: 2.462), controlPoint2:CGPoint(x: 2.462, y: 0))
        OvalPath.addCurve(to: CGPoint(x: 11, y: 5.5), controlPoint1:CGPoint(x: 8.538, y: 0), controlPoint2:CGPoint(x: 11, y: 2.462))
        OvalPath.close()
        OvalPath.move(to: CGPoint(x: 11, y: 5.5))
        
        return OvalPath
    }
    
    
}
