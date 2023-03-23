//
//  NewPollContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit


protocol NewPollViewInput: AnyObject {
  
  var controllerOutput: NewPollControllerOutput? { get set }
  var controllerInput: NewPollControllerInput? { get set }
  
  func setProgress(_: Double)
  func addImage()
}

protocol NewPollControllerInput: AnyObject {
  
  var modelOutput: NewPollModelOutput? { get set }
  
  
}

protocol NewPollModelOutput: AnyObject {
  
}

protocol NewPollControllerOutput: AnyObject {
  var viewInput: NewPollViewInput? { get set }
  
//  var isMovingToParent
  func willMoveToParent()
  func imageAdded(_: UIImage)
}
