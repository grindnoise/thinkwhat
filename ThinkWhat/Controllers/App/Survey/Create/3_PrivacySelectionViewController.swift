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
    fileprivate let privacyEnabledDescription = "Опроса не в общем доступе, просмотр и голосование только по приглашению"
    fileprivate let privacyDisabledDescription = "Опрос публичный, голосовать могут все"
    fileprivate var isAnimationStopped = false
    fileprivate var isAnimating = false
    fileprivate var isSelected = false
    var isPrivate = false
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
    @IBOutlet weak var privacyEnabledIcon: SurveyCategoryIcon! {
        didSet {
            privacyEnabledIcon.tagColor   = Colors.UpperButtons.HoneyYellow
            privacyEnabledIcon.categoryID = .Eye
        }
    }
    @IBOutlet weak var privacyDisabledIcon: SurveyCategoryIcon! {
        didSet {
            privacyDisabledIcon.tagColor   = Colors.UpperButtons.HoneyYellow
            privacyDisabledIcon.categoryID = .EyeDisabled
        }
    }
    @IBOutlet weak var privacyEnabledSubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.iconTapped(gesture:)))
            privacyEnabledSubview.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var privacyDisabledSubview: UIView! {
        didSet {
            privacyDisabledSubview.layer.masksToBounds = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(PrivacySelectionViewController.iconTapped(gesture:)))
            privacyDisabledSubview.addGestureRecognizer(tap)
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
            nc.duration = 0.25
            nc.transitionStyle = .Icon
        }
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @objc fileprivate func okButtonTapped() {
        if let v = isPrivate ? privacyEnabledSubview : privacyDisabledSubview {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                v.backgroundColor = .white
                v.transform = .identity
            }) {
                _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            actionButton.isUserInteractionEnabled = true
            let selectedView: UIView! = v == privacyEnabledSubview ? privacyEnabledSubview : privacyDisabledSubview
            let deselectedView: UIView! = v != privacyEnabledSubview ? privacyEnabledSubview : privacyDisabledSubview
            
            
            if !isSelected {
                isSelected = true
                privacyEnabledSubview.cornerRadius = v.frame.width * 0.17
                privacyDisabledSubview.cornerRadius = privacyEnabledSubview.cornerRadius
                let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
                anim.setValue(self.actionButton, forKey: "btn")
                
                self.actionButton.layer.add(anim, forKey: nil)
                self.actionButton.text = "OK"
                self.actionButton.tagColor = K_COLOR_RED
                self.actionButton.categoryID = .Text
            }
            //            v.cornerRadius = v.frame.width * 0.25
            
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.descriptionLabel.text = v == self.privacyEnabledSubview ? self.privacyEnabledDescription : self.privacyDisabledDescription
            })
            
            //            UIView.animate(withDuration: 0.12) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                selectedView.backgroundColor = Colors.UpperButtons.HoneyYellow.withAlphaComponent(0.2)
                selectedView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                deselectedView.backgroundColor = .white
                deselectedView.transform = .identity
            })
            isPrivate = v == privacyEnabledSubview ? true : false
            //            let anim2 = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.12, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue,  delegate: nil)
            //            selectedView.layer.add(anim2, forKey: nil)
        }
    }
}

extension PrivacySelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if !isAnimationStopped, let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon {
            let _anim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.5, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue, delegate: self as CAAnimationDelegate)
            _anim.setValue(btn, forKey: "btn")
            btn.layer.add(_anim, forKey: nil)
            isAnimating = true
        }
    }
}
