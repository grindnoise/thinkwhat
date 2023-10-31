//
//  UserProfile.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Combine

class Userprofiles {
  
  private var shouldImportUserDefaults = false
  static let shared = Userprofiles()
  private init() {
    shouldImportUserDefaults = true
  }
  
  var all: [Userprofile] = [] {
    didSet {
      guard !oldValue.isEmpty else {
        instancesPublisher.send(all)
        return
      }
      
      let existingSet = Set(oldValue)
      let appendingSet = Set(all)
      
      ///Difference
      instancesPublisher.send(Array(appendingSet.subtracting(existingSet)))
    }
  }
  var current: Userprofile? {
    didSet {
      guard let current = current, shouldImportUserDefaults else { return }
      
      UserDefaults.Profile.importData(from: current)
      if current.imageURL.isNil {
        current.image = UIImage(systemName: "person.fill")
      }
      
      // Register device
      guard current != oldValue, let token = PushNotifications.loadToken() else { return }
      
      Task.detached() {
        await API.shared.system.registerDevice(token: token)
      }
    }
  }
  ///**Publishers**
  public let unsubscribedPublisher = PassthroughSubject<Userprofile, Never>()
  public let instancesPublisher = PassthroughSubject<[Userprofile], Never>()
  public let newSubscriptionPublisher = PassthroughSubject<Userprofile, Never>()
  public let removeSubscriptionPublisher = PassthroughSubject<Userprofile, Never>()
  public let subscriptionFailure = PassthroughSubject<Userprofile, Never>()
  
  class func updateUserData(_ json: JSON) throws {
    guard let current = Userprofiles.shared.current,
          let data = try? json["userprofile"].rawData(),
//          let subscriptionsTotal = json["subscribed_at_count"].int,
//          let publicationsTotal = json["own_surveys_count"].int,
//          let favoritesTotal = json["favorite_surveys_count"].int,
//          let completeTotal = json["completed_surveys_count"].int,
//          let votesReceivedTotal = json["votes_received_count"].int,
//          let commentsTotal = json["comments_count"].int,
//            let commentsReceivedTotal = json["comments_received_count"].int,
          let balance = json["balance"].int,
//          let top_preferences = json["top_preferences"] as? JSON,
//          let city = try json["city"].rawData() as? Data,
//          let isBanned = json["is_banned"].bool,
          let locales = json["locales"].arrayObject as? [String]
//          let description = json["description"].string
    else { return }
    
    let instance = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self, from: data)
    Userprofiles.shared.current?.update(from: instance)
//    current.description = description
//    current.subscribersTotal = subscribersTotal
//    current.subscriptionsTotal = subscriptionsTotal
//    current.publicationsTotal = publicationsTotal
//    current.favoritesTotal = favoritesTotal
//    current.completeTotal = completeTotal
    current.balance = balance
//    current.isBanned = isBanned
//    current.updatePreferences(top_preferences)
    UserDefaults.App.contentLanguages = locales
  
    var decoder: JSONDecoder!
    guard let subscriptionsData = try? json["subscriptions"].rawData(),
          let subscribersData = try? json["subscribers"].rawData()
    else { return }
    
    do {
      decoder = JSONDecoder.withDateTimeDecodingStrategyFormatters()
      let subscriptions = try decoder.decode([Userprofile].self, from: subscriptionsData)
      let subscribers = try decoder.decode([Userprofile].self, from: subscribersData)
      shared.append((subscriptions + subscribers).uniqued())
    } catch {
      throw AppError.server
    }
////
//    guard let city = try json["city"].rawData() as? Data else { return }
////
//    current.city = try decoder.decode(City.self, from: city)
  }
  
  class func clear() {
    shared.all.removeAll()
    shared.current = nil
  }
  
  struct Validators {
    /// Checks birth date validity
    /// - Parameter date: date to check
    /// - Returns: is correct
    static func checkBirthDate(_ date: Date) -> Bool {
      date.get(.year) != 1900
    }
  }

  //    func loadSubscribedFor(_ data: Data) {
  //        let decoder                                 = JSONDecoder()
  ////        var notifications: [NSNotification.Name]    = []
  //        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
  //                                                   DateFormatter.dateTimeFormatter,
  //                                                   DateFormatter.dateFormatter ]
  //        do {
  //            let instances = try decoder.decode([Userprofile].self, from: data)
  //            for instance in instances {
  //                if subscribedFor.filter({ $0.hashValue == instance.hashValue }).isEmpty {
  //                    subscribedFor.append(Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
  ////                    notifications.append(Notifications.Userprofiles.SubscribedForUpdated)
  //                }
  //            }
  ////            Notification.send(names: notifications.uniqued())
  //        } catch {
  //            fatalError(error.localizedDescription)
  //        }
  //    }
  //
  //    public func addSubscriber(_ userprofile: Userprofile) {
  //        if subscribers.filter({ $0.hashValue == userprofile.hashValue }).isEmpty {
  //            subscribers.append(userprofile)
  //        }
  //    }
  func append(_ instances: [Userprofile]) {
    guard !instances.isEmpty else {
      instancesPublisher.send([]);
      return
    }
    
    guard !all.isEmpty else { all.append(contentsOf: instances); return }
    
    let existingSet = Set(all)
    let appendingSet = Set(replaceWithExisting(all, instances))
    let difference = Array(appendingSet.subtracting(existingSet))
    
    guard !difference.isEmpty else { return }
    
    all.append(contentsOf: difference)
  }
  
  public func eraseData() {
    current = nil
    all.removeAll()
    //        subscribers.removeAll()
    //        subscribedFor.removeAll()
  }
}

class Userprofile: Decodable {
  static let anonymous: Userprofile = {
    let instance = Userprofile()
    instance!.image = UIImage(named: "anon")
    instance!.firstName = ""
    instance!.lastName = ""
    instance!.id = 1010000110010011
    instance!.gender = .Unassigned
    instance!.cityTitle = ""
    instance!.email = ""
    instance!.imageURL = nil
    instance!.vkURL = nil
    instance!.instagramURL = nil
    instance!.facebookURL = nil
    instance!.dateJoined = Date()
    return instance!
  }()
  
  private enum CodingKeys: String, CodingKey {
    case id, age, gender, email, username, city, description,
         isBanned                 = "is_banned",
         birthDate                = "birth_date",
         firstName                = "first_name",
         dateJoined               = "date_joined",
         lastName                 = "last_name",
         imageURL                 = "image",
         instagramURL             = "instagram_url",
         tiktokURL                = "tiktok_url",
         vkURL                    = "vk_url",
         facebookURL              = "facebook_url",
         completeTotal            = "completed_surveys_count",
         votesReceivedTotal       = "votes_received_count",
         commentsTotal            = "comments_count",
         commentsReceivedTotal    = "comments_received_count",
         favoritesTotal           = "favorite_surveys_count",
         publicationsTotal        = "own_surveys_count",
         subscribersTotal         = "subscribers_count",
         subscriptionsTotal       = "subscribed_at_count",
         lastVisit                = "last_visit",
         topPublicationCategories = "top_pub_categories",
         wasEdited                = "is_edited",
         balance                  = "credit",
         subscribers              = "subscribers",
         subscriptions            = "subscriptions",
         subscribedAt             = "subscribed_at",
         subscribedToMe           = "subscribed_to_me",
         notifyOnPublication      = "notify_on_publication"
  }
  enum UserSurveyType {
    case Own, Favorite
  }
  
  var id:                 Int
  var username:           String
  @Published var firstName: String {
    didSet {
      guard oldValue != firstName else { return }
      NotificationCenter.default.post(name: Notifications.Userprofiles.FirstNameChanged, object: self)
    }
  }
  @Published var lastName: String {
    didSet {
      guard oldValue != lastName else { return }
      NotificationCenter.default.post(name: Notifications.Userprofiles.LastNameChanged, object: self)
    }
  }
  var fullName: String { firstName + (lastName.isEmpty ? "" : " \(lastName)") }
  var shortName: String { firstNameSingleWord + (lastNameSingleWord.isEmpty ? "" : " \(lastNameSingleWord)") }
  @Published var email: String
  var description: String = ""
  var dateJoined: Date
  @Published var birthDate: Date {
    didSet {
      guard oldValue != birthDate, isCurrent else { return }
      
      NotificationCenter.default.post(name: Notifications.Userprofiles.BirthDateChanged, object: self)
    }
  }
  var age: Int { birthDate.age }
  @Published var gender: Enums.User.Gender {
    didSet {
      guard oldValue != gender,
            isCurrent
      else { return }
      
      NotificationCenter.default.post(name: Notifications.Userprofiles.GenderChanged, object: self)
    }
  }
  var imageURL: URL?
  var facebookURL: URL? {
    didSet {
      guard !facebookURL.isNil else {
        if instagramURL.isNil && tiktokURL.isNil {
          NotificationCenter.default.post(name: Notifications.Userprofiles.NoSocialURL, object: self)
        }
        return
      }
      NotificationCenter.default.post(name: Notifications.Userprofiles.FacebookURL, object: self)
    }
  }
  var instagramURL: URL? {
    didSet {
      guard !instagramURL.isNil else {
        if facebookURL.isNil && tiktokURL.isNil {
          NotificationCenter.default.post(name: Notifications.Userprofiles.NoSocialURL, object: self)
        }
        return
      }
      NotificationCenter.default.post(name: Notifications.Userprofiles.InstagramURL, object: self)
    }
  }
  var tiktokURL: URL? {
    didSet {
      guard !tiktokURL.isNil else {
        if instagramURL.isNil && facebookURL.isNil {
          NotificationCenter.default.post(name: Notifications.Userprofiles.NoSocialURL, object: self)
        }
        return
      }
      NotificationCenter.default.post(name: Notifications.Userprofiles.TikTokURL, object: self)
    }
  }
  var vkURL: URL?
  @Published var city: City? {
//    willSet {
//      print(newValue)
//    }
    didSet {
      guard let city = city else { return }
      
      cityTitle = city.localizedName.isEmpty ? city.name : city.localizedName
    }
  }
  var cityId: Int = 0 {
    didSet {
      guard isCurrent else { return }
      
      UserDefaults.Profile.cityId = cityId
    }
  }
  var cityTitle: String = "" //{
//    didSet {
//      guard oldValue != cityTitle else { return }
//      if self == Userprofiles.shared.current,
//         !cityTitle.isEmpty,
//         UserDefaults.Profile.city != cityTitle {
//        UserDefaults.Profile.city = cityTitle
//      }
//    }
//  }
  var compatibility: UserCompatibility? {
    didSet {
      guard let compatibility = compatibility else { return }
      
      compatibilityPublisher.send(compatibility)
    }
  }
  var image: UIImage? {
    didSet {
      guard !image.isNil else { return }
      
      imagePublisher.send(image!)
      //#if DEBUG
      //            print("image for \(id)", image)
      //#endif
      isDownloading = false
      
      //            guard let imageData = image.jpeg else { return }
      //
      //            do {
      //                UserDefaults.Profile.imagePath = try FileIOController.write(data: imageData,
      //                                                                            toPath: .Profiles,
      //                                                                            ofType: .Images,
      //                                                                            id: String(id),
      //                                                                            toDocumentNamed: "avatar.jpg").absoluteString
      //                guard !isCurrent else { return }
      //                NotificationCenter.default.post(name: Notifications.Userprofiles.ImageDownloaded, object: self)
      //            } catch {
      //#if DEBUG
      //                print(error.localizedDescription)
      //#endif
      //            }
    }
  }
  var filteredImage: UIImage?
  var completeTotal: Int = 0 {
    didSet {
      guard oldValue != completeTotal else { return }
      
      NotificationCenter.default.post(name: Notifications.Userprofiles.CompleteTotal, object: self)
    }
  }
  @Published var votesReceivedTotal: Int = 0
  @Published var commentsTotal: Int = 0
  @Published var commentsReceivedTotal: Int = 0
  @Published var favoritesTotal: Int = 0
  @Published var publicationsTotal: Int = 0
  @Published var subscribersTotal: Int = 0
  @Published var subscriptionsTotal: Int = 0
  var lastVisit: Date
  var wasEdited: Bool?
  var isBanned: Bool {
    didSet {
      guard isBanned else { return }
      
    }
  }
  var balance: Int = 0 {
    didSet {
      guard oldValue != balance else { return }
      
      NotificationCenter.default.post(name: Notifications.Userprofiles.Balance, object: self)
    }
  }
  var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
  var surveys: [SurveyReference] { SurveyReferences.shared.all.filter { $0.owner == self && !$0.isBanned && !$0.isClaimed && !$0.isAnonymous }}
  var favorites: [Date: [SurveyReference]]   = [:]
  var preferences: [[Topic: Int]] = [[:]] {
    didSet {
      guard oldValue != preferences else { return }
      
      NotificationCenter.default.post(name: Notifications.Userprofiles.Preferences, object: self)
    }
  }
  var preferencesSorted: [[Topic: Int]]? {
    return preferences.sorted {
      guard let first = $0.first?.value,
            let second = $1.first?.value
      else { return true }
      
      return first > second
    }
  }
  var firstNameSingleWord: String {
    guard let components = firstName.components(separatedBy: .whitespaces) as? [String], components.count > 1 else {
      return firstName
    }
    return components.first!
  }
  var lastNameSingleWord: String {
    guard let components = lastName.components(separatedBy: .whitespaces) as? [String], components.count > 1 else {
      return lastName
    }
    return components.first!
  }
//  var choices: [Survey: Answer] = [:]
  ///Store answers`[Survey.id: Answer.id]`
  var answers = [Int: Int]()
  var hasSocialMedia: Bool { !facebookURL.isNil || !instagramURL.isNil || !tiktokURL.isNil }
  @Published var subscribedAt: Bool {
    didSet {
      guard oldValue != subscribedAt,
            let current = Userprofiles.shared.current
      else { return }
                                            
//      subscriptionFlagPublisher.send(subscribedAt)
      subscribedAt ? { current.subscriptionsPublisher.send([self]) }() : { current.subscriptionsRemovePublisher.send([self]) }()
      
      if subscribedAt {
        Userprofiles.shared.newSubscriptionPublisher.send(self)
      } else {
        Userprofiles.shared.removeSubscriptionPublisher.send(self)
      }
    }
  }
  var subscribedToMe: Bool {
    didSet {
      guard oldValue != subscribedAt else { return }
      
      
    }
  }
  var notifyOnPublication: Bool {
    didSet {
      guard oldValue != notifyOnPublication else { return }
      
      notificationPublisher.send([self: notifyOnPublication])
      
      guard let current = Userprofiles.shared.current else { return }
      
      current.notificationPublisher.send([self: notifyOnPublication])
    }
  }
  var isCurrent: Bool { Userprofiles.shared.current == self }
  var isAnonymous: Bool { Userprofile.anonymous == self }
  @Published var subscribers: Set<Int> = Set() //: [Int] { Userprofiles.shared.all.filter { $0.subscribedToMe && !$0.isBanned }}
  @Published var subscriptions: Set<Int> = Set() // : [Int] { Userprofiles.shared.all.filter { $0.subscribedAt && !$0.isBanned }}
  //    var contentLocales: [String] = []
  
  ///**Publishers**
  public let imagePublisher = PassthroughSubject<UIImage, Error>()
  public let cityFetchPublisher = PassthroughSubject<[City], Error>()
  public let compatibilityPublisher = PassthroughSubject<UserCompatibility, Error>()
//  public let subscriptionFlagPublisher = PassthroughSubject<Bool, Never>()
  public let subscribersPublisher = PassthroughSubject<[Userprofile], Never>()
  public let subscribersRemovePublisher = PassthroughSubject<[Userprofile], Never>()
  public let subscriptionsPublisher = PassthroughSubject<[Userprofile], Error>()
  public let subscriptionsRemovePublisher = PassthroughSubject<[Userprofile], Error>()
//  public let votesReceivedTotalPublisher = PassthroughSubject<Int, Never>()
//  public let commentsTotalPublisher = PassthroughSubject<Int, Never>()
//  public let commentsReceivedTotalPublisher = PassthroughSubject<Int, Never>()
  public let notificationPublisher = PassthroughSubject<[Userprofile:  Bool], Never>()
  
  
  
  // MARK: - Private properties
  private var isDownloading = false
  
  init?() {
    guard let _id = UserDefaults.Profile.id,
          let _username = UserDefaults.Profile.username,
          let _firstName = UserDefaults.Profile.firstName,
          let _lastName = UserDefaults.Profile.lastName,
          let _email = UserDefaults.Profile.email,
          let _gender = UserDefaults.Profile.gender,
          let _isBanned = UserDefaults.Profile.isBanned
    else {
      return nil
    }
    
    username    = _username
    lastVisit   = Date()
    id          = _id
    firstName   = _firstName
    lastName    = _lastName
    email       = _email
    gender      = _gender
    isBanned    = _isBanned
    dateJoined  = UserDefaults.Profile.dateJoined ?? Date(timeIntervalSinceReferenceDate: 1)
    subscribedAt = false
    subscribedToMe = false
    imageURL    = UserDefaults.Profile.imageURL
    notifyOnPublication = false
    birthDate   = UserDefaults.Profile.birthDate ?? "01.01.1900".toDate()
    if let path = UserDefaults.Profile.imagePath, let _image = UIImage(contentsOfFile: path) {
      image = _image
    } else if let url = imageURL {  Task { image = try await API.shared.system.downloadImageAsync(from: url) } }
//    cityTitle       = UserDefaults.Profile.city
    
    instagramURL    = UserDefaults.Profile.instagramURL
    tiktokURL       = UserDefaults.Profile.tiktokURL
    vkURL           = UserDefaults.Profile.vkURL
    facebookURL     = UserDefaults.Profile.facebookURL
//    dateJoined      = UserDefaults.Profile.dateJoined ?? Date()
  }
  
  required init(from decoder: Decoder) throws {
    do {
      let container       = try decoder.container(keyedBy: CodingKeys.self)
      username            = try container.decode(String.self, forKey: .username)
      id                  = try container.decode(Int.self, forKey: .id)
      balance             = try container.decodeIfPresent(Int.self, forKey: .balance) ?? 0
      description         = try container.decode(String.self, forKey: .description)
      firstName           = try container.decode(String.self, forKey: .firstName)
      lastName            = try container.decode(String.self, forKey: .lastName)
      email               = try container.decode(String.self, forKey: .email)
      lastVisit           = try container.decode(Date.self, forKey: .lastVisit)
      birthDate           = try container.decode(String.self, forKey: .birthDate).toDate()
//      if let _birthDate   = try container.decodeIfPresent(String.self, forKey: .birthDate) {
//        birthDate = _birthDate.toDate()
//      }
      dateJoined          = try container.decode(Date.self, forKey: .dateJoined)
      imageURL            = URL(string: try container.decodeIfPresent(String.self, forKey: .imageURL) ?? "")
      votesReceivedTotal  = try container.decode(Int.self, forKey: .votesReceivedTotal)
      favoritesTotal      = try container.decode(Int.self, forKey: .favoritesTotal)
      completeTotal       = try container.decode(Int.self, forKey: .completeTotal)
      commentsTotal       = try container.decode(Int.self, forKey: .commentsTotal)
      commentsReceivedTotal = try container.decode(Int.self, forKey: .commentsReceivedTotal)
      publicationsTotal   = try container.decode(Int.self, forKey: .publicationsTotal)
      subscribers         = try container.decode(Set.self, forKey: .subscribers)
      subscriptions       = try container.decode(Set.self, forKey: .subscriptions)
      subscribersTotal    = try container.decode(Int.self, forKey: .subscribersTotal)
      subscriptionsTotal  = try container.decode(Int.self, forKey: .subscriptionsTotal)
      tiktokURL           = URL(string: try container.decodeIfPresent(String.self, forKey: .tiktokURL) ?? "")
      instagramURL        = URL(string: try container.decodeIfPresent(String.self, forKey: .instagramURL) ?? "")
      facebookURL         = URL(string: try container.decodeIfPresent(String.self, forKey: .facebookURL) ?? "")
      vkURL               = URL(string: try container.decodeIfPresent(String.self, forKey: .vkURL) ?? "")
      wasEdited           = try container.decodeIfPresent(Bool.self, forKey: .wasEdited)
      isBanned            = try container.decode(Bool.self, forKey: .isBanned)
      subscribedAt        = try container.decode(Bool.self, forKey: .subscribedAt)
      subscribedToMe      = try container.decode(Bool.self, forKey: .subscribedToMe)
      notifyOnPublication = try container.decode(Bool.self, forKey: .notifyOnPublication)
      gender              = Enums.User.Gender(rawValue: try (container.decodeIfPresent(String.self, forKey: .gender) ?? "")) ?? .Unassigned
      ///City decoding
      if /*!isCurrent, */let decodedCity = try? container.decodeIfPresent(City.self, forKey: .city) {
        let cityInstance = Cities.shared.all.filter({ $0 == decodedCity }).first ?? decodedCity
        city = cityInstance
        cityTitle = cityInstance.localizedName.isEmpty ? cityInstance.name : cityInstance.localizedName
      }
      //            topPublicationCategories.removeAll()
      if let topics = try container.decodeIfPresent([String: Int].self, forKey: .topPublicationCategories) {
        preferences = topics.map { (key, value) -> [Topic: Int] in
          if let id = Int(key), let topic = Topics.shared[id] {
            return [topic: value]
          }
          return [:]
        }
//      }
//        preferences = topics.reduce(into: [Topic: Int]) { result, dict  in
//          guard let topic = Topics.shared.all.filter({ $0.id == Int(dict.key) }).first else { return }
//
//
//            preferences.append([topic: dict.value])
//          }
//        }
//        preferences = []
//        topics.forEach { dict in
//          if let topic = Topics.shared.all.filter({ $0.id == Int(dict.key) }).first {
//            preferences.append([topic: dict.value])
//          }
//        }
      }
      
      //Update current
      guard isCurrent else {
        if Userprofiles.shared.all.filter({ $0 == self }).isEmpty {
          Userprofiles.shared.all.append(self)
        }
        return
      }
      
      Userprofiles.shared.current?.firstName = firstName
      Userprofiles.shared.current?.lastName = lastName
      Userprofiles.shared.current?.birthDate = birthDate
      Userprofiles.shared.current?.gender = gender
//      Userprofiles.shared.current?.city = city
//      Userprofiles.shared.current?.cityTitle = cityTitle
      Userprofiles.shared.current?.facebookURL = facebookURL
      Userprofiles.shared.current?.instagramURL = instagramURL
      Userprofiles.shared.current?.tiktokURL = tiktokURL
    } catch {
//#if DEBUG
//      error.printLocalized(class: type(of: self), functionName: #function)
//      fatalError()
//#else
      throw error
//#endif
    }
  }
  
  func updateUserData(_ json: JSON) {
    guard let _subscribersTotal = json["subscribers_count"].int,
          let _subscriptionsTotal = json["subscribed_at_count"].int,
          let _publicationsTotal = json["own_surveys_count"].int,
          let _favoritesTotal = json["favorite_surveys_count"].int,
          let _completeTotal = json["completed_surveys_count"].int,
//          let _votesReceivedTotal = json["votes_received_count"].int,
//          let _commentsTotal = json["comments_count"].int,
            //            let _commentsReceivedTotal = json["comments_received_count"].int,
          let _balance = json["balance"].int,
          let _top_preferences = json["top_preferences"] as? JSON,
          let _isBanned = json["is_banned"].bool else { return }
    subscribersTotal = _subscribersTotal
//    votesReceivedTotal = _votesReceivedTotal
//    commentsCount = _commentsCount
//    commentsReceivedTotal = _commentsReceivedTotal
    subscriptionsTotal = _subscriptionsTotal
    publicationsTotal = _publicationsTotal
    favoritesTotal = _favoritesTotal
    completeTotal = _completeTotal
    balance = _balance
    isBanned = _isBanned
    updatePreferences(_top_preferences)
  }
  
  func updatePreferences(_ json: JSON) {
    guard !json.isEmpty, let container = json.dictionary else { return }
    preferences = []
    container.forEach {
      guard let key = Int($0.key),
            let topic = Topics.shared.all.filter({ $0.id == key }).first,
            let value = Int($0.key) else { return }
      preferences.append([topic: value])
    }
  }
  
  func update(from instance: Userprofile) {
    firstName = instance.firstName
    lastName = instance.lastName
    email = instance.email
    description = instance.description
    dateJoined = instance.dateJoined
    birthDate = instance.birthDate
    gender = instance.gender
    imageURL = instance.imageURL
    facebookURL = instance.facebookURL
    instagramURL = instance.instagramURL
    tiktokURL = instance.tiktokURL
    vkURL = instance.vkURL
    city = instance.city
    cityId = instance.cityId
    cityTitle = instance.cityTitle
//    compatibility = instance.compatibility
//    image = instance.image
    completeTotal = instance.completeTotal
    votesReceivedTotal = instance.votesReceivedTotal
    commentsTotal = instance.commentsTotal
    commentsReceivedTotal = instance.commentsReceivedTotal
    favoritesTotal = instance.favoritesTotal
    publicationsTotal = instance.publicationsTotal
    subscribersTotal = instance.subscribersTotal
    subscriptionsTotal = instance.subscriptionsTotal
    lastVisit = instance.lastVisit
    wasEdited = instance.wasEdited
    isBanned = instance.isBanned
    balance = instance.balance
    preferences = instance.preferences
//    surveys = instance.surveys
//    favorites = instance.favorites
//    answers = instance.answers
    subscribedAt = instance.subscribedAt
    subscribedToMe = instance.subscribedToMe
    notifyOnPublication = instance.notifyOnPublication
  }
//  func loadSurveys(data: Data) {
//    let decoder = JSONDecoder()
//    do {
//      let instances = try decoder.decode([SurveyReference].self, from: data)
//      instances.forEach { instance in
//        if surveys.filter({ $0.hashValue == instance.hashValue }).isEmpty {
//          if let existing = SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first {
//            surveys.append(existing)
//          } else {
//            surveys.append(instance)
//          }
//        }
//      }
//    } catch {
//      fatalError(error.localizedDescription)
//    }
//  }
  
  //    func updateStats(_ json: JSON) {
  //        if let _surveysAnsweredTotal   = json[DjangoVariables.UserProfile.surveysAnsweredTotal].int,
  //            let _favoriteSurveysTotal   = json[DjangoVariables.UserProfile.surveysFavoriteTotal].int,
  //            let _surveysCreatedTotal    = json[DjangoVariables.UserProfile.surveysCreatedTotal].int {
  //            completeTotal = _surveysAnsweredTotal
  //            favoritesTotal = _favoriteSurveysTotal
  //            publicationsTotal = _surveysCreatedTotal
  //            if let _lastVisitString = json[DjangoVariables.UserProfile.lastVisit].string, let _lastVisit = Date(dateTimeString: _lastVisitString) {
  //                lastVisit = _lastVisit
  //            }
  //        }
  //    }
  
  func downloadImage(downloadProgress: @escaping(Double)->(), completion: @escaping (Result<UIImage, Error>) -> ()) {
    guard let url = imageURL else {
      completion(.failure("Image URL is nil"))
      return
    }
    API.shared.system.downloadImage(url: url) { downloadProgress($0) } completion: { completion($0) }
  }
  
  func downloadImage() {
    guard image.isNil, !isDownloading, let url = imageURL else { return }
    
    isDownloading = true
    Task { [weak self] in
      guard let self = self else { return }
      //#if DEBUG
      //            print(self.id, "\(String(describing: self)).\(#function)")
      //#endif
      do {
        let image = try await API.shared.system.downloadImageAsync(from: url)
        self.image = image
        self.isDownloading = false
      } catch {
        self.imagePublisher.send(completion: .failure(error))
        self.isDownloading = false
      }
    }
  }
  
//  @discardableResult
  func downloadImageAsync() async throws {//}-> UIImage {
    do {
      guard image.isNil, !isDownloading else { return }//UIImage() }
      
      guard let url = imageURL else { throw AppError.invalidURL }
      //#if DEBUG
      //            print(self.id, "\(String(describing: self)).\(#function)")
      //#endif
      isDownloading = true
      image = try await API.shared.system.downloadImageAsync(from: url)
      self.isDownloading = false
    } catch {
      isDownloading = false
      imagePublisher.send(completion: .failure(error))
      throw error
#if DEBUG
      error.printLocalized(class: type(of: self), functionName: #function)
#endif
    }
  }
//
//  public func appendSubscriptions(_ instances: [Userprofile]) {
//    guard !instances.isEmpty else { subscriptionsPublisher.send([]); return }
//
//    guard !subscriptions.isEmpty else { subscriptions.append(contentsOf: instances); return }
//
//    let existingSet = Set(subscriptions)
//    let appendingSet = Set(replaceWithExisting(subscriptions, instances))
//    let difference = Array(appendingSet.subtracting(existingSet))
//
//    guard !difference.isEmpty else { return }
//
//    subscriptions.append(contentsOf: difference)
//  }
//
//  public func appendSubscribers(_ instances: [Userprofile]) {
//    guard !instances.isEmpty else { subscribersPublisher.send([]); return }
//
//    guard !subscribers.isEmpty else { subscribers.append(contentsOf: instances); return }
//
//    let existingSet = Set(subscribers)
//    let appendingSet = Set(replaceWithExisting(subscribers, instances))
//    let difference = Array(appendingSet.subtracting(existingSet))
//
//    guard !difference.isEmpty else { return }
//
//    subscribers.append(contentsOf: difference)
//  }
}

extension Userprofile: Hashable {
  static func == (lhs: Userprofile, rhs: Userprofile) -> Bool {
    return lhs.id == rhs.id && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName// && lhs.gender == rhs.gender && lhs.gender == rhs.gender// && lhs.age == rhs.age//lhs.hashValue == rhs.hashValue
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(gender)
    hasher.combine(email)
  }
}
