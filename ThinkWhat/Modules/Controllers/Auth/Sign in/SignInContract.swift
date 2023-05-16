//
//  SignInContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol SignInViewInput: AnyObject {
  var controllerOutput: SignInControllerOutput? { get set }
  var controllerInput: SignInControllerInput? { get set }
  
  func mailSignIn(username: String, password: String)
  func providerSignIn(provider: AuthProvider)
  func nextScene()
//  func openProfile()
  func signUp()
  func resetPassword()
}

protocol SignInControllerInput: AnyObject {
  var modelOutput: SignInModelOutput? { get set }
  
  func mailSignIn(username: String, password: String)
  func providerSignIn(provider: AuthProvider, accessToken: String)
  func sendVerificationCode(_: @escaping(Result<[String: Any], Error>)->())
  func updateUserprofile(parameters: [String: Any], image: UIImage?) throws
}

protocol SignInModelOutput: AnyObject {
  func mailSignInCallback(_: Result<Bool, Error>)
  func providerSignInCallback(result: Result<Bool, Error>)
}

protocol SignInControllerOutput: AnyObject {
  var viewInput: (UIViewController & SignInViewInput)? { get set }
  
  func mailSignInCallback(result: Result<Bool, Error>)
  func providerSignInCallback(result: Result<Bool, Error>)
  func startAuthorizationUI(provider: AuthProvider)
  func animateTransitionToApp(_ completion: @escaping Closure) 
//  func stopAuthorizationUI(completion: @escaping Closure)
}
