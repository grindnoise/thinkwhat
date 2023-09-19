//
//  SurveysModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SurveysModel {
  
  weak var modelOutput: SurveysModelOutput?
  
  // MARK: - Destructor
  deinit {
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
}

// MARK: - Controller Input
extension SurveysModel: SurveysControllerInput {
  func getDataItems(filter: SurveyFilter,
                    excludeList: [SurveyReference],
                    substring: String) {
    Task {
      do {
        try await API.shared.surveys.getSurveyReferences(filter: filter,
                                                         excludeList: excludeList,
                                                         substring: substring)
        
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
  
  func search(substring: String,
              localized: Bool = false,
              except surveys: [SurveyReference] = [],
              ownersIds: [Int] = [],
              topicsIds: [Int] = []) {
    
    var existing: [SurveyReference] {
      var instances =  SurveyReferences.shared.all
        .filter({ $0.title.lowercased().contains(substring) })
        .filter({ !surveys.map({ $0.id }).contains($0.id) })
      
      if !ownersIds.isEmpty { instances = instances.filter({ ownersIds.contains($0.owner.id) }) }
      if !topicsIds.isEmpty { instances = instances.filter({ topicsIds.contains($0.topic.id) }) }
      
      return instances
    }
    
    Task {
      do {
        let received = try await API.shared.surveys.search(substring: substring,
                                                            localized: localized,
                                                            excludedIds: surveys.map { $0.id } + existing.map { $0.id },
                                                            ownersIds: ownersIds,
                                                            topicsIds: topicsIds)
        await MainActor.run {
          modelOutput?.onSearchCompleted(surveys + existing + received)
        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
}
