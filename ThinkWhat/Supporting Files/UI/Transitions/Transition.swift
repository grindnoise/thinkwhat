//
//  Transitions.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import AuthenticationServices
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
        
        let fakeAction = try! card.voteButton.copyObject() as! UIButton
        fakeAction.layer.zPosition = 100
        let fakeActionOrigin = card.voteButton.superview!.convert(card.voteButton.frame.origin,
                                                                  to: containerView)
        fakeAction.placeTopLeading(inside: appDelegate.window!,
                                   leadingInset: fakeActionOrigin.x,
                                   topInset: fakeActionOrigin.y,
                                   width: fakeAction.frame.width,
                                   height: fakeAction.frame.height)
        let fakeClaim = try! card.claimButton.copyObject() as! UIButton
        fakeClaim.layer.zPosition = 100
        let fakeClaimOrigin = card.claimButton.superview!.convert(card.claimButton.frame.origin, to: appDelegate.window!)
        fakeClaim.placeTopLeading(inside: appDelegate.window!,
                                  leadingInset: fakeClaimOrigin.x,
                                  topInset: fakeClaimOrigin.y,
                                  width: fakeClaim.frame.width,
                                  height: fakeClaim.frame.height)
        
        let fakeNext = try! card.nextButton.copyObject() as! UIButton
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
        toView.alpha = 0
        let padding: CGFloat = 8
        let logo  = Logo(frame: CGRect(origin: fromView.logo.superview!.convert(fromView.logo.frame.origin,
                                                                                to: containerView),
                                       size: fromView.logo.bounds.size))
        logo.removeConstraints(logo.getAllConstraints())
        containerView.addSubview(logo)
        fromView.logo.alpha = 0
        toView.logoIcon.alpha = 0

        let logoText = LogoText(frame: CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                                   to: containerView),
                                          size: fromView.logoText.bounds.size))
        logoText.removeConstraints(logoText.getAllConstraints())
        containerView.addSubview(logoText)
        fromView.logoText.alpha = 0
        toView.logoText.alpha = 0

        let button: UIButton = {
          let instance = UIButton()
          if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .capsule
            config.baseBackgroundColor = Colors.main
            config.attributedTitle = AttributedString("getStartedButton".localized.capitalized,
                                                      attributes: AttributeContainer([
                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                        .foregroundColor: UIColor.white as Any
                                                      ]))
            instance.configuration = config
          } else {
            instance.cornerRadius = fromView.button.cornerRadius
            instance.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.capitalized,
                                                           attributes: [
                                                            .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                            .foregroundColor: UIColor.white as Any
                                                           ]),
                                        for: .normal)
          }
          instance.layer.shadowOpacity = 1
          instance.layer.shadowColor = navigationController.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
          instance.layer.shadowRadius = navigationController.traitCollection.userInterfaceStyle == .dark ? 8 : 4
          instance.layer.shadowOffset = navigationController.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
          
          return instance
        }()
        button.frame = CGRect(origin: fromView.convert(fromView.button.frame.origin,
                                                       to: containerView),
                              size: fromView.button.bounds.size)
        containerView.addSubview(button)
        fromView.button.alpha = 0
        toView.loginButton.alpha = 0
        toView.loginButton.transform = .init(scaleX: 0.5, y: 0.5)
        
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
        
        let separator = try! toView.separator.copyObject() as! UIStackView
        separator.arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = true }
        let separatorDestination = toView.separator.superview!.convert(toView.separator.frame.origin,
                                                                                     to: containerView)
        separator.translatesAutoresizingMaskIntoConstraints = true
        separator.frame.origin = toView.separator.superview!.convert(toView.separator.frame.origin,
                                                                       to: containerView)
        separator.frame.origin.y = containerView.bounds.height
        containerView.addSubview(separator)
        toView.separator.alpha = 0
       
        let apple = ASAuthorizationAppleIDButton(type: .signIn, style: navigationController.traitCollection.userInterfaceStyle == .dark ? .white : .black)
        let appleDestination = toView.apple.superview!.convert(toView.apple.frame.origin,
                                                                             to: containerView)
        apple.frame.origin = appleDestination
        apple.frame.origin.y = containerView.bounds.height
        apple.frame.size = toView.apple.frame.size
        (apple as UIControl).cornerRadius = apple.bounds.height/2
        containerView.addSubview(apple)
        toView.apple.alpha = 0
        
        let signupStack = try! toView.signupStack.copyObject() as! UIStackView
        signupStack.arrangedSubviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = true }
        let signupStackDestination = toView.signupStack.superview!.convert(toView.signupStack.frame.origin,
                                                                                     to: containerView)
        signupStack.translatesAutoresizingMaskIntoConstraints = true
        signupStack.frame.origin = toView.signupStack.superview!.convert(toView.signupStack.frame.origin,
                                                                       to: containerView)
        signupStack.frame.origin.y = containerView.bounds.height
        containerView.addSubview(signupStack)
        toView.signupStack.alpha = 0
        let forgotButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                         attributes: [
                                                          .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
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
          [toView.apple: [apple: appleDestination]],
          [toView.separator: [separator: separatorDestination]],
          //          [toView.label: [orLabel: orLabelDestination]],
          //          [toView.signupButton: [signupButton: signupButtonDestination]],
          [toView.signupStack: [signupStack: signupStackDestination]],
          [toView.forgotButton: [forgotButton: forgotButtonDestination]],
        ]
        
        if let stack = toView.logos.getSubview(type: UIStackView.self) {
          stack.arrangedSubviews.forEach {
            $0.transform = .init(scaleX: 0.75, y: 0.75)
            $0.alpha = 0
          }
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
          button.frame.origin.y = containerView.bounds.height
          fromView.spiral.startRotating(duration: 0.05, repeatCount: 1, clockwise: false)
          fromView.spiral.transform = .init(scaleX: 1.5, y: 1.5)
          fromView.spiral.alpha = 0
          toView.alpha = 1
        }) { _ in
          button.removeFromSuperview()
          fromView.spiral.stopRotating()
          
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
              }) {  _ in
                destination.alpha = 1
                view.removeFromSuperview()

                guard index == views.count - 1 else { return }
                
                self.context?.completeTransition(true)
              }
          }
        }
        
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
                let logoIcon = titleView.arrangedSubviews.filter({ $0 is Logo }).first as? Logo,
                let logoText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "opaque" }).first?.subviews.filter({ $0 is LogoText }).first as? LogoText,
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
        let fakeLogoIcon  = Logo(frame: CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                                to: containerView),
                                       size: fromView.logoIcon.bounds.size))
        fakeLogoIcon.removeConstraints(fakeLogoIcon.getAllConstraints())
        opaque.addSubview(fakeLogoIcon)
        fromView.logoIcon.alpha = 0
        logoIcon.alpha = 0

        
        let fakeLogoText = LogoText(frame: CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                                   to: containerView),
                                          size: fromView.logoText.bounds.size))
        fakeLogoText.removeConstraints(fakeLogoText.getAllConstraints())
        opaque.addSubview(fakeLogoText)
        fromView.logoText.alpha = 0
        logoText.alpha = 0
        
//        let fakeLogoIconDestination = logoIcon.superview!.convert(logoIcon.frame.origin,
//                                                                   to: containerView)
//        let fakeLogoTextDestination = logoText.superview!.convert(logoText.frame.origin,
//                                                                   to: containerView)

        let loginButton: UIView = {
          let opaque = UIView.opaque()
          opaque.layer.masksToBounds = false
          
          let instance = UIButton()
          if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .capsule
            config.baseBackgroundColor = Colors.main
            config.attributedTitle = AttributedString("loginButton".localized,
                                                      attributes: AttributeContainer([
                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                        .foregroundColor: UIColor.white as Any
                                                      ]))
            instance.configuration = config
          } else {
            instance.backgroundColor = Colors.main
            instance.cornerRadius = fromView.loginButton.cornerRadius
            instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized,
                                                           attributes: [
                                                            .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                            .foregroundColor: UIColor.white as Any
                                                           ]),
                                        for: .normal)
            instance.place(inside: opaque)
          }
          instance.place(inside: opaque)
          
          return opaque
        }()
        var loginButtonCoordinate = fromView.loginButton.superview!.convert(fromView.loginButton.frame.origin,
                                                                 to: containerView)
        loginButton.frame = CGRect(origin: loginButtonCoordinate,
                                    size: fromView.loginButton.bounds.size)
        containerView.addSubview(loginButton)
        
        // Draw shadow
        loginButton.layer.shadowOpacity = 1
        loginButton.layer.shadowPath = UIBezierPath(roundedRect: loginButton.bounds, cornerRadius: loginButton.bounds.height/2).cgPath
        loginButton.layer.shadowColor = navigationController.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        loginButton.layer.shadowRadius = navigationController.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        loginButton.layer.shadowOffset = navigationController.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
        loginButtonCoordinate.y = containerView.bounds.height
        
        let apple = ASAuthorizationAppleIDButton(type: .signIn, style: navigationController.traitCollection.userInterfaceStyle == .dark ? .white : .black)
        var appleDestination = fromView.apple.superview!.convert(fromView.apple.frame.origin,
                                                                             to: containerView)
        apple.frame.origin = appleDestination
        appleDestination.x = -(containerView.bounds.width + apple.frame.width)
        apple.frame.size = fromView.apple.frame.size
        containerView.addSubview(apple)
        fromView.apple.alpha = 0

        let forgotButton: UIButton = {
          let instance = UIButton()
          instance.setAttributedTitle(NSAttributedString(string: "forgotLabel".localized,
                                                         attributes: [
                                                          .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                          .foregroundColor: Colors.main as Any
                                                         ]),
                                      for: .normal)

          return instance
        }()
        let forgotButtonDestination = fromView.forgotButton.superview!.convert(fromView.forgotButton.frame.origin,
                                                                               to: containerView)
        forgotButton.frame = CGRect(origin: forgotButtonDestination,
                                    size: fromView.forgotButton.bounds.size)
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
        orLabelDestination.x = containerView.bounds.width
        
        var logosDestination = fromView.logos.superview!.convert(fromView.logos.frame.origin,
                                                                 to: containerView)
        let logos: UIView = {
          let stack = UIStackView(arrangedSubviews: logosStack.arrangedSubviews.map {
            let instance = try! $0.copyObject() as! UIView
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
        logosDestination.x = containerView.bounds.width
        
        ///Animate coordinates
        let views: [[UIView: CGPoint]] = [
          [loginContainer: loginDestination],
          [passwordContainer: passwordDestination],
          [apple: appleDestination],
          [loginButton: loginButtonCoordinate],
          [orLabel: orLabelDestination],
          [logos: logosDestination],
//          [signupButton: signupButtonDestination],
          [forgotButton: forgotButtonDestination],
        ]
        
        let fakeButtonLabel: UILabel = {
          let instance = UILabel()
          instance.font = UIFont(name: Fonts.Rubik.SemiBold, size: 14)
          instance.textColor = .white
          instance.text = "acceptButton".localized

          return instance
        }()
        let fakeButton: UIView = {
          let opaque = UIView()
          opaque.backgroundColor = .clear
          opaque.layer.masksToBounds = false
          opaque.clipsToBounds = false
          
          let instance = UIView()
          instance.backgroundColor = Colors.main
          instance.cornerRadius = fromView.loginButton.frame.height/2
          fakeButtonLabel.placeInCenter(of: instance)
          instance.place(inside: opaque)

          return opaque
        }()

        fakeButton.frame = CGRect(origin: fromView.loginButton.superview!.convert(fromView.loginButton.frame.origin,
                                                                                  to: containerView),
                                  size: fromView.loginButton.bounds.size)
        containerView.addSubview(fakeButton)
        
        // Draw shadow
        fakeButton.layer.shadowOpacity = 1
        fakeButton.layer.shadowPath = UIBezierPath(roundedRect: fakeButton.bounds, cornerRadius: fakeButton.bounds.height/2).cgPath
        fakeButton.layer.shadowColor = navigationController.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        fakeButton.layer.shadowRadius = navigationController.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        fakeButton.layer.shadowOffset = navigationController.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
        
        fakeButton.frame.origin.y = containerView.bounds.height
        
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.6,
                       options: .curveEaseOut,
                       animations: {
          fakeButton.frame.origin = toView.acceptButton.superview!.convert(toView.acceptButton.frame.origin,
                                                                  to: containerView)
          toView.webView.alpha = 1
        }) { _ in
          toView.acceptButton.alpha = 1
          fakeButton.removeFromSuperview()
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
              fromView.logoText.alpha = 1
              fromView.loginContainer.alpha = 1
              fromView.passwordContainer.alpha = 1
              fromView.label.alpha = 1
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
            fakeLogoIcon.frame = CGRect(origin: logoIcon.superview!.convert(logoIcon.frame.origin,
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
                let toView = toVC.view as? ProfileCreationView,
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
        toView.userSettingsView.alpha = 0
        toView.alpha = 1
        
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
        logoText.alpha = 0
        logoIcon.alpha = 0
        
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
        let apple = ASAuthorizationAppleIDButton(type: .signIn, style: navigationController.traitCollection.userInterfaceStyle == .dark ? .white : .black)
        var appleDestination = fromView.apple.superview!.convert(fromView.apple.frame.origin,
                                                                             to: containerView)
        apple.frame.origin = appleDestination
        appleDestination.x = -(containerView.bounds.width + apple.frame.width)
        apple.frame.size = fromView.apple.frame.size
        containerView.addSubview(apple)
        fromView.apple.alpha = 0

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
            let instance = try! $0.copyObject() as! UIView
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
          [apple: appleDestination],
          [orLabel: orLabelDestination],
          [logos: logosDestination],
          [signupButton: signupButtonDestination],
          [forgotButton: forgotButtonDestination],
        ]
        
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
              
              UIView.animate(withDuration: 0.3, animations: {
                toView.userSettingsView.alpha = 1
              }) { [weak self] _ in
                guard let self = self else { return }
                
                self.context?.completeTransition(true)
                fromView.forgotButton.alpha = 1
                fromView.signupButton.alpha = 1
                fromView.logoIcon.alpha = 1
                fromView.loginContainer.alpha = 1
                fromView.passwordContainer.alpha = 1
              }
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
//        let fakeLogoIcon: Icon = {
//          let instance = Icon()
//          instance.frame = CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
//                                                                               to: containerView),
//                                  size: fromView.logoIcon.bounds.size)
//          fromView.logoIcon.alpha = 0
//          instance.iconColor = Colors.main
//          instance.scaleMultiplicator = 1
//          instance.category = .Logo
//
//          return instance
//        }()
//        let fakeLogoText: Icon = {
//          let instance = Icon()
//          instance.frame = CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
//                                                                               to: containerView),
//                                  size: fromView.logoText.bounds.size)
//          fromView.logoIcon.alpha = 0
//          instance.iconColor = Colors.main
//          instance.scaleMultiplicator = 1
//          instance.category = .LogoText
//
//          return instance
//        }()
        let fakeLogoIcon  = Logo(frame: CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                                to: containerView),
                                       size: fromView.logoIcon.bounds.size))
        fakeLogoIcon.removeConstraints(fakeLogoIcon.getAllConstraints())
        containerView.addSubview(fakeLogoIcon)
        fromView.logoIcon.alpha = 0
        toView.logoIcon.alpha = 0

        
        let fakeLogoText = LogoText(frame: CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                                   to: containerView),
                                          size: fromView.logoText.bounds.size))
        fakeLogoText.removeConstraints(fakeLogoText.getAllConstraints())
        containerView.addSubview(fakeLogoText)
        fromView.logoText.alpha = 0
        toView.logoText.alpha = 0
        
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
       
        let fakeButtonLabel: UILabel = {
          let instance = UILabel()
          instance.font = UIFont(name: Fonts.Rubik.SemiBold, size: 14)
          instance.textColor = .white
          instance.text = "loginButton".localized
//          fakeButtonLabel.attributedText = NSAttributedString(string: "loginButton".localized.uppercased(),
//                                                    attributes: [
//                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
//                                                      .foregroundColor: UIColor.white as Any
//                                                    ])
          return instance
        }()
        let fakeButton: UIView = {
          let opaque = UIView()
          opaque.backgroundColor = .clear
          opaque.layer.masksToBounds = false
          opaque.clipsToBounds = false
          
          let instance = UIView()
          instance.backgroundColor = Colors.main
          instance.cornerRadius = fromView.loginButton.frame.height/2
          fakeButtonLabel.placeInCenter(of: instance)
          instance.place(inside: opaque)

          return opaque
        }()
        let fakeButtonCoordinate = toView.loginButton.superview!.convert(toView.loginButton.frame.origin,
                                                                         to: containerView)
        fakeButton.frame = CGRect(origin: fromView.loginButton.superview!.convert(fromView.loginButton.frame.origin,
                                                                                  to: containerView),
                                  size: fromView.loginButton.bounds.size)
        containerView.addSubview(fakeButton)
        
        // Draw shadow
        fakeButton.layer.shadowOpacity = 1
        fakeButton.layer.shadowPath = UIBezierPath(roundedRect: fakeButton.bounds, cornerRadius: fakeButton.bounds.height/2).cgPath
        fakeButton.layer.shadowColor = navigationController.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        fakeButton.layer.shadowRadius = navigationController.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        fakeButton.layer.shadowOffset = navigationController.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
        
        
        UIView.transition(with: fakeButtonLabel,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
          fakeButtonLabel.text = "signupButton".localized
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
        forgotButtonDestination.x = -(containerView.bounds.width + forgotButton.frame.width)
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
        
        let apple = ASAuthorizationAppleIDButton(type: .signIn, style: navigationController.traitCollection.userInterfaceStyle == .dark ? .white : .black)
        var appleDestination = fromView.apple.superview!.convert(fromView.apple.frame.origin,
                                                                             to: containerView)
        apple.frame.origin = appleDestination
        appleDestination.x = containerView.bounds.width//-(containerView.bounds.width + apple.frame.width)
        apple.frame.size = fromView.apple.frame.size
        containerView.addSubview(apple)
        fromView.apple.alpha = 0
        
        
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
            let instance = try! $0.copyObject() as! UIView
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
          [apple: [UIView(): appleDestination]],
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
                if view === fakeLogoText {
                  view.frame.size = toView.logoText.frame.size
                }
              }) {  _ in
                destinationView.alpha = 1
                view.removeFromSuperview()

                guard index == views.count - 1 else { return }
                
                fromView.forgotButton.alpha = 1
                fromView.signupButton.alpha = 1
                fromView.logoIcon.alpha = 1
                fromView.loginContainer.alpha = 1
                fromView.passwordContainer.alpha = 1

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
                let logoIcon = titleView.arrangedSubviews.filter({ $0 is Logo }).first as? Logo,
                let logoText = titleView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "opaque" }).first?.subviews.filter({ $0 is LogoText }).first as? LogoText {
        
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
        let fakeLogoIcon  = Logo(frame: CGRect(origin: fromView.logoIcon.superview!.convert(fromView.logoIcon.frame.origin,
                                                                                to: containerView),
                                       size: fromView.logoIcon.bounds.size))
        fakeLogoIcon.removeConstraints(fakeLogoIcon.getAllConstraints())
        opaque.addSubview(fakeLogoIcon)
        fromView.logoIcon.alpha = 0
        logoIcon.alpha = 0

        
        let fakeLogoText = LogoText(frame: CGRect(origin: fromView.logoText.superview!.convert(fromView.logoText.frame.origin,
                                                                                   to: containerView),
                                          size: fromView.logoText.bounds.size))
        fakeLogoText.removeConstraints(fakeLogoText.getAllConstraints())
        opaque.addSubview(fakeLogoText)
        fromView.logoText.alpha = 0
        logoText.alpha = 0
        
        let fakeLogoIconDestination = logoIcon.superview!.convert(logoIcon.frame.origin,
                                                                   to: containerView)
        let fakeLogoTextDestination = logoText.superview!.convert(logoText.frame.origin,
                                                                   to: containerView)
        
           
           let loginButton: UIButton = {
             let instance = UIButton()
             if #available(iOS 15, *) {
               var config = UIButton.Configuration.filled()
               config.cornerStyle = .capsule
               config.baseBackgroundColor = Colors.main
               config.attributedTitle = AttributedString("loginButton".localized,
                                                         attributes: AttributeContainer([
                                                          .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                           .foregroundColor: UIColor.white as Any
                                                         ]))
               instance.configuration = config
             } else {
               instance.backgroundColor = Colors.main
               instance.cornerRadius = fromView.loginButton.cornerRadius
               instance.setAttributedTitle(NSAttributedString(string: "loginButton".localized,
                                                              attributes: [
                                                                .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
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
           
           let acceptButton: UIView = {
             
             
             let instance = UIButton()
             if #available(iOS 15, *) {
               var config = UIButton.Configuration.filled()
               config.cornerStyle = .capsule
               config.baseBackgroundColor = UIColor.systemGray
               config.attributedTitle = AttributedString("acceptButton".localized,
                                                         attributes: AttributeContainer([
                                                          .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                           .foregroundColor: UIColor.white as Any
                                                         ]))
               instance.configuration = config
             } else {
               instance.cornerRadius = toView.acceptButton.cornerRadius
               instance.backgroundColor = .systemGray
               instance.setAttributedTitle(NSAttributedString(string: "acceptButton".localized,
                                                              attributes: [
                                                               .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
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
               fakeLogoIcon.frame = CGRect(origin: fakeLogoIconDestination,
                                   size: logoIcon.bounds.size)
               fakeLogoText.frame = CGRect(origin: fakeLogoTextDestination,
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
