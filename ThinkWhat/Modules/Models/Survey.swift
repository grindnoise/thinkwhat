//
//  Survey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Survey: Decodable {
    enum SurveyType: String, CaseIterable {
        case Poll = "Poll"
        case Ranking = "Ranking"
    }
    private enum CodingKeys: String, CodingKey {
        case active, id, title, description, category, question, type, startDate = "start_date", url = "hlink", media, answers, voteCapacity = "vote_capacity", isPrivate = "is_private", isAnonymous = "is_anonymous", isCommentingAllowed = "is_commenting_allowed", totalVotes = "total_votes", watchers, likes, views, owner = "userprofile", result
    }
    
    var active:                 Bool
    var id:                     Int
    var title:                  String
    var startDate:              Date
    var topic:                  Topic
    var description:            String
    var question:               String
    var media:                  [Mediafile] = []
    var mediaSortedByOrder:     [Mediafile] {
        return media.sorted { $0.order < $1.order }
    }
    var images: [UIImage] {
        return media.filter { $0.image != nil } .map { $0.image! }
    }
    var mediaWithImagesSortedByOrder: [Mediafile] {
        return media.filter { $0.image != nil } .sorted { $0.order < $1.order }
    }
    var mediaWithImageURLs: [Mediafile] {
        return media.filter { $0.imageURL != nil }
    }
    var imagesCount: Int {
        return max(media.filter({ $0.image != nil }).count, media.filter({ $0.imageURL != nil }).count)
    }
    var answers:                [Answer] = []
    var answersSortedByVotes:   [Answer] {
        return answers.sorted { $0.totalVotes > $1.totalVotes }
    }
    var answersSortedByOrder:   [Answer] {
        return answers.sorted { $0.order < $1.order }
    }

    var url:                    URL? = nil///hlink
    var voteCapacity:           Int
    var isPrivate:              Bool
    var isAnonymous:            Bool
    var isCommentingAllowed:    Bool
    var totalVotes:             Int = 0
    var watchers:               Int = 0
    var result:                 [Int: Date]? {
        didSet {
            if let _result = result, let _oldValue = oldValue, _oldValue.isEmpty, !_result.isEmpty, let surveyRef = SurveyReferences.shared.all.filter({ $0.hashValue == self.hashValue }).first {
                surveyRef.isComplete = true
            }
        }
    }
    var owner:                  Userprofile
    var likes:                  Int = 0
    var views:                  Int = 0
    var type:                   SurveyType
    var isHot = false
    var isComplete: Bool {
        if let _result = result, !_result.isEmpty {
            return true
        }
        return false
    }
    var isOwn: Bool {
        return owner.id == UserDefaults.Profile.id
    }
    var isFavorite: Bool {
        return !Surveys.shared.favoriteReferences.keys.filter({ $0.id == self.id }).isEmpty
    }
    var reference: SurveyReference {
        return SurveyReferences.shared.all.filter({ $0.hashValue == hashValue}).first ?? createReference()
    }
    var completion: Int {
        get {
            return totalVotes * 100 / voteCapacity
        }
    }
    private let tempId = 999999
    
    required init(from decoder: Decoder) throws {
        do {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            guard let topicId = try container.decode(Int.self, forKey: .category) as? Int, let _topic = Topics.shared.all.filter({ $0.id == topicId }).first else {
                throw "Topic not found"
            }
            guard let _type = SurveyType(rawValue: try container.decode(String.self, forKey: .type)) else {
                throw "SurveyType not defined"
            }
            let _owner          = try container.decode(Userprofile.self, forKey: .owner)
            owner               = Userprofiles.shared.all.filter({ $0.id == _owner.id }).first ?? _owner
            topic               = _topic
            active              = try container.decode(Bool.self, forKey: .active)
            id                  = try container.decode(Int.self, forKey: .id)
            title               = try container.decode(String.self, forKey: .title)
            description         = try container.decode(String.self, forKey: .description)
            startDate           = try container.decode(Date.self, forKey: .startDate)
            url                 = URL(string: try container.decode(String.self, forKey: .url))
            question            = try container.decode(String.self, forKey: .question)
            type                = _type
            media               = try container.decode([Mediafile].self, forKey: .media)
            answers             = try container.decode([Answer].self, forKey: .answers)
            voteCapacity        = try container.decode(Int.self, forKey: .voteCapacity)
            totalVotes          = try container.decode(Int.self, forKey: .totalVotes)
            watchers            = try container.decode(Int.self, forKey: .watchers)
            likes                = try container.decode(Int.self, forKey: .likes)
            views                = try container.decode(Int.self, forKey: .views)
            isPrivate            = try container.decode(Bool.self, forKey: .isPrivate)
            isAnonymous                 = try container.decode(Bool.self, forKey: .isAnonymous)
            isCommentingAllowed = try container.decode(Bool.self, forKey: .isCommentingAllowed)
            if let dict = try container.decodeIfPresent([String: Date].self, forKey: .result), !dict.isEmpty {
                result = [Int(dict.keys.first!)!: dict.values.first!]
            }
            ///Check for existing
            if Surveys.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
                Surveys.shared.all.append(self)
            }
        } catch {
            throw error
        }
    }
    
    init(type _type: SurveyType, title _title: String, topic _topic: Topic, description _description: String, question _question: String, answers _answers: [String], media _media: [Int: [UIImage: String]], url _url: URL?, voteCapacity _voteCapacity: Int, isPrivate _isPrivate: Bool, isAnonymous _isAnonymous: Bool, isCommentingAllowed _isCommentingAllowed: Bool, isHot _isHot: Bool) {
        owner               = Userprofiles.shared.current!
        topic               = _topic
        active              = true
        id                  = tempId
        title               = _title
        description         = _description
        startDate           = Date()
        url                 = _url
        question            = _question
        type                = _type
        voteCapacity        = _voteCapacity
        isPrivate           = _isPrivate
        isAnonymous         = _isAnonymous
        isCommentingAllowed = _isCommentingAllowed
        media = _media.map({ number, dict in
            return Mediafile(title: dict.first?.value ?? "", order: number, survey: self, image: dict.first?.key)
        })
        answers = _answers.enumerated().map({ (index,title) in
            return Answer(description: "", title: title, survey: self, order: index)
        })
    }
    
    private func createReference() -> SurveyReference {
        return SurveyReference(id: id, title: title, startDate: startDate, topic: topic, type: type, likes: likes, views: views, isOwn: isOwn, isComplete: isComplete, isFavorite: isFavorite, survey: self, owner: owner)
    }
    
    func getAnswerVotePercentage(_ answerVotesCount: Int) -> Int {
        return Int((Double(answerVotesCount) * Double(100) / Double(totalVotes)).rounded())
    }
    
    func getPercentForAnswer(_ answer: Answer) -> Int {
        if let _answer = answers.filter({ $0.id == answer.id }).first {
            return 100 * _answer.totalVotes / totalVotes
        }
        return 0
    }
}

extension Survey: Hashable {
    static func == (lhs: Survey, rhs: Survey) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
        hasher.combine(topic)
    }
}

class Surveys {
    enum SurveyContainerType {
        case TopLinks, NewLinks, Categorized, OwnLinks, Favorite, Downloaded, Completed, Stack, Claim, AllLinks
    }
    private enum Category: String {
        case Top = "top", Own = "own", New = "new", Favorite = "favorite", Hot = "hot", byTopic = "by_category"
    }
    static let shared = Surveys()
    private init() {}
    private var timer:  Timer?
    
//    var allReferences:           [SurveyReference] = []
    var topReferences:           [SurveyReference] = []
    var newReferences:           [SurveyReference] = [] {
        didSet {
            if oldValue.count != newReferences.count {
                let sorted = newReferences.sorted { $0.startDate > $1.startDate }
                newReferences = sorted
            }
        }
    }
    var ownReferences:           [SurveyReference] = []
    var favoriteReferences:      [SurveyReference: Date] = [:]
//    var categorizedLinks:   [Topic: [SurveyReference]] = [:]
    var completed:               [Survey] = []
    var all:                     [Survey] = []
    var hot:                     [Survey] = []
    var banned:                  [Survey] = []///Banned by user
    var rejected:                [Survey]  = [] {//Local list of rejected surveys, should be cleared periodically
        didSet {
            if !rejected.isEmpty, rejected.count != oldValue.count {
                if let survey = rejected.last {
                    hot.remove(object: survey)
                }
            }
        }
    }
    
    func load(_ json: JSON) {
        let decoder                                 = JSONDecoder()
        var notifications: [NSNotification.Name]    = []
        decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                   DateFormatter.dateTimeFormatter,
                                                   DateFormatter.dateFormatter ]
//        decoder.keyDecodingStrategy                 = .convertFromSnakeCase
        do {
            for (key, value) in json {
                if key == Category.Hot.rawValue {
                    let instances = try decoder.decode([Survey].self, from: value.rawData())
                    for instance in instances {
                        if hot.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                            hot.append(Surveys.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
                            notifications.append(Notifications.Surveys.UpdateHotSurveys)
                        }
                    }
                } else {
                    switch key {
                    case Category.Favorite.rawValue:
                        for entry in value.arrayValue {
                            guard let dateStr = entry["timestamp"].rawString(), let date = Date(dateTimeString: dateStr) as? Date, let instance = try decoder.decode(SurveyReference.self, from: entry["survey"].rawData()) as? SurveyReference else {
                                continue
                            }
                            if favoriteReferences.keys.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                                favoriteReferences[SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance] = date
                                notifications.append(Notifications.Surveys.FavoriteSurveysUpdated)
                            }
                        }
                    default:
                        let instances = try decoder.decode([SurveyReference].self, from: value.rawData())
                        for instance in instances {
    //                        let surveyReference = SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first!
                            if key == Category.Top.rawValue {//} && !value.isEmpty {
                                if topReferences.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                                    topReferences.append(SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
                                    notifications.append(Notifications.Surveys.UpdateTopSurveys)
                                }
                            } else if key == Category.New.rawValue {
                                if newReferences.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                                    newReferences.append(SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
                                    notifications.append(Notifications.Surveys.UpdateNewSurveys)
                                }
                            } else if key == Category.Own.rawValue {
                                if ownReferences.filter({ $0.hashValue == instance.hashValue }).isEmpty {
                                    ownReferences.append(SurveyReferences.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
                                    notifications.append(Notifications.Surveys.UpdateNewSurveys)
                                }
                            }
                        }
                    }
                }
            }
            sendNotifications(names: notifications.uniqued())
            print(all.count)
        } catch {
            fatalError("Survey init() threw error: \(error)")
        }
    }
    
    private func sendNotifications(names: [NSNotification.Name]) {
        names.forEach { NotificationCenter.default.post(name: $0, object: nil) }
    }
    
    ///Remove from lists & notify
    func banSurvey(object: Survey) {
        guard let instance = hot.filter({$0.hashValue == object.hashValue}).first, let reference = instance.reference as? SurveyReference else {
            return
        }
        ///Clear new/top/hot
        newReferences.remove(object: reference)
        newReferences.remove(object: reference)
        hot.remove(object: instance)
        sendNotifications(names: [Notifications.Surveys.UpdateNewSurveys, Notifications.Surveys.UpdateTopSurveys])
    }
    
    func eraseData() {
        topReferences.removeAll()
        newReferences.removeAll()
//        categorizedLinks.removeAll()
        ownReferences.removeAll()
        favoriteReferences.removeAll()
        all.removeAll()
        hot.removeAll()
        rejected.removeAll()
    }
    
    subscript (ID: Int) -> Survey? {
        if let i = all.first(where: {$0.id == ID}) {
            return i
        } else {
            return nil
        }
    }
    
    @objc fileprivate func clearRejectedSurveys() {
        rejected.removeAll()
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: TimeIntervals.ClearRejectedSurveys, target: self, selector: #selector(Surveys.clearRejectedSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
}








