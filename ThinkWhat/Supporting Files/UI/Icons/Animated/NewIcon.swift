//
//  NewIcon.swift
//
//  Code generated using QuartzCode 1.66.4 on 21.08.2020.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class NewIcon: AnimatedIcon, CAAnimationDelegate {
    
    override var state: AnimatedIcon.State {
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
        self.active = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
        self.active1 = Colors.System.Red.rawValue//Colors.UpperButtons.Avocado//K_COLOR_RED//K_COLOR_RED//UIColor(red:1.00, green: 0.15, blue:0.00, alpha:1.0)
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
                                            NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1))]
        pathTransformAnim.keyTimes       = [0, 1]
        pathTransformAnim.duration       = 0.15
        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor,
                                            self.active1.cgColor]
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
        pathFillColorAnim.values         = [self.active1.cgColor,
                                            UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
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
    
//    func removeAllAnimations(){
//        for layer in layers.values{
//            layer.removeAllAnimations()
//        }
//    }
    
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
        pathPath.move(to: CGPoint(x:minX + 0.3567 * w, y: minY + 0.11487 * h))
        
        return pathPath
    }
    
    
}







////
////  NewIcon.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 21.11.2019.
////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//@IBDesignable
//class NewIcon: Icon, CAAnimationDelegate {
//
//    override var state: Icon.State {
//        didSet {
//            if oldValue != state {
//                if state == .enabled {
//                    self.addEnableAnimation()
//                } else {
//                    self.addDisableAnimation()
//                }
//            }
//        }
//    }
//    var layers = [String: CALayer]()
//    var completionBlocks = [CAAnimation: (Bool) -> Void]()
//    var updateLayerValueForCompletedAnimation : Bool = false
//
//    var active : UIColor!
//    var active1 : UIColor!
//
//    //MARK: - Life Cycle
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupProperties()
//        setupLayers()
//    }
//
//    required init?(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)
//        setupProperties()
//        setupLayers()
//    }
//
//    override var frame: CGRect{
//        didSet{
//            setupLayerFrames()
//        }
//    }
//
//    override var bounds: CGRect{
//        didSet{
//            setupLayerFrames()
//        }
//    }
//
//    func setupProperties(){
//        self.active = K_COLOR_RED//UIColor(red:0.754, green: 0.245, blue:0.27, alpha:1)
////        self.active1 = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
//    }
//
//    func setupLayers(){
//        let path = CAShapeLayer()
//        self.layer.addSublayer(path)
//        layers["path"] = path
//
//        resetLayerProperties(forLayerIdentifiers: nil)
//        setupLayerFrames()
//    }
//
//    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        if layerIds == nil || layerIds.contains("path"){
//            let path = layers["path"] as! CAShapeLayer
//            path.setValue(45 * CGFloat.pi/180, forKeyPath:"transform.rotation")
//            path.fillRule    = .evenOdd
//            path.fillColor   = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor
//            path.strokeColor = UIColor.black.cgColor
//            path.lineWidth   = 0
//        }
//
//        CATransaction.commit()
//    }
//
//    func setupLayerFrames(){
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        if let path = layers["path"] as? CAShapeLayer{
//            path.transform = CATransform3DIdentity
//            path.frame     = CGRect(x: 0.07428 * path.superlayer!.bounds.width, y: 0.21653 * path.superlayer!.bounds.height, width: 0.85144 * path.superlayer!.bounds.width, height: 0.56694 * path.superlayer!.bounds.height)
//            path.setValue(45 * CGFloat.pi/180, forKeyPath:"transform.rotation")
//            path.path      = pathPath(bounds: layers["path"]!.bounds).cgPath
//        }
//
//        CATransaction.commit()
//    }
//
//    //MARK: - Animation Setup
//
//    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
//        if completionBlock != nil{
//            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
//            completionAnim.duration = 0.15
//            completionAnim.delegate = self
//            completionAnim.setValue("enable", forKey:"animId")
//            completionAnim.setValue(false, forKey:"needEndAnim")
//            layer.add(completionAnim, forKey:"enable")
//            if let anim = layer.animation(forKey: "enable"){
//                completionBlocks[anim] = completionBlock
//            }
//        }
//
//        let fillMode : CAMediaTimingFillMode = .forwards
//
//        let path = layers["path"] as! CAShapeLayer
//
//        ////Path animation
//        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
//        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeRotation(-45 * CGFloat.pi/180, 0, 0, -1)),
//                                            NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1.3, 1.3, 1), CATransform3DMakeRotation(45 * CGFloat.pi/180, 0, -0, 1)))]
//        pathTransformAnim.keyTimes       = [0, 1]
//        pathTransformAnim.duration       = 0.15
//        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
//
//        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
//        pathFillColorAnim.values         = [UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor,
//                                            self.active.cgColor]
//        pathFillColorAnim.keyTimes       = [0, 1]
//        pathFillColorAnim.duration       = 0.15
//        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
//
//        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathFillColorAnim], fillMode:fillMode)
//        path.add(pathEnableAnim, forKey:"pathEnableAnim")
//    }
//
//    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
//        if completionBlock != nil{
//            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
//            completionAnim.duration = 0.15
//            completionAnim.delegate = self
//            completionAnim.setValue("disable", forKey:"animId")
//            completionAnim.setValue(false, forKey:"needEndAnim")
//            layer.add(completionAnim, forKey:"disable")
//            if let anim = layer.animation(forKey: "disable"){
//                completionBlocks[anim] = completionBlock
//            }
//        }
//
//        let fillMode : CAMediaTimingFillMode = .forwards
//
//        let path = layers["path"] as! CAShapeLayer
//
//        ////Path animation
//        let pathTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
//        pathTransformAnim.values         = [NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeScale(1.3, 1.3, 1), CATransform3DMakeRotation(45 * CGFloat.pi/180, 0, -0, 1))),
//                                            NSValue(caTransform3D: CATransform3DMakeRotation(-45 * CGFloat.pi/180, 0, 0, -1))]
//        pathTransformAnim.keyTimes       = [0, 1]
//        pathTransformAnim.duration       = 0.15
//        pathTransformAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
//
//        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
//        pathFillColorAnim.values         = [self.active.cgColor,
//                                            UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1).cgColor]
//        pathFillColorAnim.keyTimes       = [0, 1]
//        pathFillColorAnim.duration       = 0.15
//        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeOut)
//
//        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathTransformAnim, pathFillColorAnim], fillMode:fillMode)
//        path.add(pathDisableAnim, forKey:"pathDisableAnim")
//    }
//
//    //MARK: - Animation Cleanup
//
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
//        if let completionBlock = completionBlocks[anim]{
//            completionBlocks.removeValue(forKey: anim)
//            if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
//                updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
//                removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
//            }
//            completionBlock(flag)
//        }
//    }
//
//    func updateLayerValues(forAnimationId identifier: String){
//        if identifier == "enable"{
//            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathEnableAnim"), theLayer:layers["path"]!)
//        }
//        else if identifier == "disable"{
//            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathDisableAnim"), theLayer:layers["path"]!)
//        }
//    }
//
//    func removeAnimations(forAnimationId identifier: String){
//        if identifier == "enable"{
//            layers["path"]?.removeAnimation(forKey: "pathEnableAnim")
//        }
//        else if identifier == "disable"{
//            layers["path"]?.removeAnimation(forKey: "pathDisableAnim")
//        }
//    }
//
//    override func removeAllAnimations(){
//        for layer in layers.values{
//            layer.removeAllAnimations()
//        }
//    }
//
//    //MARK: - Bezier Path
//
//    func pathPath(bounds: CGRect) -> UIBezierPath{
//        let pathPath = UIBezierPath()
//        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
//
//        pathPath.move(to: CGPoint(x:minX + 0.34681 * w, y: minY + h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.38574 * w, y: minY + h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.46222 * w, y: minY + h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.88472 * w, y: minY + h))
//        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.81249 * h), controlPoint1:CGPoint(x:minX + 0.94837 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.91605 * h))
//        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + 0.18751 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.88476 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.08397 * h), controlPoint2:CGPoint(x:minX + 0.94841 * w, y: minY))
//        pathPath.addLine(to: CGPoint(x:minX + 0.46207 * w, y: minY))
//        pathPath.addLine(to: CGPoint(x:minX + 0.38574 * w, y: minY))
//        pathPath.addLine(to: CGPoint(x:minX + 0.34683 * w, y: minY))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.05386 * w, y: minY + 0.20429 * h), controlPoint1:CGPoint(x:minX + 0.3005 * w, y: minY), controlPoint2:CGPoint(x:minX + 0.13873 * w, y: minY + 0.13215 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.00098 * w, y: minY + 0.32476 * h), controlPoint1:CGPoint(x:minX + 0.022 * w, y: minY + 0.23137 * h), controlPoint2:CGPoint(x:minX + 0.00098 * w, y: minY + 0.27767 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.00098 * w, y: minY + 0.67265 * h), controlPoint1:CGPoint(x:minX + 0.00098 * w, y: minY + 0.3571 * h), controlPoint2:CGPoint(x:minX + -0.00122 * w, y: minY + 0.65244 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.05209 * w, y: minY + 0.7942 * h), controlPoint1:CGPoint(x:minX + 0.008 * w, y: minY + 0.73717 * h), controlPoint2:CGPoint(x:minX + 0.02122 * w, y: minY + 0.76794 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.34681 * w, y: minY + h), controlPoint1:CGPoint(x:minX + 0.05209 * w, y: minY + 0.7942 * h), controlPoint2:CGPoint(x:minX + 0.30019 * w, y: minY + h))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.27098 * w, y: minY + 0.27952 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.12417 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.1899 * w, y: minY + 0.27952 * h), controlPoint2:CGPoint(x:minX + 0.12417 * w, y: minY + 0.37823 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.27098 * w, y: minY + 0.72048 * h), controlPoint1:CGPoint(x:minX + 0.12417 * w, y: minY + 0.62177 * h), controlPoint2:CGPoint(x:minX + 0.1899 * w, y: minY + 0.72048 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.41779 * w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.35206 * w, y: minY + 0.72048 * h), controlPoint2:CGPoint(x:minX + 0.41779 * w, y: minY + 0.62177 * h))
//        pathPath.addCurve(to: CGPoint(x:minX + 0.27098 * w, y: minY + 0.27952 * h), controlPoint1:CGPoint(x:minX + 0.41779 * w, y: minY + 0.37823 * h), controlPoint2:CGPoint(x:minX + 0.35206 * w, y: minY + 0.27952 * h))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.53061 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.48826 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.48826 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.52193 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.52193 * w, y: minY + 0.42397 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.52244 * w, y: minY + 0.42397 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.56735 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.60919 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.60919 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.57551 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.57551 * w, y: minY + 0.55795 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.575 * w, y: minY + 0.55795 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.53061 * w, y: minY + 0.31971 * h))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.7365 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.6347 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.6347 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.73905 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.73905 * w, y: minY + 0.61008 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.67144 * w, y: minY + 0.61008 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.67144 * w, y: minY + 0.51654 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.73268 * w, y: minY + 0.51654 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.73268 * w, y: minY + 0.45905 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.67144 * w, y: minY + 0.45905 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.67144 * w, y: minY + 0.3772 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.7365 * w, y: minY + 0.3772 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.7365 * w, y: minY + 0.31971 * h))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.74671 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.77988 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.82095 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.84136 * w, y: minY + 0.4152 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.84187 * w, y: minY + 0.4152 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.86228 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.90336 * w, y: minY + 0.66757 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.93653 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.90132 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.88116 * w, y: minY + 0.57695 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.88065 * w, y: minY + 0.57695 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.85922 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.82401 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.80258 * w, y: minY + 0.57695 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.80207 * w, y: minY + 0.57695 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.78192 * w, y: minY + 0.31971 * h))
//        pathPath.addLine(to: CGPoint(x:minX + 0.74671 * w, y: minY + 0.31971 * h))
//        pathPath.close()
//        pathPath.move(to: CGPoint(x:minX + 0.74671 * w, y: minY + 0.31971 * h))
//
//        return pathPath
//    }
//
//
//}
