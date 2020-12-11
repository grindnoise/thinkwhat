//
//  PieIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class PieIcon: Icon, CAAnimationDelegate {
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
        self.active = K_COLOR_RED//UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
    }
    
    func setupLayers(){
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
            path.frame = CGRect(x: 0.15309 * path.superlayer!.bounds.width, y: 0.11074 * path.superlayer!.bounds.height, width: 0.69383 * path.superlayer!.bounds.width, height: 0.77853 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(){
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
    
    func addDisableAnimation(){
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
        pathFillColorAnim.values         = [UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0).cgColor,
                                            UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.15
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathFillColorAnim], fillMode:fillMode)
        path.add(pathDisableAnim, forKey:"pathDisableAnim")
    }
    
    //MARK: - Animation Cleanup
    
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
        
        pathPath.move(to: CGPoint(x:minX + 0.56041 * w, y: minY + 0.21838 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.56155 * w, y: minY + 0.43677 * h), controlPoint1:CGPoint(x:minX + 0.56041 * w, y: minY + 0.36339 * h), controlPoint2:CGPoint(x:minX + 0.56075 * w, y: minY + 0.43677 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.78129 * w, y: minY + 0.33931 * h), controlPoint1:CGPoint(x:minX + 0.56224 * w, y: minY + 0.43677 * h), controlPoint2:CGPoint(x:minX + 0.66106 * w, y: minY + 0.39289 * h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + 0.24196 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.99324 * w, y: minY + 0.23073 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61938 * w, y: minY + 0.00316 * h), controlPoint1:CGPoint(x:minX + 0.91767 * w, y: minY + 0.10531 * h), controlPoint2:CGPoint(x:minX + 0.77774 * w, y: minY + 0.0201 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.56877 * w, y: minY), controlPoint1:CGPoint(x:minX + 0.60575 * w, y: minY + 0.00163 * h), controlPoint2:CGPoint(x:minX + 0.57907 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.56041 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.56041 * w, y: minY + 0.21838 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.44304 * w, y: minY + 0.12705 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.24723 * w, y: minY + 0.18246 * h), controlPoint1:CGPoint(x:minX + 0.37296 * w, y: minY + 0.13338 * h), controlPoint2:CGPoint(x:minX + 0.30804 * w, y: minY + 0.15175 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.19113 * w, y: minY + 0.21583 * h), controlPoint1:CGPoint(x:minX + 0.23315 * w, y: minY + 0.18961 * h), controlPoint2:CGPoint(x:minX + 0.20384 * w, y: minY + 0.20695 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00196 * w, y: minY + 0.51841 * h), controlPoint1:CGPoint(x:minX + 0.08303 * w, y: minY + 0.29084 * h), controlPoint2:CGPoint(x:minX + 0.01696 * w, y: minY + 0.39656 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00208 * w, y: minY + 0.60688 * h), controlPoint1:CGPoint(x:minX + -0.00067 * w, y: minY + 0.53994 * h), controlPoint2:CGPoint(x:minX + -0.00067 * w, y: minY + 0.58545 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.07799 * w, y: minY + 0.79986 * h), controlPoint1:CGPoint(x:minX + 0.01078 * w, y: minY + 0.6777 * h), controlPoint2:CGPoint(x:minX + 0.03597 * w, y: minY + 0.74179 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23693 * w, y: minY + 0.93711 * h), controlPoint1:CGPoint(x:minX + 0.11727 * w, y: minY + 0.85404 * h), controlPoint2:CGPoint(x:minX + 0.17487 * w, y: minY + 0.90374 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.58217 * w, y: minY + 0.99232 * h), controlPoint1:CGPoint(x:minX + 0.34079 * w, y: minY + 0.99273 * h), controlPoint2:CGPoint(x:minX + 0.46319 * w, y: minY + 1.01242 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.95603 * w, y: minY + 0.70158 * h), controlPoint1:CGPoint(x:minX + 0.75587 * w, y: minY + 0.96313 * h), controlPoint2:CGPoint(x:minX + 0.90004 * w, y: minY + 0.85108 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.98099 * w, y: minY + 0.56229 * h), controlPoint1:CGPoint(x:minX + 0.97355 * w, y: minY + 0.65505 * h), controlPoint2:CGPoint(x:minX + 0.98111 * w, y: minY + 0.6129 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.95626 * w, y: minY + 0.42401 * h), controlPoint1:CGPoint(x:minX + 0.98099 * w, y: minY + 0.51228 * h), controlPoint2:CGPoint(x:minX + 0.97332 * w, y: minY + 0.46922 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.92935 * w, y: minY + 0.36737 * h), controlPoint1:CGPoint(x:minX + 0.94721 * w, y: minY + 0.40013 * h), controlPoint2:CGPoint(x:minX + 0.93164 * w, y: minY + 0.36737 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.71018 * w, y: minY + 0.46483 * h), controlPoint1:CGPoint(x:minX + 0.92878 * w, y: minY + 0.36737 * h), controlPoint2:CGPoint(x:minX + 0.83019 * w, y: minY + 0.41126 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49125 * w, y: minY + 0.56229 * h), controlPoint1:CGPoint(x:minX + 0.59007 * w, y: minY + 0.51841 * h), controlPoint2:CGPoint(x:minX + 0.49159 * w, y: minY + 0.56229 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49056 * w, y: minY + 0.3439 * h), controlPoint1:CGPoint(x:minX + 0.4909 * w, y: minY + 0.56229 * h), controlPoint2:CGPoint(x:minX + 0.49056 * w, y: minY + 0.46401 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.49056 * w, y: minY + 0.12552 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.4743 * w, y: minY + 0.12562 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.44304 * w, y: minY + 0.12705 * h), controlPoint1:CGPoint(x:minX + 0.46525 * w, y: minY + 0.12572 * h), controlPoint2:CGPoint(x:minX + 0.45128 * w, y: minY + 0.12634 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.44304 * w, y: minY + 0.12705 * h))
        
        return pathPath
    }
    
    
}

