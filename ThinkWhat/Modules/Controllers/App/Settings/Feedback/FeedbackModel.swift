//
//  FeedbackModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class FeedbackModel {
    
    weak var modelOutput: FeedbackModelOutput?
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
}

extension FeedbackModel: FeedbackControllerInput {
    func sendFeedback(_ description: String) {
        Task {
            try await API.shared.profiles.feedback(description: description)
        }
    }
}
