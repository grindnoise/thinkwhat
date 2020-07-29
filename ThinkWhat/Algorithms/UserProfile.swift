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
    
//    func append(_ userProfile: UserProfile) {
//        var contains = false
//        for i in container {
//            if i == userProfile {
//                contains = true
//                break
//            }
//        }
//        if !contains {
//            container.append(userProfile)
//        }
//    }
}

class UserProfile {
    var ID:         Int
    var name:       String
    var age:        Int
    var gender:     Gender
    var imageURL:   String
    var image:      UIImage?
    var surveysAnsweredTotal: Int
    var surveysFavoriteTotal: Int
    var surveysCreatedTotal: Int
    var updatedAt: Date
    var lastVisit: Date
    var hashValue:  Int {
        return ObjectIdentifier(self).hashValue
    }
    
    init?(_ json: JSON) {
        if let _ID                      = json[DjangoVariables.ID].intValue as? Int,
            let _name                   = json[DjangoVariables.UserProfile.name].stringValue as? String,
            let _age                    = json[DjangoVariables.UserProfile.age].intValue as? Int,
            let _genderString           = json[DjangoVariables.UserProfile.gender].stringValue as? String,
            let _imageURL               = json[DjangoVariables.UserProfile.image].stringValue as? String,
            let _surveysAnsweredTotal   = json[DjangoVariables.UserProfile.surveysAnsweredTotal].intValue as? Int,
            let _favoriteSurveysTotal   = json[DjangoVariables.UserProfile.surveysFavoriteTotal].intValue as? Int,
            let _surveysCreatedTotal    = json[DjangoVariables.UserProfile.surveysCreatedTotal].intValue as? Int,
            let _lastVisit              = json[DjangoVariables.UserProfile.lastVisit] is NSNull ? nil : Date(dateTimeString: json[DjangoVariables.UserProfile.lastVisit].stringValue as! String),
            let _gender                 = Gender(rawValue: _genderString) {
            ID = _ID
            name = _name
            age = _age
            gender = _gender
            imageURL = _imageURL
            surveysAnsweredTotal = _surveysAnsweredTotal
            surveysFavoriteTotal = _favoriteSurveysTotal
            surveysCreatedTotal = _surveysCreatedTotal
            lastVisit = _lastVisit
            updatedAt = Date()
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
