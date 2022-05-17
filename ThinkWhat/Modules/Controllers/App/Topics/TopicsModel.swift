//
//  TopicsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class TopicsModel {
    
    weak var modelOutput: TopicsModelOutput?
}

// MARK: - Controller Input
extension TopicsModel: TopicsControllerInput {
    func search(substring: String, excludedIds: [Int] = []) {
        Task {
            do {
                let instances = try await API.shared.surveys.search(substring: substring, excludedIds: excludedIds)
                await MainActor.run {
                    modelOutput?.onSearchCompleted(instances)
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onError(error)
                }
            }
        }
    }
    
    func onDataSourceRequest(_ topic: Topic) {
        Task {
            do {
                try await API.shared.surveys.loadSurveyReferences(.Topic, topic)
            } catch {
                await MainActor.run {
                    modelOutput?.onError(error)
                }
            }
        }
    }
}
