//
//  NewAccountContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

protocol NewAccountViewInput: AnyObject {
  
  var controllerOutput: NewAccountControllerOutput? { get set }
  var controllerInput: NewAccountControllerInput? { get set }
  
  func signup(username: String, email: String, password: String, completion: @escaping(Result<Bool,Error>)->())
//  func checkCredentials(username: String, email: String, completion: @escaping(Result<Bool,Error>)->())
}

protocol NewAccountControllerInput: AnyObject {
  
  var modelOutput: NewAccountModelOutput? { get set }
  
  
}

protocol NewAccountModelOutput: AnyObject {
  
}

protocol NewAccountControllerOutput: AnyObject {
  var viewInput: NewAccountViewInput? { get set }
  
  var mailChecker: PassthroughSubject<String, Never> { get set }
  var nameChecker: PassthroughSubject<String, Never> { get set }
  
  func nameCheckerCallback(result: Result<Bool,Error>)
  func mailCheckerCallback(result: Result<Bool,Error>)
}
