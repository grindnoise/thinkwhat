//
//  SignInModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

class SignInModel {
  
  weak var modelOutput: SignInModelOutput?
}

extension SignInModel: SignInControllerInput {
  func providerlogin(_ provider: AuthProvider) {
    
  }
  
  func mailLogin(username: String, password: String) {
    Task {
      do {
        try await API.shared.auth.loginAsync(username: username, password: password)
        let userData = try await API.shared.getUserDataAsync()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: userData)
        modelOutput?.loginCallback(.success(true))
      } catch {
        UserDefaults.clear()
        modelOutput?.loginCallback(.failure(error))
      }
    }
  }
}
