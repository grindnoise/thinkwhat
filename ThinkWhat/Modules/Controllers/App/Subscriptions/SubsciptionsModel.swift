//
//  SubsciptionsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class SubsciptionsModel {
    
    weak var modelOutput: SubsciptionsModelOutput?
}

// MARK: - Controller Input
extension SubsciptionsModel: SubsciptionsControllerInput {
    func loadSubscriptions() {
        Task {
            do {
                try await API.shared.surveys.loadSubscriptions()
            } catch {
                await MainActor.run {
                    modelOutput?.onError(error)
                }
            }
        }
    }
    
    var userprofiles: [Userprofile] {
        return Array(Userprofiles.shared.subscribedFor.prefix(upTo: min(Userprofiles.shared.subscribedFor.count, 10)))
    }
}
