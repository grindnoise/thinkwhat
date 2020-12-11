//
//  ThumbUp.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.09.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ThumbUp: Icon, CAAnimationDelegate {
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
        self.active = Colors.UpperButtons.HoneyYellow//K_COLOR_RED//UIColor(red:1.00, green: 0.15, blue:0.00, alpha:1.0)
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
            path.fillColor   = self.inactive.cgColor
            path.strokeColor = UIColor.black.cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.12402 * path.superlayer!.bounds.width, y: 0, width: 0.75196 * path.superlayer!.bounds.width, height: 0.77849 * path.superlayer!.bounds.height)
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
                                            NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1))]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 0.15
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [self.active.cgColor,
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
        
        let path = layers["path"] as! CAShapeLayer
        
        ////Path animation
        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1)),
                                            NSValue(caTransform3D: CATransform3DIdentity)]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 0.15
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [active.cgColor, inactive.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.15
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
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
        
        pathPath.move(to: CGPoint(x:minX + 0.54659 * w, y: minY + 0.00605 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51553 * w, y: minY + 0.08541 * h), controlPoint1:CGPoint(x:minX + 0.52655 * w, y: minY + 0.01573 * h), controlPoint2:CGPoint(x:minX + 0.52154 * w, y: minY + 0.02831 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.35722 * w, y: minY + 0.36027 * h), controlPoint1:CGPoint(x:minX + 0.50401 * w, y: minY + 0.18655 * h), controlPoint2:CGPoint(x:minX + 0.45691 * w, y: minY + 0.26833 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.30912 * w, y: minY + 0.40479 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.31063 * w, y: minY + 0.67772 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.31213 * w, y: minY + 0.95112 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.32916 * w, y: minY + 0.96806 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61623 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.36072 * w, y: minY + 0.99952 * h), controlPoint2:CGPoint(x:minX + 0.36573 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.84117 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.85319 * w, y: minY + 0.98839 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.92032 * w, y: minY + 0.8316 * h), controlPoint1:CGPoint(x:minX + 0.87423 * w, y: minY + 0.96806 * h), controlPoint2:CGPoint(x:minX + 0.89427 * w, y: minY + 0.92209 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99497 * w, y: minY + 0.43189 * h), controlPoint1:CGPoint(x:minX + 0.98545 * w, y: minY + 0.60852 * h), controlPoint2:CGPoint(x:minX + 1.012 * w, y: minY + 0.46721 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.81011 * w, y: minY + 0.40092 * h), controlPoint1:CGPoint(x:minX + 0.98194 * w, y: minY + 0.40334 * h), controlPoint2:CGPoint(x:minX + 0.97743 * w, y: minY + 0.40237 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.65681 * w, y: minY + 0.39947 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.66582 * w, y: minY + 0.36221 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61823 * w, y: minY + 0.01282 * h), controlPoint1:CGPoint(x:minX + 0.70891 * w, y: minY + 0.18945 * h), controlPoint2:CGPoint(x:minX + 0.69087 * w, y: minY + 0.05637 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.54659 * w, y: minY + 0.00605 * h), controlPoint1:CGPoint(x:minX + 0.59418 * w, y: minY + -0.00121 * h), controlPoint2:CGPoint(x:minX + 0.56663 * w, y: minY + -0.00412 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.00903 * w, y: minY + 0.40963 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.01605 * w, y: minY + 0.7232 * h), controlPoint1:CGPoint(x:minX + -0.00399 * w, y: minY + 0.42221 * h), controlPoint2:CGPoint(x:minX + -0.00399 * w, y: minY + 0.41302 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.0416 * w, y: minY + 0.99032 * h), controlPoint1:CGPoint(x:minX + 0.03058 * w, y: minY + 0.94919 * h), controlPoint2:CGPoint(x:minX + 0.03408 * w, y: minY + 0.9821 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.13929 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.05011 * w, y: minY + 0.99903 * h), controlPoint2:CGPoint(x:minX + 0.05763 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23347 * w, y: minY + 0.99419 * h), controlPoint1:CGPoint(x:minX + 0.20091 * w, y: minY + h), controlPoint2:CGPoint(x:minX + 0.22947 * w, y: minY + 0.99806 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23949 * w, y: minY + 0.71207 * h), controlPoint1:CGPoint(x:minX + 0.23798 * w, y: minY + 0.98984 * h), controlPoint2:CGPoint(x:minX + 0.23949 * w, y: minY + 0.92064 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23648 * w, y: minY + 0.42511 * h), controlPoint1:CGPoint(x:minX + 0.23949 * w, y: minY + 0.56061 * h), controlPoint2:CGPoint(x:minX + 0.23798 * w, y: minY + 0.4314 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.11173 * w, y: minY + 0.39995 * h), controlPoint1:CGPoint(x:minX + 0.23047 * w, y: minY + 0.40334 * h), controlPoint2:CGPoint(x:minX + 0.21243 * w, y: minY + 0.39995 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00903 * w, y: minY + 0.40963 * h), controlPoint1:CGPoint(x:minX + 0.02557 * w, y: minY + 0.39995 * h), controlPoint2:CGPoint(x:minX + 0.01855 * w, y: minY + 0.40043 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.00903 * w, y: minY + 0.40963 * h))
        
        return pathPath
    }
    
    
}
