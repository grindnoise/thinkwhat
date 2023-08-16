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
//    func removeSubscribers(_ userprofiles: [Userprofile]) {
//        Task {
//            do {
//                try await API.shared.profiles.removeSubscribers(userprofiles)
//            } catch {
//#if DEBUG
//                error.printLocalized(class: type(of: self), functionName: #function)
//#endif
//            }
//        }
//    }
    
    func subscribe(at userprofiles: [Userprofile]) {
        Task {
            do {
                try await API.shared.profiles.subscribe(at: userprofiles)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    func unsubscribe(from userprofiles: [Userprofile]) {
        Task {
            do {
                try await API.shared.profiles.unsubscribe(from: userprofiles)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    func loadVoters(for answer: Answer) {
        Task {
            do {
                try await API.shared.surveys.getVoters(for: answer)
            } catch {
#if DEBUG
                error.printLocalized(class: type(of: self), functionName: #function)
#endif
            }
        }
    }
    
    
  func loadUsers(for userprofile: Userprofile, mode: Enums.UserprofilesViewMode) {
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
