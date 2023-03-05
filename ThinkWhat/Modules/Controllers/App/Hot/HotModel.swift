//
//  HotModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class HotModel {
    
  weak var modelOutput: HotModelOutput?
}

// MARK: - Controller Input
extension HotModel: HotControllerInput {
  func getSurveys(_ excludeList: [Survey]) {
    Task {
      do {
        var parameters: [String: Any] = [:]
        let stackList = excludeList.map { $0.id }
        let rejectedList = Surveys.shared.all
          .filter { $0.isRejected}
          .map { $0.id }
        let claimedList = Surveys.shared.all
          .filter { $0.isClaimed}
          .map { $0.id }
        let list = Array(Set(stackList + rejectedList + claimedList)).uniqued()
        
        if !list.isEmpty {
          parameters["exclude_ids"] = list
        }
        
        let data = try await API.shared.surveys.getSurveys(type: .Hot,
                                                           parameters: parameters)
        let json = try JSON(data: data,
                            options: .mutableContainers)
#if DEBUG
        print(json)
#endif
        Surveys.shared.load(json)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
    
    
    
    
  
  
  
  
  
  
  
  
  
  
    func reject(_ survey: Survey) {
        Task {
            do {
                try await API.shared.surveys.reject(survey: survey)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif

            }
        }
    }
    
    func loadSurveys() {
        Task {
            do {
                var parameters: [String: Any] = [:]
                let stackList = Surveys.shared.hot.map { $0.id }
              let rejectedList = Surveys.shared.all
                .filter { $0.isRejected}
                .map { $0.id }
                let list = Array(Set(stackList + rejectedList))
                if !list.isEmpty {
                    parameters["exclude_ids"] = list
                }

                let data = try await API.shared.surveys.getSurveys(type: .Hot, parameters: parameters)
                let json = try JSON(data: data, options: .mutableContainers)
#if DEBUG
                print(json)
#endif
                await MainActor.run {
                    Surveys.shared.load(json)
//                    modelOutput?.onRequestCompleted()
                }
            } catch {
                await MainActor.run {
//                    modelOutput?.onRequestCompleted()
                }
#if DEBUG
                print(error.localizedDescription)
#endif
            }
        }
    }
    
    func claim(survey: Survey, reason: Claim) {
        Task {
            try await API.shared.surveys.claim(surveyReference: survey.reference, reason: reason)
        }
    }
}
