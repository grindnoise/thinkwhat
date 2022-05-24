//
//  Popup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Popup: UIView {
    
    deinit {
        print("Popup deinit")
    }
    
    init(frame: CGRect, callbackDelegate: CallbackObservable?, bannerDelegate: BannerObservable?, heightScaleFactor _heightMultiplictator: CGFloat = 0.7) {
        self.heightScaleFactor = _heightMultiplictator
        super.init(frame: frame)
        self.callbackDelegate = callbackDelegate
        self.bannerDelegate = bannerDelegate
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor             = .clear
        bounds                      = UIScreen.main.bounds
        contentView.frame               = bounds
        contentView.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
        appDelegate.window?.addSubview(self)
        addSubview(contentView)
        
        //Set default height
        setNeedsLayout()
        height                      = UIScreen.main.bounds.height * heightScaleFactor//body.frame.width * heightScaleFactor
        heightConstraint.constant   = height
        centerYConstraint.constant  = yOrigin
        layoutIfNeeded()
        body.cornerRadius = body.frame.width * 0.07
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
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
//    @IBOutlet weak var centerYConstraint: NSLayoutConstraint! {
//        didSet {
//            centerYConstraint.constant = topMargin
//        }
//    }
    
    // MARK: - Properties
//    private var isFolded = false
    private let heightScaleFactor: CGFloat
    private var yOrigin:    CGFloat = 0
    private var height:     CGFloat = 0 {
        didSet {
            if oldValue != height {
                yOrigin = -(UIScreen.main.bounds.height/2 + height/2)
            }
        }
    }
    //Use for auto dismiss
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
        
        body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        bannerDelegate?.onBannerWillAppear(self)
        alpha = 1
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4,
            options: [.curveEaseInOut],
            animations: {
                self.setNeedsLayout()
                self.centerYConstraint.constant = 0
                self.layoutIfNeeded()
                self.body.transform = .identity
        }) {
            _ in
            self.bannerDelegate?.onBannerDidAppear(self)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.background.alpha = 1
        })
    }
    
    func dismiss(_ sender: Optional<Any> = nil) {
        bannerDelegate?.onBannerWillDisappear(self)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveLinear], animations: {
            self.background.alpha = 0
        }) {
            _ in
            self.accessibilityIdentifier = sender as? String
            self.bannerDelegate?.onBannerDidDisappear(self)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.setNeedsLayout()
            self.centerYConstraint.constant += abs(self.yOrigin)
            self.layoutIfNeeded()
            self.background.alpha = 0
            self.body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { _ in }
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

extension Popup: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if sender is VoteMessage {
            dismiss("vote")
        } else if let btn = sender as? UIButton {
            if btn.accessibilityIdentifier == "unsubscribe" {
                callbackDelegate?.callbackReceived(btn)
            }
            dismiss(btn.accessibilityIdentifier)// == "exit" ? "exit" : nil)
        } else if sender is Claim {
            callbackDelegate?.callbackReceived(sender)
        } else if let votersFilter = sender as? VotersFilter {
            callbackDelegate?.callbackReceived(votersFilter.getData())
            dismiss()
        }
    }
}

