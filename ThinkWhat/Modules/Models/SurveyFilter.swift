//
//  SurveyFilter.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyFilter: Hashable {
  static func == (lhs: SurveyFilter, rhs: SurveyFilter) -> Bool {
    lhs.main == rhs.main &&
    lhs.additional == rhs.additional &&
    lhs.period == rhs.period &&
    lhs.topic == rhs.topic &&
    lhs.userprofile == rhs.userprofile &&
    lhs.compatibility == rhs.compatibility
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(main.rawValue)
    hasher.combine(additional.rawValue)
    hasher.combine(period.rawValue)
    hasher.combine(topic)
    hasher.combine(userprofile)
    hasher.combine(compatibility)
//    hasher.combine(substring)
  }
  
  // MARK: - Public properties
  public let changePublisher = PassthroughSubject<[SurveyReference], Never>() // Notify subscribers on change
  // Optional
  public var topic: Topic?
  public var compatibility: TopicCompatibility?
  public var userprofile: Userprofile?
  public var period: Enums.Period = .unlimited
//  public var substring = ""
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  // Necessary
  private var main: Enums.SurveyFilterMode = .disabled
  private var additional: Enums.SurveyAdditionalFilterMode = .disabled
  
  init(main: Enums.SurveyFilterMode,
       additional: Enums.SurveyAdditionalFilterMode = .disabled,
       period: Enums.Period = .unlimited,
       topic: Topic? = nil,
       userprofile: Userprofile? = nil,
       compatibility: TopicCompatibility? = nil) {
    self.main = main
    self.additional = additional
    self.period = period
    self.topic = topic
    self.userprofile = userprofile
    self.compatibility = compatibility
  }
  
  // MARK: - Public methods
  @discardableResult
  public func getDataItems() -> [SurveyReference] {
    let items = additional.getDataItems(main.getDataItems(topic: topic,
                                                          userprofile: userprofile,
                                                          compatibility: compatibility),
                                        period: period)
//    if main == .rated {
//      items.sort {
//        if $0.rating == $0.rating {
//          return $0.startDate > $1.startDate
//        }
//        return $0.rating > $1.rating
//      }
//    }
    changePublisher.send(items)
    
    return items
  }
  
  @discardableResult
  public func setMain(filter: Enums.SurveyFilterMode,
                      topic: Topic? = nil,
                      userprofile: Userprofile? = nil,
                      compatibility: TopicCompatibility? = nil) -> [SurveyReference] {
    self.topic = topic
    self.userprofile = userprofile
    self.compatibility = compatibility
    main = filter
    
    return getDataItems()
  }
  
  @discardableResult
  public func setAdditional(filter: Enums.SurveyAdditionalFilterMode,
                            period: Enums.Period? = nil) -> [SurveyReference] {
    if !period.isNil { self.period = period! }
    additional = filter
    
    return getDataItems()
  }
  
  @discardableResult
  public func setBoth(main: Enums.SurveyFilterMode,
                      topic: Topic? = nil,
                      userprofile: Userprofile? = nil,
                      compatibility: TopicCompatibility? = nil,
                      additional: Enums.SurveyAdditionalFilterMode,
                      period: Enums.Period? = nil) -> [SurveyReference] {
    self.topic = topic
    self.userprofile = userprofile
    self.compatibility = compatibility
    self.main = main
    self.additional = additional
    if !period.isNil { self.period = period! }
    
    return getDataItems()
  }
  
  public func getPeriod() -> Enums.Period { period }
  
  public func setPeriod(_ period: Enums.Period) {
    self.period = period
  }
  
  public func getMain() -> Enums.SurveyFilterMode { main }
  
  public func getAdditional() -> Enums.SurveyAdditionalFilterMode { additional }
  
  public func getRequestArgs(excludeList: [SurveyReference] = [],
                             includeList: [SurveyReference] = [],
                             substring: String = "",
                             owners: [Userprofile],
                             topics: [Topic]) -> [String: Any] {
    var args = [String: Any]()
    
    if !excludeList.isEmpty {
      args["exclude_ids"] = excludeList.map { $0.id }
    }
    if !includeList.isEmpty {
      args["include_ids"] = includeList.map { $0.id }
    }
    if !topics.isEmpty {
      args["topics_ids"] = topics.map { $0.id }
    }
    if !substring.isEmpty {
      args["substring"] = substring
    }
    
    // Get args from main
    switch main {
    case .rated:
      args["rated"] = true
    case .favorite:
      args["watchlist"] = true
    case .own:
      if !owners.isEmpty {
        args["owners_ids"] = owners.map { $0.id }
      }
    case .topic:
      guard let topic = topic else { return args }
      
      args["topic_ids"] = [topic.id]
    case .user:
      guard let userprofile = userprofile else { return args }
      
      args["userprofile_id"] = userprofile.id
    case .compatible:
      guard let compatibility = compatibility else { return args }
      
      var list = [Int]()
      if !excludeList.isEmpty {
        list += excludeList.map { $0.id }
      } else {
        let fullSet = Set(compatibility.surveys)
        let existingSet = Set(Set(main.getDataItems(compatibility: compatibility).map { $0.id }))
        list = Array(fullSet.symmetricDifference(existingSet))
      }
      guard !list.isEmpty else { return args }
      
      args["include_ids"] = list
      default: debugPrint("") }
    
    // Get args from additional
    switch additional {
    case .period:
      guard let date = period.date else { return args }
      
      args["date_from"] = date.toDateString()
    case .anonymous:
      args["anonymous"] = true
    case .discussed:
      args["discussed"] = true
    case .completed:
      args["completed"] = true
    case .notCompleted:
      args["completed"] = false
    default:
      return args
    }
    
    return args
  }
}
