//
//  RecoverModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class RecoverModel {
    
    weak var modelOutput: RecoverModelOutput?
}

// MARK: - Controller Input
extension RecoverModel: RecoverControllerInput {
    func sendEmail(_ email: String) {
        Task {
            do {
                try await API.shared.system.sendPasswordResetLink(email)
                await modelOutput?.onEmailSent(.success(true))
            } catch {
#if DEBUG
                print(error.localizedDescription)
#endif
                await modelOutput?.onEmailSent(.failure(error))
            }
        }
    }
}
