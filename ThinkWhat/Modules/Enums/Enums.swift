//
//  AppEnums.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

//Tab bar items
enum Tab {
    case Hot, Subscriptions, Feed, Topics, Settings
}

enum AppSettings: Hashable {
    case notifications(Notifications)
    case languages(Languages)
    
    enum Notifications: String {
//            case Allow = "allow_push_notifications"
        case Completed = "NOTIFICATIONS_OWN_COMPLETED"
        case Subscriptions = "NOTIFICATIONS_WATCHLIST_COMPLETED"
        case Watchlist = "NOTIFICATIONS_NEW_SUBSCRIPTIONS"
    }
    
    enum Languages: String {
        case App = "default_locale"
        case Content = "locales"
    }

    public var identifier: String {
        switch self {
        case .notifications(.Completed):
            return Notifications.Completed.rawValue
        case .notifications(.Subscriptions):
            return Notifications.Subscriptions.rawValue
        case .notifications(.Watchlist):
            return Notifications.Watchlist.rawValue
        case .languages(.App):
            return Languages.App.rawValue
        case .languages(.Content):
            return Languages.Content.rawValue
        }
    }
}

//struct AppSettings: Hashable {
//    struct Notifications: Hashable {
//        static let Completed = "NOTIFICATIONS_OWN_COMPLETED"
//        static let Subscriptions = "NOTIFICATIONS_WATCHLIST_COMPLETED"
//        static let Watchlist = "NOTIFICATIONS_NEW_SUBSCRIPTIONS"
//    }
//}
enum ButtonState: String {
    case Send = "sendButton"
    case Sending = "sending"
    case Close = "continueButton"
    case Back = "back"
}
