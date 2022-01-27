//
//  HeartButton.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class HeartView: UIView, CAAnimationDelegate {
    
    enum State {
        case enabled, disabled
    }
    
    var state: HeartView.State = .disabled {
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
    
    var disabled : UIColor!
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
        self.disabled = UIColor(red:0.754, green: 0.754, blue:0.754, alpha:1)
        self.active = UIColor(red:1.00, green: 0.00, blue:0.00, alpha:0.7)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0)
        
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
            path.fillColor   = self.disabled.cgColor
            path.strokeColor = UIColor.black.cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.09817 * path.superlayer!.bounds.width, y: 0.15587 * path.superlayer!.bounds.height, width: 0.80366 * path.superlayer!.bounds.width, height: 0.68827 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.2
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Path animation
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [self.disabled.cgColor,
                                            self.active.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let path = layers["path"] as! CAShapeLayer
        
        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                            NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)),
                                            NSValue(caTransform3D: CATransform3DIdentity)]
        pathTransformAnim.keyTimes       = [0, 0.5, 1]
        pathTransformAnim.duration       = 0.2
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim, pathTransformAnim], fillMode:fillMode)
        path.add(pathEnableAnim, forKey:"pathEnableAnim")
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
        
        ////Path animation
        let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values   = [self.active.cgColor,
                                      self.disabled.cgColor]
        pathFillColorAnim.keyTimes = [0, 1]
        pathFillColorAnim.duration = 0.14
        
        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathDisableAnim, forKey:"pathDisableAnim")
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
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX + 0.22948 * w, y: minY + 0.0017 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.0168 * w, y: minY + 0.18132 * h), controlPoint1:CGPoint(x:minX + 0.12555 * w, y: minY + 0.01255 * h), controlPoint2:CGPoint(x:minX + 0.04846 * w, y: minY + 0.07764 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00046 * w, y: minY + 0.31895 * h), controlPoint1:CGPoint(x:minX + 0.00545 * w, y: minY + 0.21889 * h), controlPoint2:CGPoint(x:minX + -0.00195 * w, y: minY + 0.28158 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.05603 * w, y: minY + 0.49676 * h), controlPoint1:CGPoint(x:minX + 0.00441 * w, y: minY + 0.37741 * h), controlPoint2:CGPoint(x:minX + 0.02455 * w, y: minY + 0.44171 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.13501 * w, y: minY + 0.60546 * h), controlPoint1:CGPoint(x:minX + 0.07634 * w, y: minY + 0.53192 * h), controlPoint2:CGPoint(x:minX + 0.10783 * w, y: minY + 0.57532 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.31948 * w, y: minY + 0.81281 * h), controlPoint1:CGPoint(x:minX + 0.14809 * w, y: minY + 0.61992 * h), controlPoint2:CGPoint(x:minX + 0.23103 * w, y: minY + 0.71315 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.4857 * w, y: minY + 0.99705 * h), controlPoint1:CGPoint(x:minX + 0.40792 * w, y: minY + 0.91246 * h), controlPoint2:CGPoint(x:minX + 0.48277 * w, y: minY + 0.99524 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51306 * w, y: minY + 0.99805 * h), controlPoint1:CGPoint(x:minX + 0.49206 * w, y: minY + 1.00046 * h), controlPoint2:CGPoint(x:minX + 0.50652 * w, y: minY + 1.00107 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61045 * w, y: minY + 0.89257 * h), controlPoint1:CGPoint(x:minX + 0.51873 * w, y: minY + 0.99564 * h), controlPoint2:CGPoint(x:minX + 0.52596 * w, y: minY + 0.98761 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.77219 * w, y: minY + 0.71094 * h), controlPoint1:CGPoint(x:minX + 0.64882 * w, y: minY + 0.84957 * h), controlPoint2:CGPoint(x:minX + 0.72161 * w, y: minY + 0.7678 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.91278 * w, y: minY + 0.54599 * h), controlPoint1:CGPoint(x:minX + 0.87767 * w, y: minY + 0.5926 * h), controlPoint2:CGPoint(x:minX + 0.88817 * w, y: minY + 0.58034 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99916 * w, y: minY + 0.32658 * h), controlPoint1:CGPoint(x:minX + 0.96509 * w, y: minY + 0.47305 * h), controlPoint2:CGPoint(x:minX + 0.99451 * w, y: minY + 0.39811 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.97266 * w, y: minY + 0.14997 * h), controlPoint1:CGPoint(x:minX + 1.00311 * w, y: minY + 0.2651 * h), controlPoint2:CGPoint(x:minX + 0.99296 * w, y: minY + 0.19739 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.90417 * w, y: minY + 0.05594 * h), controlPoint1:CGPoint(x:minX + 0.95786 * w, y: minY + 0.11562 * h), controlPoint2:CGPoint(x:minX + 0.93067 * w, y: minY + 0.07845 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.7395 * w, y: minY + 0.00069 * h), controlPoint1:CGPoint(x:minX + 0.86184 * w, y: minY + 0.01998 * h), controlPoint2:CGPoint(x:minX + 0.8054 * w, y: minY + 0.00089 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.62972 * w, y: minY + 0.02982 * h), controlPoint1:CGPoint(x:minX + 0.69666 * w, y: minY + 0.00049 * h), controlPoint2:CGPoint(x:minX + 0.66964 * w, y: minY + 0.00752 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51202 * w, y: minY + 0.12767 * h), controlPoint1:CGPoint(x:minX + 0.59565 * w, y: minY + 0.04851 * h), controlPoint2:CGPoint(x:minX + 0.54403 * w, y: minY + 0.09151 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.50049 * w, y: minY + 0.14073 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.48604 * w, y: minY + 0.12486 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.37798 * w, y: minY + 0.03364 * h), controlPoint1:CGPoint(x:minX + 0.45799 * w, y: minY + 0.09392 * h), controlPoint2:CGPoint(x:minX + 0.40603 * w, y: minY + 0.04992 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.22948 * w, y: minY + 0.0017 * h), controlPoint1:CGPoint(x:minX + 0.32877 * w, y: minY + 0.00471 * h), controlPoint2:CGPoint(x:minX + 0.28747 * w, y: minY + -0.00413 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.22948 * w, y: minY + 0.0017 * h))
        
        return pathPath
    }
    
    
}
