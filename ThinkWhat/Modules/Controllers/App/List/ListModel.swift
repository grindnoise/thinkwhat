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
  
  func onDataSourceRequest(source: Survey.SurveyCategory,
                           dateFilter: Period?,
                           topic: Topic?) {
    Task {
      do {
        try await API.shared.surveys.surveyReferences(category: source,
                                                      period: dateFilter,
                                                      topic: topic)
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
