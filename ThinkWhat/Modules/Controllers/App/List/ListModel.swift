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
    func onDataSourceRequest() {
        guard let source = modelOutput?.surveyCategory else { return }
        
        Task {
            do {
                try await API.shared.surveys.loadSurveyReferences(source)
            } catch {
                await MainActor.run {
                    modelOutput?.onError(error)
                }
            }
        }
    }
    
    // Implement methods
}
