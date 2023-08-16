//
//  MailButtonView.swift
//
//  Code generated using QuartzCode 1.66.4 on 25.07.2019.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class MailButtonView: LoginButton, CAAnimationDelegate {
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    var color : UIColor!
    var color1 : UIColor!
    var green : UIColor!
    var color2 : UIColor!
    var color3 : UIColor!
    
    //MARK: - Life Cycle
  override var state: Enums.EnabledState {
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
        self.color = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
        self.color1 = UIColor(red:1.00, green: 0.58, blue:0.00, alpha:1.0)
        self.green = UIColor(red:0.29, green: 0.564, blue:0.319, alpha:1)
        self.color2 = UIColor.black
        self.color3 = UIColor(red:0.805, green: 0.342, blue:0.339, alpha:1)
    }
    
    func setupLayers(){
        self.backgroundColor = UIColor(red:0, green: 0, blue:0, alpha:0)
        
        let oval = CAShapeLayer()
        self.layer.addSublayer(oval)
        layers["oval"] = oval
        
        let oval2 = CAShapeLayer()
        self.layer.addSublayer(oval2)
        layers["oval2"] = oval2
        
        let path2 = CAShapeLayer()
        self.layer.addSublayer(path2)
        layers["path2"] = path2
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("oval"){
            let oval = layers["oval"] as! CAShapeLayer
            oval.fillColor   = self.color2.cgColor
            oval.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("oval2"){
            let oval2 = layers["oval2"] as! CAShapeLayer
            oval2.opacity     = 0
            oval2.fillColor   = self.color3.cgColor
            oval2.strokeColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval2.lineWidth   = 0
        }
        if layerIds == nil || layerIds.contains("path2"){
            let path2 = layers["path2"] as! CAShapeLayer
            path2.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            path2.strokeColor = UIColor.black.cgColor
            path2.lineWidth   = 0
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let oval = layers["oval"] as? CAShapeLayer{
            oval.frame = CGRect(x: 0.015 * oval.superlayer!.bounds.width, y: 0.015 * oval.superlayer!.bounds.height, width: 0.97 * oval.superlayer!.bounds.width, height: 0.97 * oval.superlayer!.bounds.height)
            oval.path  = ovalPath(bounds: layers["oval"]!.bounds).cgPath
        }
        
        if let oval2 = layers["oval2"] as? CAShapeLayer{
            oval2.frame = CGRect(x: 0.015 * oval2.superlayer!.bounds.width, y: 0.015 * oval2.superlayer!.bounds.height, width: 0.97 * oval2.superlayer!.bounds.width, height: 0.97 * oval2.superlayer!.bounds.height)
            oval2.path  = oval2Path(bounds: layers["oval2"]!.bounds).cgPath
        }
        
        if let path2 = layers["path2"] as? CAShapeLayer{
            path2.frame = CGRect(x: 0.29373 * path2.superlayer!.bounds.width, y: 0.29275 * path2.superlayer!.bounds.height, width: 0.41351 * path2.superlayer!.bounds.width, height: 0.41352 * path2.superlayer!.bounds.height)
            path2.path  = path2Path(bounds: layers["path2"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }
    
    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.3
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Oval2 animation
        let oval2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        oval2OpacityAnim.values         = [0, 1]
        oval2OpacityAnim.keyTimes       = [0, 1]
        oval2OpacityAnim.duration       = 0.3
        oval2OpacityAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2 = layers["oval2"] as! CAShapeLayer
        
        let oval2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        oval2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DMakeScale(0.001, 0.001, 1)),
                                             NSValue(caTransform3D: CATransform3DIdentity)]
        oval2TransformAnim.keyTimes       = [0, 1]
        oval2TransformAnim.duration       = 0.3
        oval2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2EnableAnim : CAAnimationGroup = QCMethod.group(animations: [oval2OpacityAnim, oval2TransformAnim], fillMode:fillMode)
        oval2.add(oval2EnableAnim, forKey:"oval2EnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.3
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Oval2 animation
        let oval2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        oval2OpacityAnim.values         = [1, 1, 0]
        oval2OpacityAnim.keyTimes       = [0, 0.58, 1]
        oval2OpacityAnim.duration       = 0.3
        oval2OpacityAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2 = layers["oval2"] as! CAShapeLayer
        
        let oval2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
        oval2TransformAnim.values         = [NSValue(caTransform3D: CATransform3DIdentity),
                                             NSValue(caTransform3D: CATransform3DMakeScale(0.001, 0.001, 1))]
        oval2TransformAnim.keyTimes       = [0, 1]
        oval2TransformAnim.duration       = 0.3
        oval2TransformAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let oval2DisableAnim : CAAnimationGroup = QCMethod.group(animations: [oval2OpacityAnim, oval2TransformAnim], fillMode:fillMode)
        oval2.add(oval2DisableAnim, forKey:"oval2DisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval2"]!.animation(forKey: "oval2EnableAnim"), theLayer:layers["oval2"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval2"]!.animation(forKey: "oval2DisableAnim"), theLayer:layers["oval2"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["oval2"]?.removeAnimation(forKey: "oval2EnableAnim")
        }
        else if identifier == "disable"{
            layers["oval2"]?.removeAnimation(forKey: "oval2DisableAnim")
        }
    }
    
    override func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func ovalPath(bounds: CGRect) -> UIBezierPath{
        let ovalPath = UIBezierPath(ovalIn:bounds)
        return ovalPath
    }
    
    func oval2Path(bounds: CGRect) -> UIBezierPath{
        let oval2Path = UIBezierPath(ovalIn:bounds)
        return oval2Path
    }
    
    func path2Path(bounds: CGRect) -> UIBezierPath{
        let path2Path = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        path2Path.move(to: CGPoint(x:minX + 0.45389 * w, y: minY + 0.00267 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.01034 * w, y: minY + 0.39875 * h), controlPoint1:CGPoint(x:minX + 0.23739 * w, y: minY + 0.02201 * h), controlPoint2:CGPoint(x:minX + 0.05487 * w, y: minY + 0.18489 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.22567 * w, y: minY + 0.91817 * h), controlPoint1:CGPoint(x:minX + -0.03127 * w, y: minY + 0.59826 * h), controlPoint2:CGPoint(x:minX + 0.05516 * w, y: minY + 0.80714 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.71785 * w, y: minY + 0.9501 * h), controlPoint1:CGPoint(x:minX + 0.37362 * w, y: minY + 1.01455 * h), controlPoint2:CGPoint(x:minX + 0.55848 * w, y: minY + 1.02657 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.79315 * w, y: minY + 0.90294 * h), controlPoint1:CGPoint(x:minX + 0.74598 * w, y: minY + 0.93663 * h), controlPoint2:CGPoint(x:minX + 0.78494 * w, y: minY + 0.91231 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.78377 * w, y: minY + 0.81358 * h), controlPoint1:CGPoint(x:minX + 0.81483 * w, y: minY + 0.87833 * h), controlPoint2:CGPoint(x:minX + 0.81043 * w, y: minY + 0.83438 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.70291 * w, y: minY + 0.81534 * h), controlPoint1:CGPoint(x:minX + 0.76033 * w, y: minY + 0.79483 * h), controlPoint2:CGPoint(x:minX + 0.73397 * w, y: minY + 0.79542 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.57283 * w, y: minY + 0.86837 * h), controlPoint1:CGPoint(x:minX + 0.66541 * w, y: minY + 0.83936 * h), controlPoint2:CGPoint(x:minX + 0.61824 * w, y: minY + 0.8587 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.42635 * w, y: minY + 0.86837 * h), controlPoint1:CGPoint(x:minX + 0.53797 * w, y: minY + 0.87598 * h), controlPoint2:CGPoint(x:minX + 0.46121 * w, y: minY + 0.87598 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.23563 * w, y: minY + 0.76437 * h), controlPoint1:CGPoint(x:minX + 0.35106 * w, y: minY + 0.85225 * h), controlPoint2:CGPoint(x:minX + 0.28983 * w, y: minY + 0.81886 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.13162 * w, y: minY + 0.57365 * h), controlPoint1:CGPoint(x:minX + 0.18114 * w, y: minY + 0.71017 * h), controlPoint2:CGPoint(x:minX + 0.14774 * w, y: minY + 0.64894 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.13162 * w, y: minY + 0.42717 * h), controlPoint1:CGPoint(x:minX + 0.12401 * w, y: minY + 0.53879 * h), controlPoint2:CGPoint(x:minX + 0.12401 * w, y: minY + 0.46203 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.23563 * w, y: minY + 0.23646 * h), controlPoint1:CGPoint(x:minX + 0.14803 * w, y: minY + 0.3513 * h), controlPoint2:CGPoint(x:minX + 0.18055 * w, y: minY + 0.29153 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.37655 * w, y: minY + 0.14652 * h), controlPoint1:CGPoint(x:minX + 0.27957 * w, y: minY + 0.19251 * h), controlPoint2:CGPoint(x:minX + 0.32059 * w, y: minY + 0.16644 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.49959 * w, y: minY + 0.12718 * h), controlPoint1:CGPoint(x:minX + 0.4202 * w, y: minY + 0.13128 * h), controlPoint2:CGPoint(x:minX + 0.44598 * w, y: minY + 0.12718 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.62264 * w, y: minY + 0.14652 * h), controlPoint1:CGPoint(x:minX + 0.55321 * w, y: minY + 0.12718 * h), controlPoint2:CGPoint(x:minX + 0.57899 * w, y: minY + 0.13128 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.76356 * w, y: minY + 0.23646 * h), controlPoint1:CGPoint(x:minX + 0.67772 * w, y: minY + 0.16615 * h), controlPoint2:CGPoint(x:minX + 0.72078 * w, y: minY + 0.19339 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.87371 * w, y: minY + 0.49074 * h), controlPoint1:CGPoint(x:minX + 0.83504 * w, y: minY + 0.30764 * h), controlPoint2:CGPoint(x:minX + 0.86932 * w, y: minY + 0.38733 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.85555 * w, y: minY + 0.57512 * h), controlPoint1:CGPoint(x:minX + 0.87576 * w, y: minY + 0.54494 * h), controlPoint2:CGPoint(x:minX + 0.87313 * w, y: minY + 0.55754 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.75828 * w, y: minY + 0.56252 * h), controlPoint1:CGPoint(x:minX + 0.82684 * w, y: minY + 0.60412 * h), controlPoint2:CGPoint(x:minX + 0.77908 * w, y: minY + 0.59797 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.75008 * w, y: minY + 0.54875 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.74862 * w, y: minY + 0.43596 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.74217 * w, y: minY + 0.31438 * h), controlPoint1:CGPoint(x:minX + 0.74744 * w, y: minY + 0.33841 * h), controlPoint2:CGPoint(x:minX + 0.74656 * w, y: minY + 0.322 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.65867 * w, y: minY + 0.2889 * h), controlPoint1:CGPoint(x:minX + 0.72635 * w, y: minY + 0.28538 * h), controlPoint2:CGPoint(x:minX + 0.68768 * w, y: minY + 0.27366 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.63055 * w, y: minY + 0.31966 * h), controlPoint1:CGPoint(x:minX + 0.64696 * w, y: minY + 0.29505 * h), controlPoint2:CGPoint(x:minX + 0.63436 * w, y: minY + 0.30882 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.61326 * w, y: minY + 0.31497 * h), controlPoint1:CGPoint(x:minX + 0.62879 * w, y: minY + 0.32405 * h), controlPoint2:CGPoint(x:minX + 0.62703 * w, y: minY + 0.32376 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.545 * w, y: minY + 0.28626 * h), controlPoint1:CGPoint(x:minX + 0.59569 * w, y: minY + 0.30384 * h), controlPoint2:CGPoint(x:minX + 0.56639 * w, y: minY + 0.29153 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.4492 * w, y: minY + 0.28743 * h), controlPoint1:CGPoint(x:minX + 0.52362 * w, y: minY + 0.28128 * h), controlPoint2:CGPoint(x:minX + 0.47235 * w, y: minY + 0.28186 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.2866 * w, y: minY + 0.45002 * h), controlPoint1:CGPoint(x:minX + 0.36951 * w, y: minY + 0.30677 * h), controlPoint2:CGPoint(x:minX + 0.30594 * w, y: minY + 0.37034 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.2866 * w, y: minY + 0.5508 * h), controlPoint1:CGPoint(x:minX + 0.28045 * w, y: minY + 0.4758 * h), controlPoint2:CGPoint(x:minX + 0.28045 * w, y: minY + 0.52502 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.52479 * w, y: minY + 0.7172 * h), controlPoint1:CGPoint(x:minX + 0.31268 * w, y: minY + 0.65832 * h), controlPoint2:CGPoint(x:minX + 0.41756 * w, y: minY + 0.73156 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.6493 * w, y: minY + 0.65832 * h), controlPoint1:CGPoint(x:minX + 0.57078 * w, y: minY + 0.71105 * h), controlPoint2:CGPoint(x:minX + 0.61678 * w, y: minY + 0.68937 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.66278 * w, y: minY + 0.64543 * h))
        path2Path.addLine(to: CGPoint(x:minX + 0.6827 * w, y: minY + 0.66535 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.82625 * w, y: minY + 0.71837 * h), controlPoint1:CGPoint(x:minX + 0.71932 * w, y: minY + 0.70197 * h), controlPoint2:CGPoint(x:minX + 0.77674 * w, y: minY + 0.72306 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.94344 * w, y: minY + 0.663 * h), controlPoint1:CGPoint(x:minX + 0.87342 * w, y: minY + 0.71398 * h), controlPoint2:CGPoint(x:minX + 0.90975 * w, y: minY + 0.69669 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.99793 * w, y: minY + 0.46672 * h), controlPoint1:CGPoint(x:minX + 0.99178 * w, y: minY + 0.61467 * h), controlPoint2:CGPoint(x:minX + 1.00584 * w, y: minY + 0.56428 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.94754 * w, y: minY + 0.27981 * h), controlPoint1:CGPoint(x:minX + 0.99236 * w, y: minY + 0.39641 * h), controlPoint2:CGPoint(x:minX + 0.97625 * w, y: minY + 0.33694 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.54031 * w, y: minY + 0.00238 * h), controlPoint1:CGPoint(x:minX + 0.86815 * w, y: minY + 0.12103 * h), controlPoint2:CGPoint(x:minX + 0.71727 * w, y: minY + 0.0182 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.45389 * w, y: minY + 0.00267 * h), controlPoint1:CGPoint(x:minX + 0.50311 * w, y: minY + -0.00084 * h), controlPoint2:CGPoint(x:minX + 0.49256 * w, y: minY + -0.00084 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.53914 * w, y: minY + 0.41575 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.58455 * w, y: minY + 0.46086 * h), controlPoint1:CGPoint(x:minX + 0.5576 * w, y: minY + 0.42453 * h), controlPoint2:CGPoint(x:minX + 0.57518 * w, y: minY + 0.44211 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.59188 * w, y: minY + 0.50041 * h), controlPoint1:CGPoint(x:minX + 0.59041 * w, y: minY + 0.47287 * h), controlPoint2:CGPoint(x:minX + 0.59188 * w, y: minY + 0.4799 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.58192 * w, y: minY + 0.54377 * h), controlPoint1:CGPoint(x:minX + 0.59188 * w, y: minY + 0.52326 * h), controlPoint2:CGPoint(x:minX + 0.591 * w, y: minY + 0.52678 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.53944 * w, y: minY + 0.58478 * h), controlPoint1:CGPoint(x:minX + 0.57078 * w, y: minY + 0.56428 * h), controlPoint2:CGPoint(x:minX + 0.5617 * w, y: minY + 0.57306 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.49959 * w, y: minY + 0.59269 * h), controlPoint1:CGPoint(x:minX + 0.52655 * w, y: minY + 0.59152 * h), controlPoint2:CGPoint(x:minX + 0.52098 * w, y: minY + 0.59269 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.46004 * w, y: minY + 0.58537 * h), controlPoint1:CGPoint(x:minX + 0.47908 * w, y: minY + 0.59269 * h), controlPoint2:CGPoint(x:minX + 0.47205 * w, y: minY + 0.59123 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.41463 * w, y: minY + 0.53996 * h), controlPoint1:CGPoint(x:minX + 0.44129 * w, y: minY + 0.57629 * h), controlPoint2:CGPoint(x:minX + 0.42371 * w, y: minY + 0.55871 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.41463 * w, y: minY + 0.46086 * h), controlPoint1:CGPoint(x:minX + 0.40438 * w, y: minY + 0.51916 * h), controlPoint2:CGPoint(x:minX + 0.40438 * w, y: minY + 0.48225 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.47762 * w, y: minY + 0.4093 * h), controlPoint1:CGPoint(x:minX + 0.42694 * w, y: minY + 0.43567 * h), controlPoint2:CGPoint(x:minX + 0.45067 * w, y: minY + 0.41633 * h))
        path2Path.addCurve(to: CGPoint(x:minX + 0.53914 * w, y: minY + 0.41575 * h), controlPoint1:CGPoint(x:minX + 0.49344 * w, y: minY + 0.4052 * h), controlPoint2:CGPoint(x:minX + 0.52332 * w, y: minY + 0.40842 * h))
        path2Path.close()
        path2Path.move(to: CGPoint(x:minX + 0.53914 * w, y: minY + 0.41575 * h))
        
        return path2Path
    }
    
    
}
