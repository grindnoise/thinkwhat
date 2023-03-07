//
//  TopicsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class TopicsModel {
  
  weak var modelOutput: TopicsModelOutput?
}

// MARK: - Controller Input
extension TopicsModel: TopicsControllerInput {
  func search(substring: String,
              localized: Bool,
              topic: Topic?) {
    
    var existing: [SurveyReference] {
      return SurveyReferences.shared.all
        .filter({ $0.title.contains(substring) })
        .filter({ $0.topic == topic })
    }
    
    Task {
      do {
        let received = try await API.shared.surveys.search(substring: substring,
                                                           localized: localized,
                                                           excludedIds: existing.map { $0.id },
                                                           ownersIds: [],
                                                           topicsIds: topic.isNil ? [] : [topic!.id])
        await MainActor.run {
          modelOutput?.onSearchCompleted(existing + received)
        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
//  func search(substring: String, excludedIds: [Int] = []) {
//    Task {
//      do {
//        let instances = try await API.shared.surveys.search(substring: substring, excludedIds: excludedIds)
//        await MainActor.run {
//          modelOutput?.onSearchCompleted(instances)
//        }
//      } catch {
//#if DEBUG
//        error.printLocalized(class: type(of: self), functionName: #function)
//#endif
//      }
//    }
//  }
  
  func onDataSourceRequest(dateFilter: Period, topic: Topic) {
    Task {
      try await API.shared.surveys.surveyReferences(category: .Topic,
                                                    dateFilter: dateFilter,
                                                    topic: topic)
    }
  }
  
  func unsubscribe(from userprofile: Userprofile) {
    Task {
      try await API.shared.profiles.unsubscribe(from: [userprofile])
    }
  }
  
  func subscribe(to userprofile: Userprofile) {
    Task {
      try await API.shared.profiles.subscribe(at: [userprofile])
    }
  }
  
  func claim(_ dict: [SurveyReference: Claim]) {
    guard let instance = dict.keys.first,
          let reason = dict.values.first
    else { return }
    
    Task {
      try await API.shared.surveys.claim(surveyReference: instance, reason: reason)
    }
  }
  
  func addFavorite(surveyReference: SurveyReference) {
    Task {
      await API.shared.surveys.markFavorite(mark: !surveyReference.isFavorite, surveyReference: surveyReference)
    }
  }
  
  func updateSurveyStats(_ instances: [SurveyReference]) {
    Task {
      do {
        try await API.shared.surveys.updateSurveyStats(instances)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func updateTopicsStats() {
    Task {
      do {
        try await API.shared.surveys.updateTopicsStats()
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
}
