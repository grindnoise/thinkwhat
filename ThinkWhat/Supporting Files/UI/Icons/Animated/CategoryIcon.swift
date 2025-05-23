//
//  CategoryIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CategoryIcon: AnimatedIcon, CAAnimationDelegate {
    
    override var state: AnimatedIcon.State {
        didSet {
            if oldValue != state {
                if state == .enabled {
                    self.addEnableAnimation()
                } else {
                    self.addDisableAnimation()
                }
            }
        }
    }
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var inactive : UIColor!
    var violet : UIColor!
    var blue : UIColor!
    var cyan : UIColor!
    var greeen : UIColor!
    
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
//        self.active = UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1)
//        self.active1 = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
        self.inactive = UIColor(red:0.663, green: 0.663, blue:0.663, alpha:1)
        self.violet = Constants.UI.Colors.System.Red.rawValue//Constants.UI.Colors.UpperButtons.VioletBlueCrayola//K_COLOR_RED//K_COLOR_RED//UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1)//UIColor(red:0.84, green: 0.51, blue:1.00, alpha:1.0)
        self.blue = Constants.UI.Colors.System.Red.rawValue//Constants.UI.Colors.UpperButtons.VioletBlueCrayola//K_COLOR_RED//K_COLOR_RED//UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1)//UIColor(red:0.00, green: 0.59, blue:1.00, alpha:1.0)
        self.cyan = Constants.UI.Colors.System.Red.rawValue//Constants.UI.Colors.UpperButtons.VioletBlueCrayola//K_COLOR_RED//K_COLOR_RED//UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1)//UIColor(red:0, green: 0.569, blue:0.576, alpha:1)
        self.greeen = Constants.UI.Colors.System.Red.rawValue//Constants.UI.Colors.UpperButtons.VioletBlueCrayola//K_COLOR_RED//K_COLOR_RED//UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1)//UIColor(red:0, green: 0.565, blue:0.318, alpha:1)
    }
    
    func setupLayers(){
        let category = CALayer()
        self.layer.addSublayer(category)
        layers["category"] = category
        let Rectangle = CAShapeLayer()
        category.addSublayer(Rectangle)
        layers["Rectangle"] = Rectangle
        let RectangleCopy = CAShapeLayer()
        category.addSublayer(RectangleCopy)
        layers["RectangleCopy"] = RectangleCopy
        let RectangleCopy2 = CAShapeLayer()
        category.addSublayer(RectangleCopy2)
        layers["RectangleCopy2"] = RectangleCopy2
        let RectangleCopy3 = CAShapeLayer()
        category.addSublayer(RectangleCopy3)
        layers["RectangleCopy3"] = RectangleCopy3
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("Rectangle"){
            let Rectangle = layers["Rectangle"] as! CAShapeLayer
            Rectangle.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            Rectangle.strokeColor = UIColor.black.cgColor
            Rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("RectangleCopy"){
            let RectangleCopy = layers["RectangleCopy"] as! CAShapeLayer
            RectangleCopy.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            RectangleCopy.strokeColor = UIColor.black.cgColor
            RectangleCopy.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("RectangleCopy2"){
            let RectangleCopy2 = layers["RectangleCopy2"] as! CAShapeLayer
            RectangleCopy2.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            RectangleCopy2.strokeColor = UIColor.black.cgColor
            RectangleCopy2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("RectangleCopy3"){
            let RectangleCopy3 = layers["RectangleCopy3"] as! CAShapeLayer
            RectangleCopy3.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            RectangleCopy3.strokeColor = UIColor.black.cgColor
            RectangleCopy3.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let category = layers["category"]{
            category.frame = CGRect(x: 0.08126 * category.superlayer!.bounds.width, y: 0.08126 * category.superlayer!.bounds.height, width: 0.83749 * category.superlayer!.bounds.width, height: 0.83749 * category.superlayer!.bounds.height)
        }
        
        if let Rectangle = layers["Rectangle"] as? CAShapeLayer{
            Rectangle.frame = CGRect(x: 0, y: 0, width: 0.46154 * Rectangle.superlayer!.bounds.width, height: 0.46154 * Rectangle.superlayer!.bounds.height)
            Rectangle.path  = RectanglePath(bounds: layers["Rectangle"]!.bounds).cgPath
        }
        
        if let RectangleCopy = layers["RectangleCopy"] as? CAShapeLayer{
            RectangleCopy.frame = CGRect(x: 0.53846 * RectangleCopy.superlayer!.bounds.width, y: 0, width: 0.46154 * RectangleCopy.superlayer!.bounds.width, height: 0.46154 * RectangleCopy.superlayer!.bounds.height)
            RectangleCopy.path  = RectangleCopyPath(bounds: layers["RectangleCopy"]!.bounds).cgPath
        }
        
        if let RectangleCopy2 = layers["RectangleCopy2"] as? CAShapeLayer{
            RectangleCopy2.frame = CGRect(x: 0, y: 0.53846 * RectangleCopy2.superlayer!.bounds.height, width: 0.46154 * RectangleCopy2.superlayer!.bounds.width, height: 0.46154 * RectangleCopy2.superlayer!.bounds.height)
            RectangleCopy2.path  = RectangleCopy2Path(bounds: layers["RectangleCopy2"]!.bounds).cgPath
        }
        
        if let RectangleCopy3 = layers["RectangleCopy3"] as? CAShapeLayer{
            RectangleCopy3.frame = CGRect(x: 0.53846 * RectangleCopy3.superlayer!.bounds.width, y: 0.53846 * RectangleCopy3.superlayer!.bounds.height, width: 0.46154 * RectangleCopy3.superlayer!.bounds.width, height: 0.46154 * RectangleCopy3.superlayer!.bounds.height)
            RectangleCopy3.path  = RectangleCopy3Path(bounds: layers["RectangleCopy3"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.55
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
        RectangleFillColorAnim.values         = [UIColor(red:0.663, green: 0.663, blue:0.663, alpha:1).cgColor,
                                                 self.blue.cgColor]
        RectangleFillColorAnim.keyTimes       = [0, 1]
        RectangleFillColorAnim.duration       = 0.25
        RectangleFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let Rectangle = layers["Rectangle"] as! CAShapeLayer
        
        let RectangleTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        RectangleTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1))]
        RectangleTransformAnim.keyTimes       = [0, 0.64, 1]
        RectangleTransformAnim.duration       = 0.25
        RectangleTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleEnableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleFillColorAnim, RectangleTransformAnim], fillMode:fillMode)
        Rectangle.add(RectangleEnableAnim, forKey:"RectangleEnableAnim")
        
        ////RectangleCopy animation
        let RectangleCopyFillColorAnim       = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleCopyFillColorAnim.values    = [UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor,
                                                self.violet.cgColor]
        RectangleCopyFillColorAnim.keyTimes  = [0, 1]
        RectangleCopyFillColorAnim.duration  = 0.25
        RectangleCopyFillColorAnim.beginTime = 0.1
        RectangleCopyFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy = layers["RectangleCopy"] as! CAShapeLayer
        
        let RectangleCopyTransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        RectangleCopyTransformAnim.values    = [NSValue(caTransform3D: CATransform3DIdentity),
                                                NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
                                                NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1))]
        RectangleCopyTransformAnim.keyTimes  = [0, 0.64, 1]
        RectangleCopyTransformAnim.duration  = 0.25
        RectangleCopyTransformAnim.beginTime = 0.1
        RectangleCopyTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopyEnableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleCopyFillColorAnim, RectangleCopyTransformAnim], fillMode:fillMode)
        RectangleCopy.add(RectangleCopyEnableAnim, forKey:"RectangleCopyEnableAnim")
        
        ////RectangleCopy2 animation
        let RectangleCopy2FillColorAnim       = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleCopy2FillColorAnim.values    = [UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor,
                                                 self.cyan.cgColor]
        RectangleCopy2FillColorAnim.keyTimes  = [0, 1]
        RectangleCopy2FillColorAnim.duration  = 0.25
        RectangleCopy2FillColorAnim.beginTime = 0.2
        RectangleCopy2FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy2 = layers["RectangleCopy2"] as! CAShapeLayer
        
        let RectangleCopy2TransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        RectangleCopy2TransformAnim.values    = [NSValue(caTransform3D: CATransform3DIdentity),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1))]
        RectangleCopy2TransformAnim.keyTimes  = [0, 0.62, 1]
        RectangleCopy2TransformAnim.duration  = 0.25
        RectangleCopy2TransformAnim.beginTime = 0.2
        RectangleCopy2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleCopy2FillColorAnim, RectangleCopy2TransformAnim], fillMode:fillMode)
        RectangleCopy2.add(RectangleCopy2EnableAnim, forKey:"RectangleCopy2EnableAnim")
        
        ////RectangleCopy3 animation
        let RectangleCopy3FillColorAnim       = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleCopy3FillColorAnim.values    = [UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor,
                                                 self.greeen.cgColor]
        RectangleCopy3FillColorAnim.keyTimes  = [0, 1]
        RectangleCopy3FillColorAnim.duration  = 0.25
        RectangleCopy3FillColorAnim.beginTime = 0.3
        RectangleCopy3FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy3 = layers["RectangleCopy3"] as! CAShapeLayer
        
        let RectangleCopy3TransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        RectangleCopy3TransformAnim.values    = [NSValue(caTransform3D: CATransform3DIdentity),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
                                                 NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1))]
        RectangleCopy3TransformAnim.keyTimes  = [0, 0.64, 1]
        RectangleCopy3TransformAnim.duration  = 0.25
        RectangleCopy3TransformAnim.beginTime = 0.3
        RectangleCopy3TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy3EnableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleCopy3FillColorAnim, RectangleCopy3TransformAnim], fillMode:fillMode)
        RectangleCopy3.add(RectangleCopy3EnableAnim, forKey:"RectangleCopy3EnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.75
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
        RectangleFillColorAnim.values         = [self.blue.cgColor,
                                                 UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        RectangleFillColorAnim.keyTimes       = [0, 1]
        RectangleFillColorAnim.duration       = 0.3
        RectangleFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let Rectangle = layers["Rectangle"] as! CAShapeLayer
        
        let RectangleTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        RectangleTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)),
                                                 NSValue(caTransform3D: CATransform3DIdentity)]
        RectangleTransformAnim.keyTimes       = [0, 1]
        RectangleTransformAnim.duration       = 0.25
        RectangleTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleDisableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleFillColorAnim, RectangleTransformAnim], fillMode:fillMode)
        Rectangle.add(RectangleDisableAnim, forKey:"RectangleDisableAnim")
        
        ////RectangleCopy animation
        let RectangleCopyFillColorAnim       = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleCopyFillColorAnim.values    = [self.violet.cgColor,
                                                UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        RectangleCopyFillColorAnim.keyTimes  = [0, 1]
        RectangleCopyFillColorAnim.duration  = 0.3
        RectangleCopyFillColorAnim.beginTime = 0.15
        RectangleCopyFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy = layers["RectangleCopy"] as! CAShapeLayer
        
        let RectangleCopyTransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        RectangleCopyTransformAnim.values    = [NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)),
                                                NSValue(caTransform3D: CATransform3DIdentity)]
        RectangleCopyTransformAnim.keyTimes  = [0, 1]
        RectangleCopyTransformAnim.duration  = 0.25
        RectangleCopyTransformAnim.beginTime = 0.15
        RectangleCopyTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopyDisableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleCopyFillColorAnim, RectangleCopyTransformAnim], fillMode:fillMode)
        RectangleCopy.add(RectangleCopyDisableAnim, forKey:"RectangleCopyDisableAnim")
        
        ////RectangleCopy2 animation
        let RectangleCopy2FillColorAnim       = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleCopy2FillColorAnim.values    = [self.cyan.cgColor,
                                                 UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        RectangleCopy2FillColorAnim.keyTimes  = [0, 1]
        RectangleCopy2FillColorAnim.duration  = 0.3
        RectangleCopy2FillColorAnim.beginTime = 0.3
        RectangleCopy2FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy2 = layers["RectangleCopy2"] as! CAShapeLayer
        
        let RectangleCopy2TransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        RectangleCopy2TransformAnim.values    = [NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)),
                                                 NSValue(caTransform3D: CATransform3DIdentity)]
        RectangleCopy2TransformAnim.keyTimes  = [0, 1]
        RectangleCopy2TransformAnim.duration  = 0.25
        RectangleCopy2TransformAnim.beginTime = 0.3
        RectangleCopy2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy2DisableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleCopy2FillColorAnim, RectangleCopy2TransformAnim], fillMode:fillMode)
        RectangleCopy2.add(RectangleCopy2DisableAnim, forKey:"RectangleCopy2DisableAnim")
        
        ////RectangleCopy3 animation
        let RectangleCopy3FillColorAnim       = CAKeyframeAnimation(keyPath:"fillColor")
        RectangleCopy3FillColorAnim.values    = [self.greeen.cgColor,
                                                 UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        RectangleCopy3FillColorAnim.keyTimes  = [0, 1]
        RectangleCopy3FillColorAnim.duration  = 0.3
        RectangleCopy3FillColorAnim.beginTime = 0.45
        RectangleCopy3FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy3 = layers["RectangleCopy3"] as! CAShapeLayer
        
        let RectangleCopy3TransformAnim       = CAKeyframeAnimation(keyPath:"transform")
        RectangleCopy3TransformAnim.values    = [NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)),
                                                 NSValue(caTransform3D: CATransform3DIdentity)]
        RectangleCopy3TransformAnim.keyTimes  = [0, 1]
        RectangleCopy3TransformAnim.duration  = 0.25
        RectangleCopy3TransformAnim.beginTime = 0.45
        RectangleCopy3TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let RectangleCopy3DisableAnim : CAAnimationGroup = QCMethod.group(animations: [RectangleCopy3FillColorAnim, RectangleCopy3TransformAnim], fillMode:fillMode)
        RectangleCopy3.add(RectangleCopy3DisableAnim, forKey:"RectangleCopy3DisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["RectangleCopy"]!.animation(forKey: "RectangleCopyEnableAnim"), theLayer:layers["RectangleCopy"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["RectangleCopy2"]!.animation(forKey: "RectangleCopy2EnableAnim"), theLayer:layers["RectangleCopy2"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["RectangleCopy3"]!.animation(forKey: "RectangleCopy3EnableAnim"), theLayer:layers["RectangleCopy3"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Rectangle"]!.animation(forKey: "RectangleDisableAnim"), theLayer:layers["Rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["RectangleCopy"]!.animation(forKey: "RectangleCopyDisableAnim"), theLayer:layers["RectangleCopy"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["RectangleCopy2"]!.animation(forKey: "RectangleCopy2DisableAnim"), theLayer:layers["RectangleCopy2"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["RectangleCopy3"]!.animation(forKey: "RectangleCopy3DisableAnim"), theLayer:layers["RectangleCopy3"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["Rectangle"]?.removeAnimation(forKey: "RectangleEnableAnim")
            layers["RectangleCopy"]?.removeAnimation(forKey: "RectangleCopyEnableAnim")
            layers["RectangleCopy2"]?.removeAnimation(forKey: "RectangleCopy2EnableAnim")
            layers["RectangleCopy3"]?.removeAnimation(forKey: "RectangleCopy3EnableAnim")
        }
        else if identifier == "disable"{
            layers["Rectangle"]?.removeAnimation(forKey: "RectangleDisableAnim")
            layers["RectangleCopy"]?.removeAnimation(forKey: "RectangleCopyDisableAnim")
            layers["RectangleCopy2"]?.removeAnimation(forKey: "RectangleCopy2DisableAnim")
            layers["RectangleCopy3"]?.removeAnimation(forKey: "RectangleCopy3DisableAnim")
        }
    }
    
    override func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func RectanglePath(bounds: CGRect) -> UIBezierPath{
        let RectanglePath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        RectanglePath.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        RectanglePath.addLine(to: CGPoint(x:minX + w, y: minY + 0.68333 * h))
        RectanglePath.addCurve(to: CGPoint(x:minX + 0.68333 * w, y: minY + h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.85822 * h), controlPoint2:CGPoint(x:minX + 0.85822 * w, y: minY + h))
        RectanglePath.addLine(to: CGPoint(x:minX + 0.31667 * w, y: minY + h))
        RectanglePath.addCurve(to: CGPoint(x:minX, y: minY + 0.68333 * h), controlPoint1:CGPoint(x:minX + 0.14178 * w, y: minY + h), controlPoint2:CGPoint(x:minX, y: minY + 0.85822 * h))
        RectanglePath.addLine(to: CGPoint(x:minX, y: minY + 0.31667 * h))
        RectanglePath.addCurve(to: CGPoint(x:minX + 0.31667 * w, y: minY), controlPoint1:CGPoint(x:minX, y: minY + 0.14178 * h), controlPoint2:CGPoint(x:minX + 0.14178 * w, y: minY))
        RectanglePath.addLine(to: CGPoint(x:minX + 0.68333 * w, y: minY))
        RectanglePath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.31667 * h), controlPoint1:CGPoint(x:minX + 0.85822 * w, y: minY), controlPoint2:CGPoint(x:minX + w, y: minY + 0.14178 * h))
        RectanglePath.close()
        RectanglePath.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        
        return RectanglePath
    }
    
    func RectangleCopyPath(bounds: CGRect) -> UIBezierPath{
        let RectangleCopyPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        RectangleCopyPath.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        RectangleCopyPath.addLine(to: CGPoint(x:minX + w, y: minY + 0.68333 * h))
        RectangleCopyPath.addCurve(to: CGPoint(x:minX + 0.68333 * w, y: minY + h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.85822 * h), controlPoint2:CGPoint(x:minX + 0.85822 * w, y: minY + h))
        RectangleCopyPath.addLine(to: CGPoint(x:minX + 0.31667 * w, y: minY + h))
        RectangleCopyPath.addCurve(to: CGPoint(x:minX, y: minY + 0.68333 * h), controlPoint1:CGPoint(x:minX + 0.14178 * w, y: minY + h), controlPoint2:CGPoint(x:minX, y: minY + 0.85822 * h))
        RectangleCopyPath.addLine(to: CGPoint(x:minX, y: minY + 0.31667 * h))
        RectangleCopyPath.addCurve(to: CGPoint(x:minX + 0.31667 * w, y: minY), controlPoint1:CGPoint(x:minX, y: minY + 0.14178 * h), controlPoint2:CGPoint(x:minX + 0.14178 * w, y: minY))
        RectangleCopyPath.addLine(to: CGPoint(x:minX + 0.68333 * w, y: minY))
        RectangleCopyPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.31667 * h), controlPoint1:CGPoint(x:minX + 0.85822 * w, y: minY), controlPoint2:CGPoint(x:minX + w, y: minY + 0.14178 * h))
        RectangleCopyPath.close()
        RectangleCopyPath.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        
        return RectangleCopyPath
    }
    
    func RectangleCopy2Path(bounds: CGRect) -> UIBezierPath{
        let RectangleCopy2Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        RectangleCopy2Path.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        RectangleCopy2Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.68333 * h))
        RectangleCopy2Path.addCurve(to: CGPoint(x:minX + 0.68333 * w, y: minY + h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.85822 * h), controlPoint2:CGPoint(x:minX + 0.85822 * w, y: minY + h))
        RectangleCopy2Path.addLine(to: CGPoint(x:minX + 0.31667 * w, y: minY + h))
        RectangleCopy2Path.addCurve(to: CGPoint(x:minX, y: minY + 0.68333 * h), controlPoint1:CGPoint(x:minX + 0.14178 * w, y: minY + h), controlPoint2:CGPoint(x:minX, y: minY + 0.85822 * h))
        RectangleCopy2Path.addLine(to: CGPoint(x:minX, y: minY + 0.31667 * h))
        RectangleCopy2Path.addCurve(to: CGPoint(x:minX + 0.31667 * w, y: minY), controlPoint1:CGPoint(x:minX, y: minY + 0.14178 * h), controlPoint2:CGPoint(x:minX + 0.14178 * w, y: minY))
        RectangleCopy2Path.addLine(to: CGPoint(x:minX + 0.68333 * w, y: minY))
        RectangleCopy2Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.31667 * h), controlPoint1:CGPoint(x:minX + 0.85822 * w, y: minY), controlPoint2:CGPoint(x:minX + w, y: minY + 0.14178 * h))
        RectangleCopy2Path.close()
        RectangleCopy2Path.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        
        return RectangleCopy2Path
    }
    
    func RectangleCopy3Path(bounds: CGRect) -> UIBezierPath{
        let RectangleCopy3Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        RectangleCopy3Path.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        RectangleCopy3Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.68333 * h))
        RectangleCopy3Path.addCurve(to: CGPoint(x:minX + 0.68333 * w, y: minY + h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.85822 * h), controlPoint2:CGPoint(x:minX + 0.85822 * w, y: minY + h))
        RectangleCopy3Path.addLine(to: CGPoint(x:minX + 0.31667 * w, y: minY + h))
        RectangleCopy3Path.addCurve(to: CGPoint(x:minX, y: minY + 0.68333 * h), controlPoint1:CGPoint(x:minX + 0.14178 * w, y: minY + h), controlPoint2:CGPoint(x:minX, y: minY + 0.85822 * h))
        RectangleCopy3Path.addLine(to: CGPoint(x:minX, y: minY + 0.31667 * h))
        RectangleCopy3Path.addCurve(to: CGPoint(x:minX + 0.31667 * w, y: minY), controlPoint1:CGPoint(x:minX, y: minY + 0.14178 * h), controlPoint2:CGPoint(x:minX + 0.14178 * w, y: minY))
        RectangleCopy3Path.addLine(to: CGPoint(x:minX + 0.68333 * w, y: minY))
        RectangleCopy3Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.31667 * h), controlPoint1:CGPoint(x:minX + 0.85822 * w, y: minY), controlPoint2:CGPoint(x:minX + w, y: minY + 0.14178 * h))
        RectangleCopy3Path.close()
        RectangleCopy3Path.move(to: CGPoint(x:minX + w, y: minY + 0.5 * h))
        
        return RectangleCopy3Path
    }
    
    
}
