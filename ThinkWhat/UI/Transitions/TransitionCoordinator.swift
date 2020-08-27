//
//  TransitionCoordinator.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let nc = navigationController as? NavigationControllerPreloaded {
            switch nc.transitionStyle {
            case .Circular:
                return CircularTransition(nc, operation, nc.startingPoint)
            case .Default:
                return nil
            case .Fade:
                return FadeTransition(nc, operation)
            case .Icon:
                return IconCircularTransition(nc, operation, nc.duration)//, nc.startingPoint, nc.category, nc.iconSize)
            }
            
            //            if nc.isFadeTransition {
            //                return FadeTransition(nc, operation)
            //            } else if nc.isIconCircularTransition {
            //                return IconCircularTransition(nc, operation, nc.startingPoint)
            //            } else if nc.startingPoint != .zero {
            //                return CircularTransition(nc, operation, nc.startingPoint)
            //            }
        }
        return nil
    }
}
