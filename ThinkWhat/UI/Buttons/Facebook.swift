//
//  Facebook.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class FacebookButtonView: ParentLoginButton, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var color : UIColor!
    var color1 : UIColor!
    var green : UIColor!
    var color2 : UIColor!
    var color3 : UIColor!
    
    //MARK: - Life Cycle
    override var state: ParentLoginButton.State {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.authVariant = .Facebook
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
        self.color = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        self.color1 = UIColor(red:1.00, green: 0.58, blue:0.00, alpha:1.0)
        self.green = UIColor(red:0.29, green: 0.564, blue:0.319, alpha:1)
        self.color2 = UIColor.black
        self.color3 = UIColor(red:0.805, green: 0.342, blue:0.339, alpha:1)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:0, green: 0, blue:0, alpha:0)
        
        let oval = CAShapeLayer()
        self.layer.addSublayer(oval)
        layers["oval"] = oval
        
        let oval2 = CAShapeLayer()
        self.layer.addSublayer(oval2)
        layers["oval2"] = oval2
        
        let icono1 = CALayer()
        self.layer.addSublayer(icono1)
        layers["icono1"] = icono1
        let path4 = CAShapeLayer()
        icono1.addSublayer(path4)
        layers["path4"] = path4
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("oval"){
            let oval = layers["oval"] as! CAShapeLayer
            oval.fillColor   = self.color2.cgColor
            oval.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("oval2"){
            let oval2 = layers["oval2"] as! CAShapeLayer
            oval2.opacity     = 0
            oval2.fillColor   = self.color3.cgColor
            oval2.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path4"){
            let path4 = layers["path4"] as! CAShapeLayer
            path4.fillColor   = self.color.cgColor
            path4.strokeColor = UIColor.black.cgColor
            path4.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let oval = layers["oval"] as? CAShapeLayer{
            oval.frame = CGRect(x: 0.015 * oval.superlayer!.bounds.width, y: 0.015 * oval.superlayer!.bounds.height, width: 0.97 * oval.superlayer!.bounds.width, height: 0.97 * oval.superlayer!.bounds.height)
            oval.path  = ovalPath(bounds: layers["oval"]!.bounds).cgPath
        }
        
        if let oval2 = layers["oval2"] as? CAShapeLayer{
            oval2.frame = CGRect(x: 0.015 * oval2.superlayer!.bounds.width, y: 0.015 * oval2.superlayer!.bounds.height, width: 0.97 * oval2.superlayer!.bounds.width, height: 0.97 * oval2.superlayer!.bounds.height)
            oval2.path  = oval2Path(bounds: layers["oval2"]!.bounds).cgPath
        }
        
        if let icono1 = layers["icono1"]{
            icono1.frame = CGRect(x: 0.40519 * icono1.superlayer!.bounds.width, y: 0.295 * icono1.superlayer!.bounds.height, width: 0.18961 * icono1.superlayer!.bounds.width, height: 0.41 * icono1.superlayer!.bounds.height)
        }
        
        if let path4 = layers["path4"] as? CAShapeLayer{
            path4.frame = CGRect(x: 0, y: 0, width:  path4.superlayer!.bounds.width, height:  path4.superlayer!.bounds.height)
            path4.path  = path4Path(bounds: layers["path4"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.3
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Oval2 animation
        let oval2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        oval2OpacityAnim.values         = [0, 1]
        oval2OpacityAnim.keyTimes       = [0, 1]
        oval2OpacityAnim.duration       = 0.3
        oval2OpacityAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2 = layers["oval2"] as! CAShapeLayer
        
        let oval2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        oval2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(0.001, 0.001, 1)),
                                             NSValue(caTransform3D: CATransform3DIdentity)]
        oval2TransformAnim.keyTimes       = [0, 1]
        oval2TransformAnim.duration       = 0.3
        oval2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [oval2OpacityAnim, oval2TransformAnim], fillMode:fillMode)
        oval2.add(oval2EnableAnim, forKey:"oval2EnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.3
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Oval2 animation
        let oval2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        oval2OpacityAnim.values         = [1, 1, 0]
        oval2OpacityAnim.keyTimes       = [0, 0.58, 1]
        oval2OpacityAnim.duration       = 0.3
        oval2OpacityAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2 = layers["oval2"] as! CAShapeLayer
        
        let oval2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        oval2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                             NSValue(caTransform3D: CATransform3DMakeScale(0.001, 0.001, 1))]
        oval2TransformAnim.keyTimes       = [0, 1]
        oval2TransformAnim.duration       = 0.3
        oval2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2DisableAnim : CAAnimationGroup = QCMethod.group(animations: [oval2OpacityAnim, oval2TransformAnim], fillMode:fillMode)
        oval2.add(oval2DisableAnim, forKey:"oval2DisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval2"]!.animation(forKey: "oval2EnableAnim"), theLayer:layers["oval2"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval2"]!.animation(forKey: "oval2DisableAnim"), theLayer:layers["oval2"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["oval2"]?.removeAnimation(forKey: "oval2EnableAnim")
        }
        else if identifier == "disable"{
            layers["oval2"]?.removeAnimation(forKey: "oval2DisableAnim")
        }
    }
    
    override func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func ovalPath(bounds: CGRect) -> UIBezierPath{
        let ovalPath = UIBezierPath(ovalIn:bounds)
        return ovalPath
    }
    
    func oval2Path(bounds: CGRect) -> UIBezierPath{
        let oval2Path = UIBezierPath(ovalIn:bounds)
        return oval2Path
    }
    
    func path4Path(bounds: CGRect) -> UIBezierPath{
        let path4Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path4Path.move(to: CGPoint(x:minX + 0.58639 * w, y: minY + 0.00266 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.33037 * w, y: minY + 0.05303 * h), controlPoint1:CGPoint(x:minX + 0.4801 * w, y: minY + 0.00847 * h), controlPoint2:CGPoint(x:minX + 0.38901 * w, y: minY + 0.02639 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.27068 * w, y: minY + 0.09225 * h), controlPoint1:CGPoint(x:minX + 0.30157 * w, y: minY + 0.0661 * h), controlPoint2:CGPoint(x:minX + 0.28953 * w, y: minY + 0.07433 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.2267 * w, y: minY + 0.23777 * h), controlPoint1:CGPoint(x:minX + 0.23089 * w, y: minY + 0.13027 * h), controlPoint2:CGPoint(x:minX + 0.22932 * w, y: minY + 0.13656 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.22408 * w, y: minY + 0.32688 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.11204 * w, y: minY + 0.32688 * h))
        path4Path.addLine(to: CGPoint(x:minX, y: minY + 0.32688 * h))
        path4Path.addLine(to: CGPoint(x:minX, y: minY + 0.41283 * h))
        path4Path.addLine(to: CGPoint(x:minX, y: minY + 0.49879 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.11257 * w, y: minY + 0.49879 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.22513 * w, y: minY + 0.49879 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.22513 * w, y: minY + 0.74939 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.22513 * w, y: minY + h))
        path4Path.addLine(to: CGPoint(x:minX + 0.44503 * w, y: minY + h))
        path4Path.addLine(to: CGPoint(x:minX + 0.66492 * w, y: minY + h))
        path4Path.addLine(to: CGPoint(x:minX + 0.66492 * w, y: minY + 0.74818 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.66492 * w, y: minY + 0.49637 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.81675 * w, y: minY + 0.49637 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.96859 * w, y: minY + 0.49516 * h), controlPoint1:CGPoint(x:minX + 0.90052 * w, y: minY + 0.49637 * h), controlPoint2:CGPoint(x:minX + 0.96859 * w, y: minY + 0.49588 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.98429 * w, y: minY + 0.41235 * h), controlPoint1:CGPoint(x:minX + 0.96859 * w, y: minY + 0.49443 * h), controlPoint2:CGPoint(x:minX + 0.97592 * w, y: minY + 0.45738 * h))
        path4Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.32881 * h), controlPoint1:CGPoint(x:minX + 0.99319 * w, y: minY + 0.36755 * h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.33002 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.83246 * w, y: minY + 0.32688 * h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.32785 * h), controlPoint2:CGPoint(x:minX + 0.92461 * w, y: minY + 0.32688 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.66492 * w, y: minY + 0.32688 * h))
        path4Path.addLine(to: CGPoint(x:minX + 0.66492 * w, y: minY + 0.27094 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.67068 * w, y: minY + 0.2046 * h), controlPoint1:CGPoint(x:minX + 0.66492 * w, y: minY + 0.23874 * h), controlPoint2:CGPoint(x:minX + 0.66754 * w, y: minY + 0.2109 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.72565 * w, y: minY + 0.17893 * h), controlPoint1:CGPoint(x:minX + 0.67749 * w, y: minY + 0.19177 * h), controlPoint2:CGPoint(x:minX + 0.69895 * w, y: minY + 0.18184 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.8733 * w, y: minY + 0.17676 * h), controlPoint1:CGPoint(x:minX + 0.73717 * w, y: minY + 0.17797 * h), controlPoint2:CGPoint(x:minX + 0.80314 * w, y: minY + 0.17676 * h))
        path4Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.17676 * h))
        path4Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.08838 * h))
        path4Path.addLine(to: CGPoint(x:minX + w, y: minY))
        path4Path.addLine(to: CGPoint(x:minX + 0.81309 * w, y: minY + 0.00024 * h))
        path4Path.addCurve(to: CGPoint(x:minX + 0.58639 * w, y: minY + 0.00266 * h), controlPoint1:CGPoint(x:minX + 0.70995 * w, y: minY + 0.00048 * h), controlPoint2:CGPoint(x:minX + 0.60785 * w, y: minY + 0.00145 * h))
        path4Path.close()
        path4Path.move(to: CGPoint(x:minX + 0.58639 * w, y: minY + 0.00266 * h))
        
        return path4Path
    }
    
    
}

