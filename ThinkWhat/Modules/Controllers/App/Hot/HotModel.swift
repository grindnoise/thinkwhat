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
                let data = try await API.shared.downloadSurveysAsync(type: .Hot, parameters: parameters)
                let json = try JSON(data: data, options: .mutableContainers)
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
}
