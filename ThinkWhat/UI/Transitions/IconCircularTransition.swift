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
        
        func animateIconStyleTransition(initialIcon: SurveyCategoryIcon, destinationIcon: SurveyCategoryIcon, iconFrame: CGRect, iconText: String, animatesIconChange: Bool = false, tempIconText: String = "?", tempIconTextSize: CGFloat = 43, animationBlocks: [Closure], completionBlocks: [Closure]) {
            if operation == .push {
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                let icon = getIcon(frame: iconFrame, category: initialIcon.categoryID, color: initialIcon.tagColor!, text: iconText, textSize: initialIcon.textSize)
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                initialIcon.alpha = 0
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                
                var tempIcon: SurveyCategoryIcon?
                if animatesIconChange {
                    tempIcon = getIcon(frame: icon.frame, category: .Text, color: K_COLOR_GRAY, text: tempIconText, textSize: tempIconTextSize)
                    tempIcon!.alpha = 0
                    tempIcon!.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(tempIcon!)
                }
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
//                    fromVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    tempIcon?.center = destinationPos
                    tempIcon?.frame.size = destinationSize
                    tempIcon?.alpha = 1
                }) }
                
                let block: [Closure] = [animationBlock] + animationBlocks
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: block) {
                    _ in
                    completionBlocks.map({ $0() })
                    destinationIcon.alpha = 1
                    tempIcon?.removeFromSuperview()
                    icon.removeFromSuperview()
//                    fromVC.view.transform = .identity
                    self.context?.completeTransition(true)
                }
            } else {
                
            }
        }
        
        
        if operation == .push {
            if let vc_1 = fromVC as? SurveysViewController, let collVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let vc_2 = toVC as? SubcategoryViewController, let destinationIcon = vc_2.icon {
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let icon = getIcon(frame: CGRect(origin: .zero, size: cell.icon.frame.size), category: SurveyCategoryIcon.CategoryID(rawValue: cell.category.ID) ?? .Null, color: cell.category.tagColor!)
//                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: cell.icon.frame.size))
//                icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: cell.category.ID) ?? .Null
//                icon.isOpaque = false
                var pos = cell.icon.convert(cell.icon.center, to: navigationController?.view)
                pos.x -= collVC.sectionInsets.left * 1.5
                pos.y -= collVC.sectionInsets.top * 2
//                collVC.returnPos = pos
                icon.center = pos
//                icon.tagColor = cell.category.tagColor
                
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
                
                let userImage = UIImageView(frame: CGRect(origin: .zero, size: surveyPreview.userImage.frame.size))
                userImage.image = surveyPreview.userImage.image
                var pos = CGPoint.zero
                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                userImage.center = pos
                
                toVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
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

            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? CategorySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let icon = getIcon(frame: CGRect(origin: .zero, size: vc_1.categoryIcon.frame.size), category: vc_1.category != nil ? SurveyCategoryIcon.CategoryID(rawValue: vc_1.category!.ID) ?? .Text : .Text, color: vc_1.category != nil ? vc_1.category!.tagColor! : K_COLOR_RED, text: "?")
                let pos = vc_1.categoryIcon.convert(vc_1.categoryIcon.center, to: navigationController?.view)
                icon.center = pos
                
                vc_2.categoryVC.returnPos = pos
                
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                vc_1.categoryIcon.alpha = 0
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                let destinationSize = destinationIcon.frame.size
                destinationPos.x = destinationIcon.center.x
                destinationPos.x -= destinationSize.width / 2 - icon.frame.size.width / 2
                destinationPos.y = destinationIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - icon.frame.size.height / 2
                UIApplication.shared.statusBarFrame.height
                
                let bgIcon = getIcon(frame: icon.frame, category: .Text, color: K_COLOR_GRAY, text: "?")
                bgIcon.alpha = 0
                bgIcon.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(bgIcon)
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon.center = destinationPos
                    bgIcon.frame.size = destinationSize
                    bgIcon.alpha = 1
//                    fromVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
//                    fromVC.view.transform = .identity
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

            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.anonIcon, let vc_2 = toVC as? AnonimitySelectionViewController, let destinationIcon = vc_2.actionButton {

                animateIconStyleTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, iconFrame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), iconText: "?", animatesIconChange: true, animationBlocks: [], completionBlocks: [])
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.privacyIcon, let vc_2 = toVC as? PrivacySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                animateIconStyleTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, iconFrame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), iconText: "?", animatesIconChange: true, animationBlocks: [], completionBlocks: [])
                
            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.votesIcon, let vc_2 = toVC as? VotesCountViewController, let destinationIcon = vc_2.actionButton {
                
                animateIconStyleTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, iconFrame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), iconText: initialIcon.text, animatesIconChange: false, animationBlocks: [], completionBlocks: [])

            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.hyperlinkIcon, let initialLabel = vc_1.hyperlinkLabel, let vc_2 = toVC as? HyperlinkSelectionViewController, let destinationIcon = vc_2.actionButton, let destinationLabel = vc_2.hyperlinkLabel {
                vc_2.view.setNeedsLayout()
                vc_2.heightConstraint.constant = initialLabel.bounds.height
                vc_2.widthConstraint.constant = initialLabel.bounds.width
                vc_2.hyperlinkLabel.leftInset = (initialLabel as? PaddingLabel)?.leftInset ?? 0
                vc_2.hyperlinkLabel.rightInset = (initialLabel as? PaddingLabel)?.rightInset ?? 0
                vc_2.hyperlinkLabel.topInset = (initialLabel as? PaddingLabel)?.topInset ?? 0
                vc_2.hyperlinkLabel.bottomInset = (initialLabel as? PaddingLabel)?.bottomInset ?? 0
                vc_2.hyperlinkLabel.backgroundColor = initialLabel.backgroundColor
                vc_2.hyperlinkLabel.textAlignment = initialLabel.textAlignment
                vc_2.hyperlinkLabel.text = initialLabel.text
                vc_2.hyperlinkLabel.font = initialLabel.font
                vc_2.hyperlinkLabel.textColor = initialLabel.textColor
                vc_2.hyperlinkLabel.cornerRadius = initialLabel.cornerRadius
                vc_2.hyperlinkLabel.alpha = 0
                vc_2.view.layoutIfNeeded()
                
                let tempLabel = PaddingLabel(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempLabel.leftInset = (initialLabel as? PaddingLabel)?.leftInset ?? 0
                tempLabel.rightInset = (initialLabel as? PaddingLabel)?.rightInset ?? 0
                tempLabel.topInset = (initialLabel as? PaddingLabel)?.topInset ?? 0
                tempLabel.bottomInset = (initialLabel as? PaddingLabel)?.bottomInset ?? 0
                tempLabel.backgroundColor = initialLabel.backgroundColor
                tempLabel.textAlignment = initialLabel.textAlignment
                tempLabel.text = initialLabel.text
                tempLabel.font = initialLabel.font
                tempLabel.textColor = initialLabel.textColor
                tempLabel.cornerRadius = initialLabel.cornerRadius
                initialLabel.alpha = 0
                containerView.addSubview(tempLabel)
                
                let iconText = vc_1.hyperlink == nil ? "?" : "OK"
                let tempIconText = vc_1.hyperlink == nil ? "ПРОПУСТИТЬ" : "OK"
                let tempIconTextSize: CGFloat = vc_1.hyperlink == nil ? 26 : 43
                
                //Sizes are equal
                let destinationPos = CGPoint(x: destinationLabel.center.x, y: destinationLabel.center.y + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.subviews.first!.frame.height)!)
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                    tempLabel.center = destinationPos
                }) }
                let completionBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                    delay(seconds: 0.1) {
                        vc_2.hyperlinkLabel.alpha = 1
                        tempLabel.removeFromSuperview()
                    }
                }) }
                
                
                animateIconStyleTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, iconFrame: CGRect(origin: vc_1.contentView.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), iconText: iconText, animatesIconChange: vc_1.hyperlink == nil, tempIconText: tempIconText, tempIconTextSize: tempIconTextSize, animationBlocks: [animationBlock], completionBlocks: [completionBlock])

            } else if let vc_1 = fromVC as? CreateNewSurveyViewController, let initialIcon = vc_1.imagesHeaderIcon, let vc_2 = toVC as? ImagesSelectionViewController, let destinationIcon = vc_2.actionButton {
                
                let iconText = vc_1.images.isEmpty ? "?" : "OK"
                let tempIconText = vc_1.images.isEmpty ? "ПРОПУСТИТЬ" : "OK"
                let tempIconTextSize: CGFloat = vc_1.images.isEmpty ? 26 : 43
                
                animateIconStyleTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, iconFrame: CGRect(origin: vc_1.contentView.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), iconText: iconText, animatesIconChange: vc_1.images.isEmpty, tempIconText: tempIconText, tempIconTextSize: tempIconTextSize, animationBlocks: [], completionBlocks: [])
            }  else if let vc_1 = fromVC as? CreateNewSurveyViewController, let vc_2 = toVC as? TextInputViewController, let initialLabel = vc_2.accessibilityIdentifier == "Title" ? vc_1.titleLabel : vc_1.questionLabel, let initialIcon = vc_2.accessibilityIdentifier == "Title" ? vc_1.titleIcon : vc_1.questionIcon, let destinationLabel = vc_2.frameView {
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
//                let tempLabel = initialLabel.copyView()
                destinationLabel.alpha = 0
//                vc_2.hideKBIcon.alpha = 0
//                vc_2.okButton.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempFrame.backgroundColor = destinationLabel.backgroundColor
                tempFrame.cornerRadius = initialLabel.cornerRadius
                let tempLabel = PaddingLabel(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempLabel.leftInset = (initialLabel as? PaddingLabel)?.leftInset ?? 0
                tempLabel.rightInset = (initialLabel as? PaddingLabel)?.rightInset ?? 0
                tempLabel.topInset = (initialLabel as? PaddingLabel)?.topInset ?? 0
                tempLabel.bottomInset = (initialLabel as? PaddingLabel)?.bottomInset ?? 0
                tempLabel.backgroundColor = .clear//initialLabel.backgroundColor
                tempLabel.textAlignment = initialLabel.textAlignment
                tempLabel.text = initialLabel.text
                tempLabel.font = initialLabel.font
                tempLabel.textColor = initialLabel.textColor
                tempLabel.cornerRadius = initialLabel.cornerRadius
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempLabel)
                initialLabel.alpha = 0
                
                let tempIcon = getIcon(frame: initialIcon.frame, category: initialIcon.categoryID, color: initialIcon.tagColor!, text: initialIcon.text, textSize: initialIcon.textSize)
                tempIcon.center = CGPoint(x: initialIcon.superview!.convert(initialIcon.center, to: navigationController?.view).x, y: -initialIcon.bounds.height*4)
                vc_2.view.addSubview(tempIcon)
                print(tempIcon.frame)
                
                
                var destinationPos = destinationLabel.convert(destinationLabel.center, to: navigationController?.view)
                let destinationSize = CGSize(width: destinationLabel.frame.size.width, height: vc_2.frameHeight.constant)//vc_2.view.frame.height - vc_2.keyboardHeight - vc_2.frameToStackHeight.constant - vc_2.hideKBIcon.frame.height - 20)
                destinationPos.x = destinationLabel.center.x
                destinationPos.x -= destinationSize.width / 2 - tempLabel.frame.size.width / 2
                destinationPos.y = destinationLabel.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                destinationPos.y -= destinationSize.height / 2 - tempLabel.frame.size.height / 2
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                    tempFrame.center = destinationPos
                    tempFrame.frame.size = destinationSize
                    tempLabel.center = destinationPos
                    tempLabel.frame.size = destinationSize
                }) }
                let completionBlock: Closure = {
                    UIView.animate(withDuration: 0.2, delay: 0.12, options: [.curveLinear], animations: {
                        destinationLabel.alpha = 1
                        tempLabel.alpha = 0
                        tempFrame.alpha = 0
                    }) {
                        _ in
                        initialIcon.alpha = 1
                        tempLabel.removeFromSuperview()
                        tempFrame.removeFromSuperview()
                        tempIcon.removeFromSuperview()
                    }
                }
                
//                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
//                    _ in
//                    UIView.animate(withDuration: 0.2, delay: 0.12, options: [.curveLinear], animations: {
//                        destinationLabel.alpha = 1
//                        tempLabel.alpha = 0
//                        tempFrame.alpha = 0
//                    }) {
//                        _ in
//                        tempLabel.removeFromSuperview()
//                        tempFrame.removeFromSuperview()
//                    }
//                    self.context?.completeTransition(true)
//                }
                animateIconStyleTransition(initialIcon: initialIcon, destinationIcon: tempIcon, iconFrame: CGRect(origin: vc_1.contentView.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), iconText: "", animationBlocks: [animationBlock], completionBlocks: [completionBlock])
            }
        } else if operation == .pop {
            if let vc_1 = fromVC as? SubcategoryViewController, let initialIcon = vc_1.icon, let vc_2 = toVC as? SurveysViewController, let collVC = vc_2.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
                
                let icon = getIcon(frame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), category: initialIcon.categoryID, color: initialIcon.tagColor!, text: "?")
                
//                let icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: initialIcon.frame.size))
//                icon.categoryID = initialIcon.categoryID
//                icon.isOpaque = false
//                var pos = initialIcon.convert(initialIcon.center, to: navigationController?.view)
//                pos.x = initialIcon.center.x
//                pos.y = initialIcon.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
//                icon.center = pos
//                icon.tagColor = initialIcon.tagColor
                
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
                
            } else if let vc_1 = fromVC as? CategorySelectionViewController, let collectionVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collectionVC.currentIndex as? IndexPath, let cell = collectionVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let initialIcon = cell.icon, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.categoryIcon {
                
                var center = cell.icon.convert(cell.icon.center, to: navigationController?.view)
                center.x -= collectionVC.sectionInsets.left * 1.5
                center.y -= collectionVC.sectionInsets.top * 2
                let icon = getIcon(frame: CGRect(origin: .zero, size: initialIcon.frame.size), category: initialIcon.categoryID, color: initialIcon.tagColor!, text: initialIcon.text)
                icon.center = center
                
//                var icon: SurveyCategoryIcon!
//                if vc_1.isModified {
//                    icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: initialIcon.frame.size))
//                    icon.categoryID = initialIcon.categoryID
//                    icon.isOpaque = false
//                    var pos = cell.icon.convert(cell.icon.center, to: navigationController?.view)
//                    pos.x -= collectionVC.sectionInsets.left * 1.5
//                    pos.y -= collectionVC.sectionInsets.top * 2
//                    icon.center = pos//initialIcon.convert(initialIcon.center, to: navigationController?.view)
//                    icon.tagColor = initialIcon.tagColor
//                } else {
//                    icon = SurveyCategoryIcon(frame: CGRect(origin: .zero, size: vc_1.actionButton.frame.size))
//                    icon.categoryID = vc_1.actionButton.categoryID
//                    icon.isOpaque = false
//                    icon.tagColor = vc_1.actionButton.tagColor
//                    var pos = CGPoint.zero
//                    pos.x = vc_1.actionButton.center.x
//                    pos.y = vc_1.actionButton.center.y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
//                    icon.center = pos//vc_1.actionButton.convert(vc_1.actionButton.center, to: navigationController?.view)
//                }
                containerView.addSubview(icon)
                initialIcon.alpha = 0//vc_1.isModified ? 0 : 1
                vc_2.categoryTitle.text = ""
                vc_2.categoryIcon.tagColor = vc_1.category?.tagColor
//                toVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                let destinationSize = destinationIcon.frame.size
                var destinationPos = collectionVC.returnPos
                destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
//                    toVC.view.transform = .identity
                    delay(seconds: self.duration / 1.5) {
                        vc_2.category = vc_1.category
                    }
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationIcon.alpha = 1
//                    vc_2.category = vc_1.category
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }

            } else if let vc_1 = fromVC as? AnonimitySelectionViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.anonIcon {
                let initialIcon: SurveyCategoryIcon = vc_1.isAnonymous ? vc_1.enabledIcon : vc_1.disabledIcon
                
                let icon = getIcon(frame: CGRect(origin: initialIcon.superview!.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), category: initialIcon.categoryID, color: initialIcon.tagColor!, text: initialIcon.text)
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                destinationIcon.tagColor = initialIcon.tagColor
                destinationIcon.categoryID = initialIcon.categoryID
                destinationIcon.setNeedsDisplay()
//                toVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
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
//                    toVC.view.transform = .identity
                    delay(seconds: self.duration / 1.5) {
                        vc_2.isAnonymous = vc_1.isAnonymous
                    }
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationIcon.alpha = 1
//                    vc_2.isAnonymous = vc_1.isAnonymous
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
                
            } else if let vc_1 = fromVC as? PrivacySelectionViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.privacyIcon {
                let initialIcon: SurveyCategoryIcon = vc_1.isPrivate ? vc_1.enabledIcon : vc_1.disabledIcon
                
                let icon = getIcon(frame: CGRect(origin: initialIcon.superview!.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size), category: initialIcon.categoryID, color: initialIcon.tagColor!, text: initialIcon.text)
                containerView.addSubview(icon)
                
                destinationIcon.tagColor = initialIcon.tagColor
                destinationIcon.categoryID = initialIcon.categoryID
                destinationIcon.setNeedsDisplay()
//                toVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
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
//                    toVC.view.transform = .identity
                    delay(seconds: self.duration / 1.5) {
                        vc_2.isPrivate = vc_1.isPrivate
                    }
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationIcon.alpha = 1
//                    vc_2.isPrivate = vc_1.isPrivate
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            } else if let vc_1 = fromVC as? VotesCountViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.votesIcon {
                
                let icon = getIcon(frame: CGRect(origin: vc_1.actionButton.superview!.convert(vc_1.actionButton.frame.origin, to: navigationController?.view), size: vc_1.actionButton.frame.size), category: vc_1.actionButton.categoryID, color: vc_1.actionButton.tagColor!, text: vc_1.actionButton.text)
   
                vc_1.actionButton.alpha = 0
                containerView.addSubview(icon)
                
                destinationIcon.tagColor    = vc_1.actionButton.tagColor
                destinationIcon.categoryID  = vc_1.actionButton.categoryID
                destinationIcon.text        = vc_1.actionButton.text
                destinationIcon.setNeedsDisplay()
//                toVC.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                let destinationSize = destinationIcon.frame.size
                var destinationPos = destinationIcon.convert(destinationIcon.center, to: navigationController?.view)
                if destinationSize > icon.frame.size {
                    destinationPos.x -= icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y -= icon.frame.size.height / 2 - destinationSize.height / 2
                } else {
                    destinationPos.x += icon.frame.size.width / 2 - destinationSize.width / 2
                    destinationPos.y += icon.frame.size.height / 2 - destinationSize.height / 2
                }
                
                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
//                    toVC.view.transform = .identity
//                    delay(seconds: self.duration / 1.25) {
//                        vc_2.votesCount = vc_1.votesCount
//                    }
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationIcon.alpha = 1
                    vc_2.votesCount = vc_1.votesCount
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        vc_1.actionButton.alpha = 1
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            } else if let vc_1 = fromVC as? HyperlinkSelectionViewController, let initialLabel = vc_1.hyperlinkLabel, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.hyperlinkIcon, let destinationLabel = vc_2.hyperlinkLabel {
                
                let icon = getIcon(frame: CGRect(origin: vc_1.actionButton.superview!.convert(vc_1.actionButton.frame.origin, to: navigationController?.view), size: vc_1.actionButton.frame.size), category: vc_1.actionButton.categoryID, color: vc_1.hyperlink == nil ? K_COLOR_GRAY : K_COLOR_RED, text: vc_1.actionButton.text)
                
                let tempLabel = PaddingLabel(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempLabel.leftInset = (destinationLabel as? PaddingLabel)?.leftInset ?? 0
                tempLabel.rightInset = (destinationLabel as? PaddingLabel)?.rightInset ?? 0
                tempLabel.topInset = (destinationLabel as? PaddingLabel)?.topInset ?? 0
                tempLabel.bottomInset = (destinationLabel as? PaddingLabel)?.bottomInset ?? 0
                tempLabel.backgroundColor = destinationLabel.backgroundColor
                tempLabel.textAlignment = destinationLabel.textAlignment
                tempLabel.text = destinationLabel.text
                tempLabel.font = destinationLabel.font
                tempLabel.textColor = destinationLabel.textColor
                tempLabel.cornerRadius = destinationLabel.cornerRadius
                initialLabel.alpha = 0
                containerView.addSubview(tempLabel)
                
                
//                let iconText = vc_1.hyperlink == nil ? "?" : "OK"
//                let tempIconText = vc_1.hyperlink == nil ? "ПРОПУСТИТЬ" : "OK"
//                let tempIconTextSize: CGFloat = vc_1.hyperlink == nil ? 26 : 43
                
                destinationLabel.alpha = 0
                //Sizes are equal
                let destinationLabelPos = destinationLabel.convert(destinationLabel.center, to: navigationController?.view)
                let animationLabelBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                    tempLabel.center = destinationLabelPos
                }) }
                let completionBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                    delay(seconds: 0.2) {
                        tempLabel.removeFromSuperview()
                        destinationLabel.alpha = 1
                    }
                }) }
                
                containerView.addSubview(icon)
                
                destinationIcon.categoryID  = vc_1.actionButton.categoryID
                destinationIcon.setNeedsDisplay()
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
                    bgIcon = getIcon(frame: icon.frame, category: .Text, color: vc_2.color, text: "ССЫЛКА")
                    bgIcon!.alpha = 0
                    bgIcon!.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(bgIcon!)
//                }
                
                
                
                let animationIconBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.center = destinationPos
                    icon.frame.size = destinationSize
                    bgIcon?.center = destinationPos
                    bgIcon?.frame.size = destinationSize
                    bgIcon?.alpha = 1
//                    toVC.view.transform = .identity
                    delay(seconds: self.duration / 1.55) {
                        vc_2.hyperlink = vc_1.hyperlink
                    }
                }) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationLabelBlock, animationIconBlock]) {
                    _ in
                    destinationIcon.alpha = 1
//                    vc_2.votesCount = vc_1.votesCount
                    UIView.animate(withDuration: self.duration, delay: 0, options: [.curveEaseIn], animations: {
                        icon.alpha = 0
                    }) {
                        _ in
                        completionBlock()
                        bgIcon?.removeFromSuperview()
                        icon.removeFromSuperview()
                        self.context?.completeTransition(true)
                    }
                }
            } else if let vc_1 = fromVC as? ImagesSelectionViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let destinationIcon = vc_2.imagesHeaderIcon {
                
                let icon = getIcon(frame: CGRect(origin: vc_1.actionButton.superview!.convert(vc_1.actionButton.frame.origin, to: navigationController?.view), size: vc_1.actionButton.frame.size), category: vc_1.actionButton.categoryID, color: vc_1.images.isEmpty ? K_COLOR_GRAY : K_COLOR_RED, text: vc_1.actionButton.text)
                
                containerView.addSubview(icon)
                
                destinationIcon.tagColor    = vc_1.actionButton.tagColor
                destinationIcon.categoryID  = .ImagesHeaderWithCount
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
                bgIcon = getIcon(frame: icon.frame, category: .ImagesHeaderWithCount, color: vc_2.color, text: "\(vc_1.images.count)/\(MAX_IMAGES_COUNT)")
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
            } else if let vc_1 = fromVC as? TextInputViewController, let vc_2 = toVC as? CreateNewSurveyViewController, let initialLabel = vc_1.frameView, let destinationLabel = vc_1.accessibilityIdentifier == "Title" ? vc_2.titleLabel : vc_2.questionLabel {
                
//                toVC.view.setNeedsLayout()
//                toVC.view.layoutIfNeeded()
//
                destinationLabel.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempFrame.backgroundColor = destinationLabel.backgroundColor
                tempFrame.cornerRadius = initialLabel.cornerRadius
                let tempLabel = PaddingLabel(frame: CGRect(origin: initialLabel.convert(initialLabel.bounds.origin, to: navigationController?.view), size: initialLabel.frame.size))
                tempLabel.leftInset = (destinationLabel as? PaddingLabel)?.leftInset ?? 0
                tempLabel.rightInset = (destinationLabel as? PaddingLabel)?.rightInset ?? 0
                tempLabel.topInset = (destinationLabel as? PaddingLabel)?.topInset ?? 0
                tempLabel.bottomInset = (destinationLabel as? PaddingLabel)?.bottomInset ?? 0
                tempLabel.backgroundColor = .clear//red
                tempLabel.textAlignment = destinationLabel.textAlignment
                tempLabel.numberOfLines = 3
                tempLabel.text = vc_1.text.text
                tempLabel.font = destinationLabel.font
                tempLabel.textColor = destinationLabel.textColor
                
                initialLabel.alpha = 0
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempLabel)
                //                tempFrame.addSubview(tempLabel)
                //                tempLabel.centerYAnchor.constraint(equalTo: tempFrame.centerYAnchor).isActive = true
                //                tempLabel.centerXAnchor.constraint(equalTo: tempFrame.centerXAnchor).isActive = true
                //                tempFrame.setNeedsLayout()
                //                tempFrame.layoutIfNeeded()
                
                //                tempLabel.trailingAnchor.constraint(equalTo: tempFrame.trailingAnchor).isActive = true
                //                tempLabel.leadingAnchor.constraint(equalTo: tempFrame.leadingAnchor).isActive = true
                //                tempLabel.bottomAnchor.constraint(equalTo: tempFrame.bottomAnchor).isActive = true
                //                tempLabel.topAnchor.constraint(equalTo: tempFrame.topAnchor).isActive = true
                
                //                tempLabel.addEquallyTo(to: tempFrame)
                
                
                
                var destinationPos = destinationLabel.convert(destinationLabel.center, to: navigationController?.view)
                let destinationSize = destinationLabel.frame.size

                if destinationSize.width != tempLabel.frame.size.width {
                    destinationPos.x += (destinationSize.width > tempLabel.frame.size.width) ? -(tempLabel.frame.size.width / 2 - destinationSize.width / 2) : tempLabel.frame.size.width / 2 - destinationSize.width / 2
                }
//                destinationPos.y -= (destinationSize.height > tempLabel.frame.size.height) ? -(tempLabel.frame.size.height / 2 - destinationSize.height / 2) : tempLabel.frame.size.height / 2 - destinationSize.height / 2
                
//                if destinationSize.height > tempFrame.frame.size.height {
//                    destinationPos.y -= tempFrame.frame.size.height / 2 - destinationSize.height / 2
//                } else {
                    destinationPos.y += tempFrame.frame.size.height / 2 - destinationSize.height / 2
//                }
                
//                if destinationSize > tempFrame.frame.size {
//                    destinationPos.x -= tempFrame.frame.size.width / 2 - destinationSize.width / 2
//                    destinationPos.y -= tempFrame.frame.size.height / 2 - destinationSize.height / 2
//                } else {
//                    destinationPos.x += tempFrame.frame.size.width / 2 - destinationSize.width / 2
//                    destinationPos.y += tempFrame.frame.size.height / 2 - destinationSize.height / 2
//                }

                let animationBlock: Closure = { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    tempFrame.center = destinationPos
                    tempFrame.frame.size = destinationSize
                    tempLabel.center = destinationPos
                    tempLabel.frame.size = destinationSize
                    delay(seconds: self.duration / 1.55) {
                        if vc_1.accessibilityIdentifier == "Title" {
                            vc_2.titleLabel.text = vc_1.text.text
                            vc_2.questionTitle = vc_1.text.text
                        } else {
                            vc_2.questionLabel.text = vc_1.text.text
                            vc_2.question = vc_1.text.text
                        }
                    }
                }) }

                    self.animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [animationBlock]) {
                    _ in
                    destinationLabel.alpha = 1
                    tempLabel.removeFromSuperview()
                    tempFrame.removeFromSuperview()
                    self.context?.completeTransition(true)
                }
            } else {
                context?.completeTransition(true)
            }
        }
    }
    
    private func animateWithBlurEffect(fromView: UIView, toView: UIView, animationBlocks: [Closure], completion: @escaping(Bool)->()) {
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
        
//        if animationBlock != nil {
//            animationBlock!()
//        }
        animationBlocks.map({ $0() })
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration - delay, delay: 0, options: [.curveLinear], animations: {
            fromView.alpha = 0
            effectViewOutgoing.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            effectViewOutgoing.removeFromSuperview()
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            effectViewIncoming.effect = nil
            toView.alpha = 1
        }) {
            _ in
            effectViewIncoming.removeFromSuperview()
            fromView.removeFromSuperview()
            completion(true)
        }
    }
    
    private func getIcon(frame: CGRect, category: SurveyCategoryIcon.CategoryID, color: UIColor, text: String = "", textSize: CGFloat = 43) -> SurveyCategoryIcon {
        let icon = SurveyCategoryIcon(frame: frame)
        icon.textSize = textSize
        icon.text = text
        icon.tagColor = color
        icon.categoryID = category
        icon.isOpaque = false
        return icon
    }
    
    
    
}
