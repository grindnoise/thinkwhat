//
//  SurveyCategory.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Topics {
    static let shared = Topics()
    private init() {}
    var all: [Topic] = []
    var active: Int {
        Topics.shared.all.filter({ !$0.isParentNode}).reduce(into: 0) { $0 += $1.active }
//        return all.filter({ $0.isParentNode }).reduce(into: 0) { $0 += $1.active }
    }
//    var tree: [[String: [Topic]]] = [[:]]
    
    //var _categories: [SurveyCategory: [SurveyCategory?]] = [:]
    
    func load(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode([Topic].self, from: data)
        } catch {
            fatalError("Topic init() threw error: \(error)")
        }
    }
    
//    func importJson(_ json: JSON) {
//        categories.removeAll()
//        tree.removeAll()
//        for i in json {
//            if let category = Topic(i.1) {
//                var array: [Topic] = []
//                categories.append(category)
//                if !i.1["children"].isEmpty {
//                    let subcategories = i.1["children"]
//                    for j in subcategories {
//                        if let subCategory = Topic(j.1, category) {
//                            categories.append(subCategory)
//                            array.append(subCategory)
//                        }
//                    }
//                } else {
//                    category.hasNoChildren = true
//                }
//                let entry:[String: [Topic]] = [category.title: array]
//                tree.append(entry)
//            }
//        }
//    }
    
    func updateCount(_ json: JSON) {
        if let _categories = json["categories"] as? JSON {
            if !_categories.isEmpty {
                for cat in all {
                    cat.total = 0
                    cat.active = 0
                }
                for cat in _categories {
                    if let category = self[Int(cat.0)!] as? Topic, let total = cat.1["total"].intValue as? Int, let active = cat.1["active"].intValue as? Int {
                        category.total = total
                        category.active = active
                        category.parent?.total += total
                        category.parent?.active += active
                    }
                }
            }
        }
    }
    
    subscript (ID: Int) -> Topic? {
        if let i = all.first(where: {$0.id == ID}) {
            return i
        } else {
            return nil
        }
    }
    
    subscript (title: String) -> Topic? {
        if let i = all.first(where: {$0.title == title}) {
            return i
        } else {
            return nil
        }
    }
}

class Topic: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, title, parent, children
        case createdAt      = "created_at"
        case ageRestriction = "age_restriction"
        case tagColor       = "tag_color"
        case total          = "total_count"
        case active         = "active_count"
    }
    
    let id: Int
    let title: String
    var parent: Topic? {
        return Topics.shared.all.filter({ $0.children.contains(self) }).first
    }
    var children: [Topic] = []
    var ageRestriction: Int
    var tagColor: UIColor
    var total: Int = 0
    var active: Int = 0
    var isParentNode: Bool {
        return !children.isEmpty
    }
    
    required init(from decoder: Decoder) throws {
        do {
            let container   = try decoder.container(keyedBy: CodingKeys.self)
            id              = try container.decode(Int.self, forKey: .id)
            title           = try container.decode(String.self, forKey: .title)
            tagColor        = try container.decode(String.self, forKey: .tagColor).hexColor ?? K_COLOR_GRAY
            ageRestriction  = (try? container.decode(Int.self, forKey: .ageRestriction)) ?? 0
            children        = (try? container.decode([Topic].self, forKey: .children)) ?? []
            total           = try container.decode(Int.self, forKey: .total)
            active           = try container.decode(Int.self, forKey: .active)
            if Topics.shared.all.filter({ $0.hashValue == hashValue }).isEmpty {
                Topics.shared.all.append(self)
            }
        } catch {
            throw error
        }
    }
}

extension Topic: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
    }
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
