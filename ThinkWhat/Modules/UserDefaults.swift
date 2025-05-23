//
//  UserDefaults.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

extension UserDefaults {
  
  struct Profile {
    @UserDefault(key: "id", defaultValue: nil)
    static var id: Int?
    
    @UserDefault(key: "first_name", defaultValue: nil)
    static var firstName: String?
    
    @UserDefault(key: "last_name", defaultValue: nil)
    static var lastName: String?
    
    @UserDefault(key: "username", defaultValue: nil)
    static var username: String?
    
    @UserDefault(key: "pseudonym", defaultValue: nil)
    static var pseudonym: String?
    
    @UserDefault(key: "email", defaultValue: nil)
    static var email: String?
    
    //    @UserDefault(key: "city", defaultValue: "")
    //    static var city: String {
    //      didSet {
    //        print(city)
    //      }
    //    }
    
    @UserDefault(key: "cityId", defaultValue: nil)
    static var cityId: Int?
    
    @UserDefault(key: "image_path", defaultValue: nil)
    static var imagePath: String?
    
    @UserDefault(key: "birth_date", defaultValue: nil)
    static var birthDate: Date?
    
    @UserDefault(key: "date_joined", defaultValue: nil)
    static var dateJoined: Date?
    
    static var gender: Enums.User.Gender? {
      set { _gender = newValue?.rawValue }
      get { return Enums.User.Gender(rawValue: _gender ?? "") }
    }
    @UserDefault(key: "gender", defaultValue: nil)
    private static var _gender: String?
    
    @UserDefault(key: "was_edited", defaultValue: nil)
    static var wasEdited: Bool?
    
    @UserDefault(key: "is_banned", defaultValue: nil)
    static var isBanned: Bool?
    
    static var imageURL: URL? {
      set { _imageURL = newValue?.absoluteString }
      get { return URL(string: _imageURL ?? "") }
    }
    @UserDefault(key: "imageURL", defaultValue: nil)
    private static var _imageURL: String?
    
    static var instagramURL: URL? {
      set { _instagramURL = newValue?.absoluteString }
      get { return URL(string: _instagramURL ?? "") }
    }
    @UserDefault(key: "instagramURL", defaultValue: nil)
    static var _instagramURL: String?
    
    static var tiktokURL: URL? {
      set { _tiktokURL = newValue?.absoluteString }
      get { return URL(string: _tiktokURL ?? "") }
    }
    @UserDefault(key: "tiktokURL", defaultValue: nil)
    static var _tiktokURL: String?
    
    static var vkURL: URL? {
      set { _vkURL = newValue?.absoluteString }
      get { return URL(string: _vkURL ?? "") }
    }
    @UserDefault(key: "vkURL", defaultValue: nil)
    static var _vkURL: String?
    
    static var facebookURL: URL? {
      set { _facebookURL = newValue?.absoluteString }
      get { return URL(string: _facebookURL ?? "") }
    }
    @UserDefault(key: "facebookURL", defaultValue: nil)
    static var _facebookURL: String?
    
    static func clear() {
      UserDefaults.Profile.id             = nil
      UserDefaults.Profile.firstName      = nil
      UserDefaults.Profile.lastName       = nil
//      UserDefaults.Profile.city           = ""
      UserDefaults.Profile.cityId         = nil
                  UserDefaults.Profile.username       = nil
      UserDefaults.Profile.email          = nil
      UserDefaults.Profile.birthDate      = nil
      UserDefaults.Profile.dateJoined      = nil
      UserDefaults.Profile.gender         = nil
      UserDefaults.Profile.wasEdited      = nil
      UserDefaults.Profile.isBanned       = nil
      UserDefaults.Profile.imageURL       = nil
      UserDefaults.Profile.instagramURL   = nil
      UserDefaults.Profile.tiktokURL      = nil
      UserDefaults.Profile.vkURL          = nil
      UserDefaults.Profile.facebookURL    = nil
      UserDefaults.Profile.pseudonym = nil
      if imagePath != nil {
        try? FileIOController.delete(dataPath: imagePath!)
        imagePath = nil
      }
    }
    
    static func authorize() throws {
      guard let accessToken = KeychainService.loadAccessToken() as? String, !accessToken.isEmpty,
            let user = Userprofile.init() else {
        throw ""
      }
      Userprofiles.shared.current = user
    }
    
    //        func load(from json: JSON) {
    //            UserDefaults.Profile.id             = json["id"].int ?? UserDefaults.Profile.id
    //            UserDefaults.Profile.firstName      = json["first_name"].string ?? UserDefaults.Profile.firstName
    //            UserDefaults.Profile.lastName       = json["last_name"].string ?? UserDefaults.Profile.lastName
    //            UserDefaults.Profile.email          = json["email"].string ?? UserDefaults.Profile.email
    //            UserDefaults.Profile.username       = json["username"].string ?? UserDefaults.Profile.username
    //
    //            UserDefaults.Profile.birthDate      = json["birth_date"].da ?? UserDefaults.Profile.birthDate
    //            UserDefaults.Profile.gender         = Gender(rawValue: json["gender"].string ?? "") ?? UserDefaults.Profile.gender
    //            UserDefaults.Profile.wasEdited      = json["is_edited"].bool ?? UserDefaults.Profile.wasEdited
    //            UserDefaults.Profile.isBanned       = json["is_banned"].bool ?? UserDefaults.Profile.isBanned
    //            UserDefaults.Profile.imageURL       = URL(string: json["image"].string ?? "") ?? UserDefaults.Profile.imageURL
    //            UserDefaults.Profile.instagramURL   = URL(string: json["instagram_url"].string ?? "") ?? UserDefaults.Profile.instagramURL
    //            UserDefaults.Profile.tiktokURL      = URL(string: json["tiktok_url"].string ?? "") ?? UserDefaults.Profile.tiktokURL
    //            UserDefaults.Profile.vkURL          = URL(string: json["vk_url"].string ?? "") ?? UserDefaults.Profile.vkURL
    //            UserDefaults.Profile.facebookURL    = URL(string: json["facebook_url"].string ?? "") ?? UserDefaults.Profile.facebookURL
    //        }
    
    static func importData(from profile: Userprofile) {
      UserDefaults.Profile.id             = profile.id
      UserDefaults.Profile.firstName      = profile.firstName
      UserDefaults.Profile.lastName       = profile.lastName
      UserDefaults.Profile.email          = profile.email
//      UserDefaults.Profile.city           = profile.cityTitle
      UserDefaults.Profile.cityId         = profile.cityId
      UserDefaults.Profile.birthDate      = profile.birthDate
                  UserDefaults.Profile.username       = profile.username
      UserDefaults.Profile.gender         = profile.gender
      UserDefaults.Profile.wasEdited      = profile.wasEdited
      UserDefaults.Profile.isBanned       = profile.isBanned
      UserDefaults.Profile.imageURL       = profile.imageURL
      UserDefaults.Profile.instagramURL   = profile.instagramURL
      UserDefaults.Profile.tiktokURL      = profile.tiktokURL
      UserDefaults.Profile.vkURL          = profile.vkURL
      UserDefaults.Profile.facebookURL    = profile.facebookURL
      //          UserDefaults.Profile.pseudonym    = profile.facebookURL
    }
    
  }
  
  struct App {
    @UserDefault(key: "content_languages", defaultValue: [])
    static var contentLanguages: [String] {
      didSet {
        guard oldValue != contentLanguages else { return }
        
        NotificationCenter.default.post(name: Notifications.System.ContentLanguage, object: contentLanguages)
      }
    }
    
    @UserDefault(key: "NOTIFICATIONS_OWN_COMPLETED", defaultValue: false)
    static var notifyOnOwnCompleted: Bool? {
      didSet {
        print("notifyOnOwnCompleted", notifyOnOwnCompleted)
      }
    }
    
    @UserDefault(key: "NOTIFICATIONS_WATCHLIST_COMPLETED", defaultValue: false)
    static var notifyOnWatchlistCompleted: Bool? {
      didSet {
        print("notifyOnWatchlistCompleted", notifyOnWatchlistCompleted)
      }
    }
    
    @UserDefault(key: "NOTIFICATIONS_NEW_SUBSCRIPTIONS", defaultValue: false)
    static var notifyOnNewSubscription: Bool? {
      didSet {
        print("notifyOnNewSubscription", notifyOnWatchlistCompleted)
      }
    }
    
    @UserDefault(key: "has_seen_app_introduction", defaultValue: false)
    static var hasSeenAppIntroduction: Bool?
    
    @UserDefault(key: "has_seen_poll_introduction", defaultValue: false)
    static var hasSeenPollIntroduction: Bool?
    
    @UserDefault(key: "has_seen_poll_vote_introduction", defaultValue: false)
    static var hasSeenPollVoteIntroduction: Bool?
    
    @UserDefault(key: "has_read_terms_of_use", defaultValue: false)
    static var hasReadTermsOfUse: Bool
    
    @UserDefault(key: "min_api_version", defaultValue: 0.3)
    static var minAPIVersion: Double?
    
//    @UserDefault(key: "country_by_ip", defaultValue: nil)
//    static var countryByIP: String?
    
    static var youtubePlay: Enums.SideAppPreference? {
      set { _youtubePlay = newValue?.rawValue }
      get { return Enums.SideAppPreference(rawValue: _youtubePlay ?? "") }
    }
    @UserDefault(key: "youtube_play", defaultValue: nil)
    private static var _youtubePlay: String?
    
    static var tiktokPlay: Enums.SideAppPreference? {
      set { _tiktokPlay = newValue?.rawValue }
      get { return Enums.SideAppPreference(rawValue: _tiktokPlay ?? "") }
    }
    @UserDefault(key: "tiktok_play", defaultValue: nil)
    private static var _tiktokPlay: String?
    
    @UserDefault(key: "has_seen_poll_creation_introduction", defaultValue: false)
    static var hasSeenPollCreationIntroduction: Bool
    
    static func clear() {
      UserDefaults.App.hasReadTermsOfUse                  = false
      UserDefaults.App.hasSeenPollIntroduction            = nil
      UserDefaults.App.hasSeenPollVoteIntroduction        = nil
      UserDefaults.App.hasSeenAppIntroduction             = nil
      UserDefaults.App.minAPIVersion                      = nil
//      UserDefaults.App.countryByIP                        = nil
      UserDefaults.App.youtubePlay                        = nil
      UserDefaults.App.tiktokPlay                         = nil
      UserDefaults.App.hasSeenPollCreationIntroduction    = false
      UserDefaults.App.notifyOnOwnCompleted               = nil
      UserDefaults.App.notifyOnWatchlistCompleted         = nil
      UserDefaults.App.notifyOnNewSubscription            = nil
      UserDefaults.App.contentLanguages                   = []
    }
  }
  
  static func clear() {
    App.clear()
    Profile.clear()
//    KeychainService.saveAccessToken(token: "")
//    KeychainService.saveRefreshToken(token: "")
//    KeychainService.saveTokenExpireDateTime(token: "")
#if DEBUG
    print("UserDefaults.cleaned()")
#endif
  }
}

import Combine

@propertyWrapper
struct UserDefault<Value> {
  let key: String
  let defaultValue: Value
  var container: UserDefaults = .standard
  private let publisher = PassthroughSubject<Value, Never>()
  
  var wrappedValue: Value {
    get {
      return container.object(forKey: key) as? Value ?? defaultValue
    }
    set {
      // Check whether we're dealing with an optional and remove the object if the new value is nil.
      if let optional = newValue as? AnyOptional, optional.isNil {
        container.removeObject(forKey: key)
      } else {
        container.set(newValue, forKey: key)
      }
      publisher.send(newValue)
    }
  }
  
  var projectedValue: AnyPublisher<Value, Never> {
    return publisher.eraseToAnyPublisher()
  }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
  
  /// Creates a new User Defaults property wrapper for the given key.
  /// - Parameters:
  ///   - key: The key to use with the user defaults store.
  init(key: String, _ container: UserDefaults = .standard) {
    self.init(key: key, defaultValue: nil, container: container)
  }
}
