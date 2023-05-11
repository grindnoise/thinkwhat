//
//  SignInViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import SwiftyJSON

class SignInViewController: UIViewController {
  
  
  // MARK: - Public properties
  var controllerOutput: SignInControllerOutput?
  var controllerInput: SignInControllerInput?
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Overridden Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = SignInView()
    let model = SignInModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.setHidesBackButton(true, animated: false)
  }
}

extension SignInViewController: SignInViewInput {
  func openAgreement() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(TermsViewController(), animated: true)
    navigationController?.delegate = nil
  }
  
  func providerSignIn(provider: AuthProvider) {
    switch provider {
    case .VK:
      VKWorker.wakeUp()
      VKWorker.authorize(completion: { [weak self] result in
        guard let self = self else { return }

        switch result {
        case .success(let accessToken):
          self.controllerInput?.providerSignIn(provider: provider, accessToken: accessToken)
          self.controllerOutput?.startAuthorizationUI(provider: provider)
        case .failure(let error):
          self.controllerOutput?.providerSignInCallback(result: .failure(error))
        }
      })
//    case .Facebook:
//        FBWorker.wakeUp()
//        guard let providerToken = try await FBWorker.authorizeAsync(viewController: self).tokenString as? String else { throw "Facebook token not available" }
//        return providerToken
    case .Google:
      GoogleWorker.signIn(viewController: self) { [weak self] result in
        guard let self = self else { return }
        
        switch result {
        case .success(let accessToken):
          self.controllerInput?.providerSignIn(provider: provider, accessToken: accessToken)
          self.controllerOutput?.startAuthorizationUI(provider: provider)
        case .failure(let error):
          self.controllerOutput?.providerSignInCallback(result: .failure(error))
        }
      }
    default:
#if DEBUG
        fatalError("Not implemented")
#endif
//        throw "Not implemented"
    }
  }
  
  func signUp() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(NewAccountViewController(), animated: true)
    navigationController?.delegate = nil
  }
  
  func mailSignIn(username: String, password: String) {
    controllerInput?.mailSignIn(username: username, password: password)
  }
}

extension SignInViewController: SignInModelOutput {
  func providerSignInCallback(result: Result<Bool, Error>) {
    if case .failure(let error) = result {
      let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                            text: AppError.server.localizedDescription,
                                                            tintColor: .systemRed,
                                                            fontName: Fonts.Regular,
                                                            textStyle: .subheadline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &subscriptions)
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
    }
    controllerOutput?.providerSignInCallback(result: result)
  }
  
  func mailSignInCallback(_ result: Result<Bool, Error>) {
    switch result {
    case .success(let success):
      if !AppData.isEmailVerified {
        guard AppData.emailVerificationCode.isNil else {
          ///App already has the code
          guard let userprofile = Userprofiles.shared.current,
                let email = userprofile.email as? String,
                let components = email.components(separatedBy: "@") as? [String],
                let username = components.first,
                let firstLetter = username.first,
                let lastLetter = username.last
          else { return }
          
          
          let banner = NewPopup(padding: self.padding*2,
                                contentPadding: .uniform(size: self.padding*2))
          let content = EmailVerificationPopupContent(code: AppData.emailVerificationCode!,
                                                      retryTimeout: 60,
                                                      email: email.replacingOccurrences(of: username,
                                                                                        with: "\(firstLetter)\(String.init(repeating: "*", count: username.count-2))\(lastLetter)"),
                                                      color: Colors.main)
          
          content.verifiedPublisher
            .delay(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .sink {
              AppData.isEmailVerified = true
              banner.dismiss()
            }
            .store(in: &banner.subscriptions)
          content.retryPublisher
            .sink { [unowned self] in self.controllerInput?.sendVerificationCode { [unowned self] in
              
              switch $0 {
              case .success(let dict):
                guard let code = dict["confirmation_code"] as? Int else { return }
                
                content.onEmailSent(code)
              case.failure(let error):
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
                let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                                      text: AppError.server.localizedDescription,
                                                                      tintColor: .systemRed,
                                                                      fontName: Fonts.Regular,
                                                                      textStyle: .subheadline,
                                                                      textAlignment: .natural),
                                       contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                       isModal: false,
                                       useContentViewHeight: true,
                                       shouldDismissAfter: 2)
                banner.didDisappearPublisher
                  .sink { _ in banner.removeFromSuperview() }
                  .store(in: &self.subscriptions)
              }
            }}
            .store(in: &banner.subscriptions)
          banner.setContent(content)
          banner.didDisappearPublisher
            .sink { [unowned self] _ in
              banner.removeFromSuperview()
              self.controllerOutput?.mailSignInCallback(result: result)
            }
            .store(in: &self.subscriptions)
          
          return
        }
        
        controllerInput?.sendVerificationCode() { [weak self] in
          guard let self = self else { return }
         
          switch $0 {
          case .success(let dict):
            guard let code = dict["confirmation_code"] as? Int,
                  let expiresString = dict["expires_in"] as? String,
                  let expiresDate = expiresString.dateTime,
                  let email = Userprofiles.shared.current!.email as? String,
                  let components = email.components(separatedBy: "@") as? [String],
                  let username = components.first,
                  let firstLetter = username.first,
                  let lastLetter = username.last
            else { return }
            
            //              let email = "pbuxaroff@gmail.com"
            let banner = NewPopup(padding: self.padding*2,
                                  contentPadding: .uniform(size: self.padding*2))
            let content = EmailVerificationPopupContent(code: code,
                                                        retryTimeout: 60,
                                                        email: email.replacingOccurrences(of: username, with: "\(firstLetter)\(String.init(repeating: "*", count: username.count-2))\(lastLetter)"),
                                                        color: Colors.main)
            content.verifiedPublisher
              .delay(for: .seconds(0.25), scheduler: DispatchQueue.main)
              .sink {
                do {
                  try self.controllerInput?.updateUserprofile(parameters: ["is_email_verified": true], image: nil)
                  AppData.isEmailVerified = true
                } catch {
  #if DEBUG
                  error.printLocalized(class: type(of: self), functionName: #function)
  #endif
                }
                banner.dismiss()
              }
              .store(in: &banner.subscriptions)
            content.retryPublisher
              .sink { [unowned self] in self.controllerInput?.sendVerificationCode { [unowned self] in
                
                switch $0 {
                case .success(let dict):
                  guard let code = dict["confirmation_code"] as? Int else { return }
                  
                  content.onEmailSent(code)
                case.failure(let error):
#if DEBUG
                  error.printLocalized(class: type(of: self), functionName: #function)
#endif
                  let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                                        text: AppError.server.localizedDescription,
                                                                        tintColor: .systemRed,
                                                                        fontName: Fonts.Regular,
                                                                        textStyle: .subheadline,
                                                                        textAlignment: .natural),
                                         contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                         isModal: false,
                                         useContentViewHeight: true,
                                         shouldDismissAfter: 2)
                  banner.didDisappearPublisher
                    .sink { _ in banner.removeFromSuperview() }
                    .store(in: &self.subscriptions)
                }
              }}
              .store(in: &banner.subscriptions)
            banner.setContent(content)
            banner.didDisappearPublisher
              .sink { [unowned self] _ in
                banner.removeFromSuperview()
                self.controllerOutput?.mailSignInCallback(result: result)
              }
              .store(in: &self.subscriptions)

          case .failure(let error):
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
            let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                                  text: AppError.server.localizedDescription,
                                                                  tintColor: .systemRed,
                                                                  fontName: Fonts.Regular,
                                                                  textStyle: .subheadline,
                                                                  textAlignment: .natural),
                                   contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                   isModal: false,
                                   useContentViewHeight: true,
                                   shouldDismissAfter: 2)
            banner.didDisappearPublisher
              .sink { _ in banner.removeFromSuperview() }
              .store(in: &self.subscriptions)
            
            controllerOutput?.mailSignInCallback(result: .failure(error))
          }
        }
      } else {
        controllerOutput?.mailSignInCallback(result: result)
      }
    case .failure(let failure):
      if let apiError = failure as? APIError,
         let errorDescription = apiError.errorDescription {
        let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
                                                              text: errorDescription,
                                                              tintColor: .systemRed,
                                                              fontName: Fonts.Regular,
                                                              textStyle: .subheadline,
                                                              textAlignment: .natural),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &subscriptions)
      }
      controllerOutput?.mailSignInCallback(result: result)
    }
  }
}

private extension SignInViewController {
  @MainActor
  func setupUI() {
    navigationController?.setNavigationBarHidden(true, animated: false)
//    navigationItem.setHidesBackButton(true, animated: false)
  }
}
