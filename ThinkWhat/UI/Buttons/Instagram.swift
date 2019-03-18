//
//  Instagram.swift
//  SpamGuard
//
//  Created by Pavel Bukharov on 24.12.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class InstagramButtonView: ParentLoginButton, CAAnimationDelegate {
    
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
        self.authVariant = .Instagram
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
        
        let instagramiconlogovectordownload = CALayer()
        self.layer.addSublayer(instagramiconlogovectordownload)
        layers["instagramiconlogovectordownload"] = instagramiconlogovectordownload
        let path = CAShapeLayer()
        instagramiconlogovectordownload.addSublayer(path)
        layers["path"] = path
        let path2 = CAShapeLayer()
        instagramiconlogovectordownload.addSublayer(path2)
        layers["path2"] = path2
        let path3 = CAShapeLayer()
        instagramiconlogovectordownload.addSublayer(path3)
        layers["path3"] = path3
        
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
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path2"){
            let path2 = layers["path2"] as! CAShapeLayer
            path2.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path2.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path3"){
            let path3 = layers["path3"] as! CAShapeLayer
            path3.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path3.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path3.lineWidth   = 0
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
        
        if let instagramiconlogovectordownload = layers["instagramiconlogovectordownload"]{
            instagramiconlogovectordownload.frame = CGRect(x: 0.29593 * instagramiconlogovectordownload.superlayer!.bounds.width, y: 0.29596 * instagramiconlogovectordownload.superlayer!.bounds.height, width: 0.40814 * instagramiconlogovectordownload.superlayer!.bounds.width, height: 0.40808 * instagramiconlogovectordownload.superlayer!.bounds.height)
        }
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0, y: 0, width: 1 * path.superlayer!.bounds.width, height: 1 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let path2 = layers["path2"] as? CAShapeLayer{
            path2.frame = CGRect(x: 0.70729 * path2.superlayer!.bounds.width, y: 0.17257 * path2.superlayer!.bounds.height, width: 0.11996 * path2.superlayer!.bounds.width, height: 0.12024 * path2.superlayer!.bounds.height)
            path2.path  = path2Path(bounds: layers["path2"]!.bounds).cgPath
        }
        
        if let path3 = layers["path3"] as? CAShapeLayer{
            path3.frame = CGRect(x: 0.243 * path3.superlayer!.bounds.width, y: 0.24353 * path3.superlayer!.bounds.height, width: 0.514 * path3.superlayer!.bounds.width, height: 0.51372 * path3.superlayer!.bounds.height)
            path3.path  = path3Path(bounds: layers["path3"]!.bounds).cgPath
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
    
    override func removeAllAnimations() {
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
        
        pathPath.move(to: CGPoint(x:minX + 0.31329 * w, y: minY + 0.00064 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.11647 * w, y: minY + 0.05446 * h), controlPoint1:CGPoint(x:minX + 0.22279 * w, y: minY + 0.00459 * h), controlPoint2:CGPoint(x:minX + 0.16678 * w, y: minY + 0.01975 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.05255 * w, y: minY + 0.11905 * h), controlPoint1:CGPoint(x:minX + 0.09802 * w, y: minY + 0.0672 * h), controlPoint2:CGPoint(x:minX + 0.06485 * w, y: minY + 0.10081 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00313 * w, y: minY + 0.26953 * h), controlPoint1:CGPoint(x:minX + 0.02532 * w, y: minY + 0.15947 * h), controlPoint2:CGPoint(x:minX + 0.00972 * w, y: minY + 0.20714 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00313 * w, y: minY + 0.73088 * h), controlPoint1:CGPoint(x:minX + -0.00104 * w, y: minY + 0.30886 * h), controlPoint2:CGPoint(x:minX + -0.00104 * w, y: minY + 0.69156 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.08528 * w, y: minY + 0.91893 * h), controlPoint1:CGPoint(x:minX + 0.01214 * w, y: minY + 0.81546 * h), controlPoint2:CGPoint(x:minX + 0.03652 * w, y: minY + 0.87148 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.22169 * w, y: minY + 0.98989 * h), controlPoint1:CGPoint(x:minX + 0.12394 * w, y: minY + 0.9565 * h), controlPoint2:CGPoint(x:minX + 0.16414 * w, y: minY + 0.97759 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.26518 * w, y: minY + 0.99912 * h), controlPoint2:CGPoint(x:minX + 0.28649 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.77831 * w, y: minY + 0.98989 * h), controlPoint1:CGPoint(x:minX + 0.71351 * w, y: minY + h), controlPoint2:CGPoint(x:minX + 0.73482 * w, y: minY + 0.99912 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.91472 * w, y: minY + 0.91893 * h), controlPoint1:CGPoint(x:minX + 0.83586 * w, y: minY + 0.97759 * h), controlPoint2:CGPoint(x:minX + 0.87606 * w, y: minY + 0.9565 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99687 * w, y: minY + 0.73088 * h), controlPoint1:CGPoint(x:minX + 0.96348 * w, y: minY + 0.87148 * h), controlPoint2:CGPoint(x:minX + 0.98786 * w, y: minY + 0.81546 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99687 * w, y: minY + 0.26953 * h), controlPoint1:CGPoint(x:minX + 1.00104 * w, y: minY + 0.69156 * h), controlPoint2:CGPoint(x:minX + 1.00104 * w, y: minY + 0.30886 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.94569 * w, y: minY + 0.11663 * h), controlPoint1:CGPoint(x:minX + 0.99006 * w, y: minY + 0.2056 * h), controlPoint2:CGPoint(x:minX + 0.97424 * w, y: minY + 0.15815 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.88111 * w, y: minY + 0.0527 * h), controlPoint1:CGPoint(x:minX + 0.93295 * w, y: minY + 0.09818 * h), controlPoint2:CGPoint(x:minX + 0.89934 * w, y: minY + 0.065 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.73394 * w, y: minY + 0.00349 * h), controlPoint1:CGPoint(x:minX + 0.84179 * w, y: minY + 0.02634 * h), controlPoint2:CGPoint(x:minX + 0.79456 * w, y: minY + 0.01052 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.31329 * w, y: minY + 0.00064 * h), controlPoint1:CGPoint(x:minX + 0.71373 * w, y: minY + 0.00107 * h), controlPoint2:CGPoint(x:minX + 0.3581 * w, y: minY + -0.00112 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.68451 * w, y: minY + 0.09159 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.78094 * w, y: minY + 0.10499 * h), controlPoint1:CGPoint(x:minX + 0.7302 * w, y: minY + 0.09378 * h), controlPoint2:CGPoint(x:minX + 0.7581 * w, y: minY + 0.09774 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.89275 * w, y: minY + 0.21242 * h), controlPoint1:CGPoint(x:minX + 0.83718 * w, y: minY + 0.12278 * h), controlPoint2:CGPoint(x:minX + 0.87386 * w, y: minY + 0.15815 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.91076 * w, y: minY + 0.50021 * h), controlPoint1:CGPoint(x:minX + 0.90791 * w, y: minY + 0.25569 * h), controlPoint2:CGPoint(x:minX + 0.91076 * w, y: minY + 0.30117 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.89231 * w, y: minY + 0.78844 * h), controlPoint1:CGPoint(x:minX + 0.91076 * w, y: minY + 0.70166 * h), controlPoint2:CGPoint(x:minX + 0.90813 * w, y: minY + 0.7423 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.85233 * w, y: minY + 0.85259 * h), controlPoint1:CGPoint(x:minX + 0.88265 * w, y: minY + 0.817 * h), controlPoint2:CGPoint(x:minX + 0.87364 * w, y: minY + 0.8315 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.78819 * w, y: minY + 0.89257 * h), controlPoint1:CGPoint(x:minX + 0.83125 * w, y: minY + 0.8739 * h), controlPoint2:CGPoint(x:minX + 0.81675 * w, y: minY + 0.88291 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.91103 * h), controlPoint1:CGPoint(x:minX + 0.74206 * w, y: minY + 0.90839 * h), controlPoint2:CGPoint(x:minX + 0.70143 * w, y: minY + 0.91103 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.21181 * w, y: minY + 0.89257 * h), controlPoint1:CGPoint(x:minX + 0.29857 * w, y: minY + 0.91103 * h), controlPoint2:CGPoint(x:minX + 0.25794 * w, y: minY + 0.90839 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.14767 * w, y: minY + 0.85259 * h), controlPoint1:CGPoint(x:minX + 0.18325 * w, y: minY + 0.88291 * h), controlPoint2:CGPoint(x:minX + 0.16875 * w, y: minY + 0.8739 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.10769 * w, y: minY + 0.78844 * h), controlPoint1:CGPoint(x:minX + 0.12636 * w, y: minY + 0.8315 * h), controlPoint2:CGPoint(x:minX + 0.11735 * w, y: minY + 0.817 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.08924 * w, y: minY + 0.50021 * h), controlPoint1:CGPoint(x:minX + 0.09187 * w, y: minY + 0.7423 * h), controlPoint2:CGPoint(x:minX + 0.08924 * w, y: minY + 0.70166 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.10791 * w, y: minY + 0.21066 * h), controlPoint1:CGPoint(x:minX + 0.08924 * w, y: minY + 0.29853 * h), controlPoint2:CGPoint(x:minX + 0.09209 * w, y: minY + 0.25503 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.13646 * w, y: minY + 0.15881 * h), controlPoint1:CGPoint(x:minX + 0.11625 * w, y: minY + 0.18715 * h), controlPoint2:CGPoint(x:minX + 0.12241 * w, y: minY + 0.17617 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.3089 * w, y: minY + 0.09181 * h), controlPoint1:CGPoint(x:minX + 0.17183 * w, y: minY + 0.11531 * h), controlPoint2:CGPoint(x:minX + 0.22213 * w, y: minY + 0.09576 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.68451 * w, y: minY + 0.09159 * h), controlPoint1:CGPoint(x:minX + 0.35986 * w, y: minY + 0.08939 * h), controlPoint2:CGPoint(x:minX + 0.63531 * w, y: minY + 0.08917 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.68451 * w, y: minY + 0.09159 * h))
        
        return pathPath
    }
    
    func path2Path(bounds: CGRect) -> UIBezierPath{
        let path2Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path2Path.move(to: CGPoint(x:minX + 0.29536 * w, y: minY + 0.04635 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.02801 * w, y: minY + 0.32407 * h), controlPoint1:CGPoint(x:minX + 0.18549 * w, y: minY + 0.09751 * h), controlPoint2:CGPoint(x:minX + 0.0628 * w, y: minY + 0.22541 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.37227 * w, y: minY + 0.98183 * h), controlPoint1:CGPoint(x:minX + -0.06721 * w, y: minY + 0.60179 * h), controlPoint2:CGPoint(x:minX + 0.08844 * w, y: minY + 0.89961 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.97288 * w, y: minY + 0.67305 * h), controlPoint1:CGPoint(x:minX + 0.61398 * w, y: minY + 1.05126 * h), controlPoint2:CGPoint(x:minX + 0.87949 * w, y: minY + 0.91605 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.93443 * w, y: minY + 0.2455 * h), controlPoint1:CGPoint(x:minX + 1.02049 * w, y: minY + 0.54515 * h), controlPoint2:CGPoint(x:minX + 1.00401 * w, y: minY + 0.35878 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.29536 * w, y: minY + 0.04635 * h), controlPoint1:CGPoint(x:minX + 0.79709 * w, y: minY + 0.02442 * h), controlPoint2:CGPoint(x:minX + 0.52242 * w, y: minY + -0.06145 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.29536 * w, y: minY + 0.04635 * h))
        
        return path2Path
    }
    
    func path3Path(bounds: CGRect) -> UIBezierPath{
        let path3Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path3Path.move(to: CGPoint(x:minX + 0.41239 * w, y: minY + 0.00615 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.21667 * w, y: minY + 0.08526 * h), controlPoint1:CGPoint(x:minX + 0.34701 * w, y: minY + 0.01684 * h), controlPoint2:CGPoint(x:minX + 0.27521 * w, y: minY + 0.04635 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.0859 * w, y: minY + 0.21612 * h), controlPoint1:CGPoint(x:minX + 0.18248 * w, y: minY + 0.10836 * h), controlPoint2:CGPoint(x:minX + 0.10897 * w, y: minY + 0.18191 * h))
        path3Path.addCurve(to: CGPoint(x:minX, y: minY + 0.49965 * h), controlPoint1:CGPoint(x:minX + 0.02906 * w, y: minY + 0.30122 * h), controlPoint2:CGPoint(x:minX, y: minY + 0.39659 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.13846 * w, y: minY + 0.84519 * h), controlPoint1:CGPoint(x:minX, y: minY + 0.63308 * h), controlPoint2:CGPoint(x:minX + 0.04701 * w, y: minY + 0.74983 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.26966 * w, y: minY + 0.94441 * h), controlPoint1:CGPoint(x:minX + 0.18162 * w, y: minY + 0.89009 * h), controlPoint2:CGPoint(x:minX + 0.21752 * w, y: minY + 0.91746 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.34359 * w, y: minY + 0.98247 * h), controlPoint2:CGPoint(x:minX + 0.41538 * w, y: minY + h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.73034 * w, y: minY + 0.94441 * h), controlPoint1:CGPoint(x:minX + 0.58462 * w, y: minY + h), controlPoint2:CGPoint(x:minX + 0.65641 * w, y: minY + 0.98247 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.86154 * w, y: minY + 0.84519 * h), controlPoint1:CGPoint(x:minX + 0.78248 * w, y: minY + 0.91746 * h), controlPoint2:CGPoint(x:minX + 0.81838 * w, y: minY + 0.89009 * h))
        path3Path.addCurve(to: CGPoint(x:minX + w, y: minY + 0.49965 * h), controlPoint1:CGPoint(x:minX + 0.95299 * w, y: minY + 0.74983 * h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.63308 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.94444 * w, y: minY + 0.26915 * h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.41498 * h), controlPoint2:CGPoint(x:minX + 0.98248 * w, y: minY + 0.34313 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.8453 * w, y: minY + 0.13786 * h), controlPoint1:CGPoint(x:minX + 0.91752 * w, y: minY + 0.21698 * h), controlPoint2:CGPoint(x:minX + 0.89017 * w, y: minY + 0.18106 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.58333 * w, y: minY + 0.00572 * h), controlPoint1:CGPoint(x:minX + 0.77051 * w, y: minY + 0.06602 * h), controlPoint2:CGPoint(x:minX + 0.68291 * w, y: minY + 0.02197 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.41239 * w, y: minY + 0.00615 * h), controlPoint1:CGPoint(x:minX + 0.53632 * w, y: minY + -0.00198 * h), controlPoint2:CGPoint(x:minX + 0.45855 * w, y: minY + -0.00198 * h))
        path3Path.close()
        path3Path.move(to: CGPoint(x:minX + 0.57863 * w, y: minY + 0.18533 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.72863 * w, y: minY + 0.27086 * h), controlPoint1:CGPoint(x:minX + 0.64017 * w, y: minY + 0.20201 * h), controlPoint2:CGPoint(x:minX + 0.6859 * w, y: minY + 0.22767 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.82222 * w, y: minY + 0.49965 * h), controlPoint1:CGPoint(x:minX + 0.79231 * w, y: minY + 0.33415 * h), controlPoint2:CGPoint(x:minX + 0.82222 * w, y: minY + 0.40814 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.72863 * w, y: minY + 0.72844 * h), controlPoint1:CGPoint(x:minX + 0.82222 * w, y: minY + 0.59117 * h), controlPoint2:CGPoint(x:minX + 0.79231 * w, y: minY + 0.66515 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.27137 * w, y: minY + 0.72844 * h), controlPoint1:CGPoint(x:minX + 0.60171 * w, y: minY + 0.85546 * h), controlPoint2:CGPoint(x:minX + 0.39829 * w, y: minY + 0.85546 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.3406 * w, y: minY + 0.21698 * h), controlPoint1:CGPoint(x:minX + 0.11966 * w, y: minY + 0.57706 * h), controlPoint2:CGPoint(x:minX + 0.15385 * w, y: minY + 0.32517 * h))
        path3Path.addCurve(to: CGPoint(x:minX + 0.57863 * w, y: minY + 0.18533 * h), controlPoint1:CGPoint(x:minX + 0.40726 * w, y: minY + 0.17849 * h), controlPoint2:CGPoint(x:minX + 0.50513 * w, y: minY + 0.16523 * h))
        path3Path.close()
        path3Path.move(to: CGPoint(x:minX + 0.57863 * w, y: minY + 0.18533 * h))
        
        return path3Path
    }
}
