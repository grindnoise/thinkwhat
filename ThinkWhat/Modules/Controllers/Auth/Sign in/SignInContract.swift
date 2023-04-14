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
  
  
}

protocol SignInControllerInput: AnyObject {
  
  var modelOutput: SignInModelOutput? { get set }
  
  
}

protocol SignInModelOutput: AnyObject {
  
}

protocol SignInControllerOutput: AnyObject {
  var viewInput: SignInViewInput? { get set }
  
  
}
