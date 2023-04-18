//
//  SignInViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
  
  
  // MARK: - Public properties
  var controllerOutput: SignInControllerOutput?
  var controllerInput: SignInControllerInput?
  
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
}

extension SignInViewController: SignInViewInput {
  func mailLogin(username: String, password: String) {
    controllerInput?.mailLogin(username: username, password: password)
  }
  
  func providerlogin(_ provider: AuthProvider) {
    controllerInput?.providerlogin(provider)
  }
  
  func signup() {
    
  }
}

extension SignInViewController: SignInModelOutput {
  func loginCallback(_ result: Result<Bool, Error>) {
    print("loginCallback", result)
  }
}

private extension SignInViewController {
  @MainActor
  func setupUI() {
    navigationItem.setHidesBackButton(true, animated: false)
  }
}
