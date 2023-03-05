//
//  ScrollingTabBarUtils.swift
//  Burb
//
//  Created by Pavel Bukharov on 10.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class ScrollingTabBarControllerDelegate: NSObject, UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ScrollingTransitionAnimator(tabBarController: tabBarController, lastIndex: tabBarController.selectedIndex)
  }
  
  //    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
  //        self.title = viewController.title
  //    }
}

class ScrollingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  weak var transitionContext: UIViewControllerContextTransitioning?
  var tabBarController: UITabBarController!
  var lastIndex = 0
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return tabAnimationDuration
  }
  
  init(tabBarController: UITabBarController, lastIndex: Int) {
    self.tabBarController = tabBarController
    self.lastIndex = lastIndex
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    self.transitionContext = transitionContext
    
    let containerView = transitionContext.containerView
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
    
    containerView.addSubview(toViewController!.view)
    
    var viewWidth = toViewController!.view.bounds.width
    
    if tabBarController.selectedIndex < lastIndex {
      viewWidth = -viewWidth
    }
    
    toViewController!.view.transform = CGAffineTransform(translationX: viewWidth, y: 0)
    
        UIView.animate(withDuration: self.transitionDuration(using: (self.transitionContext)),
                       delay: 0.0,
                       usingSpringWithDamping: 2.0,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
          toViewController!.view.transform = CGAffineTransform.identity
                      fromViewController!.view.transform = CGAffineTransform(translationX: -viewWidth, y: 0)
                  }, completion: { _ in
                      self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
                      fromViewController!.view.transform = CGAffineTransform.identity
        })
    
//    if #available(iOS 16.0, *) {
//      toViewController!.view.transform = CGAffineTransform(CGAffineTransformComponents(scale: CGSize(width: 0.85,
//                                                                                                     height: 0.85),
//                                                                                       translation: CGVector(dx: viewWidth,
//                                                                                                             dy: .zero)))
//    } else {
//      toViewController!.view.transform = CGAffineTransform(translationX: viewWidth, y: 0)
//    }
//    toViewController!.view.alpha = 1
//
//    UIView.animate(withDuration: self.transitionDuration(using: (self.transitionContext)),
//                   delay: 0.0,
//                   usingSpringWithDamping: 2.0,
//                   initialSpringVelocity: 0.5,
//                   options: .curveEaseInOut,
//                   animations: {
//      toViewController!.view.transform = CGAffineTransform.identity
//      toViewController!.view.alpha = 1
//      fromViewController!.view.alpha = 0
//      if #available(iOS 16.0, *) {
//        fromViewController!.view.transform = CGAffineTransform(CGAffineTransformComponents(scale: CGSize(width: 0.85,
//                                                                                                       height: 0.85),
//                                                                                           translation: CGVector(dx: -viewWidth,
//                                                                                                                 dy: .zero)))
//      } else {
//        fromViewController!.view.transform = CGAffineTransform(translationX: -viewWidth, y: 0)
//      }
//    }, completion: { _ in
//      self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
//      fromViewController!.view.transform = CGAffineTransform.identity
//    })
  }
}
