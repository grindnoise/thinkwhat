//
//  PrivacySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.11.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class PrivacySelectionViewController: UIViewController {

    var delegate: CallbackDelegate?
    private let privacyEnabledDescription = "Опроса не в общем доступе, просмотр и голосование только по приглашению"
    private let privacyDisabledDescription = "Опрос публичный, голосовать могут все"
    private var isAnimationStopped = false
    private var isAnimating = false
    private var isSelected = false
    var color: UIColor!
    var isPrivate = false
    private var isFirstSelection = true
    private var finalShadowPath: CGPath!
    private var initialShadowPath: CGPath!
    private var scaleAnim: CABasicAnimation!
    private var shadowPathAnim: CABasicAnimation!
    private var groupAnim: CAAnimationGroup!
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
            actionButton.text = "?"
            actionButton.tagColor = K_COLOR_GRAY
            actionButton.categoryID = .Text
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var enabledIcon: SurveyCategoryIcon! {
        didSet {
            enabledIcon.isGradient = false
            enabledIcon.tagColor   = K_COLOR_GRAY
            enabledIcon.categoryID = .Privacy
        }
    }
    @IBOutlet weak var disabledIcon: SurveyCategoryIcon! {
        didSet {
            disabledIcon.tagColor   = K_COLOR_GRAY
            disabledIcon.isGradient = false
            disabledIcon.categoryID = .PrivacyDisabled
        }
    }
    @IBOutlet weak var enabledBg: UIView!
    @IBOutlet weak var enabledFg: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.iconTapped(gesture:)))
            enabledFg.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var disabledBg: UIView!
    @IBOutlet weak var disabledFg: UIView! {
        didSet {
            disabledFg.layer.masksToBounds = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.iconTapped(gesture:)))
            disabledFg.addGestureRecognizer(tap)
        }
    }
    //    @IBOutlet weak var usersAnonLabel: UILabel! {
    //        didSet {
    //            usersAnonLabel.clipsToBounds = false
    //            usersAnonLabel.layer.masksToBounds = false
    //        }
    //    }
    @IBOutlet weak var descriptionLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.duration = 0.32
            nc.transitionStyle = .Icon
        }
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.enabledBg.setNeedsLayout()
            self.enabledBg.layoutIfNeeded()
            self.enabledBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            self.enabledBg.layer.shadowPath = UIBezierPath(roundedRect: self.enabledBg.bounds, cornerRadius: 10).cgPath
            self.enabledBg.layer.shadowRadius = 15
            self.enabledBg.layer.shadowOffset = .zero
            self.enabledBg.layer.shadowOpacity = 0
            self.enabledBg.layer.masksToBounds = false
//            self.enabledBg.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        DispatchQueue.main.async {
            self.actionButton.setNeedsLayout()
            self.actionButton.layoutIfNeeded()
            self.actionButton.layer.shadowColor = K_COLOR_GRAY.withAlphaComponent(0.3).cgColor
            let delta = self.actionButton.bounds.width - self.actionButton.bounds.width / 1.15
            self.initialShadowPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: self.actionButton.bounds.origin.x + delta/2, y: self.actionButton.bounds.origin.y + delta/2), size: CGSize(width: self.actionButton.bounds.width - delta, height: self.actionButton.bounds.height - delta))).cgPath
            self.finalShadowPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: self.actionButton.bounds.origin.x - delta/2, y: self.actionButton.bounds.origin.y - delta/2), size: CGSize(width: self.actionButton.bounds.width + delta, height: self.actionButton.bounds.height + delta))).cgPath//UIBezierPath(ovalIn: self.actionButton.bounds).cgPath
            self.actionButton.layer.shadowPath = self.initialShadowPath
            self.actionButton.layer.shadowRadius = 5
            self.actionButton.layer.shadowOffset = .zero
            self.actionButton.layer.shadowOpacity = 1
            self.actionButton.layer.masksToBounds = false
        }
        disabledBg.setNeedsLayout()
        disabledBg.layoutIfNeeded()
        disabledBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        disabledBg.layer.shadowPath = UIBezierPath(roundedRect: disabledBg.bounds, cornerRadius: 10).cgPath
        disabledBg.layer.shadowRadius = 15
        disabledBg.layer.shadowOffset = .zero
        disabledBg.layer.shadowOpacity = 0
        disabledBg.layer.masksToBounds = false
//        disabledBg.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if scaleAnim == nil {
            scaleAnim = Animations.transformScale(fromValue: 1, toValue: 1.1, duration: 0.6, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.linear, delegate: nil)
        }
        if shadowPathAnim == nil {
            shadowPathAnim = Animations.shadowPath(fromValue: initialShadowPath, toValue: finalShadowPath, duration: 0.6, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.linear, delegate: nil)
        }
        if groupAnim == nil {
            groupAnim = Animations.group(animations: [scaleAnim, shadowPathAnim], repeatCount: 0, autoreverses: true, duration: 0.6, timingFunction: CAMediaTimingFunctionName.linear, delegate: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        actionButton.layer.removeAllAnimations()
    }
    @objc fileprivate func okButtonTapped() {
        isAnimationStopped = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            actionButton.isUserInteractionEnabled = true
            let selectedView: UIView! = v == enabledFg ? enabledFg : disabledFg
            let deselectedView: UIView! = v != enabledFg ? enabledFg : disabledFg
            
            if let enabled = selectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let disabled = deselectedView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon {
                disabled.tagColor = K_COLOR_GRAY
                disabled.setNeedsDisplay()
                enabled.tagColor = color
                enabled.setNeedsDisplay()
            }
            
            if !isSelected {
                isSelected = true
                groupAnim.setValue(actionButton, forKey: "btn")
                actionButton.layer.add(groupAnim, forKey: nil)
                actionButton.text = "OK"
                actionButton.tagColor = K_COLOR_RED
                actionButton.categoryID = .Text
            }
            
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.descriptionLabel.text = v == self.enabledFg ? self.privacyEnabledDescription : self.privacyDisabledDescription
            })
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                deselectedView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                selectedView.transform = .identity
            })
            if !isFirstSelection {
                setShadow(subview: deselectedView.superview!, on: false)
            }
            setShadow(subview: selectedView.superview!, on: true)
            isFirstSelection = false
            isPrivate = v == enabledFg ? true : false
        }
    }
    
    private func setShadow(subview: UIView, on: Bool) {
        CATransaction.begin()
        let anim = CABasicAnimation(keyPath: "shadowOpacity")
        anim.fromValue = on ? 0 : 1
        anim.toValue = on ? 1 :0
        anim.duration = 0.2
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        anim.isRemovedOnCompletion = false
        subview.layer.add(anim, forKey: "shadowOpacity")
        CATransaction.commit()
        subview.layer.shadowOpacity = on ? 1 : 0
    }
}

extension PrivacySelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon, !isAnimationStopped {
            groupAnim.setValue(btn, forKey: "btn")
            btn.layer.add(groupAnim, forKey: nil)
            isAnimating = true
        }
    }
}
