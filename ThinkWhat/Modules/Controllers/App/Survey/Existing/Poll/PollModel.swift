//
//  PollModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class PollModel {
    
    weak var modelOutput: PollModelOutput?
}

// MARK: - Controller Input
extension PollModel: PollControllerInput {
    var survey: Survey? {
        return modelOutput?.survey
    }
    
    func claim() {
        
    }
    
    func loadSurvey() {
        
    }
    
    func addFavorite(_ mark: Bool) {
        guard !survey.isNil else { modelOutput?.onAddFavorite(.failure("Survey is nil")); return }
        
        Task {
            do {
                let data = try await API.shared.markFavoriteAsync(mark: mark, surveyReference: survey!.reference)
                let json = try JSON(data: data, options: .mutableContainers)
                guard let value = json["status"].string else { throw "Unknown error" }
                guard value == "ok" else {
                    guard let error = json["error"].string else { throw "Unknown error" }
                    await MainActor.run {
                        modelOutput?.onAddFavorite(.failure(error))
                    }
                    return
                }
                await MainActor.run {
                    modelOutput?.onAddFavorite(.success(true))
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onAddFavorite(.failure(error))
                }
            }
            
        }
    }
}
