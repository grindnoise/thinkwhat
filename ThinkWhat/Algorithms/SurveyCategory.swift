//
//  SurveyCategory.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

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
                } else {
                    category.hasNoChildren = true
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
    var hasNoChildren = false
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
//    var pointInParentView: CGPoint = .zero
//    var icon: UIView!
    
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
            if _parent != nil {
                tagColor            = parent!.tagColor
            } else {
                tagColor            = _tagColor.hexColor
            }
//            if let _icon = SurveyCategoryIcons.shared.container[ID] as? UIView {
//                icon = _icon
//            } else {
//                icon = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
//                icon.backgroundColor = .clear
//            }
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
