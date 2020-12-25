//
//  HyperlinkSelectionViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.12.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class HyperlinkSelectionViewController: UIViewController {
    
    private var isAnimating = false
    private var isAnimationStopped = false
    var hyperlink: URL? {
        didSet {
            if hyperlink != nil {
                
            }
        }
    }
    @IBOutlet weak var actionButton: SurveyCategoryIcon! {
        didSet {
            actionButton.categoryID = .Text
            actionButton.tagColor   = K_COLOR_RED
            actionButton.text       = "?"
            let tap = UITapGestureRecognizer(target: self, action: #selector(HyperlinkSelectionViewController.actionButtonTapped))
            actionButton.addGestureRecognizer(tap)
        }
    }
    @IBAction func dismiss(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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

extension HyperlinkSelectionViewController: CAAnimationDelegate {
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
