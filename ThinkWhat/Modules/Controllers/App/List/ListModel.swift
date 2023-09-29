//
//  ListModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class ListModel {
  
  weak var modelOutput: ListModelOutput?
}

// MARK: - Controller Input
extension ListModel: ListControllerInput {
  func search(substring: String,
              localized: Bool,
              filter: SurveyFilter) {
    var existing: [SurveyReference] {
      var instances =  SurveyReferences.shared.all
        .filter({ $0.title.lowercased().contains(substring.lowercased()) })
      
      if !filter.userprofile.isNil { instances = instances.filter({ $0.owner == filter.userprofile! }) }
      if !filter.topic.isNil { instances = instances.filter({ $0.topic == filter.topic! }) }
      
      modelOutput?.onSearchCompleted(Array(Set(instances)).sorted { $0.startDate > $1.startDate }, localSearch: true)
      
      return instances
    }
    
    Task {
      do {
        let received = try await API.shared.surveys.search(substring: substring,
                                                           localized: localized,
                                                           excludedIds: existing.map { $0.id },
                                                           ownersIds: filter.userprofile.isNil ? [] : [filter.userprofile!.id],
                                                           topicsIds: filter.topic.isNil ? [] : [filter.topic!.id])
        await MainActor.run {
          modelOutput?.onSearchCompleted(Array(Set(existing + received)).sorted { $0.startDate > $1.startDate }, localSearch: false)
        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
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
      await API.shared.surveys.markFavorite(mark: !surveyReference.isFavorite,
                                            surveyReference: surveyReference)
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
  
  func getDataItems(filter: SurveyFilter, excludeList: [SurveyReference]) {
    Task {
      do {
        try await API.shared.surveys.getSurveyReferences(filter: filter, excludeList: excludeList)
        
        await MainActor.run {
          modelOutput?.onRequestCompleted(.success(true))
        }
      } catch {
        await MainActor.run {
          modelOutput?.onRequestCompleted(.failure(error))
        }
      }
    }
  }
}
