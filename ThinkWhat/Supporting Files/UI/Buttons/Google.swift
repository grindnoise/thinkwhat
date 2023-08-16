//
//  Google.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class GoogleButtonView: LoginButton, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var color : UIColor!
    var color1 : UIColor!
    var green : UIColor!
    var color2 : UIColor!
    var color3 : UIColor!
    
    //MARK: - Life Cycle
  override var state: Enums.EnabledState {
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
        self.authVariant = .Google
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
        
        let google2 = CALayer()
        self.layer.addSublayer(google2)
        layers["google2"] = google2
        let path5 = CAShapeLayer()
        google2.addSublayer(path5)
        layers["path5"] = path5
        
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
        if layerIds == nil || layerIds.contains("path5"){
            let path5 = layers["path5"] as! CAShapeLayer
            path5.fillColor   = self.color.cgColor
            path5.strokeColor = UIColor.black.cgColor
            path5.lineWidth   = 0
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
        
        if let google2 = layers["google2"]{
            google2.frame = CGRect(x: 0.295 * google2.superlayer!.bounds.width, y: 0.295 * google2.superlayer!.bounds.height, width: 0.41 * google2.superlayer!.bounds.width, height: 0.41 * google2.superlayer!.bounds.height)
        }
        
        if let path5 = layers["path5"] as? CAShapeLayer{
            path5.frame = CGRect(x: 0, y: 0, width:  path5.superlayer!.bounds.width, height:  path5.superlayer!.bounds.height)
            path5.path  = path5Path(bounds: layers["path5"]!.bounds).cgPath
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
    
    func path5Path(bounds: CGRect) -> UIBezierPath{
        let path5Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path5Path.move(to: CGPoint(x:minX + 0.47877 * w, y: minY + 0.00094 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.32096 * w, y: minY + 0.03538 * h), controlPoint1:CGPoint(x:minX + 0.42624 * w, y: minY + 0.00399 * h), controlPoint2:CGPoint(x:minX + 0.37126 * w, y: minY + 0.01598 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.24624 * w, y: minY + 0.07168 * h), controlPoint1:CGPoint(x:minX + 0.30267 * w, y: minY + 0.04236 * h), controlPoint2:CGPoint(x:minX + 0.26386 * w, y: minY + 0.06121 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.09145 * w, y: minY + 0.21337 * h), controlPoint1:CGPoint(x:minX + 0.18714 * w, y: minY + 0.10656 * h), controlPoint2:CGPoint(x:minX + 0.13204 * w, y: minY + 0.15702 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.03669 * w, y: minY + 0.31255 * h), controlPoint1:CGPoint(x:minX + 0.07182 * w, y: minY + 0.24061 * h), controlPoint2:CGPoint(x:minX + 0.04929 * w, y: minY + 0.28149 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.03625 * w, y: minY + 0.68639 * h), controlPoint1:CGPoint(x:minX + -0.01204 * w, y: minY + 0.43277 * h), controlPoint2:CGPoint(x:minX + -0.01227 * w, y: minY + 0.56595 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.07338 * w, y: minY + 0.75941 * h), controlPoint1:CGPoint(x:minX + 0.04338 * w, y: minY + 0.70426 * h), controlPoint2:CGPoint(x:minX + 0.06268 * w, y: minY + 0.74219 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.2168 * w, y: minY + 0.9096 * h), controlPoint1:CGPoint(x:minX + 0.1094 * w, y: minY + 0.81751 * h), controlPoint2:CGPoint(x:minX + 0.15892 * w, y: minY + 0.86939 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.32096 * w, y: minY + 0.96464 * h), controlPoint1:CGPoint(x:minX + 0.2439 * w, y: minY + 0.92846 * h), controlPoint2:CGPoint(x:minX + 0.28974 * w, y: minY + 0.95265 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.78847 * w, y: minY + 0.91963 * h), controlPoint1:CGPoint(x:minX + 0.47699 * w, y: minY + 1.02459 * h), controlPoint2:CGPoint(x:minX + 0.65442 * w, y: minY + 1.00748 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.91472 * w, y: minY + 0.79538 * h), controlPoint1:CGPoint(x:minX + 0.83866 * w, y: minY + 0.88661 * h), controlPoint2:CGPoint(x:minX + 0.88115 * w, y: minY + 0.84486 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.94561 * w, y: minY + 0.74306 * h), controlPoint1:CGPoint(x:minX + 0.92843 * w, y: minY + 0.77511 * h), controlPoint2:CGPoint(x:minX + 0.93423 * w, y: minY + 0.76541 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.99981 * w, y: minY + 0.51636 * h), controlPoint1:CGPoint(x:minX + 0.97929 * w, y: minY + 0.67691 * h), controlPoint2:CGPoint(x:minX + 0.99747 * w, y: minY + 0.60083 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.99155 * w, y: minY + 0.42339 * h), controlPoint1:CGPoint(x:minX + 1.0007 * w, y: minY + 0.48268 * h), controlPoint2:CGPoint(x:minX + 0.99858 * w, y: minY + 0.4586 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.98866 * w, y: minY + 0.40846 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.75011 * w, y: minY + 0.40846 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.51167 * w, y: minY + 0.40846 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.51167 * w, y: minY + 0.50546 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.51167 * w, y: minY + 0.60247 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.64829 * w, y: minY + 0.60247 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.78501 * w, y: minY + 0.60247 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.78423 * w, y: minY + 0.6065 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.77252 * w, y: minY + 0.64356 * h), controlPoint1:CGPoint(x:minX + 0.78312 * w, y: minY + 0.61293 * h), controlPoint2:CGPoint(x:minX + 0.77643 * w, y: minY + 0.63407 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.59029 * w, y: minY + 0.78666 * h), controlPoint1:CGPoint(x:minX + 0.74286 * w, y: minY + 0.7168 * h), controlPoint2:CGPoint(x:minX + 0.67728 * w, y: minY + 0.76824 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.48323 * w, y: minY + 0.79331 * h), controlPoint1:CGPoint(x:minX + 0.55884 * w, y: minY + 0.79331 * h), controlPoint2:CGPoint(x:minX + 0.51223 * w, y: minY + 0.79614 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.24167 * w, y: minY + 0.6308 * h), controlPoint1:CGPoint(x:minX + 0.37773 * w, y: minY + 0.78285 * h), controlPoint2:CGPoint(x:minX + 0.28851 * w, y: minY + 0.72279 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.21056 * w, y: minY + 0.50001 * h), controlPoint1:CGPoint(x:minX + 0.22071 * w, y: minY + 0.5896 * h), controlPoint2:CGPoint(x:minX + 0.21056 * w, y: minY + 0.54688 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.29866 * w, y: minY + 0.29184 * h), controlPoint1:CGPoint(x:minX + 0.21056 * w, y: minY + 0.42067 * h), controlPoint2:CGPoint(x:minX + 0.24145 * w, y: minY + 0.34775 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.47821 * w, y: minY + 0.20726 * h), controlPoint1:CGPoint(x:minX + 0.34762 * w, y: minY + 0.24399 * h), controlPoint2:CGPoint(x:minX + 0.40885 * w, y: minY + 0.21511 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.55438 * w, y: minY + 0.20835 * h), controlPoint1:CGPoint(x:minX + 0.49784 * w, y: minY + 0.20508 * h), controlPoint2:CGPoint(x:minX + 0.5371 * w, y: minY + 0.20563 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.68085 * w, y: minY + 0.25784 * h), controlPoint1:CGPoint(x:minX + 0.60212 * w, y: minY + 0.21598 * h), controlPoint2:CGPoint(x:minX + 0.6436 * w, y: minY + 0.23211 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.69713 * w, y: minY + 0.26928 * h), controlPoint1:CGPoint(x:minX + 0.6881 * w, y: minY + 0.26274 * h), controlPoint2:CGPoint(x:minX + 0.69546 * w, y: minY + 0.26797 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.70026 * w, y: minY + 0.27157 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.77498 * w, y: minY + 0.19865 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.8497 * w, y: minY + 0.12563 * h))
        path5Path.addLine(to: CGPoint(x:minX + 0.84434 * w, y: minY + 0.12094 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.82583 * w, y: minY + 0.10623 * h), controlPoint1:CGPoint(x:minX + 0.84144 * w, y: minY + 0.11833 * h), controlPoint2:CGPoint(x:minX + 0.83308 * w, y: minY + 0.11168 * h))
        path5Path.addCurve(to: CGPoint(x:minX + 0.47877 * w, y: minY + 0.00094 * h), controlPoint1:CGPoint(x:minX + 0.72524 * w, y: minY + 0.02993 * h), controlPoint2:CGPoint(x:minX + 0.60546 * w, y: minY + -0.00647 * h))
        path5Path.close()
        path5Path.move(to: CGPoint(x:minX + 0.47877 * w, y: minY + 0.00094 * h))
        
        return path5Path
    }
    
    
}

