//
//  PasswordResetContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol PasswordResetViewInput: AnyObject {
  
  var controllerOutput: PasswordResetControllerOutput? { get set }
  var controllerInput: PasswordResetControllerInput? { get set }
  
  func sendResetLink(_: String)
}

protocol PasswordResetControllerInput: AnyObject {
  
  var modelOutput: PasswordResetModelOutput? { get set }
  
  func sendResetLink(_: String)
}

protocol PasswordResetModelOutput: AnyObject {
  func callback(_: Result<Bool, Error>)
}

protocol PasswordResetControllerOutput: AnyObject {
  var viewInput: (PasswordResetViewInput & UIViewController)? { get set }
  
  func callback(_: Result<Bool, Error>)
}
