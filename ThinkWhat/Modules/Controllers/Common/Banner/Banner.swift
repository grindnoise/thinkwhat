//
//  Banner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Banner: UIView {
    
    deinit {
        print("Banner deinit")
    }
    
    init(frame: CGRect, callbackDelegate: CallbackObservable?, bannerDelegate: BannerObservable?, heightDivisor _heightDivisor: CGFloat = 3.05) {
        super.init(frame: frame)
        self.callbackDelegate = callbackDelegate
        self.bannerDelegate = bannerDelegate
        self.heightDivisor = _heightDivisor
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor                 = .clear
        bounds                          = UIScreen.main.bounds
        contentView.frame               = bounds
        contentView.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
        appDelegate.window?.addSubview(self)
        addSubview(contentView)
        
        //Set default height
        setNeedsLayout()
        height                      = contentView.bounds.width/heightDivisor
        heightConstraint.constant   = height
        topConstraint.constant      = yOrigin//-(topConstraint.constant + height)
        layoutIfNeeded()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(recognizer:)))
        body.addGestureRecognizer(gestureRecognizer)
        body.cornerRadius = body.frame.width * 0.05
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            background.alpha = 0
        }
    }
    @IBOutlet weak var body: UIView! {
        didSet {
            body.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .secondarySystemBackground
                default:
                    return .systemBackground
                }
            }
        }
    }
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.constant = topMargin
        }
    }
    
    // MARK: - Properties
    ///Geometry
    private var heightDivisor:  CGFloat = .zero
    private let topMargin:      CGFloat = 8
    private var yOrigin:        CGFloat = 0
    private var height:         CGFloat = 0 {
        didSet {
            if oldValue != height {
                yOrigin = -(height*1.5+topMargin)
            }
        }
    }
    ///Auto dismiss
    private var timer:  Timer?
    private var timeElapsed: TimeInterval = 0
    private var isModal = false
    private var isInteracting = false {
        didSet {
            if isInteracting {
                stopTimer()
            }
        }
    }
    
    ///Delegates
    private weak var callbackDelegate : CallbackObservable?
    private weak var bannerDelegate: BannerObservable?
    
    func present(subview: UIView, isModal _isModal: Bool = false, shouldDismissAfter seconds: TimeInterval = 0) {
        subview.frame = container.frame
        subview.addEquallyTo(to: container)
        subview.setNeedsLayout()
        subview.layoutIfNeeded()
        
        isInteracting = false
        isModal       = _isModal
        if seconds != 0 {
            timeElapsed = seconds + 1
            startTimer()
        }

        bannerDelegate?.onBannerWillAppear(self)
        alpha = 1
        UIView.animate(
            withDuration: 0.5,
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
            self.bannerDelegate?.onBannerDidAppear(self)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.background.alpha = 1
        })
    }
    
    func dismiss() {
        bannerDelegate?.onBannerWillDisappear(self)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.setNeedsLayout()
            self.topConstraint.constant = self.yOrigin
            self.layoutIfNeeded()
            self.background.alpha = 0
        }) {
            _ in
            self.bannerDelegate?.onBannerDidDisappear(self)
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
            bannerDelegate?.onBannerWillDisappear(self)
            let time = TimeInterval(distance/abs(yVelocity)*2.5)
            let duration: TimeInterval = time < 0.08 ? 0.08 : time
            UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) {
                _ in
                self.bannerDelegate?.onBannerDidDisappear(self)
            }
        } else if background.alpha > 0.33 {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.topMargin
                self.layoutIfNeeded()
                self.background.alpha = 1
            })
        } else {
            bannerDelegate?.onBannerWillDisappear(self)
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) {
                _ in
                self.bannerDelegate?.onBannerDidDisappear(self)
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func updateTimer() {
        timeElapsed -= 0.5
        if timeElapsed <= 0 {
            dismiss()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.body.backgroundColor = .tertiarySystemBackground
        default:
            self.body.backgroundColor = .systemBackground
        }
    }
}

func showBanner(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, text: String, imageContent: UIView, color: UIColor = .systemRed, isModal: Bool = false, shouldDismissAfter: TimeInterval = 1, accessibilityIdentifier: String = "") {
    let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
    banner.accessibilityIdentifier = accessibilityIdentifier
    banner.present(subview: PlainBannerContent(text: text, imageContent: imageContent, color: color), isModal: isModal, shouldDismissAfter: shouldDismissAfter)
}
//
//func showPopup(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, subview: UIView, color: UIColor = .systemRed, isModal: Bool = true, shouldDismissAfter: TimeInterval = 1, accessibilityIdentifier: String = "", callbackPassthrough: Bool = false) {
//    let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
//    banner.accessibilityIdentifier = accessibilityIdentifier
//    banner.present(subview: subview)
//}


func showPopup<C: UIView>(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, subview: C, isModal: Bool = true, shouldDismissAfter: TimeInterval = .infinity, accessibilityIdentifier: String = "") where C:CallbackCallable {
    let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
    banner.accessibilityIdentifier = accessibilityIdentifier
    subview.callbackDelegate = banner
    banner.present(subview: subview)
}
