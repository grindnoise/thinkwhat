//
//  AppEnums.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit

struct Enums {
  enum EditingMode { case ReadOnly, Write }
  
  /// Used to detect primary/repeating tap on tab bar item
  enum TabBarTapMode { case Primary, Repeat }
  
  /// Open side app or embedded html
  enum SideAppPreference: String {
    case Embedded = "embedded"
    case App = "app"
  }
  
  enum ImageType: String {
    case Profile = "profile"
    case Survey  = "survey"
  }
  
  enum Language: String {
    case English = "English"
    case Russian = "Русский"
  }
  
  enum FileFormat: String, CaseIterable {
    case PNG        = "png"
    case JPEG       = "jpg"
    case TIFF       = "tiff"
    case GIF        = "gif"
    case Unknown    = "thinkwhat"
    
    static func fromString(_ string: String) -> Self {
      for value in Self.allCases {
        guard string.lowercased() == value.rawValue else { continue }
        return value
      }
      return .Unknown
    }
  }
  
  enum EnabledState {
    case enabled, disabled
  }
  
  //enum TokenState {
  //    case Received
  //    case Error
  //    case Unassigned
  //    case WrongCredentials
  //    case Expired
  //    case Revoked
  //    case ConnectionError
  //    case AccessDenied
  //}
  
  enum ApiReachabilityState {
    case Reachable, None
  }
  
  enum SessionType: String {
    case authorized     = "authorized"
    case unauthorized   = "unauthorized"
  }
  
  enum Gender: String, CaseIterable {
    case Male           = "Male"
    case Female         = "Female"
    case Unassigned     = "all_genders"
  }
  
  enum InternetConnection {
    case Available
    case None
  }
  
  enum AuthProvider: String {
    case VK         = "vk-oauth2"
    case Facebook   = "Facebook"
    case Apple      = "apple"
    case Google     = "google-oauth2"
    case Phone      = "Phone"
    case Mail       = "Mail"
    case Username   = "Username"
  }
  
  enum SocialMedia: String {
    case VK, Facebook, TikTok, Instagram, Twitter
  }
  
  enum ThirdPartyApp: String {
    case TikTok     = "TikTok"
    case Youtube    = "Youtube"
    case Null       = ""
    
    func logo() -> UIView {
      var instance = UIView()
      switch self {
      case .Youtube:
        instance = YoutubeLogo()
      case .TikTok:
        instance = TikTokLogo()
      default:
        return UIView()
      }
      instance.isOpaque = false
      
      return instance
    }
  }
  
  enum ClientSettingsMode {
    case Reminder, Language
  }
  
  //Tab bar items
  enum Tab {
    case Hot, Subscriptions, Feed, Topics, Settings
  }
  
  enum PushNotificationsLanguagesSettings: Hashable {
    case notifications(Notifications)
    case languages(Languages)
    
    enum Notifications: String {
      //            case Allow = "allow_push_notifications"
      case Completed = "NOTIFICATIONS_OWN_COMPLETED"
      case Subscriptions = "NOTIFICATIONS_NEW_SUBSCRIPTIONS"
      case Watchlist = "NOTIFICATIONS_WATCHLIST_COMPLETED"
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
  
  enum UserprofilesViewMode: String {
    case Subscribers, Subscriptions, Voters
  }
  
  enum Period: String {
    //    case PerDay     = "per_day"
    //    case PerWeek    = "per_week"
    //    case PerMonth   = "per_month"
    //    case AllTime    = "all_time"
    case PerDay     = "day"
    case PerWeek    = "week"
    case PerMonth   = "month"
    case AllTime    = "all_time"
    
    func date() -> Date? {
      switch self {
      case .PerDay:
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())
      case .PerWeek:
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())
      case .PerMonth:
        return Calendar.current.date(byAdding: .month, value: -1, to: Date())
      case .AllTime:
        return Calendar.current.date(byAdding: .year, value: -999, to: Date())
      }
    }
  }
}
