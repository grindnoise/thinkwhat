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
        containerView.backgroundColor = .clear
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
          
//          let origin = hotController.view.convert(card.frame.origin, to: appDelegate.window!)
          let fakeCard = HotCard(item: card.item,
                                nextColor: card.item.topic.tagColor,
                                isReplica: true)
          fakeCard.frame = card.frame
//          fakeCard.body.cornerRadius = card.body.cornerRadius
          fakeCard.stack.alpha = 0
          fakeCard.setNeedsLayout()
          fakeCard.layoutIfNeeded()
          
          let fakeAction = card.voteButton.copyView()!
          fakeAction.layer.zPosition = 100
          let fakeActionOrigin = card.voteButton.superview!.convert(card.voteButton.frame.origin,
                                                                    to: containerView)
          fakeAction.placeTopLeading(inside: appDelegate.window!,
                                     leadingInset: fakeActionOrigin.x,
                                     topInset: fakeActionOrigin.y,
                                     width: fakeAction.frame.width,
                                     height: fakeAction.frame.height)
          let fakeClaim = card.claimButton.copyView()!
          fakeClaim.layer.zPosition = 100
          let fakeClaimOrigin = card.claimButton.superview!.convert(card.claimButton.frame.origin, to: appDelegate.window!)
          fakeClaim.placeTopLeading(inside: appDelegate.window!,
                                    leadingInset: fakeClaimOrigin.x,
                                    topInset: fakeClaimOrigin.y,
                                    width: fakeClaim.frame.width,
                                    height: fakeClaim.frame.height)
          
          let fakeNext = card.nextButton.copyView()!
          fakeNext.layer.zPosition = 100
          let fakeNextOrigin = card.nextButton.superview!.convert(card.nextButton.frame.origin, to: appDelegate.window!)
          fakeNext.placeTopLeading(inside: appDelegate.window!,
                                   leadingInset: fakeNextOrigin.x,
                                   topInset: fakeNextOrigin.y,
                                   width: fakeNext.frame.width,
                                   height: fakeNext.frame.height)

          delay(seconds: 0.05) { [weak self] in
            guard let self = self else { return }
            appDelegate.window?.addSubview(fakeCard)
            hotView.alpha = 0
            fakeCard.togglePollMode()
            
            UIView.animate(withDuration: self.duration,//self.duration,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
              fakeAction.transform = .init(scaleX: 0.75, y: 0.75)
//              fakeAction.alpha = 0
//              fakeNext.transform = .init(scaleX: 0.75, y: 0.75)
//              fakeNext.alpha = 0
//              fakeClaim.transform = .init(scaleX: 0.75, y: 0.75)
//              fakeClaim.alpha = 0
              
              if let fakeNextConstraint = fakeNext.getConstraint(identifier: "leadingAnchor"),
                 let fakeClaimConstraint = fakeClaim.getConstraint(identifier: "leadingAnchor"),
                 let fakeActionConstraint = fakeAction.getConstraint(identifier: "topAnchor")
              {
                
                //                              let padding = containerView.bounds.width/6
                appDelegate.window!.setNeedsLayout()
                fakeClaimConstraint.constant -= fakeClaimOrigin.x + fakeClaim.bounds.width//padding//
                fakeNextConstraint.constant += UIScreen.main.bounds.width - fakeNextOrigin.x //fakeNext.bounds.width/2//padding//
                fakeActionConstraint.constant += UIScreen.main.bounds.height - fakeActionOrigin.y
                appDelegate.window!.layoutIfNeeded()
              }
            }) { _ in
              fakeAction.removeFromSuperview()
              fakeClaim.removeFromSuperview()
              fakeCard.removeFromSuperview()
//              self.context?.completeTransition(true)
            }
            
            UIView.animate(withDuration: self.duration*0.9,//self.duration,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
              fakeCard.frame.origin.y -= 8//CGPoint(x: 0, y: topInset)
              fakeCard.bounds.size.width += 16
              fakeCard.body.cornerRadius = 0
              fakeCard.body.backgroundColor = .clear
              fakeCard.fadeOut(duration: self.duration)
            }) {
              _ in
//              UIView.animate(withDuration: 0.15,
//                             animations: {
                toVC.view.alpha = 1
//              }) { _ in
                self.context?.completeTransition(true)
                hotController.view.removeFromSuperview()
                hotController.view.alpha = 1
                fakeCard.removeFromSuperview()
  //              self.context?.completeTransition(true)
//              }
            }
          }
        } else if let fromView = fromVC.view as? StartView,
                  let toView = toVC.view as? SignInView {
          
          toView.setNeedsLayout()
          toView.layoutIfNeeded()
          let logo = Icon(category: .Logo, scaleMultiplicator: 1, iconColor: Colors.main)
          logo.frame = CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                            to: containerView),
                               size: fromView.logoIcon.bounds.size)
          containerView.addSubview(logo)
          fromView.logoIcon.alpha = 0
          toView.logoIcon.alpha = 0
          logo.iconColor = Colors.main
          logo.scaleMultiplicator = 1
          logo.category = .Logo
          
          
          UIView.animate(withDuration: 0.5,
                         delay: 0,
                         options: .curveEaseInOut,
                         animations: { [weak self] in
            guard let self = self else { return }

            logo.frame = CGRect(origin: toView.logoIcon.superview!.convert(toView.logoIcon.frame.origin,
                                                             to: containerView),
                                 size: toView.logoIcon.bounds.size)
          }) {
            _ in

              toVC.view.alpha = 1
              toView.logoIcon.alpha = 0
              self.context?.completeTransition(true)

          }
        }
        
        

        
          
      } else { fatalError() }
    }
}
