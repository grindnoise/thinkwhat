//
//  HotContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol HotViewInput: AnyObject {
  var controllerOutput: HotControllerOutput? { get set }
  var controllerInput: HotControllerInput? { get set }
  var queue: QueueArray<Survey> { get }
  var tabBarHeight: CGFloat { get }
  var navBarHeight: CGFloat { get }
  
  func deque() -> Survey?
  
}

protocol HotControllerInput: AnyObject {
  var modelOutput: HotModelOutput? { get set }
 
  func getSurveys(_:[Survey])
}

protocol HotModelOutput: AnyObject {
  
}

protocol HotControllerOutput: AnyObject {
  var viewInput: (UIViewController & HotViewInput)? { get set }
  
  func peek(_: Survey?)
}
