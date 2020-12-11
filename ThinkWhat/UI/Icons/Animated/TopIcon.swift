//
//  TopIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class TopIcon: Icon, CAAnimationDelegate {
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
        self.active = Colors.UpperButtons.HoneyYellow//K_COLOR_RED//K_COLOR_RED//UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
        let Group = CALayer()
        self.layer.addSublayer(Group)
        layers["Group"] = Group
        let path = CAShapeLayer()
        Group.addSublayer(path)
        layers["path"] = path
        let path2 = CAShapeLayer()
        Group.addSublayer(path2)
        layers["path2"] = path2
        
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
        if layerIds == nil || layerIds.contains("path2"){
            let path2 = layers["path2"] as! CAShapeLayer
            path2.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            path2.strokeColor = UIColor.black.cgColor
            path2.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let Group = layers["Group"]{
            Group.frame = CGRect(x: 0.11 * Group.superlayer!.bounds.width, y: 0.11 * Group.superlayer!.bounds.height, width: 0.78 * Group.superlayer!.bounds.width, height: 0.96523 * Group.superlayer!.bounds.height)
        }
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0, y: 0, width:  path.superlayer!.bounds.width, height: 0.8081 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let path2 = layers["path2"] as? CAShapeLayer{
            path2.frame = CGRect(x: 0.04226 * path2.superlayer!.bounds.width, y: 0.76054 * path2.superlayer!.bounds.height, width: 0.91548 * path2.superlayer!.bounds.width, height: 0.23946 * path2.superlayer!.bounds.height)
            path2.path  = path2Path(bounds: layers["path2"]!.bounds).cgPath
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
        
        let Group = layers["Group"] as! CALayer
        
        ////Group animation
        let GroupTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        GroupTransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                             NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1))]
        GroupTransformAnim.keyTimes       = [0, 1]
        GroupTransformAnim.duration       = 0.15
        GroupTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let GroupEnableAnim : CAAnimationGroup = QCMethod.group(animations: [GroupTransformAnim], fillMode:fillMode)
        Group.add(GroupEnableAnim, forKey:"GroupEnableAnim")
        
        ////Path animation
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [self.active.cgColor,
                                            self.active.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.15
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathEnableAnim, forKey:"pathEnableAnim")
        
        ////Path2 animation
        let path2FillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        path2FillColorAnim.values         = [self.active.cgColor,
                                             self.active.cgColor]
        path2FillColorAnim.keyTimes       = [0, 1]
        path2FillColorAnim.duration       = 0.15
        path2FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let path2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [path2FillColorAnim], fillMode:fillMode)
        layers["path2"]?.add(path2EnableAnim, forKey:"path2EnableAnim")
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
        
        let Group = layers["Group"] as! CALayer
        
        ////Group animation
        let GroupTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        GroupTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
                                             NSValue(caTransform3D: CATransform3DIdentity)]
        GroupTransformAnim.keyTimes       = [0, 1]
        GroupTransformAnim.duration       = 0.15
        GroupTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let GroupDisableAnim : CAAnimationGroup = QCMethod.group(animations: [GroupTransformAnim], fillMode:fillMode)
        Group.add(GroupDisableAnim, forKey:"GroupDisableAnim")
        
        ////Path animation
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0).cgColor,
                                            UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.15
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathDisableAnim, forKey:"pathDisableAnim")
        
        ////Path2 animation
        let path2FillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        path2FillColorAnim.values         = [UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0).cgColor,
                                             UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        path2FillColorAnim.keyTimes       = [0, 1]
        path2FillColorAnim.duration       = 0.15
        path2FillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let path2DisableAnim : CAAnimationGroup = QCMethod.group(animations: [path2FillColorAnim], fillMode:fillMode)
        layers["path2"]?.add(path2DisableAnim, forKey:"path2DisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Group"]!.animation(forKey: "GroupEnableAnim"), theLayer:layers["Group"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathEnableAnim"), theLayer:layers["path"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path2"]!.animation(forKey: "path2EnableAnim"), theLayer:layers["path2"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["Group"]!.animation(forKey: "GroupDisableAnim"), theLayer:layers["Group"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathDisableAnim"), theLayer:layers["path"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path2"]!.animation(forKey: "path2DisableAnim"), theLayer:layers["path2"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["Group"]?.removeAnimation(forKey: "GroupEnableAnim")
            layers["path"]?.removeAnimation(forKey: "pathEnableAnim")
            layers["path2"]?.removeAnimation(forKey: "path2EnableAnim")
        }
        else if identifier == "disable"{
            layers["Group"]?.removeAnimation(forKey: "GroupDisableAnim")
            layers["path"]?.removeAnimation(forKey: "pathDisableAnim")
            layers["path2"]?.removeAnimation(forKey: "path2DisableAnim")
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
        
        pathPath.move(to: CGPoint(x:minX + 0.40586 * w, y: minY + 0.05793 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23316 * w, y: minY + 0.13513 * h), controlPoint1:CGPoint(x:minX + 0.33888 * w, y: minY + 0.03058 * h), controlPoint2:CGPoint(x:minX + 0.27951 * w, y: minY + 0.00633 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.10667 * w, y: minY + 0.27618 * h), controlPoint1:CGPoint(x:minX + 0.16089 * w, y: minY + 0.13749 * h), controlPoint2:CGPoint(x:minX + 0.09684 * w, y: minY + 0.13959 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.04825 * w, y: minY + 0.45668 * h), controlPoint1:CGPoint(x:minX + 0.04161 * w, y: minY + 0.30785 * h), controlPoint2:CGPoint(x:minX + -0.01606 * w, y: minY + 0.33592 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.06801 * w, y: minY + 0.64544 * h), controlPoint1:CGPoint(x:minX + 0.00165 * w, y: minY + 0.51219 * h), controlPoint2:CGPoint(x:minX + -0.03967 * w, y: minY + 0.56138 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.16253 * w, y: minY + 0.80981 * h), controlPoint1:CGPoint(x:minX + 0.04792 * w, y: minY + 0.71518 * h), controlPoint2:CGPoint(x:minX + 0.03011 * w, y: minY + 0.77699 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.31547 * w, y: minY + 0.92137 * h), controlPoint1:CGPoint(x:minX + 0.17243 * w, y: minY + 0.88173 * h), controlPoint2:CGPoint(x:minX + 0.1812 * w, y: minY + 0.94547 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.50038 * w, y: minY + 0.96083 * h), controlPoint1:CGPoint(x:minX + 0.35364 * w, y: minY + 0.98303 * h), controlPoint2:CGPoint(x:minX + 0.38748 * w, y: minY + 1.03768 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.68529 * w, y: minY + 0.92137 * h), controlPoint1:CGPoint(x:minX + 0.56023 * w, y: minY + 1.00157 * h), controlPoint2:CGPoint(x:minX + 0.61328 * w, y: minY + 1.03768 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.83823 * w, y: minY + 0.80981 * h), controlPoint1:CGPoint(x:minX + 0.75647 * w, y: minY + 0.93415 * h), controlPoint2:CGPoint(x:minX + 0.81956 * w, y: minY + 0.94547 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.93275 * w, y: minY + 0.64544 * h), controlPoint1:CGPoint(x:minX + 0.90843 * w, y: minY + 0.79241 * h), controlPoint2:CGPoint(x:minX + 0.97065 * w, y: minY + 0.77699 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.95251 * w, y: minY + 0.45668 * h), controlPoint1:CGPoint(x:minX + 0.98983 * w, y: minY + 0.60088 * h), controlPoint2:CGPoint(x:minX + 1.04043 * w, y: minY + 0.56138 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.89409 * w, y: minY + 0.27618 * h), controlPoint1:CGPoint(x:minX + 0.9866 * w, y: minY + 0.39266 * h), controlPoint2:CGPoint(x:minX + 1.01682 * w, y: minY + 0.33592 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.7676 * w, y: minY + 0.13513 * h), controlPoint1:CGPoint(x:minX + 0.8993 * w, y: minY + 0.20377 * h), controlPoint2:CGPoint(x:minX + 0.90392 * w, y: minY + 0.13959 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5949 * w, y: minY + 0.05793 * h), controlPoint1:CGPoint(x:minX + 0.74303 * w, y: minY + 0.06685 * h), controlPoint2:CGPoint(x:minX + 0.72125 * w, y: minY + 0.00633 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.40586 * w, y: minY + 0.05793 * h), controlPoint1:CGPoint(x:minX + 0.54479 * w, y: minY + 0.00559 * h), controlPoint2:CGPoint(x:minX + 0.50038 * w, y: minY + -0.0408 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.40586 * w, y: minY + 0.05793 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.52331 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.75641 * w, y: minY + 0.52331 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.24359 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.24359 * w, y: minY + 0.52331 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.52331 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.75641 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.75641 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.52331 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.62821 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.62821 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.65385 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.65385 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.62821 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.70513 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.70513 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.62821 * w, y: minY + 0.73077 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.73077 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.70513 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.37179 * w, y: minY + 0.70513 * h))
        
        return pathPath
    }
    
    func path2Path(bounds: CGRect) -> UIBezierPath{
        let path2Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path2Path.move(to: CGPoint(x:minX + 0.42863 * w, y: minY + 0.22254 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.24749 * w, y: minY + h))
        path2Path.addLine(to: CGPoint(x:minX + 0.17138 * w, y: minY + 0.61851 * h))
        path2Path.addLine(to: CGPoint(x:minX, y: minY + 0.6459 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.15044 * w, y: minY + 0.00017 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.27905 * w, y: minY + 0.03406 * h), controlPoint1:CGPoint(x:minX + 0.17429 * w, y: minY + 0.04586 * h), controlPoint2:CGPoint(x:minX + 0.21318 * w, y: minY + 0.06335 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.42863 * w, y: minY + 0.22254 * h), controlPoint1:CGPoint(x:minX + 0.31449 * w, y: minY + 0.17593 * h), controlPoint2:CGPoint(x:minX + 0.3466 * w, y: minY + 0.30443 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.84952 * w, y: minY))
        path2Path.addLine(to: CGPoint(x:minX + w, y: minY + 0.6459 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.82862 * w, y: minY + 0.61851 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.75251 * w, y: minY + h))
        path2Path.addLine(to: CGPoint(x:minX + 0.57311 * w, y: minY + 0.22998 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.72181 * w, y: minY + 0.03406 * h), controlPoint1:CGPoint(x:minX + 0.61886 * w, y: minY + 0.27881 * h), controlPoint2:CGPoint(x:minX + 0.66508 * w, y: minY + 0.26111 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.84952 * w, y: minY), controlPoint1:CGPoint(x:minX + 0.77103 * w, y: minY + 0.05595 * h), controlPoint2:CGPoint(x:minX + 0.81679 * w, y: minY + 0.0763 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.84952 * w, y: minY))
        
        return path2Path
    }
    
    
}
