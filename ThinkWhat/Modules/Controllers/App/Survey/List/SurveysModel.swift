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
    
    
    
    func claim(surveyReference: SurveyReference, claim: Claim) {
        Task {
            try await API.shared.surveys.claim(surveyReference: surveyReference, reason: claim)
        }
    }
    
    func addFavorite(surveyReference: SurveyReference) {
        Task {
            do {
                let data = try await API.shared.surveys.markFavoriteAsync(mark: !surveyReference.isFavorite, surveyReference: surveyReference)
                let json = try JSON(data: data, options: .mutableContainers)
                guard let value = json["status"].string else { throw "Unknown error" }
                guard value == "ok" else {
                    guard let error = json["error"].string else { throw "Unknown error" }
#if DEBUG
                    error.printLocalized(class: type(of: self), functionName: #function)
#endif
                    return
                }
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
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
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?) {
#if DEBUG
        print("onDataSourceRequest")
#endif
        Task {
            do {
                try await API.shared.surveys.loadSurveyReferences(source, topic)
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
