//
//  Survey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Surveys {
    static let shared = Surveys()
    private init() {}
    var topSurveys:         [SurveyLink] = []
    var newSurveys:         [SurveyLink] = []
    var byCategory:         [SurveyCategory: [SurveyLink]] = [:]
    var ownSurveys:         [SurveyLink] = []
    var favoriteSurveys:    [SurveyLink] = []
    var downloadedSurveys:  [Survey] = []
    
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
            } else if i.0 == "own" && !i.1.isEmpty {
                ownSurveys.removeAll()
                for k in i.1 {
                    if let survey = SurveyLink(k.1) {
                        ownSurveys.append(survey)
                    }
                }
                NotificationCenter.default.post(name: kNotificationOwnSurveysUpdated, object: nil)
            } else if i.0 == "favorite" && !i.1.isEmpty {
                favoriteSurveys.removeAll()
                for k in i.1 {
                    if let survey = SurveyLink(k.1) {
                        favoriteSurveys.append(survey)
                    }
                }
                NotificationCenter.default.post(name: kNotificationFavoriteSurveysUpdated, object: nil)
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
    
    deinit {
        print("deinit")
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
    var ID: Int
    
    init?(_ json: JSON) {
        if  let _ID                     = json["id"].intValue as? Int {
            ID = _ID
        } else {
            return nil
        }
    }
}
