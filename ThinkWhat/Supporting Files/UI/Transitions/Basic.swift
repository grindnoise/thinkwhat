////
////  Basic.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 26.01.2022.
////  Copyright © 2022 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class BasicTransition: NSObject, UIViewControllerAnimatedTransitioning {
//    
//    var operation: UINavigationController.Operation!
//    var navigationController: CustomNavigationController!
//    var duration: TimeInterval = 0.3
//    
//    init(navigationController: CustomNavigationController, operation: UINavigationController.Operation) {
//        self.navigationController = navigationController
//        self.operation = operation
//    }
//    
//    weak var context: UIViewControllerContextTransitioning?
//    
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return duration
//    }
//    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
//    
//    func animateIconPosition(fromView: UIView, fromIcon: Icon, toView: UIView, toIcon: Icon, keyWindow: UIView, containerView: UIView) -> [Closure] {
//        let icon = Icon(frame: CGRect(origin: fromView.convert(fromIcon.frame.origin, to: keyWindow),
//                                      size: fromIcon.frame.size))
//        icon.iconColor = fromIcon.iconColor
//        icon.backgroundColor = fromIcon.backgroundColor
//        icon.category = fromIcon.category
//        containerView.addSubview(icon)
//        fromIcon.alpha = 0
//        toIcon.alpha = 0
//        let destinationSize     = toIcon.frame.size
//        let destinationOrigin   = toView.convert(toIcon.frame.origin, to: keyWindow)
//        
//        var animationBlocks: [Closure] = []
//        animationBlocks.append {
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
//                icon.frame.origin = destinationOrigin
//                icon.frame.size   = destinationSize
//            }) {
//                _ in
//                toIcon.alpha = 1
//                icon.removeFromSuperview()
////                fromIcon.alpha = 1
//                self.context?.completeTransition(true)
//            }
//        }
//        if let destinationLayer = toIcon.icon as? CAShapeLayer, let destinationPath = destinationLayer.path {
//            let pathAnim = Animations.get(property: .Path,
//                                                fromValue: (fromIcon.icon as! CAShapeLayer).path as Any,
//                                                toValue: destinationPath as Any,
//                                                duration: duration*1.1,
//                                                delay: 0,
//                                                repeatCount: 0,
//                                                autoreverses: false,
//                                                timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                                                delegate: nil,
//                                                isRemovedOnCompletion: true)
//            animationBlocks.append {
//                icon.icon.add(pathAnim, forKey: nil)
//                (icon.icon as! CAShapeLayer).path = destinationPath
//            }
//        }
//        return animationBlocks
//    }
//}
