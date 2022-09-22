//
//  SubscribersModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

class SubscribersModel {
    
    weak var modelOutput: SubscribersModelOutput?
}

// MARK: - Controller Input
extension SubscribersModel: SubscribersControllerInput {
    func loadSubscriptions() {
        Task {
            do {
                try await API.shared.profiles.getSubscriptions(for: Userprofiles.shared.current!)
            } catch {
#if DEBUG
                    print(error)
#endif
                await MainActor.run {
                    modelOutput?.onAPIError()
                }
            }
        }
    }
    
    func loadSubscribers() {
        Task {
            do {
                try await API.shared.profiles.getSubscribers(for: Userprofiles.shared.current!)
            } catch {
#if DEBUG
                    print(error)
#endif
                await MainActor.run {
                    modelOutput?.onAPIError()
                }
            }
        }
    }
    
    func unsubscribe(_ userprofiles: [Userprofile]) {
        Task {
            do {
                try await API.shared.profiles.unsubscribe(userprofiles)
            } catch {
#if DEBUG
                    print(error)
#endif
                await MainActor.run {
                    modelOutput?.onAPIError()
                }
            }
        }
    }
    
    var userprofiles: [Userprofile] {
        return []//modelOutput?.mode == .Subscriptions ? Userprofiles.shared.subscribedFor : Userprofiles.shared.subscribers
    }
}
