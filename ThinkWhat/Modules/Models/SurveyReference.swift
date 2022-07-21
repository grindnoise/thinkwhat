//
//  SurveyRef.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SurveyReference: Decodable {

    private enum CodingKeys: String, CodingKey {
        case id, type, title, category, likes, views, progress, rating, description,
             startDate = "start_date",
             isComplete = "is_complete",
             isOwn = "is_own",
             isFavorite = "is_favorite",
             owner = "userprofile",
             votesLimit = "vote_capacity",
             votesTotal = "votes_total",
             isHot = "is_hot",
             isAnonymous = "is_anonymous"
    }
    var id: Int
    var title: String
    var startDate: Date
    var topic: Topic
    var truncatedDescription: String
    //    var completionPercentage: Int
    var rating: Double {
        didSet {
            guard oldValue != rating else { return }
//            Notification.send(names: [Notifications.Surveys.Rating])
            NotificationCenter.default.post(name: Notifications.Surveys.Rating, object: self)
            guard let survey = survey else { return }
            survey.rating = rating
        }
    }
    var likes: Int {
        didSet {
            guard oldValue != likes else { return }
//            Notification.send(names: [Notifications.Surveys.Likes])
            NotificationCenter.default.post(name: Notifications.Surveys.Likes, object: self)
            guard let survey = survey else { return }
            survey.likes = likes
        }
    }
    var views: Int {
        didSet {
            guard oldValue != views else { return }
//            Notification.send(names: [Notifications.Surveys.Views])
            NotificationCenter.default.post(name: Notifications.Surveys.Views, object: self)
            guard let survey = survey else { return }
            survey.views = views
        }
    }
    var type: Survey.SurveyType
    var isComplete: Bool {
        didSet {
            guard oldValue != isComplete else { return }
            NotificationCenter.default.post(name: Notifications.Surveys.Completed, object: self)
//            Notification.send(names: [Notifications.Surveys.Completed])
        }
    }
    var isOwn: Bool
    var isAnonymous: Bool
    var isHot: Bool {
        didSet {
            guard oldValue != isHot else { return }
            NotificationCenter.default.post(name: Notifications.Surveys.SwitchHot, object: self)
//            Notification.send(names: [Notifications.Surveys.SwitchHot])
        }
    }
    var isFavorite: Bool {
        didSet {
            guard oldValue != isFavorite else { return }
            NotificationCenter.default.post(name: Notifications.Surveys.SwitchFavorite, object: self)
//            Notification.send(names: [Notifications.Surveys.SwitchFavorite])
        }
    }
    
    var isBanned: Bool = false {
        didSet {
            guard isBanned else { return }
            NotificationCenter.default.post(name: Notifications.Surveys.Ban, object: self)
        }
    }
    var isClaimed: Bool = false {
        didSet {
            guard isClaimed else { return }
            NotificationCenter.default.post(name: Notifications.Surveys.Claim, object: self)
        }
    }
//    var isFavorite: Bool {
//        didSet {
//            guard oldValue != isFavorite else { return }
//            if isFavorite, Surveys.shared.favoriteReferences.keys.filter({ $0 == self }).isEmpty {
//                Surveys.shared.favoriteReferences[self] = Date()
//            } else if !isFavorite, let instance = Surveys.shared.favoriteReferences.keys.filter({ $0 == self }).first {
//                Surveys.shared.favoriteReferences[instance] = nil
//            }
//        }
//    }
    var owner: Userprofile
    var votesTotal: Int
    var votesLimit: Int
    var survey: Survey? {
        return Surveys.shared.all.filter{ $0.hashValue == hashValue }.first
    }
    var progress: Int {
        didSet {
            guard oldValue != progress else { return }
            NotificationCenter.default.post(name: Notifications.Surveys.Progress, object: self)
//            Notification.send(names: [Notifications.Surveys.Progress])
            guard let survey = survey else { return }
            survey.progress = progress
        }
    }
    required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let topicId = try container.decode(Int.self, forKey: .category) as? Int,
                  let _topic = Topics.shared.all.filter({ $0.id == topicId }).first else {
                throw "Topic not found"
            }
            guard let _type = Survey.SurveyType(rawValue: try container.decode(String.self, forKey: .type)) else {
                throw "Type not defined"
            }
            isAnonymous             = try container.decode(Bool.self, forKey: .isAnonymous)
            owner                   = Userprofiles.shared.anonymous
            let _owner              = try container.decodeIfPresent(Userprofile.self, forKey: .owner)
            if !_owner.isNil {
                owner = Userprofiles.shared.all.filter({ $0.id == _owner!.id }).first ?? _owner!
            }
            id      = try container.decode(Int.self, forKey: .id)
            title   = try container.decode(String.self, forKey: .title)
            truncatedDescription = try container.decode(String.self, forKey: .description)
            topic   = _topic
            type    = _type
//            let _owner  = try container.decode(Userprofile.self, forKey: .owner)
//            owner       = Userprofiles.shared.all.filter({ $0.id == _owner.id }).first ?? _owner
            likes       = try container.decode(Int.self, forKey: .likes)
            views       = try container.decode(Int.self, forKey: .views)
            votesLimit  = try container.decode(Int.self, forKey: .votesLimit)
            votesTotal  = try container.decode(Int.self, forKey: .votesTotal)
            startDate   = try container.decode(Date.self, forKey: .startDate)
            isComplete  = try container.decode(Bool.self, forKey: .isComplete)
            isOwn       = try container.decode(Bool.self, forKey: .isOwn)
            isFavorite  = try container.decode(Bool.self, forKey: .isFavorite)
            isHot       = try container.decode(Bool.self, forKey: .isHot)
            progress    = try container.decode(Int.self, forKey: .progress)
            rating      = Double(try container.decode(String.self, forKey: .rating)) ?? 0
            ///Check for existing instance by hashValue
            if SurveyReferences.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
                SurveyReferences.shared.all.append(self)
            }
        } catch {
#if DEBUG
            print(error.localizedDescription)
#endif
            throw error
        }
    }
    
    init(id: Int,
         title: String,
         description: String,
         startDate: Date,
         topic: Topic,
         type: Survey.SurveyType,
         likes: Int = 0,
         views: Int = 0,
         isOwn: Bool,
         isComplete: Bool,
         isFavorite: Bool,
         isHot: Bool,
         survey: Survey,
         owner: Userprofile,
         votesTotal: Int = 0,
         votesLimit: Int = 0,
         isAnonymous: Bool,
         progress: Int = 0,
         rating: Double = 0) {
        
        self.id                      = id
        self.title                   = title
        self.topic                   = topic
        self.startDate               = startDate
        self.likes                   = likes
        self.views                   = views
        self.type                    = type
        self.isOwn                   = isOwn
        self.isHot                   = isHot
        self.isComplete              = isComplete
        self.isFavorite              = isFavorite
        self.votesTotal              = votesTotal
        self.votesLimit              = votesLimit
//        survey                  = _survey
        self.owner                   = owner
        self.isAnonymous             = isAnonymous
        self.truncatedDescription    = description
        self.progress                = progress
        self.rating                  = rating
        if SurveyReferences.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
            SurveyReferences.shared.all.append(self)
        }
    }
//    //    var survey
//    //    var hashValue: Int {
//    //        return ObjectIdentifier(self).hashValue
//    //    }
//
    //    init(id _id: Int, title _title: String, startDate _startDate: Date, category _category: SurveyCategory, completionPercentage _completionPercentage: Int, type _type: SurveyType) {//}, likes _likes: Int) {
    
//
//    init?(_ json: JSON) {
//        if  let _ID                     = json["id"].intValue as? Int,
//            let _title                  = json["title"].stringValue as? String,
//            let _categoryID             = json["category"].intValue as? Int,
//            let _category               = Topics.shared[_categoryID],
//            let _startDate              = Date(dateTimeString: (json["start_date"].stringValue as? String)!) as? Date,
//            //            let _completionPercentage   = json["vote_capacity"].intValue as? Int,
//            let _likes                  = json["likes"].intValue as? Int,
//            let _views                  = json["views"].intValue as? Int,
//            let _isOwn                  = json["is_own"].boolValue as? Bool,
//            let _isComplete             = json["is_complete"].boolValue as? Bool,
//            let _isFavorite             = json["is_favorite"].boolValue as? Bool,
//            let _type                   = json["type"].stringValue as? String {
//            id                      = _ID
//            title                   = _title
//            category                = _category
//            //            completionPercentage    = _completionPercentage
//            startDate               = _startDate
//            likes                   = _likes
//            views                   = _views
//            isOwn                   = _isOwn
//            isComplete              = _isComplete
//            isFavorite              = _isFavorite
//            type                    = Survey.SurveyType(rawValue: _type)!
//        } else {
//            return nil
//        }
//    }
}

extension SurveyReference: Hashable {
    static func == (lhs: SurveyReference, rhs: SurveyReference) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
        hasher.combine(topic)
    }
}

class SurveyReferences {
    static let shared = SurveyReferences()
    private init() {}
    var all: [SurveyReference] = [] {
        didSet {
            guard oldValue.count != all.count else { return }
            Notification.send(names: [Notifications.Surveys.UpdateAll])
        }
    }
    
    public func eraseData() {
        all.removeAll()
    }
}
