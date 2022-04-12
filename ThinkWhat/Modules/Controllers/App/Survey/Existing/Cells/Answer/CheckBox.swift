//
//  CheckBox.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CheckBox: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var main : UIColor! {
        didSet {
            setupLayers()
            setupProperties()
        }
    }
    
    var isOn = false {
        didSet {
            if isOn != oldValue {
                if isOn {
                    addEnableAnimation()
                } else {
                    addDisableAnimation()
                }
            }
        }
    }
    
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
    
    override var frame: CGRect{
        didSet{
            setupLayerFrames()
        }
    }
    
    override var bounds: CGRect{
        didSet{
            setupLayerFrames()
        }
    }
    
    func setupProperties(){
        guard main.isNil else { return }
        self.main = K_COLOR_RED
    }
    
    func setupLayers(){
        self.backgroundColor = .clear
        
        let path = CAShapeLayer()
        self.layer.addSublayer(path)
        layers["path"] = path
        
        let rectangle = CAShapeLayer()
        self.layer.addSublayer(rectangle)
        layers["rectangle"] = rectangle
        
        let rectangle2 = CAShapeLayer()
        self.layer.addSublayer(rectangle2)
        layers["rectangle2"] = rectangle2
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillRule    = .evenOdd
            path.fillColor   = traitCollection.userInterfaceStyle == .dark ? UIColor.white.cgColor : UIColor.black.cgColor
            path.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            path.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle"){
            let rectangle = layers["rectangle"] as! CAShapeLayer
            rectangle.anchorPoint = CGPoint(x: 0.5, y: 0)
            rectangle.frame       = CGRect(x: 0.0541 * rectangle.superlayer!.bounds.width, y: 0.45702 * rectangle.superlayer!.bounds.height, width: 0.17959 * rectangle.superlayer!.bounds.width, height: 0.01 * rectangle.superlayer!.bounds.height)
            rectangle.setValue(-44.64 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle.opacity     = 0
            rectangle.fillColor   = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : main.cgColor
            rectangle.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle2"){
            let rectangle2 = layers["rectangle2"] as! CAShapeLayer
            rectangle2.anchorPoint = CGPoint(x: 0.5, y: 0)
            rectangle2.frame       = CGRect(x: 0.25858 * rectangle2.superlayer!.bounds.width, y: 0.77369 * rectangle2.superlayer!.bounds.height, width: 0.16959 * rectangle2.superlayer!.bounds.width, height: 0.01 * rectangle2.superlayer!.bounds.height)
            rectangle2.setValue(-135.09 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle2.opacity     = 0
            rectangle2.fillColor   = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : main.cgColor
            rectangle2.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle2.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.005 * path.superlayer!.bounds.width, y: 0.005 * path.superlayer!.bounds.height, width: 0.99 * path.superlayer!.bounds.width, height: 0.99 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let rectangle = layers["rectangle"] as? CAShapeLayer{
            rectangle.transform = CATransform3DIdentity
            rectangle.frame     = CGRect(x: 0.0541 * rectangle.superlayer!.bounds.width, y: 0.45702 * rectangle.superlayer!.bounds.height, width: 0.17959 * rectangle.superlayer!.bounds.width, height: 0.01 * rectangle.superlayer!.bounds.height)
            rectangle.setValue(-44.64 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle.path      = rectanglePath(bounds: layers["rectangle"]!.bounds).cgPath
        }
        
        if let rectangle2 = layers["rectangle2"] as? CAShapeLayer{
            rectangle2.transform = CATransform3DIdentity
            rectangle2.frame     = CGRect(x: 0.25858 * rectangle2.superlayer!.bounds.width, y: 0.77369 * rectangle2.superlayer!.bounds.height, width: 0.16959 * rectangle2.superlayer!.bounds.width, height: 0.01 * rectangle2.superlayer!.bounds.height)
            rectangle2.setValue(-135.09 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle2.path      = rectangle2Path(bounds: layers["rectangle2"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.305
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        let rectangle = layers["rectangle"] as! CAShapeLayer
        
        ////Rectangle animation
        let rectangleTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        rectangleTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeRotation(44.64 * CGFloat.pi/180, 0, 0, -1)),
                                                 NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 45, 10), CATransform3DMakeRotation(-44.64 * CGFloat.pi/180, -0, 0, 1)))]
        rectangleTransformAnim.keyTimes       = [0, 1]
        rectangleTransformAnim.duration       = 0.1
        rectangleTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let rectangleOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        rectangleOpacityAnim.values         = [0, 1]
        rectangleOpacityAnim.keyTimes       = [0, 1]
        rectangleOpacityAnim.duration       = 0.05
        rectangleOpacityAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let rectangleEnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangleTransformAnim, rectangleOpacityAnim], fillMode:fillMode)
        rectangle.add(rectangleEnableAnim, forKey:"rectangleEnableAnim")
        
        let rectangle2 = layers["rectangle2"] as! CAShapeLayer
        
        ////Rectangle2 animation
        let rectangle2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        rectangle2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeRotation(135.09 * CGFloat.pi/180, 0, 0, -1)),
                                                  NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 75, 1), CATransform3DMakeRotation(-135.09 * CGFloat.pi/180, -0, 0, 1)))]
        rectangle2TransformAnim.keyTimes       = [0, 1]
        rectangle2TransformAnim.duration       = 0.1
        rectangle2TransformAnim.beginTime      = 0.155
        rectangle2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let rectangle2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        rectangle2OpacityAnim.values         = [0, 1]
        rectangle2OpacityAnim.keyTimes       = [0, 1]
        rectangle2OpacityAnim.duration       = 0.05
        rectangle2OpacityAnim.beginTime      = 0.155
        rectangle2OpacityAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let rectangle2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle2TransformAnim, rectangle2OpacityAnim], fillMode:fillMode)
        rectangle2.add(rectangle2EnableAnim, forKey:"rectangle2EnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.1
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        let rectangle = layers["rectangle"] as! CAShapeLayer
        
        ////Rectangle animation
        let rectangleTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        rectangleTransformAnim.values   = [NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 45, 10), CATransform3DMakeRotation(-44.64 * CGFloat.pi/180, -0, 0, 1))),
                                           NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 45, 10), CATransform3DMakeRotation(-44.64 * CGFloat.pi/180, -0, 0, 1))),
                                           NSValue(caTransform3D: CATransform3DMakeRotation(44.64 * CGFloat.pi/180, 0, 0, -1))]
        rectangleTransformAnim.keyTimes = [0, 0.659, 1]
        rectangleTransformAnim.duration = 0.1
        
        let rectangleOpacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        rectangleOpacityAnim.values   = [1, 1, 0]
        rectangleOpacityAnim.keyTimes = [0, 0.956, 1]
        rectangleOpacityAnim.duration = 0.1
        
        let rectangleDisableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangleTransformAnim, rectangleOpacityAnim], fillMode:fillMode)
        rectangle.add(rectangleDisableAnim, forKey:"rectangleDisableAnim")
        
        let rectangle2 = layers["rectangle2"] as! CAShapeLayer
        
        ////Rectangle2 animation
        let rectangle2TransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        rectangle2TransformAnim.values   = [NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 75, 1), CATransform3DMakeRotation(-135.09 * CGFloat.pi/180, -0, 0, 1))),
                                            NSValue(caTransform3D: CATransform3DMakeRotation(135.09 * CGFloat.pi/180, 0, 0, -1))]
        rectangle2TransformAnim.keyTimes = [0, 1]
        rectangle2TransformAnim.duration = 0.1
        
        let rectangle2OpacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        rectangle2OpacityAnim.values   = [1, 1, 0]
        rectangle2OpacityAnim.keyTimes = [0, 0.691, 1]
        rectangle2OpacityAnim.duration = 0.1
        
        let rectangle2DisableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle2TransformAnim, rectangle2OpacityAnim], fillMode:fillMode)
        rectangle2.add(rectangle2DisableAnim, forKey:"rectangle2DisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle"]!.animation(forKey: "rectangleEnableAnim"), theLayer:layers["rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle2"]!.animation(forKey: "rectangle2EnableAnim"), theLayer:layers["rectangle2"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle"]!.animation(forKey: "rectangleDisableAnim"), theLayer:layers["rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle2"]!.animation(forKey: "rectangle2DisableAnim"), theLayer:layers["rectangle2"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["rectangle"]?.removeAnimation(forKey: "rectangleEnableAnim")
            layers["rectangle2"]?.removeAnimation(forKey: "rectangle2EnableAnim")
        }
        else if identifier == "disable"{
            layers["rectangle"]?.removeAnimation(forKey: "rectangleDisableAnim")
            layers["rectangle2"]?.removeAnimation(forKey: "rectangle2DisableAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX + 0.18182 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.18182 * h), controlPoint1:CGPoint(x:minX + 0.0814 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.0814 * h))
        pathPath.addLine(to: CGPoint(x:minX, y: minY + 0.81818 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.18182 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.9186 * h), controlPoint2:CGPoint(x:minX + 0.0814 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.81818 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.81818 * h), controlPoint1:CGPoint(x:minX + 0.9186 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.9186 * h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + 0.18182 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.81818 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.0814 * h), controlPoint2:CGPoint(x:minX + 0.9186 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.18182 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.24763 * w, y: minY + 0.12642 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.12642 * w, y: minY + 0.24763 * h), controlPoint1:CGPoint(x:minX + 0.18069 * w, y: minY + 0.12642 * h), controlPoint2:CGPoint(x:minX + 0.12642 * w, y: minY + 0.18069 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.12642 * w, y: minY + 0.75237 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.24763 * w, y: minY + 0.87358 * h), controlPoint1:CGPoint(x:minX + 0.12642 * w, y: minY + 0.81931 * h), controlPoint2:CGPoint(x:minX + 0.18069 * w, y: minY + 0.87358 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.75237 * w, y: minY + 0.87358 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.87358 * w, y: minY + 0.75237 * h), controlPoint1:CGPoint(x:minX + 0.81931 * w, y: minY + 0.87358 * h), controlPoint2:CGPoint(x:minX + 0.87358 * w, y: minY + 0.81931 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.87358 * w, y: minY + 0.24763 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.75237 * w, y: minY + 0.12642 * h), controlPoint1:CGPoint(x:minX + 0.87358 * w, y: minY + 0.18069 * h), controlPoint2:CGPoint(x:minX + 0.81931 * w, y: minY + 0.12642 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.24763 * w, y: minY + 0.12642 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.24763 * w, y: minY + 0.12642 * h))
        
        return pathPath
    }
    
    func rectanglePath(bounds: CGRect) -> UIBezierPath{
        let rectanglePath = UIBezierPath(rect:bounds)
        return rectanglePath
    }
    
    func rectangle2Path(bounds: CGRect) -> UIBezierPath{
        let rectangle2Path = UIBezierPath(rect:bounds)
        return rectangle2Path
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let path = layers["path"] as? CAShapeLayer,
              let rectangle = layers["rectangle"] as? CAShapeLayer,
              let rectangle2 = layers["rectangle2"] as? CAShapeLayer else {
            return
        }
        switch traitCollection.userInterfaceStyle {
        case .dark:
            path.fillColor = UIColor.white.cgColor
            rectangle.fillColor = UIColor.systemBlue.cgColor
            rectangle2.fillColor = UIColor.systemBlue.cgColor
        default:
            path.fillColor = UIColor.black.cgColor
            rectangle.fillColor = main.cgColor
            rectangle2.fillColor = main.cgColor
        }
    }
}

