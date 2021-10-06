//
//  AlertView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 05.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class Alert: UIView, ServerProtocol {
    enum ContentType: Int {
        case Info, Claim
    }
    
    var survey: Survey?
    var claimCategory: ClaimCategory?
    
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
        if contentType == .Claim, survey != nil, claimCategory != nil {
            apiManager.postClaim(survey: survey!, claimCategory: claimCategory!) { _, _ in }
        }
        dismiss() { _ in }
    }
    
    
    static let willAppearSignal       = "alertWillAppearSignal"
    static let didAppearSignal        = "alertDidAppearSignal"
    static let willDisappearSignal    = "alertWillDisappearSignal"
    static let didDisappearSignal     = "alertDidDisappearSignal"
    static let shared = Alert()
    
    private weak var delegate: CallbackDelegate?
    private var contentType: ContentType = .Info {
        didSet {
            if contentType != oldValue {
                container.subviews.forEach({ $0.removeFromSuperview() })
                if contentType == .Claim {
                    let vc = Storyboards.survey.instantiateViewController(withIdentifier: "ClaimViewController") as! ClaimViewController
                    vc.delegate = self
                    vc.view.addEquallyTo(to: container)
                }
            }
        }
    }
    private var keyWindow:  UIWindow!
    private var color: UIColor = K_COLOR_RED
    private var standartHeight: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not for XIB/NIB")
    }
    
    private init() {
        super.init(frame: UIScreen.main.bounds)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Alert", owner: self, options: nil)
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
        
        setNeedsLayout()
        yConstraint.constant = (frame.height + body.frame.height)/2
        layoutIfNeeded()
        topFrame.cornerRadius = topFrame.frame.height / 2
        bottomFrame.cornerRadius = bottomFrame.frame.height / 2
        button.cornerRadius = button.frame.height / 2
        standartHeight = heightConstraint.constant
    }
    
    func present(delegate _delegate: CallbackDelegate?, height: CGFloat = 0, contentType _contentType: ContentType = .Info, survey _survey: Survey?) {
        contentType = _contentType
        survey = _survey
        setNeedsLayout()
        heightConstraint.constant = height == 0 ? standartHeight : height
        layoutIfNeeded()
        alpha = 1
        delegate = _delegate
        delegate?.callbackReceived(Alert.willAppearSignal as AnyObject)
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
                self.setNeedsLayout()
                self.yConstraint.constant = 0
                self.layoutIfNeeded()
        }) {
            _ in
            self.delegate?.callbackReceived(Alert.didAppearSignal as AnyObject)
        }
    }
    
    func dismiss(completion: @escaping (Bool) -> ()) {
        self.delegate?.callbackReceived(Alert.willDisappearSignal as AnyObject)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
            self.effectView.effect = nil
            self.setNeedsLayout()
            self.yConstraint.constant = -(self.frame.height + self.body.frame.height)/2
            self.layoutIfNeeded()
        }) {
            _ in
            self.delegate?.callbackReceived(Alert.didDisappearSignal as AnyObject)
            self.delegate = nil
            self.alpha = 0
            self.yConstraint.constant = (self.frame.height + self.body.frame.height)/2
            self.contentType = .Info
            self.survey = nil
            self.claimCategory = nil
            completion(true)
        }
    }
    
}

extension Alert: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        
    }
}
