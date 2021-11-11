//
//  AlertView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class AlertController: UIViewController, ServerProtocol {
    enum ContentType: Int {
        case Info, Claim
    }
    
    var survey: Survey?
    var claimCategory: ClaimCategory? {
        didSet {
            if oldValue == nil, claimCategory != nil {
                if contentType == .Claim {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.button.backgroundColor = K_COLOR_RED
                    }) {
                        _ in
                        self.button.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var effectView: UIVisualEffectView! {
        didSet {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
                self.effectView.effect = nil
            })
        }
    }
    @IBOutlet weak var body: UIView!
    @IBOutlet weak var container: UIView! {
        didSet {
            container.backgroundColor = .clear
        }
    }
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    @IBOutlet weak var topFrame: UIView! {
        didSet {
            topFrame.backgroundColor = .white
        }
    }
    @IBOutlet weak var icon: Icon! {
        didSet {
            icon.backgroundColor = color
            icon.isRounded = true
            icon.backgroundColor = color
            icon.iconColor = .white
        }
    }
    @IBOutlet weak var bottomFrame: UIView! {
        didSet {
            bottomFrame.backgroundColor = .white
        }
    }
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.backgroundColor = color
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        if contentType == .Claim, survey != nil, let claimVC = currentController as? ClaimViewController {
            if claimCategory != nil {
                apiManager.postClaim(survey: survey!, claimCategory: claimCategory!) { _, _ in }
                if icon != nil {
                    let pathAnim = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path!, toValue: (icon.getLayer(.Letter) as! CAShapeLayer).path!, duration: 0.5, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: icon, isRemovedOnCompletion: false)
                    icon.icon.add(pathAnim, forKey: nil)
                }
                button.setTitle("ДАЛЕЕ", for: .normal)
                claimCategory = nil
                claimVC.showFeedback() {
                    _ in
                    self.popController = true
                    self.dismissAfter(5)
                    //                delay(seconds: 1.5) {
                    //                    self.delegate?.callbackReceived("post_claim" as AnyObject)
                    //                    self.dismiss() { _ in }
                    //                }
                }
            } else {
                stopTimer()
                dismiss() { _ in }
            }
        } else {
            dismiss() { _ in }
        }
    }
    
    
    static let willAppearSignal       = "alertWillAppearSignal"
    static let didAppearSignal        = "alertDidAppearSignal"
    static let willDisappearSignal    = "alertWillDisappearSignal"
    static let didDisappearSignal     = "alertDidDisappearSignal"
    static let popController          = "popController"
    static let shared: AlertController = {
        let vc = Storyboards.controllers.instantiateViewController(withIdentifier: "AlertController") as! AlertController
        let _keyWindow = UIApplication.shared.value(forKey: "statusBarWindow") as! UIWindow
        vc.view.addEquallyTo(to: _keyWindow)
        vc.view.setNeedsLayout()
        vc.yConstraint.constant = (vc.view.frame.height + vc.body.frame.height)/2
        vc.view.layoutIfNeeded()
        vc.topFrame.cornerRadius = vc.topFrame.frame.height / 2
        vc.bottomFrame.cornerRadius = vc.bottomFrame.frame.height / 2
        vc.button.cornerRadius = vc.button.frame.height / 2
        vc.standartHeight = vc.heightConstraint.constant
        return vc
    } ()
    private var popController = false
    private var currentController: UIViewController?
    private weak var delegate: CallbackDelegate?
    private var contentType: ContentType = .Info {
        didSet {
            if button != nil {
                button.isUserInteractionEnabled = true
                button.backgroundColor = K_COLOR_RED
                button.setTitle("ОТПРАВИТЬ", for: .normal)
            }
            container.subviews.forEach({ $0.removeFromSuperview() })
            currentController?.removeFromParent()
            if contentType == .Claim {
                icon.category = .Caution
                let vc = Storyboards.survey.instantiateViewController(withIdentifier: "ClaimViewController") as! ClaimViewController
                vc.delegate = self
                self.addChild(vc)
                vc.view.addEquallyTo(to: container)
                vc.didMove(toParent: self)
                currentController = vc
                if button != nil { button.isUserInteractionEnabled = false; button.backgroundColor = K_COLOR_GRAY }
            }
        }
    }
    private var keyWindow:  UIWindow!
    private var color: UIColor = K_COLOR_RED
    private var standartHeight: CGFloat = 0
    private var timer:  Timer?
    private var timeElapsed: TimeInterval = 0
    
    func present(delegate _delegate: CallbackDelegate?, height: CGFloat = 0, contentType _contentType: ContentType = .Info, survey _survey: Survey?) {
        popController = false
        contentType = _contentType
        survey = _survey
        view.setNeedsLayout()
        heightConstraint.constant = height == 0 ? standartHeight : height
        view.layoutIfNeeded()
        view.alpha = 1
        delegate = _delegate
        delegate?.callbackReceived(AlertController.willAppearSignal as AnyObject)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, options: [.curveLinear], animations: {
            self.effectView.effect = UIBlurEffect(style: .dark)
        })
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut],
            animations: {
                self.view.setNeedsLayout()
                self.yConstraint.constant = 0
                self.view.layoutIfNeeded()
        }) {
            _ in
            self.delegate?.callbackReceived(AlertController.didAppearSignal as AnyObject)
        }
    }
    
    func dismiss(completion: @escaping (Bool) -> ()) {
        delegate?.callbackReceived((self.popController ? AlertController.popController : AlertController.willDisappearSignal) as AnyObject)
        self.delegate?.callbackReceived(AlertController.willDisappearSignal as AnyObject)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
            self.effectView.effect = nil
            self.view.setNeedsLayout()
            self.yConstraint.constant = -(self.view.frame.height + self.body.frame.height)/2
            self.view.layoutIfNeeded()
        }) {
            _ in
            self.delegate?.callbackReceived(AlertController.willDisappearSignal as AnyObject)
            self.delegate?.callbackReceived((self.popController ? AlertController.popController : AlertController.didDisappearSignal) as AnyObject)
            self.delegate = nil
            self.view.alpha = 0
            self.yConstraint.constant = (self.view.frame.height + self.body.frame.height)/2
//            self.contentType = .Info
            self.survey = nil
            self.claimCategory = nil
            completion(true)
        }
    }
    
    func dismissAfter(_ _timeElapsed: TimeInterval = 0) {
        timeElapsed = _timeElapsed
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeElapsed = 0
    }
    
    @objc private func updateTimer() {
        timeElapsed    -= 0.5
        if timeElapsed <= 0 {
            stopTimer()
            dismiss() {_ in}
        }
    }
}

extension AlertController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if contentType == .Claim {
            if let _claimCategory =  sender as? ClaimCategory, survey != nil {
                //                dismiss() {
                //                    _ in
                //                    self.delegate?.callbackReceived("post_claim" as AnyObject)
                //                }
                claimCategory = _claimCategory
                
                //                apiManager.postClaim(survey: survey!, claimCategory: claimCategory) { _, _ in }
            } else if let string = sender as? String, string == "cancel_claim" {
                dismiss() { _ in }
            }
        }
    }
}

//
//import UIKit
//
//class Alert: UIView, ServerProtocol {
//    enum ContentType: Int {
//        case Info, Claim
//    }
//
//    var survey: Survey?
//    var claimCategory: ClaimCategory?
//
//    @IBOutlet var contentView: UIView!
//    @IBOutlet weak var effectView: UIVisualEffectView! {
//        didSet {
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
//                self.effectView.effect = nil
//            })
//        }
//    }
//    @IBOutlet weak var body: UIView!
//    @IBOutlet weak var container: UIView! {
//        didSet {
//            container.backgroundColor = .clear
//        }
//    }
//    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var yConstraint: NSLayoutConstraint!
//    @IBOutlet weak var topFrame: UIView! {
//        didSet {
//            topFrame.backgroundColor = .white
//        }
//    }
//    @IBOutlet weak var icon: Icon! {
//        didSet {
//            icon.backgroundColor = color
//            icon.isRounded = true
//            icon.backgroundColor = color
//            icon.iconColor = .white
//        }
//    }
//    @IBOutlet weak var bottomFrame: UIView! {
//        didSet {
//            bottomFrame.backgroundColor = .white
//        }
//    }
//    @IBOutlet weak var button: UIButton! {
//        didSet {
//            button.backgroundColor = color
//        }
//    }
//    @IBAction func buttonTapped(_ sender: Any) {
//        if contentType == .Claim, survey != nil, claimCategory != nil {
//            apiManager.postClaim(survey: survey!, claimCategory: claimCategory!) { _, _ in }
//        }
//        dismiss() { _ in }
//    }
//
//
//    static let willAppearSignal       = "alertWillAppearSignal"
//    static let didAppearSignal        = "alertDidAppearSignal"
//    static let willDisappearSignal    = "alertWillDisappearSignal"
//    static let didDisappearSignal     = "alertDidDisappearSignal"
//    static let shared = Alert()
//
//    private weak var delegate: CallbackDelegate?
//    private var contentType: ContentType = .Info {
//        didSet {
//            if contentType != oldValue {
//                container.subviews.forEach({ $0.removeFromSuperview() })
//                if contentType == .Claim {
//                    //                    let claimView = ClaimView(frame: container.frame)
//                    //                    claimView.addEquallyTo(to: container)
//                    let vc = Storyboards.survey.instantiateViewController(withIdentifier: "ClaimViewController") as! ClaimViewController
//                    vc.delegate = self
//                    vc.view.addEquallyTo(to: container)
//                }
//            }
//        }
//    }
//    private var keyWindow:  UIWindow!
//    private var color: UIColor = K_COLOR_RED
//    private var standartHeight: CGFloat = 0
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("Not for XIB/NIB")
//    }
//
//    private init() {
//        super.init(frame: UIScreen.main.bounds)
//        self.commonInit()
//    }
//
//    private func commonInit() {
//        Bundle.main.loadNibNamed("Alert", owner: self, options: nil)
//        guard let content = contentView, let _keyWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow else {
//            return
//        }
//        backgroundColor             = .clear
//        bounds                      = UIScreen.main.bounds
//        content.frame               = bounds
//        content.autoresizingMask    = [.flexibleHeight, .flexibleWidth]
//        keyWindow = _keyWindow
//        keyWindow.addSubview(self)
//        addSubview(content)
//
//        setNeedsLayout()
//        yConstraint.constant = (frame.height + body.frame.height)/2
//        layoutIfNeeded()
//        topFrame.cornerRadius = topFrame.frame.height / 2
//        bottomFrame.cornerRadius = bottomFrame.frame.height / 2
//        button.cornerRadius = button.frame.height / 2
//        standartHeight = heightConstraint.constant
//    }
//
//    func present(delegate _delegate: CallbackDelegate?, height: CGFloat = 0, contentType _contentType: ContentType = .Info, survey _survey: Survey?) {
//        contentType = _contentType
//        survey = _survey
//        setNeedsLayout()
//        heightConstraint.constant = height == 0 ? standartHeight : height
//        layoutIfNeeded()
//        alpha = 1
//        delegate = _delegate
//        delegate?.callbackReceived(Alert.willAppearSignal as AnyObject)
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, options: [.curveLinear], animations: {
//            self.effectView.effect = UIBlurEffect(style: .dark)
//        })
//        UIView.animate(
//            withDuration: 0.5,
//            delay: 0,
//            usingSpringWithDamping: 0.75,
//            initialSpringVelocity: 0.2,
//            options: [.curveEaseInOut],
//            animations: {
//                self.setNeedsLayout()
//                self.yConstraint.constant = 0
//                self.layoutIfNeeded()
//        }) {
//            _ in
//            self.delegate?.callbackReceived(Alert.didAppearSignal as AnyObject)
//        }
//    }
//
//    func dismiss(completion: @escaping (Bool) -> ()) {
//        self.delegate?.callbackReceived(Alert.willDisappearSignal as AnyObject)
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
//            self.effectView.effect = nil
//            self.setNeedsLayout()
//            self.yConstraint.constant = -(self.frame.height + self.body.frame.height)/2
//            self.layoutIfNeeded()
//        }) {
//            _ in
//            self.delegate?.callbackReceived(Alert.didDisappearSignal as AnyObject)
//            self.delegate = nil
//            self.alpha = 0
//            self.yConstraint.constant = (self.frame.height + self.body.frame.height)/2
//            self.contentType = .Info
//            self.survey = nil
//            self.claimCategory = nil
//            completion(true)
//        }
//    }
//
//}
//
//extension Alert: CallbackDelegate {
//    func callbackReceived(_ sender: AnyObject) {
//
//    }
//}
//
//
