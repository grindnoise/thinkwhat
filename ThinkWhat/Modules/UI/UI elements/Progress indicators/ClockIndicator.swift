//
//  ClockIndicator.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ClockIndicator: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    
    var main : UIColor!
    
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
        self.main = Constants.UI.Colors.main//UIColor.darkGray
    }
    
    func setupLayers(){
        self.backgroundColor = .clear
        
        let path = CAShapeLayer()
        self.layer.addSublayer(path)
        layers["path"] = path
        
        let roundedRect = CAShapeLayer()
        self.layer.addSublayer(roundedRect)
        layers["roundedRect"] = roundedRect
        
        let roundedRect2 = CAShapeLayer()
        self.layer.addSublayer(roundedRect2)
        layers["roundedRect2"] = roundedRect2
        
        let oval3 = CAShapeLayer()
        self.layer.addSublayer(oval3)
        layers["oval3"] = oval3
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("path"){
            let path = layers["path"] as! CAShapeLayer
            path.fillRule    = .evenOdd
            path.fillColor   = self.main.cgColor
            path.strokeColor = UIColor.black.cgColor
            path.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("roundedRect"){
            let roundedRect = layers["roundedRect"] as! CAShapeLayer
            roundedRect.anchorPoint = CGPoint(x: 0.5, y: 1)
            roundedRect.frame       = CGRect(x: 0.474 * roundedRect.superlayer!.bounds.width, y: 0.13671 * roundedRect.superlayer!.bounds.height, width: 0.052 * roundedRect.superlayer!.bounds.width, height: 0.36329 * roundedRect.superlayer!.bounds.height)
            roundedRect.setValue(-360 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            roundedRect.fillColor   = self.main.cgColor
            roundedRect.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            roundedRect.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("roundedRect2"){
            let roundedRect2 = layers["roundedRect2"] as! CAShapeLayer
            roundedRect2.anchorPoint = CGPoint(x: 0.5, y: 1)
            roundedRect2.frame       = CGRect(x: 0.474 * roundedRect2.superlayer!.bounds.width, y: 0.20185 * roundedRect2.superlayer!.bounds.height, width: 0.052 * roundedRect2.superlayer!.bounds.width, height: 0.29815 * roundedRect2.superlayer!.bounds.height)
            roundedRect2.setValue(-360 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            roundedRect2.fillColor   = self.main.cgColor
            roundedRect2.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            roundedRect2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("oval3"){
            let oval3 = layers["oval3"] as! CAShapeLayer
            oval3.fillColor   = self.main.cgColor
            oval3.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            oval3.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.0005 * path.superlayer!.bounds.width, y: -0.0005 * path.superlayer!.bounds.height, width: 1 * path.superlayer!.bounds.width, height: 1 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        if let roundedRect = layers["roundedRect"] as? CAShapeLayer{
            roundedRect.transform = CATransform3DIdentity
            roundedRect.frame     = CGRect(x: 0.474 * roundedRect.superlayer!.bounds.width, y: 0.13671 * roundedRect.superlayer!.bounds.height, width: 0.052 * roundedRect.superlayer!.bounds.width, height: 0.36329 * roundedRect.superlayer!.bounds.height)
            roundedRect.setValue(-360 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            roundedRect.path      = roundedRectPath(bounds: layers["roundedRect"]!.bounds).cgPath
        }
        
        if let roundedRect2 = layers["roundedRect2"] as? CAShapeLayer{
            roundedRect2.transform = CATransform3DIdentity
            roundedRect2.frame     = CGRect(x: 0.474 * roundedRect2.superlayer!.bounds.width, y: 0.20185 * roundedRect2.superlayer!.bounds.height, width: 0.052 * roundedRect2.superlayer!.bounds.width, height: 0.29815 * roundedRect2.superlayer!.bounds.height)
            roundedRect2.setValue(-360 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            roundedRect2.path      = roundedRect2Path(bounds: layers["roundedRect2"]!.bounds).cgPath
        }
        
        if let oval3 = layers["oval3"] as? CAShapeLayer{
            oval3.frame = CGRect(x: 0.45 * oval3.superlayer!.bounds.width, y: 0.45 * oval3.superlayer!.bounds.height, width: 0.1 * oval3.superlayer!.bounds.width, height: 0.1 * oval3.superlayer!.bounds.height)
            oval3.path  = oval3Path(bounds: layers["oval3"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(){
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////An infinity animation
        
        let roundedRect2 = layers["roundedRect2"] as! CAShapeLayer
        
        ////RoundedRect2 animation
        let roundedRect2TransformAnim         = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        roundedRect2TransformAnim.values      = [0,
                                                 360 * CGFloat.pi/180]
        roundedRect2TransformAnim.keyTimes    = [0, 1]
        roundedRect2TransformAnim.duration    = 10
        roundedRect2TransformAnim.repeatCount = Float.infinity
        
        let roundedRect2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [roundedRect2TransformAnim], fillMode:fillMode)
        roundedRect2.add(roundedRect2EnableAnim, forKey:"roundedRect2EnableAnim")
        
        let roundedRect = layers["roundedRect"] as! CAShapeLayer
        
        ////RoundedRect animation
        let roundedRectTransformAnim         = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        roundedRectTransformAnim.values      = [0,
                                                360 * CGFloat.pi/180]
        roundedRectTransformAnim.keyTimes    = [0, 1]
        roundedRectTransformAnim.duration    = 1
        roundedRectTransformAnim.repeatCount = Float.infinity
        
        let roundedRectEnableAnim : CAAnimationGroup = QCMethod.group(animations: [roundedRectTransformAnim], fillMode:fillMode)
        roundedRect.add(roundedRectEnableAnim, forKey:"roundedRectEnableAnim")
    }
    
    //MARK: - Animation Cleanup
    
    func updateLayerValues(forAnimationId identifier: String){
        if identifier == "enable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["roundedRect2"]!.animation(forKey: "roundedRect2EnableAnim"), theLayer:layers["roundedRect2"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["roundedRect"]!.animation(forKey: "roundedRectEnableAnim"), theLayer:layers["roundedRect"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["roundedRect2"]?.removeAnimation(forKey: "roundedRect2EnableAnim")
            layers["roundedRect"]?.removeAnimation(forKey: "roundedRectEnableAnim")
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
        
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.4995 * w, y: minY + 0.05502 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.05402 * w, y: minY + 0.5005 * h), controlPoint1:CGPoint(x:minX + 0.25347 * w, y: minY + 0.05502 * h), controlPoint2:CGPoint(x:minX + 0.05402 * w, y: minY + 0.25447 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.4995 * w, y: minY + 0.94598 * h), controlPoint1:CGPoint(x:minX + 0.05402 * w, y: minY + 0.74653 * h), controlPoint2:CGPoint(x:minX + 0.25347 * w, y: minY + 0.94598 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.94498 * w, y: minY + 0.5005 * h), controlPoint1:CGPoint(x:minX + 0.74553 * w, y: minY + 0.94598 * h), controlPoint2:CGPoint(x:minX + 0.94498 * w, y: minY + 0.74653 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.4995 * w, y: minY + 0.05502 * h), controlPoint1:CGPoint(x:minX + 0.94498 * w, y: minY + 0.25447 * h), controlPoint2:CGPoint(x:minX + 0.74553 * w, y: minY + 0.05502 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.4995 * w, y: minY + 0.05502 * h))
        
        return pathPath
    }
    
    func roundedRectPath(bounds: CGRect) -> UIBezierPath{
        let roundedRectPath = UIBezierPath(roundedRect:bounds, cornerRadius:26)
        return roundedRectPath
    }
    
    func roundedRect2Path(bounds: CGRect) -> UIBezierPath{
        let roundedRect2Path = UIBezierPath(roundedRect:bounds, cornerRadius:26)
        return roundedRect2Path
    }
    
    func oval3Path(bounds: CGRect) -> UIBezierPath{
        let oval3Path = UIBezierPath(ovalIn:bounds)
        return oval3Path
    }
}
