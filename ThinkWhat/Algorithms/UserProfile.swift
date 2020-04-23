//
//  UserProfile.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserProfiles {
    static let shared = UserProfiles()
    private init() {}
    var container: [UserProfile] = []
    
    func append(_ userProfile: UserProfile) {
        var contains = false
        for i in container {
            if i == userProfile {
                contains = true
                break
            }
        }
        if !contains {
            container.append(userProfile)
        }
    }
}

class UserProfile {
    var ID:         Int
    var name:       String
    var age:        Int
    var gender:     Gender
    var imageURL:   String
    var image:      UIImage?
    var hashValue:  Int {
        return ObjectIdentifier(self).hashValue
    }
    
    init?(_ json: JSON) {
        if let _ID                      = json["id"].intValue as? Int,
            let _name                   = json["name"].stringValue as? String,
            let _age                    = json["age"].intValue as? Int,
            let _genderString           = json["gender"].stringValue as? String,
            let _imageURL               = json["image"].stringValue as? String,
            let _gender                 = Gender(rawValue: _genderString) {
            ID = _ID
            name = _name
            age = _age
            gender = _gender
            imageURL = _imageURL
        } else {
            return nil
        }
    }
    
    static func === (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        if lhs.ID == rhs.ID,
            lhs.age == rhs.age,
            lhs.gender == rhs.gender,
            lhs.name == rhs.name,
            lhs.imageURL == rhs.imageURL {
            return true
        }
        return false
    }
}
