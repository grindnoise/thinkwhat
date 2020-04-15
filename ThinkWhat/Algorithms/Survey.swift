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
    static let shared = Surveys()
    private init() {}
    var topSurveys:         [SurveyLink] = []
    var newSurveys:         [SurveyLink] = [] {
        didSet {
            if oldValue.count != newSurveys.count {
                let sorted = newSurveys.sorted { $0.startDate > $1.startDate }
                newSurveys = sorted
            }
        }
    }
    var byCategory:         [SurveyCategory: [SurveyLink]] = [:]
    var ownSurveys:         [SurveyLink] = []
    var favoriteSurveys:    [SurveyLink: Date] = [:]
    var downloadedSurveys:  [Survey] = []
    var completedSurveyIDs: [Int] = []//Completed surveys IDs
    
    func importSurveys(_ json: JSON) {
        for i in json {
            if i.0 == "top" && !i.1.isEmpty {
                topSurveys.removeAll()
                for j in i.1 {
                    if let survey = SurveyLink(j.1) {
                        topSurveys.append(survey)
                    }
                }
                NotificationCenter.default.post(name: kNotificationTopSurveysUpdated, object: nil)
            } else if i.0 == "new" && !i.1.isEmpty {
                newSurveys.removeAll()
                for k in i.1 {
                    if let survey = SurveyLink(k.1) {
                        newSurveys.append(survey)
                    }
                }
                NotificationCenter.default.post(name: kNotificationNewSurveysUpdated, object: nil)
            }  else if i.0 == "by_category" && !i.1.isEmpty {
                byCategory.removeAll()
                for cat in i.1 {
                    let category = SurveyCategories.shared[Int(cat.0)!]
                    var data: [SurveyLink] = []
                    for survey in cat.1 {
                        data.append(SurveyLink(survey.1)!)
                    }
                    byCategory[category!] = data
                }
                NotificationCenter.default.post(name: kNotificationSurveysByCategoryUpdated, object: nil)
            } else if i.0 == "own" {
                ownSurveys.removeAll()
                if !i.1.isEmpty {
                    for k in i.1 {
                        if let survey = SurveyLink(k.1) {
                            ownSurveys.append(survey)
                        }
                    }
                }
                NotificationCenter.default.post(name: kNotificationOwnSurveysUpdated, object: nil)
            } else if i.0 == "favorite" {
                favoriteSurveys.removeAll()
                if !i.1.isEmpty {
                    for k in i.1 {
//                        print(k)
                        if let date = Date(dateTimeString: (k.1["added_at"].stringValue as? String)!) as? Date,
                            let survey = SurveyLink(k.1["survey"]) {
                            favoriteSurveys[survey] = date
                        }
                    }
                }
                NotificationCenter.default.post(name: kNotificationFavoriteSurveysUpdated, object: nil)
            }  else if i.0 == "user_results" {
                completedSurveyIDs.removeAll()
                for k in i.1 {
                    if let id = k.1["survey"].intValue as? Int {
                        completedSurveyIDs.append(id)
                    }
                }
            }
        }
    }
    
    func eraseData() {
        topSurveys.removeAll()
        newSurveys.removeAll()
        byCategory.removeAll()
        ownSurveys.removeAll()
        favoriteSurveys.removeAll()
        downloadedSurveys.removeAll()
    }
    
    subscript (ID: Int) -> Survey? {
        if let i = downloadedSurveys.first(where: {$0.ID == ID}) {
            return i
        } else {
            return nil
        }
    }
}

class SurveyLink {
    var ID: Int
    var title: String
    var startDate: Date
    var category: SurveyCategory?
    var completionPercentage: Int
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
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

extension SurveyLink: Hashable {
    static func == (lhs: SurveyLink, rhs: SurveyLink) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
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

class Survey {
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
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
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
            let _startDate              = json["start_date"] is NSNull ? nil : Date(dateTimeString: json["end_date"].stringValue as! String),
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
            let _balance                = json["balance"].intValue as? Int {
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
        } else {
            return nil
        }
    }
    
    func createSurveyLink() -> SurveyLink? {
        if ID != nil, let surveyLink = SurveyLink(id: ID!, title: title, startDate: startDate, category: category, completionPercentage: 0) as? SurveyLink {
            return surveyLink
        }
        return nil
    }
    
    func getAnswerVotePercentage(_ answerVotesCount: Int) -> Int {
        return Int((Double(answerVotesCount) * Double(100) / Double(totalVotes)).rounded())
    }
}

extension Survey: Hashable {
    static func == (lhs: Survey, rhs: Survey) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
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
