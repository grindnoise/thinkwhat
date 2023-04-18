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
  
  func providerlogin(_: AuthProvider)
  func mailLogin(username: String, password: String)
  func signup()
}

protocol SignInControllerInput: AnyObject {
  
  var modelOutput: SignInModelOutput? { get set }
  
  func mailLogin(username: String, password: String)
  func providerlogin(_: AuthProvider)
}

protocol SignInModelOutput: AnyObject {
  func loginCallback(_: Result<Bool, Error>)
}

protocol SignInControllerOutput: AnyObject {
  var viewInput: SignInViewInput? { get set }
  
  
}
