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
    static let shared = Userprofiles()
    private init() {}
    var all: [Userprofile] = []
//    var own: Userprofile?
    
    public func eraseData() {
        all.removeAll()
    }
}

class Userprofile: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, name, age, gender,
             imageURL = "image",
             instagramURL = "instagram_url",
             tiktokURL = "tiktok_url",
             vkURL = "vk_url",
             facebookURL = "facebook_url",
             completeTotal = "surveys_results_count",
             favoritesTotal = "favorite_surveys_count",
             publicationsTotal = "surveys_count",
             lastVisit = "last_visit",
             topPublicationCategories = "top_pub_categories"
    }
    enum UserSurveyType {
        case Own, Favorite
    }

    var id:                 Int
    var name:               String
    var age:                Int
    var gender:             Gender
    var imageURL:           URL?
    var instagramURL:       URL?
    var tiktokURL:          URL?
    var vkURL:              URL?
    var facebookURL:        URL?
    var image:              UIImage?
    var completeTotal:      Int = 0
    var favoritesTotal:     Int = 0
    var publicationsTotal:  Int = 0
    var lastVisit:          Date
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
    
    init(id _id: Int,
         name _name: String,
         age _age: Int,
         image _image: UIImage?,
         gender _gender: Gender,
         imageURL _imageURL: URL?,
         instagramURL _instagramURL: URL?,
         tiktokURL _tiktokURL: URL?,
         vkURL _vkURL: URL?,
         facebookURL _facebookURL: URL?) {
        id = _id
        name = _name
        age = _age
        gender = _gender
        image = _image
        imageURL = _imageURL
        instagramURL = _instagramURL
        tiktokURL = _tiktokURL
        facebookURL = _facebookURL
        vkURL = _vkURL
        lastVisit = Date()
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let container       = try decoder.container(keyedBy: CodingKeys.self)
            id                  = try container.decode(Int.self, forKey: .id)
            name                = try container.decode(String.self, forKey: .name)
            lastVisit           = try container.decode(Date.self, forKey: .lastVisit)
            age                 = try container.decode(Int.self, forKey: .age)
            imageURL            = URL(string: try container.decodeIfPresent(String.self, forKey: .imageURL) ?? "")
            favoritesTotal      = try container.decode(Int.self, forKey: .favoritesTotal)
            completeTotal       = try container.decode(Int.self, forKey: .completeTotal)
            publicationsTotal   = try container.decode(Int.self, forKey: .publicationsTotal)
            tiktokURL           = URL(string: try container.decodeIfPresent(String.self, forKey: .tiktokURL) ?? "")
            instagramURL        = URL(string: try container.decodeIfPresent(String.self, forKey: .instagramURL) ?? "")
            facebookURL         = URL(string: try container.decodeIfPresent(String.self, forKey: .facebookURL) ?? "")
            vkURL               = URL(string: try container.decodeIfPresent(String.self, forKey: .vkURL) ?? "")
            gender              = Gender(rawValue: try container.decode(String.self, forKey: .gender)) ?? .Unassigned
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
            fatalError(error.localizedDescription)
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
            let _surveysCreatedTotal    = json[DjangoVariables.UserProfile.surveysCreatedTotal].int,
            let _lastVisit              = json[DjangoVariables.UserProfile.lastVisit] is NSNull ? nil : Date(dateTimeString: json[DjangoVariables.UserProfile.lastVisit].stringValue as! String) {
            completeTotal = _surveysAnsweredTotal
            favoritesTotal = _favoriteSurveysTotal
            publicationsTotal = _surveysCreatedTotal
            lastVisit = _lastVisit
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
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.gender == rhs.gender && lhs.age == rhs.age//lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(gender)
    }
}
