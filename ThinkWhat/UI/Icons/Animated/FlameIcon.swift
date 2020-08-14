//
//  FlameIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.11.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class FlameIcon: Icon, CAAnimationDelegate {
    
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
    var inactive : UIColor!
    
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
        self.active = K_COLOR_RED//UIColor(red:1.00, green: 0.15, blue:0.00, alpha:1.0)
        self.inactive = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
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
            path.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
            path.strokeColor = UIColor.black.cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0.14981 * path.superlayer!.bounds.width, y: 0.0836 * path.superlayer!.bounds.height, width: 0.70038 * path.superlayer!.bounds.width, height: 0.8328 * path.superlayer!.bounds.height)
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
        pathFillColorAnim.values         = [self.inactive.cgColor,
                                            UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1).cgColor]
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
        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1)),
                                            NSValue(caTransform3D: CATransform3DIdentity)]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 0.2
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
        
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1).cgColor,
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
        
        pathPath.move(to: CGPoint(x:minX + 0.50364 * w, y: minY + 0.00314 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.39821 * w, y: minY + 0.05453 * h), controlPoint1:CGPoint(x:minX + 0.46568 * w, y: minY + 0.01497 * h), controlPoint2:CGPoint(x:minX + 0.42863 * w, y: minY + 0.03299 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.31708 * w, y: minY + 0.14741 * h), controlPoint1:CGPoint(x:minX + 0.35959 * w, y: minY + 0.08179 * h), controlPoint2:CGPoint(x:minX + 0.3345 * w, y: minY + 0.11063 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.30213 * w, y: minY + 0.189 * h), controlPoint1:CGPoint(x:minX + 0.30876 * w, y: minY + 0.16516 * h), controlPoint2:CGPoint(x:minX + 0.30707 * w, y: minY + 0.16978 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.29563 * w, y: minY + 0.24658 * h), controlPoint1:CGPoint(x:minX + 0.29849 * w, y: minY + 0.20305 * h), controlPoint2:CGPoint(x:minX + 0.2968 * w, y: minY + 0.21811 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.28653 * w, y: minY + 0.32625 * h), controlPoint1:CGPoint(x:minX + 0.29433 * w, y: minY + 0.27902 * h), controlPoint2:CGPoint(x:minX + 0.2916 * w, y: minY + 0.3025 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.26963 * w, y: minY + 0.37431 * h), controlPoint1:CGPoint(x:minX + 0.28484 * w, y: minY + 0.3342 * h), controlPoint2:CGPoint(x:minX + 0.27379 * w, y: minY + 0.36543 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23076 * w, y: minY + 0.43253 * h), controlPoint1:CGPoint(x:minX + 0.25975 * w, y: minY + 0.39529 * h), controlPoint2:CGPoint(x:minX + 0.24168 * w, y: minY + 0.42237 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.22374 * w, y: minY + 0.43946 * h), controlPoint1:CGPoint(x:minX + 0.22881 * w, y: minY + 0.43429 * h), controlPoint2:CGPoint(x:minX + 0.22569 * w, y: minY + 0.43743 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.21061 * w, y: minY + 0.45055 * h), controlPoint1:CGPoint(x:minX + 0.22192 * w, y: minY + 0.4415 * h), controlPoint2:CGPoint(x:minX + 0.21594 * w, y: minY + 0.44649 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.20099 * w, y: minY + 0.45795 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.20086 * w, y: minY + 0.44224 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.17538 * w, y: minY + 0.36534 * h), controlPoint1:CGPoint(x:minX + 0.20086 * w, y: minY + 0.41433 * h), controlPoint2:CGPoint(x:minX + 0.19345 * w, y: minY + 0.39205 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.12038 * w, y: minY + 0.31146 * h), controlPoint1:CGPoint(x:minX + 0.16264 * w, y: minY + 0.3464 * h), controlPoint2:CGPoint(x:minX + 0.14288 * w, y: minY + 0.32708 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.07592 * w, y: minY + 0.28604 * h), controlPoint1:CGPoint(x:minX + 0.10738 * w, y: minY + 0.3024 * h), controlPoint2:CGPoint(x:minX + 0.07592 * w, y: minY + 0.28447 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.07917 * w, y: minY + 0.29464 * h), controlPoint1:CGPoint(x:minX + 0.07592 * w, y: minY + 0.28632 * h), controlPoint2:CGPoint(x:minX + 0.07735 * w, y: minY + 0.2902 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.08684 * w, y: minY + 0.34196 * h), controlPoint1:CGPoint(x:minX + 0.08593 * w, y: minY + 0.31165 * h), controlPoint2:CGPoint(x:minX + 0.08684 * w, y: minY + 0.31774 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.07371 * w, y: minY + 0.40665 * h), controlPoint1:CGPoint(x:minX + 0.08684 * w, y: minY + 0.36858 * h), controlPoint2:CGPoint(x:minX + 0.08541 * w, y: minY + 0.37606 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.04472 * w, y: minY + 0.47366 * h), controlPoint1:CGPoint(x:minX + 0.06695 * w, y: minY + 0.42449 * h), controlPoint2:CGPoint(x:minX + 0.06331 * w, y: minY + 0.43299 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.03497 * w, y: minY + 0.49584 * h), controlPoint1:CGPoint(x:minX + 0.04056 * w, y: minY + 0.48281 * h), controlPoint2:CGPoint(x:minX + 0.03614 * w, y: minY + 0.49279 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.02938 * w, y: minY + 0.5097 * h), controlPoint1:CGPoint(x:minX + 0.03211 * w, y: minY + 0.50333 * h), controlPoint2:CGPoint(x:minX + 0.0325 * w, y: minY + 0.5024 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00156 * w, y: minY + 0.61275 * h), controlPoint1:CGPoint(x:minX + 0.01651 * w, y: minY + 0.53965 * h), controlPoint2:CGPoint(x:minX + 0.00585 * w, y: minY + 0.57921 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.00156 * w, y: minY + 0.70148 * h), controlPoint1:CGPoint(x:minX + -0.00052 * w, y: minY + 0.62893 * h), controlPoint2:CGPoint(x:minX + -0.00052 * w, y: minY + 0.6853 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.01495 * w, y: minY + 0.76571 * h), controlPoint1:CGPoint(x:minX + 0.00468 * w, y: minY + 0.72588 * h), controlPoint2:CGPoint(x:minX + 0.00884 * w, y: minY + 0.74575 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.03003 * w, y: minY + 0.80268 * h), controlPoint1:CGPoint(x:minX + 0.02015 * w, y: minY + 0.78281 * h), controlPoint2:CGPoint(x:minX + 0.02158 * w, y: minY + 0.78632 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.09724 * w, y: minY + 0.88632 * h), controlPoint1:CGPoint(x:minX + 0.04628 * w, y: minY + 0.83392 * h), controlPoint2:CGPoint(x:minX + 0.06799 * w, y: minY + 0.861 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.14613 * w, y: minY + 0.9219 * h), controlPoint1:CGPoint(x:minX + 0.10595 * w, y: minY + 0.8939 * h), controlPoint2:CGPoint(x:minX + 0.13677 * w, y: minY + 0.91627 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.27223 * w, y: minY + 0.97643 * h), controlPoint1:CGPoint(x:minX + 0.18396 * w, y: minY + 0.94473 * h), controlPoint2:CGPoint(x:minX + 0.23128 * w, y: minY + 0.96516 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.29043 * w, y: minY + 0.98161 * h), controlPoint1:CGPoint(x:minX + 0.27899 * w, y: minY + 0.97828 * h), controlPoint2:CGPoint(x:minX + 0.28718 * w, y: minY + 0.98059 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.36908 * w, y: minY + 0.9976 * h), controlPoint1:CGPoint(x:minX + 0.30265 * w, y: minY + 0.9853 * h), controlPoint2:CGPoint(x:minX + 0.35465 * w, y: minY + 0.99593 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.37818 * w, y: minY + 0.9988 * h), controlPoint1:CGPoint(x:minX + 0.37194 * w, y: minY + 0.99797 * h), controlPoint2:CGPoint(x:minX + 0.3761 * w, y: minY + 0.99843 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.38208 * w, y: minY + 0.99926 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37818 * w, y: minY + 0.99713 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.31682 * w, y: minY + 0.95083 * h), controlPoint1:CGPoint(x:minX + 0.35868 * w, y: minY + 0.98632 * h), controlPoint2:CGPoint(x:minX + 0.33476 * w, y: minY + 0.96821 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.27145 * w, y: minY + 0.88475 * h), controlPoint1:CGPoint(x:minX + 0.30057 * w, y: minY + 0.93503 * h), controlPoint2:CGPoint(x:minX + 0.27834 * w, y: minY + 0.90277 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.25832 * w, y: minY + 0.84566 * h), controlPoint1:CGPoint(x:minX + 0.26417 * w, y: minY + 0.86571 * h), controlPoint2:CGPoint(x:minX + 0.26144 * w, y: minY + 0.85758 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.25481 * w, y: minY + 0.8036 * h), controlPoint1:CGPoint(x:minX + 0.25507 * w, y: minY + 0.83299 * h), controlPoint2:CGPoint(x:minX + 0.25481 * w, y: minY + 0.83059 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.25754 * w, y: minY + 0.76479 * h), controlPoint1:CGPoint(x:minX + 0.25468 * w, y: minY + 0.77754 * h), controlPoint2:CGPoint(x:minX + 0.25494 * w, y: minY + 0.77403 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.27782 * w, y: minY + 0.72181 * h), controlPoint1:CGPoint(x:minX + 0.26222 * w, y: minY + 0.74871 * h), controlPoint2:CGPoint(x:minX + 0.2721 * w, y: minY + 0.72763 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.28133 * w, y: minY + 0.72569 * h), controlPoint1:CGPoint(x:minX + 0.27951 * w, y: minY + 0.72006 * h), controlPoint2:CGPoint(x:minX + 0.27977 * w, y: minY + 0.72024 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.30031 * w, y: minY + 0.76331 * h), controlPoint1:CGPoint(x:minX + 0.28419 * w, y: minY + 0.73614 * h), controlPoint2:CGPoint(x:minX + 0.2929 * w, y: minY + 0.75333 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.33281 * w, y: minY + 0.79399 * h), controlPoint1:CGPoint(x:minX + 0.30876 * w, y: minY + 0.77458 * h), controlPoint2:CGPoint(x:minX + 0.32007 * w, y: minY + 0.7853 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.35634 * w, y: minY + 0.80647 * h), controlPoint1:CGPoint(x:minX + 0.34165 * w, y: minY + 0.8 * h), controlPoint2:CGPoint(x:minX + 0.3553 * w, y: minY + 0.80721 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.35478 * w, y: minY + 0.79603 * h), controlPoint1:CGPoint(x:minX + 0.35673 * w, y: minY + 0.80628 * h), controlPoint2:CGPoint(x:minX + 0.35595 * w, y: minY + 0.80157 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.35036 * w, y: minY + 0.7061 * h), controlPoint1:CGPoint(x:minX + 0.34919 * w, y: minY + 0.76969 * h), controlPoint2:CGPoint(x:minX + 0.34724 * w, y: minY + 0.72985 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.36063 * w, y: minY + 0.65943 * h), controlPoint1:CGPoint(x:minX + 0.35192 * w, y: minY + 0.69307 * h), controlPoint2:CGPoint(x:minX + 0.35725 * w, y: minY + 0.66941 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.41706 * w, y: minY + 0.56932 * h), controlPoint1:CGPoint(x:minX + 0.37168 * w, y: minY + 0.62736 * h), controlPoint2:CGPoint(x:minX + 0.39431 * w, y: minY + 0.59122 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.42525 * w, y: minY + 0.56128 * h), controlPoint1:CGPoint(x:minX + 0.41992 * w, y: minY + 0.56654 * h), controlPoint2:CGPoint(x:minX + 0.42369 * w, y: minY + 0.56294 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.50494 * w, y: minY + 0.50767 * h), controlPoint1:CGPoint(x:minX + 0.44098 * w, y: minY + 0.54492 * h), controlPoint2:CGPoint(x:minX + 0.47764 * w, y: minY + 0.52024 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51612 * w, y: minY + 0.50527 * h), controlPoint1:CGPoint(x:minX + 0.51404 * w, y: minY + 0.50342 * h), controlPoint2:CGPoint(x:minX + 0.51716 * w, y: minY + 0.50277 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51248 * w, y: minY + 0.54067 * h), controlPoint1:CGPoint(x:minX + 0.51391 * w, y: minY + 0.51063 * h), controlPoint2:CGPoint(x:minX + 0.51235 * w, y: minY + 0.52495 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.57033 * w, y: minY + 0.65841 * h), controlPoint1:CGPoint(x:minX + 0.51248 * w, y: minY + 0.58669 * h), controlPoint2:CGPoint(x:minX + 0.5299 * w, y: minY + 0.62218 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.60023 * w, y: minY + 0.68438 * h), controlPoint1:CGPoint(x:minX + 0.5806 * w, y: minY + 0.66765 * h), controlPoint2:CGPoint(x:minX + 0.59646 * w, y: minY + 0.68142 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.60868 * w, y: minY + 0.69177 * h), controlPoint1:CGPoint(x:minX + 0.60166 * w, y: minY + 0.6854 * h), controlPoint2:CGPoint(x:minX + 0.60543 * w, y: minY + 0.68872 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61713 * w, y: minY + 0.69917 * h), controlPoint1:CGPoint(x:minX + 0.61206 * w, y: minY + 0.69482 * h), controlPoint2:CGPoint(x:minX + 0.61583 * w, y: minY + 0.69815 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.63117 * w, y: minY + 0.71322 * h), controlPoint1:CGPoint(x:minX + 0.61843 * w, y: minY + 0.70018 * h), controlPoint2:CGPoint(x:minX + 0.6248 * w, y: minY + 0.70647 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.66849 * w, y: minY + 0.76895 * h), controlPoint1:CGPoint(x:minX + 0.64898 * w, y: minY + 0.73198 * h), controlPoint2:CGPoint(x:minX + 0.659 * w, y: minY + 0.74695 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.6759 * w, y: minY + 0.87486 * h), controlPoint1:CGPoint(x:minX + 0.68045 * w, y: minY + 0.79667 * h), controlPoint2:CGPoint(x:minX + 0.68331 * w, y: minY + 0.83891 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.63039 * w, y: minY + 0.95896 * h), controlPoint1:CGPoint(x:minX + 0.66992 * w, y: minY + 0.90351 * h), controlPoint2:CGPoint(x:minX + 0.65328 * w, y: minY + 0.93429 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.59321 * w, y: minY + 0.99104 * h), controlPoint1:CGPoint(x:minX + 0.61869 * w, y: minY + 0.97153 * h), controlPoint2:CGPoint(x:minX + 0.60972 * w, y: minY + 0.9793 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.58138 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.58619 * w, y: minY + 0.99593 * h), controlPoint2:CGPoint(x:minX + 0.58086 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.61154 * w, y: minY + 0.99584 * h), controlPoint1:CGPoint(x:minX + 0.58372 * w, y: minY + h), controlPoint2:CGPoint(x:minX + 0.604 * w, y: minY + 0.99723 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.63884 * w, y: minY + 0.9902 * h), controlPoint1:CGPoint(x:minX + 0.61622 * w, y: minY + 0.99501 * h), controlPoint2:CGPoint(x:minX + 0.62844 * w, y: minY + 0.99251 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.90028 * w, y: minY + 0.85813 * h), controlPoint1:CGPoint(x:minX + 0.7422 * w, y: minY + 0.96719 * h), controlPoint2:CGPoint(x:minX + 0.83073 * w, y: minY + 0.92255 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.93916 * w, y: minY + 0.81368 * h), controlPoint1:CGPoint(x:minX + 0.91277 * w, y: minY + 0.84658 * h), controlPoint2:CGPoint(x:minX + 0.93994 * w, y: minY + 0.81553 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.9402 * w, y: minY + 0.81248 * h), controlPoint1:CGPoint(x:minX + 0.93903 * w, y: minY + 0.81331 * h), controlPoint2:CGPoint(x:minX + 0.93955 * w, y: minY + 0.81275 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.95775 * w, y: minY + 0.78743 * h), controlPoint1:CGPoint(x:minX + 0.94176 * w, y: minY + 0.81174 * h), controlPoint2:CGPoint(x:minX + 0.95177 * w, y: minY + 0.79741 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.98115 * w, y: minY + 0.7366 * h), controlPoint1:CGPoint(x:minX + 0.96529 * w, y: minY + 0.77468 * h), controlPoint2:CGPoint(x:minX + 0.97868 * w, y: minY + 0.74556 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.98583 * w, y: minY + 0.72107 * h), controlPoint1:CGPoint(x:minX + 0.98154 * w, y: minY + 0.7353 * h), controlPoint2:CGPoint(x:minX + 0.98362 * w, y: minY + 0.72837 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99974 * w, y: minY + 0.6354 * h), controlPoint1:CGPoint(x:minX + 0.99493 * w, y: minY + 0.6915 * h), controlPoint2:CGPoint(x:minX + 0.99857 * w, y: minY + 0.66932 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.99103 * w, y: minY + 0.54113 * h), controlPoint1:CGPoint(x:minX + 1.00091 * w, y: minY + 0.60157 * h), controlPoint2:CGPoint(x:minX + 0.99818 * w, y: minY + 0.57116 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.96789 * w, y: minY + 0.47227 * h), controlPoint1:CGPoint(x:minX + 0.98596 * w, y: minY + 0.51941 * h), controlPoint2:CGPoint(x:minX + 0.97543 * w, y: minY + 0.48854 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.96321 * w, y: minY + 0.46211 * h), controlPoint1:CGPoint(x:minX + 0.96659 * w, y: minY + 0.4695 * h), controlPoint2:CGPoint(x:minX + 0.96451 * w, y: minY + 0.46488 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.90639 * w, y: minY + 0.37523 * h), controlPoint1:CGPoint(x:minX + 0.95398 * w, y: minY + 0.44104 * h), controlPoint2:CGPoint(x:minX + 0.92226 * w, y: minY + 0.39251 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.89833 * w, y: minY + 0.36599 * h), controlPoint1:CGPoint(x:minX + 0.90392 * w, y: minY + 0.37246 * h), controlPoint2:CGPoint(x:minX + 0.90028 * w, y: minY + 0.3683 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.8722 * w, y: minY + 0.339 * h), controlPoint1:CGPoint(x:minX + 0.89404 * w, y: minY + 0.36072 * h), controlPoint2:CGPoint(x:minX + 0.87571 * w, y: minY + 0.34187 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.86349 * w, y: minY + 0.33087 * h), controlPoint1:CGPoint(x:minX + 0.87077 * w, y: minY + 0.3378 * h), controlPoint2:CGPoint(x:minX + 0.86687 * w, y: minY + 0.3342 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.85452 * w, y: minY + 0.32301 * h), controlPoint1:CGPoint(x:minX + 0.86011 * w, y: minY + 0.32754 * h), controlPoint2:CGPoint(x:minX + 0.85608 * w, y: minY + 0.32394 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.85166 * w, y: minY + 0.32116 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.85257 * w, y: minY + 0.32532 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.8553 * w, y: minY + 0.45425 * h), controlPoint1:CGPoint(x:minX + 0.86323 * w, y: minY + 0.37366 * h), controlPoint2:CGPoint(x:minX + 0.86414 * w, y: minY + 0.41774 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.82709 * w, y: minY + 0.51941 * h), controlPoint1:CGPoint(x:minX + 0.84932 * w, y: minY + 0.47865 * h), controlPoint2:CGPoint(x:minX + 0.84217 * w, y: minY + 0.49519 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.80226 * w, y: minY + 0.54621 * h), controlPoint1:CGPoint(x:minX + 0.82228 * w, y: minY + 0.52726 * h), controlPoint2:CGPoint(x:minX + 0.8046 * w, y: minY + 0.54621 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.80083 * w, y: minY + 0.53762 * h), controlPoint1:CGPoint(x:minX + 0.802 * w, y: minY + 0.54621 * h), controlPoint2:CGPoint(x:minX + 0.80135 * w, y: minY + 0.54233 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.78445 * w, y: minY + 0.45933 * h), controlPoint1:CGPoint(x:minX + 0.79823 * w, y: minY + 0.51118 * h), controlPoint2:CGPoint(x:minX + 0.79199 * w, y: minY + 0.48124 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.72816 * w, y: minY + 0.3646 * h), controlPoint1:CGPoint(x:minX + 0.77184 * w, y: minY + 0.42311 * h), controlPoint2:CGPoint(x:minX + 0.75702 * w, y: minY + 0.39815 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.70775 * w, y: minY + 0.34325 * h), controlPoint1:CGPoint(x:minX + 0.7253 * w, y: minY + 0.36137 * h), controlPoint2:CGPoint(x:minX + 0.71373 * w, y: minY + 0.34917 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.69618 * w, y: minY + 0.3317 * h), controlPoint1:CGPoint(x:minX + 0.7045 * w, y: minY + 0.34002 * h), controlPoint2:CGPoint(x:minX + 0.6993 * w, y: minY + 0.33484 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.68838 * w, y: minY + 0.3244 * h), controlPoint1:CGPoint(x:minX + 0.69306 * w, y: minY + 0.32856 * h), controlPoint2:CGPoint(x:minX + 0.68955 * w, y: minY + 0.32532 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.68149 * w, y: minY + 0.31821 * h), controlPoint1:CGPoint(x:minX + 0.68721 * w, y: minY + 0.32348 * h), controlPoint2:CGPoint(x:minX + 0.68422 * w, y: minY + 0.3207 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.65705 * w, y: minY + 0.29621 * h), controlPoint1:CGPoint(x:minX + 0.67889 * w, y: minY + 0.3158 * h), controlPoint2:CGPoint(x:minX + 0.66784 * w, y: minY + 0.30582 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.57319 * w, y: minY + 0.21793 * h), controlPoint1:CGPoint(x:minX + 0.59633 * w, y: minY + 0.24224 * h), controlPoint2:CGPoint(x:minX + 0.59425 * w, y: minY + 0.2403 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.53406 * w, y: minY + 0.17033 * h), controlPoint1:CGPoint(x:minX + 0.55655 * w, y: minY + 0.20028 * h), controlPoint2:CGPoint(x:minX + 0.54732 * w, y: minY + 0.18891 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.52106 * w, y: minY + 0.15416 * h), controlPoint1:CGPoint(x:minX + 0.52743 * w, y: minY + 0.16109 * h), controlPoint2:CGPoint(x:minX + 0.52171 * w, y: minY + 0.15379 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.52106 * w, y: minY + 0.1536 * h), controlPoint1:CGPoint(x:minX + 0.52054 * w, y: minY + 0.15453 * h), controlPoint2:CGPoint(x:minX + 0.52054 * w, y: minY + 0.15425 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51131 * w, y: minY + 0.13318 * h), controlPoint1:CGPoint(x:minX + 0.52184 * w, y: minY + 0.15259 * h), controlPoint2:CGPoint(x:minX + 0.5195 * w, y: minY + 0.1476 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49649 * w, y: minY + 0.08771 * h), controlPoint1:CGPoint(x:minX + 0.5078 * w, y: minY + 0.12699 * h), controlPoint2:CGPoint(x:minX + 0.49831 * w, y: minY + 0.09769 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.51287 * w, y: minY + 0.00388 * h), controlPoint1:CGPoint(x:minX + 0.49155 * w, y: minY + 0.05878 * h), controlPoint2:CGPoint(x:minX + 0.49714 * w, y: minY + 0.03022 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5143 * w, y: minY), controlPoint1:CGPoint(x:minX + 0.51417 * w, y: minY + 0.00176 * h), controlPoint2:CGPoint(x:minX + 0.51482 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX + 0.50364 * w, y: minY + 0.00314 * h), controlPoint1:CGPoint(x:minX + 0.51378 * w, y: minY), controlPoint2:CGPoint(x:minX + 0.50897 * w, y: minY + 0.00139 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.50364 * w, y: minY + 0.00314 * h))
        
        return pathPath
    }
    
    
}
