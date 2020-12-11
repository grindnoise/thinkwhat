//
//  CustomSwitch.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.09.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

@IBDesignable
public class CustomSwitch: UIControl {
    
    // MARK: Public properties
    public var animationDelay: Double = 0
    public var animationSpriteWithDamping = CGFloat(0.7)
    public var initialSpringVelocity = CGFloat(0.5)
    public var animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions.curveEaseOut, UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.allowUserInteraction]
    
    @IBInspectable public var isOn:Bool = true {
        didSet {
            thumbView.setOn(isOn)
        }
    }
    
    public var animationDuration: Double = 0.5
    
    @IBInspectable  public var padding: CGFloat = 1 {
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable  public var onTintColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5) {//UIColor(red: 144/255, green: 202/255, blue: 119/255, alpha: 1) {
        didSet {
            self.setupUI()
        }
    }
    
    @IBInspectable public var offTintColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5) {//UIColor.black {
        didSet {
            self.setupUI()
        }
    }
    
//    @IBInspectable public var cornerRadius: CGFloat {
        override var cornerRadius: CGFloat {
        
        get {
            return self.privateCornerRadius
        }
        set {
            if newValue > 0.5 || newValue < 0.0 {
                privateCornerRadius = 0.5
            } else {
                privateCornerRadius = newValue
            }
        }
        
    }
    
    private var privateCornerRadius: CGFloat = 0.5 {
        didSet {
            self.layoutSubviews()
        }
    }
    
    // thumb properties
    @IBInspectable public var thumbTintColor: UIColor = K_COLOR_RED {//UIColor.white {
        didSet {
            self.thumbView.backgroundColor = self.thumbTintColor
        }
    }
    
    @IBInspectable public var thumbCornerRadius: CGFloat {
        get {
            return self.privateThumbCornerRadius
        }
        set {
            if newValue > 0.5 || newValue < 0.0 {
                privateThumbCornerRadius = 0.5
            } else {
                privateThumbCornerRadius = newValue
            }
        }
        
    }
    
    private var privateThumbCornerRadius: CGFloat = 0.5 {
        didSet {
            self.layoutSubviews()
            
        }
    }
    
    @IBInspectable public var thumbSize: CGSize = CGSize.zero {
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable public var thumbImage:UIImage? = nil {
        didSet {
            guard let image = thumbImage else {
                return
            }
//            thumbView.thumbImageView.image = image
        }
    }
    
    public var onImage:UIImage? {
        didSet {
            self.onImageView.image = onImage
            self.layoutSubviews()
            
        }
        
    }
    
    public var offImage:UIImage? {
        didSet {
            self.offImageView.image = offImage
            self.layoutSubviews()
        }
        
    }
    
    
    // dodati kasnije
    @IBInspectable public var thumbShadowColor: UIColor = UIColor.clear {//black {
        didSet {
            self.thumbView.layer.shadowColor = self.thumbShadowColor.cgColor
        }
    }
    
    @IBInspectable public var thumbShadowOffset: CGSize = CGSize(width: 0.75, height: 2) {
        didSet {
            self.thumbView.layer.shadowOffset = self.thumbShadowOffset
        }
    }
    
    @IBInspectable public var thumbShaddowRadius: CGFloat = 0 {//1.5 {
        didSet {
            self.thumbView.layer.shadowRadius = self.thumbShaddowRadius
        }
    }
    
    @IBInspectable public var thumbShaddowOppacity: Float = 0 {//0.4 {
        didSet {
            self.thumbView.layer.shadowOpacity = self.thumbShaddowOppacity
        }
    }
    
    // labels
    
    public var labelOff:UILabel = UILabel()
    public var labelOn:UILabel = UILabel()
    
    public var areLabelsShown: Bool = false {
        didSet {
            self.setupUI()
        }
    }
    
    var thumbView = CustomThumbView(frame: CGRect.zero)
    public var onImageView = UIImageView(frame: CGRect.zero)
    public var offImageView = UIImageView(frame: CGRect.zero)
    public var onPoint = CGPoint.zero
    public var offPoint = CGPoint.zero
    public var isAnimating = false
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
}

// MARK: Private methods
extension CustomSwitch {
    fileprivate func setupUI() {
        // clear self before configuration
        self.clear()
        
        self.clipsToBounds = false
        
        // configure thumb view
        self.thumbView.backgroundColor = self.thumbTintColor
        self.thumbView.isUserInteractionEnabled = false
        
        // dodati kasnije
        self.thumbView.layer.shadowColor = self.thumbShadowColor.cgColor
        self.thumbView.layer.shadowRadius = self.thumbShaddowRadius
        self.thumbView.layer.shadowOpacity = self.thumbShaddowOppacity
        self.thumbView.layer.shadowOffset = self.thumbShadowOffset
        
        self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
        
        self.addSubview(self.thumbView)
////        self.addSubview(self.onImageView)
////        self.addSubview(self.offImageView)
//        let new = CustomSwitchNewIcon(frame: thumbView.frame)
////        new.isOpaque = false
//        new.alpha = 0
//
//        let top = CustomSwitchTopIcon(frame: thumbView.frame)
////        top.isOpaque = false
//        top.alpha = 0
//
////        new.addEquallyTo(to: thumbView)
////        top.addEquallyTo(to: thumbView)
//
////        self.setupLabels()
//
        
    }
    
    
    private func clear() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        self.animate()
        return true
    }
    
    func setOn(on:Bool, animated:Bool) {
        
        switch animated {
        case true:
            self.animate(on: on)
        case false:
            self.isOn = on
            self.setupViewsOnAction()
            self.completeAction()
        }
    }
    
    fileprivate func animate(on:Bool? = nil) {
        self.isOn = on ?? !self.isOn
        
        self.isAnimating = true
        
        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [UIView.AnimationOptions.curveEaseOut, UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.allowUserInteraction], animations: {
            self.setupViewsOnAction()
            
        }, completion: { _ in
            self.completeAction()
        })
    }
    
    private func setupViewsOnAction() {
        self.thumbView.frame.origin.x = self.isOn ? self.onPoint.x : self.offPoint.x
        self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
        self.setOnOffImageFrame()
    }
    
    private func completeAction() {
        self.isAnimating = false
        self.sendActions(for: UIControl.Event.valueChanged)
    }
    
}

// Mark: Public methods
extension CustomSwitch {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.isAnimating {
            self.layer.cornerRadius = self.bounds.size.height * self.cornerRadius
            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            
            // thumb managment
            // get thumb size, if none set, use one from bounds
            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width: self.bounds.size.height*2.2, height: self.bounds.height*2.2)
            let yPostition = (self.bounds.size.height - thumbSize.height) / 2
            
            self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - self.padding, y: yPostition)
            self.offPoint = CGPoint(x: self.padding, y: yPostition)
            
            self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)
            self.thumbView.layer.cornerRadius = thumbSize.height * self.thumbCornerRadius
            
            
            //label frame
            if self.areLabelsShown {
                let labelWidth = self.bounds.width / 2 - self.padding * 2
                self.labelOn.frame = CGRect(x: 0, y: 0, width: labelWidth, height: self.frame.height)
                self.labelOff.frame = CGRect(x: self.frame.width - labelWidth, y: 0, width: labelWidth, height: self.frame.height)
            }
            
            // on/off images
            //set to preserve aspect ratio of image in thumbView
            
            guard onImage != nil && offImage != nil else {
                return
            }
            
            let frameSize = thumbSize.width > thumbSize.height ? thumbSize.height * 0.7 : thumbSize.width * 0.7
            
            let onOffImageSize = CGSize(width: frameSize, height: frameSize)
            
            
            self.onImageView.frame.size = onOffImageSize
            self.offImageView.frame.size = onOffImageSize
            
            self.onImageView.center = CGPoint(x: self.onPoint.x + self.thumbView.frame.size.width / 2, y: self.thumbView.center.y)
            self.offImageView.center = CGPoint(x: self.offPoint.x + self.thumbView.frame.size.width / 2, y: self.thumbView.center.y)
            
            
            self.onImageView.alpha = self.isOn ? 1.0 : 0.0
            self.offImageView.alpha = self.isOn ? 0.0 : 1.0
            
        }
    }
}

//Mark: Labels frame
extension CustomSwitch {
    
    fileprivate func setupLabels() {
        guard self.areLabelsShown else {
            self.labelOff.alpha = 0
            self.labelOn.alpha = 0
            return
            
        }
        
        self.labelOff.alpha = 1
        self.labelOn.alpha = 1
        
        let labelWidth = self.bounds.width / 2 - self.padding * 2
        self.labelOn.frame = CGRect(x: 0, y: 0, width: labelWidth, height: self.frame.height)
        self.labelOff.frame = CGRect(x: self.frame.width - labelWidth, y: 0, width: labelWidth, height: self.frame.height)
        self.labelOn.font = UIFont.boldSystemFont(ofSize: 12)
        self.labelOff.font = UIFont.boldSystemFont(ofSize: 12)
        self.labelOn.textColor = UIColor.white
        self.labelOff.textColor = UIColor.white
        
        self.labelOff.sizeToFit()
        self.labelOff.text = "Off"
        self.labelOn.text = "On"
        self.labelOff.textAlignment = .center
        self.labelOn.textAlignment = .center
        
        self.insertSubview(self.labelOff, belowSubview: self.thumbView)
        self.insertSubview(self.labelOn, belowSubview: self.thumbView)
        
    }
    
}

//Mark: Animating on/off images
extension CustomSwitch {
    
    fileprivate func setOnOffImageFrame() {
        guard onImage != nil && offImage != nil else {
            return
        }
        
        self.onImageView.center.x = self.isOn ? self.onPoint.x + self.thumbView.frame.size.width / 2 : self.frame.width
        self.offImageView.center.x = !self.isOn ? self.offPoint.x + self.thumbView.frame.size.width / 2 : 0
        self.onImageView.alpha = self.isOn ? 1.0 : 0.0
        self.offImageView.alpha = self.isOn ? 0.0 : 1.0
    }
    
}

class CustomThumbView: UIView {
    var animationDuration: Double = 0.3
//    fileprivate(set) var thumbImageView = UIImageView(frame: CGRect.zero)
    fileprivate(set) var newThumb = CustomSwitchNewIcon(frame: .zero)
    fileprivate(set) var topThumb = CustomSwitchTopIcon(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.addSubview(self.thumbImageView)
        newThumb.isOpaque = false
        topThumb.isOpaque = false
        topThumb.alpha = 0
        self.addSubview(self.newThumb)
        self.addSubview(self.topThumb)
//        thumb.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
//        thumb.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
//        self.addSubview(self.thumb)
        
//        thumb.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
//        thumb.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        
//        thumb.addEquallyTo(to: self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.addSubview(self.thumbImageView)
        newThumb.isOpaque = false
        topThumb.isOpaque = false
        topThumb.alpha = 0
        self.addSubview(self.newThumb)
        self.addSubview(self.topThumb)
        
//        thumb.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
//        thumb.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
//        self.addSubview(self.thumb)
//        thumb.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
//        thumb.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        
//        thumb.addEquallyTo(to: self)
    }
    
    
}

extension CustomThumbView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.thumbImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
//        self.thumb.layer.cornerRadius = self.layer.cornerRadius
//        self.thumbImageView.clipsToBounds = self.clipsToBounds
        self.newThumb.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.topThumb.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)//.size = CGSize(width: frame.width * 0.7, height: frame.height * 0.7)// = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
//        self.thumb.center = center
    }
    
    func setOn(_ isOn: Bool) {
        let revealView = isOn ? topThumb : newThumb
        let hideView = isOn ? newThumb : topThumb
        revealView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: animationDuration/2, delay: 0, options: [.curveEaseOut], animations: {
            hideView.alpha = 0
            hideView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in hideView.transform = .identity }
        UIView.animate(withDuration: animationDuration/2, delay: 0, options: [.curveEaseIn], animations: {
            revealView.alpha = 1
            revealView.transform = .identity
        })
    }
}

class CustomSwitchNewIcon: UIView {
    override func draw(_ rect: CGRect) {
        CustomSwitchStyleKit.drawIconNew(frame: rect, resizing: .aspectFit)
    }
}

class CustomSwitchTopIcon: UIView {
    override func draw(_ rect: CGRect) {
        CustomSwitchStyleKit.drawIconTop(frame: rect, resizing: .aspectFit)
    }
}

public class CustomSwitchStyleKit : NSObject {
    
    //// Drawing Methods
    
    @objc public dynamic class func drawIconNew(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 176, height: 176), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 176, height: 176), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 176, y: resizedFrame.height / 176)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        //// Group
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 83.39, y: 39.22))
        bezierPath.addCurve(to: CGPoint(x: 77.09, y: 44.75), controlPoint1: CGPoint(x: 82.45, y: 39.69), controlPoint2: CGPoint(x: 79.64, y: 42.19))
        bezierPath.addLine(to: CGPoint(x: 72.54, y: 49.42))
        bezierPath.addLine(to: CGPoint(x: 68.25, y: 48.95))
        bezierPath.addCurve(to: CGPoint(x: 53.41, y: 51.25), controlPoint1: CGPoint(x: 58.98, y: 47.93), controlPoint2: CGPoint(x: 55.07, y: 48.53))
        bezierPath.addCurve(to: CGPoint(x: 51.03, y: 63.28), controlPoint1: CGPoint(x: 52.22, y: 53.16), controlPoint2: CGPoint(x: 51.37, y: 57.5))
        bezierPath.addLine(to: CGPoint(x: 50.73, y: 68.09))
        bezierPath.addLine(to: CGPoint(x: 47.5, y: 70.25))
        bezierPath.addCurve(to: CGPoint(x: 37.25, y: 81.48), controlPoint1: CGPoint(x: 39.04, y: 75.95), controlPoint2: CGPoint(x: 37.25, y: 77.91))
        bezierPath.addCurve(to: CGPoint(x: 42.74, y: 92.75), controlPoint1: CGPoint(x: 37.25, y: 84.2), controlPoint2: CGPoint(x: 38.7, y: 87.13))
        bezierPath.addLine(to: CGPoint(x: 45.71, y: 96.83))
        bezierPath.addLine(to: CGPoint(x: 44.65, y: 100.4))
        bezierPath.addCurve(to: CGPoint(x: 42.35, y: 111.79), controlPoint1: CGPoint(x: 43.16, y: 105.5), controlPoint2: CGPoint(x: 42.35, y: 109.45))
        bezierPath.addCurve(to: CGPoint(x: 58.34, y: 121.61), controlPoint1: CGPoint(x: 42.35, y: 116.47), controlPoint2: CGPoint(x: 45.29, y: 118.3))
        bezierPath.addCurve(to: CGPoint(x: 61.27, y: 124.89), controlPoint1: CGPoint(x: 59.96, y: 122), controlPoint2: CGPoint(x: 60.17, y: 122.21))
        bezierPath.addCurve(to: CGPoint(x: 66.63, y: 135.26), controlPoint1: CGPoint(x: 63.19, y: 129.48), controlPoint2: CGPoint(x: 65.31, y: 133.6))
        bezierPath.addCurve(to: CGPoint(x: 81.17, y: 134.84), controlPoint1: CGPoint(x: 69.4, y: 138.75), controlPoint2: CGPoint(x: 72.76, y: 138.66))
        bezierPath.addLine(to: CGPoint(x: 87.04, y: 132.11))
        bezierPath.addLine(to: CGPoint(x: 91.8, y: 134.37))
        bezierPath.addCurve(to: CGPoint(x: 98.23, y: 137.17), controlPoint1: CGPoint(x: 94.44, y: 135.6), controlPoint2: CGPoint(x: 97.29, y: 136.88))
        bezierPath.addCurve(to: CGPoint(x: 105.33, y: 137.09), controlPoint1: CGPoint(x: 100.39, y: 137.98), controlPoint2: CGPoint(x: 103.75, y: 137.94))
        bezierPath.addCurve(to: CGPoint(x: 111.92, y: 126.71), controlPoint1: CGPoint(x: 107.03, y: 136.24), controlPoint2: CGPoint(x: 109.41, y: 132.41))
        bezierPath.addCurve(to: CGPoint(x: 115.45, y: 121.66), controlPoint1: CGPoint(x: 113.83, y: 122.29), controlPoint2: CGPoint(x: 114.04, y: 122))
        bezierPath.addCurve(to: CGPoint(x: 130.5, y: 115.62), controlPoint1: CGPoint(x: 126.16, y: 118.89), controlPoint2: CGPoint(x: 128.88, y: 117.79))
        bezierPath.addCurve(to: CGPoint(x: 129.52, y: 100.91), controlPoint1: CGPoint(x: 132.16, y: 113.32), controlPoint2: CGPoint(x: 131.9, y: 109.11))
        bezierPath.addLine(to: CGPoint(x: 128.33, y: 96.87))
        bezierPath.addLine(to: CGPoint(x: 131.56, y: 92.36))
        bezierPath.addCurve(to: CGPoint(x: 136.75, y: 81.48), controlPoint1: CGPoint(x: 135.56, y: 86.62), controlPoint2: CGPoint(x: 136.75, y: 84.16))
        bezierPath.addCurve(to: CGPoint(x: 126.5, y: 70.25), controlPoint1: CGPoint(x: 136.75, y: 77.99), controlPoint2: CGPoint(x: 134.92, y: 75.99))
        bezierPath.addLine(to: CGPoint(x: 123.27, y: 68.04))
        bezierPath.addLine(to: CGPoint(x: 122.97, y: 63.11))
        bezierPath.addCurve(to: CGPoint(x: 113.15, y: 48.49), controlPoint1: CGPoint(x: 122.25, y: 51), controlPoint2: CGPoint(x: 120.59, y: 48.49))
        bezierPath.addCurve(to: CGPoint(x: 105.75, y: 48.95), controlPoint1: CGPoint(x: 111.41, y: 48.49), controlPoint2: CGPoint(x: 108.09, y: 48.7))
        bezierPath.addLine(to: CGPoint(x: 101.54, y: 49.42))
        bezierPath.addLine(to: CGPoint(x: 96.69, y: 44.58))
        bezierPath.addCurve(to: CGPoint(x: 90.32, y: 39.01), controlPoint1: CGPoint(x: 94.06, y: 41.9), controlPoint2: CGPoint(x: 91.21, y: 39.39))
        bezierPath.addCurve(to: CGPoint(x: 83.39, y: 39.22), controlPoint1: CGPoint(x: 88.28, y: 38.03), controlPoint2: CGPoint(x: 85.47, y: 38.11))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()
        
    }
    
    @objc public dynamic class func drawIconTop(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 176, height: 176), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 176, height: 176), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 176, y: resizedFrame.height / 176)
        
        
        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        //// Group 2
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 91.46, y: 30.33))
        bezierPath.addCurve(to: CGPoint(x: 88.49, y: 38.26), controlPoint1: CGPoint(x: 89.54, y: 31.29), controlPoint2: CGPoint(x: 89.06, y: 32.55))
        bezierPath.addCurve(to: CGPoint(x: 73.34, y: 65.74), controlPoint1: CGPoint(x: 87.38, y: 48.37), controlPoint2: CGPoint(x: 82.88, y: 56.55))
        bezierPath.addLine(to: CGPoint(x: 68.73, y: 70.19))
        bezierPath.addLine(to: CGPoint(x: 68.88, y: 97.48))
        bezierPath.addLine(to: CGPoint(x: 69.02, y: 124.82))
        bezierPath.addLine(to: CGPoint(x: 70.65, y: 126.51))
        bezierPath.addCurve(to: CGPoint(x: 98.12, y: 129.71), controlPoint1: CGPoint(x: 73.67, y: 129.66), controlPoint2: CGPoint(x: 74.15, y: 129.71))
        bezierPath.addLine(to: CGPoint(x: 119.65, y: 129.71))
        bezierPath.addLine(to: CGPoint(x: 120.8, y: 128.55))
        bezierPath.addCurve(to: CGPoint(x: 127.23, y: 112.87), controlPoint1: CGPoint(x: 122.82, y: 126.51), controlPoint2: CGPoint(x: 124.73, y: 121.92))
        bezierPath.addCurve(to: CGPoint(x: 134.37, y: 72.9), controlPoint1: CGPoint(x: 133.46, y: 90.56), controlPoint2: CGPoint(x: 136, y: 76.44))
        bezierPath.addCurve(to: CGPoint(x: 116.68, y: 69.81), controlPoint1: CGPoint(x: 133.13, y: 70.05), controlPoint2: CGPoint(x: 132.69, y: 69.95))
        bezierPath.addLine(to: CGPoint(x: 102.01, y: 69.66))
        bezierPath.addLine(to: CGPoint(x: 102.87, y: 65.94))
        bezierPath.addCurve(to: CGPoint(x: 98.32, y: 31), controlPoint1: CGPoint(x: 106.99, y: 48.66), controlPoint2: CGPoint(x: 105.27, y: 35.36))
        bezierPath.addCurve(to: CGPoint(x: 91.46, y: 30.33), controlPoint1: CGPoint(x: 96.01, y: 29.6), controlPoint2: CGPoint(x: 93.38, y: 29.31))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 40.01, y: 70.68))
        bezier2Path.addCurve(to: CGPoint(x: 40.68, y: 102.03), controlPoint1: CGPoint(x: 38.77, y: 71.94), controlPoint2: CGPoint(x: 38.77, y: 71.02))
        bezier2Path.addCurve(to: CGPoint(x: 43.13, y: 128.74), controlPoint1: CGPoint(x: 42.07, y: 124.63), controlPoint2: CGPoint(x: 42.41, y: 127.92))
        bezier2Path.addCurve(to: CGPoint(x: 52.48, y: 129.71), controlPoint1: CGPoint(x: 43.94, y: 129.61), controlPoint2: CGPoint(x: 44.66, y: 129.71))
        bezier2Path.addCurve(to: CGPoint(x: 61.49, y: 129.13), controlPoint1: CGPoint(x: 58.38, y: 129.71), controlPoint2: CGPoint(x: 61.11, y: 129.51))
        bezier2Path.addCurve(to: CGPoint(x: 62.07, y: 100.92), controlPoint1: CGPoint(x: 61.92, y: 128.69), controlPoint2: CGPoint(x: 62.07, y: 121.77))
        bezier2Path.addCurve(to: CGPoint(x: 61.78, y: 72.23), controlPoint1: CGPoint(x: 62.07, y: 85.77), controlPoint2: CGPoint(x: 61.92, y: 72.86))
        bezier2Path.addCurve(to: CGPoint(x: 49.84, y: 69.71), controlPoint1: CGPoint(x: 61.2, y: 70.05), controlPoint2: CGPoint(x: 59.48, y: 69.71))
        bezier2Path.addCurve(to: CGPoint(x: 40.01, y: 70.68), controlPoint1: CGPoint(x: 41.59, y: 69.71), controlPoint2: CGPoint(x: 40.92, y: 69.76))
        bezier2Path.close()
        fillColor.setFill()
        bezier2Path.fill()
        
        context.restoreGState()
        
    }
    
    
    
    
    @objc public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
