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

    private var oval: CAShapeLayer!
    private var duration = 0.6
    var state: State = .On {
        didSet {
            if oval != nil {
                oval.strokeStart = state == .On ? 0 : 1
            }
            if roundIcon != nil, state == .Off {
                roundIcon.alpha = 0
                roundIcon.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            }
        }
    }
    var text = "" {
        didSet {
            roundIcon.icon.text = text
        }
    }
    var roundIcon: RoundIcon! {
        didSet {
            roundIcon.alpha = state == .On ? 1 : 0
        }
    }
    var category: SurveyCategoryIcon.CategoryID = .Anon
    var color: UIColor = K_COLOR_RED {
        didSet {
            roundIcon.color = color
            oval.strokeColor = color.withAlphaComponent(0.25).cgColor
        }
    }
    
    var layers = [String: CALayer]()
    var completionBlocks = [CAAnimation: (Bool) -> Void]()
    var updateLayerValueForCompletedAnimation : Bool = false
    
    //MARK: - Interface properties
    @IBInspectable var lineWidth: CGFloat = 5
    
    
    
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
        self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:0.0)
        
        oval = CAShapeLayer()
        self.layer.insertSublayer(oval, at: 1)//(oval)
        layers["oval"] = oval
        
        roundIcon = RoundIcon(frame: self.bounds)//getIcon(frame: self.bounds, category: category, color: color)
        self.addSubview(roundIcon)
        roundIcon.translatesAutoresizingMaskIntoConstraints = false
        roundIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        roundIcon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        roundIcon.heightAnchor.constraint(equalTo: roundIcon.widthAnchor, multiplier: 1.0/1.0).isActive = true
        roundIcon.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9/1.0).isActive = true
        roundIcon.icon = getIcon(frame: roundIcon.bounds, category: category, color: color, text: text, isFramed: false)
        
        resetLayerProperties(forLayerIdentifiers: nil)
        setupLayerFrames()
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
//            cornerRadius = bounds.size.height / 2
        }
    }
    
    func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if layerIds == nil || layerIds.contains("oval"){
            let oval = layers["oval"] as! CAShapeLayer
            oval.fillColor   = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0).cgColor
            oval.strokeColor = color.withAlphaComponent(0.25).cgColor//UIColor(red:0.404, green: 0.404, blue:0.404, alpha:1).cgColor
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
        UIView.animate(withDuration: 0.5) {
            self.roundIcon.transform = .identity
            self.roundIcon.alpha = 1
        }
        addEnableAnimation {
            _ in
            completionBlocks.map { $0() }
        }
    }

}
