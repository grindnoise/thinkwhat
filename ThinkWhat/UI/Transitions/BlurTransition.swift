//
//  BlurTransition.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.12.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class BlurTransition: BasicTransition {
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let containerView = transitionContext.containerView
        context = transitionContext
        toVC.view.alpha = 0//self.operation == .push ? 0 : toVC.view.alpha
        containerView.addSubview(toVC.view)
        
        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectViewOutgoing.frame = fromVC.view.bounds
        effectViewOutgoing.addEquallyTo(to: fromVC.view)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
            effectViewOutgoing.effect = nil
        })
        let effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        effectViewIncoming.frame = toVC.view.bounds
        effectViewIncoming.addEquallyTo(to: toVC.view)
        let delay = duration * 0.25
        
        if operation == .pop{
            if let vc_1 = fromVC as? TextViewController, let vc_2 = toVC as? NewPollController {
                if vc_1.accessibilityIdentifier == "Title" {
                    vc_2.title = vc_1.text.text
                } else if vc_1.accessibilityIdentifier == "Description" {
                    vc_2.pollDescription = vc_1.text.text
//                    vc_2.descriptionContainer.font = vc_1.font
//                    vc_2.descriptionContainer.textAlignment = .natural
//                    vc_2.descriptionContainer.numberOfLines = 0
                } else if vc_1.accessibilityIdentifier == "Question" {
                    
                }
            }
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration - delay, delay: 0, options: [.curveLinear], animations: {
            fromVC.view.alpha = 0
            effectViewOutgoing.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            effectViewOutgoing.removeFromSuperview()
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
                       effectViewIncoming.effect = nil
            toVC.view.alpha = 1
        }) {
            _ in
           
            effectViewIncoming.removeFromSuperview()
            fromVC.view.removeFromSuperview()
            self.context?.completeTransition(true)
        }
    }
}

