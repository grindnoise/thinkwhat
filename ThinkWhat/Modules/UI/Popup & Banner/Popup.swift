//
//  Popup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
//import Combine

class Popup: UIView {
    
    // MARK: - Public properties

    
    
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

    
    
    // MARK: - Private properties
    private let heightScaleFactor: CGFloat
    private var yOrigin:    CGFloat = 0
    private var height:     CGFloat = 0 {
        didSet {
            if oldValue != height {
                yOrigin = -(UIScreen.main.bounds.height/2 + height/2)
            }
        }
    }
    private var originalContainerHeight = CGFloat.zero
    private var padding: CGFloat = 16
    private var isDismissing = false
    private var lastHeight: CGFloat = 0
    
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
    
    
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable?, bannerDelegate: BannerObservable?, heightScaleFactor: CGFloat = 0.7) {
        self.heightScaleFactor = heightScaleFactor
        
        super.init(frame: UIScreen.main.bounds)
        
        self.callbackDelegate = callbackDelegate
        self.bannerDelegate = bannerDelegate
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        body.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
    }
    
    
    
    // MARK: - Public methods
    public func present(content: UIView, isModal _isModal: Bool = false, dismissAfter seconds: TimeInterval = 0) {
        content.frame = container.frame
        content.addEquallyTo(to: container)
        content.setNeedsLayout()
        content.layoutIfNeeded()
        
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
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.75,
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
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.background.alpha = 1
        })
    }
    
    public func dismiss(_ sender: Optional<Any> = nil) {
        isDismissing = true
        bannerDelegate?.onBannerWillDisappear(self)
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveLinear], animations: {
            self.background.alpha = 0
        }) {
            _ in
            self.accessibilityIdentifier = sender as? String
            self.bannerDelegate?.onBannerDidDisappear(self)
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.setNeedsLayout()
            self.centerYConstraint.constant += abs(self.yOrigin)
            self.layoutIfNeeded()
            self.background.alpha = 0
            self.body.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { _ in }
    }
    
    public func onContainerHeightChange(_ height: CGFloat) {
        //        guard !isDismissing else { return }
        guard lastHeight != height else { return }
        lastHeight = height
        
        setNeedsLayout()
        self.height = min((height + padding*2), UIScreen.main.bounds.height * 0.8)//body.frame.width * heightScaleFactor
        heightConstraint.constant = self.height
        centerYConstraint.constant = yOrigin
        layoutIfNeeded()
    }
    
    public func resize(_ height: CGFloat, animationDuration: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0) {
            self.setNeedsLayout()
            self.heightConstraint.constant = height
            self.layoutIfNeeded()
        }
    }
    
}

private extension Popup {
    func commonInit() {
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
//        guard let constraint = container.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
        originalContainerHeight     = container.bounds.height//constraint.constant
    }
    
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    func updateTimer() {
        timeElapsed -= 0.5
        if timeElapsed <= 0 {
            dismiss()
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
        } else if sender is Topic {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if let votersFilter = sender as? VotersFilter {
            callbackDelegate?.callbackReceived(votersFilter.getData())
            dismiss()
        } else if let string = sender as? String {
//            if string == "exit" {
//
//            } else if string == "pop" {
//                accessibilityIdentifier = string
//            }
            dismiss(string)
        } else if sender is PollCreationController.Option {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is ImageItem {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is ChoiceItem {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is PollCreationController.Comments {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is Int {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is PollCreationController.Hot {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is VoteEducation {
            dismiss()
        }
    }
}

