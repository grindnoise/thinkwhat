//
//  UserprofileModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class UserprofileModel {
    
    weak var modelOutput: UserprofileModelOutput?
}

// MARK: - Controller Input
extension UserprofileModel: UserprofileControllerInput {
    func unsubscribe(from userprofile: Userprofile) {
        Task {
            try await API.shared.profiles.unsubscribe(from: [userprofile])
        }
    }
    
    func subscribe(to userprofile: Userprofile) {
        Task {
            try await API.shared.profiles.subscribe(at: [userprofile])
        }
    }
    
    func switchNotifications(userprofile: Userprofile, notify: Bool) {
        Task {
            do {
                try await API.shared.profiles.switchNotifications(userprofile: userprofile, notify: notify)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
}
