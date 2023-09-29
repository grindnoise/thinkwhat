//
//  ListContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol ListViewInput: AnyObject {
  
  var controllerOutput: ListControllerOutput? { get set }
  var controllerInput: ListControllerInput? { get set }
  var searchMode: Enums.SearchMode { get set }
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
  func search(substring: String,
              localized: Bool,
              filter: SurveyFilter)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol ListModelOutput: AnyObject {
  func onRequestCompleted(_: Result<Bool, Error>)
  func onSearchCompleted(_: [SurveyReference], localSearch: Bool)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol ListControllerOutput: AnyObject {
  var viewInput: (ListViewInput & TintColorable)? { get set }
  var searchPublisher: PassthroughSubject<String, Never> { get }
//  var isOnScreen: Bool { get set }
  
  func onRequestCompleted(_: Result<Bool, Error>)
  func didAppear()
  func didDisappear()
  func scrollToTop()
  func beginSearchRefreshing()
  func setSearchModeEnabled(_: Bool)
  func onSearchCompleted(_: [SurveyReference], localSearch: Bool)
}
