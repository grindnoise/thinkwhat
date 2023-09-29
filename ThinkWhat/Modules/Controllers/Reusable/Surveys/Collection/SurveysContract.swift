//
//  SurveysContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SurveysViewInput: AnyObject {
  
  var controllerOutput: SurveysControllerOutput? { get set }
  var controllerInput: SurveysControllerInput? { get set }
  var filter: SurveyFilter { get }
  
  func onSurveyTapped(_: SurveyReference)
  func getDataItems(excludeList: [SurveyReference])
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(_: SurveyReference)
  func share(_: SurveyReference)
  func claim(_: [SurveyReference: Claim])
  func openUserprofile(_: Userprofile)
  func unsubscribe(from: Userprofile)
  func subscribe(to: Userprofile)
}

protocol SurveysControllerInput: AnyObject {
  
  var modelOutput: SurveysModelOutput? { get set }
  
  func getDataItems(filter: SurveyFilter, excludeList: [SurveyReference], substring: String)
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(surveyReference: SurveyReference)
  func claim(_: [SurveyReference: Claim])
  func unsubscribe(from: Userprofile)
  func subscribe(to: Userprofile)
  func search(substring: String,
              localized: Bool,
              filter: SurveyFilter)
}

protocol SurveysModelOutput: AnyObject {
  func onRequestCompleted(_: Result<Bool, Error>)
  func onSearchCompleted(_: [SurveyReference], localSearch: Bool)
}

protocol SurveysControllerOutput: AnyObject {
  var viewInput: (TintColorable & SurveysViewInput)? { get set }
  
  func onRequestCompleted(_: Result<Bool, Error>)
  func viewDidDisappear()
  func beginSearchRefreshing()
  func setSearchModeEnabled(_: Bool)
  func onSearchCompleted(_: [SurveyReference])
}
