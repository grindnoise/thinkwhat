//
//  PlusIcon.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit


@IBDesignable
class PlusIcon: StateButton, CAAnimationDelegate {

    override var state: State {
        didSet {
            if state != oldValue {
                state == .enabled ? addEnableAnimation() : addDisableAnimation()
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
        self.active = K_COLOR_RED//UIColor(red:0.89, green: 0.462, blue:0.444, alpha:1)
        self.inactive = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
    }
    
    func setupLayers(){
        self.backgroundColor = .clear//UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        
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
            path.fillColor   = self.active.cgColor
            path.strokeColor = self.active.cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0, y: 0, width:  path.superlayer!.bounds.width, height: 1 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
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
        
        ////Path animation
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [self.active.cgColor,
                                            self.inactive.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathDisableAnim, forKey:"pathDisableAnim")
    }
    
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
        pathFillColorAnim.values         = [self.inactive.cgColor,
                                            self.active.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathEnableAnim, forKey:"pathEnableAnim")
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
        if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathDisableAnim"), theLayer:layers["path"]!)
        }
        else if identifier == "enable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathEnableAnim"), theLayer:layers["path"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "disable"{
            layers["path"]?.removeAnimation(forKey: "pathDisableAnim")
        }
        else if identifier == "enable"{
            layers["path"]?.removeAnimation(forKey: "pathEnableAnim")
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
        
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.43872 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.20803 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49823 * w, y: minY + 0.14418 * h), controlPoint1:CGPoint(x:minX + 0.43985 * w, y: minY + 0.17277 * h), controlPoint2:CGPoint(x:minX + 0.46599 * w, y: minY + 0.14418 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5566 * w, y: minY + 0.20803 * h), controlPoint1:CGPoint(x:minX + 0.53046 * w, y: minY + 0.14418 * h), controlPoint2:CGPoint(x:minX + 0.5566 * w, y: minY + 0.17277 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.5566 * w, y: minY + 0.43872 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.78907 * w, y: minY + 0.43872 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.85291 * w, y: minY + 0.49709 * h), controlPoint1:CGPoint(x:minX + 0.82432 * w, y: minY + 0.43872 * h), controlPoint2:CGPoint(x:minX + 0.85291 * w, y: minY + 0.46485 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.78907 * w, y: minY + 0.55546 * h), controlPoint1:CGPoint(x:minX + 0.85291 * w, y: minY + 0.52933 * h), controlPoint2:CGPoint(x:minX + 0.82432 * w, y: minY + 0.55546 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.5566 * w, y: minY + 0.55546 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.5566 * w, y: minY + 0.78616 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.49823 * w, y: minY + 0.85 * h), controlPoint1:CGPoint(x:minX + 0.5566 * w, y: minY + 0.82142 * h), controlPoint2:CGPoint(x:minX + 0.53046 * w, y: minY + 0.85 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.78616 * h), controlPoint1:CGPoint(x:minX + 0.46599 * w, y: minY + 0.85 * h), controlPoint2:CGPoint(x:minX + 0.43985 * w, y: minY + 0.82142 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.55546 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.21093 * w, y: minY + 0.55546 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.14709 * w, y: minY + 0.49709 * h), controlPoint1:CGPoint(x:minX + 0.17568 * w, y: minY + 0.55546 * h), controlPoint2:CGPoint(x:minX + 0.14709 * w, y: minY + 0.52933 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.21093 * w, y: minY + 0.43872 * h), controlPoint1:CGPoint(x:minX + 0.14709 * w, y: minY + 0.46485 * h), controlPoint2:CGPoint(x:minX + 0.17568 * w, y: minY + 0.43872 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.43872 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.43872 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.43985 * w, y: minY + 0.43872 * h))
        
        return pathPath
    }
    
}

@IBDesignable
class GalleryIcon: StateButton, CAAnimationDelegate {
    
    override var state: State {
        didSet {
            if state != oldValue {
                state == .enabled ? addEnableAnimation() : addDisableAnimation()
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
        self.active = K_COLOR_RED//UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0)
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
            path.fillRule    = .evenOdd
            path.fillColor   = self.active.cgColor
            path.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0, y: 0.12315 * path.superlayer!.bounds.height, width:  path.superlayer!.bounds.width, height: 0.75369 * path.superlayer!.bounds.height)
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
        pathFillColorAnim.values         = [self.inactive.cgColor,
                                            self.active.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathEnableAnim, forKey:"pathEnableAnim")
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
        
        ////Path animation
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [self.active.cgColor,
                                            self.inactive.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
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
    
    override func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func pathPath(bounds: CGRect) -> UIBezierPath{
        let pathPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        pathPath.move(to: CGPoint(x:minX + 0.12 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.15922 * h), controlPoint1:CGPoint(x:minX + 0.05373 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.07128 * h))
        pathPath.addLine(to: CGPoint(x:minX, y: minY + 0.84078 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.12 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.92872 * h), controlPoint2:CGPoint(x:minX + 0.05373 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.88 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.84078 * h), controlPoint1:CGPoint(x:minX + 0.94627 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.92872 * h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + 0.15922 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.88 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.07128 * h), controlPoint2:CGPoint(x:minX + 0.94627 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.12 * w, y: minY))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.60371 * w, y: minY + 0.80516 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.14 * w, y: minY + 0.80516 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.37186 * w, y: minY + 0.29423 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.55186 * w, y: minY + 0.69089 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.67127 * w, y: minY + 0.42774 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.84254 * w, y: minY + 0.80516 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.60371 * w, y: minY + 0.80516 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.60371 * w, y: minY + 0.80516 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.60371 * w, y: minY + 0.80516 * h))
        
        return pathPath
    }
    
    
}

@IBDesignable
class CameraIcon: StateButton, CAAnimationDelegate {
    
    override var state: State {
        didSet {
            if state != oldValue {
                state == .enabled ? addEnableAnimation() : addDisableAnimation()
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
        self.active = K_COLOR_RED//UIColor(red:0.89, green: 0.462, blue:0.444, alpha:1)
        self.inactive = UIColor(red:0.664, green: 0.664, blue:0.664, alpha:1)
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
            path.fillColor   = self.active.cgColor
            path.strokeColor = UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            path.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let path = layers["path"] as? CAShapeLayer{
            path.frame = CGRect(x: 0, y: 0.02046 * path.superlayer!.bounds.height, width:  path.superlayer!.bounds.width, height: 0.85394 * path.superlayer!.bounds.height)
            path.path  = pathPath(bounds: layers["path"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
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
        
        ////Path animation
        let pathFillColorAnim            = CAKeyframeAnimation(keyPath:"fillColor")
        pathFillColorAnim.values         = [UIColor(red:1.00, green: 0.49, blue:0.47, alpha:1.0).cgColor,
                                            self.inactive.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathDisableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathDisableAnim, forKey:"pathDisableAnim")
    }
    
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
        pathFillColorAnim.values         = [self.inactive.cgColor,
                                            self.active.cgColor]
        pathFillColorAnim.keyTimes       = [0, 1]
        pathFillColorAnim.duration       = 0.2
        pathFillColorAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let pathEnableAnim : CAAnimationGroup = QCMethod.group(animations: [pathFillColorAnim], fillMode:fillMode)
        layers["path"]?.add(pathEnableAnim, forKey:"pathEnableAnim")
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
        if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathDisableAnim"), theLayer:layers["path"]!)
        }
        else if identifier == "enable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["path"]!.animation(forKey: "pathEnableAnim"), theLayer:layers["path"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "disable"{
            layers["path"]?.removeAnimation(forKey: "pathDisableAnim")
        }
        else if identifier == "enable"{
            layers["path"]?.removeAnimation(forKey: "pathEnableAnim")
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
        
        pathPath.move(to: CGPoint(x:minX + 0.79433 * w, y: minY + 0.12312 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.88 * w, y: minY + 0.12312 * h))
        pathPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.26364 * h), controlPoint1:CGPoint(x:minX + 0.94627 * w, y: minY + 0.12312 * h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.18603 * h))
        pathPath.addLine(to: CGPoint(x:minX + w, y: minY + 0.85948 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.88 * w, y: minY + h), controlPoint1:CGPoint(x:minX + w, y: minY + 0.93708 * h), controlPoint2:CGPoint(x:minX + 0.94627 * w, y: minY + h))
        pathPath.addLine(to: CGPoint(x:minX + 0.12 * w, y: minY + h))
        pathPath.addCurve(to: CGPoint(x:minX, y: minY + 0.85948 * h), controlPoint1:CGPoint(x:minX + 0.05373 * w, y: minY + h), controlPoint2:CGPoint(x:minX, y: minY + 0.93708 * h))
        pathPath.addLine(to: CGPoint(x:minX, y: minY + 0.26364 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.12 * w, y: minY + 0.12312 * h), controlPoint1:CGPoint(x:minX, y: minY + 0.18603 * h), controlPoint2:CGPoint(x:minX + 0.05373 * w, y: minY + 0.12312 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.20567 * w, y: minY + 0.12312 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.36285 * w, y: minY), controlPoint1:CGPoint(x:minX + 0.23116 * w, y: minY + 0.05085 * h), controlPoint2:CGPoint(x:minX + 0.29194 * w, y: minY))
        pathPath.addLine(to: CGPoint(x:minX + 0.63715 * w, y: minY))
        pathPath.addCurve(to: CGPoint(x:minX + 0.79433 * w, y: minY + 0.12312 * h), controlPoint1:CGPoint(x:minX + 0.70806 * w, y: minY), controlPoint2:CGPoint(x:minX + 0.76884 * w, y: minY + 0.05085 * h))
        pathPath.addLine(to: CGPoint(x:minX + 0.79433 * w, y: minY + 0.12312 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.27118 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.23204 * w, y: minY + 0.58498 * h), controlPoint1:CGPoint(x:minX + 0.35201 * w, y: minY + 0.27118 * h), controlPoint2:CGPoint(x:minX + 0.23204 * w, y: minY + 0.41167 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.89878 * h), controlPoint1:CGPoint(x:minX + 0.23204 * w, y: minY + 0.75828 * h), controlPoint2:CGPoint(x:minX + 0.35201 * w, y: minY + 0.89878 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.76796 * w, y: minY + 0.58498 * h), controlPoint1:CGPoint(x:minX + 0.64799 * w, y: minY + 0.89878 * h), controlPoint2:CGPoint(x:minX + 0.76796 * w, y: minY + 0.75828 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.27118 * h), controlPoint1:CGPoint(x:minX + 0.76796 * w, y: minY + 0.41167 * h), controlPoint2:CGPoint(x:minX + 0.64799 * w, y: minY + 0.27118 * h))
        pathPath.close()
        pathPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.36215 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.30971 * w, y: minY + 0.58498 * h), controlPoint1:CGPoint(x:minX + 0.39491 * w, y: minY + 0.36215 * h), controlPoint2:CGPoint(x:minX + 0.30971 * w, y: minY + 0.46191 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.80781 * h), controlPoint1:CGPoint(x:minX + 0.30971 * w, y: minY + 0.70805 * h), controlPoint2:CGPoint(x:minX + 0.39491 * w, y: minY + 0.80781 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.69029 * w, y: minY + 0.58498 * h), controlPoint1:CGPoint(x:minX + 0.60509 * w, y: minY + 0.80781 * h), controlPoint2:CGPoint(x:minX + 0.69029 * w, y: minY + 0.70805 * h))
        pathPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + 0.36215 * h), controlPoint1:CGPoint(x:minX + 0.69029 * w, y: minY + 0.46191 * h), controlPoint2:CGPoint(x:minX + 0.60509 * w, y: minY + 0.36215 * h))
        
        return pathPath
    }
    
    
}

class PlusIconPassThrough: PlusIcon {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
