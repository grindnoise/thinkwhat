//
//  LoadingText.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class LoadingTextIndicator: UIView, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    
    
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
        
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor.white
        
        let rectangle2 = CAShapeLayer()
        self.layer.addSublayer(rectangle2)
        layers["rectangle2"] = rectangle2
        let rectangle = CAShapeLayer()
        let rectangleGradient = CAGradientLayer()
        rectangle.addSublayer(rectangleGradient)
        rectangle2.addSublayer(rectangle)
        layers["rectangle"] = rectangle
        layers["rectangleGradient"] = rectangleGradient
        
        let rectangle4 = CAShapeLayer()
        self.layer.addSublayer(rectangle4)
        layers["rectangle4"] = rectangle4
        let rectangle3 = CAShapeLayer()
        let rectangle3Gradient = CAGradientLayer()
        rectangle3.addSublayer(rectangle3Gradient)
        rectangle4.addSublayer(rectangle3)
        layers["rectangle3"] = rectangle3
        layers["rectangle3Gradient"] = rectangle3Gradient
        
        let rectangle6 = CAShapeLayer()
        self.layer.addSublayer(rectangle6)
        layers["rectangle6"] = rectangle6
        let rectangle5 = CAShapeLayer()
        let rectangle5Gradient = CAGradientLayer()
        rectangle5.addSublayer(rectangle5Gradient)
        rectangle6.addSublayer(rectangle5)
        layers["rectangle5"] = rectangle5
        layers["rectangle5Gradient"] = rectangle5Gradient
        
        let rectangle8 = CAShapeLayer()
        self.layer.addSublayer(rectangle8)
        layers["rectangle8"] = rectangle8
        let rectangle7 = CAShapeLayer()
        let rectangle7Gradient = CAGradientLayer()
        rectangle7.addSublayer(rectangle7Gradient)
        rectangle8.addSublayer(rectangle7)
        layers["rectangle7"] = rectangle7
        layers["rectangle7Gradient"] = rectangle7Gradient
        
        let rectangle10 = CAShapeLayer()
        self.layer.addSublayer(rectangle10)
        layers["rectangle10"] = rectangle10
        let rectangle9 = CAShapeLayer()
        let rectangle9Gradient = CAGradientLayer()
        rectangle9.addSublayer(rectangle9Gradient)
        rectangle10.addSublayer(rectangle9)
        layers["rectangle9"] = rectangle9
        layers["rectangle9Gradient"] = rectangle9Gradient
        
        let rectangle12 = CAShapeLayer()
        self.layer.addSublayer(rectangle12)
        layers["rectangle12"] = rectangle12
        let rectangle11 = CAShapeLayer()
        let rectangle11Gradient = CAGradientLayer()
        rectangle11.addSublayer(rectangle11Gradient)
        rectangle12.addSublayer(rectangle11)
        layers["rectangle11"] = rectangle11
        layers["rectangle11Gradient"] = rectangle11Gradient
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("rectangle2"){
            let rectangle2 = layers["rectangle2"] as! CAShapeLayer
            rectangle2.masksToBounds = true
            rectangle2.fillColor     = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            rectangle2.strokeColor   = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle2.lineWidth     = 0
        }
        if layerIds == nil || layerIds.contains("rectangle"){
            let rectangle = layers["rectangle"] as! CAShapeLayer
            rectangle.fillColor          = nil
            rectangle.strokeColor        = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle.lineWidth          = 0
            
            let rectangleGradient = layers["rectangleGradient"] as! CAGradientLayer
            let rectangleMask            = CAShapeLayer()
            rectangleMask.path           = rectangle.path
            rectangleGradient.mask       = rectangleMask
            rectangleGradient.frame      = rectangle.bounds
            let rectangleGradientColors : Array <AnyObject> = [UIColor(red:0.937, green: 0.937, blue:0.937, alpha:0).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.24).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.602).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.2).cgColor, UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0).cgColor]
            rectangleGradient.colors = rectangleGradientColors
            rectangleGradient.locations  = [0, 0.166, 0.27, 0.42, 0.5, 0.584, 0.742, 0.841, 1]
            rectangleGradient.startPoint = CGPoint(x: 0, y: 0.5)
            rectangleGradient.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        if layerIds == nil || layerIds.contains("rectangle4"){
            let rectangle4 = layers["rectangle4"] as! CAShapeLayer
            rectangle4.masksToBounds = true
            rectangle4.fillColor     = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            rectangle4.strokeColor   = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle4.lineWidth     = 0
        }
        if layerIds == nil || layerIds.contains("rectangle3"){
            let rectangle3 = layers["rectangle3"] as! CAShapeLayer
            rectangle3.fillColor          = nil
            rectangle3.strokeColor        = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle3.lineWidth          = 0
            
            let rectangle3Gradient = layers["rectangle3Gradient"] as! CAGradientLayer
            let rectangle3Mask            = CAShapeLayer()
            rectangle3Mask.path           = rectangle3.path
            rectangle3Gradient.mask       = rectangle3Mask
            rectangle3Gradient.frame      = rectangle3.bounds
            let rectangle3GradientColors : Array <AnyObject> = [UIColor(red:0.937, green: 0.937, blue:0.937, alpha:0).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.24).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.602).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.2).cgColor, UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0).cgColor]
            rectangle3Gradient.colors = rectangle3GradientColors
            rectangle3Gradient.locations  = [0, 0.166, 0.27, 0.42, 0.5, 0.584, 0.742, 0.841, 1]
            rectangle3Gradient.startPoint = CGPoint(x: 0, y: 0.5)
            rectangle3Gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        if layerIds == nil || layerIds.contains("rectangle6"){
            let rectangle6 = layers["rectangle6"] as! CAShapeLayer
            rectangle6.masksToBounds = true
            rectangle6.fillColor     = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            rectangle6.strokeColor   = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle6.lineWidth     = 0
        }
        if layerIds == nil || layerIds.contains("rectangle5"){
            let rectangle5 = layers["rectangle5"] as! CAShapeLayer
            rectangle5.fillColor          = nil
            rectangle5.strokeColor        = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle5.lineWidth          = 0
            
            let rectangle5Gradient = layers["rectangle5Gradient"] as! CAGradientLayer
            let rectangle5Mask            = CAShapeLayer()
            rectangle5Mask.path           = rectangle5.path
            rectangle5Gradient.mask       = rectangle5Mask
            rectangle5Gradient.frame      = rectangle5.bounds
            let rectangle5GradientColors : Array <AnyObject> = [UIColor(red:0.937, green: 0.937, blue:0.937, alpha:0).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.24).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.602).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.2).cgColor, UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0).cgColor]
            rectangle5Gradient.colors = rectangle5GradientColors
            rectangle5Gradient.locations  = [0, 0.166, 0.27, 0.42, 0.5, 0.584, 0.742, 0.841, 1]
            rectangle5Gradient.startPoint = CGPoint(x: 0, y: 0.5)
            rectangle5Gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        if layerIds == nil || layerIds.contains("rectangle8"){
            let rectangle8 = layers["rectangle8"] as! CAShapeLayer
            rectangle8.masksToBounds = true
            rectangle8.fillColor     = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            rectangle8.strokeColor   = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle8.lineWidth     = 0
        }
        if layerIds == nil || layerIds.contains("rectangle7"){
            let rectangle7 = layers["rectangle7"] as! CAShapeLayer
            rectangle7.fillColor          = nil
            rectangle7.strokeColor        = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle7.lineWidth          = 0
            
            let rectangle7Gradient = layers["rectangle7Gradient"] as! CAGradientLayer
            let rectangle7Mask            = CAShapeLayer()
            rectangle7Mask.path           = rectangle7.path
            rectangle7Gradient.mask       = rectangle7Mask
            rectangle7Gradient.frame      = rectangle7.bounds
            let rectangle7GradientColors : Array <AnyObject> = [UIColor(red:0.937, green: 0.937, blue:0.937, alpha:0).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.24).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.602).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.2).cgColor, UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0).cgColor]
            rectangle7Gradient.colors = rectangle7GradientColors
            rectangle7Gradient.locations  = [0, 0.166, 0.27, 0.42, 0.5, 0.584, 0.742, 0.841, 1]
            rectangle7Gradient.startPoint = CGPoint(x: 0, y: 0.5)
            rectangle7Gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        if layerIds == nil || layerIds.contains("rectangle10"){
            let rectangle10 = layers["rectangle10"] as! CAShapeLayer
            rectangle10.masksToBounds = true
            rectangle10.fillColor     = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            rectangle10.strokeColor   = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle10.lineWidth     = 0
        }
        if layerIds == nil || layerIds.contains("rectangle9"){
            let rectangle9 = layers["rectangle9"] as! CAShapeLayer
            rectangle9.fillColor          = nil
            rectangle9.strokeColor        = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle9.lineWidth          = 0
            
            let rectangle9Gradient = layers["rectangle9Gradient"] as! CAGradientLayer
            let rectangle9Mask            = CAShapeLayer()
            rectangle9Mask.path           = rectangle9.path
            rectangle9Gradient.mask       = rectangle9Mask
            rectangle9Gradient.frame      = rectangle9.bounds
            let rectangle9GradientColors : Array <AnyObject> = [UIColor(red:0.937, green: 0.937, blue:0.937, alpha:0).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.24).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.602).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.2).cgColor, UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0).cgColor]
            rectangle9Gradient.colors = rectangle9GradientColors
            rectangle9Gradient.locations  = [0, 0.166, 0.27, 0.42, 0.5, 0.584, 0.742, 0.841, 1]
            rectangle9Gradient.startPoint = CGPoint(x: 0, y: 0.5)
            rectangle9Gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        if layerIds == nil || layerIds.contains("rectangle12"){
            let rectangle12 = layers["rectangle12"] as! CAShapeLayer
            rectangle12.masksToBounds = true
            rectangle12.fillColor     = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            rectangle12.strokeColor   = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle12.lineWidth     = 0
        }
        if layerIds == nil || layerIds.contains("rectangle11"){
            let rectangle11 = layers["rectangle11"] as! CAShapeLayer
            rectangle11.fillColor          = nil
            rectangle11.strokeColor        = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            rectangle11.lineWidth          = 0
            
            let rectangle11Gradient = layers["rectangle11Gradient"] as! CAGradientLayer
            let rectangle11Mask            = CAShapeLayer()
            rectangle11Mask.path           = rectangle11.path
            rectangle11Gradient.mask       = rectangle11Mask
            rectangle11Gradient.frame      = rectangle11.bounds
            let rectangle11GradientColors : Array <AnyObject> = [UIColor(red:0.937, green: 0.937, blue:0.937, alpha:0).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.24).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.6).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.602).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.4).cgColor, UIColor(red:0.754, green: 0.754, blue:0.754, alpha:0.2).cgColor, UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0).cgColor]
            rectangle11Gradient.colors = rectangle11GradientColors
            rectangle11Gradient.locations  = [0, 0.166, 0.27, 0.42, 0.5, 0.584, 0.742, 0.841, 1]
            rectangle11Gradient.startPoint = CGPoint(x: 0, y: 0.5)
            rectangle11Gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let rectangle2 = layers["rectangle2"] as? CAShapeLayer{
            rectangle2.frame = CGRect(x: 0, y: 0.04 * rectangle2.superlayer!.bounds.height, width:  rectangle2.superlayer!.bounds.width, height: 0.11097 * rectangle2.superlayer!.bounds.height)
            rectangle2.path  = rectangle2Path(bounds: layers["rectangle2"]!.bounds).cgPath
        }
        
        if let rectangle = layers["rectangle"] as? CAShapeLayer{
            rectangle.frame = CGRect(x: -0.61974 * rectangle.superlayer!.bounds.width, y: -0.10921 * rectangle.superlayer!.bounds.height, width: 0.61974 * rectangle.superlayer!.bounds.width, height: 1.14556 * rectangle.superlayer!.bounds.height)
            rectangle.path  = rectanglePath(bounds: layers["rectangle"]!.bounds).cgPath
            let rectangleGradient = layers["rectangleGradient"] as! CAGradientLayer
            rectangleGradient.frame = rectangle.bounds
            (rectangleGradient.mask as! CAShapeLayer).path = rectangle.path
        }
        
        if let rectangle4 = layers["rectangle4"] as? CAShapeLayer{
            rectangle4.frame = CGRect(x: 0, y: 0.18903 * rectangle4.superlayer!.bounds.height, width: 0.65794 * rectangle4.superlayer!.bounds.width, height: 0.11097 * rectangle4.superlayer!.bounds.height)
            rectangle4.path  = rectangle4Path(bounds: layers["rectangle4"]!.bounds).cgPath
        }
        
        if let rectangle3 = layers["rectangle3"] as? CAShapeLayer{
            rectangle3.frame = CGRect(x: -1.06456 * rectangle3.superlayer!.bounds.width, y: -0.10921 * rectangle3.superlayer!.bounds.height, width: 0.98473 * rectangle3.superlayer!.bounds.width, height: 1.14556 * rectangle3.superlayer!.bounds.height)
            rectangle3.path  = rectangle3Path(bounds: layers["rectangle3"]!.bounds).cgPath
            let rectangle3Gradient = layers["rectangle3Gradient"] as! CAGradientLayer
            rectangle3Gradient.frame = rectangle3.bounds
            (rectangle3Gradient.mask as! CAShapeLayer).path = rectangle3.path
        }
        
        if let rectangle6 = layers["rectangle6"] as? CAShapeLayer{
            rectangle6.frame = CGRect(x: 0, y: 0.33903 * rectangle6.superlayer!.bounds.height, width: 0.60003 * rectangle6.superlayer!.bounds.width, height: 0.11097 * rectangle6.superlayer!.bounds.height)
            rectangle6.path  = rectangle6Path(bounds: layers["rectangle6"]!.bounds).cgPath
        }
        
        if let rectangle5 = layers["rectangle5"] as? CAShapeLayer{
            rectangle5.frame = CGRect(x: -1.17637 * rectangle5.superlayer!.bounds.width, y: -0.10921 * rectangle5.superlayer!.bounds.height, width: 1.08816 * rectangle5.superlayer!.bounds.width, height: 1.14556 * rectangle5.superlayer!.bounds.height)
            rectangle5.path  = rectangle5Path(bounds: layers["rectangle5"]!.bounds).cgPath
            let rectangle5Gradient = layers["rectangle5Gradient"] as! CAGradientLayer
            rectangle5Gradient.frame = rectangle5.bounds
            (rectangle5Gradient.mask as! CAShapeLayer).path = rectangle5.path
        }
        
        if let rectangle8 = layers["rectangle8"] as? CAShapeLayer{
            rectangle8.frame = CGRect(x: 0, y: 0.49452 * rectangle8.superlayer!.bounds.height, width: 0.83821 * rectangle8.superlayer!.bounds.width, height: 0.11097 * rectangle8.superlayer!.bounds.height)
            rectangle8.path  = rectangle8Path(bounds: layers["rectangle8"]!.bounds).cgPath
        }
        
        if let rectangle7 = layers["rectangle7"] as? CAShapeLayer{
            rectangle7.frame = CGRect(x: -0.70542 * rectangle7.superlayer!.bounds.width, y: -0.10921 * rectangle7.superlayer!.bounds.height, width: 0.65252 * rectangle7.superlayer!.bounds.width, height: 1.14556 * rectangle7.superlayer!.bounds.height)
            rectangle7.path  = rectangle7Path(bounds: layers["rectangle7"]!.bounds).cgPath
            let rectangle7Gradient = layers["rectangle7Gradient"] as! CAGradientLayer
            rectangle7Gradient.frame = rectangle7.bounds
            (rectangle7Gradient.mask as! CAShapeLayer).path = rectangle7.path
        }
        
        if let rectangle10 = layers["rectangle10"] as? CAShapeLayer{
            rectangle10.frame = CGRect(x: 0, y: 0.64903 * rectangle10.superlayer!.bounds.height, width: 0.72916 * rectangle10.superlayer!.bounds.width, height: 0.11097 * rectangle10.superlayer!.bounds.height)
            rectangle10.path  = rectangle10Path(bounds: layers["rectangle10"]!.bounds).cgPath
        }
        
        if let rectangle9 = layers["rectangle9"] as? CAShapeLayer{
            rectangle9.frame = CGRect(x: -0.81846 * rectangle9.superlayer!.bounds.width, y: -0.10921 * rectangle9.superlayer!.bounds.height, width: 0.75709 * rectangle9.superlayer!.bounds.width, height: 1.14556 * rectangle9.superlayer!.bounds.height)
            rectangle9.path  = rectangle9Path(bounds: layers["rectangle9"]!.bounds).cgPath
            let rectangle9Gradient = layers["rectangle9Gradient"] as! CAGradientLayer
            rectangle9Gradient.frame = rectangle9.bounds
            (rectangle9Gradient.mask as! CAShapeLayer).path = rectangle9.path
        }
        
        if let rectangle12 = layers["rectangle12"] as? CAShapeLayer{
            rectangle12.frame = CGRect(x: 0, y: 0.80903 * rectangle12.superlayer!.bounds.height, width: 0.96814 * rectangle12.superlayer!.bounds.width, height: 0.11097 * rectangle12.superlayer!.bounds.height)
            rectangle12.path  = rectangle12Path(bounds: layers["rectangle12"]!.bounds).cgPath
        }
        
        if let rectangle11 = layers["rectangle11"] as? CAShapeLayer{
            rectangle11.frame = CGRect(x: -0.70542 * rectangle11.superlayer!.bounds.width, y: -0.10921 * rectangle11.superlayer!.bounds.height, width: 0.65252 * rectangle11.superlayer!.bounds.width, height: 1.14556 * rectangle11.superlayer!.bounds.height)
            rectangle11.path  = rectangle11Path(bounds: layers["rectangle11"]!.bounds).cgPath
            let rectangle11Gradient = layers["rectangle11Gradient"] as! CAGradientLayer
            rectangle11Gradient.frame = rectangle11.bounds
            (rectangle11Gradient.mask as! CAShapeLayer).path = rectangle11.path
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(){
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////An infinity animation
        
        let rectangle = layers["rectangle"] as! CAShapeLayer
        
        ////Rectangle animation
        let rectanglePositionAnim         = CAKeyframeAnimation(keyPath:"position")
        rectanglePositionAnim.values      = [NSValue(cgPoint: CGPoint(x: -0.3 * rectangle.superlayer!.bounds.width, y: 0.45059 * rectangle.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 1.3 * rectangle.superlayer!.bounds.width, y: 0.45059 * rectangle.superlayer!.bounds.height))]
        rectanglePositionAnim.keyTimes    = [0, 1]
        rectanglePositionAnim.duration    = 0.981
        rectanglePositionAnim.repeatCount = Float.infinity
        
        let rectangleEnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectanglePositionAnim], fillMode:fillMode)
        rectangle.add(rectangleEnableAnim, forKey:"rectangleEnableAnim")
        
        let rectangle3 = layers["rectangle3"] as! CAShapeLayer
        
        ////Rectangle3 animation
        let rectangle3PositionAnim         = CAKeyframeAnimation(keyPath:"position")
        rectangle3PositionAnim.values      = [NSValue(cgPoint: CGPoint(x: -0.52989 * rectangle3.superlayer!.bounds.width, y: 0.4593 * rectangle3.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 1.97587 * rectangle3.superlayer!.bounds.width, y: 0.4593 * rectangle3.superlayer!.bounds.height))]
        rectangle3PositionAnim.keyTimes    = [0, 1]
        rectangle3PositionAnim.duration    = 0.981
        rectangle3PositionAnim.repeatCount = Float.infinity
        
        let rectangle3EnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle3PositionAnim], fillMode:fillMode)
        rectangle3.add(rectangle3EnableAnim, forKey:"rectangle3EnableAnim")
        
        let rectangle5 = layers["rectangle5"] as! CAShapeLayer
        
        ////Rectangle5 animation
        let rectangle5PositionAnim         = CAKeyframeAnimation(keyPath:"position")
        rectangle5PositionAnim.values      = [NSValue(cgPoint: CGPoint(x: -0.49998 * rectangle5.superlayer!.bounds.width, y: 0.4593 * rectangle5.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 2.16656 * rectangle5.superlayer!.bounds.width, y: 0.4593 * rectangle5.superlayer!.bounds.height))]
        rectangle5PositionAnim.keyTimes    = [0, 1]
        rectangle5PositionAnim.duration    = 0.981
        rectangle5PositionAnim.repeatCount = Float.infinity
        
        let rectangle5EnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle5PositionAnim], fillMode:fillMode)
        rectangle5.add(rectangle5EnableAnim, forKey:"rectangle5EnableAnim")
        
        let rectangle7 = layers["rectangle7"] as! CAShapeLayer
        
        ////Rectangle7 animation
        let rectangle7PositionAnim         = CAKeyframeAnimation(keyPath:"position")
        rectangle7PositionAnim.values      = [NSValue(cgPoint: CGPoint(x: -0.3579 * rectangle7.superlayer!.bounds.width, y: 0.5 * rectangle7.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 1.55092 * rectangle7.superlayer!.bounds.width, y: 0.5 * rectangle7.superlayer!.bounds.height))]
        rectangle7PositionAnim.keyTimes    = [0, 1]
        rectangle7PositionAnim.duration    = 0.981
        rectangle7PositionAnim.repeatCount = Float.infinity
        
        let rectangle7EnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle7PositionAnim], fillMode:fillMode)
        rectangle7.add(rectangle7EnableAnim, forKey:"rectangle7EnableAnim")
        
        let rectangle9 = layers["rectangle9"] as! CAShapeLayer
        
        ////Rectangle9 animation
        let rectangle9PositionAnim         = CAKeyframeAnimation(keyPath:"position")
        rectangle9PositionAnim.values      = [NSValue(cgPoint: CGPoint(x: -0.41143 * rectangle9.superlayer!.bounds.width, y: 0.4593 * rectangle9.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 1.78287 * rectangle9.superlayer!.bounds.width, y: 0.4593 * rectangle9.superlayer!.bounds.height))]
        rectangle9PositionAnim.keyTimes    = [0, 1]
        rectangle9PositionAnim.duration    = 0.981
        rectangle9PositionAnim.repeatCount = Float.infinity
        
        let rectangle9EnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle9PositionAnim], fillMode:fillMode)
        rectangle9.add(rectangle9EnableAnim, forKey:"rectangle9EnableAnim")
        
        let rectangle11 = layers["rectangle11"] as! CAShapeLayer
        
        ////Rectangle11 animation
        let rectangle11PositionAnim         = CAKeyframeAnimation(keyPath:"position")
        rectangle11PositionAnim.values      = [NSValue(cgPoint: CGPoint(x: -0.30987 * rectangle11.superlayer!.bounds.width, y: 0.4593 * rectangle11.superlayer!.bounds.height)), NSValue(cgPoint: CGPoint(x: 1.34277 * rectangle11.superlayer!.bounds.width, y: 0.4593 * rectangle11.superlayer!.bounds.height))]
        rectangle11PositionAnim.keyTimes    = [0, 1]
        rectangle11PositionAnim.duration    = 0.981
        rectangle11PositionAnim.repeatCount = Float.infinity
        
        let rectangle11EnableAnim : CAAnimationGroup = QCMethod.group(animations: [rectangle11PositionAnim], fillMode:fillMode)
        rectangle11.add(rectangle11EnableAnim, forKey:"rectangle11EnableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle"]!.animation(forKey: "rectangleEnableAnim"), theLayer:layers["rectangle"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle3"]!.animation(forKey: "rectangle3EnableAnim"), theLayer:layers["rectangle3"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle5"]!.animation(forKey: "rectangle5EnableAnim"), theLayer:layers["rectangle5"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle7"]!.animation(forKey: "rectangle7EnableAnim"), theLayer:layers["rectangle7"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle9"]!.animation(forKey: "rectangle9EnableAnim"), theLayer:layers["rectangle9"]!)
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["rectangle11"]!.animation(forKey: "rectangle11EnableAnim"), theLayer:layers["rectangle11"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["rectangle"]?.removeAnimation(forKey: "rectangleEnableAnim")
            layers["rectangle3"]?.removeAnimation(forKey: "rectangle3EnableAnim")
            layers["rectangle5"]?.removeAnimation(forKey: "rectangle5EnableAnim")
            layers["rectangle7"]?.removeAnimation(forKey: "rectangle7EnableAnim")
            layers["rectangle9"]?.removeAnimation(forKey: "rectangle9EnableAnim")
            layers["rectangle11"]?.removeAnimation(forKey: "rectangle11EnableAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func rectangle2Path(bounds: CGRect) -> UIBezierPath{
        let rectangle2Path = UIBezierPath(rect:bounds)
        return rectangle2Path
    }
    
    func rectanglePath(bounds: CGRect) -> UIBezierPath{
        let rectanglePath = UIBezierPath(rect:bounds)
        return rectanglePath
    }
    
    func rectangle4Path(bounds: CGRect) -> UIBezierPath{
        let rectangle4Path = UIBezierPath(rect:bounds)
        return rectangle4Path
    }
    
    func rectangle3Path(bounds: CGRect) -> UIBezierPath{
        let rectangle3Path = UIBezierPath(rect:bounds)
        return rectangle3Path
    }
    
    func rectangle6Path(bounds: CGRect) -> UIBezierPath{
        let rectangle6Path = UIBezierPath(rect:bounds)
        return rectangle6Path
    }
    
    func rectangle5Path(bounds: CGRect) -> UIBezierPath{
        let rectangle5Path = UIBezierPath(rect:bounds)
        return rectangle5Path
    }
    
    func rectangle8Path(bounds: CGRect) -> UIBezierPath{
        let rectangle8Path = UIBezierPath(rect:bounds)
        return rectangle8Path
    }
    
    func rectangle7Path(bounds: CGRect) -> UIBezierPath{
        let rectangle7Path = UIBezierPath(rect:bounds)
        return rectangle7Path
    }
    
    func rectangle10Path(bounds: CGRect) -> UIBezierPath{
        let rectangle10Path = UIBezierPath(rect:bounds)
        return rectangle10Path
    }
    
    func rectangle9Path(bounds: CGRect) -> UIBezierPath{
        let rectangle9Path = UIBezierPath(rect:bounds)
        return rectangle9Path
    }
    
    func rectangle12Path(bounds: CGRect) -> UIBezierPath{
        let rectangle12Path = UIBezierPath(rect:bounds)
        return rectangle12Path
    }
    
    func rectangle11Path(bounds: CGRect) -> UIBezierPath{
        let rectangle11Path = UIBezierPath(rect:bounds)
        return rectangle11Path
    }
    
    
}
