//
//  UserprofilesModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class UserprofilesModel {
    
    weak var modelOutput: UserprofilesModelOutput?
}

// MARK: - Controller Input
extension UserprofilesModel: UserprofilesControllerInput {
    
    func loadUsers(for userprofile: Userprofile, mode: UserprofilesController.Mode) {
        Task {
            do {
                switch mode {
                case .Subscribers:
                    try await API.shared.profiles.getSubscribers(for: userprofile)
                case .Subscriptions:
                    try await API.shared.profiles.getSubscriptions(for: userprofile)
                case .Voters:
                    print("")
                }
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
}
