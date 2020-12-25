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
                            let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
                            anim.setValue(actionButton, forKey: "btn")
                            actionButton.layer.add(anim, forKey: nil)
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
            actionButton.tagColor   = Colors.UpperButtons.Avocado
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
//        votesCountTF.becomeFirstResponder()
//        let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
//        anim.setValue(actionButton, forKey: "btn")
//        actionButton.layer.add(anim, forKey: nil)
//        isAnimating = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delay(seconds: 0.4) {
            let anim = animateTransformScale(fromValue: 1, toValue: 1.15, duration: 0.4, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, delegate: self as CAAnimationDelegate)
            anim.setValue(self.actionButton, forKey: "btn")
            self.actionButton.layer.add(anim, forKey: nil)
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
            let _anim = animateTransformScale(fromValue: 1, toValue: 1.1, duration: 0.5, repeatCount: 0, autoreverses: true, timingFunction: CAMediaTimingFunctionName.easeInEaseOut.rawValue, delegate: self as CAAnimationDelegate)
            _anim.setValue(btn, forKey: "btn")
            btn.layer.add(_anim, forKey: nil)
            isAnimating = true
        }
    }
}
