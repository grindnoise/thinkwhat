//
//  AnonimitySelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class AnonimitySelectionViewController: UIViewController {
    
    var delegate: CallbackDelegate?
    fileprivate let anonEnabledDescription = "Владелец опроса скрыт, респонденты никогда не узнают автора"
    fileprivate let anonDisabledDescription = "Владелец опроса виден респондентам"
    fileprivate var isAnimating = false
    fileprivate var heightConstraintConstant: CGFloat = 0
    fileprivate var newHeightConstraint: NSLayoutConstraint!
    fileprivate var isSelected = false
    var isAnonymous = false
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
            actionButton.text = "?"
            actionButton.tagColor = K_COLOR_GRAY
            actionButton.categoryID = .Text
            let tap = UITapGestureRecognizer(target: self, action: #selector(AnonimitySelectionViewController.okButtonTapped))
            actionButton.addGestureRecognizer(tap)
            actionButton.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var anonEnabledIcon: SurveyCategoryIcon! {
        didSet {
            anonEnabledIcon.tagColor   = Colors.RussianViolet
            anonEnabledIcon.categoryID = .Anon
        }
    }
    @IBOutlet weak var anonDisabledIcon: SurveyCategoryIcon! {
        didSet {
            anonDisabledIcon.tagColor   = Colors.RussianViolet
            anonDisabledIcon.categoryID = .AnonDisabled
        }
    }
    @IBOutlet weak var anonEnabledSubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(AnonimitySelectionViewController.iconTapped(gesture:)))
            anonEnabledSubview.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var anonDisabledSubview: UIView! {
        didSet {
            anonDisabledSubview.layer.masksToBounds = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(AnonimitySelectionViewController.iconTapped(gesture:)))
            anonDisabledSubview.addGestureRecognizer(tap)
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
    
    override func viewDidAppear(_ animated: Bool) {
        newHeightConstraint = NSLayoutConstraint(item: upperView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: upperView.frame.size.height)
        NSLayoutConstraint.deactivate([heightConstraint])
        NSLayoutConstraint.activate([newHeightConstraint])
//        if heightConstraintConstant == 0 {
//            heightConstraintConstant = upperView.frame.size.height
//            heightConstraint.multiplier = 1
//            heightConstraint.constant = heightConstraintConstant
//        }
    }
    
    
    @objc fileprivate func okButtonTapped() {
        if let v = isAnonymous ? anonEnabledSubview : anonDisabledSubview {
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
            let selectedView: UIView! = v == anonEnabledSubview ? anonEnabledSubview : anonDisabledSubview
            let deselectedView: UIView! = v != anonEnabledSubview ? anonEnabledSubview : anonDisabledSubview
            
            
            if !isSelected {
                isSelected = true
                anonEnabledSubview.cornerRadius = v.frame.width * 0.17
                anonDisabledSubview.cornerRadius = anonEnabledSubview.cornerRadius
                let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
                anim.setValue(self.actionButton, forKey: "btn")
                
                self.actionButton.layer.add(anim, forKey: nil)
                self.actionButton.text = "OK"
                self.actionButton.tagColor = K_COLOR_RED
                self.actionButton.categoryID = .Text
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.view.setNeedsLayout()
                    self.newHeightConstraint.constant *= 0.7
                    self.view.layoutIfNeeded()
                }) {
                    _ in
                    
                }
            }
//            v.cornerRadius = v.frame.width * 0.25
            
            UIView.transition(with: descriptionLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.descriptionLabel.text = v == self.anonEnabledSubview ? self.anonEnabledDescription : self.anonDisabledDescription
            })
            
//            UIView.animate(withDuration: 0.12) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                selectedView.backgroundColor = Colors.RussianViolet.withAlphaComponent(0.2)
                selectedView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                deselectedView.backgroundColor = .white
                deselectedView.transform = .identity
            })
            isAnonymous = v == anonEnabledSubview ? true : false
//            let anim2 = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.12, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue,  delegate: nil)
//            selectedView.layer.add(anim2, forKey: nil)
        }
    }
}

extension AnonimitySelectionViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon {
            let _anim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.5, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue, delegate: self as CAAnimationDelegate)
            _anim.setValue(btn, forKey: "btn")
            btn.layer.add(_anim, forKey: nil)
            isAnimating = true
        }
    }
}
