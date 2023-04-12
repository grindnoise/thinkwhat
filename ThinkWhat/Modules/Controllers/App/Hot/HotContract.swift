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
  var isOnScreen: Bool { get }
  
  func deque() -> Survey?
  func vote(_: Survey)
  func claim(_: [SurveyReference: Claim])
  func reject(_: Survey)
}

protocol HotControllerInput: AnyObject {
  var modelOutput: HotModelOutput? { get set }
 
  func getSurveys(_:[Survey])
  func reject(_: Survey)
  func claim(_: [SurveyReference: Claim])
  func updateData()
}

protocol HotModelOutput: AnyObject {
  var queue: QueueArray<Survey> { get }
  var currentSurvey: Survey? { get }
}

protocol HotControllerOutput: AnyObject {
  var viewInput: (UIViewController & HotViewInput)? { get set }
  var currentSurvey: Survey? { get }
  
  func setSurvey(_: Survey?)
  func didAppear()
  func didDisappear()
  func didLoad()
  func next(_ survey: Survey?)
}
