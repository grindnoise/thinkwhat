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
    controllerOutput?.mailSignInCallback(result: result)
    if case .failure(let failure) = result {
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
