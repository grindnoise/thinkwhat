//
//  VotesCountViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.12.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class VotesCountViewController: UIViewController {

    private var isAnimating = false
    private var isAnimationStopped = false
    private var finalShadowPath: CGPath!
    private var initialShadowPath: CGPath!
    private var scaleAnim: CABasicAnimation!
    private var shadowPathAnim: CABasicAnimation!
    private var groupAnim: CAAnimationGroup!
    var color: UIColor!
    var votesCount = 100 {
        didSet {
            if votesCount != oldValue {
                if votesCount == 0 {
                    isAnimationStopped = true
                    actionButton.tagColor = K_COLOR_GRAY
                    actionButton.text = "\(votesCount)"
                    actionButton.isUserInteractionEnabled = false
                } else {
                    if actionButton != nil {
                        actionButton.text = "\(votesCount)"
                        actionButton.tagColor = Colors.UpperButtons.Avocado
                        actionButton.isUserInteractionEnabled = true
                        if !isAnimating {
                            isAnimationStopped = false
                            groupAnim.setValue(actionButton, forKey: "btn")
                            actionButton.layer.add(groupAnim, forKey: nil)
                            isAnimating = true
                        }
                    }
                }
            }
        }
    }
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
            actionButton.categoryID = .Text
            actionButton.tagColor   = color//Colors.UpperButtons.Avocado
            actionButton.text = "\(votesCount)"
            let tap = UITapGestureRecognizer(target: self, action: #selector(VotesCountViewController.actionButtonTapped))
            actionButton.addGestureRecognizer(tap)
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let text = sender.text, let intValue = Int(text) {
            votesCount = intValue
        } else {
            votesCount = 0
        }
    }
    @IBOutlet weak var votesCountTF: UITextField! {
        didSet {
            votesCountTF.text = "\(votesCount)"
        }
    }
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
        if scaleAnim == nil {
            scaleAnim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.6, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.linear.rawValue, delegate: nil)
        }
        if shadowPathAnim == nil {
            shadowPathAnim = animateShadowPath(fromValue: initialShadowPath, toValue: finalShadowPath, duration: 0.6, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.linear.rawValue, delegate: nil)
        }
        if groupAnim == nil {
            groupAnim = joinAnimations(animations: [scaleAnim, shadowPathAnim], repeatCount: 0, autoreverses: true, duration: 0.6, timingFunction: CAMediaTimingFunctionName.linear.rawValue, delegate: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        delay(seconds: 0.4) {
            self.groupAnim.setValue(self.actionButton, forKey: "btn")
            self.actionButton.layer.add(self.groupAnim, forKey: nil)
            self.isAnimating = true
        }
        delay(seconds: 0.1) {
            self.votesCountTF.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isAnimationStopped = true
    }
    
    @objc fileprivate func actionButtonTapped() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            self.actionButton.transform = .identity
        }) {
            _ in
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}

extension VotesCountViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if !isAnimationStopped, let btn = anim.value(forKey: "btn") as? SurveyCategoryIcon {
            groupAnim.setValue(btn, forKey: "btn")
            btn.layer.add(groupAnim, forKey: nil)
            isAnimating = true
        }
    }
}
