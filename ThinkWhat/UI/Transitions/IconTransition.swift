//
//  IconCircularTransition.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class IconTransition: BasicTransition {
    deinit {
        print("---\(self) deinit()")
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let containerView = transitionContext.containerView
        context = transitionContext
//        fromVC.view.subviews.map {$0.isUserInteractionEnabled = false}
//        toVC.view.subviews.map {$0.isUserInteractionEnabled = false}
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        
        func animateIconStyleTransition(initialIcon: Icon, destinationIcon: Icon, origin: CGPoint, text: String, iconChange: Bool = false, animationBlocks: [Closure], completionBlocks: [Closure], useIncomingEffect: Bool = true, completeTransition: Bool = true) {
            if operation == .push {
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                let icon = initialIcon.copyView() as! Icon
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
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animBlocks, withIncomingBlurEffect: useIncomingEffect) {
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
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                let icon = cell.icon.copyView() as! Icon
                let origin = cell.contentView.convert(cell.icon.frame.origin, to: containerView)
                icon.frame.origin = origin
                collVC.returnPos = origin
                containerView.addSubview(icon)
                destinationIcon.alpha = 0
                cell.icon.alpha = 0
                
                let destinationOrigin = toVC.view.convert(destinationIcon.frame.origin, to: containerView)
                let destinationSize = destinationIcon.frame.size
                let destinationPath = (destinationIcon.icon as! CAShapeLayer).path
                let pathAnim = Animations.get(property: .Path,
                                              fromValue: (icon.icon as! CAShapeLayer).path as Any,
                                              toValue: destinationPath as Any,
                                              duration: animDuration * 0.9,
                                              delay: 0,
                                              repeatCount: 0,
                                              autoreverses: false,
                                              timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                              delegate: nil,
                                              isRemovedOnCompletion: false)
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIView.animate(
                        withDuration: animDuration * 0.9,
                        delay: 0,
//                        usingSpringWithDamping: 0.7,
//                        initialSpringVelocity: 0.7,
                        options: [.curveEaseInOut],
                        animations: {
                            icon.frame.origin = destinationOrigin
                            icon.frame.size   = destinationSize
                    })
                }
                animationBlocks.append {
                    icon.icon.add(pathAnim, forKey: nil)
                }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlocks, withIncomingBlurEffect: false) {
                    _ in
                    destinationIcon.alpha = 1
                    icon.removeFromSuperview()
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
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
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? SurveysViewController, let stackVC = vc_1.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview, let vc_2 = toVC as? delUserViewController {
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
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? NewPollController, let initialIcon = vc_1.categoryIcon, let vc_2 = toVC as? CategorySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                
                //                vc_2.containerCenterYConstraint.constant += 800//vc_2.containerBg.bounds.height
                
                let icon = initialIcon.icon.copyView() as! Icon
                
                let pos = initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view)
                icon.frame.origin = pos
                vc_2.view.alpha = 1
                vc_2.categoryVC.returnPos = pos
                
                containerView.addSubview(icon)
                initialIcon.icon.alpha = 0
                destinationIcon.alpha = 0
                //                toVC.view.alpha = 1
                vc_2.containerBg.alpha = 1
                let destinationPos = destinationIcon.convert(destinationIcon.icon.frame.origin, to: navigationController?.view)
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPath = (destinationIcon.icon.icon as! CAShapeLayer).path
                let pathAnim = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration*0.8, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                
                var animationBlock: [Closure] = []
                animationBlock.append {
                    UIView.animate(
                        withDuration: self.duration,
                        delay: 0,
                        usingSpringWithDamping: 0.9,
                        initialSpringVelocity: 0.2,
                        options: [.curveEaseInOut],
                        animations: {
                            vc_2.view.setNeedsLayout()
                            vc_2.containerTopConstraint.constant -= vc_2.containerBg.frame.height
                            vc_2.view.layoutIfNeeded()
                    })
                }
                animationBlock.append { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration*0.8, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.frame.origin = destinationPos
                    icon.frame.size = destinationSize
                    icon.backgroundColor = destinationIcon.icon.backgroundColor
//                    vc_2.view.setNeedsLayout()
//                    vc_2.containerTopConstraint.constant -= vc_2.containerBg.frame.height
//                    vc_2.view.layoutIfNeeded()
                }) }
                animationBlock.append {
                    icon.icon.add(pathAnim, forKey: nil)
                    (icon.icon as! CAShapeLayer).path = destinationPath
                }
                
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlock, withIncomingBlurEffect: false) {
                    _ in
                    destinationIcon.alpha = 1
                    icon.removeFromSuperview()
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? NewPollController, let vc_2 = toVC as? BinarySelectionViewController, let destinationIcon = vc_2.actionButton {
                
                var initialIcon: CircleButton!
                switch vc_2.selectionType {
                case .Anonimity:
                    initialIcon = vc_1.anonIcon
                case .Privacy:
                    initialIcon = vc_1.privacyIcon
                case .Comments:
                    initialIcon = vc_1.commentsIcon
                case .Hot:
                    initialIcon = vc_1.hotIcon
                }
                
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
                let completionBlocks = [{
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    }]
                
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view), text: "?", iconChange: true, animationBlocks: animationBlocks, completionBlocks: completionBlocks, useIncomingEffect: false)
                
            } else if let vc_1 = fromVC as? NewPollController, let initialIcon = vc_1.votesIcon, let vc_2 = toVC as? VotesCountViewController, let destinationIcon = vc_2.actionButton {
                let completionBlocks = [{
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    }]
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: initialIcon.convert(initialIcon.icon.frame.origin, to: navigationController?.view), text: "?", iconChange: false, animationBlocks: [], completionBlocks: completionBlocks)//, useIncomingEffect: false)
                
            } else if let vc_1 = fromVC as? NewPollController, let initialIcon = vc_1.imagesIcon, let vc_2 = toVC as? ImagesSelectionViewController, let destinationIcon = vc_2.actionButton {
                
                let text = vc_1.images.isEmpty ? "?" : "OK"
                let tempIconText = vc_1.images.isEmpty ? "ПРОПУСТИТЬ" : "OK"
                let tempIconTextSize: CGFloat = vc_1.images.isEmpty ? 26 : 43
                let completionBlocks = [{
//                    fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    }]
                animateIconStyleTransition(initialIcon: initialIcon.icon, destinationIcon: destinationIcon.icon, origin: vc_1.contentView.convert(initialIcon.center, to: navigationController?.view), text: text, animationBlocks: [], completionBlocks: completionBlocks)
                
            }  else if let vc_1 = fromVC as? NewPollController, let vc_2 = toVC as? TextInputViewController, vc_2.type != .Answer, let destinationView = vc_2.frameView, let destinationTextView = vc_2.textView as? UITextView {
                var initialIcon: CircleButton!
                var initialFrame: UIView!
                var initialTextView: UITextView!
                vc_2.isInputEnabled = false
                
                if vc_2.type == .Title {
                    initialIcon = vc_1.titleIcon
                    initialTextView = vc_1.pollTitleTextView
                    initialFrame = vc_1.pollTitleContainer
                    destinationTextView.font = initialTextView.font
                    destinationTextView.textAlignment = initialTextView.textAlignment
                    destinationTextView.text = initialTextView.text
//                    attributedText = initialTextView.attributedText as! NSAttributedString
                } else if vc_2.type == .Description {
                    initialIcon = vc_1.pollDescriptionIcon
                    initialTextView = vc_1.pollDescriptionTextView
                    initialFrame = vc_1.pollDescriptionContainer
                    destinationTextView.font = StringAttributes.FontStyle.Regular.get(size: 15)
                    destinationTextView.textAlignment = .natural
                    destinationTextView.layoutManager.hyphenationFactor = 1
//                    let paragraphStyle = NSMutableParagraphStyle()
//                    paragraphStyle.hyphenationFactor = 1.0
//                    let attributedString = NSMutableAttributedString(string: question, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
//                    attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 15), foregroundColor: .black, backgroundColor: .clear), range: question.fullRange())
                    
//                    attributedText = initialTextView.attributedText as! NSAttributedString
                } else if vc_2.type == .Question {
                    initialIcon = vc_1.questionIcon
                    initialTextView = vc_1.questionTextView
                    initialFrame = vc_1.questionContainer
//                    destinationTextView.font = StringAttributes.FontStyle.Regular.get(size: 15)
                    destinationTextView.textAlignment = .natural
                    destinationTextView.layoutManager.hyphenationFactor = 1
                }
                let attributedText = initialTextView.attributedText as! NSAttributedString
                vc_2.textViewWidthConstraint.constant = initialTextView.frame.width
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                toVC.view.isUserInteractionEnabled = false
                toVC.view.subviews.map {$0.isUserInteractionEnabled = false}
                
                vc_2.textView.becomeFirstResponder()
                let height = vc_2.view.frame.height - vc_2.keyboardHeight - vc_2.frameToStackHeight.constant - vc_2.hideKBIcon.frame.height - 20
                toVC.view.setNeedsLayout()
                vc_2.frameHeight.constant = height
                toVC.view.layoutIfNeeded()
                
                if vc_2.textContent.isEmpty {
                    vc_2.textView.text = ""
                }
//                vc_2.text!.text = vc_2.textContent
                destinationView.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialFrame.convert(initialFrame.bounds.origin, to: navigationController?.view), size: initialFrame.frame.size))
                tempFrame.backgroundColor = destinationView.backgroundColor
                tempFrame.cornerRadius = initialFrame.cornerRadius
                
                let tempTextView = UITextView(frame: CGRect(origin: initialTextView.convert(initialTextView.bounds.origin, to: navigationController?.view), size: initialTextView.frame.size))
//                    ),
//                                              textContainer: NSTextContainer(size: initialTextView.textContainer.size))

//                tempTextView.font = initialTextView.font
//                tempTextView.textAlignment = initialTextView.textAlignment
//                tempTextView.text = initialTextView.text
//                tempTextView.textColor = initialTextView.textColor
                tempTextView.attributedText = attributedText
                                tempTextView.backgroundColor = .clear
                tempTextView.layer.masksToBounds = true
                tempTextView.alpha = 0
                tempTextView.layoutManager.hyphenationFactor = vc_2.type == .Title ? 0 : 1
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempTextView)
                tempTextView.contentOffset.y = initialTextView.contentOffset.y
                tempTextView.alpha = 1
                initialFrame.alpha = 0
                
                let icon = CircleButton(frame: CGRect(origin: vc_1.contentView.convert(initialIcon.frame.origin, to: navigationController?.view), size: initialIcon.frame.size))
                icon.color = initialIcon.color
                icon.oval.lineWidth = initialIcon.oval.lineWidth
                icon.category = initialIcon.category
                icon.state = .On
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                let destinationFramePos = vc_2.view.convert(destinationView.frame.origin, to: navigationController?.view)
                let destinationFrameSize = CGSize(width: destinationView.frame.size.width, height: vc_2.frameHeight.constant)
                let destinationTextViewPos = destinationView.convert(destinationTextView.frame.origin, to: navigationController?.view)
                let destinationTextViewSize = CGSize(width: destinationTextView.frame.size.width, height: destinationTextView.frame.size.height)
                
                var animationBlocks: [Closure] = []
                
                vc_2.hideKBIcon.alpha = 0
                vc_2.okButton.alpha = 0
                
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.7, delay: 0, options: [.curveEaseOut], animations: {
                        icon.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    })
                }
                destinationTextView.text = vc_2.textContent
                destinationTextView.scrollToBottom()
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.9, delay: 0, options: [.curveEaseOut], animations: {
                        icon.frame.origin = CGPoint(x: containerView.frame.width/2 - icon.frame.width/2, y: destinationFramePos.y - icon.frame.height/2)
                        icon.icon.backgroundColor = icon.color.withAlphaComponent(0.3)
                        tempFrame.frame.origin = destinationFramePos
                        tempFrame.frame.size = destinationFrameSize
                        tempTextView.frame.origin = destinationTextViewPos
                        tempTextView.frame.size = destinationTextViewSize
                        tempTextView.textContainer.size = destinationTextView.textContainer.size
                        tempTextView.scrollToBottom()//contentOffset.y = initialTextView.contentSize.height
//                        destinationTextView.scrollToBottom()
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        initialIcon.alpha = 1
                        UIView.animate(withDuration: 0.2, animations: {
                            vc_2.hideKBIcon.alpha = 1
                            vc_2.okButton.alpha = 1
//                            vc_2.text!.text = vc_2.textContent
                        }) {
                            _ in
                            if vc_2.needsScaleAnim {
                                UIView.animate(withDuration: 0.15, delay: 0.3, options: [.curveEaseInOut], animations: {
                                    tempTextView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                                    tempTextView.alpha = 0
                                }) {
                                    _ in
                                    tempTextView.removeFromSuperview()
                                    tempFrame.removeFromSuperview()
                                    destinationView.alpha = 1
                                    toVC.view.isUserInteractionEnabled = true
                                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                                    vc_2.isInputEnabled = true
                                    self.context?.completeTransition(true)
                                }
                            } else {
                                tempTextView.removeFromSuperview()
                                tempFrame.removeFromSuperview()
                                destinationView.alpha = 1
                                toVC.view.isUserInteractionEnabled = true
                                toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                                vc_2.isInputEnabled = true
                                self.context?.completeTransition(true)
                            }
                        }
                    }
                }
                animationBlocks.append {
                    icon.addDisableAnimation()
                }
                
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks, withIncomingBlurEffect: false) { _ in }
                
            } else if let vc_1 = fromVC as? NewPollController, let vc_2 = toVC as? ImageViewController {
                var initialImageView: UIImageView!
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                switch vc_1.imagePosition {
                case 0:
                    initialImageView = vc_1.image_1.subviews.filter { $0 is UIImageView }.first as? UIImageView ?? UIImageView()
                case 1:
                    initialImageView = vc_1.image_2.subviews.filter { $0 is UIImageView }.first as? UIImageView ?? UIImageView()
                default:
                    initialImageView = vc_1.image_3.subviews.filter { $0 is UIImageView }.first as? UIImageView ?? UIImageView()
                }
                
                vc_2.view.alpha = 0
                vc_2.scrollView.alpha = 0
                let imageView = UIImageView(frame: initialImageView.frame)
                imageView.backgroundColor = .black
                imageView.frame.origin = initialImageView.superview!.convert(initialImageView.frame.origin, to: containerView)
                imageView.layer.masksToBounds = true
                imageView.image = initialImageView.image
                imageView.cornerRadius = initialImageView.cornerRadius
                imageView.contentMode = .scaleAspectFill
                containerView.addSubview(imageView)
                
                let blackScreen = UIView(frame: vc_1.view.frame)
                blackScreen.addEquallyTo(to: vc_1.view)
                blackScreen.backgroundColor = .black
                blackScreen.alpha = 0
                let destinationSize = vc_2.scrollView.imageView.getImageRect().size//CGSize(width: vc_2.view.frame.width, height: vc_2.view.frame.width)//vc_2.scrollView.frame.size
                let destinationOrigin = toVC.view.convert(CGPoint(x: 0, y: vc_2.scrollView.imageView.getImageRect().origin.y), to: navigationController?.view)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    imageView.frame.origin = destinationOrigin
                    imageView.frame.size = destinationSize
                    imageView.cornerRadius = 0
                    blackScreen.alpha = 1
                }) {
                    _ in
                    blackScreen.removeFromSuperview()
                    imageView.removeFromSuperview()
                    vc_2.view.alpha = 1
                    vc_2.scrollView.alpha = 1
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? PollController, let vc_2 = toVC as? ImageViewController, let cell = vc_1.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? ImagesCell, let initialView = cell.scrollView {
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                vc_2.view.alpha = 0
                vc_2.scrollView.alpha = 0
                let imageView = UIImageView(frame: initialView.frame)
                imageView.backgroundColor = .black
                imageView.frame.origin = initialView.superview!.convert(initialView.frame.origin, to: containerView)
                imageView.layer.masksToBounds = true
                imageView.image = vc_2.image
                imageView.cornerRadius = initialView.cornerRadius
                imageView.contentMode = .scaleAspectFill
                containerView.addSubview(imageView)
                initialView.alpha = 0

                let blackScreen = UIView(frame: vc_1.view.frame)
                blackScreen.addEquallyTo(to: vc_1.view)
                blackScreen.backgroundColor = .black
                blackScreen.alpha = 0
                let destinationSize = vc_2.scrollView.imageView.getImageRect().size//CGSize(width: vc_2.view.frame.width, height: vc_2.view.frame.width)//vc_2.scrollView.frame.size
                let destinationOrigin = toVC.view.convert(CGPoint(x: 0, y: vc_2.scrollView.imageView.getImageRect().origin.y), to: navigationController?.view)// - navigationController!.navigationBar.frame.height - 12)
//                toVC.view.convert(destinationOrigin, to: navigationController?.view)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    self.navigationController?.navigationBar.setNeedsLayout()
                    self.navigationController?.navigationBar.barTintColor = .black
                    self.navigationController?.navigationBar.tintColor = .white
                    UIApplication.shared.statusBarView?.backgroundColor = .black
                    self.navigationController?.navigationBar.layoutIfNeeded()
                    imageView.frame.origin = destinationOrigin
                    imageView.frame.size = destinationSize
                    imageView.cornerRadius = 0
                    blackScreen.alpha = 1
                }) {
                    _ in
                    blackScreen.removeFromSuperview()
                    imageView.removeFromSuperview()
                    vc_2.view.alpha = 1
                    vc_2.scrollView.alpha = 1
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? SurveysViewController, let initialIcon = vc_1.navigationItem.rightBarButtonItem?.value(forKey: "view") as? Icon, let vc_2 = toVC as? NewSurveySelectionTypeController, let keyWindow = navigationController?.view.window {
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                vc_2.ratingIcon.alpha = 0
                vc_2.pollIcon.alpha = 0
                
                let ratingIcon = Icon(frame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: keyWindow),
                                                            size: initialIcon.frame.size))
                ratingIcon.iconColor = initialIcon.iconColor
                ratingIcon.backgroundColor = initialIcon.backgroundColor
                ratingIcon.scaleMultiplicator = initialIcon.scaleMultiplicator
                ratingIcon.category = initialIcon.category
                let pollIcon = Icon(frame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: keyWindow),
                                                                  size: initialIcon.frame.size))
                pollIcon.iconColor          = initialIcon.iconColor
                pollIcon.backgroundColor    = initialIcon.backgroundColor
                pollIcon.scaleMultiplicator        = initialIcon.scaleMultiplicator
                pollIcon.category           = initialIcon.category
                keyWindow.addSubview(ratingIcon)
                keyWindow.addSubview(pollIcon)
                initialIcon.alpha           = 0
                
                let ratingOrigin    = vc_2.view.convert(vc_2.ratingIcon.frame.origin, to: keyWindow)
                let pollOrigin      = vc_2.view.convert(vc_2.pollIcon.frame.origin, to: keyWindow)
                let ratingSize      = vc_2.ratingIcon.frame.size
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                        ratingIcon.frame.origin = ratingOrigin
                        pollIcon.frame.origin   = pollOrigin
                        ratingIcon.frame.size   = ratingSize
                        pollIcon.frame.size     = ratingSize
                        vc_2.ratingLabel.alpha  = 1
                        vc_2.pollLabel.alpha    = 1
                    }) {
                        _ in
                        ratingIcon.removeFromSuperview()
                        pollIcon.removeFromSuperview()
                        vc_2.ratingIcon.alpha = 1
                        vc_2.pollIcon.alpha   = 1
//                            fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                            toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                        self.context?.completeTransition(true)
                    }
                }
                if let pollLayer = vc_2.pollIcon.icon as? CAShapeLayer, let destinationPath = pollLayer.path {
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (initialIcon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: duration,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: false)
                    let fillColorAnim   = Animations.get(property: .FillColor,
                                                         fromValue: initialIcon.iconColor.cgColor as Any,
                                                         toValue: UIColor.lightGray.withAlphaComponent(0.75).cgColor as Any,
                                                         duration: duration,
                                                         delay: 0,
                                                         repeatCount: 0,
                                                         autoreverses: false,
                                                         timingFunction: CAMediaTimingFunctionName.easeIn,
                                                         delegate: nil,
                                                         isRemovedOnCompletion: false)
                    animationBlocks.append {
                        pollIcon.icon.add(pathAnim, forKey: nil)
                        (pollIcon.icon as! CAShapeLayer).path = destinationPath
                    }
                    animationBlocks.append {
                        pollIcon.icon.add(fillColorAnim, forKey: nil)
                    }
                }
                if let ratingLayer = vc_2.ratingIcon.icon as? CAShapeLayer, let destinationPath = ratingLayer.path {
                    let pathAnim      = Animations.get(property: .Path,
                                                       fromValue: (initialIcon.icon as! CAShapeLayer).path as Any,
                                                       toValue: destinationPath as Any,
                                                       duration: duration,
                                                       delay: 0,
                                                       repeatCount: 0,
                                                       autoreverses: false,
                                                       timingFunction: CAMediaTimingFunctionName.easeOut,
                                                       delegate: nil,
                                                       isRemovedOnCompletion: false)
                    let fillColorAnim = Animations.get(property: .FillColor,
                                                       fromValue: initialIcon.iconColor.cgColor as Any,
                                                       toValue: UIColor.lightGray.withAlphaComponent(0.75).cgColor as Any,
                                                       duration: duration, delay: 0,
                                                       repeatCount: 0,
                                                       autoreverses: false,
                                                       timingFunction: CAMediaTimingFunctionName.easeIn,
                                                       delegate: nil,
                                                       isRemovedOnCompletion: false)
                    animationBlocks.append {
                        ratingIcon.icon.add(fillColorAnim, forKey: nil)
                    }
                    animationBlocks.append {
                        ratingIcon.icon.add(pathAnim, forKey: nil)
                        (ratingIcon.icon as! CAShapeLayer).path = destinationPath
                    }
                }
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
            } else if let vc_1 = fromVC as? NewSurveySelectionTypeController, toVC is NewPollController || toVC is NewRatingController {/*let initialIcon = vc_1.isRatingSelected! ? vc_1.ratingIcon : vc_1.pollIcon, let vc_2 = toVC as? NewPollController, let keyWindow = navigationController?.view.window, let destinationIcon = vc_2.navigationItem.titleView as? SurveyCategoryIcon {
                let icon = initialIcon.copyView() as! SurveyCategoryIcon
                icon.layer.masksToBounds = false
                icon.frame.origin = vc_1.view.convert(initialIcon.frame.origin, to: keyWindow)

                (icon.icon as! CAShapeLayer).path = (initialIcon.icon as! CAShapeLayer).path
                (icon.icon as! CAShapeLayer).fillColor = K_COLOR_RED.cgColor
//                .fillColor     = K_COLOR_RED.cgColor
//                icon.icon               = copyLayer
                keyWindow.addSubview(icon)
                initialIcon.alpha       = 0
                destinationIcon.alpha   = 0
                var destinationOrigin   = vc_2.navigationController!.navigationBar.convert(destinationIcon.frame.origin, to: keyWindow)
                destinationOrigin.x     = keyWindow.bounds.midX - destinationIcon.bounds.width/2
                let destinationSize     = destinationIcon.frame.size

                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration*0.9, delay: 0, options: [.curveEaseInOut], animations: {
                        icon.frame.origin = destinationOrigin
                        icon.frame.size   = destinationSize
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        destinationIcon.alpha   = 1
                        initialIcon.alpha       = 1
//                            fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                            toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        self.context?.completeTransition(true)
                    }
                }
                if let iconLayer = destinationIcon.icon as? CAShapeLayer, let destinationPath = iconLayer.path {
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (initialIcon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: duration*0.9,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: true)
                    animationBlocks.append {
                        icon.icon.add(pathAnim, forKey: nil)
                    }
                }*/
                
                animateWithBlurEffect(fromView: vc_1.view, toView: toVC.view, animationBlocks: []) {
                    _ in
                    self.context?.completeTransition(true)
                }
            }  else if let vc_1 = fromVC as? NewPollController, let vc_2 = toVC as? TextInputViewController, let cell = vc_1.tableView.cellForRow(at: vc_1.selectedCellIndex!) as? AnswerSelectionCell, let destinationView = vc_2.frameView, let destinationTextView = vc_2.textView as? UITextView, let initialView = cell.contentView as? UIView, let initialTextView = cell.textView as? UITextView {
                
                vc_2.isInputEnabled = false
                
                let attributedText = initialTextView.attributedText as! NSAttributedString
                vc_2.textViewWidthConstraint.constant = initialTextView.frame.width
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                toVC.view.isUserInteractionEnabled = false
                toVC.view.subviews.map {$0.isUserInteractionEnabled = false}
                
                vc_2.textView.becomeFirstResponder()
                let height = vc_2.view.frame.height - vc_2.keyboardHeight - vc_2.frameToStackHeight.constant - vc_2.hideKBIcon.frame.height - 20
                toVC.view.setNeedsLayout()
                vc_2.frameHeight.constant = height
                toVC.view.layoutIfNeeded()
                
                destinationView.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialView.convert(initialView.bounds.origin, to: navigationController?.view), size: initialView.frame.size))
                tempFrame.backgroundColor = .white
                tempFrame.cornerRadius = cell.cornerRadius
                let tempTextView = UITextView(frame: CGRect(origin: initialTextView.convert(initialTextView.bounds.origin, to: navigationController?.view), size: initialTextView.frame.size))
                tempTextView.attributedText = attributedText
                tempTextView.backgroundColor = .clear
                tempTextView.layer.masksToBounds = true
                tempTextView.alpha = 0
                tempTextView.layoutManager.hyphenationFactor = vc_2.type == .Title ? 0 : 1
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempTextView)
                tempTextView.contentOffset.y = initialTextView.contentOffset.y
                tempTextView.alpha = 1
                initialView.alpha = 0 
                
                let destinationFramePos = vc_2.view.convert(destinationView.frame.origin, to: navigationController?.view)
                let destinationFrameSize = CGSize(width: destinationView.frame.size.width, height: vc_2.frameHeight.constant)
                let destinationTextViewPos = destinationView.convert(destinationTextView.frame.origin, to: navigationController?.view)
                let destinationTextViewSize = CGSize(width: destinationTextView.frame.size.width, height: destinationTextView.frame.size.height)
                destinationTextView.font = initialTextView.font
                destinationTextView.textAlignment = .natural
                destinationTextView.layoutManager.hyphenationFactor = 1
                var animationBlocks: [Closure] = []
                
                vc_2.hideKBIcon.alpha = 0
                vc_2.okButton.alpha = 0
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.9, delay: 0, options: [.curveEaseOut], animations: {
                        tempFrame.frame.origin = destinationFramePos
                        tempFrame.frame.size = destinationFrameSize
                        tempFrame.backgroundColor = destinationView.backgroundColor
                        tempTextView.frame.origin = destinationTextViewPos
                        tempTextView.frame.size = destinationTextViewSize
                        tempTextView.textContainer.size = destinationTextView.textContainer.size
                        tempTextView.scrollToBottom()
                    }) {
                        _ in
                        UIView.animate(withDuration: 0.2, animations: {
                            vc_2.hideKBIcon.alpha = 1
                            vc_2.okButton.alpha = 1
                            //                            vc_2.text!.text = vc_2.textContent
                        }) {
                            _ in
                            if vc_2.needsScaleAnim {
                                UIView.animate(withDuration: 0.15, delay: 0.3, options: [.curveEaseInOut], animations: {
                                    tempTextView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                                    tempTextView.alpha = 0
                                }) {
                                    _ in
                                    tempTextView.removeFromSuperview()
                                    tempFrame.removeFromSuperview()
                                    destinationView.alpha = 1
                                    toVC.view.isUserInteractionEnabled = true
                                    toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                                    self.context?.completeTransition(true)
                                    vc_2.isInputEnabled = true
                                }
                            } else {
                                tempTextView.removeFromSuperview()
                                tempFrame.removeFromSuperview()
                                destinationView.alpha = 1
                                toVC.view.isUserInteractionEnabled = true
                                toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                                self.context?.completeTransition(true)
                                vc_2.isInputEnabled = true
                            }
                        }
                    }
                }
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks, withIncomingBlurEffect: false) { _ in }
            } else if (fromVC is NewPollController || fromVC is NewRatingController), let initialIcon = fromVC.navigationItem.titleView as? Icon, let vc_2 = toVC as? NewSurveyResultViewController, let keyWindow = navigationController?.view.window, let destinationIcon = vc_2.iconView as? Icon {
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                let icon = Icon(frame: CGRect(origin: initialIcon.convert(initialIcon.frame.origin, to: keyWindow),
                                                            size: initialIcon.frame.size))
                icon.iconColor = initialIcon.iconColor
                icon.backgroundColor = initialIcon.backgroundColor
//                icon.scaleMultiplicator = initialIcon.scaleMultiplicator
                icon.category = initialIcon.category
                keyWindow.addSubview(icon)
                initialIcon.alpha = 0
                destinationIcon.alpha = 0
                
                let destinationOrigin   = vc_2.view.convert(destinationIcon.frame.origin, to: keyWindow)
                let destinationSize     = destinationIcon.frame.size
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                        icon.frame.origin = destinationOrigin
                        icon.frame.size   = destinationSize
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        destinationIcon.alpha = 1
                        self.context?.completeTransition(true)
                    }
                }
                if let destinationLayer = vc_2.iconView.icon as? CAShapeLayer, let destinationPath = destinationLayer.path {
                    let pathAnim      = Animations.get(property: .Path,
                                                       fromValue: (initialIcon.icon as! CAShapeLayer).path as Any,
                                                       toValue: destinationPath as Any,
                                                       duration: duration,
                                                       delay: 0,
                                                       repeatCount: 0,
                                                       autoreverses: false,
                                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                       delegate: nil,
                                                       isRemovedOnCompletion: true)
                    animationBlocks.append {
                        icon.icon.add(pathAnim, forKey: nil)
                        (icon.icon as! CAShapeLayer).path = destinationPath
                    }
                }
                animateWithBlurEffect(fromView: fromVC.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
            } else if let vc_1 = fromVC as? SurveysViewController, let vc_2 = toVC as? PollController {
                var animationBlocks: [Closure] = []
                vc_2.tableView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5 )
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseOut], animations: {
                        vc_2.tableView.transform = .identity
                        fromVC.view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    }) {
                        _ in
                        fromVC.view.transform = .identity
                        self.context?.completeTransition(true)
                    }
                }
                animateWithBlurEffect(fromView: fromVC.view, toView: vc_2.view, animationBlocks: animationBlocks, withIncomingBlurEffect: false) { _ in }
            } else if let vc_1 = fromVC as? PollController, let vc_2 = toVC as? VotersViewController, let initialCell = vc_1.tableView.cellForRow(at: vc_2.initialIndex) as? ChoiceResultCell, let resultIndicator = initialCell.getResultIndicator() as? ResultIndicator, let imageViews = resultIndicator.actionView.subviews.filter({  $0 is UIImageView }) as? [UIImageView], let collectionView = vc_2.collectionView as? UICollectionView {

                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()

                var tempImageViews: [UIImageView] = []
                for (i, imageView) in imageViews.enumerated() {
                    let tempImageView = UIImageView(frame: CGRect(origin: imageView.superview!.convert(imageView.frame.origin, to: containerView), size: imageView.frame.size))
                    tempImageView.image = imageView.image
                    tempImageView.layer.zPosition = CGFloat(100 - i)
                    containerView.addSubview(tempImageView)
                    tempImageViews.append(tempImageView)
                    imageView.alpha = 0
                }
//                for i in 0..<imageViews.count {
////                    let tempImageView = initialImageView.copyView() as! UIImageView
//                    if let _cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? UserCell {
//                        let tempImageView = UIImageView(frame: CGRect(origin: _cell.convert(_cell.imageView.frame.origin, to: containerView), size: _cell.imageView.frame.size))
//                        tempImageView.image = _cell.imageView.image
////                        tempImageView.frame.origin = initialImageView.superview!.convert(initialImageView.frame.origin, to: containerView)
//                        tempImageView.layer.zPosition = CGFloat(100 - i)
//                        containerView.addSubview(tempImageView)
//                        tempImageViews.append(tempImageView)
//                        _cell.imageView.alpha = 0
//                    }
//                }

                var destinationOrigins: [CGPoint] = []
                var destinationSize: CGSize = .zero
                var destinationImageViews: [UIImageView] = []
                for i in 0..<tempImageViews.count {
                    if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? UserCell, let imageView = cell.imageView as? UIImageView{
                        if destinationSize == .zero { destinationSize = imageView.frame.size }
                        imageView.alpha = 0
                        destinationOrigins.append(cell.convert(imageView.frame.origin, to: containerView))
                        destinationImageViews.append(imageView)
                    }
                }
//                for (i,cell) in collectionView.visibleCells.enumerated() {
//                    if i == tempImageViews.count { break }
//                    if let downcastedCell = cell as? UserCell, let imageView = downcastedCell.imageView as? UIImageView {
//                        if destinationSize == .zero { destinationSize = imageView.frame.size }
//                        imageView.alpha = 0
//                        destinationOrigins.append(downcastedCell.convert(imageView.frame.origin, to: containerView))
//                        destinationImageViews.append(imageView)
//                    }
//                }

                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration*0.9, delay: 0, options: [.curveEaseInOut], animations: {
                            tempImageViews.enumerated().forEach({
                                (i, imageView) in
                                imageView.frame.origin = destinationOrigins[i]
                                imageView.frame.size = destinationSize
                            })
                    }) {
                        _ in
                        destinationImageViews.forEach({ $0.alpha = 1 })
                        tempImageViews.forEach({ $0.removeFromSuperview() })
                        imageViews.forEach({ $0.alpha = 1 })
                        self.context?.completeTransition(true)
                    }
                }
                animateWithBlurEffect(fromView: fromVC.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
            }
        } else if operation == .pop {
            if let vc_1 = fromVC as? SubcategoryViewController, let initialIcon = vc_1.icon, let vc_2 = toVC as? SurveysViewController, let collVC = vc_2.categoryVC as? CategoryCollectionViewController, let indexPath = collVC.currentIndex as? IndexPath, let cell = collVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                let animDuration = duration + Double(indexPath.row / 3 ) / 20
                duration = animDuration
                let icon = initialIcon.copyView() as! Icon
                icon.frame.origin = fromVC.view.convert(initialIcon.frame.origin, to: containerView)
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                toVC.tabBarController?.setTabBarVisible(visible: true, animated: true)
                
                let destinationSize = cell.icon.frame.size
                let destinationOrigin = collVC.returnPos
                let destinationPath = (cell.icon.icon as! CAShapeLayer).path
                let pathAnim = Animations.get(property: .Path,
                                              fromValue: (icon.icon as! CAShapeLayer).path as Any,
                                              toValue: destinationPath as Any,
                                              duration: duration,
                                              delay: 0,
                                              repeatCount: 0,
                                              autoreverses: false,
                                              timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                              delegate: nil,
                                              isRemovedOnCompletion: false)
                
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIView.animate(
                        withDuration: animDuration,
                        delay: 0,
                        options: [.curveEaseInOut],
                        animations: {
                            icon.frame.origin = destinationOrigin
                            icon.frame.size = destinationSize
                    })
                }
                animationBlocks.append { icon.icon.add(pathAnim, forKey: nil) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlocks, withIncomingBlurEffect: false) {
                    _ in
                    cell.icon.alpha = 1
                    icon.removeFromSuperview()
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
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
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
                
                //                var pos = CGPoint.zero
                //                pos.x = surveyPreview.userImage.center.x + surveyPreview.frame.origin.x
                //                pos.y = surveyPreview.userImage.frame.origin.y + surveyPreview.frame.origin.y + surveyPreview.convert(surveyPreview.frame.origin, to: fromVC.view).y + (navigationController?.navigationBar.subviews.first!.frame.height)! + UIApplication.shared.statusBarFrame.height
                //                userImage.center = pos
                
                
                
                
                //                context?.completeTransition(true)
            } else if let vc_1 = fromVC as? delUserViewController, let vc_2 = toVC as? SurveysViewController, let stackVC = vc_2.surveyStackVC as? SurveyStackViewController, let surveyPreview = stackVC.surveyPreview as? SurveyPreview {
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
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? CategorySelectionViewController, let collectionVC = vc_1.categoryVC as? CategoryCollectionViewController, let indexPath = collectionVC.currentIndex as? IndexPath, let cell = collectionVC.collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell, let initialIcon = cell.icon, let vc_2 = toVC as? NewPollController, let destinationIcon = vc_2.categoryIcon {
                
                vc_2.categoryTitle.alpha = 0
                vc_1.view.backgroundColor = .clear
//                cell.isSelected = false
                var origin = cell.contentView.convert(initialIcon.frame.origin, to: containerView)
                
                let icon = cell.icon.copyView() as! Icon
                icon.frame.origin = origin
                icon.backgroundColor = cell.category.tagColor
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                destinationIcon.category = Icon.Category(rawValue: vc_1.category!.ID) ?? .Null
                
                vc_2.contentView.alpha = 0
                vc_2.categoryTitle.text = ""
                vc_2.selectedColor = vc_1.category!.tagColor
                
                
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPos = collectionVC.returnPos
                
                let toValue = (icon.icon as! CAShapeLayer).path!.getScaledPath(size: destinationSize)
                let pathAnim        = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue  = (icon.icon as! CAShapeLayer).path
                pathAnim.toValue    = toValue
                pathAnim.duration   = self.duration// * 0.8
                pathAnim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
                
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
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveEaseIn], animations: {
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
//                    delay(seconds: self.duration * 0.33) {
//                        vc_2.category = vc_1.category
//                    }
                }) {
                    _ in
                    effectViewOutgoing.removeFromSuperview()
                    effectView.removeFromSuperview()
                    icon.removeFromSuperview()
                    cell.isSelected = false
                    destinationIcon.icon.alpha = 1
                    vc_1.actionButton.alpha = 1
                    vc_1.view.removeFromSuperview()
//                    vc_2.category = vc_1.category
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                    delay(seconds: 0.1) {
                        vc_2.category = vc_1.category
                    }
                }
                
            } else if let vc_1 = fromVC as? BinarySelectionViewController, let vc_2 = toVC as? NewPollController {
                
                let initialIcon: Icon = vc_1.isEnabled! ? vc_1.enabledIcon : vc_1.disabledIcon
                
                var destinationIcon: CircleButton!
                switch vc_1.selectionType {
                case .Anonimity:
                    destinationIcon = vc_2.anonIcon
                    vc_2.anonTitle.alpha = 0
                case .Privacy:
                    destinationIcon = vc_2.privacyIcon
                    vc_2.privacyTitle.alpha = 0
                case .Comments:
                    destinationIcon = vc_2.commentsIcon
                    vc_2.commentsTitle.alpha = 0
                case .Hot:
                    destinationIcon = vc_2.hotIcon
                    vc_2.hotTitle.alpha = 0
                }
                
                let icon = initialIcon.copyView() as! Icon
                icon.center = initialIcon.superview!.convert(initialIcon.center, to: containerView)
                containerView.addSubview(icon)
                initialIcon.alpha = 0
                
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPos = destinationIcon.convert(destinationIcon.icon.frame.origin, to: navigationController?.view)
                
                let destinationPath = (icon.icon as! CAShapeLayer).path?.getScaledPath(size: destinationIcon.icon.frame.size)//(destinationIcon.icon.icon as! CAShapeLayer).path
                let pathAnim        = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration * 0.8, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                let fillColorAnim   = Animations.get(property: .FillColor, fromValue: UIColor.black.cgColor as Any, toValue: UIColor.white.cgColor as Any, duration: duration * 0.9, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration * 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                        icon.frame.origin = destinationPos
                        icon.frame.size = destinationSize
                        icon.backgroundColor = vc_2.color
                        delay(seconds: self.duration * 0.65) {
                            switch vc_1.selectionType {
                            case .Anonimity:
                                vc_2.isAnonymous = vc_1.isEnabled!
                                vc_2.anonTitle.text = vc_1.isEnabled! == true ? vc_1.enabledLabel.text?.uppercased() : vc_1.disabledLabel.text?.uppercased()
                            case .Privacy:
                                vc_2.isPrivate = vc_1.isEnabled!
                                vc_2.privacyTitle.text = vc_1.isEnabled! == true ? vc_1.enabledLabel.text?.uppercased() : vc_1.disabledLabel.text?.uppercased()
                            case .Comments:
                                vc_2.isCommentingAllowed = vc_1.isEnabled!
                                vc_2.commentsTitle.text = vc_1.isEnabled! == true ? vc_1.enabledLabel.text?.uppercased() : vc_1.disabledLabel.text?.uppercased()
                            case .Hot:
                                vc_2.isHot = vc_1.isEnabled!
                                vc_2.hotTitle.text = vc_1.isEnabled! == true ? vc_1.enabledLabel.text?.uppercased() : vc_1.disabledLabel.text?.uppercased()
                            }
                        }
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
                    
//                    if vc_1.selectionType == .Anonimity {
//                        vc_2.isAnonymous = vc_1.isEnabled!
//                    } else {
//                        vc_2.isPrivate = vc_1.isEnabled!
//                    }
                    
                    initialIcon.alpha = 1
                    icon.removeFromSuperview()
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
                
            } else if let vc_1 = fromVC as? VotesCountViewController, let initialIcon = vc_1.actionButton as? CircleButton, let vc_2 = toVC as? NewPollController, let destinationIcon = vc_2.votesIcon {
                
                let icon = initialIcon.icon.copyView() as! Icon
                icon.center = initialIcon.superview!.convert(initialIcon.center, to: containerView)
                vc_1.actionButton.alpha = 0
                containerView.addSubview(icon)
                
                let destinationPath = (destinationIcon.icon.icon as! CAShapeLayer).path?.getScaledPath(size: destinationIcon.icon.frame.size)//(destinationIcon.icon.icon as! CAShapeLayer).path
                let pathAnim        = Animations.get(property: .Path, fromValue: (icon.icon as! CAShapeLayer).path as Any, toValue: destinationPath as Any, duration: duration * 0.8, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
                
                destinationIcon.color    = vc_1.actionButton.color
                destinationIcon.category = vc_1.actionButton.category
                let destinationSize = destinationIcon.icon.frame.size
                let destinationPos = destinationIcon.convert(destinationIcon.icon.frame.origin, to: navigationController?.view)
                var animationBlocks: [Closure] = []
                animationBlocks.append { UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    icon.frame.origin = destinationPos
                    icon.frame.size = destinationSize
                    delay(seconds: self.duration * 0.33) {
                        vc_2.votesCapacity = vc_1.votesCapacity
                    }
                })
                }
                animationBlocks.append { icon.icon.add(pathAnim, forKey: nil) }
                
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlocks) {
                    _ in
                    destinationIcon.alpha = 1
                    destinationIcon.icon.alpha = 1
//                    vc_2.votesCount = vc_1.votesCount
                    vc_1.actionButton.alpha = 1
                    icon.removeFromSuperview()
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? TextInputViewController, let vc_2 = toVC as? NewPollController, vc_1.type != .Answer, let initialFrame = vc_1.frameView, let initialTextView = vc_1.textView as? UITextView {
                var destinationView: UIView!
                var destinationTextView: UITextView!
                var destinationIcon: CircleButton!

                if vc_1.type == .Title {
                    destinationView = vc_2.pollTitleContainer
                    destinationTextView = vc_2.pollTitleTextView
                    destinationIcon = vc_2.titleIcon
                    vc_2.pollTitle = vc_1.textView.text
                } else if vc_1.type == .Description {
                    vc_2.pollDescription = vc_1.textView.text
                    destinationIcon = vc_2.pollDescriptionIcon
                    destinationView = vc_2.pollDescriptionContainer
                    destinationTextView = vc_2.pollDescriptionTextView
                    destinationTextView.layoutManager.hyphenationFactor = 1
//                    destinationTextView.contentOffset = .zero
                } else if vc_1.type == .Question {
                    vc_2.question = vc_1.textView.text
                    destinationIcon = vc_2.questionIcon
                    destinationView = vc_2.questionContainer
                    destinationTextView = vc_2.questionTextView
                    destinationTextView.layoutManager.hyphenationFactor = 1
//                    destinationTextView.contentOffset = .zero
                }
//                toVC.view.setNeedsLayout()
//                toVC.view.layoutIfNeeded()
                
                toVC.view.alpha = 0
                destinationIcon.alpha = 0
                destinationTextView.alpha = 0
                destinationTextView.contentOffset.y = 0
                destinationView.alpha = 0
                
                let tempFrame = UIView(frame: CGRect(origin: initialFrame.convert(initialFrame.bounds.origin, to: navigationController?.view), size: initialFrame.frame.size))
                tempFrame.backgroundColor = destinationView.backgroundColor
                tempFrame.cornerRadius = initialFrame.cornerRadius
                
                let tempTextView = UITextView(frame: CGRect(origin: initialTextView.convert(initialTextView.bounds.origin, to: navigationController?.view), size: initialTextView.frame.size),
                                              textContainer: initialTextView.textContainer)
                tempTextView.backgroundColor = .clear
                tempTextView.layer.masksToBounds = true
                tempTextView.contentOffset.y = initialTextView.contentOffset.y
                
                destinationTextView.font = initialTextView.font
                destinationTextView.textAlignment = initialTextView.textAlignment
                destinationTextView.text = initialTextView.text
                destinationTextView.textColor = .black
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempTextView)
                initialFrame.alpha = 0
                
                let icon = CircleButton(frame: CGRect(origin: CGPoint(x: containerView.frame.width/2 - destinationIcon.frame.width/2,
                                                                      y: vc_1.view.convert(initialFrame.frame.origin, to: navigationController.view).y - destinationIcon.frame.height/2),
                                                      size: destinationIcon.frame.size))
                icon.color = destinationIcon.color
                icon.category = destinationIcon.category
                icon.state = .On
                icon.lineWidth = destinationIcon.oval.lineWidth
                icon.icon.backgroundColor = icon.color.withAlphaComponent(0.3)
                containerView.addSubview(icon)
                icon.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                destinationIcon.alpha = 0
                
                let destinationFramePos = vc_2.contentView.convert(destinationView.frame.origin, to: navigationController?.view)
                let destinationFrameSize = destinationView.frame.size
                let destinationTextViewPos = destinationView.convert(destinationTextView.frame.origin, to: navigationController?.view)
                let destinationTextViewSize = destinationTextView.frame.size
                
                var animationBlocks: [Closure] = []
                
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0/*self.duration/2*/, options: [.curveEaseOut], animations: {
                        icon.frame.origin = CGPoint(x: containerView.frame.width/2 - icon.frame.width/2, y: destinationFramePos.y - icon.frame.height/2)
                        icon.transform = .identity
                        icon.icon.backgroundColor = destinationIcon.color
                        tempFrame.frame.origin = destinationFramePos
                        tempFrame.frame.size = destinationFrameSize
                        tempTextView.frame.origin = destinationTextViewPos
                        tempTextView.frame.size = destinationTextViewSize
                        tempTextView.textContainer.size = destinationTextView.textContainer.size
                        tempTextView.contentOffset.y = 0
                    }) {
                        _ in
                        tempFrame.removeFromSuperview()
                        tempTextView.removeFromSuperview()
                        icon.removeFromSuperview()
                        destinationIcon.alpha = 1
                        destinationTextView.alpha = 1
                        destinationView.alpha = 1
                        
                        if vc_1.type == .Title {
                            //                                destinationTextView.attributedText = initialTextView.attributedText
                            vc_2.stage = .Description
                        } else if vc_1.type == .Description {
                            vc_2.stage = .Hyperlink
                        } else if vc_1.type == .Question {
                            vc_2.stage = .Answers
                        }
                        self.context?.completeTransition(true)
                    }
                }
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
            } else if let vc_1 = fromVC as? ImageViewController, let vc_2 = toVC as? NewPollController {
                toVC.view.alpha = 1
                var destinationImageView: UIImageView!
                let blackScreen = UIView(frame: vc_1.view.frame)
                vc_1.view.alpha = 0
                blackScreen.addEquallyTo(to: vc_2.view)
                blackScreen.backgroundColor = .black
                blackScreen.alpha = 1
                let imageView = UIImageView(frame: vc_1.scrollView.imageView.getImageRect())//vc_1.scrollView.convert(vc_1.scrollView.imageView.getImageRect(), to: containerView))
                imageView.frame.origin.y += navigationController!.navigationBar.frame.height + 12
                imageView.layer.masksToBounds = true
                imageView.image = vc_1.scrollView.image
                imageView.contentMode = .scaleAspectFill
                containerView.addSubview(imageView)
                
                vc_2.setTitleForImage(vc_1.image, text: vc_1.titleString)
                
                switch vc_2.imagePosition {
                case 0:
                    destinationImageView = vc_2.image_1.subviews.filter { $0 is UIImageView }.first as? UIImageView ?? UIImageView()
                case 1:
                    destinationImageView = vc_2.image_2.subviews.filter { $0 is UIImageView }.first as? UIImageView ?? UIImageView()
                default:
                    destinationImageView = vc_2.image_3.subviews.filter { $0 is UIImageView }.first as? UIImageView ?? UIImageView()
                }
                destinationImageView.alpha = 0
                let destinationSize = destinationImageView.frame.size
                let destinationOrigin = destinationImageView.superview!.convert(destinationImageView.frame.origin, to: containerView)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                    UIApplication.shared.statusBarView?.backgroundColor = .white
                    imageView.frame.origin = destinationOrigin
                    imageView.frame.size = destinationSize
                    imageView.cornerRadius = destinationImageView.cornerRadius
                    blackScreen.alpha = 0
                }) {
                    _ in
                    blackScreen.removeFromSuperview()
                    imageView.removeFromSuperview()
                    destinationImageView.alpha = 1
//                        fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                        toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? ImageViewController, let vc_2 = toVC as? PollController, let cell = vc_2.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? ImagesCell, let destinationView = cell.scrollView {
                toVC.view.alpha = 1
                
                let blackScreen = UIView(frame: vc_1.view.frame)
                vc_1.view.alpha = 0
                blackScreen.addEquallyTo(to: vc_2.view)
                blackScreen.backgroundColor = .black
                blackScreen.alpha = 1
                let initialFrame = vc_1.scrollView.imageView.getImageRect()
                let imageView = UIImageView(frame: CGRect(origin: fromVC.view.convert(initialFrame.origin, to: navigationController.view), size: initialFrame.size))
                imageView.layer.masksToBounds = true
                imageView.image = vc_1.scrollView.image
                imageView.contentMode = .scaleAspectFill
                containerView.addSubview(imageView)
      
                let destinationSize = destinationView.frame.size
                let destinationOrigin = destinationView.superview!.convert(destinationView.frame.origin, to: containerView)
                
//                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.1, options: [.curveEaseInOut], animations: {
//                    self.navigationController?.navigationBar.setNeedsLayout()
//                    self.navigationController?.navigationBar.barTintColor = .white
//                    self.navigationController?.navigationBar.tintColor = .black
//                    self.navigationController?.navigationBar.layoutIfNeeded()
//                })
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
//                                        self.navigationController?.navigationBar.setNeedsLayout()
//                                        self.navigationController?.navigationBar.barTintColor = .white
//                                        self.navigationController?.navigationBar.tintColor = .black
//                                        self.navigationController?.navigationBar.layoutIfNeeded()
                    UIApplication.shared.statusBarView?.backgroundColor = .white
                    imageView.frame.origin = destinationOrigin
                    imageView.frame.size = destinationSize
                    imageView.cornerRadius = destinationView.cornerRadius
                                        self.navigationController?.navigationBar.barTintColor = .white
                    blackScreen.alpha = 0
                }) {
                    _ in
                    

                    blackScreen.removeFromSuperview()
                    imageView.removeFromSuperview()
                    destinationView.alpha = 1
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? NewSurveySelectionTypeController, let vc_2 = toVC as? SurveysViewController, let destinationIcon = vc_2.navigationItem.rightBarButtonItem?.value(forKey: "view") as? Icon, let keyWindow = navigationController?.view.window {
                
                let ratingIcon = Icon(frame: CGRect(origin: vc_1.view.convert(vc_1.ratingIcon.frame.origin, to: keyWindow),
                                                                  size: vc_1.ratingIcon.frame.size))
                ratingIcon.iconColor        = vc_1.ratingIcon.iconColor
                ratingIcon.backgroundColor  = vc_1.ratingIcon.backgroundColor
//                ratingIcon.scaleFactor = vc_1.ratingIcon.scaleFactor
//                ratingIcon.category = vc_1.ratingIcon.category
                ratingIcon.icon = vc_1.ratingIcon.icon
                let pollIcon = Icon(frame: CGRect(origin: vc_1.view.convert(vc_1.pollIcon.frame.origin, to: keyWindow),
                                                                size: vc_1.pollIcon.frame.size))
                pollIcon.iconColor          = vc_1.pollIcon.iconColor
                pollIcon.backgroundColor    = vc_1.pollIcon.backgroundColor
//                pollIcon.scaleFactor        = vc_1.pollIcon.scaleFactor
//                pollIcon.category           = vc_1.pollIcon.category
                pollIcon.icon = vc_1.pollIcon.icon
                keyWindow.addSubview(ratingIcon)
                keyWindow.addSubview(pollIcon)
                vc_1.pollIcon.alpha         = 0
                vc_1.ratingIcon.alpha       = 0
                
                let destinationOrigin = destinationIcon.convert(destinationIcon.frame.origin, to: keyWindow)
                let destinationSize   = destinationIcon.frame.size
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                        ratingIcon.frame.origin = destinationOrigin
                        pollIcon.frame.origin   = destinationOrigin
                        ratingIcon.frame.size   = destinationSize
                        pollIcon.frame.size     = destinationSize
                    }) {
                        _ in
                        ratingIcon.removeFromSuperview()
                        pollIcon.removeFromSuperview()
                        vc_1.ratingIcon.alpha = 1
                        vc_1.pollIcon.alpha   = 1
//                            fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                            toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                        self.context?.completeTransition(true)
                    }
                }
                if let pollLayer = destinationIcon.icon as? CAShapeLayer, let destinationPath = pollLayer.path {
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (vc_1.pollIcon.icon as! CAShapeLayer).path as Any,
                                                  toValue: (vc_1.pollIcon.icon as! CAShapeLayer).path?.getScaledPath(size: destinationSize) as Any,
                                                  duration: duration,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: false)
                    let fillColorAnim   = Animations.get(property: .FillColor,
                                                         fromValue: vc_1.pollIcon.iconColor.cgColor as Any,
                                                         toValue: UIColor.clear.cgColor as Any,
                                                         duration: duration,
                                                         delay: 0,
                                                         repeatCount: 0,
                                                         autoreverses: false,
                                                         timingFunction: CAMediaTimingFunctionName.easeIn,
                                                         delegate: nil,
                                                         isRemovedOnCompletion: false)
                    animationBlocks.append {
                        pollIcon.icon.add(pathAnim, forKey: nil)
//                        (pollIcon.icon as! CAShapeLayer).path = destinationPath
                    }
                    animationBlocks.append {
                        pollIcon.icon.add(fillColorAnim, forKey: nil)
                    }
                }
                if let ratingLayer = destinationIcon.icon as? CAShapeLayer, let destinationPath = ratingLayer.path {
                    let pathAnim      = Animations.get(property: .Path,
                                                       fromValue: (vc_1.ratingIcon.icon as! CAShapeLayer).path as Any,
                                                       toValue: (vc_1.ratingIcon.icon as! CAShapeLayer).path?.getScaledPath(size: destinationSize) as Any,//destinationPath as Any,
                                                       duration: duration,
                                                       delay: 0,
                                                       repeatCount: 0,
                                                       autoreverses: false,
                                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                       delegate: nil,
                                                       isRemovedOnCompletion: false)
                    let fillColorAnim = Animations.get(property: .FillColor,
                                                       fromValue: vc_1.ratingIcon.iconColor.cgColor as Any,
                                                       toValue: UIColor.clear.cgColor as Any,
                                                       duration: duration, delay: 0,
                                                       repeatCount: 0,
                                                       autoreverses: false,
                                                       timingFunction: CAMediaTimingFunctionName.easeIn,
                                                       delegate: nil,
                                                       isRemovedOnCompletion: false)
                    animationBlocks.append {
                        ratingIcon.icon.add(fillColorAnim, forKey: nil)
                    }
                    animationBlocks.append {
                        ratingIcon.icon.add(pathAnim, forKey: nil)
                    }
                }
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks, withIncomingBlurEffect: true) { _ in }
            }  else if let vc_1 = fromVC as? NewPollController, let initialIcon = vc_1.navigationItem.titleView as? Icon, let vc_2 = toVC as? NewSurveySelectionTypeController, let keyWindow = navigationController?.view.window, let destinationIcon = vc_2.isRatingSelected! ? vc_2.ratingIcon : vc_2.pollIcon {
                let icon = Icon(frame: CGRect(origin: vc_1.view.convert(initialIcon.frame.origin, to: keyWindow),
                                                            size: initialIcon.frame.size))
                icon.frame.origin.x     = keyWindow.bounds.midX - initialIcon.bounds.width/2
                icon.iconColor          = K_COLOR_RED
                icon.backgroundColor    = initialIcon.backgroundColor
                icon.icon = initialIcon.icon
                keyWindow.addSubview(icon)
                initialIcon.alpha = 0
                destinationIcon.alpha   = 0
                var destinationOrigin   = vc_2.view.convert(destinationIcon.frame.origin, to: keyWindow)
                let destinationSize     = destinationIcon.frame.size

                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveLinear], animations: {
                        icon.frame.origin = destinationOrigin
                        icon.frame.size   = destinationSize
                    }) {
                        _ in
                        icon.removeFromSuperview()
//                        destinationIcon.scaleFactor     = 0.7
//                        destinationIcon.category        = .Poll
                        (destinationIcon.icon as! CAShapeLayer).fillColor = K_COLOR_RED.cgColor
                        destinationIcon.alpha   = 1
                        initialIcon.alpha       = 1
//                            fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                            toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                        self.context?.completeTransition(true)
                    }
                }
                if let iconLayer = destinationIcon.icon as? CAShapeLayer, let destinationPath = iconLayer.path {
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (initialIcon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: duration,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: false)
                    animationBlocks.append {
                        icon.icon.add(pathAnim, forKey: nil)
                    }
                }
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
            } else if let vc_1 = fromVC as? TextInputViewController, let vc_2 = toVC as? NewPollController, let indexPath = vc_2.selectedCellIndex, let cell = vc_2.tableView.cellForRow(at: indexPath) as? AnswerSelectionCell, let initialView = vc_1.frameView, let initialTextView = vc_1.textView as? UITextView, let destinationView = cell.contentView as? UIView, let destinationTextView = cell.textView as? UITextView, let text = vc_1.textView.text {
                
                vc_2.answers[indexPath.row] = text.contains("\t") ? text : "\t\(text)"
                vc_2.tableView.reloadData()
                vc_2.tableView.alpha = 0
                vc_2.view.setNeedsLayout()
                vc_2.view.layoutIfNeeded()
                toVC.view.alpha = 0
                let tempFrame = UIView(frame: CGRect(origin: initialView.convert(initialView.bounds.origin, to: navigationController?.view), size: initialView.frame.size))
                tempFrame.backgroundColor = initialView.backgroundColor
                tempFrame.cornerRadius = initialView.cornerRadius
                
                let tempTextView = UITextView(frame: CGRect(origin: initialTextView.convert(initialTextView.bounds.origin, to: navigationController?.view),
                                                            size: initialTextView.frame.size),
                                              textContainer: initialTextView.textContainer)
                tempTextView.backgroundColor = .clear
                tempTextView.layer.masksToBounds = true
                tempTextView.contentOffset.y = initialTextView.contentOffset.y
                
                destinationTextView.font = initialTextView.font
                destinationTextView.text = initialTextView.text
                destinationTextView.textColor = .black
                containerView.addSubview(tempFrame)
                containerView.addSubview(tempTextView)
                initialView.alpha = 0
                
//                let destinationPos = destinationView.convert(destinationView.bounds.origin, to: navigationController?.view)
//                let destinationSize = destinationView.frame.size
                
                let destinationFramePos = destinationView.convert(destinationView.frame.origin, to: navigationController?.view)
                let destinationFrameSize = destinationView.frame.size
                let destinationTextViewPos = destinationView.convert(destinationTextView.frame.origin, to: navigationController?.view)
                let destinationTextViewSize = destinationTextView.frame.size
                
                var animationBlocks: [Closure] = []
                
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0/*self.duration/2*/, options: [.curveEaseIn], animations: {
                        tempFrame.frame.origin = destinationFramePos
                        tempFrame.frame.size = destinationFrameSize
                        tempTextView.frame.origin = destinationTextViewPos
                        tempTextView.frame.size = destinationTextViewSize
                        tempTextView.textContainer.size = destinationTextView.textContainer.size
                        tempTextView.contentOffset.y = 0
                        tempFrame.backgroundColor = .white
                        vc_2.tableView.alpha = 1
                    }) {
                        _ in
                        tempFrame.removeFromSuperview()
                        tempTextView.removeFromSuperview()
                        destinationTextView.alpha = 1
                        destinationView.alpha = 1
//                        destinationView.alpha = 1
//                        //                        UIView.transition(with: label, duration: 0.15, options: .transitionCrossDissolve, animations: {
//                        UIView.animate(withDuration: 0.15, animations: {
//                            tempFrame.alpha = 0
//                        }) {
//                            _ in
                            vc_2.selectedCellIndex = nil
//                            tempFrame.removeFromSuperview()
//                                fromVC.view.subviews.map {$0.isUserInteractionEnabled = true}
//                                toVC.view.subviews.map {$0.isUserInteractionEnabled = true}
                            if vc_2.answers.count < 2 {
                                vc_2.appendAnswer(0.1)
                            }
                            self.context?.completeTransition(true)
//                        }
                    }
                }
                
                animateWithBlurEffect(fromView: vc_1.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
            } else if let vc_1 = fromVC as? NewSurveyResultViewController, let initialIcon = vc_1.iconView as? Icon, (toVC is NewPollController || toVC is NewRatingController), let keyWindow = navigationController?.view.window, let destinationIcon = toVC.navigationItem.titleView as? Icon {
                let icon = Icon(frame: CGRect(origin: vc_1.view.convert(initialIcon.frame.origin, to: keyWindow),
                                                            size: initialIcon.frame.size))
                icon.iconColor = initialIcon.iconColor
                icon.backgroundColor = initialIcon.backgroundColor
                icon.category = initialIcon.category
                keyWindow.addSubview(icon)
                initialIcon.alpha = 0
                destinationIcon.alpha = 0.1
                
                let destinationSize     = destinationIcon.frame.size
                let destinationOrigin   = CGPoint(x: (keyWindow.frame.width - destinationSize.width)/2, y: navigationController!.navigationBar.convert(destinationIcon.frame.origin, to: keyWindow).y)
                
                
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                        icon.frame.origin = destinationOrigin
                        icon.frame.size   = destinationSize
                        icon.alpha = 0
                    }) {
                        _ in
                        icon.removeFromSuperview()
                        destinationIcon.alpha = 1
                        self.context?.completeTransition(true)
                    }
                }
                if let destinationLayer = destinationIcon.icon as? CAShapeLayer, let destinationPath = destinationLayer.path {
                    let pathAnim      = Animations.get(property: .Path,
                                                       fromValue: (initialIcon.icon as! CAShapeLayer).path as Any,
                                                       toValue: destinationPath as Any,
                                                       duration: duration*1.1,
                                                       delay: 0,
                                                       repeatCount: 0,
                                                       autoreverses: false,
                                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                       delegate: nil,
                                                       isRemovedOnCompletion: true)
                    animationBlocks.append {
                        icon.icon.add(pathAnim, forKey: nil)
//                        (icon.icon as! CAShapeLayer).path = destinationPath
                    }
                }
                animateWithBlurEffect(fromView: vc_1.view, toView: toVC.view, animationBlocks: animationBlocks) { _ in }
            } else if fromVC is NewSurveyResultViewController, toVC is SurveysViewController {
                toVC.view.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [{
                    toVC.view.transform = .identity
//                    fromVC.view.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
                    }], completion: {
                        _ in
//                        fromVC.view.transform = .identity
                        self.context?.completeTransition(true)
                })
                
            }  else if fromVC is PollController, toVC is SurveysViewController {
                var animationBlocks: [Closure] = []
                toVC.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration/2, delay: 0, options: [.curveEaseInOut], animations: {
                        fromVC.view.alpha = 0
                    }) { _ in }
                }
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration, delay: 0, options: [.curveEaseInOut], animations: {
                        fromVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        toVC.view.transform = .identity
                    }) {
                        _ in
                        self.context?.completeTransition(true)
                    }
                }
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: animationBlocks, withIncomingBlurEffect: true) { _ in }
            } else if let vc_1 = fromVC as? ClaimViewController, let vc_2 = toVC as? SurveysViewController {
                animateWithBlurEffect(fromView: fromVC.view, toView: toVC.view, animationBlocks: [], withIncomingBlurEffect: false) {
                    _ in
                    self.context?.completeTransition(true)
                }
            } else if let vc_1 = fromVC as? VotersViewController, let vc_2 = toVC as? PollController, let cell = vc_2.tableView.cellForRow(at: vc_1.initialIndex) as? ChoiceResultCell, let resultIndicator = cell.getResultIndicator() as? ResultIndicator, let imageViews = resultIndicator.actionView.subviews.filter({  $0 is UIImageView }) as? [UIImageView], let collectionView = vc_1.collectionView as? UICollectionView {
                
                var tempImageViews: [UIImageView] = []
                for (i, initialImageView) in imageViews.enumerated() {
                    if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? UserCell {
                        let tempImageView = UIImageView(frame: CGRect(origin: cell.convert(cell.imageView.frame.origin, to: containerView), size: cell.imageView.frame.size))
                        tempImageView.image = cell.imageView.image
//                        tempImageView.frame.origin = cell.convert(cell.imageView.frame.origin, to: containerView)
                        tempImageView.layer.zPosition = CGFloat(100 - i)
                        containerView.addSubview(tempImageView)
                        tempImageViews.append(tempImageView)
                        cell.imageView.alpha = 0
                    }
                }


                var destinationOrigins: [CGPoint] = []
                var destinationSize: CGSize = .zero
                for imageView in imageViews {
                        if destinationSize == .zero { destinationSize = imageView.frame.size }
                        destinationOrigins.append(imageView.superview!.convert(imageView.frame.origin, to: containerView))
                }
                var animationBlocks: [Closure] = []
                animationBlocks.append {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.duration*0.9, delay: 0, options: [.curveEaseInOut], animations: {
                        tempImageViews.enumerated().forEach({
                            (i, imageView) in
                            imageView.frame.origin = destinationOrigins[i]
                            imageView.frame.size = destinationSize
                        })
                    }) {
                        _ in
                        imageViews.forEach({ $0.alpha = 1 })
                        tempImageViews.forEach({ $0.removeFromSuperview() })
                        self.context?.completeTransition(true)
                    }
                }
                animateWithBlurEffect(fromView: fromVC.view, toView: vc_2.view, animationBlocks: animationBlocks) { _ in }
//                animateWithBlurEffect(fromView: fromVC.view, toView: vc_2.view, animationBlocks: []) { _ in self.context?.completeTransition(true) }
            } else {
                context?.completeTransition(true)
            }
        }
    }
    
    private func animateWithBlurEffect(fromView: UIView, toView: UIView, animationBlocks: [Closure], withIncomingBlurEffect: Bool = true, completion: @escaping(Bool)->()) {
        let effectViewOutgoing = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        effectViewOutgoing.frame = fromView.bounds
        effectViewOutgoing.addEquallyTo(to: fromView)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: [], animations: {
            effectViewOutgoing.effect = nil
        })
        var effectViewIncoming: UIVisualEffectView!
        if withIncomingBlurEffect {
            effectViewIncoming = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            effectViewIncoming.frame = toView.bounds
            effectViewIncoming.addEquallyTo(to: toView)
        }
        let delay = duration * 0.25
        
        DispatchQueue.main.async {
            animationBlocks.map({ $0() })
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            fromView.alpha = 0
            //            if !useIncomingEffect {
            toView.alpha = 1
            //            }
            effectViewOutgoing.effect = UIBlurEffect(style: .light)
        }) {
            _ in
            effectViewOutgoing.removeFromSuperview()
            if !withIncomingBlurEffect {
                fromView.removeFromSuperview()
                completion(true)
            }
        }
        
        if withIncomingBlurEffect {
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
