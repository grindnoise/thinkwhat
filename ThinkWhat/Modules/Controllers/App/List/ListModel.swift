//
//  ListModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class ListModel {
    
    weak var modelOutput: ListModelOutput?
}

// MARK: - Controller Input
extension ListModel: ListControllerInput {
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
    
    func onDataSourceRequest() {
        guard let source = modelOutput?.surveyCategory else { return }
        
        Task {
            do {
                try await API.shared.surveys.loadSurveyReferences(source)
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
    
    // Implement methods
}
