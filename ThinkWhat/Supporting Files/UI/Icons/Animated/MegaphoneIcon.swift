//
//  MegaphoneIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class MegaphoneIcon: AnimatedIcon, CAAnimationDelegate {
    
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
    var active : UIColor!
    
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
        self.inactive = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
        self.active = Constants.UI.Colors.main//UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
    }
    
    func setupLayers(){
        let CombinedShape = CAShapeLayer()
        self.layer.addSublayer(CombinedShape)
        layers["CombinedShape"] = CombinedShape
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("CombinedShape"){
            let CombinedShape = layers["CombinedShape"] as! CAShapeLayer
            CombinedShape.fillColor   = self.inactive.cgColor
            CombinedShape.strokeColor = UIColor.black.cgColor
            CombinedShape.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let CombinedShape = layers["CombinedShape"] as? CAShapeLayer{
            CombinedShape.frame = CGRect(x: 0.11184 * CombinedShape.superlayer!.bounds.width, y: 0.22414 * CombinedShape.superlayer!.bounds.height, width: 0.77632 * CombinedShape.superlayer!.bounds.width, height: 0.55173 * CombinedShape.superlayer!.bounds.height)
            CombinedShape.path  = CombinedShapePath(bounds: layers["CombinedShape"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.15
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////CombinedShape animation
        let CombinedShapeFillColorAnim      = CAKeyframeAnimation(keyPath:"fillColor")
        CombinedShapeFillColorAnim.values   = [self.inactive.cgColor,
                                               self.active.cgColor]
        CombinedShapeFillColorAnim.keyTimes = [0, 1]
        CombinedShapeFillColorAnim.duration = 0.15
        CombinedShapeFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let CombinedShape = layers["CombinedShape"] as! CAShapeLayer
        
        let CombinedShapeTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        CombinedShapeTransformAnim.values   = [NSValue(caTransform3D: CATransform3DIdentity),
                                               NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1))]
        CombinedShapeTransformAnim.keyTimes = [0, 1]
        CombinedShapeTransformAnim.duration = 0.15
        CombinedShapeTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let CombinedShapeEnableAnim : CAAnimationGroup = QCMethod.group(animations: [CombinedShapeFillColorAnim, CombinedShapeTransformAnim], fillMode:fillMode)
        CombinedShape.add(CombinedShapeEnableAnim, forKey:"CombinedShapeEnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.15
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////CombinedShape animation
        let CombinedShapeFillColorAnim      = CAKeyframeAnimation(keyPath:"fillColor")
        CombinedShapeFillColorAnim.values   = [self.active.cgColor,
                                               self.inactive.cgColor]
        CombinedShapeFillColorAnim.keyTimes = [0, 1]
        CombinedShapeFillColorAnim.duration = 0.15
        CombinedShapeFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let CombinedShape = layers["CombinedShape"] as! CAShapeLayer
        
        let CombinedShapeTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        CombinedShapeTransformAnim.values   = [NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1)),
                                               NSValue(caTransform3D: CATransform3DIdentity)]
        CombinedShapeTransformAnim.keyTimes = [0, 1]
        CombinedShapeTransformAnim.duration = 0.15
        CombinedShapeTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let CombinedShapeDisableAnim : CAAnimationGroup = QCMethod.group(animations: [CombinedShapeFillColorAnim, CombinedShapeTransformAnim], fillMode:fillMode)
        CombinedShape.add(CombinedShapeDisableAnim, forKey:"CombinedShapeDisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["CombinedShape"]!.animation(forKey: "CombinedShapeEnableAnim"), theLayer:layers["CombinedShape"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["CombinedShape"]!.animation(forKey: "CombinedShapeDisableAnim"), theLayer:layers["CombinedShape"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["CombinedShape"]?.removeAnimation(forKey: "CombinedShapeEnableAnim")
        }
        else if identifier == "disable"{
            layers["CombinedShape"]?.removeAnimation(forKey: "CombinedShapeDisableAnim")
        }
    }
    
    override func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func CombinedShapePath(bounds: CGRect) -> UIBezierPath{
        let CombinedShapePath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        CombinedShapePath.move(to: CGPoint(x:minX + w, y: minY))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY + 0.88147 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.66801 * w, y: minY + 0.77938 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.66801 * w, y: minY + 0.88048 * h))
        CombinedShapePath.addCurve(to: CGPoint(x:minX + 0.57457 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.66801 * w, y: minY + 0.95219 * h), controlPoint2:CGPoint(x:minX + 0.6312 * w, y: minY + h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.30275 * w, y: minY + h))
        CombinedShapePath.addCurve(to: CGPoint(x:minX + 0.20932 * w, y: minY + 0.88048 * h), controlPoint1:CGPoint(x:minX + 0.24612 * w, y: minY + h), controlPoint2:CGPoint(x:minX + 0.20932 * w, y: minY + 0.95219 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.20932 * w, y: minY + 0.63875 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.04297 * w, y: minY + 0.5877 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.04297 * w, y: minY + 0.64711 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX, y: minY + 0.64711 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX, y: minY + 0.23411 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.04297 * w, y: minY + 0.23411 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.04297 * w, y: minY + 0.29333 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY))
        CombinedShapePath.addLine(to: CGPoint(x:minX + w, y: minY))
        CombinedShapePath.move(to: CGPoint(x:minX + 0.58448 * w, y: minY + 0.88048 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.58448 * w, y: minY + 0.75398 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.29214 * w, y: minY + 0.66434 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.29214 * w, y: minY + 0.88048 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.58448 * w, y: minY + 0.88048 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.58448 * w, y: minY + 0.88048 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.58448 * w, y: minY + 0.88048 * h))
        CombinedShapePath.addLine(to: CGPoint(x:minX + 0.58448 * w, y: minY + 0.88048 * h))
        
        return CombinedShapePath
    }
    
    
}

