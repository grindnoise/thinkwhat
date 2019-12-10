//
//  NewIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class NewIcon: Icon, CAAnimationDelegate {
    
    override var state: Icon.State {
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
    
    var active : UIColor!
    var active1 : UIColor!
    
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
        self.active = UIColor(red:0, green: 0.56, blue:0, alpha:1)
        self.active1 = UIColor(red:0, green: 0.56, blue:0, alpha:1)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
        let path = CAShapeLayer()
        self.layer.addSublayer(path)
        layers["path"] = path
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillRule    = .evenOdd
            path.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            path.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.10993 * path.superlayer!.bounds.width, y: 0.10993 * path.superlayer!.bounds.height, width: 0.78014 * path.superlayer!.bounds.width, height: 0.78014 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
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
        
        let path = layers["path"] as! CAShapeLayer
        
        ////Path animation
        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                            NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1))]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 0.15
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [self.active1.cgColor,
                                            self.active.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.15
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathFillColorAnim], fillMode:fillMode)
        path.add(pathEnableAnim, forKey:"pathEnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.2
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        let path = layers["path"] as! CAShapeLayer
        
        ////Path animation
        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)),
                                            NSValue(caTransform3D: CATransform3DIdentity)]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 0.2
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [UIColor(red:0, green: 0.56, blue:0, alpha:1).cgColor,
                                            UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathFillColorAnim], fillMode:fillMode)
        path.add(pathDisableAnim, forKey:"pathDisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathEnableAnim"), theLayer:layers["path"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathDisableAnim"), theLayer:layers["path"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["path"]?.removeAnimation(forKey: "pathEnableAnim")
        }
        else if identifier == "disable"{
            layers["path"]?.removeAnimation(forKey: "pathDisableAnim")
        }
    }
    
    override func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX + 0.3567 * w, y: minY + 0.11487 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.13723 * w, y: minY + 0.30153 * h), controlPoint1:CGPoint(x:minX + 0.15142 * w, y: minY + 0.09053 * h), controlPoint2:CGPoint(x:minX + 0.14935 * w, y: minY + 0.09029 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.08748 * w, y: minY + 0.58751 * h), controlPoint1:CGPoint(x:minX + -0.03546 * w, y: minY + 0.41663 * h), controlPoint2:CGPoint(x:minX + -0.0372 * w, y: minY + 0.41779 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23073 * w, y: minY + 0.839 * h), controlPoint1:CGPoint(x:minX + 0.02819 * w, y: minY + 0.78819 * h), controlPoint2:CGPoint(x:minX + 0.02759 * w, y: minY + 0.79022 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49995 * w, y: minY + 0.93832 * h), controlPoint1:CGPoint(x:minX + 0.31257 * w, y: minY + 1.03136 * h), controlPoint2:CGPoint(x:minX + 0.3134 * w, y: minY + 1.0333 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.76918 * w, y: minY + 0.839 * h), controlPoint1:CGPoint(x:minX + 0.68464 * w, y: minY + 1.03235 * h), controlPoint2:CGPoint(x:minX + 0.68651 * w, y: minY + 1.0333 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.91243 * w, y: minY + 0.58751 * h), controlPoint1:CGPoint(x:minX + 0.97029 * w, y: minY + 0.79071 * h), controlPoint2:CGPoint(x:minX + 0.97232 * w, y: minY + 0.79022 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.86268 * w, y: minY + 0.30153 * h), controlPoint1:CGPoint(x:minX + 1.03586 * w, y: minY + 0.41949 * h), controlPoint2:CGPoint(x:minX + 1.03711 * w, y: minY + 0.41779 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.64321 * w, y: minY + 0.11487 * h), controlPoint1:CGPoint(x:minX + 0.85068 * w, y: minY + 0.0924 * h), controlPoint2:CGPoint(x:minX + 0.85056 * w, y: minY + 0.09029 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.3567 * w, y: minY + 0.11487 * h), controlPoint1:CGPoint(x:minX + 0.50139 * w, y: minY + -0.03752 * h), controlPoint2:CGPoint(x:minX + 0.49995 * w, y: minY + -0.03906 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.3567 * w, y: minY + 0.11487 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.18351 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.22798 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.30881 * w, y: minY + 0.54021 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.30881 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.34833 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.34833 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.30592 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.22303 * w, y: minY + 0.45731 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.22303 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.18351 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.18351 * w, y: minY + 0.39852 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.53793 * w, y: minY + 0.43446 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43053 * w, y: minY + 0.43446 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43053 * w, y: minY + 0.47756 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.52912 * w, y: minY + 0.47756 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.52912 * w, y: minY + 0.51281 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43053 * w, y: minY + 0.51281 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43053 * w, y: minY + 0.56499 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.54289 * w, y: minY + 0.56499 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.54289 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.38909 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.38909 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.53793 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.53793 * w, y: minY + 0.43446 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.60362 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.63047 * w, y: minY + 0.51473 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.63625 * w, y: minY + 0.54709 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.64217 * w, y: minY + 0.51542 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.66503 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.70978 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.73388 * w, y: minY + 0.51473 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.74007 * w, y: minY + 0.54709 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.74627 * w, y: minY + 0.51597 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.77339 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.81649 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.75935 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.71887 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.69436 * w, y: minY + 0.48279 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.6872 * w, y: minY + 0.44355 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.68004 * w, y: minY + 0.48279 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.65553 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.61615 * w, y: minY + 0.60148 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.55859 * w, y: minY + 0.39852 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.60362 * w, y: minY + 0.39852 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.60362 * w, y: minY + 0.39852 * h))
        
        return pathPath
    }
    
    
}
