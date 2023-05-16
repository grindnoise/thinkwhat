//
//  PasswordResetModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class PasswordResetModel {
  
  weak var modelOutput: PasswordResetModelOutput?
}

extension PasswordResetModel: PasswordResetControllerInput {
  func sendResetLink(_ mail: String) {
    Task {
      do {
        try await API.shared.system.sendPasswordResetLink(mail)
        
        await MainActor.run { modelOutput?.callback(.success(true)) }
      } catch {
#if DEBUG
        print(error.localizedDescription)
#endif
        await MainActor.run { modelOutput?.callback(.failure(error)) }
      }
    }
  }
}
