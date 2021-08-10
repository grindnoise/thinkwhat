//
//  Survey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SurveyAnonymity: Int, CaseIterable {
    case Full
    case Host
    case Responder
    case AllowAnonymousVoting
    case Disabled
}

enum SurveyType: String, CaseIterable {
    case Poll = "Poll"
    case Ranking = "Ranking"
}

enum SurveyPoints: Int {
    case Vote               = 1
    case VoteX2             = 2
    case SurveyBaseCost     = 100
    case SurveyHighlighting = 50
}


class Surveys {
    enum SurveyContainerType {
        case TopLinks, NewLinks, Categorized, OwnLinks, Favorite, Downloaded, Completed, Stack, Claim, AllLinks
    }
    static let shared = Surveys()
    private init() {}
    
//    var currentHotSurvey:   FullSurvey?//Add to list of hot_except
    fileprivate var timer:  Timer?
    var rejectedSurveys:    [FullSurvey]  = [] {//Local list of rejected surveys, should be cleared periodically
        didSet {
            if !rejectedSurveys.isEmpty, rejectedSurveys.count != oldValue.count {
                if let survey = rejectedSurveys.last {//Set(oldValue).symmetricDifference(rejectedSurveys).first {
                    stackObjects.remove(object: survey)
                }
            }
        }
    }
    var allLinks:           [ShortSurvey] = []
    var topLinks:           [ShortSurvey] = []
    var newLinks:           [ShortSurvey] = [] {
        didSet {
            if oldValue.count != newLinks.count {
                let sorted = newLinks.sorted { $0.startDate > $1.startDate }
                newLinks = sorted
            }
        }
    }
    var categorizedLinks:   [SurveyCategory: [ShortSurvey]] = [:]
    var ownLinks:           [ShortSurvey] = []
    var favoriteLinks:      [ShortSurvey: Date] = [:]
    var downloadedObjects:  [FullSurvey] = []
    var completedSurveyIDs: [Int] = []//Completed surveys IDs
    var stackObjects:       [FullSurvey] = []{
        didSet {
            if stackObjects.count < oldValue.count {
                print("didSet stackObjects DECREASE \(stackObjects.count)")
            } else {
                print("didSet stackObjects INCREASE \(stackObjects.count)")
            }
        }
    }//Stack of hot surveys
    var claimObjects:       [FullSurvey] = []
    
    func importSurveys(_ json: JSON) {
        for i in json {
            if i.0 == "top" && !i.1.isEmpty {
                topLinks.removeAll()
                for j in i.1 {
                    if let survey = ShortSurvey(j.1) {
                        append(object: survey, type: .TopLinks)
                        //topLinks.append(survey)
                    }
                }
                NotificationCenter.default.post(name: Notifications.Surveys.TopSurveysUpdated, object: nil)
            } else if i.0 == "new" && !i.1.isEmpty {
                newLinks.removeAll()
                for k in i.1 {
                    if let survey = ShortSurvey(k.1) {
                        append(object: survey, type: .NewLinks)
                        //newLinks.append(survey)
                    }
                }
                NotificationCenter.default.post(name: Notifications.Surveys.NewSurveysUpdated, object: nil)
            }  else if i.0 == "by_category" && !i.1.isEmpty {
                categorizedLinks.removeAll()
                for cat in i.1 {
                    let category = SurveyCategories.shared[Int(cat.0)!]
                    var data: [ShortSurvey] = []
                    for _survey in cat.1 {
                        if let survey = ShortSurvey(_survey.1) {
                            if let _foundObject = allLinks.filter({ $0.hashValue == survey.hashValue}).first {
                                data.append(_foundObject)
                            } else {
                                data.append(survey)
                            }
                        }
                        //data.append(ShortSurvey(_survey.1)!)
                    }
                    categorizedLinks[category!] = data
                }
                NotificationCenter.default.post(name: Notifications.Surveys.SurveysByCategoryUpdated, object: nil)
            } else if i.0 == "own" {
                var isFirstLoad = false
                if ownLinks.isEmpty {
                    isFirstLoad = true
                } else {
                    ownLinks.removeAll()
                }
                if !i.1.isEmpty {
                    for k in i.1 {
                        if let survey = ShortSurvey(k.1) {
                            append(object: survey, type: .OwnLinks)
                            //ownLinks.append(survey)
                        }
                    }
                }
                NotificationCenter.default.post(name: isFirstLoad ? Notifications.Surveys.OwnSurveysReceived : Notifications.Surveys.OwnSurveysUpdated, object: nil)
            } else if i.0 == "favorite" {
                favoriteLinks.removeAll()
                if !i.1.isEmpty {
                    for k in i.1 {
//                        print(k)
                        if let date = Date(dateTimeString: (k.1["timestamp"].stringValue as? String)!) as? Date,
                            let survey = ShortSurvey(k.1["survey"]) {
                            if let _foundObject = allLinks.filter({ $0.hashValue == survey.hashValue}).first {
                                favoriteLinks[_foundObject] = date
                            } else {
                                favoriteLinks[survey] = date
                            }
//                            favoriteLinks[survey] = date
                        }
                    }
                }
                NotificationCenter.default.post(name: Notifications.Surveys.FavoriteSurveysUpdated, object: nil)
            } else if i.0 == "user_results" {
                completedSurveyIDs.removeAll()
                for k in i.1 {
                    if let id = k.1["survey"].intValue as? Int {
                        completedSurveyIDs.append(id)
                    }
                }
            } else if i.0 == "hot" {
                if !i.1.isEmpty {
                    for k in i.1 {
                        if let survey = FullSurvey(k.1) {
                            append(object: survey, type: .Stack)
                        }
                    }
                    
                    NotificationCenter.default.post(name: Notifications.Surveys.SurveysStackReceived, object: nil)
                    
                    //TODO - clear rejected
//                    delay(seconds: 30) { self.startTimer() }
                }
            }
        }
    }
    
    func append(object: AnyObject, type: SurveyContainerType) {
        switch type {
        case .Stack:
            if let _object = object as? FullSurvey {
                if let _foundObject = downloadedObjects.filter({ $0.hashValue == _object.hashValue}).first {
                    if stackObjects.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty, rejectedSurveys.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty {
                        stackObjects.append(_foundObject)
                    }
                } else {
                    downloadedObjects.append(_object)
                    if stackObjects.filter({ $0.hashValue == _object.hashValue}).isEmpty, rejectedSurveys.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        stackObjects.append(_object)
//                        append(object: _object, type: .Downloaded)
                    }
                }
            }
        case .Downloaded:
            if let _object = object as? FullSurvey {
                if downloadedObjects.isEmpty {
                    downloadedObjects.append(_object)
                } else {
                    if downloadedObjects.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        downloadedObjects.append(_object)
                    }
                }
            }
        case .NewLinks:
            if let _object = object as? ShortSurvey {
                if let _foundObject = allLinks.filter({ $0.hashValue == _object.hashValue}).first {
                    if newLinks.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty {
                        newLinks.append(_foundObject)
                    }
                } else {
                    if newLinks.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        newLinks.append(_object)
                        allLinks.append(_object)
                    }
                }
//                if newLinks.isEmpty {
//                    newLinks.append(_object)
//                } else {
//                    if newLinks.filter({ $0.hashValue == _object.hashValue}).isEmpty {
//                        newLinks.append(_object)
//                    }
//                }
            }
        case .TopLinks:
            if let _object = object as? ShortSurvey {
                if let _foundObject = allLinks.filter({ $0.hashValue == _object.hashValue}).first {
                    if topLinks.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty {
                        topLinks.append(_foundObject)
                    }
                } else {
                    if topLinks.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        topLinks.append(_object)
                        allLinks.append(_object)
                    }
                }
//                if topLinks.isEmpty {
//                    topLinks.append(_object)
//                } else {
//                    if topLinks.filter({ $0.hashValue == _object.hashValue}).isEmpty {
//                        topLinks.append(_object)
//                    }
//                }
            }
        case .OwnLinks:
            if let _object = object as? ShortSurvey {
                if let _foundObject = allLinks.filter({ $0.hashValue == _object.hashValue}).first {
                    if ownLinks.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty {
                        ownLinks.append(_foundObject)
                    }
                } else {
                    if ownLinks.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        ownLinks.append(_object)
                        allLinks.append(_object)
                    }
                }
//                if ownLinks.isEmpty {
//                    ownLinks.append(_object)
//                } else {
//                    if ownLinks.filter({ $0.hashValue == _object.hashValue}).isEmpty {
//                        ownLinks.append(_object)
//                    }
//                }
            }
        case .Claim:
            if let _object = object as? FullSurvey {
                if claimObjects.isEmpty {
                    claimObjects.append(_object)
                    removeClaimSurvey(object: _object)
                } else {
                    if claimObjects.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        claimObjects.append(_object)
                        removeClaimSurvey(object: _object)
                    }
                }
            }
        default:
            print("")
        }
    }
    
    //Remove from lists -> post Notification
    func removeClaimSurvey(object: FullSurvey) {
        if let surveyLink = object.toShortSurvey() as? ShortSurvey {
            if contains(object: surveyLink, type: .NewLinks) {
                newLinks.remove(object: surveyLink)
                NotificationCenter.default.post(name: Notifications.Surveys.NewSurveysUpdated, object: nil)// (kNotificationNewSurveysUpdated)
            }
            if contains(object: surveyLink, type: .TopLinks) {
                topLinks.remove(object: surveyLink)
                NotificationCenter.default.post(name: Notifications.Surveys.TopSurveysUpdated, object: nil)// (kNotificationTopSurveysUpdated)
            }
        }
        if contains(object: object, type: .Stack) {
            stackObjects.remove(object: object)
//            NotificationCenter.default.post(name: kNotificationTopSurveysUpdated, object: nil)// (kNotificationTopSurveysUpdated)
        }
    }
    
    func contains(object: AnyObject, type: SurveyContainerType) -> Bool {
        switch type {
        case .Stack:
            if let _object = object as? FullSurvey {
                if stackObjects.isEmpty {
                    return false
                } else {
                    return !stackObjects.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        case .Downloaded:
            if let _object = object as? FullSurvey {
                if downloadedObjects.isEmpty {
                    return false
                } else {
                    return !downloadedObjects.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        case .NewLinks:
            if let _object = object as? ShortSurvey {
                if newLinks.isEmpty {
                    return false
                } else {
                    return !newLinks.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        case .TopLinks:
            if let _object = object as? ShortSurvey {
                if topLinks.isEmpty {
                    return false
                } else {
                    return !topLinks.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        case .OwnLinks:
            if let _object = object as? ShortSurvey {
                if ownLinks.isEmpty {
                    return false
                } else {
                    return !ownLinks.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        default:
            return false
        }
        return false
    }
    
    func eraseData() {
        topLinks.removeAll()
        newLinks.removeAll()
        categorizedLinks.removeAll()
        ownLinks.removeAll()
        favoriteLinks.removeAll()
        downloadedObjects.removeAll()
        stackObjects.removeAll()
        rejectedSurveys.removeAll()
    }
    
    subscript (ID: Int) -> FullSurvey? {
        if let i = downloadedObjects.first(where: {$0.ID == ID}) {
            return i
        } else {
            return nil
        }
    }
    
    @objc fileprivate func clearRejectedSurveys() {
        rejectedSurveys.removeAll()
    }
    
    fileprivate func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: TimeIntervals.ClearRejectedSurveys, target: self, selector: #selector(Surveys.clearRejectedSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
}

class ShortSurvey {
    var ID: Int
    var title: String
    var startDate: Date
    var category: SurveyCategory?
    var completionPercentage: Int
    var likes: Int
    var type: SurveyType
//    var hashValue: Int {
//        return ObjectIdentifier(self).hashValue
//    }
    
    init(id _id: Int, title _title: String, startDate _startDate: Date, category _category: SurveyCategory, completionPercentage _completionPercentage: Int, type _type: SurveyType) {//}, likes _likes: Int) {
        ID                      = _id
        title                   = _title
        category                = _category
        completionPercentage    = _completionPercentage
        startDate               = _startDate
        likes = 0
        type                    = _type
        //likes                   = _likes
    }
    
    init?(_ json: JSON) {
        if  let _ID                     = json["id"].intValue as? Int,
            let _title                  = json["title"].stringValue as? String,
            let _category               = json["category"].intValue as? Int,
            let _startDate              = Date(dateTimeString: (json["start_date"].stringValue as? String)!) as? Date,
            let _completionPercentage   = json["vote_capacity"].intValue as? Int,
            let _likes                  = json["likes"].intValue as? Int,
            let _type                   = json["type"].stringValue as? String {
            ID                      = _ID
            title                   = _title
            category                = SurveyCategories.shared[_category]
            completionPercentage    = _completionPercentage
            startDate               = _startDate
            likes                   = _likes
            type                    = SurveyType(rawValue: _type)!
        } else {
            return nil
        }
    }
}

extension ShortSurvey: Hashable {
    static func == (lhs: ShortSurvey, rhs: ShortSurvey) -> Bool {
        return lhs.hashValue == rhs.hashValue
        //        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(ID)
    }
}


class ClaimCategory {
    let ID: Int
    let description: String
    
    init?(_ json: JSON) {
        if  let _ID     = json["id"].intValue as? Int,
            let _description  = json["description"].stringValue as? String {
            ID          = _ID
            description = _description
        } else {
            return nil
        }
    }
}

extension ClaimCategory: Hashable {
    static func == (lhs: ClaimCategory, rhs: ClaimCategory) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        hasher.combine(ID)
    }
}


class ClaimCategories {
    static let shared = ClaimCategories()
    var container: [ClaimCategory] = []
    private init() {}
    
    func importJson(_ json: JSON) {
        container.removeAll()
        for i in json {
            if let category = ClaimCategory(i.1) {
                container.append(category)
            }
        }
    }
    
    subscript (ID: Int) -> ClaimCategory? {
        if let i = container.first(where: {$0.ID == ID}) {
            return i
        } else {
            return nil
        }
    }
}

class FullSurvey {
    var ID: Int?
    var title: String
    var startDate: Date
    var endDate: Date?
    var modified: Date
    var category: SurveyCategory
    var description: String
    var images: [[UIImage: String]]?//Already downloaded -> Download should begin interactively, then store data here
    var imagesURLs: [[String: String]]?//URL - key, Title - value
    var answersWithoutID: [String] = []//Array
    var answers: [SurveyAnswer] = []
    var owner: String
    var link: String?
    var voteCapacity: Int
    var isPrivate: Bool
    var isAnonymous: Bool
    var isCommentingAllowed: Bool
    var totalVotes: Int = 0
    var watchers: Int = 0
    var result: [Int: Date]?
    var userProfile: UserProfile?
    var likes: Int
    var type: SurveyType
    var isHot = false
//    var hashValue: Int {
//        return ObjectIdentifier(self).hashValue
//    }
//    var hashValue: Int
    var dict: [String: Any] {//Dict to create new survey
        var _dict: [String: Any] = [:]
        //Necessary data
        _dict[DjangoVariables.Survey.title] = title
        _dict[DjangoVariables.Survey.category] = category.ID
        _dict[DjangoVariables.Survey.description] = description
        _dict[DjangoVariables.Survey.voteCapacity] = voteCapacity
        _dict[DjangoVariables.Survey.isPrivate] = isPrivate
        _dict[DjangoVariables.Survey.isAnonymous] = isAnonymous
        _dict[DjangoVariables.Survey.isCommentingAllowed] = isCommentingAllowed
        _dict[DjangoVariables.Survey.type] = type.rawValue
        _dict[DjangoVariables.Survey.startDate] = startDate.toDateTimeString()
        _dict[DjangoVariables.Survey.postHot] = isHot
        var _answers: [[String: String]] = []
        
        
        for answer in answersWithoutID {
//            _answers.append(["text" : answer])
            _answers.append([DjangoVariables.SurveyAnswer.description : answer])
        }
        _dict[DjangoVariables.Survey.answers] = _answers
        
        //Optional
        if images != nil {
            _dict[DjangoVariables.Survey.images] = images!
        }
        if link != nil {
            _dict[DjangoVariables.Survey.hlink] = link!
        }
        if endDate != nil {
            _dict[DjangoVariables.Survey.endDate] = endDate!.toDateTimeString()
        }
        return _dict
    }
    init?(newWithoutID dict: [String: Any]) {
        //Necessary fields
        if let _title                   = dict[DjangoVariables.Survey.title] as? String,
            let _category               = dict[DjangoVariables.Survey.category] as? SurveyCategory,
            let _description            = dict[DjangoVariables.Survey.description] as? String,
            let _voteCapacity           = dict[DjangoVariables.Survey.voteCapacity] as? Int,
            let _isPrivate              = dict[DjangoVariables.Survey.isPrivate] as? Bool,
            let _isAnonymous            = dict[DjangoVariables.Survey.isAnonymous] as? Bool,
            let _isHot                  = dict[DjangoVariables.Survey.postHot] as? Bool,
            let _isCommentingAllowed    = dict[DjangoVariables.Survey.isCommentingAllowed] as? Bool,
            let _answers                = dict[DjangoVariables.Survey.answers] as? [String],
            let _type                   = dict[DjangoVariables.Survey.type] as? String {
            
            title               = _title
            startDate           = Date()
            modified            = Date()
            category            = _category
            owner               = AppData.shared.userProfile.ID!
            description         = _description
            voteCapacity        = _voteCapacity
            isPrivate           = _isPrivate
            isAnonymous         = _isAnonymous
            isCommentingAllowed = _isCommentingAllowed
            answersWithoutID    = _answers
            likes               = 0
            type                = SurveyType(rawValue: _type)!
            isHot               = _isHot
            
//            _answers.forEach {
//                dict in
//                dict.map { answersWithoutID.append($0.value }
//            }
//            userProfile         = AppData.shared.userProfile
            
            //Optional fields
            if let _images                 = dict[DjangoVariables.Survey.images] as? [[UIImage: String]] {
                images = _images
            }
            if let _link                  = dict[DjangoVariables.Survey.hlink] as? String {
                link = _link
            }
            if let _endDate               = dict[DjangoVariables.Survey.endDate] as? Date {
                endDate = _endDate
            }
        } else {
            return nil
        }
    }
    
    init?(_ json: JSON) {
        if let _ID                      = json[DjangoVariables.ID].intValue as? Int,
            let _title                  = json[DjangoVariables.Survey.title].stringValue as? String,
            let _startDate              = json[DjangoVariables.Survey.startDate] is NSNull ? nil : Date(dateTimeString: json[DjangoVariables.Survey.startDate].stringValue as! String),
            var _endDate                = json[DjangoVariables.Survey.endDate] is NSNull ? nil : Date(dateTimeString: json[DjangoVariables.Survey.endDate].stringValue as! String),
            var _modified               = Date(dateTimeString: json[DjangoVariables.Survey.modifiedAt].stringValue as! String) as? Date,
            let _category               = json[DjangoVariables.Survey.category].intValue as? Int,
            let _owner                  = json[DjangoVariables.Survey.owner].stringValue as? String,
            let _description            = json[DjangoVariables.Survey.description].stringValue as? String,
            let _link                   = json[DjangoVariables.Survey.hlink].stringValue as? String,
            let _voteCapacity           = json[DjangoVariables.Survey.voteCapacity].intValue as? Int,
            let _isAnonymous            = json[DjangoVariables.Survey.isAnonymous].boolValue as? Bool,
            let _isPrivate              = json[DjangoVariables.Survey.isPrivate].boolValue as? Bool,
            let _isCommentingAllowed    = json[DjangoVariables.Survey.isCommentingAllowed].boolValue as? Bool,
            let _answers                = json[DjangoVariables.Survey.answers].arrayValue as? [JSON],
            let _imageURLs              = json[DjangoVariables.Survey.images].arrayValue as? [JSON],
            let _watchers               = json[DjangoVariables.Survey.watchers].intValue as? Int,
            let _totalVotes             = json[DjangoVariables.Survey.totalVotes].intValue as? Int,
            let _result                 = json[DjangoVariables.Survey.result].arrayValue as? [JSON],
//            let _balance                = json[DjangoVariables.UserProfile.balance].intValue as? Int,
            let _userProfileDict        = json[DjangoVariables.Survey.userprofile] as? JSON,
            let _likes                  = json[DjangoVariables.Survey.likes].intValue as? Int,
            let _type                   = json[DjangoVariables.Survey.type].stringValue as? String {
            ID = _ID
            title = _title
            startDate = _startDate
            endDate = _endDate
            modified = _modified
            category = SurveyCategories.shared[_category]!
            description = _description
            owner = _owner
            link = _link
            voteCapacity = _voteCapacity
            isPrivate = _isPrivate
            isAnonymous = _isAnonymous
            isCommentingAllowed = _isCommentingAllowed
            totalVotes = _totalVotes
            watchers = _watchers
//            AppData.shared.userProfile.balance = _balance
            likes = _likes
            type = SurveyType(rawValue: _type)!
            
            for _answer in _answers {
                if let answer = SurveyAnswer(json: _answer) {
                    answers.append(answer)
                } else {
                    return nil
                }
            }
            if _imageURLs != nil, !_imageURLs.isEmpty {
                imagesURLs = []
                for _imageURL in _imageURLs {
                    if let _url = _imageURL["image"].stringValue as? String, let _imageTitle = _imageURL["title"].stringValue as? String {
                        imagesURLs?.append([_url: _imageTitle])
                    }
                }
            }
            if !_result.isEmpty {
                for _res in _result {
                    if let _answerID = _res["answer"].intValue as? Int, let _timestamp = Date(dateTimeString: _res["timestamp"].stringValue as! String) as? Date {
                        result = [_answerID: _timestamp]
                    }
                }
            }
            if let _userProfile = UserProfile(_userProfileDict) {
//                //TODO find else add
//                var isFound = false
//                isFound = !UserProfiles.shared.container.filter(){
//                    if $0 == _userProfile {
//                        userProfile = $0
//                }}.isEmpty
                
                if let user = UserProfiles.shared.container.filter({ $0 == _userProfile }).first {
                    userProfile = user
                } else {
                    UserProfiles.shared.container.append(_userProfile)
                    userProfile = _userProfile
                }
                
//                if !isFound {
//                    UserProfiles.shared.container.append(_userProfile)
//                    userProfile = _userProfile
//                }
            }
        } else {
            return nil
        }
    }
    
    func toShortSurvey() -> ShortSurvey? {
        if ID != nil, let surveyLink = ShortSurvey(id: ID!, title: title, startDate: startDate, category: category, completionPercentage: 0, type: type) as? ShortSurvey {
            return surveyLink
        }
        return nil
    }
    
    func getAnswerVotePercentage(_ answerVotesCount: Int) -> Int {
        return Int((Double(answerVotesCount) * Double(100) / Double(totalVotes)).rounded())
    }
}

extension FullSurvey: Hashable {
    static func == (lhs: FullSurvey, rhs: FullSurvey) -> Bool {
        return lhs.hashValue == rhs.hashValue
//        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(ID)
        hasher.combine(owner)
        hasher.combine(description)
    }
}

class SurveyAnswer {
    let ID: Int
    var description: String
    var totalVotes: Int
    var title: String
    
    init?(json: JSON) {
        if let _description = json["description"].stringValue as? String,
            let _title = json["title"].stringValue as? String,
            let _ID = json["id"].intValue as? Int,
            let _totalVotes = json["votes_count"].intValue as? Int {
            ID = _ID
            description =  _description
            title = _title
            totalVotes = _totalVotes
        } else {
            print("JSON parse error")
            return nil
        }
    }
}
