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
                let rejectedList = Surveys.shared.rejected.map { $0.id }
                let list = Array(Set(stackList + rejectedList))
                if !list.isEmpty {
                    parameters["ids"] = list
                }
//                let data = try await API.shared.downloadSurveysAsync(type: .Hot, parameters: parameters)
                let data = try await API.shared.surveys.loadSurveys(type: .Hot, parameters: parameters)
                let json = try JSON(data: data, options: .mutableContainers)
#if DEBUG
                print(json)
#endif
                await MainActor.run {
                    Surveys.shared.load(json)
                    modelOutput?.onRequestCompleted()
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onRequestCompleted()
                }
#if DEBUG
                print(error.localizedDescription)
#endif
            }
        }
    }
    
    func claim(survey: Survey, reason: Claim) {
        Task {
            let json = try await API.shared.surveys.claim(survey: survey, reason: reason)
            guard let value = json["status"].string else { throw "Unknown error" }
            guard value == "ok" else {
                guard let error = json["error"].string else { throw "Unknown error" }
                await MainActor.run {
                    modelOutput?.onClaimCallback(.failure(error))
                }
                return
            }
            await MainActor.run {
                modelOutput?.onClaimCallback(.success(true))
            }
        }
    }
}
