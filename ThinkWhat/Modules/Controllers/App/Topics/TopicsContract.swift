//
//  TopicsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

protocol TopicsViewInput: AnyObject {
  
  var controllerOutput: TopicsControllerOutput? { get set }
  var controllerInput: TopicsControllerInput? { get set }
  var mode: TopicsController.Mode { get set }
  var filter: SurveyFilter { get }
  var searchMode: Enums.SearchMode { get set }
  
  func openSettings()
  func getDataItems(excludeList: [SurveyReference])
  func onSurveyTapped(_: SurveyReference)
  //  func onTopicSelected(_: Topic)
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(_: SurveyReference)
  func share(_: SurveyReference)
  func claim(_: [SurveyReference: Claim])
  func openUserprofile(_: Userprofile)
  func unsubscribe(from: Userprofile)
  func subscribe(to: Userprofile)
  func subscribe(topic: Topic, subscribe: Bool)
}

protocol TopicsControllerInput: AnyObject {
  
  var modelOutput: TopicsModelOutput? { get set }
  
  func getDataItems(filter: SurveyFilter, excludeList: [SurveyReference])
  func updateSurveyStats(_: [SurveyReference])
  func addFavorite(surveyReference: SurveyReference)
  func claim(_: [SurveyReference: Claim])
  func unsubscribe(from: Userprofile)
  func subscribe(to: Userprofile)
  func subscribe(topic: Topic, subscribe: Bool)
  func search(substring: String,
              localized: Bool,
              filter: SurveyFilter)
  func updateTopicsStats()
}

protocol TopicsModelOutput: AnyObject {
  func onRequestCompleted(_: Result<Bool, Error>)
  func onSearchCompleted(_: [SurveyReference], localSearch: Bool)
}

protocol TopicsControllerOutput: AnyObject {
  var viewInput: (TopicsViewInput & TintColorable)? { get set }
  var searchPublisher: PassthroughSubject<String, Never> { get }
  
  func onRequestCompleted(_: Result<Bool, Error>)
  func didAppear()
  func didDisappear()
  func scrollToTop()
  func showTopics()
//  func setTopicModeEnabled(_: Topic)
  func setColor(_: UIColor)
  func resetFilters()
  func setFiltersHidden(_: Bool)
  func setSearchModeEnabled(enabled: Bool, delay: TimeInterval)
  func onSearchCompleted(_: [SurveyReference], localSearch: Bool)
  func beginSearchRefreshing()
  //    var topic: Topic? { get }
  
  //    func onDidLayout()
  //    func onWillAppear()
  //    func onParentMode()
  //    func onChildMode()
  
  //    func onListToChildMode()
  //    func onSearchToParentMode()
  //    func onError()
}
