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
    var all: [Userprofile] = []
    var current: Userprofile? {
        didSet {
            guard shouldImportUserDefaults, !current.isNil else { return }
            UserDefaults.Profile.load(from: current!)
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
    
    public func eraseData() {
        current = nil
        all.removeAll()
    }
}

class Userprofile: Decodable {
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
             completeTotal = "surveys_results_count",
             favoritesTotal = "favorite_surveys_count",
             publicationsTotal = "surveys_count",
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
    var firstName:          String
    var lastName:           String
    var name: String {
        return "\(firstName) \(lastName)"
    }
    var email:              String
    var birthDate:          Date?
    var age: Int {
        return birthDate?.age ?? 18
    }
    var gender:             Gender
    var imageURL:           URL?
    var instagramURL:       URL?
    var tiktokURL:          URL?
    var vkURL:              URL?
    var facebookURL:        URL?
    var city:               City?
    var image:              UIImage? {
        didSet {
            guard let imageData = image?.jpeg else { return }
            do {
                UserDefaults.Profile.imagePath = try FileIOController.write(data: imageData,
                                                                            toPath: .Profiles,
                                                                            ofType: .Images,
                                                                            id: String(id),
                                                                            toDocumentNamed: "avatar.jpg").absoluteString
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
    var lastVisit:          Date
    var wasEdited:          Bool?
    var isBanned:           Bool
    var balance:            Int
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    var surveys:      [SurveyReference]   = []
    var favorites:    [Date: [SurveyReference]]   = [:]
    var topPublicationCategories: [[Topic: Int]] = [[:]]
    var sortedTopPublicationCategories: [[Topic: Int]] {
        return topPublicationCategories.sorted { (first, second) in
            first.first!.value > second.first!.value
        }
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
            tiktokURL           = URL(string: try container.decodeIfPresent(String.self, forKey: .tiktokURL) ?? "")
            instagramURL        = URL(string: try container.decodeIfPresent(String.self, forKey: .instagramURL) ?? "")
            facebookURL         = URL(string: try container.decodeIfPresent(String.self, forKey: .facebookURL) ?? "")
            vkURL               = URL(string: try container.decodeIfPresent(String.self, forKey: .vkURL) ?? "")
            wasEdited           = try container.decodeIfPresent(Bool.self, forKey: .wasEdited)
            isBanned            = try container.decode(Bool.self, forKey: .isBanned)
            gender              = Gender(rawValue: try (container.decodeIfPresent(String.self, forKey: .gender) ?? "")) ?? .Unassigned
            ///City decoding
            if let cityInstance = try container.decodeIfPresent(City.self, forKey: .city) {
                city = Cities.shared.all.filter({ $0 == cityInstance }).first ?? cityInstance
            }
            topPublicationCategories.removeAll()
            let topics          = try container.decode([String: Int].self, forKey: .topPublicationCategories)
            topics.forEach { dict in
                if let topic = Topics.shared.all.filter({ $0.id == Int(dict.key) }).first {
                    topPublicationCategories.append([topic: dict.value])
                }
            }
            if Userprofiles.shared.all.filter({ $0 == self }).isEmpty {
                Userprofiles.shared.all.append(self)
            }
        } catch {
#if DEBUG
            print(error.localizedDescription)
#endif
            throw error
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
    
    func updateStats(_ json: JSON) {
        if let _surveysAnsweredTotal   = json[DjangoVariables.UserProfile.surveysAnsweredTotal].int,
            let _favoriteSurveysTotal   = json[DjangoVariables.UserProfile.surveysFavoriteTotal].int,
            let _surveysCreatedTotal    = json[DjangoVariables.UserProfile.surveysCreatedTotal].int {
            completeTotal = _surveysAnsweredTotal
            favoritesTotal = _favoriteSurveysTotal
            publicationsTotal = _surveysCreatedTotal
            if let _lastVisitString = json[DjangoVariables.UserProfile.lastVisit].string, let _lastVisit = Date(dateTimeString: _lastVisitString) {
                lastVisit = _lastVisit
            }
        }
    }
    
    func downloadImage(downloadProgress: @escaping(Double)->(), completion: @escaping (Result<UIImage, Error>) -> ()) {
        guard let url = imageURL else {
            completion(.failure("Image URL is nil"))
            return
        }
        API.shared.downloadImage(url: url) { downloadProgress($0) } completion: { completion($0) }
    }
    
    func downloadImageAsync() async throws -> UIImage {
        do {
            guard let url =  imageURL else {
                throw "Image URL is nil"
            }
            self.image = try await API.shared.downloadImageAsync(from: url)
            return self.image!
        } catch {
            throw error
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
