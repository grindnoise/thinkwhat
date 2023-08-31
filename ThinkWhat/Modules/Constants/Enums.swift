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
  //  enum ComplaintType {
  
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
  
  enum Period: CaseIterable, RawRepresentable {
    typealias RawValue = Int
    
    case day, week, month, unlimited
    
    var rawValue: RawValue {
          switch self {
          case .day: return 0
          case .week: return 1
          case .month: return 2
          case .unlimited: return 3
          }
        }
    
    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .day
      case 1: self = .week
      case 2: self = .month
      case 4: self = .unlimited
      default: return nil
      }
    }
    
    var description: String {
      switch self {
      case .day: return "filter_per_day"
      case .week: return "filter_per_week"
      case .month: return "filter_per_month"
      case .unlimited: return "filter_per_all_time"
      }
    }
    
    var date: Date? {
      switch self {
      case .day:
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())
      case .week:
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())
      case .month:
        return Calendar.current.date(byAdding: .month, value: -1, to: Date())
      case .unlimited:
        return Calendar.current.date(byAdding: .year, value: -999, to: Date())
      }
    }
  }
  
  enum SurveyFilterMode: String, CaseIterable {
    case hot
    case new
    case own
    case favorite
    case subscriptions
    case topic
    case search
    case user
    case compatible
    case disabled // Filter is off
//    case period // Filter
//    case anonymous // Only anonymois publications
//    case discussed // Most discussed,
//    case completed // Only completed
//    case notCompleted // Only completed
    case rated // Only completed
    
    func getDataItems(topic: Topic? = nil,
                      userprofile: Userprofile? = nil,
                      compatibility: TopicCompatibility? = nil) -> [SurveyReference] {
      var allowed = Array(Set(SurveyReferences.shared.all.filter { !$0.isClaimed && !$0.isBanned && !$0.isRejected } + Surveys.shared.all.filter { $0.isNew && !$0.isClaimed && !$0.isBanned }.map { $0.reference }))
      
      switch self {
      case .hot:
        return allowed.filter { $0.isHot }
        //        let referencesFromSurveys = Surveys.shared.hot.map { $0.reference }
        //        return (SurveyReferences.shared.all.filter { $0.isHot && !$0.isClaimed && !$0.isBanned && !$0.isRejected } + referencesFromSurveys).uniqued()
      case .new:
        return allowed
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.isNew && !$0.isClaimed && !$0.isBanned }.map { $0.reference }// && $0.isRejected
//        return (SurveyReferences.shared.all.filter { $0.isNew && !$0.isClaimed && !$0.isBanned } + referencesFromSurveys).uniqued()//&& !$0.isRejected
      case .rated:
        return allowed
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.isTop && !$0.isClaimed && !$0.isBanned && !$0.isRejected }.map { $0.reference }//&& !$0.isRejected
//        return (SurveyReferences.shared.all.filter { $0.isTop && !$0.isClaimed && !$0.isBanned } + referencesFromSurveys).uniqued()
      case .own:
        return allowed.filter { $0.isOwn }
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.isOwn && !$0.isBanned }.map { $0.reference }
//        return (SurveyReferences.shared.all.filter { $0.isOwn && !$0.isBanned } + referencesFromSurveys).uniqued()
      case .favorite:
        return allowed.filter { $0.isFavorite }
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.isFavorite && !$0.isBanned }.map { $0.reference }
//        return (SurveyReferences.shared.all.filter { $0.isFavorite && !$0.isBanned } + referencesFromSurveys).uniqued()
      case .subscriptions:
        return allowed.filter { $0.owner.subscribedAt && !$0.isAnonymous }
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.owner.subscribedAt && !$0.isClaimed && !$0.isBanned && !$0.isAnonymous }.map { $0.reference }
//        return (SurveyReferences.shared.all.filter { $0.owner.subscribedAt && !$0.isClaimed && !$0.isBanned && !$0.isAnonymous } + referencesFromSurveys).uniqued()
      case .disabled:
        return allowed
//        let referencesFromSurveys = Surveys.shared.all.filter { !$0.isClaimed && !$0.isBanned }.map { $0.reference }//&& !$0.isRejected
//        return (SurveyReferences.shared.all.filter { !$0.isClaimed && !$0.isBanned } + referencesFromSurveys).uniqued()//&& !$0.isRejected
      case .topic:
        guard let topic = topic else { return [] }
        
        return allowed.filter { $0.topic == topic }
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.topic == topic && !$0.isClaimed && !$0.isBanned }.map { $0.reference }//&& !$0.isRejected
//        return (SurveyReferences.shared.all.filter { $0.topic == topic && !$0.isClaimed && !$0.isBanned } + referencesFromSurveys).uniqued()//&& !$0.isRejected
      case .user:
        guard let userprofile = userprofile else { return [] }
        
        return allowed.filter { $0.owner == userprofile && !$0.isAnonymous }
//        let referencesFromSurveys = Surveys.shared.all.filter { $0.owner == userprofile && !$0.isClaimed && !$0.isBanned && !$0.isAnonymous }.map { $0.reference }//&& !$0.isRejected
//        return (SurveyReferences.shared.all.filter { $0.owner == userprofile && !$0.isClaimed && !$0.isBanned && !$0.isAnonymous } + referencesFromSurveys).uniqued()//&& !$0.isRejected
      case .search:
        fatalError()
      case .compatible:
        guard let compatibility = compatibility else { return [] }
        
        return SurveyReferences.shared[compatibility.surveys]
//      default: return allowed
      }
    }
    
    var url: URL? {
      switch self {
      case .hot:
        return API_URLS.Surveys.hot
      case .new:
        return API_URLS.Surveys.new
      case .rated:
        return API_URLS.Surveys.top
      case .own:
        return API_URLS.Surveys.own
      case .favorite:
        return API_URLS.Surveys.favorite
      case .subscriptions:
        return API_URLS.Surveys.subscriptions
      case .disabled:
        return API_URLS.Surveys.all
      case .topic:
        return API_URLS.Surveys.byTopic
      case .search:
        return API_URLS.Surveys.search
      case .user:
        return API_URLS.Surveys.byUserprofile
      case .compatible:
        return API_URLS.Surveys.listByIds
      default:
        return API_URLS.Surveys.all
      }
    }
    var localizedDescription: String {
      switch self {
      case .subscriptions:
        return "empty_pub_view_subscriptions".localized
      case .new:
        return "empty_pub_view_new".localized
      case .rated:
        return "empty_pub_view_top".localized
      case .own:
        return "empty_pub_view_own".localized
      case .favorite:
        return "empty_pub_view_watching".localized
      default:
        return "empty_pub_view_default".localized
      }
    }
  }
  
  enum SurveyAdditionalFilterMode: Int, CaseIterable {
    case disabled // Filter is off
    case period // Filter
    case anonymous // Only anonymois publications
    case discussed // Most discussed,
    case completed // Only completed
    case notCompleted // Only completed
    case rated // Only completed
    
    func getDataItems(_ items: [SurveyReference], period: Period? = nil) -> [SurveyReference] {
      switch self {
      case .anonymous: return items.filter { $0.isAnonymous }.sorted { $0.startDate > $1.startDate }
      case .completed: return items.filter { $0.isComplete }.sorted { $0.startDate > $1.startDate }
      case .notCompleted: return items.filter { !$0.isComplete }.sorted { $0.startDate > $1.startDate }
      case .discussed: return items.sorted { $0.commentsTotal > $1.commentsTotal }
      case .disabled: return items.sorted { $0.startDate > $1.startDate }
      case .rated: return items.sorted { $0.rating > $1.rating }
      case .period:
        guard let period = period else { return items }
        
        return items.filter({ $0.isValid(byBeriod: period) }).sorted { $0.startDate > $1.startDate }
      }
    }
  }
}
