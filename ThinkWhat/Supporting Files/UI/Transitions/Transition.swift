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
  
  // MARK: - Destructor
  deinit {
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
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
//      toVC.view.alpha = 0
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
              appDelegate.window!.setNeedsLayout()
              fakeClaimConstraint.constant -= fakeClaimOrigin.x + fakeClaim.bounds.width
              fakeNextConstraint.constant += UIScreen.main.bounds.width - fakeNextOrigin.x
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
        toView.alpha = 1
        let padding: CGFloat = 8
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
        
        let logoText = Icon(category: .LogoText, scaleMultiplicator: 1, iconColor: Colors.main)
        logoText.frame = CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                             to: containerView),
                                size: fromView.logoText.bounds.size)
        containerView.addSubview(logoText)
        fromView.logoText.alpha = 0
        logoText.iconColor = Colors.main
        logoText.scaleMultiplicator = 1
        logoText.category = .LogoText
        
        let button: UIButton = {
          let instance = UIButton()
          if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .small
            config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
            config.baseBackgroundColor = Colors.Logo.Flame.rawValue
            config.contentInsets.top = padding
            config.contentInsets.bottom = padding
            config.contentInsets.leading = 20
            config.contentInsets.trailing = 20
            config.attributedTitle = AttributedString("getStartedButton".localized.uppercased(),
                                                      attributes: AttributeContainer([
                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                        .foregroundColor: UIColor.white as Any
                                                      ]))
            instance.configuration = config
          } else {
            instance.cornerRadius = fromView.button.cornerRadius
            instance.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.uppercased(),
                                                           attributes: [
                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                            .foregroundColor: UIColor.white as Any
                                                           ]),
                                        for: .normal)
          }
          
          return instance
        }()
        button.frame = CGRect(origin: fromView.convert(fromView.button.frame.origin,
                                                       to: containerView),
                              size: fromView.button.bounds.size)
        containerView.addSubview(button)
        fromView.button.alpha = 0
        toView.loginButton.alpha = 0
        toView.loginButton.transform = .init(scaleX: 0.5, y: 0.5)
        
        let label: UILabel = {
          let instance = UILabel()
          instance.numberOfLines = 0
          instance.backgroundColor = .clear
          instance.textAlignment = .center
          instance.alpha = 1
          instance.text = "welcomeLabel".localized
          instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title3)
          
          return instance
        }()
        label.frame = CGRect(origin: fromView.label.superview!.convert(fromView.label.frame.origin,
                                                                       to: containerView),
                             size: fromView.label.bounds.size)
        containerView.addSubview(label)
        fromView.label.alpha = 0
        
        let loginContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        let loginDestination = toView.loginContainer.superview!.convert(toView.loginContainer.frame.origin,
                                                                        to: containerView)
        loginContainer.frame = CGRect(origin: loginDestination,
                                      size: toView.loginContainer.bounds.size)
        loginContainer.frame.origin.y = containerView.bounds.height
        //          loginContainer.transform = .init(scaleX: 0.75, y: 0.75)
        loginContainer.cornerRadius = loginContainer.bounds.width * 0.025
        containerView.addSubview(loginContainer)
        toView.loginContainer.alpha = 0
        
        let passwordContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        let passwordDestination = toView.passwordContainer.superview!.convert(toView.passwordContainer.frame.origin,
                                                                              to: containerView)
        passwordContainer.frame = CGRect(origin: loginDestination,
                                         size: toView.passwordContainer.bounds.size)
        passwordContainer.frame.origin.y = containerView.bounds.height
        passwordContainer.cornerRadius = passwordContainer.bounds.width * 0.025
        containerView.addSubview(passwordContainer)
        toView.passwordContainer.alpha = 0
        
        let orLabel: UILabel = {
          let instance = UILabel()
          instance.numberOfLines = 0
          instance.textAlignment = .center
          instance.text = "providerLabel".localized
          instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
          
          return instance
        }()
        let orLabelDestination = toView.passwordContainer.superview!.convert(toView.label.frame.origin,
                                                                             to: containerView)
        orLabel.frame = CGRect(origin: loginDestination,
                               size: toView.label.bounds.size)
        orLabel.frame.origin.y = containerView.bounds.height
        containerView.addSubview(orLabel)
        toView.label.alpha = 0
        
        let signupButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                         attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)
          
          return instance
        }()
        let signupButtonDestination = toView.signupButton.superview!.convert(toView.signupButton.frame.origin,
                                                                             to: containerView)
        signupButton.frame = CGRect(origin: signupButtonDestination,
                                    size: toView.signupButton.bounds.size)
        signupButton.frame.origin.x = -(containerView.bounds.width + signupButton.frame.width)
        containerView.addSubview(signupButton)
        toView.signupButton.alpha = 0
        
        
        let forgotButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                         attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)
          
          return instance
        }()
        let forgotButtonDestination = toView.forgotButton.superview!.convert(toView.forgotButton.frame.origin,
                                                                             to: containerView)
        forgotButton.frame = CGRect(origin: forgotButtonDestination,
                                    size: toView.forgotButton.bounds.size)
        forgotButton.frame.origin.x = containerView.bounds.width
        containerView.addSubview(forgotButton)
        toView.forgotButton.alpha = 0
        
        ///Animate coordinates
        let views: [ [UIView: [UIView: CGPoint]]] = [
          [toView.loginContainer: [loginContainer: loginDestination]],
          [toView.passwordContainer: [passwordContainer: passwordDestination]],
          [toView.label: [orLabel: orLabelDestination]],
          [toView.signupButton: [signupButton: signupButtonDestination]],
          [toView.forgotButton: [forgotButton: forgotButtonDestination]],
        ]
        
        if let stack = toView.logos.getSubview(type: UIStackView.self) {
          stack.arrangedSubviews.forEach {
            $0.transform = .init(scaleX: 0.75, y: 0.75)
            $0.alpha = 0
          }
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
          label.frame.origin.x = -label.bounds.width
          //          logoText.frame.origin.x = containerView.bounds.width
          button.frame.origin.y = containerView.bounds.height
        }) {
          _ in
          label.removeFromSuperview()
          //          logoText.removeFromSuperview()
          button.removeFromSuperview()
          
          delay(seconds: 0.3) {
            if let stack = toView.logos.getSubview(type: UIStackView.self) {
              stack.arrangedSubviews.enumerated().forEach { index, view in
                UIView.animate(
                  withDuration: 0.3,
                  delay: 0.1*Double(index),
                  options: [.curveEaseInOut],
                  animations: {
                    view.transform = .identity
                    view.alpha = 1
                  })
              }
            }
          }
          
          views.enumerated().forEach { index, dict in
            guard let destination = dict.keys.first,
                  let nested = dict.values.first,
                  let coordinate = nested.values.first,
                  let view = nested.keys.first
            else { return }
            
            UIView.animate(
              withDuration: 0.6,
              delay: 0.3,
              usingSpringWithDamping: 0.7,
              initialSpringVelocity: 0.3,
              options: [.curveEaseInOut],
              animations: {
                toView.loginButton.alpha = 1
                toView.loginButton.transform = .identity
              })
            
            UIView.animate(
              withDuration: 0.6,
              delay: 0.05*Double(index),
              usingSpringWithDamping: 0.8,
              initialSpringVelocity: 0.3,
              options: [.curveEaseInOut],
              animations: {
                view.frame.origin = coordinate
                //                                    size: toView.logoIcon.bounds.size)
                //                loginContainer.transform = .identity
              }) {  _ in
                destination.alpha = 1
                view.removeFromSuperview()
                
                //                if index == 0 {
                //                  UIView.animate(
                //                    withDuration: 0.6,
                //                    delay: 0,
                //                    usingSpringWithDamping: 0.7,
                //                    initialSpringVelocity: 0.3,
                //                    options: [.curveEaseInOut],
                //                    animations: {
                //                      toView.loginButton.alpha = 1
                //                      toView.loginButton.transform = .identity
                //                    })
                //                }
                
                guard index == views.count - 1 else { return }
                
                self.context?.completeTransition(true)
              }
          }
        }
        
        //        UIView.animate(withDuration: 0.5,
        //                       delay: 0,
        //                       options: .curveEaseInOut,
        //                       animations: {
        //          logo.frame = CGRect(origin: toView.logoIcon.superview!.convert(toView.logoIcon.frame.origin,
        //                                                                         to: containerView),
        //                              size: toView.logoIcon.bounds.size)
        //        }) {  _ in
        //          toVC.view.alpha = 1
        //          toView.logoIcon.alpha = 1
        //          logo.removeFromSuperview()
        //          //            self.context?.completeTransition(true)
        //        }
        //
        logoText.icon.add(Animations.get(property: .Path,
                                         fromValue: (logoText.icon as! CAShapeLayer).path as Any,
                                         toValue: (toView.logoText.icon as! CAShapeLayer).path as Any,
                                         duration: 0.3,
                                         delay: 0,
                                         repeatCount: 0,
                                         autoreverses: false,
                                         timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                         delegate: nil,
                                         isRemovedOnCompletion: false),
                          forKey: nil)
        
        UIView.animate(
          withDuration: 0.6,
          delay: 0,
          usingSpringWithDamping: 0.7,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut],
          animations: {
            logo.frame = CGRect(origin: toView.logoIcon.superview!.convert(toView.logoIcon.frame.origin,
                                                                           to: containerView),
                                size: toView.logoIcon.bounds.size)
            logoText.frame = CGRect(origin: toView.logoText.superview!.convert(toView.logoText.frame.origin,
                                                                               to: containerView),
                                    size: toView.logoText.bounds.size)
          }) { _ in
            logoText.removeFromSuperview()
            toView.logoText.alpha = 1
            toVC.view.alpha = 1
            toView.logoIcon.alpha = 1
            logo.removeFromSuperview()
          }
      } else if let fromView = fromVC.view as? SignInView,
                let toView = toVC.view as? TermsView,
                let titleView = toVC.navigationController?.navigationBar.subviews.filter({ $0 is UIStackView }).first as? UIStackView,
                let logoIcon = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoIcon" }).first as? Icon,
                let logoText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoText" }).first as? Icon,
                let logosStack = fromView.logos.getSubview(type: UIStackView.self, identifier: "stack")  {
        
        let opaque = UIView.opaque()
        opaque.place(inside: appDelegate.window!)
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        toVC.navigationController?.navigationBar.setNeedsLayout()
        toVC.navigationController?.navigationBar.layoutIfNeeded()
        toView.alpha = 1
        toView.acceptButton.alpha = 0
        toView.webView.alpha = 0
        
        let padding: CGFloat = 8
        let logo: Icon = {
          let instance = Icon()
          instance.frame = CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                               to: containerView),
                                  size: fromView.logoIcon.bounds.size)
          fromView.logoIcon.alpha = 0
          logoIcon.alpha = 0
          instance.iconColor = Colors.main
          instance.scaleMultiplicator = 1
          instance.category = .Logo
          
          return instance
        }()
        let fakeLogoText: Icon = {
          let instance = Icon()
          instance.frame = CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                               to: containerView),
                                  size: fromView.logoText.bounds.size)
          fromView.logoIcon.alpha = 0
          logoText.alpha = 0
          instance.iconColor = Colors.main
          instance.scaleMultiplicator = 1
          instance.category = .LogoText
          
          return instance
        }()
        
        opaque.addSubview(logo)
        opaque.addSubview(fakeLogoText)
        
        logo.icon.add(Animations.get(property: .Path,
                                     fromValue: (logo.icon as! CAShapeLayer).path as Any,
                                     toValue: (logoIcon.icon as! CAShapeLayer).path as Any,
                                     duration: 0.3,
                                     delay: 0,
                                     repeatCount: 0,
                                     autoreverses: false,
                                     timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                     delegate: nil,
                                     isRemovedOnCompletion: false),
                      forKey: nil)
        fakeLogoText.icon.add(Animations.get(property: .Path,
                                             fromValue: (fakeLogoText.icon as! CAShapeLayer).path as Any,
                                             toValue: (logoText.icon as! CAShapeLayer).path as Any,
                                             duration: 0.3,
                                             delay: 0,
                                             repeatCount: 0,
                                             autoreverses: false,
                                             timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                             delegate: nil,
                                             isRemovedOnCompletion: false),
                              forKey: nil)
        
        
        
        let loginButton: UIButton = {
          let instance = UIButton()
          if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .small
            config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
            config.baseBackgroundColor = Colors.main
            config.contentInsets.top = padding
            config.contentInsets.bottom = padding
            config.contentInsets.leading = 20
            config.contentInsets.trailing = 20
            config.attributedTitle = AttributedString("loginButton".localized.uppercased(),
                                                      attributes: AttributeContainer([
                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                        .foregroundColor: UIColor.white as Any
                                                      ]))
            instance.configuration = config
          } else {
            instance.backgroundColor = Colors.main
            instance.cornerRadius = fromView.loginButton.cornerRadius
            instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
                                                           attributes: [
                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                            .foregroundColor: UIColor.white as Any
                                                           ]),
                                        for: .normal)
          }
          
          return instance
        }()
        var loginButtonCoordinate = fromView.loginButton.superview!.convert(fromView.loginButton.frame.origin,
                                                                 to: containerView)
        //        buttonCoordinate.y = containerView.bounds.height
        loginButton.frame = CGRect(origin: loginButtonCoordinate,
                                    size: fromView.loginButton.bounds.size)
        containerView.addSubview(loginButton)
        loginButtonCoordinate.y = containerView.bounds.height
        
        
        let signupButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                         attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)
          
          return instance
        }()
        var signupButtonDestination = fromView.signupButton.superview!.convert(fromView.signupButton.frame.origin,
                                                                               to: containerView)
        signupButton.frame = CGRect(origin: signupButtonDestination,
                                    size: fromView.signupButton.bounds.size)
        //        signupButton.frame.origin.x = -(containerView.bounds.width + signupButton.frame.width)
        containerView.addSubview(signupButton)
        fromView.signupButton.alpha = 0
        signupButtonDestination.y = containerView.bounds.height
        
        
        let forgotButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                         attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)
          
          return instance
        }()
        let forgotButtonDestination = fromView.forgotButton.superview!.convert(fromView.forgotButton.frame.origin,
                                                                               to: containerView)
        forgotButton.frame = CGRect(origin: forgotButtonDestination,
                                    size: fromView.forgotButton.bounds.size)
        //        forgotButton.frame.origin.x = containerView.bounds.width
        containerView.addSubview(forgotButton)
        fromView.forgotButton.alpha = 0
        
        let loginContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        var loginDestination = fromView.loginContainer.superview!.convert(fromView.loginContainer.frame.origin,
                                                                          to: containerView)
        loginContainer.frame = CGRect(origin: loginDestination,
                                      size: fromView.loginContainer.bounds.size)
        //        loginContainer.frame.origin.y = containerView.bounds.height
        //          loginContainer.transform = .init(scaleX: 0.75, y: 0.75)
        loginContainer.cornerRadius = loginContainer.bounds.width * 0.025
        containerView.addSubview(loginContainer)
        fromView.loginContainer.alpha = 0
        loginDestination.x = -(containerView.bounds.width + loginContainer.frame.width)
        
        let passwordContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        var passwordDestination = fromView.passwordContainer.superview!.convert(fromView.passwordContainer.frame.origin,
                                                                                to: containerView)
        passwordContainer.frame = CGRect(origin: passwordDestination,
                                         size: fromView.passwordContainer.bounds.size)
        passwordContainer.cornerRadius = passwordContainer.bounds.width * 0.025
        containerView.addSubview(passwordContainer)
        fromView.passwordContainer.alpha = 0
        passwordDestination.x = containerView.bounds.height
        
        let orLabel: UILabel = {
          let instance = UILabel()
          instance.numberOfLines = 0
          instance.textAlignment = .center
          instance.text = "providerLabel".localized
          instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
          
          return instance
        }()
        var orLabelDestination = fromView.label.superview!.convert(fromView.label.frame.origin,
                                                                   to: containerView)
        orLabel.frame = CGRect(origin: orLabelDestination,
                               size: fromView.label.bounds.size)
        //        orLabel.frame.origin.y = containerView.bounds.height
        containerView.addSubview(orLabel)
        fromView.label.alpha = 0
        orLabelDestination.x = containerView.bounds.height
        
        var logosDestination = fromView.logos.superview!.convert(fromView.logos.frame.origin,
                                                                 to: containerView)
        let logos: UIView = {
          let stack = UIStackView(arrangedSubviews: logosStack.arrangedSubviews.map {
            let instance = $0.copyView()!
            instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
            
            return instance
          })
          stack.axis = .horizontal
          let instance = UIView.opaque()
          stack.placeInCenter(of: instance,
                              topInset: 0,
                              bottomInset: 0)
          
          return instance
        }()
        logos.frame = CGRect(origin: logosDestination,
                             size: fromView.logos.bounds.size)
        containerView.addSubview(logos)
        fromView.label.alpha = 0
        logosDestination.x = containerView.bounds.height
        
        ///Animate coordinates
        let views: [[UIView: CGPoint]] = [
          [loginContainer: loginDestination],
          [passwordContainer: passwordDestination],
          [loginButton: loginButtonCoordinate],
          [orLabel: orLabelDestination],
          [logos: logosDestination],
          [signupButton: signupButtonDestination],
          [forgotButton: forgotButtonDestination],
        ]
        
        let acceptButton: UIButton = {
          let instance = UIButton()
          if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .small
            config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
            config.baseBackgroundColor = UIColor.systemGray
            config.contentInsets.top = padding
            config.contentInsets.bottom = padding
            config.contentInsets.leading = 20
            config.contentInsets.trailing = 20
            config.attributedTitle = AttributedString("acceptButton".localized.uppercased(),
                                                      attributes: AttributeContainer([
                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                        .foregroundColor: UIColor.white as Any
                                                      ]))
            instance.configuration = config
          } else {
            instance.cornerRadius = toView.acceptButton.cornerRadius
            instance.setAttributedTitle(NSAttributedString(string: "acceptButton".localized.uppercased(),
                                                           attributes: [
                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                            .foregroundColor: UIColor.white as Any
                                                           ]),
                                        for: .normal)
          }
          
          return instance
        }()
        let acceptButtonCoordinate = toView.acceptButton.convert(CGPoint(x: loginButtonCoordinate.x,
                                                                         y: containerView.bounds.height),
                                                                 to: containerView)
//        acceptButtonCoordinate.y = containerView.bounds.height
//        acceptButtonCoordinate.x = containerView.bounds.height
        acceptButton.frame = CGRect(origin: acceptButtonCoordinate,
                                    size: toView.acceptButton.bounds.size)
        containerView.addSubview(acceptButton)
        acceptButton.center.x = containerView.bounds.midX
        
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.6,
                       options: .curveEaseOut,
                       animations: {
          acceptButton.frame.origin = toView.acceptButton.superview!.convert(toView.acceptButton.frame.origin,
                                                                  to: containerView)
          toView.webView.alpha = 1
        }) { _ in
          toView.acceptButton.alpha = 1
          acceptButton.removeFromSuperview()
        }
        
        views.enumerated().forEach { index, dict in
          guard let coordinate = dict.values.first,
                let view = dict.keys.first
          else { return }
          
          UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: [.curveEaseInOut],
            animations: {
              view.frame.origin = coordinate
            }) {  _ in
              view.removeFromSuperview()
              
              guard index == views.count - 1 else { return }
              
              self.context?.completeTransition(true)
              fromView.forgotButton.alpha = 1
              fromView.signupButton.alpha = 1
              fromView.logoIcon.alpha = 1
              fromView.loginContainer.alpha = 1
              fromView.passwordContainer.alpha = 1
            }
        }
        
        
        titleView.convert(logoIcon.frame.origin, to: containerView)
        UIView.animate(
          withDuration: 0.6,
          delay: 0,
          usingSpringWithDamping: 0.7,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut],
          animations: {
            logo.frame = CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
                                                                    to: containerView),
                                size: logoIcon.bounds.size)
            fakeLogoText.frame = CGRect(origin: logoText.superview!.convert(logoText.frame.origin,
                                                                            to: containerView),
                                        size: logoText.bounds.size)
          }) { _ in
            logoText.alpha = 1
            logoIcon.alpha = 1
            opaque.removeFromSuperview()
          }
      } else if let fromView = fromVC.view as? SignInView,
                let toView = toVC.view as? NewAccountView,
                let logosStack = fromView.logos.getSubview(type: UIStackView.self, identifier: "stack")  {
        
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        toView.alpha = 1
        toView.loginButton.alpha = 0
        fromView.alpha = 1
        
        let padding: CGFloat = 8
        let fakeLogoIcon: Icon = {
          let instance = Icon()
          instance.frame = CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                               to: containerView),
                                  size: fromView.logoIcon.bounds.size)
          fromView.logoIcon.alpha = 0
          instance.iconColor = Colors.main
          instance.scaleMultiplicator = 1
          instance.category = .Logo
          
          return instance
        }()
        let fakeLogoText: Icon = {
          let instance = Icon()
          instance.frame = CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                               to: containerView),
                                  size: fromView.logoText.bounds.size)
          fromView.logoIcon.alpha = 0
          instance.iconColor = Colors.main
          instance.scaleMultiplicator = 1
          instance.category = .LogoText
          
          return instance
        }()
        let fakeLogoIconDestination = toView.logoIcon.superview!.convert(toView.logoIcon.frame.origin,
                                                                   to: containerView)
        let fakeLogoTextDestination = toView.logoText.superview!.convert(toView.logoText.frame.origin,
                                                                   to: containerView)
        
        fromView.logoIcon.alpha = 0
        fromView.logoText.alpha = 0
        toView.logoIcon.alpha = 0
        toView.logoText.alpha = 0
        containerView.addSubview(fakeLogoIcon)
        containerView.addSubview(fakeLogoText)
        
//        let fakeButton: UIButton = {
//          let instance = UIButton()
//          if #available(iOS 15, *) {
//            var config = UIButton.Configuration.filled()
//            config.cornerStyle = .small
//            config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
//            config.baseBackgroundColor = Colors.main
//            config.contentInsets.top = padding
//            config.contentInsets.bottom = padding
//            config.contentInsets.leading = 20
//            config.contentInsets.trailing = 20
//            config.attributedTitle = AttributedString("loginButton".localized.uppercased(),
//                                                      attributes: AttributeContainer([
//                                                        .font: UIFont(name: Fonts.Bold, size: 20) as Any,
//                                                        .foregroundColor: UIColor.white as Any
//                                                      ]))
//            instance.configuration = config
//          } else {
//            instance.backgroundColor = Colors.main
//            instance.cornerRadius = fromView.loginButton.cornerRadius
//            instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
//                                                           attributes: [
//                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
//                                                            .foregroundColor: UIColor.white as Any
//                                                           ]),
//                                        for: .normal)
//          }
//
//          return instance
//        }()
        let fakeButtonLabel: UILabel = {
          let instance = UILabel()
          instance.font = UIFont(name: Fonts.Bold, size: 20)
          instance.textColor = .white
          instance.text = "loginButton".localized.uppercased()
//          fakeButtonLabel.attributedText = NSAttributedString(string: "loginButton".localized.uppercased(),
//                                                    attributes: [
//                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
//                                                      .foregroundColor: UIColor.white as Any
//                                                    ])
          return instance
        }()
        let fakeButton: UIView = {
          let instance = UIView()
          instance.backgroundColor = Colors.main
          instance.cornerRadius = 6//fromView.loginButton.cornerRadius
          //            instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
          //                                                           attributes: [
          //                                                            .font: UIFont(name: Fonts.Bold, size: 20) as Any,
          //                                                            .foregroundColor: UIColor.white as Any
          //                                                           ]),
          //                                        for: .normal)
//          let label = UILabel()
//          label.attributedText = NSAttributedString(string: "loginButton".localized.uppercased(),
//                                                    attributes: [
//                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
//                                                      .foregroundColor: UIColor.white as Any
//                                                    ])
          fakeButtonLabel.placeInCenter(of: instance)

          return instance
        }()
        let fakeButtonCoordinate = toView.loginButton.superview!.convert(toView.loginButton.frame.origin,
                                                                         to: containerView)
        fakeButton.frame = CGRect(origin: fromView.loginButton.superview!.convert(fromView.loginButton.frame.origin,
                                                                                  to: containerView),
                                  size: fromView.loginButton.bounds.size)
        containerView.addSubview(fakeButton)
        UIView.transition(with: fakeButtonLabel,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
          fakeButton.frame.size = toView.loginButton.frame.size
          fakeButtonLabel.text = "signupButton".localized.uppercased()
//          fakeButtonLabel.attributedText = NSAttributedString(string: "signupButton".localized.uppercased(),
//                                                              attributes: [
//                                                                .font: UIFont(name: Fonts.Bold, size: 20) as Any,
//                                                                .foregroundColor: UIColor.white as Any
//                                                              ])
        })
        
        
        
        let signupButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "signupButton".localized,
                                                         attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)
          
          return instance
        }()
        var signupButtonDestination = fromView.signupButton.superview!.convert(fromView.signupButton.frame.origin,
                                                                               to: containerView)
        signupButtonDestination.x = -(containerView.bounds.width + signupButton.frame.width)
        signupButton.frame = CGRect(origin: fromView.signupButton.superview!.convert(fromView.signupButton.frame.origin,
                                                                                     to: containerView),
                                    size: fromView.signupButton.bounds.size)
        
        fromView.signupButton.alpha = 0
        containerView.addSubview(signupButton)

        
        
        let forgotButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                         attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .headline) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)
          
          return instance
        }()
        var forgotButtonDestination = fromView.forgotButton.superview!.convert(fromView.forgotButton.frame.origin,
                                                                               to: containerView)
        forgotButtonDestination.x = containerView.bounds.width
        forgotButton.frame = CGRect(origin: fromView.forgotButton.superview!.convert(fromView.forgotButton.frame.origin,
                                                                                     to: containerView),
                                    size: fromView.forgotButton.bounds.size)
        //        forgotButton.frame.origin.x = containerView.bounds.width
        containerView.addSubview(forgotButton)
        fromView.forgotButton.alpha = 0
        
        
        
        let mailContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "mailTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        let mailDestination = toView.mailContainer.superview!.convert(toView.mailContainer.frame.origin,
                                                                      to: containerView)
        mailContainer.frame = CGRect(origin: fromView.loginContainer.superview!.convert(fromView.loginContainer.frame.origin,
                                                                                        to: containerView),
                                     size: fromView.loginContainer.bounds.size)
        mailContainer.cornerRadius = fromView.passwordContainer.bounds.width * 0.025
        containerView.addSubview(mailContainer)
        toView.mailContainer.alpha = 0
        
        
        
        
        let loginContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        let loginDestination = toView.loginContainer.superview!.convert(toView.loginContainer.frame.origin,
                                                                        to: containerView)
        loginContainer.frame = CGRect(origin: fromView.loginContainer.superview!.convert(fromView.loginContainer.frame.origin,
                                                                                         to: containerView),
                                      size: fromView.loginContainer.bounds.size)
        loginContainer.cornerRadius = loginContainer.bounds.width * 0.025
        containerView.addSubview(loginContainer)
        fromView.loginContainer.alpha = 0
        toView.loginContainer.alpha = 0
        
        
        
        let passwordContainer: UIStackView = {
          let loginTextField: UnderlinedSignTextField = {
            let instance = UnderlinedSignTextField()
            instance.backgroundColor = .clear
            instance.tintColor = Colors.main
            instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
            instance.clipsToBounds = false
            instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                                attributes: [
                                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                ])
            return instance
          }()
          
          let instance = UIStackView(arrangedSubviews: [
            UIView.horizontalSpacer(padding),
            loginTextField,
            UIView.horizontalSpacer(padding)
          ])
          instance.axis = .horizontal
          instance.spacing = 0
          instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
          
          return instance
        }()
        let passwordDestination = toView.passwordContainer.superview!.convert(toView.passwordContainer.frame.origin,
                                                                              to: containerView)
        passwordContainer.frame = CGRect(origin: fromView.passwordContainer.superview!.convert(fromView.passwordContainer.frame.origin,
                                                                                               to: containerView),
                                         size: fromView.passwordContainer.bounds.size)
        passwordContainer.cornerRadius = passwordContainer.bounds.width * 0.025
        containerView.addSubview(passwordContainer)
        fromView.passwordContainer.alpha = 0
        toView.passwordContainer.alpha = 0
        
        
        let orLabel: UILabel = {
          let instance = UILabel()
          instance.numberOfLines = 0
          instance.textAlignment = .center
          instance.text = "providerLabel".localized
          instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
          
          return instance
        }()
        var orLabelDestination = fromView.label.superview!.convert(fromView.label.frame.origin,
                                                                   to: containerView)
        orLabelDestination.x = containerView.bounds.height
        orLabel.frame = CGRect(origin: fromView.label.superview!.convert(fromView.label.frame.origin,
                                                                         to: containerView),
                               size: fromView.label.bounds.size)
        containerView.addSubview(orLabel)
        fromView.label.alpha = 0
        
        
        var logosDestination = fromView.logos.superview!.convert(fromView.logos.frame.origin,
                                                                 to: containerView)
        logosDestination.x = containerView.bounds.height
        let logos: UIView = {
          let stack = UIStackView(arrangedSubviews: logosStack.arrangedSubviews.map {
            let instance = $0.copyView()!
            instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
            
            return instance
          })
          stack.axis = .horizontal
          let instance = UIView.opaque()
          stack.placeInCenter(of: instance,
                              topInset: 0,
                              bottomInset: 0)
          
          return instance
        }()
        logos.frame = CGRect(origin: fromView.logos.superview!.convert(fromView.logos.frame.origin,
                                                                       to: containerView),
                             size: fromView.logos.bounds.size)
        containerView.addSubview(logos)
        fromView.logos.alpha = 0
        
        
        
        
        ///Animate coordinates and alpha
        let views: [[UIView: [UIView: CGPoint]]] = [
          [fakeLogoIcon: [toView.logoIcon: fakeLogoIconDestination]],
          [fakeLogoText: [toView.logoText: fakeLogoTextDestination]],
          [loginContainer: [toView.loginContainer: loginDestination]],
          [mailContainer: [toView.mailContainer: mailDestination]],
          [passwordContainer: [toView.passwordContainer: passwordDestination]],
          [fakeButton: [toView.loginButton: fakeButtonCoordinate]],
          [orLabel: [UIView(): orLabelDestination]],
          [logos: [UIView(): logosDestination]],
          [signupButton: [UIView(): signupButtonDestination]],
          [forgotButton: [UIView(): forgotButtonDestination]],
        ]
          
//          UIView.animate(withDuration: 0.3,
//                         delay: 0.6,
//                         options: .curveEaseOut,
//                         animations: {
//            acceptButton.frame.origin = toView.acceptButton.superview!.convert(toView.acceptButton.frame.origin,
//                                                                    to: containerView)
//            toView.webView.alpha = 1
//          }) { _ in
//            toView.acceptButton.alpha = 1
//            acceptButton.removeFromSuperview()
//          }
          
          views.enumerated().forEach { index, dict in
            guard let view = dict.keys.first,
                  let nested = dict.values.first,
                  let destinationView = nested.keys.first,
                  let destinationCoordinate = nested.values.first
            else { return }

            UIView.animate(
              withDuration: 0.6,
              delay: 0,//.01 * Double(index),
              usingSpringWithDamping: 0.8,
              initialSpringVelocity: 0.2,
              options: [.curveEaseInOut],
              animations: {
                view.frame.origin = destinationCoordinate
              }) {  _ in
                destinationView.alpha = 1
                view.removeFromSuperview()

                guard index == views.count - 1 else { return }

                fromView.stack.arrangedSubviews.forEach { v in v.alpha = 1; v.subviews.forEach { $0.alpha = 1 } }
                self.context?.completeTransition(true)
                
//                fromView.forgotButton.alpha = 1
//                fromView.signupButton.alpha = 1
//                fromView.logoIcon.alpha = 1
//                fromView.loginContainer.alpha = 1
//                fromView.passwordContainer.alpha = 1
              }
          }
          
//          UIView.animate(
//            withDuration: 0.6,
//            delay: 0,
//            usingSpringWithDamping: 0.7,
//            initialSpringVelocity: 0.3,
//            options: [.curveEaseInOut],
//            animations: {
//              logo.frame = CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
//                                                                      to: containerView),
//                                  size: logoIcon.bounds.size)
//              fakeLogoText.frame = CGRect(origin: logoText.superview!.convert(logoText.frame.origin,
//                                                                              to: containerView),
//                                          size: logoText.bounds.size)
//            }) { _ in
//              logoText.alpha = 1
//              logoIcon.alpha = 1
        //              opaque.removeFromSuperview()
        //            }
      } else if let fromView = fromVC.view as? NewAccountView,
                let toView = toVC.view as? TermsView,
                let titleView = toVC.navigationController?.navigationBar.subviews.filter({ $0 is UIStackView }).first as? UIStackView,
                let logoIcon = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoIcon" }).first as? Icon,
                let logoText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "logoText" }).first as? Icon {
        
        let opaque = UIView.opaque()
        opaque.place(inside: appDelegate.window!)
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        toVC.navigationController?.navigationBar.setNeedsLayout()
        toVC.navigationController?.navigationBar.layoutIfNeeded()
//        toView.alpha = 1
        toView.acceptButton.alpha = 0
        toView.webView.alpha = 0
        
        let padding: CGFloat = 8
        let logo: Icon = {
          let instance = Icon()
          instance.frame = CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                               to: containerView),
                                  size: fromView.logoIcon.bounds.size)
          fromView.logoIcon.alpha = 0
          logoIcon.alpha = 0
          instance.iconColor = Colors.main
          instance.scaleMultiplicator = 1
          instance.category = .Logo
          
          return instance
        }()
        let fakeLogoText: Icon = {
             let instance = Icon()
             instance.frame = CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                                  to: containerView),
                                     size: fromView.logoText.bounds.size)
             fromView.logoIcon.alpha = 0
             logoText.alpha = 0
             instance.iconColor = Colors.main
             instance.scaleMultiplicator = 1
             instance.category = .LogoText
             
             return instance
           }()
           
           opaque.addSubview(logo)
           opaque.addSubview(fakeLogoText)
           
           logo.icon.add(Animations.get(property: .Path,
                                        fromValue: (logo.icon as! CAShapeLayer).path as Any,
                                        toValue: (logoIcon.icon as! CAShapeLayer).path as Any,
                                        duration: 0.3,
                                        delay: 0,
                                        repeatCount: 0,
                                        autoreverses: false,
                                        timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                        delegate: nil,
                                        isRemovedOnCompletion: false),
                         forKey: nil)
           fakeLogoText.icon.add(Animations.get(property: .Path,
                                                fromValue: (fakeLogoText.icon as! CAShapeLayer).path as Any,
                                                toValue: (logoText.icon as! CAShapeLayer).path as Any,
                                                duration: 0.3,
                                                delay: 0,
                                                repeatCount: 0,
                                                autoreverses: false,
                                                timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                delegate: nil,
                                                isRemovedOnCompletion: false),
                                 forKey: nil)
           
           
           
           let loginButton: UIButton = {
             let instance = UIButton()
             if #available(iOS 15, *) {
               var config = UIButton.Configuration.filled()
               config.cornerStyle = .small
               config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
               config.baseBackgroundColor = Colors.main
               config.contentInsets.top = padding
               config.contentInsets.bottom = padding
               config.contentInsets.leading = 20
               config.contentInsets.trailing = 20
               config.attributedTitle = AttributedString("loginButton".localized.uppercased(),
                                                         attributes: AttributeContainer([
                                                           .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                           .foregroundColor: UIColor.white as Any
                                                         ]))
               instance.configuration = config
             } else {
               instance.backgroundColor = Colors.main
               instance.cornerRadius = fromView.loginButton.cornerRadius
               instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized.uppercased(),
                                                              attributes: [
                                                               .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                               .foregroundColor: UIColor.white as Any
                                                              ]),
                                           for: .normal)
             }
             
             return instance
           }()
           var loginButtonCoordinate = fromView.loginButton.superview!.convert(fromView.loginButton.frame.origin,
                                                                    to: containerView)
           //        buttonCoordinate.y = containerView.bounds.height
           loginButton.frame = CGRect(origin: loginButtonCoordinate,
                                       size: fromView.loginButton.bounds.size)
           containerView.addSubview(loginButton)
           loginButtonCoordinate.x = containerView.bounds.height
           
           let loginContainer: UIStackView = {
             let loginTextField: UnderlinedSignTextField = {
               let instance = UnderlinedSignTextField()
               instance.backgroundColor = .clear
               instance.tintColor = Colors.main
               instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
               instance.clipsToBounds = false
               instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                                   attributes: [
                                                                     .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                   ])
               return instance
             }()
             
             let instance = UIStackView(arrangedSubviews: [
               UIView.horizontalSpacer(padding),
               loginTextField,
               UIView.horizontalSpacer(padding)
             ])
             instance.axis = .horizontal
             instance.spacing = 0
             instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
             
             return instance
           }()
           var loginDestination = fromView.loginContainer.superview!.convert(fromView.loginContainer.frame.origin,
                                                                             to: containerView)
           loginContainer.frame = CGRect(origin: loginDestination,
                                         size: fromView.loginContainer.bounds.size)
           loginContainer.cornerRadius = loginContainer.bounds.width * 0.025
           containerView.addSubview(loginContainer)
           fromView.loginContainer.alpha = 0
           loginDestination.x = -(containerView.bounds.width + loginContainer.frame.width)
           
          
          let mailContainer: UIStackView = {
            let loginTextField: UnderlinedSignTextField = {
              let instance = UnderlinedSignTextField()
              instance.backgroundColor = .clear
              instance.tintColor = Colors.main
              instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
              instance.clipsToBounds = false
              instance.attributedPlaceholder = NSAttributedString(string: "usernameTF".localized,
                                                                  attributes: [
                                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                  ])
              return instance
            }()
            
            let instance = UIStackView(arrangedSubviews: [
              UIView.horizontalSpacer(padding),
              loginTextField,
              UIView.horizontalSpacer(padding)
            ])
            instance.axis = .horizontal
            instance.spacing = 0
            instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
            
            return instance
          }()
          var mailDestination = fromView.mailContainer.superview!.convert(fromView.mailContainer.frame.origin,
                                                                            to: containerView)
          mailContainer.frame = CGRect(origin: mailDestination,
                                        size: fromView.mailContainer.bounds.size)
          mailContainer.cornerRadius = mailContainer.bounds.width * 0.025
          containerView.addSubview(mailContainer)
          fromView.mailContainer.alpha = 0
          mailDestination.x = containerView.bounds.width
          
          
           let passwordContainer: UIStackView = {
             let loginTextField: UnderlinedSignTextField = {
               let instance = UnderlinedSignTextField()
               instance.backgroundColor = .clear
               instance.tintColor = Colors.main
               instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
               instance.clipsToBounds = false
               instance.attributedPlaceholder = NSAttributedString(string: "passwordTF".localized,
                                                                   attributes: [
                                                                     .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any
                                                                   ])
               return instance
             }()
             
             let instance = UIStackView(arrangedSubviews: [
               UIView.horizontalSpacer(padding),
               loginTextField,
               UIView.horizontalSpacer(padding)
             ])
             instance.axis = .horizontal
             instance.spacing = 0
             instance.backgroundColor = (toView.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground)
             
             return instance
           }()
           var passwordDestination = fromView.passwordContainer.superview!.convert(fromView.passwordContainer.frame.origin,
                                                                                   to: containerView)
           passwordContainer.frame = CGRect(origin: passwordDestination,
                                            size: fromView.passwordContainer.bounds.size)
           passwordContainer.cornerRadius = passwordContainer.bounds.width * 0.025
           containerView.addSubview(passwordContainer)
           fromView.passwordContainer.alpha = 0
           passwordDestination.x = -(containerView.bounds.width + loginContainer.frame.width)
           
           ///Animate coordinates
           let views: [[UIView: CGPoint]] = [
             [loginContainer: loginDestination],
             [mailContainer: mailDestination],
             [passwordContainer: passwordDestination],
             [loginButton: loginButtonCoordinate],
           ]
           
           let acceptButton: UIButton = {
             let instance = UIButton()
             if #available(iOS 15, *) {
               var config = UIButton.Configuration.filled()
               config.cornerStyle = .small
               config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
               config.baseBackgroundColor = UIColor.systemGray
               config.contentInsets.top = padding
               config.contentInsets.bottom = padding
               config.contentInsets.leading = 20
               config.contentInsets.trailing = 20
               config.attributedTitle = AttributedString("acceptButton".localized.uppercased(),
                                                         attributes: AttributeContainer([
                                                           .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                           .foregroundColor: UIColor.white as Any
                                                         ]))
               instance.configuration = config
             } else {
               instance.cornerRadius = toView.acceptButton.cornerRadius
               instance.setAttributedTitle(NSAttributedString(string: "acceptButton".localized.uppercased(),
                                                              attributes: [
                                                               .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                               .foregroundColor: UIColor.white as Any
                                                              ]),
                                           for: .normal)
             }
             
             return instance
           }()
           let acceptButtonCoordinate = toView.acceptButton.convert(CGPoint(x: loginButtonCoordinate.x,
                                                                            y: containerView.bounds.height),
                                                                    to: containerView)
           acceptButton.frame = CGRect(origin: acceptButtonCoordinate,
                                       size: toView.acceptButton.bounds.size)
           containerView.addSubview(acceptButton)
           acceptButton.center.x = containerView.bounds.midX
           
           
           UIView.animate(withDuration: 0.3,
                          delay: 0.6,
                          options: .curveEaseOut,
                          animations: {
             acceptButton.frame.origin = toView.acceptButton.superview!.convert(toView.acceptButton.frame.origin,
                                                                     to: containerView)
             toView.webView.alpha = 1
           }) { _ in
             toView.acceptButton.alpha = 1
             acceptButton.removeFromSuperview()
           }
           
           views.enumerated().forEach { index, dict in
             guard let coordinate = dict.values.first,
                   let view = dict.keys.first
             else { return }
             
             UIView.animate(
               withDuration: 0.3,
               delay: 0.05*Double(index),
//               usingSpringWithDamping: 0.8,
//               initialSpringVelocity: 0.3,
               options: [.curveEaseInOut],
               animations: {
                 view.frame.origin = coordinate
               }) {  _ in
                 view.removeFromSuperview()
                 
                 guard index == views.count - 1 else { return }
                 
                 self.context?.completeTransition(true)
                 fromView.loginButton.alpha = 1
                 fromView.logoIcon.alpha = 1
                 fromView.loginContainer.alpha = 1
                 fromView.passwordContainer.alpha = 1
                 fromView.mailContainer.alpha = 1
               }
           }
           
           titleView.convert(logoIcon.frame.origin, to: containerView)
           UIView.animate(
             withDuration: 0.6,
             delay: 0,
             usingSpringWithDamping: 0.7,
             initialSpringVelocity: 0.3,
             options: [.curveEaseInOut],
             animations: {
               logo.frame = CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
                                                                       to: containerView),
                                   size: logoIcon.bounds.size)
               fakeLogoText.frame = CGRect(origin: logoText.superview!.convert(logoText.frame.origin,
                                                                               to: containerView),
                                           size: logoText.bounds.size)
             }) { _ in
               logoText.alpha = 1
               logoIcon.alpha = 1
               opaque.removeFromSuperview()
             }
        } else { self.context?.completeTransition(true) }
    }
  }
}
