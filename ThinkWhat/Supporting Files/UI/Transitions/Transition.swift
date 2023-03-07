//
//  Transitions.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class Transition: NSObject, UIViewControllerAnimatedTransitioning {
    var operation: UINavigationController.Operation!
    var navigationController: UINavigationController!
    var duration = 0.2
    
    init(_ _navigationController: UINavigationController, _ _operation: UINavigationController.Operation) {
        navigationController = _navigationController
        operation = _operation
    }
    
    weak var context: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let containerView = transitionContext.containerView
        context = transitionContext
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        
        toVC.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//        toVC.view.setNeedsLayout()
//        toVC.view.layoutIfNeeded()
        
//        UIView.animate(withDuration: duration) {
//            fromVC.view.alpha = 0
//        }
//        UIView.animate(withDuration: self.duration,
//                       delay: 0,
//                       options: self.operation == .push ? .curveEaseIn : .curveEaseOut, animations: {
        //                        fromVC.view.alpha = 0
        //        })
        UIView.animate(withDuration: self.duration,
                       delay: 0,
                       //                       options: operation == .pop ? .curveEaseOut : .curveEaseIn , animations: {
                       options: .curveLinear, animations: {
            toVC.view.transform = .identity
            fromVC.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            toVC.view.alpha = 1
            fromVC.view.alpha = 0
            //                    toVC.view.setNeedsDisplay()
            //                    toVC.view.layoutIfNeeded()
        }) {
            _ in
            fromVC.view.transform = .identity
            fromVC.view.removeFromSuperview()
            self.context?.completeTransition(true)
        }
    }
}
