//
//  CircleButton.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 09.03.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
class CircleButton: UIView, CAAnimationDelegate {
    
    enum State {
        case On, Off
    }

    var oval: CAShapeLayer!
    var iconProportionConstraint = NSLayoutConstraint()
    var scaleColorAnim: CAAnimationGroup?
    
    private var duration = 0.6
    var state: State = .On {
        didSet {
            oval.strokeStart = state == .On ? 0 : 1
        }
    }
    var text = "" {
        didSet {
            icon.text = text
        }
    }
    var icon: SurveyCategoryIcon! {
        didSet {
            icon.alpha = state == .On ? 1 : 0
        }
    }
    var category: SurveyCategoryIcon.Category = .Anon {
        didSet {
            icon.category = category
        }
    }
    var color: UIColor = K_COLOR_RED {
        didSet {
            icon.backgroundColor = color
            oval.strokeColor = color.withAlphaComponent(0.3).cgColor
        }
    }
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    //MARK: - Interface properties
    @IBInspectable var lineWidth: CGFloat = 5 {
        didSet {
            if oldValue != lineWidth {
                oval.lineWidth = lineWidth
            }
        }
    }
    
    
    
    //MARK: - Interface connections
    @IBOutlet var contentView: UIView!
//    @IBOutlet weak var icon: SurveyCategoryIcon! {
//        didSet {
////            icon.layer.zPosition = 3
////            layer.insertSublayer(icon.layer, at: 2)
//        }
//    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("CircleButton", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear//UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0)
        
        oval = CAShapeLayer()
        self.layer.insertSublayer(oval, at: 1)//(oval)
        layers["oval"] = oval
        
        icon = SurveyCategoryIcon.getIcon(frame: .zero, category: .Outdoor/*category*/, backgroundColor: color, text: text)//SurveyCategoryIcon(frame: self.bounds)//getIcon(frame: self.bounds, category: category, color: color)
        self.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1.0/1.0).isActive = true
        iconProportionConstraint = icon.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.79/1.0)
        iconProportionConstraint.isActive = true
//        icon.text = text
//        icon.backgroundColor = color
//        icon.category = category
//        roundIcon.icon = getIcon(frame: roundIcon.bounds, category: category, color: color, text: text, isFramed: false)
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
        clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(CircleButton.lineWidthChanged(_:)), name: Notifications.UI.LineWidth, object: nil)
    }
    
    override var frame: CGRect{
        didSet{
            setupLayerFrames()
            cornerRadius = bounds.size.height / 2
        }
    }
    
    override var bounds: CGRect{
        didSet{
            setupLayerFrames()
            cornerRadius = bounds.size.height / 2
        }
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("oval"){
            let oval = layers["oval"] as! CAShapeLayer
            oval.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval.strokeColor = color.withAlphaComponent(0.3).cgColor//UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
            oval.lineWidth   = lineWidth
            oval.strokeStart = 1
        }
        
        CATransaction.commit()
    }
    
    func setupLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if let oval = layers["oval"] as? CAShapeLayer{
            oval.frame = CGRect(x: 0.025 * oval.superlayer!.bounds.width, y: 0.025 * oval.superlayer!.bounds.height, width: 0.95 * oval.superlayer!.bounds.width, height: 0.95 * oval.superlayer!.bounds.height)
            oval.path  = ovalPath(bounds: layers["oval"]!.bounds).cgPath
        }
        
        CATransaction.commit()
    }

    //MARK: - Animation Setup
    
    func addEnableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.4
            completionAnim.delegate = self
            completionAnim.setValue("enable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"enable")
            if let anim = layer.animation(forKey: "enable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Oval animation
        let ovalStrokeStartAnim            = CAKeyframeAnimation(keyPath:"strokeStart")
        ovalStrokeStartAnim.values         = [1, 0]
        ovalStrokeStartAnim.keyTimes       = [0, 1]
        ovalStrokeStartAnim.duration       = duration
        ovalStrokeStartAnim.timingFunction = CAMediaTimingFunction(name:.easeInEaseOut)
        
        let ovalEnableAnim : CAAnimationGroup = QCMethod.group(animations: [ovalStrokeStartAnim], fillMode:fillMode)
        layers["oval"]?.add(ovalEnableAnim, forKey:"ovalEnableAnim")
    }
    
    func addDisableAnimation(completionBlock: ((_ finished: Bool) -> Void)? = nil){
        if completionBlock != nil{
            let completionAnim = CABasicAnimation(keyPath:"completionAnim")
            completionAnim.duration = 0.6
            completionAnim.delegate = self
            completionAnim.setValue("disable", forKey:"animId")
            completionAnim.setValue(false, forKey:"needEndAnim")
            layer.add(completionAnim, forKey:"disable")
            if let anim = layer.animation(forKey: "disable"){
                completionBlocks[anim] = completionBlock
            }
        }
        
        let fillMode : CAMediaTimingFillMode = .forwards
        
        ////Oval animation
        let ovalStrokeStartAnim            = CAKeyframeAnimation(keyPath:"strokeStart")
        ovalStrokeStartAnim.values         = [0, 1]
        ovalStrokeStartAnim.keyTimes       = [0, 1]
        ovalStrokeStartAnim.duration       = duration
        ovalStrokeStartAnim.timingFunction = CAMediaTimingFunction(name:.easeIn)
        
        let ovalDisableAnim : CAAnimationGroup = QCMethod.group(animations: [ovalStrokeStartAnim], fillMode:fillMode)
        layers["oval"]?.add(ovalDisableAnim, forKey:"ovalDisableAnim")
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
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval"]!.animation(forKey: "ovalEnableAnim"), theLayer:layers["oval"]!)
        }
        else if identifier == "disable"{
            QCMethod.updateValueFromPresentationLayer(forAnimation: layers["oval"]!.animation(forKey: "ovalDisableAnim"), theLayer:layers["oval"]!)
        }
    }
    
    func removeAnimations(forAnimationId identifier: String){
        if identifier == "enable"{
            layers["oval"]?.removeAnimation(forKey: "ovalEnableAnim")
        }
        else if identifier == "disable"{
            layers["oval"]?.removeAnimation(forKey: "ovalDisableAnim")
        }
    }
    
    func removeAllAnimations(){
        for layer in layers.values{
            layer.removeAllAnimations()
        }
    }
    
    //MARK: - Bezier Path
    
    func ovalPath(bounds: CGRect) -> UIBezierPath{
        let ovalPath = UIBezierPath()
        let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
        
        ovalPath.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
        ovalPath.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
        ovalPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
        ovalPath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
        ovalPath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
        
        return ovalPath
    }

    func present(completionBlocks: [Closure]) {
        
//        if icon != nil, state == .Off {
        icon.alpha = 0
        icon.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        icon.backgroundColor = .lightGray
        UIView.animate(withDuration: 0.5) {
            self.icon.transform = .identity
            self.icon.alpha = 1
            self.icon.backgroundColor = self.color
        }
        addEnableAnimation {
            _ in
            completionBlocks.map { $0() }
        }
    }
    
    @objc private func lineWidthChanged(_ notification: Notification) {
        if let lineWidth = notification.object as? CGFloat {
            oval.lineWidth = lineWidth
        }
    }
    
    func bounce(animationDelegate: CAAnimationDelegate?) {
      
        if scaleColorAnim == nil {
            let colorA = CABasicAnimation(keyPath: "backgroundColor")
            colorA.fromValue = K_COLOR_RED.cgColor
            colorA.toValue = K_COLOR_RED.darker(0.15).cgColor
            let scaleA = CABasicAnimation(keyPath: "transform.scale")
            scaleA.fromValue = 1
            scaleA.toValue = CATransform3DMakeScale(1.1, 1.1, 1)
            scaleColorAnim = CAAnimationGroup()
            scaleColorAnim?.animations = [colorA, scaleA]
            scaleColorAnim?.duration = 0.75
            scaleColorAnim?.isRemovedOnCompletion = true
            scaleColorAnim?.autoreverses = true
            scaleColorAnim?.delegate = animationDelegate
        }
        
        if scaleColorAnim != nil {
            self.icon.layer.add(scaleColorAnim!, forKey: nil)
        }
        
    }
    
    func animateIconChange(toCategory: SurveyCategoryIcon.Category) {
        
        let pathAnim = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path!, toValue: (icon.getLayer(toCategory) as! CAShapeLayer).path!, duration: 0.5, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: icon, isRemovedOnCompletion: false)
        pathAnim.setValue(toCategory, forKey: "toCategory")
        icon.icon.add(pathAnim, forKey: nil)
        
    }
}

