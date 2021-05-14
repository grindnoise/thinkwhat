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
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        
        func animateIconStyleTransition(initialIcon: SurveyCategoryIcon, destinationIcon: SurveyCategoryIcon, origin: CGPoint, text: String, iconChange: Bool = false, animationBlocks: [Closure], completionBlocks: [Closure], useIncomingEffect: Bool = true, completeTransition: Bool = true) {
            if operation == .push {
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                let icon = initialIcon.copyView() as! SurveyCategoryIcon
                icon.frame.origin = origin
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                initialIcon.alpha = 0
                var destinationPos = destinationIcon.superview!.convert(destinationIcon.center, to: navigationController?.view)//destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                if destinationSize != icon.frame.size {
                    //                destinationPos.x = destinationIcon.center.x
                    destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                    //                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                    destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                }
                
                var animBlocks: [Closure] = []
                animBlocks.append { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    icon.backgroundColor = destinationIcon.backgroundColor
                }) }
                
                if iconChange {
                    if let shapeLayer = destinationIcon.icon as? CAShapeLayer, let destinationPath = shapeLayer.path {
                        let pathAnim = Animations.get(property: .Path, fromValue: (initialIcon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration * 0.8, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                        animBlocks.append {
                            icon.icon.add(pathAnim, forKey: nil)
                            (icon.icon as! CAShapeLayer).path = destinationPath
                        }
                    } else if let textLayer = destinationIcon.icon as? CATextLayer {
                        
                    }
                }
                animBlocks += animationBlocks
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animBlocks, useIncomingEffect: useIncomingEffect) {
                    _ in
                    completionBlocks.map { $0() }
                    destinationIcon.alpha = 1
                    icon.removeFromSuperview()
                    if completeTransition { self.context?.completeTransition(true) }
                }
            } else {
                
            }
        }
        
        
        if operation == .push {
            if let vc_1 = fromVC as? SurveysViewController, let collVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let vc_2 = toVC as? SubcategoryViewController, let destinationIcon = vc_2.icon {
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
                //                duration = animDuration
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let icon = cell.icon.copyView() as! SurveyCategoryIcon
                var pos = cell.icon.convert(cell.icon.center, to: navigationController?.view)
                pos.x -= collVC.sectionInsets.left * 1.5
                pos.y -= collVC.sectionInsets.top * 2
                
                icon.center = pos
                pos.x += 1
                collVC.returnPos = pos
                
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                cell.icon.alpha = 0
                var destinationPos: CGPoint = .zero
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                let animationBlock: Closure = {
                    UIView.animate(
                        withDuration: animDuration,
                        delay: 0,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.7,
                        options: [.curveEaseOut],
                        animations: {
                            icon.center = destinationPos
                            icon.frame.size = destinationSize
                    })
                }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock], useIncomingEffect: false) {
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
                
                let userImage = UIImageView(frame: CGRect(origin: .zero, size: surveyPreview.userImage.frame.size))
                userImage.image = surveyPreview.userImage.image
                var pos = CGPoint.zero
                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                userImage.center = pos
                
                toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIApplication.shared.keyWindow?.addSubview(userImage)
                surveyPreview.userImage.alpha = 0
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
                    fromVC.view.removeFromSuperview()
                    surveyPreview.userImage.alpha = 1
                    surveyPreview.icon.alpha = 1
                    surveyPreview.transform = .identity
                    surveyPreview.alpha = 1
                    vc_1.buttonsContainer.alpha = 1
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? SurveysViewController, let stackVC = vc_1.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview, let vc_2 = toVC as? UserViewController {
                vc_1.view.setNeedsLayout()
                vc_1.view.layoutIfNeeded()
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let userImage = UIImageView(frame: CGRect(origin: .zero, size: surveyPreview.userImage.frame.size))
                userImage.image = vc_2.header.imageView.image
                var pos = CGPoint.zero
                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                userImage.center = pos
                
                UIApplication.shared.keyWindow?.addSubview(userImage)
                surveyPreview.userImage.alpha = 0
                vc_2.header.imageView.alpha = 0
                let userImageDestinationSize = vc_2.header.imageView.frame.size
                
                var userImageDestinationPos = UIApplication.shared.keyWindow!.convert(vc_2.header.imageView.center, from: vc_2.view)
                userImageDestinationPos.x -= userImageDestinationSize.width / 2 - userImage.frame.size.width / 2
                userImageDestinationPos.y -= userImageDestinationSize.height / 2 - userImage.frame.size.height / 2
                
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
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.categoryIcon, let vc_2 = toVC as? CategorySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                //                vc_2.containerCenterYConstraint.constant += 800//vc_2.containerBg.bounds.height
                
                let icon = initialIcon.icon.copyView() as! SurveyCategoryIcon
                
                let pos = initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view)
                icon.frame.origin = pos
                
                vc_2.categoryVC.returnPos = pos
                
                
                containerView.addSubview(icon)
                initialIcon.icon.alpha = 0
                destinationIcon.alpha = 0
                //                toVC.view.alpha = 1
                vc_2.containerBg.alpha = 1
                let destinationPos = destinationIcon.convert(destinationIcon.icon.frame.origin, to: navigationController?.view)
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPath = (destinationIcon.icon.icon as! CAShapeLayer).path
                let pathAnim = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration * 0.8, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                
                var animationBlock: [Closure] = []
                animationBlock.append { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.9, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.frame.origin = destinationPos
                    icon.frame.size = destinationSize
                    icon.backgroundColor = destinationIcon.icon.backgroundColor
                    vc_2.view.setNeedsLayout()
                    vc_2.containerTopConstraint.constant -= vc_2.containerBg.frame.height
                    vc_2.view.layoutIfNeeded()
                }) }
                animationBlock.append {
                    icon.icon.add(pathAnim, forKey: nil)
                    (icon.icon as! CAShapeLayer).path = destinationPath
                }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlock, useIncomingEffect: false) {
                    _ in
                    destinationIcon.alpha = 1
                    icon.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? BinarySelectionViewController, let initialIcon = vc_2.selectionType == .Anonimity ? vc_1.anonIcon : vc_1.privacyIcon, let destinationIcon = vc_2.actionButton {
                
                var animationBlocks: [Closure] = []
                //                vc_2.view.alpha = 1
                animationBlocks.append {
                    UIView.animate(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                        vc_2.view.setNeedsLayout()
                        vc_2.leftConstraint.constant = 0
                        vc_2.rightConstraint.constant = 0
                        vc_2.view.layoutIfNeeded()
                    })
                }
                
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view), text: "?", iconChange: true, animationBlocks: animationBlocks, completionBlocks: [], useIncomingEffect: false)
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.votesIcon, let vc_2 = toVC as? VotesCountViewController, let destinationIcon = vc_2.actionButton {
                
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view), text: "?", iconChange: false, animationBlocks: [], completionBlocks: [])//, useIncomingEffect: false)
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.hyperlinkIcon, let initialLabel = vc_1.hyperlinkLabel, let vc_2 = toVC as? HyperlinkSelectionViewController, let destinationIcon = vc_2.actionButton, let destinationLabel = vc_2.hyperlinkLabel, let initialColor = initialLabel.backgroundColor {
                
                vc_2.contentView.alpha = 0
                vc_2.contentView.backgroundColor = initialLabel.backgroundColor
                vc_2.contentView.cornerRadius = initialLabel.cornerRadius
                
                let tempFrame = UIView(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempFrame.backgroundColor = vc_2.contentView.backgroundColor
                tempFrame.cornerRadius = initialLabel.cornerRadius
                containerView.addSubview(tempFrame)

                initialLabel.backgroundColor = .clear
                
                let destinationPos = vc_2.view.convert(vc_2.contentView.frame.origin, to: navigationController?.view)
                let destinationSize = vc_2.contentView.frame.size
                
                let destinationLabelCenter = destinationLabel.superview!.convert(destinationLabel.center, to: navigationController?.view)
                
                var animationBlocks: [Closure] = []
                
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                        
                        tempFrame.frame.origin = destinationPos
                        tempFrame.frame.size = destinationSize

                    }) {
                        _ in
                        tempFrame.removeFromSuperview()
                        initialLabel.backgroundColor = initialColor
                        vc_2.contentView.alpha = 1
                        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
                            vc_2.stackView.alpha = 1
                        }) {
                            _ in
                            self.context?.completeTransition(true)
                        }
                    }
                }
                
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view), text: "", iconChange: true, animationBlocks: animationBlocks, completionBlocks: [], useIncomingEffect: false, completeTransition: false)
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.imagesHeaderIcon, let vc_2 = toVC as? ImagesSelectionViewController, let destinationIcon = vc_2.actionButton {
                
                let text = vc_1.images.isEmpty ? "?" : "OK"
                let tempIconText = vc_1.images.isEmpty ? "ПРОПУСТИТЬ" : "OK"
                let tempIconTextSize: CGFloat = vc_1.images.isEmpty ? 26 : 43
                
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: vc_1.contentView.convert(initialIcon.center, to: navigationController?.view), text: text, animationBlocks: [], completionBlocks: [])
                
            }  else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? TextInputViewController, let initialLabel = vc_2.accessibilityIdentifier == "Title" ? vc_1.titleLabel : vc_1.questionLabel, let initialIcon = vc_2.accessibilityIdentifier == "Title" ? vc_1.titleIcon : vc_1.questionIcon, let destinationLabel = vc_2.frameView {
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                destinationLabel.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempFrame.backgroundColor = destinationLabel.backgroundColor
                tempFrame.cornerRadius = initialLabel.cornerRadius
                let tempLabel = PaddingLabel(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempLabel.leftInset = (initialLabel as? PaddingLabel)?.leftInset ?? 0
                tempLabel.rightInset = (initialLabel as? PaddingLabel)?.rightInset ?? 0
                tempLabel.topInset = (initialLabel as? PaddingLabel)?.topInset ?? 0
                tempLabel.bottomInset = (initialLabel as? PaddingLabel)?.bottomInset ?? 0
                tempLabel.backgroundColor = .clear
                tempLabel.textAlignment = initialLabel.textAlignment
                tempLabel.text = initialLabel.text
                tempLabel.font = initialLabel.font
                tempLabel.textColor = initialLabel.textColor
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempLabel)
                initialLabel.alpha = 0
                
                let icon = CircleButton(frame: CGRect(origin: vc_1.contentView.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size))
                icon.color = initialIcon.color
                icon.lineWidth = initialIcon.lineWidth
                icon.category = initialIcon.category
                icon.state = .On
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                let destinationPos = vc_2.view.convert(destinationLabel.frame.origin, to: navigationController?.view)
                let destinationSize = CGSize(width: destinationLabel.frame.size.width, height: vc_2.frameHeight.constant)
                
                var animationBlocks: [Closure] = []
                
                vc_2.hideKBIcon.alpha = 0
                vc_2.okButton.alpha = 0
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                        icon.frame.origin = CGPoint(x: containerView.frame.width/2 - icon.frame.width/2, y: destinationPos.y - icon.frame.height/2)
                        icon.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        icon.icon.backgroundColor = icon.color.withAlphaComponent(0.2)
                        tempFrame.frame.origin = destinationPos
                        tempFrame.frame.size = destinationSize
                        tempLabel.frame.origin = destinationPos
                        tempLabel.frame.size = destinationSize
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        UIView.animate(withDuration: 0.2, delay: 0.12, options: [.curveLinear], animations: {
                            destinationLabel.alpha = 1
                            tempLabel.alpha = 0
                            tempFrame.alpha = 0
                            vc_2.hideKBIcon.alpha = 1
                            vc_2.okButton.alpha = 1
                        }) {
                            _ in
                            initialIcon.alpha = 1
                            tempLabel.removeFromSuperview()
                            tempFrame.removeFromSuperview()
                            self.context?.completeTransition(true)
                        }
                        
                    }
                }
                animationBlocks.append {
                    icon.addDisableAnimation()
                }
                
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks, useIncomingEffect: false) { _ in }
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? ImageViewController {
                print(vc_2)
            }
            
        } else if operation == .pop {
            if let vc_1 = fromVC as? SubcategoryViewController, let initialIcon = vc_1.icon, let vc_2 = toVC as? SurveysViewController, let collVC = vc_2.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
                duration = animDuration
                let icon = initialIcon.copyView() as! SurveyCategoryIcon
                icon.center = fromVC.view.convert(initialIcon.center, to: containerView)
                
                containerView.addSubview(icon)
                toVC.tabBarController?.setTabBarVisible(visible: true, animated: true)
                initialIcon.alpha = 0
                let destinationSize = cell.icon.frame.size
                var destinationPos = collVC.returnPos
                destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                
                let animationBlock: Closure = {
                    UIView.animate(
                        withDuration: animDuration * 0.4,
                        delay: 0,
                        options: [.curveEaseOut],
                        animations: {
                            icon.center = destinationPos
                            icon.frame.size = destinationSize
                    })
                }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock], useIncomingEffect: false) {
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
                
            } else if let vc_1 = fromVC as? CategorySelectionViewController, let collectionVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collectionVC.currentIndex as? IndexPath, let cell = collectionVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let initialIcon = cell.icon, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.categoryIcon {
                
                vc_1.view.backgroundColor = .clear
                
                var center = initialIcon.convert(initialIcon.center, to: containerView)
                center.x -= collectionVC.sectionInsets.left * 1.5
                center.y -= collectionVC.sectionInsets.top * 2
                
                let icon = cell.icon.copyView() as! SurveyCategoryIcon
                icon.center = center
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                vc_2.contentView.alpha = 0
                vc_2.categoryTitle.text = ""
                vc_2.categoryIcon.color = vc_1.category!.tagColor!
                vc_2.selectedColor = vc_2.categoryIcon.color
                
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPos = collectionVC.returnPos
                
                let toValue = (icon.icon as! CAShapeLayer).path!.getScaledPath(size: destinationSize)
                let pathAnim        = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue  = (icon.icon as! CAShapeLayer).path
                pathAnim.toValue    = toValue
                pathAnim.duration   = self.duration * 0.8
                pathAnim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
                
                var effectView: UIVisualEffectView!
                effectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
                effectView.frame = vc_2.view.bounds
                effectView.addEquallyTo(to: vc_2.view)
                
                let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                effectViewOutgoing.frame = vc_1.actionButton.bounds
                effectViewOutgoing.addEquallyTo(to: vc_1.actionButton)
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
                    effectViewOutgoing.effect = nil
                })
                
                icon.icon.add(pathAnim, forKey: nil)
                (icon.icon as! CAShapeLayer).path = toValue
                
//                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration * 0.9, delay: 0, options: [.curveEaseInOut], animations: {
//                    vc_1.actionButton.alpha = 0
//                    vc_1.view.setNeedsLayout()
//                    vc_1.containerTopConstraint.constant += vc_1.containerBg.frame.height
//                    vc_1.view.layoutIfNeeded()
//
//                })
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
                    vc_1.actionButton.alpha = 0
                    vc_1.view.setNeedsLayout()
                    vc_1.containerTopConstraint.constant += vc_1.containerBg.frame.height
                    vc_1.view.layoutIfNeeded()
                    icon.frame.origin = destinationPos
                    icon.frame.size = destinationSize
                    vc_2.contentView.alpha = 1
                    effectViewOutgoing.effect = UIBlurEffect(style: .light)
                    effectView.effect = nil
                    vc_2.view.alpha = 1
                }) {
                    _ in
                    effectViewOutgoing.removeFromSuperview()
                    effectView.removeFromSuperview()
                    icon.removeFromSuperview()
                    destinationIcon.icon.alpha = 1
                    vc_1.actionButton.alpha = 1
                    vc_1.view.removeFromSuperview()
                    vc_2.category = vc_1.category
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? BinarySelectionViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_1.selectionType == .Anonimity ? vc_2.anonIcon : vc_2.privacyIcon {
                
                let initialIcon: SurveyCategoryIcon = vc_1.isEnabled! ? vc_1.enabledIcon : vc_1.disabledIcon
                
                let icon = initialIcon.copyView() as! SurveyCategoryIcon
                icon.center = initialIcon.superview!.convert(initialIcon.center, to: containerView)
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPos = destinationIcon.convert(destinationIcon.icon.frame.origin, to: navigationController?.view)
                
                let destinationPath = (icon.icon as! CAShapeLayer).path?.getScaledPath(size: destinationIcon.icon.frame.size)//(destinationIcon.icon.icon as! CAShapeLayer).path
                let pathAnim        = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration * 0.8, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                let fillColorAnim   = Animations.get(property: .FillColor, fromValue: UIColor.darkGray.cgColor as Any, toValue: UIColor.white.cgColor as Any, duration: duration * 0.9, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                        icon.frame.origin = destinationPos
                        icon.frame.size = destinationSize
                        icon.backgroundColor = vc_2.color
                    }) }
                animationBlocks.append {
                    icon.icon.add(pathAnim, forKey: nil)
                    (icon.icon as! CAShapeLayer).path = destinationPath
                    icon.icon.add(fillColorAnim, forKey: nil)
                }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlocks) {
                    _ in
                    destinationIcon.alpha = 1
                    destinationIcon.icon.alpha = 1
                    destinationIcon.category = initialIcon.category
                    
                    if vc_1.selectionType == .Anonimity {
                        vc_2.isAnonymous = vc_1.isEnabled!
                    } else {
                        vc_2.isPrivate = vc_1.isEnabled!
                    }
                    
                    initialIcon.alpha = 1
                    icon.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? VotesCountViewController, let initialIcon = vc_1.actionButton as? CircleButton, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.votesIcon {
                
                let icon = initialIcon.icon.copyView() as! SurveyCategoryIcon
                icon.center = initialIcon.superview!.convert(initialIcon.center, to: containerView)
                vc_1.actionButton.alpha = 0
                containerView.addSubview(icon)
                
                destinationIcon.color    = vc_1.actionButton.color
                destinationIcon.category = vc_1.actionButton.category
                destinationIcon.text     = vc_1.actionButton.text
                destinationIcon.setNeedsDisplay()
                //                toVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                let destinationSize = destinationIcon.icon.frame.size
                var destinationPos = vc_2.contentView.convert(destinationIcon.center, to: navigationController?.view)
                if destinationSize != icon.frame.size {
                    if destinationSize > icon.frame.size {
                        destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                        destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                    } else {
                        destinationPos.x -= icon.frame.size.width / 2 - destinationSize.width / 2
                        destinationPos.y -= icon.frame.size.height / 2 - destinationSize.height / 2
                    }
                }
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationIcon.alpha = 1
                    destinationIcon.icon.alpha = 1
                    vc_2.votesCount = vc_1.votesCount
                    vc_1.actionButton.alpha = 1
                    icon.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? HyperlinkSelectionViewController, let initialIcon = vc_1.actionButton.icon as? SurveyCategoryIcon, let initialLabel = vc_1.hyperlinkLabel, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.hyperlinkIcon.icon, let destinationLabel = vc_2.hyperlinkLabel, let initialColor = initialLabel.backgroundColor {
                
                let tempFrame = UIView(frame: CGRect(origin: vc_1.contentView.convert(vc_1.contentView.bounds.origin, to: navigationController?.view), size: vc_1.contentView.frame.size))
                tempFrame.backgroundColor = destinationLabel.backgroundColor
                tempFrame.cornerRadius = destinationLabel.cornerRadius
                containerView.addSubview(tempFrame)
                
//                initialLabel.backgroundColor = .clear
                
                let destinationPos = vc_2.contentView.convert(destinationLabel.frame.origin, to: navigationController?.view)
                let destinationSize = destinationLabel.frame.size
                
                let destinationIconPos = destinationIcon.superview!.convert(destinationIcon.frame.origin, to: navigationController?.view)
                let destinationIconSize = destinationIcon.frame.size
                
                let destinationBgIconPos = vc_2.hyperlinkIcon.superview!.convert(vc_2.hyperlinkIcon.frame.origin, to: navigationController?.view)
                let destinationBgIconSize = vc_2.hyperlinkIcon.frame.size
                
                let bgIcon = CircleButton(frame: vc_2.hyperlinkIcon.frame)
                bgIcon.state = .On
                bgIcon.color = destinationIcon.backgroundColor!
                bgIcon.oval.opacity = 0
                bgIcon.icon.alpha = 0
                bgIcon.oval.lineWidth = vc_2.hyperlinkIcon.oval.lineWidth
                bgIcon.center = initialIcon.superview!.convert(initialIcon.center, to: containerView)
                containerView.addSubview(bgIcon)
                initialIcon.alpha = 0
                
                let icon = initialIcon.copyView() as! SurveyCategoryIcon
                icon.center = initialIcon.superview!.convert(initialIcon.center, to: containerView)
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                vc_2.hyperlinkIcon.alpha = 0
                
                if vc_1.hyperlink != nil {
                    destinationLabel.numberOfLines = 1
                    destinationLabel.attributedText = NSAttributedString(string: vc_1.hyperlink!.absoluteString, attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Semibold, size: 25), foregroundColor: .blue, backgroundColor: .clear))//initialLabel.text
                } else {
                    destinationLabel.numberOfLines = 0
                    destinationLabel.attributedText = vc_2.hyperlinkPlaceholder
                }
                
                let destinationPath = (destinationIcon.icon as! CAShapeLayer).path
                let pathAnim = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                
                destinationIcon.alpha = 0
                destinationLabel.alpha = 0
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                        bgIcon.frame.origin = destinationBgIconPos
                        bgIcon.frame.size = destinationBgIconSize
                        bgIcon.oval.opacity = 1
                        icon.frame.origin = destinationIconPos
                        icon.frame.size = destinationIconSize
                        icon.backgroundColor = destinationIcon.backgroundColor
                        tempFrame.frame.origin = destinationPos
                        tempFrame.frame.size = destinationSize
                    })
                }
                animationBlocks.append {
                    icon.icon.add(pathAnim, forKey: nil)
                    (icon.icon as! CAShapeLayer).path = destinationPath
                }
                
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks) {
                    _ in
                    destinationLabel.alpha = 1
                    destinationIcon.alpha = 1
                    bgIcon.removeFromSuperview()
                    icon.removeFromSuperview()
                    vc_2.hyperlinkIcon.alpha = 1
                    vc_2.hyperlink = vc_1.hyperlink
                    tempFrame.removeFromSuperview()
                    self.context?.completeTransition(true)
                }

            } /*else if let vc_1 = fromVC as? ImagesSelectionViewController, let initialIcon = vc_1.actionButton as? CircleButton, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.imagesHeaderIcon {
                
                let icon = initialIcon.icon.copyView() as! SurveyCategoryIcon
                //                let icon = getIcon(frame: CGRect(origin: vc_1.actionButton.superview!.convert(vc_1.actionButton.frame.origin, to: navigationController?.view), size: vc_1.actionButton.frame.size), category: vc_1.actionButton.categoryID, color: vc_1.images.isEmpty ? K_COLOR_GRAY : K_COLOR_RED, text: vc_1.actionButton.text)
                
                containerView.addSubview(icon)
                
                destinationIcon.color    = initialIcon.color
                destinationIcon.category = .ImagesHeaderWithCount
                //                destinationIcon.text        = vc_1.actionButton.text
                destinationIcon.setNeedsDisplay()
                //                toVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                let destinationSize = destinationIcon.frame.size
                var destinationPos = vc_2.scrollView!.convert(destinationIcon.center, to: navigationController?.view)
                if destinationSize > icon.frame.size {
                    destinationPos.x -= icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y -= icon.frame.size.height / 2 - destinationSize.height / 2
                } else {
                    destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                }
                
                var bgIcon: SurveyCategoryIcon?
                //                if vc_1.hyperlink == nil {
                bgIcon = SurveyCategoryIcon.getIcon(frame: icon.frame, category: .ImagesHeaderWithCount, backgroundColor: vc_2.color, text: "\(vc_1.images.count)/\(MAX_IMAGES_COUNT)")
                bgIcon!.alpha = 0
                bgIcon!.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(bgIcon!)
                //                }
                
                
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon?.center = destinationPos
                    bgIcon?.frame.size = destinationSize
                    bgIcon?.alpha = 1
                    //                    toVC.view.transform = .identity
                    delay(seconds: self.duration / 1.55) {
                        vc_2.images = vc_1.images
                    }
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationIcon.alpha = 1
                    //                    vc_2.votesCount = vc_1.votesCount
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        bgIcon?.removeFromSuperview()
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            } */else if let vc_1 = fromVC as? TextInputViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let initialLabel = vc_1.frameView, let destinationLabel = vc_1.accessibilityIdentifier == "Title" ? vc_2.titleLabel : vc_2.questionLabel, let destinationIcon = vc_1.accessibilityIdentifier == "Title" ? vc_2.titleIcon : vc_2.questionIcon {
                
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                if vc_1.accessibilityIdentifier == "Title" {
                    vc_2.titleLabel.text = vc_1.text.text
                } else {
                    vc_2.questionLabel.text = vc_1.text.text
                }
                
                toVC.view.alpha = 0
                destinationLabel.alpha = 0
                destinationIcon.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempFrame.backgroundColor = destinationLabel.backgroundColor
                tempFrame.cornerRadius = initialLabel.cornerRadius
                let tempLabel = PaddingLabel(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempLabel.leftInset = (destinationLabel as? PaddingLabel)?.leftInset ?? 0
                tempLabel.rightInset = (destinationLabel as? PaddingLabel)?.rightInset ?? 0
                tempLabel.topInset = (destinationLabel as? PaddingLabel)?.topInset ?? 0
                tempLabel.bottomInset = (destinationLabel as? PaddingLabel)?.bottomInset ?? 0
                tempLabel.backgroundColor = .clear//initialLabel.backgroundColor
                tempLabel.textAlignment = destinationLabel.textAlignment
                tempLabel.text = destinationLabel.text
                tempLabel.font = destinationLabel.font
                tempLabel.textColor = destinationLabel.textColor
                tempLabel.cornerRadius = initialLabel.cornerRadius
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempLabel)
                initialLabel.alpha = 0
                
                let icon = CircleButton(frame: CGRect(origin: CGPoint(x: containerView.frame.width/2 - destinationIcon.frame.width/2, y: vc_1.view.convert(initialLabel.frame.origin, to: navigationController.view).y - destinationIcon.frame.height/2), size: destinationIcon.frame.size))
                icon.color = destinationIcon.color
                icon.category = destinationIcon.category
                icon.state = .On
                icon.lineWidth = destinationIcon.oval.lineWidth
                icon.icon.backgroundColor = icon.color.withAlphaComponent(0.2)
                containerView.addSubview(icon)
                icon.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                destinationIcon.alpha = 0
                
                let destinationPos = vc_2.contentView.convert(destinationLabel.frame.origin, to: navigationController?.view)
                let destinationSize = destinationLabel.frame.size
                
                var animationBlocks: [Closure] = []
                
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: self.duration/2, options: [.curveEaseOut], animations: {
                        icon.frame.origin = CGPoint(x: containerView.frame.width/2 - icon.frame.width/2, y: destinationPos.y - icon.frame.height/2)
                        icon.transform = .identity
                        icon.icon.backgroundColor = destinationIcon.color
                        tempFrame.frame.origin = destinationPos
                        tempFrame.frame.size = destinationSize
                        tempLabel.frame.origin = destinationPos
                        tempLabel.frame.size = destinationSize
                        
                    }) {
                        _ in
                        destinationLabel.alpha = 1
                        destinationIcon.alpha = 1
                        icon.removeFromSuperview()
                        if vc_1.accessibilityIdentifier == "Title" {
                            vc_2.questionTitle = vc_1.text.text
                        } else {
                            vc_2.question = vc_1.text.text
                        }
                        tempLabel.removeFromSuperview()
                        tempFrame.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
                
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
                
            } else {
                context?.completeTransition(true)
            }
        }
    }
    
    private func animateWithBlurEffect(fromView: UIView, toView: UIView, animationBlocks: [Closure], useIncomingEffect: Bool = true, completion: @escaping(Bool)->()) {
        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectViewOutgoing.frame = fromView.bounds
        effectViewOutgoing.addEquallyTo(to: fromView)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
            effectViewOutgoing.effect = nil
        })
        var effectViewIncoming: UIVisualEffectView!
        if useIncomingEffect {
            effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            effectViewIncoming.frame = toView.bounds
            effectViewIncoming.addEquallyTo(to: toView)
        }
        let delay = duration * 0.25
        
        DispatchQueue.main.async {
            animationBlocks.map({ $0() })
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration - delay, delay: 0, options: [.curveLinear], animations: {
            fromView.alpha = 0
            //            if !useIncomingEffect {
            toView.alpha = 1
            //            }
            effectViewOutgoing.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            effectViewOutgoing.removeFromSuperview()
            if !useIncomingEffect {
                fromView.removeFromSuperview()
                completion(true)
            }
        }
        
        if useIncomingEffect {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0/*delay*/, options: [.curveLinear], animations: {
                effectViewIncoming.effect = nil
                toView.alpha = 1
            }) {
                _ in
                effectViewIncoming.removeFromSuperview()
                fromView.removeFromSuperview()
                completion(true)
            }
        }
    }
    
    //    private func getIcon(frame: CGRect, category: SurveyCategoryIcon.CategoryID, color: UIColor, text: String = "", textSize: CGFloat = 43) -> SurveyCategoryIcon {
    //        let icon = SurveyCategoryIcon(frame: frame)
    //        icon.textSize = textSize
    //        icon.text = text
    //        icon.tagColor = color
    //        icon.categoryID = category
    //        icon.isOpaque = false
    //        return icon
    //    }
    
    
    
}
