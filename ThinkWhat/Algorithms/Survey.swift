//
//  Survey.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Surveys: ServerProtocol {
    static let shared = Surveys()
    private init() {}
    var topSurveys: [SurveyLink] = []
    var newSurveys: [SurveyLink] = []
    
    func importTopSurveys(_ json: JSON) {
        topSurveys.removeAll()
        for i in json {
            if let survey = SurveyLink(i.1) {
                topSurveys.append(survey)
            }
        }
        NotificationCenter.default.post(name: kNotificationTopSurveysUpdated, object: nil)
    }
    func importNewSurveys(_ json: JSON) {
        newSurveys.removeAll()
        for i in json {
            if let survey = SurveyLink(i.1) {
                newSurveys.append(survey)
            }
        }
        NotificationCenter.default.post(name: kNotificationNewSurveysUpdated, object: nil)
    }
    
    func eraseData() {
        topSurveys.removeAll()
        newSurveys.removeAll()
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

class SurveyCategories: ServerProtocol {
    static let shared = SurveyCategories()
    private init() {}
    var categories: [SurveyCategory] = []
    
    func importJson(_ json: JSON) {
        categories.removeAll()
        for i in json {
            if let category = SurveyCategory(i.1) {
                categories.append(category)
                if !i.1["children"].isEmpty {
                    let subcategories = i.1["children"]
                    for j in subcategories {
                        if let subCategory = SurveyCategory(j.1, category) {
                            categories.append(subCategory)
                        }
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
}

class SurveyCategory {
    let ID: Int
    let title: String
    let dateCreated: Date
    var parent: SurveyCategory?
    var ageRestriction: Int?
    
    init?(_ json: JSON, _ _parent: SurveyCategory? = nil) {
        if  let _ID                     = json["id"].intValue as? Int,
            let _title                  = json["title"].stringValue as? String,
            let _dateCreated            = json["created_at"] is NSNull ? nil : Date(dateTimeString: json["created_at"].stringValue as! String),
            let _ageRestriction         = json["age_restriction"] is NSNull ? nil : json["age_restriction"].intValue as? Int {
            ID                      = _ID
            title                   = _title
            dateCreated             = _dateCreated
            ageRestriction          = _ageRestriction
            parent                  = _parent
        } else {
            return nil
            
        }
    }
}
