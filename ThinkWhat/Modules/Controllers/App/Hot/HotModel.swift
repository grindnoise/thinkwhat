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
  ///**Logic**
  private let minimumThreshold = 30
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
        try Surveys.shared.load(json)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func updateData() {
    guard let modelOutput = modelOutput else { return }
    
    Task { [weak self] in
      guard let self = self else { return }
      
      do {
        try await API.shared.surveys.updateSurveyStats(modelOutput.queue.elements.map { $0.reference } + [modelOutput.currentSurvey].reduce(into: [SurveyReference]()) { result, next in
          guard let instance = next?.reference else { return }
          
          result.append(instance)
        })
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        
      }
    }
  }
  
  func reject(_ survey: Survey) {
    guard let modelOutput = modelOutput else { return }
    
    Task {
      do {
        try await API.shared.surveys.reject(survey: survey,
                                            requestHotExcept: modelOutput.queue.length <= minimumThreshold ? modelOutput.queue.elements : [])
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
          try? Surveys.shared.load(json)
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
  
  func claim(_ dict: [SurveyReference: Claim]) {
    guard let instance = dict.keys.first,
          let reason = dict.values.first,
          let modelOutput = modelOutput
    else { return }
    
    Task {
      try await API.shared.surveys.claim(surveyReference: instance,
                                         reason: reason,
                                         requestHotExcept: modelOutput.queue.length <= minimumThreshold ? modelOutput.queue.elements : [])
    }
  }
}
