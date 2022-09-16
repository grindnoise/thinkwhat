//
//  UserProfile.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Userprofiles {

    private var shouldImportUserDefaults = false
    static let shared = Userprofiles()
    private init() {
        shouldImportUserDefaults = true
    }
    var all: [Userprofile] = [] {
        didSet {
            //Check for duplicates
            guard let lastInstance = all.last else { return }
            if !oldValue.filter({ $0 == lastInstance }).isEmpty {
                all.remove(object: lastInstance)
            }
        }
    }
    var subscribedFor: [Userprofile] = [] {
        didSet {
            Notification.send(names: [Notifications.Userprofiles.SubscribedForUpdated])
        }
    }
    var subscribers: [Userprofile] = [] {
        didSet {
            Notification.send(names: [Notifications.Userprofiles.SubscribersUpdated])
        }
    }
    var current: Userprofile? {
        didSet {
            guard shouldImportUserDefaults, !current.isNil else { return }
            UserDefaults.Profile.importData(from: current!)
        }
    }
//    lazy var current: Userprofile {
////        return shared.all.filter({ $0.id == UserDefaults.Profile.id && $0.name == "\(User)) \(String(describing: profile.lastName))" }).first ?? Userprofile(id: profile.id!,
////                                                                                                                                                                                             name: "\(String(describing: profile.firstName)) \(String(describing: profile.lastName))",
////                                                                                                                                                                                             age: profile.birthDate?.age ?? 0,
////                                                                                                                                                                                             image: UIImage(contentsOfFile: profile.imagePath ?? ""),
////                                                                                                                                                                                             gender: profile.gender ?? .Unassigned,
////                                                                                                                                                                                             imageURL: profile.imageURL,
////                                                                                                                                                                                             instagramURL: profile.instagramURL,
////                                                                                                                                                                                             tiktokURL: profile.tiktokURL,
////                                                                                                                                                                                             vkURL: profile.vkURL,
////                                                                                                                                                                                             facebookURL: profile.facebookURL)
//    }()
    
    func loadSubscribedFor(_ data: Data) {
        let decoder                                 = JSONDecoder()
//        var notifications: [NSNotification.Name]    = []
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
        do {
            let instances = try decoder.decode([Userprofile].self, from: data)
            for instance in instances {
                if subscribedFor.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                    subscribedFor.append(Userprofiles.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
//                    notifications.append(Notifications.Userprofiles.SubscribedForUpdated)
                }
            }
//            Notification.send(names: notifications.uniqued())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func addSubscriber(_ userprofile: Userprofile) {
        if subscribers.filter({ $0.hashValue == userprofile.hashValue }).isEmpty {
            subscribers.append(userprofile)
        }
    }
    
    public func eraseData() {
        current = nil
        all.removeAll()
        subscribers.removeAll()
        subscribedFor.removeAll()
    }
}

class Userprofile: Decodable {
    static let anonymous: Userprofile = {
        let instance = Userprofile()
        instance!.image = nil
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
        return instance!
    }()
    
    private enum CodingKeys: String, CodingKey {
        case id, age, gender, email, username, city,
             isBanned = "is_banned",
             birthDate = "birth_date",
             firstName = "first_name",
             lastName = "last_name",
             imageURL = "image",
             instagramURL = "instagram_url",
             tiktokURL = "tiktok_url",
             vkURL = "vk_url",
             facebookURL = "facebook_url",
             completeTotal = "completed_surveys_count",
             favoritesTotal = "favorite_surveys_count",
             publicationsTotal = "own_surveys_count",
             subscribersTotal = "subscribers_count",
             subscriptionsTotal = "subscribed_at_count",
             lastVisit = "last_visit",
             topPublicationCategories = "top_pub_categories",
             wasEdited = "is_edited",
             balance = "credit"
    }
    enum UserSurveyType {
        case Own, Favorite
    }

    var id:                 Int
//    var username:           String
    var firstName:          String {
        didSet {
            guard oldValue != firstName else { return }
            NotificationCenter.default.post(name: Notifications.Userprofiles.FirstNameChanged, object: self)
        }
    }
    var lastName:           String {
        didSet {
            guard oldValue != lastName else { return }
            NotificationCenter.default.post(name: Notifications.Userprofiles.LastNameChanged, object: self)
        }
    }
    var name: String {
        return "\(firstName) \(lastName)"
    }
    var email:              String
    var birthDate:          Date? {
        didSet {
            guard let birthDate = birthDate,
                  oldValue != birthDate,
                  isCurrent
            else { return }
            
            NotificationCenter.default.post(name: Notifications.Userprofiles.BirthDateChanged, object: self)
        }
    }
    var age: Int {
        return birthDate?.age ?? 18
    }
    var gender:             Gender {
        didSet {
            guard oldValue != gender,
                  isCurrent
            else { return }
            
            NotificationCenter.default.post(name: Notifications.Userprofiles.GenderChanged, object: self)
        }
    }
    var imageURL:           URL?
    var facebookURL:        URL? {
        didSet {
            guard !facebookURL.isNil, oldValue != facebookURL else {
                if instagramURL.isNil && tiktokURL.isNil {
                    NotificationCenter.default.post(name: Notifications.Userprofiles.NoSocialURL, object: self)
                }
                return
            }
            NotificationCenter.default.post(name: Notifications.Userprofiles.FacebookURL, object: self)
        }
    }
    var instagramURL:       URL? {
        didSet {
            guard !facebookURL.isNil, oldValue != facebookURL else {
                if facebookURL.isNil && tiktokURL.isNil {
                    NotificationCenter.default.post(name: Notifications.Userprofiles.NoSocialURL, object: self)
                }
                return
            }
            NotificationCenter.default.post(name: Notifications.Userprofiles.InstagramURL, object: self)
        }
    }
    var tiktokURL:          URL? {
        didSet {
            guard !facebookURL.isNil, oldValue != facebookURL else {
                if instagramURL.isNil && facebookURL.isNil {
                    NotificationCenter.default.post(name: Notifications.Userprofiles.NoSocialURL, object: self)
                }
                return
            }
            NotificationCenter.default.post(name: Notifications.Userprofiles.TikTokURL, object: self)
        }
    }
    var vkURL:              URL?
    var city:               City? {
        didSet {
            if !city.isNil {
                cityTitle = city!.localized ?? city!.name
            }
        }
    }
    var cityTitle:          String = ""
    var image:              UIImage? {
        didSet {
            guard let imageData = image?.jpeg else { return }
            do {
                UserDefaults.Profile.imagePath = try FileIOController.write(data: imageData,
                                                                            toPath: .Profiles,
                                                                            ofType: .Images,
                                                                            id: String(id),
                                                                            toDocumentNamed: "avatar.jpg").absoluteString
//                guard !isCurrent else { return }
                NotificationCenter.default.post(name: Notifications.Userprofiles.ImageDownloaded, object: self)
            } catch {
#if DEBUG
                print(error.localizedDescription)
#endif
            }
        }
    }
    var completeTotal:      Int = 0
    var favoritesTotal:     Int = 0
    var publicationsTotal:  Int = 0
    var subscribersTotal:   Int = 0
    var subscriptionsTotal: Int = 0
    var lastVisit:          Date
    var wasEdited:          Bool?
    var isBanned:           Bool
    var balance:            Int = 0
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    var surveys:      [SurveyReference]   = []
    var favorites:    [Date: [SurveyReference]]   = [:]
    var topPublicationCategories: [[Topic: Int]]?// = [[:]]
    var sortedTopPublicationCategories: [[Topic: Int]]? {
        return topPublicationCategories?.sorted { (first, second) in
            first.first!.value > second.first!.value
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
    var isCurrent: Bool {
        guard let current = Userprofiles.shared.current,
              current.id == id
        else { return false }
        
        return true
    }
    var hasSocialMedia: Bool {
        guard !facebookURL.isNil || !instagramURL.isNil || !tiktokURL.isNil else {
            return false
        }
        return true
    }
//    init(id _id: Int,
//         firstName _firstName: String,
//         lastName _lastName: String,
//         birthDate _birthDate: Date?,
////         age _age: Int,
//         email _email: String,
//         image _image: UIImage?,
//         gender _gender: Gender,
//         imageURL _imageURL: URL?,
//         instagramURL _instagramURL: URL?,
//         tiktokURL _tiktokURL: URL?,
//         vkURL _vkURL: URL?,
//         facebookURL _facebookURL: URL?) {
//        username = ""
//        id = _id
//        firstName = _firstName
//        lastName = _lastName
//        email = _email
//        birthDate = _birthDate
////        age = _age
//        gender = _gender
//        image = _image
//        imageURL = _imageURL
//        instagramURL = _instagramURL
//        tiktokURL = _tiktokURL
//        facebookURL = _facebookURL
//        vkURL = _vkURL
    //        lastVisit = Date()
    //    }
    init?() {
        guard let _id = UserDefaults.Profile.id,
        let _firstName = UserDefaults.Profile.firstName,
            let _lastName = UserDefaults.Profile.lastName,
            let _email = UserDefaults.Profile.email,
            let _gender = UserDefaults.Profile.gender,
            let _isBanned = UserDefaults.Profile.isBanned else {
                return nil
            }
        lastVisit   = Date()
        id          = _id
        firstName   = _firstName
        lastName    = _lastName
        email       = _email
        gender      = _gender
        isBanned    = _isBanned
        imageURL    = UserDefaults.Profile.imageURL
        if let path = UserDefaults.Profile.imagePath, let _image = UIImage(contentsOfFile: path) {
            image = _image
        } else {
            if let url = imageURL {
                Task {
                    image = try await API.shared.downloadImageAsync(from: url)
//                    await MainActor.run { image = data }
                }
            }
        }
        cityTitle       = UserDefaults.Profile.city
        birthDate       = UserDefaults.Profile.birthDate
        instagramURL    = UserDefaults.Profile.instagramURL
        tiktokURL       = UserDefaults.Profile.tiktokURL
        vkURL           = UserDefaults.Profile.vkURL
        facebookURL     = UserDefaults.Profile.facebookURL
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let container       = try decoder.container(keyedBy: CodingKeys.self)
            id                  = try container.decode(Int.self, forKey: .id)
            balance             = try container.decodeIfPresent(Int.self, forKey: .balance) ?? 0
            firstName           = try container.decode(String.self, forKey: .firstName)
            lastName            = try container.decode(String.self, forKey: .lastName)
            email               = try container.decode(String.self, forKey: .email)
            lastVisit           = try container.decode(Date.self, forKey: .lastVisit)
            if let _birthDate   = try container.decodeIfPresent(String.self, forKey: .birthDate) {
                birthDate = _birthDate.toDate()
            }
            imageURL            = URL(string: try container.decodeIfPresent(String.self, forKey: .imageURL) ?? "")
            favoritesTotal      = try container.decode(Int.self, forKey: .favoritesTotal)
            completeTotal       = try container.decode(Int.self, forKey: .completeTotal)
            publicationsTotal   = try container.decode(Int.self, forKey: .publicationsTotal)
            subscribersTotal    = try container.decode(Int.self, forKey: .subscribersTotal)
            subscriptionsTotal  = try container.decode(Int.self, forKey: .subscriptionsTotal)
            tiktokURL           = URL(string: try container.decodeIfPresent(String.self, forKey: .tiktokURL) ?? "")
            instagramURL        = URL(string: try container.decodeIfPresent(String.self, forKey: .instagramURL) ?? "")
            facebookURL         = URL(string: try container.decodeIfPresent(String.self, forKey: .facebookURL) ?? "")
            vkURL               = URL(string: try container.decodeIfPresent(String.self, forKey: .vkURL) ?? "")
            wasEdited           = try container.decodeIfPresent(Bool.self, forKey: .wasEdited)
            isBanned            = try container.decode(Bool.self, forKey: .isBanned)
            gender              = Gender(rawValue: try (container.decodeIfPresent(String.self, forKey: .gender) ?? "")) ?? .Unassigned
            ///City decoding
            if let cityInstance = try? container.decodeIfPresent(City.self, forKey: .city) {
                city = Cities.shared.all.filter({ $0 == cityInstance }).first ?? cityInstance
                cityTitle = city!.localized ?? city!.name
            }
//            topPublicationCategories.removeAll()
            if let topics = try container.decodeIfPresent([String: Int].self, forKey: .topPublicationCategories), topics != nil, !topics.isEmpty {
                topPublicationCategories = []
                topics.forEach { dict in
                    if let topic = Topics.shared.all.filter({ $0.id == Int(dict.key) }).first {
                        topPublicationCategories!.append([topic: dict.value])
                    }
                }
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
            Userprofiles.shared.current?.city = city
            Userprofiles.shared.current?.cityTitle = cityTitle
            Userprofiles.shared.current?.facebookURL = facebookURL
            Userprofiles.shared.current?.instagramURL = instagramURL
            Userprofiles.shared.current?.tiktokURL = tiktokURL
        } catch {
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
            fatalError()
#else
            throw error
#endif
        }
    }
    
    func updateStats(_ json: JSON) {
        guard let _subscribersTotal = json["subscribers_count"].int,
              let _subscriptionsTotal = json["subscribed_at_count"].int,
              let _publicationsTotal = json["own_surveys_count"].int,
              let _favoritesTotal = json["favorite_surveys_count"].int,
              let _completeTotal = json["completed_surveys_count"].int,
              let _balance = json["balance"].int,
              let _top_preferences = json["top_preferences"] as? JSON,
              let _isBanned = json["is_banned"].bool else { return }
        subscribersTotal = _subscribersTotal
        subscriptionsTotal = _subscriptionsTotal
        publicationsTotal = _publicationsTotal
        favoritesTotal = _favoritesTotal
        completeTotal = _completeTotal
        balance = _balance
        isBanned = _isBanned
        updateTopCategories(_top_preferences)
    }
    
    func updateTopCategories(_ json: JSON) {
        guard !json.isEmpty, let container = json.dictionary else { return }
        topPublicationCategories = []
        container.forEach {
            guard let key = Int($0.key),
                  let topic = Topics.shared.all.filter({ $0.id == key }).first,
                  let value = Int($0.key) else { return }
            topPublicationCategories!.append([topic: value])
        }
    }
    
    func loadSurveys(data: Data) {
        let decoder = JSONDecoder()
        do {
            let instances = try decoder.decode([SurveyReference].self, from: data)
            instances.forEach { instance in
                if surveys.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                    if let existing = SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first {
                        surveys.append(existing)
                    } else {
                        surveys.append(instance)
                    }
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
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
        API.shared.downloadImage(url: url) { downloadProgress($0) } completion: { completion($0) }
    }
    
    func downloadImageAsync() async throws -> UIImage {
        do {
            guard let url =  imageURL else { throw AppError.invalidURL }
            
            let _image = try await API.shared.downloadImageAsync(from: url)
            await MainActor.run {
                self.image = _image
            }
            return image!
        } catch {
            throw error
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
        }
    }
}

extension Userprofile: Hashable {
    static func == (lhs: Userprofile, rhs: Userprofile) -> Bool {
        return lhs.id == rhs.id && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName && lhs.gender == rhs.gender && lhs.gender == rhs.gender// && lhs.age == rhs.age//lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(gender)
        hasher.combine(email)
    }
}
