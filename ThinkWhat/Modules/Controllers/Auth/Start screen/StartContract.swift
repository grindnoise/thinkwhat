//
//  StartContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol StartViewInput: AnyObject {
  
  var controllerOutput: StartControllerOutput? { get set }
  var controllerInput: StartControllerInput? { get set }
  
  func nextScene()
}

protocol StartControllerInput: AnyObject {
  
  var modelOutput: StartModelOutput? { get set }
  
  
}

protocol StartModelOutput: AnyObject {
  
}

protocol StartControllerOutput: AnyObject {
  var viewInput: StartViewInput? { get set }
  
  func didAppear()
  func didDisappear()
}
