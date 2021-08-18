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
    
    enum UserSurveyType {
        case Own, Favorite
    }
    
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
    var surveysCreated:     [Date: [SurveyRef]]   = [:]
    var surveysFavorite:    [Date: [SurveyRef]]   = [:]
    
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
            surveysCreated = [Date(): []]
            surveysFavorite = [Date(): []]
            lastVisit = _lastVisit
            updatedAt = Date()
        } else {
            return nil
        }
    }
    
    func updateStats(_ json: JSON) {
        if let _surveysAnsweredTotal   = json[DjangoVariables.UserProfile.surveysAnsweredTotal].intValue as? Int,
            let _favoriteSurveysTotal   = json[DjangoVariables.UserProfile.surveysFavoriteTotal].intValue as? Int,
            let _surveysCreatedTotal    = json[DjangoVariables.UserProfile.surveysCreatedTotal].intValue as? Int,
            let _lastVisit              = json[DjangoVariables.UserProfile.lastVisit] is NSNull ? nil : Date(dateTimeString: json[DjangoVariables.UserProfile.lastVisit].stringValue as! String) {
            surveysAnsweredTotal = _surveysAnsweredTotal
            surveysFavoriteTotal = _favoriteSurveysTotal
            surveysCreatedTotal = _surveysCreatedTotal
            lastVisit = _lastVisit
            updatedAt = Date()
        }
    }
    
    func importSurveys(_ type: UserSurveyType, json: JSON) {
        if !json.isEmpty {
            if type == .Own {
                surveysCreated.removeAll()
                surveysCreated[Date()] = []
            } else if type == .Favorite {
                surveysFavorite.removeAll()
                surveysFavorite[Date()] = []
            }
        }
        for i in json {
            if let survey = SurveyRef(i.1) {
                if let _foundObject = Surveys.shared.allLinks.filter({ $0.hashValue == survey.hashValue}).first {
                    if type == .Own {
                        if var container = surveysCreated.values.first, container.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty, let key = surveysCreated.keys.first {
                            container.append(_foundObject)
                            surveysCreated[key] = container
                            //container.append(_foundObject)
                        }
                    } else if type == .Favorite {
                        if var container = surveysFavorite.values.first, container.filter({ $0.hashValue == _foundObject.hashValue}).isEmpty, let key = surveysFavorite.keys.first {
                            container.append(_foundObject)
                            surveysFavorite[key] = container
                        }
                    }
                } else {
                    if type == .Own {
                        if var container = surveysCreated.values.first, let key = surveysCreated.keys.first {
                            container.append(survey)
                            surveysCreated[key] = container
                            Surveys.shared.allLinks.append(survey)
                        }
//                        if surveysCreated.filter({ $0.hashValue == survey.hashValue}).isEmpty {
//                            surveysCreated.append(survey)
//                        }
                    } else if type == .Favorite {
                        if var container = surveysFavorite.values.first, let key = surveysFavorite.keys.first {
                            container.append(survey)
                            surveysFavorite[key] = container
                            Surveys.shared.allLinks.append(survey)
                        }
//                        if surveysFavorite.filter({ $0.hashValue == survey.hashValue}).isEmpty {
//                            surveysFavorite.append(survey)
//                        }
                    }
                }
            }
        }
        //If smth changes
        if type == .Own {
            NotificationCenter.default.post(name: Notifications.Surveys.UserSurveysUpdated, object: nil)
            surveysCreatedTotal = surveysCreated.values.first?.count ?? surveysCreatedTotal
        } else if type == .Favorite {
            NotificationCenter.default.post(name: Notifications.Surveys.UserFavoriteSurveysUpdated, object: nil)
            surveysFavoriteTotal = surveysFavorite.values.first?.count ?? surveysFavoriteTotal
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
