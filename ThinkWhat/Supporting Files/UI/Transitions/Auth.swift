////
////  Auth.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 26.01.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class AuthTransition: BasicTransition {
//    
//    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        guard let fromVC = transitionContext.viewController(forKey: .from),
//              let toVC = transitionContext.viewController(forKey: .to) else {
//                  transitionContext.completeTransition(false)
//                  return
//              }
//        let containerView = transitionContext.containerView
//        context = transitionContext
//        toVC.view.alpha = 0
//        containerView.addSubview(toVC.view)
//        
//        if operation == .push {
//            if let vc_1 = fromVC as? GetStartedViewController, let vc_2 = toVC as? SignupViewController {
//                containerView.backgroundColor = .systemBackground
//                var animations: [Closure] = []
//                if let initialIcon = (vc_1.view as? WelcomeView)?.logo,
//                   let keyWindow = navigationController?.view.window,
//                   let destinationIcon = (vc_2.view as? SignupView)?.logo {
//                    vc_2.view.setNeedsLayout()
//                    vc_2.view.layoutIfNeeded()
//                    animations = animateIconPosition(fromView: initialIcon.superview!,
//                                                     fromIcon: initialIcon,
//                                                     toView: destinationIcon.superview!,
//                                                     toIcon: destinationIcon,
//                                                     keyWindow: keyWindow,
//                                                     containerView: containerView)
//                }
//                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animations, useIncomingBlurEffect: true) {
//                    _ in
////                    self.context?.completeTransition(true)
//                }
//            }
//        } else {
//            if let vc_1 = fromVC as? SignupViewController, let vc_2 = toVC as? GetStartedViewController {
//                toVC.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
//                containerView.backgroundColor = .systemBackground
//                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [], useIncomingBlurEffect: false) {
//                    _ in
//                    self.context?.completeTransition(true)
//                }
//            }
//        }
//        
//        func animateWithBlurEffect(fromView: UIView, toView: UIView, animationBlocks: [Closure], useIncomingBlurEffect: Bool = true, completion: @escaping(Bool)->()) {
//            let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//            effectViewOutgoing.frame = fromView.bounds
//            effectViewOutgoing.addEquallyTo(to: fromView)
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
//                effectViewOutgoing.effect = nil
//            })
//            var effectViewIncoming: UIVisualEffectView!
//            if useIncomingBlurEffect {
//                effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
//                effectViewIncoming.frame = toView.bounds
//                effectViewIncoming.addEquallyTo(to: toView)
//            }
////            let delay = duration * 0.25
//            
//            DispatchQueue.main.async {
//                animationBlocks.forEach{ $0() }
//            }
//            
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
//                fromView.alpha = 0
//                toView.alpha = 1
//                effectViewOutgoing.effect = UIBlurEffect(style: .light)
//            }) {
//                _ in
//                effectViewOutgoing.removeFromSuperview()
//                if !useIncomingBlurEffect {
//                    fromView.removeFromSuperview()
//                    completion(true)
//                }
//            }
//            
//            if useIncomingBlurEffect {
//                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0/*delay*/, options: [.curveLinear], animations: {
//                    effectViewIncoming.effect = nil
//                    toView.alpha = 1
//                }) {
//                    _ in
//                    effectViewIncoming.removeFromSuperview()
//                    fromView.removeFromSuperview()
//                    completion(true)
//                }
//            }
//        }
//    }
//}
//    
