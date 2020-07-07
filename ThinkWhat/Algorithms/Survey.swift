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

enum SurveyPoints: Int {
    case Vote               = 1
    case VoteX2             = 2
    case SurveyBaseCost     = 100
    case SurveyHighlighting = 50
}


class Surveys {
    enum SurveyContainerType {
        case Top, New, Categorized, Own, Favorite, Downloaded, Completed, Stack
    }
    static let shared = Surveys()
    private init() {}
    
//    var currentHotSurvey:   FullSurvey?//Add to list of hot_except
    fileprivate var timer:  Timer?
    var rejectedSurveys:    [FullSurvey]  = []//Local list of rejected surveys, should be cleared periodically
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
            print("didSet stackObjects \(stackObjects.count)")
        }
    }//Stack of hot surveys
    
    func importSurveys(_ json: JSON) {
        for i in json {
            if i.0 == "top" && !i.1.isEmpty {
                topLinks.removeAll()
                for j in i.1 {
                    if let survey = ShortSurvey(j.1) {
                        topLinks.append(survey)
                    }
                }
                NotificationCenter.default.post(name: kNotificationTopSurveysUpdated, object: nil)
            } else if i.0 == "new" && !i.1.isEmpty {
                newLinks.removeAll()
                for k in i.1 {
                    if let survey = ShortSurvey(k.1) {
                        newLinks.append(survey)
                    }
                }
                NotificationCenter.default.post(name: kNotificationNewSurveysUpdated, object: nil)
            }  else if i.0 == "by_category" && !i.1.isEmpty {
                categorizedLinks.removeAll()
                for cat in i.1 {
                    let category = SurveyCategories.shared[Int(cat.0)!]
                    var data: [ShortSurvey] = []
                    for survey in cat.1 {
                        data.append(ShortSurvey(survey.1)!)
                    }
                    categorizedLinks[category!] = data
                }
                NotificationCenter.default.post(name: kNotificationSurveysByCategoryUpdated, object: nil)
            } else if i.0 == "own" {
                ownLinks.removeAll()
                if !i.1.isEmpty {
                    for k in i.1 {
                        if let survey = ShortSurvey(k.1) {
                            ownLinks.append(survey)
                        }
                    }
                }
                NotificationCenter.default.post(name: kNotificationOwnSurveysUpdated, object: nil)
            } else if i.0 == "favorite" {
                favoriteLinks.removeAll()
                if !i.1.isEmpty {
                    for k in i.1 {
//                        print(k)
                        if let date = Date(dateTimeString: (k.1["added_at"].stringValue as? String)!) as? Date,
                            let survey = ShortSurvey(k.1["survey"]) {
                            favoriteLinks[survey] = date
                        }
                    }
                }
                NotificationCenter.default.post(name: kNotificationFavoriteSurveysUpdated, object: nil)
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
                    
                    NotificationCenter.default.post(name: kNotificationSurveysStackReceived, object: nil)
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
                    if stackObjects.filter({ $0.hashValue == _object.hashValue}).isEmpty, rejectedSurveys.filter({ $0.hashValue == _object.hashValue}).isEmpty {
                        stackObjects.append(_object)
                        append(object: _object, type: .Downloaded)
                    }
                }
//                append(object: _object, type: .Downloaded)
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
        case .New:
            if let _object = object as? ShortSurvey {
                if newLinks.isEmpty {
                    newLinks.append(_object)
                } else {
                    newLinks.map() {
                        if $0.hashValue != _object.hashValue {
                            newLinks.append(_object)
                        }
                    }
                }
            }
        case .Top:
            if let _object = object as? ShortSurvey {
                if topLinks.isEmpty {
                    topLinks.append(_object)
                } else {
                    topLinks.map() {
                        if $0.hashValue != _object.hashValue {
                            topLinks.append(_object)
                        }
                    }
                }
            }
        case .Own:
            if let _object = object as? ShortSurvey {
                if ownLinks.isEmpty {
                    ownLinks.append(_object)
                } else {
                    ownLinks.map() {
                        if $0.hashValue != _object.hashValue {
                            ownLinks.append(_object)
                        }
                    }
                }
            }
        default:
            print("")
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
        case .New:
            if let _object = object as? ShortSurvey {
                if newLinks.isEmpty {
                    return false
                } else {
                    return !newLinks.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        case .Top:
            if let _object = object as? ShortSurvey {
                if topLinks.isEmpty {
                    return false
                } else {
                    return !topLinks.map() { $0.hashValue == _object.hashValue }.isEmpty
                }
            }
        case .Own:
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
        timer = Timer.scheduledTimer(timeInterval: REJECTED_SURVEYS_ERASE_INTERVAL, target: self, selector: #selector(Surveys.clearRejectedSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
}

class ShortSurvey {
    var ID: Int
    var title: String
    var startDate: Date
    var category: SurveyCategory?
    var completionPercentage: Int
//    var hashValue: Int {
//        return ObjectIdentifier(self).hashValue
//    }
    
    init(id _id: Int, title _title: String, startDate _startDate: Date, category _category: SurveyCategory, completionPercentage _completionPercentage: Int) {
        ID                      = _id
        title                   = _title
        category                = _category
        completionPercentage    = _completionPercentage
        startDate               = _startDate
    }
    
    init?(_ json: JSON) {
        if  let _ID                     = json["id"].intValue as? Int,
            let _title                  = json["title"].stringValue as? String,
            let _category               = json["category"].intValue as? Int,
            let _startDate              = Date(dateTimeString: (json["start_date"].stringValue as? String)!) as? Date,
            let _completionPercentage   = json["vote_capacity"].intValue as? Int {
            ID                      = _ID
            title                   = _title
            category                = SurveyCategories.shared[_category]
            completionPercentage    = _completionPercentage
            startDate               = _startDate
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

class SurveyCategories {
    static let shared = SurveyCategories()
    private init() {}
    var categories: [SurveyCategory] = []
    var tree: [[String: [SurveyCategory]]] = [[:]]
    //var _categories: [SurveyCategory: [SurveyCategory?]] = [:]
    
    func importJson(_ json: JSON) {
        categories.removeAll()
        tree.removeAll()
        for i in json {
            if let category = SurveyCategory(i.1) {
                var array: [SurveyCategory] = []
                categories.append(category)
                if !i.1["children"].isEmpty {
                    let subcategories = i.1["children"]
                    for j in subcategories {
                        if let subCategory = SurveyCategory(j.1, category) {
                            categories.append(subCategory)
                            array.append(subCategory)
                        }
                    }
                }
                let entry:[String: [SurveyCategory]] = [category.title: array]
                tree.append(entry)
            }
        }
    }
    
    func updateCount(_ json: JSON) {
        if let _categories = json["categories"] as? JSON {
            if !_categories.isEmpty {
                for cat in categories {
                    cat.total = 0
                    cat.active = 0
                }
                for cat in _categories {
                    if let category = self[Int(cat.0)!] as? SurveyCategory, let total = cat.1["total"].intValue as? Int, let active = cat.1["active"].intValue as? Int {
                        category.total = total
                        category.active = active
                        category.parent?.total += total
                        category.parent?.active += active
                    }
                }
            }
        }
    }
    
    subscript (ID: Int) -> SurveyCategory? {
        if let i = categories.first(where: {$0.ID == ID}) {
            return i
        } else {
            return nil
        }
    }
    
    subscript (title: String) -> SurveyCategory? {
        if let i = categories.first(where: {$0.title == title}) {
            return i
        } else {
            return nil
        }
    }
}

class SurveyCategory {
    let ID: Int
    let title: String
    let dateCreated: Date
    var parent: SurveyCategory?
    var ageRestriction: Int?
    var tagColor: UIColor?
    var total: Int = 0
    var active: Int = 0
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    init?(_ json: JSON, _ _parent: SurveyCategory? = nil) {
        if  let _ID                     = json["id"].intValue as? Int,
            let _title                  = json["title"].stringValue as? String,
            let _tagColor               = json["tag_color"] is NSNull ? "" as? String: json["tag_color"].stringValue as? String,
            var _dateCreated            = json["created_at"] is NSNull ? nil : Date(dateTimeString: json["created_at"].stringValue as! String),
            var _ageRestriction         = json["age_restriction"] is NSNull ? nil : json["age_restriction"].intValue as? Int {
            ID                      = _ID
            title                   = _title
            dateCreated             = _dateCreated
            ageRestriction          = _ageRestriction
            parent                  = _parent
            tagColor                = _tagColor.hexColor
        } else {
            return nil
        }
    }
}

extension SurveyCategory: Hashable {
    static func == (lhs: SurveyCategory, rhs: SurveyCategory) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
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
    var totalVotes: Int = 0
    var watchers: Int = 0
    var result: [Int: Date]?
    var userProfile: UserProfile?
    
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
        _dict[DjangoVariables.Survey.startDate] = startDate.toDateTimeString()
        var _answers: [[String: String]] = []
        for answer in answersWithoutID {
            _answers.append(["text" : answer])
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
    init?(new dict: [String: Any]) {
        //Necessary fields
        if let _title                   = dict[DjangoVariables.Survey.title] as? String,
            let _category               = dict[DjangoVariables.Survey.category] as? SurveyCategory,
            let _description            = dict[DjangoVariables.Survey.description] as? String,
            let _voteCapacity           = dict[DjangoVariables.Survey.voteCapacity] as? Int,
            let _isPrivate              = dict[DjangoVariables.Survey.isPrivate] as? Bool,
            let _answers                = dict[DjangoVariables.Survey.answers] as? [String] {
            
            title               = _title
            startDate           = Date()
            modified            = Date()
            category            = _category
            owner               = AppData.shared.userProfile.ID!
            description         = _description
            voteCapacity        = _voteCapacity
            isPrivate           = _isPrivate
            answersWithoutID    = _answers
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
        if let _ID                      = json["id"].intValue as? Int,
            let _title                  = json["title"].stringValue as? String,
            let _startDate              = json["start_date"] is NSNull ? nil : Date(dateTimeString: json["start_date"].stringValue as! String),
            var _endDate                = json["end_date"] is NSNull ? nil : Date(dateTimeString: json["end_date"].stringValue as! String),
            var _modified               = Date(dateTimeString: json["modified_at"].stringValue as! String) as? Date,
            let _category               = json["category"].intValue as? Int,
            let _owner                  = json["owner"].stringValue as? String,
            let _description            = json["description"].stringValue as? String,
            let _link                   = json["hlink"].stringValue as? String,
            let _voteCapacity           = json["voteCapacity"].intValue as? Int,
            let _isPrivate              = json["is_private"].boolValue as? Bool,
            let _answers                = json["answers"].arrayValue as? [JSON],
            let _imageURLs              = json["mediafiles"].arrayValue as? [JSON],
            let _watchers               = json["watchers"].intValue as? Int,
            let _totalVotes             = json["total_votes"].intValue as? Int,
            let _result                 = json["result"].arrayValue as? [JSON],
            let _balance                = json["balance"].intValue as? Int,
            let _userProfileDict        = json["userprofile"] as? JSON {
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
            totalVotes = _totalVotes
            watchers = _watchers
            AppData.shared.userProfile.balance = _balance
            
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
    
    func createSurveyLink() -> ShortSurvey? {
        if ID != nil, let surveyLink = ShortSurvey(id: ID!, title: title, startDate: startDate, category: category, completionPercentage: 0) as? ShortSurvey {
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
    var text: String
    var totalVotes: Int
    
    init?(json: JSON) {
        if let _text = json["text"].stringValue as? String,
            let _ID = json["id"].intValue as? Int,
            let _totalVotes = json["votes_count"].intValue as? Int {
            ID = _ID
            text = _text
            totalVotes = _totalVotes
        } else {
            print("JSON parse error")
            return nil
        }
    }
}
