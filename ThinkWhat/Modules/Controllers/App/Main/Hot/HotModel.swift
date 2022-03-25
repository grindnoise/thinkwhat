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
                let data = try await API.shared.downloadSurveysAsync(type: .Hot)
                let json = try JSON(data: data, options: .mutableContainers)
                print(json)
                await MainActor.run {
                    Surveys.shared.load(json)
                }
            } catch {
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
}
