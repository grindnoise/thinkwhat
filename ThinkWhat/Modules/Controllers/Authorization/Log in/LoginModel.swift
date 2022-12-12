//
//  _LoginModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class LoginModel {
    weak var modelOutput: LoginModelOutput?
}

// MARK: - Controller Input
extension LoginModel: LoginControllerInput {
    func performLogin(username: String, password: String) {
        Task {
            do {
                try await API.shared.auth.loginAsync(username: username, password: password)
                let userData = try await API.shared.getUserDataAsync()
#if DEBUG
                print(JSON(userData))
#endif
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: userData)
                modelOutput?.onSuccess()
            } catch {
                UserDefaults.clear()
                modelOutput?.onError(error)
            }
        }
    }
}
