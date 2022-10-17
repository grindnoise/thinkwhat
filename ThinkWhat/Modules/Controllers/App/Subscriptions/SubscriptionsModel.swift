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
    func claim(surveyReference: SurveyReference, claim: Claim) {
        Task {
            try await API.shared.surveys.claim(surveyReference: surveyReference, reason: claim)
        }
    }
    
    func addFavorite(surveyReference: SurveyReference) {
        Task {
            try await API.shared.surveys.markFavoriteAsync(mark: !surveyReference.isFavorite, surveyReference: surveyReference)
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
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?, userprofile: Userprofile?) {
        Task {
            do {
                try await API.shared.surveys.loadSurveyReferences(source, topic, userprofile)
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
