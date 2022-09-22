//
//  PollCreationModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class PollCreationModel {
    
    weak var modelOutput: PollCreationModelOutput?
}

// MARK: - Controller Input
extension PollCreationModel: PollCreationControllerInput {
    func post(_ dict: [String: Any]) {
        Task {
            do {
                try await API.shared.surveys.post(dict)
                await MainActor.run {
                    modelOutput?.onSuccess()
                }
            } catch {
                await MainActor.run {
                    modelOutput?.onError(error)
                }
            }
        }

    }
    
    var balance: Int {
        return Userprofiles.shared.current?.balance ?? 0
    }
    
}
