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
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
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
                
                UIView.animate(withDuration: animDuration / 2, animations: {
                    fromVC.view.alpha = 0
                }) {
                    _ in
                    fromVC.view.removeFromSuperview()
                }
                
                UIView.animate(
                    withDuration: animDuration,
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
            } else if let vc_1 = fromVC as? SurveysViewController, let stackVC = vc_1.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview, let vc_2 = toVC as? SurveyViewController {
                vc_1.view.setNeedsLayout()
                vc_1.view.layoutIfNeeded()
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
//                let icon = SurveyCategoryIcon(frame: surveyPreview.icon.frame)
//                icon.isOpaque = false
//                icon.categoryID = surveyPreview.icon.categoryID
//                icon.tagColor = surveyPreview.icon.tagColor
//                icon.frame.origin = containerView.convert(surveyPreview.icon.frame.origin, from: surveyPreview)
//                let iconDestinationSize = cell.icon.frame.size
//                var iconDestinationPos = containerView.convert(cell.icon.center, from: cell.iconContainer)
//                iconDestinationPos.x -= iconDestinationSize.width / 2 - icon.frame.size.width / 2
//                iconDestinationPos.y -= iconDestinationSize.height / 2 - icon.frame.size.height / 2
                
                let userImage = UIImageView(frame: CGRect(origin: .zero, size: surveyPreview.userImage.frame.size))
                userImage.image = surveyPreview.userImage.image
                var pos = CGPoint.zero
                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                userImage.center = pos
                
                toVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
//                containerView.addSubview(icon)
                UIApplication.shared.keyWindow?.addSubview(userImage)
                surveyPreview.userImage.alpha = 0
//                surveyPreview.icon.alpha = 0
                let userImageDestinationSize = vc_2.navTitleSize//vc_2.navTitle.frame.size
                var userImageDestinationPos = navigationController.navigationBar.center
                userImageDestinationPos.x -= userImageDestinationSize.width / 2 - userImage.frame.size.width / 2
                userImageDestinationPos.y -= userImageDestinationSize.height / 2 - userImage.frame.size.height / 2
                
                UIView.animate(withDuration: duration * 0.8, delay: 0, options: .curveEaseInOut, animations: {
                    vc_1.buttonsContainer.alpha = 0
                    surveyPreview.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    surveyPreview.alpha = 0
                })
                
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
                    userImage.center = userImageDestinationPos
                    userImage.frame.size = userImageDestinationSize
                })
                
                UIView.animate(withDuration: duration * 1.2, delay: duration/3, options: [.curveEaseOut], animations: {
                    toVC.view.transform = .identity
                    toVC.view.alpha = 1
                }) {
                    _ in
                    vc_2.navTitle = userImage.copyView()
                    userImage.removeFromSuperview()
                    //                    icon.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    surveyPreview.userImage.alpha = 1
                    surveyPreview.icon.alpha = 1
                    surveyPreview.transform = .identity
                    surveyPreview.alpha = 1
                    vc_1.buttonsContainer.alpha = 1
                    self.context?.completeTransition(true)
                }
                //                UIView.animate(
                //                    withDuration: duration * 1.3,
                //                    delay: 0,
                //                    usingSpringWithDamping: 0.7,
                //                    initialSpringVelocity: 0.7,
                //                    options: [.curveEaseInOut],
                //                    animations: {
                //                        userImage.center = destinationPos
                //                        userImage.frame.size = destinationSize
                //                }) {
                //                    _ in
                //                    userImage.removeFromSuperview()
                //                    backgroundView.removeFromSuperview()
                //                    cardView.removeFromSuperview()
                //                    fromVC.view.removeFromSuperview()
                //                    vc_2.navTitle = userImage//.copyView()
                ////                    self.navigationController.navigationItem.titleView = userImage
                ////                    vc_2.navTitle.alpha = 1
                //                    surveyPreview.userImage.alpha = 1
                //                    self.context?.completeTransition(true)
                //                }
            } else if let vc_1 = fromVC as? SurveysViewController, let stackVC = vc_1.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview, let vc_2 = toVC as? UserViewController {
                vc_1.view.setNeedsLayout()
                vc_1.view.layoutIfNeeded()
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let userImage = UIImageView(frame: CGRect(origin: .zero, size: surveyPreview.userImage.frame.size))
                userImage.image = vc_2.header.imageView.image//surveyPreview.userImage.image
                var pos = CGPoint.zero
                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                userImage.center = pos
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                UIApplication.shared.keyWindow?.addSubview(userImage)
                surveyPreview.userImage.alpha = 0
                vc_2.header.imageView.alpha = 0
                let userImageDestinationSize = vc_2.header.imageView.frame.size
                
                var userImageDestinationPos = UIApplication.shared.keyWindow!.convert(vc_2.header.imageView.center, from: vc_2.view)
                userImageDestinationPos.x -= userImageDestinationSize.width / 2 - userImage.frame.size.width / 2
                userImageDestinationPos.y -= userImageDestinationSize.height / 2 - userImage.frame.size.height / 2
                
//                UIView.animate(withDuration: duration * 0.6, delay: 0, options: .curveEaseInOut, animations: {
//                    vc_1.buttonsContainer.alpha = 0
//                    surveyPreview.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
//                    surveyPreview.alpha = 0
//                })
                let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                effectViewOutgoing.frame = vc_1.view.bounds
                effectViewOutgoing.addEquallyTo(to: vc_1.view)
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
                    effectViewOutgoing.effect = nil
                })
                let effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
                effectViewIncoming.frame = vc_2.view.bounds
                effectViewIncoming.addEquallyTo(to: vc_2.view)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration * 1.3 + duration * 0.25, delay: 0, options: [.curveEaseInOut], animations: {
                    userImage.center = userImageDestinationPos
                    userImage.frame.size = userImageDestinationSize
                })
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
                    effectViewOutgoing.effect = UIBlurEffect(style: .prominent)
                    vc_1.view.alpha = 0
                }) {
                    _ in
                    effectViewOutgoing.removeFromSuperview()
                }
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration * 1.3, delay: duration * 0.25, options: [.curveLinear], animations: {
                    effectViewIncoming.effect = nil
                    vc_2.view.alpha = 1
                }) {
                    _ in
                    vc_2.header.imageView.alpha = 1
                    userImage.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    surveyPreview.userImage.alpha = 1
                    effectViewIncoming.removeFromSuperview()
                    self.context?.completeTransition(true)
                }

            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? CategorySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: vc_1.categoryIcon.frame.size))
                icon.text = "?"
                if vc_1.category != nil {
                    icon.tagColor = vc_1.category!.tagColor
                    icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: vc_1.category!.ID) ?? .Text
                } else {
                    icon.tagColor = K_COLOR_RED
                    icon.categoryID = .Text
                }
                icon.isOpaque = false
                let pos = vc_1.categoryIcon.convert(vc_1.categoryIcon.center, to: navigationController?.view)
                icon.center = pos
                
                vc_2.categoryVC.returnPos = pos
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                vc_1.categoryIcon.alpha = 0
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                let bgIcon = SurveyCategoryIcon(frame: icon.frame)
                bgIcon.text = "?"
                bgIcon.tagColor = K_COLOR_GRAY
                bgIcon.categoryID = .Text
                bgIcon.alpha = 0
                bgIcon.isOpaque = false
                bgIcon.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(bgIcon)
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon.center = destinationPos
                    bgIcon.frame.size = destinationSize
                    bgIcon.alpha = 1
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        bgIcon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }

            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? AnonimitySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                let icon = SurveyCategoryIcon(frame: CGRect(origin: vc_1.anonIcon.convert(vc_1.anonIcon.frame.origin, to: navigationController?.view), size: vc_1.anonIcon.frame.size))
                icon.text = "?"
                icon.tagColor = vc_1.anonIcon.tagColor
                icon.categoryID = vc_1.anonIcon.categoryID
                icon.isOpaque = false
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                vc_1.anonIcon.alpha = 0
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                let bgIcon = SurveyCategoryIcon(frame: icon.frame)
                bgIcon.text = "?"
                bgIcon.tagColor = K_COLOR_GRAY
                bgIcon.categoryID = .Text
                bgIcon.alpha = 0
                bgIcon.isOpaque = false
                bgIcon.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(bgIcon)
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon.center = destinationPos
                    bgIcon.frame.size = destinationSize
                    bgIcon.alpha = 1
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        bgIcon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
                
                
//                UIView.animate(withDuration: duration / 2, animations: {
//                    fromVC.view.alpha = 0
//                }) {
//                    _ in
//                    fromVC.view.removeFromSuperview()
//                }
//
//                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
//                    toVC.view.alpha = 1
//                    icon.center = destinationPos
//                    icon.frame.size = destinationSize
//                }) {
//                    _ in
//                    destinationIcon.alpha = 1
//                    UIView.animate(withDuration: self.duration / 2, delay: 0, options: [.curveEaseIn], animations: {
//                        icon.alpha = 0
//                    }) {
//                        _ in
//                        icon.removeFromSuperview()
//                        self.context?.completeTransition(true)
//                    }
//                }
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? PrivacySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                let icon = SurveyCategoryIcon(frame: CGRect(origin: vc_1.privacyIcon.convert(vc_1.privacyIcon.frame.origin, to: navigationController?.view), size: vc_1.privacyIcon.frame.size))
                icon.text = "?"
                icon.tagColor = vc_1.privacyIcon.tagColor
                icon.categoryID = vc_1.privacyIcon.categoryID
                icon.isOpaque = false
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                vc_1.privacyIcon.alpha = 0
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                let bgIcon = SurveyCategoryIcon(frame: icon.frame)
                bgIcon.text = "?"
                bgIcon.categoryID = .Text
                bgIcon.tagColor = K_COLOR_GRAY
                bgIcon.alpha = 0
                bgIcon.isOpaque = false
                bgIcon.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(bgIcon)
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon.center = destinationPos
                    bgIcon.frame.size = destinationSize
                    bgIcon.alpha = 1
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        bgIcon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? VotesCountViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                let icon = SurveyCategoryIcon(frame: CGRect(origin: vc_1.privacyIcon.convert(vc_1.privacyIcon.frame.origin, to: navigationController?.view), size: vc_1.privacyIcon.frame.size))
                icon.text = "?"
                icon.tagColor = vc_1.privacyIcon.tagColor
                icon.categoryID = vc_1.privacyIcon.categoryID
                icon.isOpaque = false
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                vc_1.privacyIcon.alpha = 0
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                let bgIcon = SurveyCategoryIcon(frame: icon.frame)
                bgIcon.text = "?"
                bgIcon.categoryID = .Text
                bgIcon.tagColor = K_COLOR_GRAY
                bgIcon.alpha = 0
                bgIcon.isOpaque = false
                bgIcon.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(bgIcon)
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon.center = destinationPos
                    bgIcon.frame.size = destinationSize
                    bgIcon.alpha = 1
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        bgIcon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            }
        } else if operation == .pop {
            if let vc_1 = fromVC as? SubcategoryViewController, let initialIcon = vc_1.icon, let vc_2 = toVC as? SurveysViewController, let collVC = vc_2.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
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
                UIView.animate(withDuration: animDuration,
                               delay: 0,
                               options: .curveLinear, animations: {
                                toVC.view.alpha = 1
                })
                UIView.animate(withDuration: animDuration / 2, animations: {
                    fromVC.view.alpha = 0
                }) {
                    _ in
                    fromVC.view.removeFromSuperview()
                }
                UIView.animate(
                    withDuration: animDuration,
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
            } else if let vc_1 = fromVC as? SurveyViewController, let vc_2 = toVC as? SurveysViewController, let stackVC = vc_2.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview {

                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                vc_2.buttonsContainer.alpha = 0
                let userImage = UIImageView(frame: CGRect(origin: vc_1.navigationController!.navigationBar.center, size: vc_1.navTitleSize))//surveyPreview.userImage.frame.size))
                userImage.center = navigationController.navigationBar.center
                userImage.image = vc_1.navTitle.image
                vc_1.navigationController!.navigationItem.titleView = nil
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                UIApplication.shared.keyWindow?.addSubview(userImage)
                
                surveyPreview.alpha = 0
                surveyPreview.userImage.alpha = 0
                surveyPreview.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                
                let userImageDestinationSize = surveyPreview.userImage.frame.size//vc_2.navTitle.frame.size
                var userImageDestinationPos = UIApplication.shared.keyWindow!.convert(surveyPreview.userImage.center, from: vc_2.surveyStackVC.view)//navigationController.navigationBar.center
                userImageDestinationPos.x += userImageDestinationSize.width / 4 - userImage.frame.size.width / 4
                userImageDestinationPos.y += userImageDestinationSize.height / 2 - userImage.frame.size.height / 2
                
                UIView.animate(withDuration: duration / 2, delay: 0, options: .curveEaseInOut, animations: {
                    vc_2.buttonsContainer.alpha = 1
                    vc_1.view.alpha = 0
                    vc_1.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
                
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
                    userImage.center = userImageDestinationPos
                    userImage.frame.size = userImageDestinationSize
                    surveyPreview.transform = .identity
                    surveyPreview.alpha = 1
                })
                
                UIView.animate(withDuration: self.duration * 1.4, delay: 0, options: [.curveEaseInOut], animations: {
                    toVC.view.transform = .identity
                    toVC.view.alpha = 1
                }) {
                    _ in
                    userImage.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    surveyPreview.userImage.alpha = 1
                    vc_1.view.transform = .identity
//                    surveyPreview.icon.alpha = 1
//                    surveyPreview.transform = .identity
//                    surveyPreview.alpha = 1
//                    vc_1.buttonsContainer.alpha = 1
                    self.context?.completeTransition(true)
                }
                
//                var pos = CGPoint.zero
//                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
//                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
//                userImage.center = pos
                
                
                
                
//                context?.completeTransition(true)
            } else if let vc_1 = fromVC as? UserViewController, let vc_2 = toVC as? SurveysViewController, let stackVC = vc_2.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview {
                vc_1.view.setNeedsLayout()
                vc_1.view.layoutIfNeeded()
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let userImage = UIImageView(frame: CGRect(origin: containerView.convert(vc_1.header.imageView.frame.origin, from: vc_1.header), size: vc_1.header.imageView.frame.size))
                userImage.image = vc_1.header.imageView.image
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(userImage)
                vc_1.header.imageView.alpha = 0
                surveyPreview.userImage.alpha = 0
//                toVC.tabBarController?.setTabBarVisible(visible: true, animated: true)
                let destinationSize = surveyPreview.userImage.frame.size
                var destinationPos = containerView.convert(surveyPreview.userImage.center, from: surveyPreview)
                destinationPos.x += userImage.frame.size.width / 2 - destinationSize.width / 2
                destinationPos.y += userImage.frame.size.height / 2 - destinationSize.height / 2
                
                
                let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                effectViewOutgoing.frame = vc_1.view.bounds
                effectViewOutgoing.addEquallyTo(to: vc_1.view)
                toVC.tabBarController?.setTabBarVisible(visible: true, animated: true)
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
                    effectViewOutgoing.effect = nil
                })
                let effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
                effectViewIncoming.frame = vc_2.view.bounds
                effectViewIncoming.addEquallyTo(to: vc_2.view)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration * 1.3 + duration * 0.25, delay: 0, options: [.curveEaseInOut], animations: {
                    userImage.center = destinationPos
                    userImage.frame.size = destinationSize
                })
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
                    effectViewOutgoing.effect = UIBlurEffect(style: .prominent)
                    vc_1.view.alpha = 0
                }) {
                    _ in
                    effectViewOutgoing.removeFromSuperview()
                }
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration * 1.3, delay: duration * 0.25, options: [.curveEaseOut], animations: {
                    effectViewIncoming.effect = nil
                    vc_2.view.alpha = 1
                }) {
                    _ in
                    userImage.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    surveyPreview.userImage.alpha = 1
                    effectViewIncoming.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
                
                
//                UIView.animate(withDuration: duration*0.8, delay: 0, options: [.curveEaseOut], animations: {
//                    userImage.center = destinationPos
//                    userImage.frame.size = destinationSize
//                    vc_1.view.alpha = 0
//                })
//
//                UIView.animate(withDuration: duration, delay: duration/3, options: [.curveEaseInOut], animations: {
//                    toVC.view.alpha = 1
//                }) {
//                    _ in
//                    userImage.removeFromSuperview()
//                    fromVC.view.removeFromSuperview()
//                    surveyPreview.userImage.alpha = 1
//                    self.context?.completeTransition(true)
//                }
                
            } else if let vc_1 = fromVC as? CategorySelectionViewController, let collectionVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collectionVC.currentIndex as? IndexPath, let cell = collectionVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let initialIcon = cell.icon, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.categoryIcon {
                
                
//                let animDuration = duration + Double(indexPath.row / 3 ) / 20
                var icon: SurveyCategoryIcon!
                if vc_1.isModified {
                    icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: initialIcon.frame.size))
                    icon.categoryID = initialIcon.categoryID
                    icon.isOpaque = false
                    var pos = cell.icon.convert(cell.icon.center, to: navigationController?.view)
                    pos.x -= collectionVC.sectionInsets.left * 1.5
                    pos.y -= collectionVC.sectionInsets.top * 2
                    icon.center = pos//initialIcon.convert(initialIcon.center, to: navigationController?.view)
                    icon.tagColor = initialIcon.tagColor
                } else {
                    icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: vc_1.actionButton.frame.size))
                    icon.categoryID = vc_1.actionButton.categoryID
                    icon.isOpaque = false
                    icon.tagColor = vc_1.actionButton.tagColor
                    var pos = CGPoint.zero
                    pos.x = vc_1.actionButton.center.x
                    pos.y = vc_1.actionButton.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                    icon.center = pos//vc_1.actionButton.convert(vc_1.actionButton.center, to: navigationController?.view)
                }
                
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                initialIcon.alpha = 0//vc_1.isModified ? 0 : 1
                vc_2.categoryTitle.text = ""
                
                let destinationSize = destinationIcon.frame.size
                var destinationPos = collectionVC.returnPos
                destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                fromVC.view.alpha = 0
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    vc_2.category = vc_1.category
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }

            } else if let vc_1 = fromVC as? AnonimitySelectionViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.anonIcon {
                let initialIcon: SurveyCategoryIcon = vc_1.isAnonymous ? vc_1.anonEnabledIcon : vc_1.anonDisabledIcon
                let icon = SurveyCategoryIcon(frame: CGRect(origin: initialIcon.superview!.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size))
                icon.categoryID = initialIcon.categoryID
                icon.isOpaque = false
                icon.tagColor = initialIcon.tagColor
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                
                destinationIcon.tagColor = initialIcon.tagColor
                destinationIcon.categoryID = initialIcon.categoryID
                destinationIcon.setNeedsDisplay()
                
                let destinationSize = destinationIcon.frame.size
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                if destinationSize > icon.frame.size {
                    destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                } else {
                    destinationPos.x -= icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y -= icon.frame.size.height / 2 - destinationSize.height / 2
                }

                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    vc_2.isAnonymous = vc_1.isAnonymous
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
                
            } else if let vc_1 = fromVC as? PrivacySelectionViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.privacyIcon {
                let initialIcon: SurveyCategoryIcon = vc_1.isPrivate ? vc_1.privacyEnabledIcon : vc_1.privacyDisabledIcon
                let icon = SurveyCategoryIcon(frame: CGRect(origin: initialIcon.superview!.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size))
                icon.categoryID = initialIcon.categoryID
                icon.isOpaque = false
                icon.tagColor = initialIcon.tagColor
                toVC.view.alpha = 0
                containerView.addSubview(toVC.view)
                containerView.addSubview(icon)
                
                destinationIcon.tagColor = initialIcon.tagColor
                destinationIcon.categoryID = initialIcon.categoryID
                destinationIcon.setNeedsDisplay()
                
                let destinationSize = destinationIcon.frame.size
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                if destinationSize > icon.frame.size {
                    destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                } else {
                    destinationPos.x -= icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y -= icon.frame.size.height / 2 - destinationSize.height / 2
                }
                fromVC.view.alpha = 0
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlock: animationBlock) {
                    _ in
                    destinationIcon.alpha = 1
                    vc_2.isPrivate = vc_1.isPrivate
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            } else {
                context?.completeTransition(true)
            }
        }
    }
    
    private func animateWithBlurEffect(fromView: UIView, toView: UIView, animationBlock: Closure?, completion: @escaping(Bool)->()) {
        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectViewOutgoing.frame = fromView.bounds
        effectViewOutgoing.addEquallyTo(to: fromView)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
            effectViewOutgoing.effect = nil
        })
        let effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        effectViewIncoming.frame = toView.bounds
        effectViewIncoming.addEquallyTo(to: toView)
        let delay = duration * 0.25
        
        if animationBlock != nil {
            animationBlock!()
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration - delay, delay: 0, options: [.curveLinear], animations: {
            fromView.alpha = 0
            effectViewOutgoing.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            effectViewOutgoing.removeFromSuperview()
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            effectViewIncoming.effect = nil
//            effectViewOutgoing.effect = UIBlurEffect(style: .light)
            toView.alpha = 1
//            fromView.alpha = 0
        }) {
            _ in
//            effectViewOutgoing.removeFromSuperview()
            effectViewIncoming.removeFromSuperview()
            fromView.removeFromSuperview()
            completion(true)
        }
    }
}


////
////  IconCircularTransition.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 25.08.2020.
////  Copyright © 2020 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class IconCircularTransition: NSObject, UIViewControllerAnimatedTransitioning {
//
//    var operation: UINavigationController.Operation!
//    var navigationController: NavigationControllerPreloaded!
//    var duration: TimeInterval = 0.3
//
//    init(_ _navigationController: NavigationControllerPreloaded, _ _operation: UINavigationController.Operation, _ _duration: TimeInterval) {
//        navigationController = _navigationController
//        operation = _operation
//        duration = _duration
//    }
//
//    weak var context: UIViewControllerContextTransitioning?
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return duration
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        guard let fromVC = transitionContext.viewController(forKey: .from),
//            let toVC = transitionContext.viewController(forKey: .to) else {
//                transitionContext.completeTransition(false)
//                return
//        }
//
//        let containerView = transitionContext.containerView
//        context = transitionContext
//        if operation == .push {
//            if let vc_1 = fromVC as? SurveysViewController, let collVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let vc_2 = toVC as? SubcategoryViewController, let destinationIcon = vc_2.icon {
//                let animDuration = duration + Double(indexPath.row / 3 ) / 20
//                vc_2.view.setNeedsLayout()
//                vc_2.view.layoutIfNeeded()
//                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: cell.icon.frame.size))
//                icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: cell.category.ID) ?? .Null
//                icon.isOpaque = false
//                var pos = cell.icon.convert(cell.icon.center, to: navigationController?.view)
//                pos.x -= collVC.sectionInsets.left * 1.5
//                pos.y -= collVC.sectionInsets.top * 2
//                collVC.returnPos = pos
//                icon.center = pos
//                icon.tagColor = cell.category.tagColor
//
//                toVC.view.alpha = 0
//                containerView.addSubview(toVC.view)
//                containerView.addSubview(icon)
//                destinationIcon.alpha = 0
//                cell.icon.alpha = 0
//                var destinationPos: CGPoint = .zero
//                let destinationSize = destinationIcon.frame.size
//                destinationPos.x = destinationIcon.center.x
//                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
//                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
//                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
//
//                UIView.animate(withDuration: animDuration / 2, animations: {
//                    fromVC.view.alpha = 0
//                }) {
//                    _ in
//                    fromVC.view.removeFromSuperview()
//                }
//
//                UIView.animate(
//                    withDuration: animDuration,
//                    delay: 0,
//                    usingSpringWithDamping: 0.7,
//                    initialSpringVelocity: 0.7,
//                    options: [.curveEaseOut],
//                    animations: {
//                        toVC.view.alpha = 1
//                        icon.center = destinationPos
//                        icon.frame.size = destinationSize
//                }) {
//                    _ in
//                    destinationIcon.alpha = 1
//                    icon.removeFromSuperview()
//                    self.context?.completeTransition(true)
//                }
//            } else if let vc_1 = fromVC as? SurveysViewController, let stackVC = vc_1.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview ,let vc_2 = toVC as? SurveyViewController {
//                vc_1.view.setNeedsLayout()
//                vc_1.view.layoutIfNeeded()
//
//                let backgroundView = UIView(frame: fromVC.view.frame)
//                backgroundView.backgroundColor = UIColor.groupTableViewBackground
//                backgroundView.alpha = 0
//                let cardView = UIView(frame: surveyPreview.contentView.frame)
//                cardView.cornerRadius = surveyPreview.contentView.cornerRadius
//                cardView.backgroundColor = .white
//                cardView.alpha = 1
//                cardView.frame.origin = containerView.convert(surveyPreview.frame.origin, from: vc_1.container)
//                let userImage = UIImageView(frame: CGRect(origin: .zero, size: surveyPreview.userImage.frame.size))
//                userImage.image = surveyPreview.userImage.image
//                var pos = CGPoint.zero
//                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
//                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
//                userImage.center = pos
//                toVC.view.alpha = 0
//                containerView.addSubview(toVC.view)
//                containerView.addSubview(backgroundView)
//                containerView.addSubview(cardView)
//                UIApplication.shared.keyWindow?.addSubview(userImage)
//                surveyPreview.userImage.alpha = 0
//                let destinationSize = vc_2.navTitleSize//vc_2.navTitle.frame.size
//                var destinationPos = navigationController.navigationBar.center
//                destinationPos.x -= destinationSize.width / 2 - userImage.frame.size.width / 2
//                destinationPos.y -= destinationSize.height / 2 - userImage.frame.size.height / 2
////                vc_2.navTitle.alpha = 0
////                navigationController.navigationItem.titleView?.alpha = 0
//                UIView.animate(withDuration: duration / 1.7, delay: 0, options: .curveEaseInOut, animations: {
//                    backgroundView.alpha = 1
//                    cardView.frame = CGRect(origin: CGPoint(x: toVC.view.frame.origin.x - surveyPreview.contentView.cornerRadius, y: toVC.view.frame.origin.y - surveyPreview.contentView.cornerRadius), size: CGSize(width: toVC.view.frame.size.width + surveyPreview.contentView.cornerRadius, height: toVC.view.frame.size.height + surveyPreview.contentView.cornerRadius))//toVC.view.frame
//                }) {
//                    _ in
//                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//                        toVC.view.alpha = 1
//                    }) {
//                        _ in
//
//                    }
//                }
//
//                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
//                    userImage.center = destinationPos
//                    userImage.frame.size = destinationSize
//                }) {
//                    _ in
//                    userImage.removeFromSuperview()
//                    backgroundView.removeFromSuperview()
//                    cardView.removeFromSuperview()
//                    fromVC.view.removeFromSuperview()
//                    vc_2.navTitle = userImage//.copyView()
//                    //                    self.navigationController.navigationItem.titleView = userImage
//                    //                    vc_2.navTitle.alpha = 1
//                    surveyPreview.userImage.alpha = 1
//                    self.context?.completeTransition(true)
//                }
//
////                UIView.animate(
////                    withDuration: duration * 1.3,
////                    delay: 0,
////                    usingSpringWithDamping: 0.7,
////                    initialSpringVelocity: 0.7,
////                    options: [.curveEaseInOut],
////                    animations: {
////                        userImage.center = destinationPos
////                        userImage.frame.size = destinationSize
////                }) {
////                    _ in
////                    userImage.removeFromSuperview()
////                    backgroundView.removeFromSuperview()
////                    cardView.removeFromSuperview()
////                    fromVC.view.removeFromSuperview()
////                    vc_2.navTitle = userImage//.copyView()
//////                    self.navigationController.navigationItem.titleView = userImage
//////                    vc_2.navTitle.alpha = 1
////                    surveyPreview.userImage.alpha = 1
////                    self.context?.completeTransition(true)
////                }
//            }
//        } else if operation == .pop {
//            if let vc_1 = fromVC as? SubcategoryViewController, let initialIcon = vc_1.icon, let vc_2 = toVC as? SurveysViewController, let collVC = vc_2.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
//                let animDuration = duration + Double(indexPath.row / 3 ) / 20
//                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: initialIcon.frame.size))
//                icon.categoryID = initialIcon.categoryID
//                icon.isOpaque = false
//                var pos = initialIcon.convert(initialIcon.center, to: navigationController?.view)
//                pos.x = initialIcon.center.x
//                pos.y = initialIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
//                icon.center = pos
//                icon.tagColor = initialIcon.tagColor
//
//                toVC.view.alpha = 0
//                containerView.addSubview(toVC.view)
//                containerView.addSubview(icon)
//                toVC.tabBarController?.setTabBarVisible(visible: true, animated: true)
//                initialIcon.alpha = 0
//                let destinationSize = cell.icon.frame.size
//                var destinationPos = collVC.returnPos
//                destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
//                destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
//                UIView.animate(withDuration: animDuration,
//                               delay: 0,
//                               options: .curveLinear, animations: {
//                                toVC.view.alpha = 1
//                })
//                UIView.animate(withDuration: animDuration / 2, animations: {
//                    fromVC.view.alpha = 0
//                }) {
//                    _ in
//                    fromVC.view.removeFromSuperview()
//                }
//                UIView.animate(
//                    withDuration: animDuration,
//                    delay: 0,
//                    usingSpringWithDamping: 0.7,
//                    initialSpringVelocity: 0.7,
//                    options: [.curveEaseIn],
//                    animations: {
//                        icon.center = destinationPos
//                        icon.frame.size = destinationSize
//                }) {
//                    _ in
//                    cell.icon.alpha = 1
//                    icon.removeFromSuperview()
//                    self.context?.completeTransition(true)
//                }
//            } else {
//                context?.completeTransition(true)
//            }
//        }
//    }
//}
