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
      
      
      if operation == .push {
        
        let containerView = transitionContext.containerView
        context = transitionContext
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        
        //        toVC.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        if let hotController = fromVC as? HotController,
//           let mainController = navigationController.tabBarController as? MainController,
           let pollController = toVC as? PollController,
           let hotView = hotController.view as? HotView,
           let card = hotView.current as? HotCard {
          
          pollController.view.setNeedsLayout()
          pollController.view.layoutIfNeeded()
          
          let fakeCard = HotCard(item: card.item,
                                nextColor: card.item.topic.tagColor,
                                isReplica: true)
          fakeCard.frame = card.frame
          fakeCard.body.cornerRadius = card.body.cornerRadius
          fakeCard.stack.alpha = 0
          fakeCard.setNeedsLayout()
          fakeCard.layoutIfNeeded()

          delay(seconds: 0.1) { [weak self] in
            guard let self = self else { return }
            appDelegate.window?.addSubview(fakeCard)
            hotView.alpha = 0
//            mainController.tabBarController?.setTabBarVisible(visible: false, animated: true)
            
            UIView.animate(withDuration: 1,//self.duration,
                           delay: 0,
                           options: .curveLinear,
                           animations: {

//              fakeCard.stack.alpha = 0
              fakeCard.body.cornerRadius = 0
              
              let topInset = hotController.view.statusBarFrame.height + self.navigationController.navigationBar.frame.height
              fakeCard.frame.origin = CGPoint(x: 0, y: topInset)
//              fakeCard.body.bounds.size.width += 20//appDelegate.window?.bounds.width ?? 0 // pollController.view.bounds.width// + 10
//                                      size: CGSize(width: pollController.view.bounds.width,
//                                                   height: fakeCard.bounds.height + 20 + self.navigationController.tabBarController!.tabBar.frame.height))
              
              pollController.view.alpha = 1
              //            hotController.view.alpha = 0
              //                    toVC.view.setNeedsDisplay()
              //                    toVC.view.layoutIfNeeded()
            }) {
              _ in
              //              fromVC.view.transform = .identity
              hotController.view.removeFromSuperview()
              hotController.view.alpha = 1
              fakeCard.removeFromSuperview()
              self.context?.completeTransition(true)
            }
          }
        }
        
        

        
          
      } else { fatalError() }
    }
}
