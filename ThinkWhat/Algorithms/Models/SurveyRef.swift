//
//  SurveyRef.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SurveyRef {
    var ID: Int
    var title: String
    var startDate: Date
    var category: SurveyCategory
    //    var completionPercentage: Int
    var likes: Int
    var views: Int
    var type: SurveyType
    var isComplete: Bool
    var isOwn: Bool
    var isFavorite: Bool
    //    var survey
    //    var hashValue: Int {
    //        return ObjectIdentifier(self).hashValue
    //    }
    
    //    init(id _id: Int, title _title: String, startDate _startDate: Date, category _category: SurveyCategory, completionPercentage _completionPercentage: Int, type _type: SurveyType) {//}, likes _likes: Int) {
    init(id _id: Int, title _title: String, startDate _startDate: Date, category _category: SurveyCategory, type _type: SurveyType, likes _likes: Int = 0, views _views: Int = 0, isOwn _isOwn: Bool, isComplete _isComplete: Bool, isFavorite _isFavorite: Bool) {
        ID                      = _id
        title                   = _title
        category                = _category
        //        completionPercentage    = _completionPercentage
        startDate               = _startDate
        likes                   = _likes
        views                   = _views
        type                    = _type
        isOwn                   = _isOwn
        isComplete              = _isComplete
        isFavorite              = _isFavorite
        //likes                   = _likes
    }
    
    init?(_ json: JSON) {
        if  let _ID                     = json["id"].intValue as? Int,
            let _title                  = json["title"].stringValue as? String,
            let _categoryID             = json["category"].intValue as? Int,
            let _category               = SurveyCategories.shared[_categoryID],
            let _startDate              = Date(dateTimeString: (json["start_date"].stringValue as? String)!) as? Date,
            //            let _completionPercentage   = json["vote_capacity"].intValue as? Int,
            let _likes                  = json["likes"].intValue as? Int,
            let _views                  = json["views"].intValue as? Int,
            let _isOwn                  = json["is_own"].boolValue as? Bool,
            let _isComplete             = json["is_complete"].boolValue as? Bool,
            let _isFavorite             = json["is_favorite"].boolValue as? Bool,
            let _type                   = json["type"].stringValue as? String {
            ID                      = _ID
            title                   = _title
            category                = _category
            //            completionPercentage    = _completionPercentage
            startDate               = _startDate
            likes                   = _likes
            views                   = _views
            isOwn                   = _isOwn
            isComplete              = _isComplete
            isFavorite              = _isFavorite
            type                    = SurveyType(rawValue: _type)!
        } else {
            return nil
        }
    }
}

extension SurveyRef: Hashable {
    static func == (lhs: SurveyRef, rhs: SurveyRef) -> Bool {
        return lhs.hashValue == rhs.hashValue
        //        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(ID)
    }
}
