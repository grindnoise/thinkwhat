//
//  ReadySign.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class ReadySign: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
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
      self.main = Colors.main//UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
        let rectangle = CAShapeLayer()
        self.layer.addSublayer(rectangle)
        layers["rectangle"] = rectangle
        
        let rectangle2 = CAShapeLayer()
        self.layer.addSublayer(rectangle2)
        layers["rectangle2"] = rectangle2
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("rectangle"){
            let rectangle = layers["rectangle"] as! CAShapeLayer
            rectangle.anchorPoint = CGPoint(x: 0.5, y: 0)
            rectangle.frame       = CGRect(x: 0.0541 * rectangle.superlayer!.bounds.width, y: 0.45702 * rectangle.superlayer!.bounds.height, width: 0.17959 * rectangle.superlayer!.bounds.width, height: 0.01 * rectangle.superlayer!.bounds.height)
            rectangle.setValue(-44.64 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle.opacity     = 0
            rectangle.fillColor   = self.main.cgColor
            rectangle.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("rectangle2"){
            let rectangle2 = layers["rectangle2"] as! CAShapeLayer
            rectangle2.anchorPoint = CGPoint(x: 0.5, y: 0)
            rectangle2.frame       = CGRect(x: 0.25858 * rectangle2.superlayer!.bounds.width, y: 0.77369 * rectangle2.superlayer!.bounds.height, width: 0.16959 * rectangle2.superlayer!.bounds.width, height: 0.01 * rectangle2.superlayer!.bounds.height)
            rectangle2.setValue(-135.09 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle2.opacity     = 0
            rectangle2.fillColor   = self.main.cgColor
            rectangle2.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle2.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let rectangle = layers["rectangle"] as? CAShapeLayer{
            rectangle.transform = CATransform3DIdentity
            rectangle.frame     = CGRect(x: 0.0541 * rectangle.superlayer!.bounds.width, y: 0.45702 * rectangle.superlayer!.bounds.height, width: 0.17959 * rectangle.superlayer!.bounds.width, height: 0.01 * rectangle.superlayer!.bounds.height)
            rectangle.setValue(-44.64 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle.path      = rectanglePath(bounds: layers["rectangle"]!.bounds).cgPath
        }
        
        if let rectangle2 = layers["rectangle2"] as? CAShapeLayer{
            rectangle2.transform = CATransform3DIdentity
            rectangle2.frame     = CGRect(x: 0.25858 * rectangle2.superlayer!.bounds.width, y: 0.77369 * rectangle2.superlayer!.bounds.height, width: 0.16959 * rectangle2.superlayer!.bounds.width, height: 0.01 * rectangle2.superlayer!.bounds.height)
            rectangle2.setValue(-135.09 * CGFloat.pi/180, forKeyPath:"transform.rotation")
            rectangle2.path      = rectangle2Path(bounds: layers["rectangle2"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addUntitled1Animation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.605
            completionAnim.delegate = self
            completionAnim.setValue("Untitled1", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"Untitled1")
            if let anim = layer.animation(forKey: "Untitled1"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        let rectangle = layers["rectangle"] as! CAShapeLayer
        
        ////Rectangle animation
        let rectangleTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        rectangleTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeRotation(44.64 * CGFloat.pi/180, 0, 0, -1)),
                                                 NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 45, 10), CATransform3DMakeRotation(-44.64 * CGFloat.pi/180, -0, 0, 1)))]
        rectangleTransformAnim.keyTimes       = [0, 1]
        rectangleTransformAnim.duration       = 0.3
        rectangleTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let rectangleOpacityAnim      = CAKeyframeAnimation(keyPath:"opacity")
        rectangleOpacityAnim.values   = [0, 1]
        rectangleOpacityAnim.keyTimes = [0, 1]
        rectangleOpacityAnim.duration = 0.1
        
        let rectangleUntitled1Anim : CAAnimationGroup = QCMethod.group(animations: [rectangleTransformAnim, rectangleOpacityAnim], fillMode:fillMode)
        rectangle.add(rectangleUntitled1Anim, forKey:"rectangleUntitled1Anim")
        
        let rectangle2 = layers["rectangle2"] as! CAShapeLayer
        
        ////Rectangle2 animation
        let rectangle2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        rectangle2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeRotation(135.09 * CGFloat.pi/180, 0, 0, -1)),
                                                  NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1, 75, 1), CATransform3DMakeRotation(-135.09 * CGFloat.pi/180, -0, 0, 1)))]
        rectangle2TransformAnim.keyTimes       = [0, 1]
        rectangle2TransformAnim.duration       = 0.3
        rectangle2TransformAnim.beginTime      = 0.305
        rectangle2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let rectangle2OpacityAnim       = CAKeyframeAnimation(keyPath:"opacity")
        rectangle2OpacityAnim.values    = [0, 1]
        rectangle2OpacityAnim.keyTimes  = [0, 1]
        rectangle2OpacityAnim.duration  = 0.1
        rectangle2OpacityAnim.beginTime = 0.305
        
        let rectangle2Untitled1Anim : CAAnimationGroup = QCMethod.group(animations: [rectangle2TransformAnim, rectangle2OpacityAnim], fillMode:fillMode)
        rectangle2.add(rectangle2Untitled1Anim, forKey:"rectangle2Untitled1Anim")
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
        if identifier == "Untitled1"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle"]!.animation(forKey: "rectangleUntitled1Anim"), theLayer:layers["rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle2"]!.animation(forKey: "rectangle2Untitled1Anim"), theLayer:layers["rectangle2"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "Untitled1"{
            layers["rectangle"]?.removeAnimation(forKey: "rectangleUntitled1Anim")
            layers["rectangle2"]?.removeAnimation(forKey: "rectangle2Untitled1Anim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func rectanglePath(bounds: CGRect) -> UIBezierPath{
        let rectanglePath = UIBezierPath(rect:bounds)
        return rectanglePath
    }
    
    func rectangle2Path(bounds: CGRect) -> UIBezierPath{
        let rectangle2Path = UIBezierPath(rect:bounds)
        return rectangle2Path
    }
    
    
}
