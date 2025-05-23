//
//  SubsciptionsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SubscriptionsModel {
  
  weak var modelOutput: SubsciptionsModelOutput?
}

// MARK: - Controller Input
extension SubscriptionsModel: SubsciptionsControllerInput {
  func getDataItems(filter: SurveyFilter, excludeList: [SurveyReference]) {
    Task {
      do {
        try await API.shared.surveys.getSurveyReferences(filter: filter,
                                                         excludeList: excludeList,
                                                         owners: Userprofiles.shared.all.filter { $0.subscribedAt })
        
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
  
//  func onDataSourceRequest(source: Enums.SurveyFilterMode, dateFilter: Enums.Period?, topic: Topic?, userprofile: Userprofile?) {
//    Task {
//      do {
//        try await API.shared.surveys.surveyReferences(category: source,
//                                                      period: dateFilter,
//                                                      topic: topic,
//                                                      userprofile: userprofile)
//
//        await MainActor.run {
//          modelOutput?.onRequestCompleted(.success(true))
//        }
//      } catch {
//        await MainActor.run {
//          modelOutput?.onRequestCompleted(.failure(error))
//        }
//      }
//    }
//  }
  
  func switchNotifications(userprofile: Userprofile, notify: Bool) {
    Task {
      do {
        try await API.shared.profiles.switchNotifications(userprofile: userprofile, notify: notify)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
}
