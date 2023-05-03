//
//  ProfileCreationContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol ProfileCreationViewInput: AnyObject {
  var controllerOutput: ProfileCreationControllerOutput? { get set }
  var controllerInput: ProfileCreationControllerInput? { get set }
  
  func openApp()
}

protocol ProfileCreationControllerInput: AnyObject {
  
  var modelOutput: ProfileCreationModelOutput? { get set }
}

protocol ProfileCreationModelOutput: AnyObject {
  
}

protocol ProfileCreationControllerOutput: AnyObject {
  var viewInput: (UIViewController & ProfileCreationViewInput)? { get set }
}
