//
//  VKButtonView.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class VKButtonView: LoginButton, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var color : UIColor!
    var color1 : UIColor!
    var green : UIColor!
    var color2 : UIColor!
    
    //MARK: - Life Cycle
    override var state: State {
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
        self.authVariant = .VK
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
        self.color1 = UIColor(red:0.805, green: 0.342, blue:0.339, alpha:1)
        self.green = UIColor.black
        self.color2 = UIColor.black
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:0, green: 0, blue:0, alpha:0)
        
        let oval = CAShapeLayer()
        self.layer.addSublayer(oval)
        layers["oval"] = oval
        
        let oval2 = CAShapeLayer()
        self.layer.addSublayer(oval2)
        layers["oval2"] = oval2
        
        let Group = CALayer()
        self.layer.addSublayer(Group)
        layers["Group"] = Group
        let path = CAShapeLayer()
        Group.addSublayer(path)
        layers["path"] = path
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("oval"){
            let oval = layers["oval"] as! CAShapeLayer
            oval.fillColor   = UIColor.black.cgColor
            oval.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("oval2"){
            let oval2 = layers["oval2"] as! CAShapeLayer
            oval2.opacity     = 0
            oval2.fillColor   = self.color1.cgColor
            oval2.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillColor   = self.color.cgColor
            path.strokeColor = UIColor.black.cgColor
            path.lineWidth   = 0
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
        
        if let Group = layers["Group"]{
            Group.frame = CGRect(x: 0.24 * Group.superlayer!.bounds.width, y: 0.38957 * Group.superlayer!.bounds.height, width: 0.47551 * Group.superlayer!.bounds.width, height: 0.27043 * Group.superlayer!.bounds.height)
        }
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0, y: 0, width:  path.superlayer!.bounds.width, height:  path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
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
        oval2OpacityAnim.keyTimes       = [0, 0.622, 1]
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
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX + 0.41903 * w, y: minY + 0.00057 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.36624 * w, y: minY + 0.01466 * h), controlPoint1:CGPoint(x:minX + 0.40006 * w, y: minY + 0.00298 * h), controlPoint2:CGPoint(x:minX + 0.37582 * w, y: minY + 0.00951 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.33281 * w, y: minY + 0.06691 * h), controlPoint1:CGPoint(x:minX + 0.34963 * w, y: minY + 0.0236 * h), controlPoint2:CGPoint(x:minX + 0.3291 * w, y: minY + 0.05591 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.34141 * w, y: minY + 0.07276 * h), controlPoint1:CGPoint(x:minX + 0.33359 * w, y: minY + 0.06863 * h), controlPoint2:CGPoint(x:minX + 0.33731 * w, y: minY + 0.07138 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.3813 * w, y: minY + 0.11985 * h), controlPoint1:CGPoint(x:minX + 0.3594 * w, y: minY + 0.0786 * h), controlPoint2:CGPoint(x:minX + 0.37445 * w, y: minY + 0.09648 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.39185 * w, y: minY + 0.3732 * h), controlPoint1:CGPoint(x:minX + 0.39283 * w, y: minY + 0.15973 * h), controlPoint2:CGPoint(x:minX + 0.39811 * w, y: minY + 0.28486 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.37973 * w, y: minY + 0.46636 * h), controlPoint1:CGPoint(x:minX + 0.38775 * w, y: minY + 0.43164 * h), controlPoint2:CGPoint(x:minX + 0.38599 * w, y: minY + 0.44505 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.28433 * w, y: minY + 0.34948 * h), controlPoint1:CGPoint(x:minX + 0.36351 * w, y: minY + 0.52342 * h), controlPoint2:CGPoint(x:minX + 0.32577 * w, y: minY + 0.47736 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.21884 * w, y: minY + 0.11951 * h), controlPoint1:CGPoint(x:minX + 0.26947 * w, y: minY + 0.30411 * h), controlPoint2:CGPoint(x:minX + 0.22802 * w, y: minY + 0.15835 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.19127 * w, y: minY + 0.05248 * h), controlPoint1:CGPoint(x:minX + 0.2075 * w, y: minY + 0.07241 * h), controlPoint2:CGPoint(x:minX + 0.20398 * w, y: minY + 0.06382 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.18052 * w, y: minY + 0.04285 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.09938 * w, y: minY + 0.04388 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.012 * w, y: minY + 0.0511 * h), controlPoint1:CGPoint(x:minX + 0.02607 * w, y: minY + 0.04491 * h), controlPoint2:CGPoint(x:minX + 0.01767 * w, y: minY + 0.0456 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00027 * w, y: minY + 0.0872 * h), controlPoint1:CGPoint(x:minX + 0.00281 * w, y: minY + 0.0597 * h), controlPoint2:CGPoint(x:minX + -0.0011 * w, y: minY + 0.07173 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.05481 * w, y: minY + 0.30101 * h), controlPoint1:CGPoint(x:minX + 0.00144 * w, y: minY + 0.1037 * h), controlPoint2:CGPoint(x:minX + 0.03213 * w, y: minY + 0.22401 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.17641 * w, y: minY + 0.65508 * h), controlPoint1:CGPoint(x:minX + 0.09899 * w, y: minY + 0.45089 * h), controlPoint2:CGPoint(x:minX + 0.13653 * w, y: minY + 0.55986 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.32128 * w, y: minY + 0.90774 * h), controlPoint1:CGPoint(x:minX + 0.23526 * w, y: minY + 0.79499 * h), controlPoint2:CGPoint(x:minX + 0.26126 * w, y: minY + 0.84036 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.39459 * w, y: minY + 0.97168 * h), controlPoint1:CGPoint(x:minX + 0.34923 * w, y: minY + 0.93937 * h), controlPoint2:CGPoint(x:minX + 0.36957 * w, y: minY + 0.9569 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49527 * w, y: minY + 0.9978 * h), controlPoint1:CGPoint(x:minX + 0.429 * w, y: minY + 0.99196 * h), controlPoint2:CGPoint(x:minX + 0.44386 * w, y: minY + 0.99574 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.57191 * w, y: minY + 0.98405 * h), controlPoint1:CGPoint(x:minX + 0.5463 * w, y: minY + 0.99987 * h), controlPoint2:CGPoint(x:minX + 0.56096 * w, y: minY + 0.99712 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5852 * w, y: minY + 0.9129 * h), controlPoint1:CGPoint(x:minX + 0.58071 * w, y: minY + 0.9734 * h), controlPoint2:CGPoint(x:minX + 0.58344 * w, y: minY + 0.95862 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.59869 * w, y: minY + 0.80805 * h), controlPoint1:CGPoint(x:minX + 0.58677 * w, y: minY + 0.86752 * h), controlPoint2:CGPoint(x:minX + 0.59185 * w, y: minY + 0.82868 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.62391 * w, y: minY + 0.76818 * h), controlPoint1:CGPoint(x:minX + 0.60495 * w, y: minY + 0.78983 * h), controlPoint2:CGPoint(x:minX + 0.61805 * w, y: minY + 0.76852 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.69625 * w, y: minY + 0.86271 * h), controlPoint1:CGPoint(x:minX + 0.64366 * w, y: minY + 0.76646 * h), controlPoint2:CGPoint(x:minX + 0.6548 * w, y: minY + 0.78089 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.77093 * w, y: minY + 0.97993 * h), controlPoint1:CGPoint(x:minX + 0.73515 * w, y: minY + 0.93937 * h), controlPoint2:CGPoint(x:minX + 0.74942 * w, y: minY + 0.96171 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.79732 * w, y: minY + 0.99815 * h), controlPoint1:CGPoint(x:minX + 0.7807 * w, y: minY + 0.98783 * h), controlPoint2:CGPoint(x:minX + 0.79243 * w, y: minY + 0.99608 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.97757 * w, y: minY + 0.9923 * h), controlPoint1:CGPoint(x:minX + 0.80905 * w, y: minY + 1.00296 * h), controlPoint2:CGPoint(x:minX + 0.96741 * w, y: minY + 0.99746 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99888 * w, y: minY + 0.95552 * h), controlPoint1:CGPoint(x:minX + 0.98774 * w, y: minY + 0.9868 * h), controlPoint2:CGPoint(x:minX + 0.99869 * w, y: minY + 0.9679 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.98324 * w, y: minY + 0.86993 * h), controlPoint1:CGPoint(x:minX + 0.99966 * w, y: minY + 0.92149 * h), controlPoint2:CGPoint(x:minX + 0.99673 * w, y: minY + 0.90602 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.89781 * w, y: minY + 0.70149 * h), controlPoint1:CGPoint(x:minX + 0.96526 * w, y: minY + 0.82249 * h), controlPoint2:CGPoint(x:minX + 0.95001 * w, y: minY + 0.79224 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.83838 * w, y: minY + 0.56364 * h), controlPoint1:CGPoint(x:minX + 0.84229 * w, y: minY + 0.60489 * h), controlPoint2:CGPoint(x:minX + 0.83857 * w, y: minY + 0.59595 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.89429 * w, y: minY + 0.40242 * h), controlPoint1:CGPoint(x:minX + 0.83838 * w, y: minY + 0.53648 * h), controlPoint2:CGPoint(x:minX + 0.84561 * w, y: minY + 0.51586 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99791 * w, y: minY + 0.11092 * h), controlPoint1:CGPoint(x:minX + 0.96291 * w, y: minY + 0.24257 * h), controlPoint2:CGPoint(x:minX + 0.99028 * w, y: minY + 0.16523 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.98833 * w, y: minY + 0.05248 * h), controlPoint1:CGPoint(x:minX + 1.0024 * w, y: minY + 0.07895 * h), controlPoint2:CGPoint(x:minX + 0.99986 * w, y: minY + 0.06348 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.98011 * w, y: minY + 0.04491 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.88139 * w, y: minY + 0.04595 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.77777 * w, y: minY + 0.0511 * h), controlPoint1:CGPoint(x:minX + 0.81159 * w, y: minY + 0.04698 * h), controlPoint2:CGPoint(x:minX + 0.78129 * w, y: minY + 0.04835 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.75548 * w, y: minY + 0.11538 * h), controlPoint1:CGPoint(x:minX + 0.77112 * w, y: minY + 0.0566 * h), controlPoint2:CGPoint(x:minX + 0.76428 * w, y: minY + 0.07688 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.65187 * w, y: minY + 0.43301 * h), controlPoint1:CGPoint(x:minX + 0.73202 * w, y: minY + 0.21817 * h), controlPoint2:CGPoint(x:minX + 0.68374 * w, y: minY + 0.36633 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61296 * w, y: minY + 0.48664 * h), controlPoint1:CGPoint(x:minX + 0.63916 * w, y: minY + 0.45948 * h), controlPoint2:CGPoint(x:minX + 0.61942 * w, y: minY + 0.48664 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.59048 * w, y: minY + 0.4557 * h), controlPoint1:CGPoint(x:minX + 0.60378 * w, y: minY + 0.48664 * h), controlPoint2:CGPoint(x:minX + 0.59615 * w, y: minY + 0.47633 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.5852 * w, y: minY + 0.4368 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.58579 * w, y: minY + 0.25839 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.57602 * w, y: minY + 0.03529 * h), controlPoint1:CGPoint(x:minX + 0.58638 * w, y: minY + 0.06623 * h), controlPoint2:CGPoint(x:minX + 0.58599 * w, y: minY + 0.06073 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.4767 * w, y: minY + 0.00023 * h), controlPoint1:CGPoint(x:minX + 0.56604 * w, y: minY + 0.01054 * h), controlPoint2:CGPoint(x:minX + 0.5418 * w, y: minY + 0.00194 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.41903 * w, y: minY + 0.00057 * h), controlPoint1:CGPoint(x:minX + 0.45031 * w, y: minY + -0.00012 * h), controlPoint2:CGPoint(x:minX + 0.4245 * w, y: minY + -0.00012 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.41903 * w, y: minY + 0.00057 * h))
        
        return pathPath
    }
    
    
}
