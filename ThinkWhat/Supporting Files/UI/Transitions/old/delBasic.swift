//
//  BasicTransition.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.05.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class delBasicTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var operation: UINavigationController.Operation!
    var navigationController: NavigationControllerPreloaded!
    var duration: TimeInterval = 0.3
    
    init(_ _navigationController: NavigationControllerPreloaded, _ _operation: UINavigationController.Operation, _ _duration: TimeInterval) {
        navigationController = _navigationController
        operation = _operation
        duration = _duration
    }
    
    weak var context: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
}
