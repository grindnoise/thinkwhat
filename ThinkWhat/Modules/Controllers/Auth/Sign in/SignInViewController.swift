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
import AuthenticationServices

class SignInViewController: UIViewController {
  
  
  // MARK: - Public properties
  var controllerOutput: SignInControllerOutput?
  var controllerInput: SignInControllerInput?
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  // Banner handlers
  private var bannersQueue: QueueArray<NewBanner> = QueueArray() // Store banners in queue
  private var isBannerOnScreen = false // Prevent banner overlay
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
    
    setTasks()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.setHidesBackButton(true, animated: false)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationController?.setBarColor(traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground)
//    fillNavigationBar(with: traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground)
  }
}

extension SignInViewController: SignInViewInput {
  func resetPassword() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
//    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(PasswordResetViewController(), animated: true)
    navigationController?.delegate = nil
  }
  
  func nextScene() {
//    guard !UserDefaults.App.hasReadTermsOfUse else {
//      guard let userprofile = Userprofiles.shared.current,
//            let wasEdited = userprofile.wasEdited
//      else { return }
//
//      guard wasEdited else {
//        navigationController?.delegate = appDelegate.transitionCoordinator
//        navigationController?.pushViewController(ProfileCreationViewController(), animated: true)
//        navigationController?.delegate = nil
//        return
//      }
//      controllerOutput?.animateTransitionToApp {
//        appDelegate.window?.rootViewController = MainController(surveyId: nil)
//      }
//
//      return
//    }
    
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(TermsViewController(), animated: true)
    navigationController?.delegate = nil
  }
  
  func providerSignIn(provider: Enums.AuthProvider) {
    switch provider {
    case .VK:
      VKWorker.wakeUp()
      VKWorker.authorize(completion: { [weak self] result in
        guard let self = self else { return }

        switch result {
        case .success(let accessToken):
          self.controllerInput?.providerSignIn(provider: provider, accessToken: accessToken)
          self.controllerOutput?.startLoadingAnim()
        case .failure(let error):
          self.controllerOutput?.stopLoadingAnim { [weak self] in
            guard let self = self else { return }
          
            self.enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                          text: AppError.server.localizedDescription)
    #if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
    #endif
          }

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
          self.controllerOutput?.startLoadingAnim()
        case .failure(let error):
          self.controllerOutput?.stopLoadingAnim { [weak self] in
            guard let self = self else { return }
          
            self.enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                          text: AppError.server.localizedDescription)
    #if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
    #endif
          }
        }
      }
    case .Apple:
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email,]
      
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    default:
#if DEBUG
        fatalError("Not implemented")
#endif
    }
  }
  
  func signUp() {
    let backItem = UIBarButtonItem()
    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
    navigationController?.delegate = appDelegate.transitionCoordinator
    navigationController?.pushViewController(NewAccountViewController(), animated: true)
//    navigationController?.delegate = nil
  }
  
  func mailSignIn(username: String, password: String) {
    controllerInput?.mailSignIn(username: username, password: password)
  }
}

extension SignInViewController: SignInModelOutput {
  func providerSignInCallback(result: Result<Bool, Error>) {
    controllerOutput?.stopLoadingAnim() { [weak self] in
      guard let self = self  else { return }
      
      switch result {
      case .success(_):
        self.nextScene()
      case .failure(let error):
        self.enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                      text: AppError.server.localizedDescription)
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func mailSignInCallback(_ result: Result<Bool, Error>) {
    switch result {
    case .success(_):
      if !AppData.isSocialAuth && !AppData.isEmailVerified {
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
                                                      color: Constants.UI.Colors.main)
          
          content.verifiedPublisher
            .delay(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .sink {[weak self] in
              guard let self = self else { return }
              
              try? self.controllerInput?.updateUserprofile(parameters: ["is_email_verified": true], image: nil)
              AppData.isEmailVerified = true
              banner.dismiss()
            }
            .store(in: &banner.subscriptions)
          content.retryPublisher
            .sink { [weak self] in
              guard let self = self else { return }
              
              self.controllerInput?.sendVerificationCode { [unowned self] in
                
                switch $0 {
                case .success(let dict):
                  guard let code = dict["confirmation_code"] as? Int else { return }
                  
                  content.onEmailSent(code)
                case.failure(let error):
#if DEBUG
                  error.printLocalized(class: type(of: self), functionName: #function)
#endif
                  self.enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                     text: AppError.server.localizedDescription)
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
                                                        color: Constants.UI.Colors.main)
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
                  self.enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                                text: AppError.server.localizedDescription)
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
            self.enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                          text: AppError.server.localizedDescription)
            
            self.controllerOutput?.mailSignInCallback(result: .failure(error))
          }
        }
      } else {
        controllerOutput?.mailSignInCallback(result: result)
      }
    case .failure(let failure):
      if let apiError = failure as? APIError,
         let errorDescription = apiError.errorDescription {
        enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                      text: AppError.server.localizedDescription)
      }
      controllerOutput?.mailSignInCallback(result: result)
    }
  }
}

private extension SignInViewController {
  @MainActor
  func setupUI() {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  // Banner queue listener
  func setTasks() {
    Timer
      .publish(every: 0.5, on: .main, in: .common)
      .autoconnect()
      .filter { [unowned self] _ in !self.isBannerOnScreen}
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        if let banner = self.bannersQueue.dequeue() {
          self.isBannerOnScreen = true
          banner.present()
          banner.didDisappearPublisher
            .sink { [unowned self] _ in
              banner.removeFromSuperview()
              self.isBannerOnScreen = false
            }
            .store(in: &self.subscriptions)
        }
      }
      .store(in: &subscriptions)
  }
  
  func enqueueBanner(image: UIImage? = nil,
                     icon: Icon? = nil,
                     text: String,
                     attributedText: NSAttributedString? = nil,
                     isModal: Bool = false,
                     shouldPresent: Bool = false,
                     shouldDismissAfter: Double = 2.0) {
    bannersQueue.enqueue(NewBanner(contentView: TextBannerContent(image: image, icon: icon, text: text, attributedText: attributedText),
                                   contentPadding: UIEdgeInsets(top: Constants.UI.padding*2, left: Constants.UI.padding, bottom: Constants.UI.padding*2, right: Constants.UI.padding),
                                   isModal: isModal,
                                   useContentViewHeight: true,
                                   shouldPresent: shouldPresent,
                                   shouldDismissAfter: shouldDismissAfter))
  }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
#if DEBUG
    error.printLocalized(class: type(of: self), functionName: #function)
#endif
    enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                  text: AppError.server.localizedDescription)
//    controllerOutput?.stopLoadingAnim {}
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let authorizationCode = appleIDCredential.authorizationCode,
          let code = String(data: authorizationCode, encoding: .utf8)
    else {
      enqueueBanner(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: UIColor.systemRed),
                    text: AppError.server.localizedDescription)
      return
    }
    
    // Smooth delay
    delay(seconds: 0.5) { [weak self] in
      guard let self = self else { return }
     
      self.controllerOutput?.startLoadingAnim()
    }
    controllerInput?.providerSignIn(provider: .Apple, accessToken: code)
    //        let userIdentifier = appleIDCredential.user
    //        let fullName = appleIDCredential.fullName
    //        let email = appleIDCredential.email
    //
    //        // For the purpose of this demo app, store the `userIdentifier` in the keychain.
    //        //          self.saveUserInKeychain(userIdentifier)
    //        //
    //        //          // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
    //        //          self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
    //
    //      case let passwordCredential as ASPasswordCredential:
    //
    //          // Sign in using an existing iCloud Keychain credential.
    //          let username = passwordCredential.user
    //          let password = passwordCredential.password
    //
    ////          // For the purpose of this demo app, show the password credential as an alert.
    ////          DispatchQueue.main.async {
    ////              self.showPasswordCredentialAlert(username: username, password: password)
    ////          }
  }
}
