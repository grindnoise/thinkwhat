//
//  Banner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class Banner: UIView {
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.layer.masksToBounds = false
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            guard shadowed else { return }
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOffset = .zero
            shadowView.publisher(for: \.bounds, options: .new)
                .sink { [weak self] in
                    guard let self = self else { return }
                    
                    self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0,
                                                                    cornerRadius: $0.width*0.025).cgPath
                }
                .store(in: &subscriptions)
        }
    }
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = fadeBackground ? UIColor.black.withAlphaComponent(0.8) : .clear
            background.alpha = 0
        }
    }
    @IBOutlet weak var coloredBackround: UIView! {
        didSet {
            coloredBackround.backgroundColor = color//traitCollection.userInterfaceStyle == .dark ? .clear : color
        }
    }
    @IBOutlet weak var body: UIView! {
        didSet {
            body.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBackground : .tertiarySystemBackground
        }
    }
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.constant = topMargin
        }
    }
    
    
    
    // MARK: - Public properties
    public let willAppearPublisher = PassthroughSubject<Bool, Never>()
    public let didAppearPublisher = PassthroughSubject<Bool, Never>()
    public let willDisappearPublisher = PassthroughSubject<Bool, Never>()
    public let didDisappearPublisher = PassthroughSubject<Bool, Never>()
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let fadeBackground: Bool
    ///Geometry
    private var heightDivisor:  CGFloat = .zero
    private let topMargin:      CGFloat = 0
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
    private var shadowed: Bool
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
    private var color: UIColor = .clear
    
    
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    init(frame: CGRect = UIScreen.main.bounds,
         callbackDelegate: CallbackObservable? = nil,
         bannerDelegate: BannerObservable? = nil,
         backgroundColor: UIColor = .clear,
         heightDivisor _heightDivisor: CGFloat = 5,
         fadeBackground: Bool,
         shadowed: Bool = true) {

        self.fadeBackground = fadeBackground
        self.shadowed = shadowed
        
        super.init(frame: frame)
        
        self.callbackDelegate = callbackDelegate
        self.bannerDelegate = bannerDelegate
        self.heightDivisor = _heightDivisor
        self.color = backgroundColor
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func setupUI() {
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
        body.cornerRadius = body.frame.width * 0.025
    }
    
    
    
    func present(content: UIView, isModal _isModal: Bool = false, dismissAfter seconds: TimeInterval = 0) {
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

        bannerDelegate?.onBannerWillAppear(self)
        willAppearPublisher.send(true)
        
        alpha = 1
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.4,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.setNeedsLayout()
                self.topConstraint.constant = self.topMargin
                self.layoutIfNeeded()
        }) {
            _ in
            self.bannerDelegate?.onBannerDidAppear(self)
            self.didAppearPublisher.send(true)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.background.alpha = 1
        })
    }
    
    func dismiss() {
        bannerDelegate?.onBannerWillDisappear(self)
        willDisappearPublisher.send(true)

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            
            self.setNeedsLayout()
            self.topConstraint.constant = self.yOrigin
            self.layoutIfNeeded()
            self.background.alpha = 0
        }) { [weak self] _ in
            guard let self = self else { return }
            
            self.bannerDelegate?.onBannerDidDisappear(self)
            self.didDisappearPublisher.send(true)
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
            willDisappearPublisher.send(true)
            
            let time = TimeInterval(distance/abs(yVelocity)*2.5)
            let duration: TimeInterval = time < 0.08 ? 0.08 : time
            UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: { [weak self] in
                guard let self = self else { return }
                
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) { [weak self] _ in
                guard let self = self else { return }
                
                self.bannerDelegate?.onBannerDidDisappear(self)
                self.didDisappearPublisher.send(true)
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
            willDisappearPublisher.send(true)

            
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                
                self.setNeedsLayout()
                self.topConstraint.constant = self.yOrigin
                self.layoutIfNeeded()
                self.background.alpha = 0
            }) { [weak self] _ in
                guard let self = self else { return }
                
                self.bannerDelegate?.onBannerDidDisappear(self)
                self.didDisappearPublisher.send(true)
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
            stopTimer()
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

extension Banner: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if sender is URL {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if let string = sender as? String {
            if string == "dismiss" {
                dismiss()
            }
        } else if sender is UIImage {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        } else if sender is SideAppPreference {
            callbackDelegate?.callbackReceived(sender)
            dismiss()
        }
    }
}

func showBanner(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, text: String, content: UIView, color: UIColor = .systemRed, textColor: UIColor = .label, isModal: Bool = false, dismissAfter: TimeInterval = 1, backgroundColor: UIColor = . clear, identifier: String = "", fadeBackground: Bool = false, shadowed: Bool = true) {
    let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate, backgroundColor: backgroundColor, fadeBackground: fadeBackground, shadowed: shadowed)
    banner.accessibilityIdentifier = identifier
    banner.present(content: PlainBannerContent(text: text, imageContent: content, color: color, textColor: textColor), isModal: isModal, dismissAfter: dismissAfter)
}
//
//func showPopup(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, subview: UIView, color: UIColor = .systemRed, isModal: Bool = true, shouldDismissAfter: TimeInterval = 1, accessibilityIdentifier: String = "", callbackPassthrough: Bool = false) {
//    let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
//    banner.accessibilityIdentifier = accessibilityIdentifier
//    banner.present(subview: subview)
//}


func showPopup<C: UIView>(callbackDelegate: CallbackObservable? = nil, bannerDelegate: BannerObservable, subview: C, isModal: Bool = true, shouldDismissAfter: TimeInterval = .infinity, accessibilityIdentifier: String = "") where C:CallbackCallable {
    let banner = Popup(callbackDelegate: callbackDelegate, bannerDelegate: bannerDelegate)
    banner.accessibilityIdentifier = accessibilityIdentifier
    subview.callbackDelegate = banner
    banner.present(content: subview)
}

func showTip(delegate: BannerObservable, identifier: String, force: Bool = false, timeout: TimeInterval = 2) {
    guard  force || UserDefaults.App.hasSeenAppIntroduction.isNil else { return }
    guard identifier == "choices_tip" ||
    identifier == "description_tip" ||
    identifier == "url_tip" ||
    identifier == "images_tip" ||
    identifier == "limits_tip" ||
    identifier == "question_tip" ||
    identifier == "hot_tip" else { return }
    var color = K_COLOR_TABBAR
    var imageView = UIImageView(image: UIImage(systemName: "info.circle.fill"))
    if identifier == "hot_tip" {
        color = .systemRed
        imageView = ImageSigns.flameFilled
    } else if identifier == "question_tip" {
        imageView = UIImageView(image: UIImage(systemName: "questionmark.circle.fill"))
    } else if identifier == "limits_tip" {
        imageView = ImageSigns.speedometer
    } else if identifier == "url_tip" {
        imageView = UIImageView(image: UIImage(systemName: "link.circle.fill"))
    }
    
    showBanner(bannerDelegate: delegate,
               text: identifier.localized,
               content: imageView,
               color: color,
               dismissAfter: timeout)
}
