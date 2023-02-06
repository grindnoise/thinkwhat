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
  
  func claim(surveyReference: SurveyReference, claim: Claim) {
    Task {
      try await API.shared.surveys.claim(surveyReference: surveyReference, reason: claim)
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
  
  func onDataSourceRequest(source: Survey.SurveyCategory, dateFilter: Period?, topic: Topic?, userprofile: Userprofile?) {
    Task {
      do {
        try await API.shared.surveys.surveyReferences(category: source, dateFilter: dateFilter, topic: topic, userprofile: userprofile)
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
  
  func search(substring: String, excludedIds: [Int] = []) {
      Task {
          do {
              let instances = try await API.shared.surveys.search(substring: substring, excludedIds: excludedIds)
              await MainActor.run {
                  modelOutput?.onSearchCompleted(instances)
              }
          } catch {
#if DEBUG
              error.printLocalized(class: type(of: self), functionName: #function)
#endif
          }
      }
  }
}
