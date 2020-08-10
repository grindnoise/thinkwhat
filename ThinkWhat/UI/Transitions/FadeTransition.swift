//
//  FadeTransition.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 09.06.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//
import UIKit

class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var operation: UINavigationController.Operation!
    var navigationController: NavigationControllerPreloaded!
    var duration = 0.35
    
    init(_ _navigationController: NavigationControllerPreloaded, _ _operation: UINavigationController.Operation) {
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
        toVC.view.alpha = 0//self.operation == .push ? 0 : toVC.view.alpha
        containerView.addSubview(toVC.view)
        
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
                       options: operation == .pop ? .curveEaseOut : .curveEaseIn , animations: {
                        toVC.view.alpha = 1
                        fromVC.view.alpha = 0
        }) {
            _ in
            fromVC.view.removeFromSuperview()
            self.context?.completeTransition(true)
        }
    }
}
