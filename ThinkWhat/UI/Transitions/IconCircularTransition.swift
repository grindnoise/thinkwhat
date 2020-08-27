//
//  IconCircularTransition.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class IconCircularTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
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
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let containerView = transitionContext.containerView
        context = transitionContext
        if operation == .push {
            if let vc_1 = fromVC as? SurveysViewController, let collVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let vc_2 = toVC as? SubcategoryViewController, let destinationIcon = vc_2.icon {
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: cell.icon.frame.size))
                icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: cell.category.ID) ?? .Null
                icon.isOpaque = false
                var pos = cell.icon.convert(cell.icon.center, to: navigationController?.view)
                pos.x -= collVC.sectionInsets.left * 1.5
                pos.y -= collVC.sectionInsets.top * 2
                collVC.returnPos = pos
                icon.center = pos
                icon.tagColor = cell.category.tagColor
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                cell.icon.alpha = 0
                var destinationPos: CGPoint = .zero
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                UIView.animate(withDuration: 0.15, animations: {
                    fromVC.view.alpha = 0
                }) {
                    _ in
                    fromVC.view.removeFromSuperview()
                }
                
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.7,
                    options: [.curveEaseOut],
                    animations: {
                        toVC.view.alpha = 1
                        icon.center = destinationPos
                        icon.frame.size = destinationSize
                }) {
                    _ in
                    destinationIcon.alpha = 1
                    icon.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
            }
        } else if operation == .pop {
            if let vc_2 = toVC as? SurveysViewController, let collVC = vc_2.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let vc_1 = fromVC as? SubcategoryViewController, let initialIcon = vc_1.icon {
                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: initialIcon.frame.size))
                icon.categoryID = initialIcon.categoryID
                icon.isOpaque = false
                var pos = initialIcon.convert(initialIcon.center, to: navigationController?.view)
                pos.x = initialIcon.center.x
                pos.y = initialIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                icon.center = pos
                icon.tagColor = initialIcon.tagColor
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                toVC.tabBarController?.setTabBarVisible(visible: true, animated: true)
                initialIcon.alpha = 0
                let destinationSize = cell.icon.frame.size
                var destinationPos = collVC.returnPos
                destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: .curveLinear, animations: {
                                toVC.view.alpha = 1
                })
                UIView.animate(withDuration: 0.15, animations: {
                    fromVC.view.alpha = 0
                }) {
                    _ in
                    fromVC.view.removeFromSuperview()
                }
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.7,
                    options: [.curveEaseIn],
                    animations: {
                        icon.center = destinationPos
                        icon.frame.size = destinationSize
                }) {
                    _ in
                    cell.icon.alpha = 1
                    icon.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
            }
        }
    }
}
