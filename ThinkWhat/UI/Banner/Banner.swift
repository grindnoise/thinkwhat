//
//  CostDetailBanner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class Banner: UIView {
    static let bannerWillAppearSignal       = "bannerWillAppearSignal"
    static let bannerDidAppearSignal        = "bannerDidAppearSignal"
    static let bannerWillDisappearSignal    = "bannerWillDisappearSignal"
    static let bannerDidDisappearSignal     = "bannerDidDisappearSignal"
    enum ContentType: Int {
        case None, TotaLCost, Sum, Warning, SideApp
    }
    //Use for auto dismiss
    private var timer:  Timer?
    private var timeElapsed: TimeInterval = 0
    private var isModal = false
    private var isVisible = false
    private var isInteracting = false {
        didSet {
            if isInteracting {
                stopTimer()
            }
        }
    }
    static let shared = Banner()
    var contentType: ContentType = .None {
        didSet {
            if oldValue != contentType {
                container.subviews.forEach { $0.removeFromSuperview() }
                var _content: BannerContent!
                switch contentType {
                case .TotaLCost:
                    _content = TotalCost.init(width: container.frame.width)
                case .Warning:
                    _content = Warning.init(width: container.frame.width)
                case .Sum:
                    _content = VotesFormula.init(width: container.frame.width)
                case .SideApp:
                    _content = SideApp.init(width: container.frame.width)
                default:
                    print("ContentType.None")
                }
                container.addSubview(_content as! UIView)
                (_content as! UIView).setNeedsLayout()
                (_content as! UIView).layoutIfNeeded()
                heightConstraint.constant = _content.minHeigth + topMargin*2
                content = _content
            }
        }
    }
    var content: BannerContent?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            background.alpha = 0
        }
    }
    @IBOutlet weak var body: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.constant = topMargin
        }
    }
//    private var isFolded = false
    private let topMargin:  CGFloat = 8
    private var yOrigin:    CGFloat = 0
    private var height:     CGFloat = 0 {
        didSet {
            if oldValue != height {
                yOrigin = -(height+topMargin)
            }
        }
    }
    private var keyWindow:  UIWindow!
    private weak var delegate : CallbackDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not for XIB/NIB")
    }
    
    private init() {
        super.init(frame: UIScreen.main.bounds)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Banner", owner: self, options: nil)
        guard let content = contentView, let _keyWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow else {
            return
        }
        backgroundColor             = .clear
        bounds                      = UIScreen.main.bounds
        content.frame               = bounds
        content.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
        keyWindow = _keyWindow
        keyWindow.addSubview(self)
        addSubview(content)
        
        //Set default height
        setNeedsLayout()
        height                      = content.bounds.width/3
        heightConstraint.constant   = height
        topConstraint.constant      = -(topConstraint.constant + height)
        layoutIfNeeded()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(recognizer:)))
        body.addGestureRecognizer(gestureRecognizer)
    }
    
    func present(isModal _isModal: Bool = false, shouldDismissAfter seconds: TimeInterval = 0, delegate _delegate: CallbackDelegate?) {
        isInteracting = false
        isModal       = _isModal
        if seconds != 0 {
            timeElapsed = seconds + 1
            startTimer()
        }
        delegate = _delegate
        delegate?.callbackReceived(Banner.bannerWillAppearSignal as AnyObject)
        alpha = 1
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4,
            options: [.curveEaseInOut],
            animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.topMargin
                self.layoutIfNeeded()
        }) {
            _ in
            self.delegate?.callbackReceived(Banner.bannerDidAppearSignal as AnyObject)
            self.isVisible = true
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.background.alpha = 1
        })
    }
    
    func dismiss(completion: @escaping (Bool) -> ()) {
        self.delegate?.callbackReceived(Banner.bannerWillDisappearSignal as AnyObject)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.setNeedsLayout()
            self.topConstraint.constant = self.yOrigin
            self.layoutIfNeeded()
            self.background.alpha = 0
        }) {
            _ in
            self.delegate?.callbackReceived(Banner.bannerDidDisappearSignal as AnyObject)
            self.delegate = nil
            self.isVisible = false
            self.alpha = 0
            completion(true)
        }
    }
    
    func unfold() {
        if let subview = container?.subviews.first as? BannerContent, subview.foldable, let maxHeight = subview.maxHeigth as? CGFloat {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.heightConstraint.constant = maxHeight + self.topMargin*2
                self.layoutIfNeeded()
            }) {
                _ in
                self.height = self.heightConstraint.constant
            }
        }
    }
    
    func fold() {
        if let subview = container?.subviews.first as? BannerContent, subview.foldable, let minHeight = subview.minHeigth as? CGFloat {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.heightConstraint.constant = minHeight + self.topMargin*2
                self.layoutIfNeeded()
            }) {
                _ in
                self.height = self.heightConstraint.constant
            }
        }
    }
    
    @objc private func viewPanned(recognizer: UIPanGestureRecognizer) {
        guard !isModal else {
            return
        }
        isInteracting = true
        let minConstant = -(height+topMargin)
        guard topConstraint.constant <= topMargin else {
            return
        }
        let yTranslation = recognizer.translation(in: contentView).y
        topConstraint.constant += yTranslation
        
        if yTranslation > 0 {
            topConstraint.constant = min(topConstraint.constant, topMargin)
        }
        topConstraint.constant = topConstraint.constant < minConstant ? minConstant : topConstraint.constant
        
        recognizer.setTranslation(.zero, in: contentView)
        var yPoint = convert(body.frame.origin, to: contentView).y + height
        yPoint = yPoint < 0 ? 0 : yPoint
        background.alpha = yPoint/(height+topMargin)

        guard recognizer.state == .ended else {
            return
        }

        let yVelocity = recognizer.velocity(in: contentView).y
        let distance = abs(yOrigin) - abs(yPoint)
        if yVelocity < -500 {
            delegate?.callbackReceived(Banner.bannerWillDisappearSignal as AnyObject)
            let time = TimeInterval(distance/abs(yVelocity)*2.5)
            let duration: TimeInterval = time < 0.08 ? 0.08 : time
            UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) {
                _ in
                self.alpha = 0
                self.delegate?.callbackReceived(Banner.bannerDidDisappearSignal as AnyObject)
            }
        } else if background.alpha > 0.33 {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.topMargin
                self.layoutIfNeeded()
                self.background.alpha = 1
            })
        } else {
            delegate?.callbackReceived(Banner.bannerWillDisappearSignal as AnyObject)
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) {
                _ in
                self.alpha = 0
                self.delegate?.callbackReceived(Banner.bannerDidDisappearSignal as AnyObject)
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func updateTimer() {
        timeElapsed    -= 1
        if timeElapsed <= 0 {
            dismiss() {_ in}
        }
    }
}
