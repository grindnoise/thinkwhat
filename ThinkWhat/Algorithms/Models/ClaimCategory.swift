//
//  ClaimCategory.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

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
