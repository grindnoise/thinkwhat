//
//  ListContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol ListViewInput: AnyObject {
  
  var controllerOutput: ListControllerOutput? { get set }
  var controllerInput: ListControllerInput? { get set }
  
  func onSurveyTapped(_: SurveyReference)
  func getDataItems(filter: SurveyFilter, excludeList: [SurveyReference])
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(_: SurveyReference)
  func share(_: SurveyReference)
  func claim(_: [SurveyReference: Claim])
  func openUserprofile(_: Userprofile)
  func unsubscribe(from: Userprofile)
  func subscribe(to: Userprofile)
  func openSettings()
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol ListControllerInput: AnyObject {
  
  var modelOutput: ListModelOutput? { get set }
  
  func getDataItems(filter: SurveyFilter, excludeList: [SurveyReference])
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(surveyReference: SurveyReference)
  func claim(_: [SurveyReference: Claim])
  func unsubscribe(from: Userprofile)
  func subscribe(to: Userprofile)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol ListModelOutput: AnyObject {
  func onRequestCompleted(_: Result<Bool, Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol ListControllerOutput: AnyObject {
  var viewInput: (ListViewInput & TintColorable)? { get set }
  var isOnScreen: Bool { get set }
  
  func onRequestCompleted(_: Result<Bool, Error>)
  func didAppear()
  func didDisappear()
  func scrollToTop()
}
