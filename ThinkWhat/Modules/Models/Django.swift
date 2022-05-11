//
//  Django.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.07.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

enum DjangoError: String {
    case InvalidGrant = "invalid credentials given."
    case AccessDenied = "access_denied"
    enum Authentication: String {
        case ConnectionFailed = "failed to establish a new connection"
    }
}

struct DjangoVariables {
    static let ID                           = "id"
    struct User {
        static let firstName                = "first_name"
        static let lastName                 = "last_name"
        static let email                    = "email"
    }
    struct UserProfile {
        static let owner                    = "owner"
        static let name                     = "name"
        static let gender                   = "gender"
        static let birthDate                = "birth_date"
        static let age                      = "age"
        static let image                    = "image"
        static let isDeleted                = "is_del"
        static let isBanned                 = "is_banned"
        static let credit                   = "credit"
        static let facebookID               = "facebook_ID"
        static let vkID                     = "vk_ID"
        static let isEdited                 = "is_edited"
        static let isEmailVerified          = "is_email_verified"
        static let surveysAnsweredTotal     = "surveys_results_count"
        static let surveysFavoriteTotal     = "favorite_surveys_count"
        static let surveysCreatedTotal      = "surveys_count"
        static let lastVisit                = "last_visit"
        static let balance                  = "balance"
        static let topPublicationCategories = "top_pub_categories"
        static let tiktokURL                = "tiktok_url"
        static let instagramURL             = "instagram_url"
        static let facebookURL              = "facebook_url"
        static let vkURL                    = "vk_url"
        static let city                     = "city"
    }
    struct Survey {
        static let category                 = "category"
        static let owner                    = "owner"
        static let title                    = "title"
        static let description              = "description"
        static let question                 = "question"
        static let hlink                    = "hlink"
        static let voteCapacity             = "vote_capacity"
        static let isPrivate                = "is_private"
        static let isAnonymous              = "is_anonymous"
        static let isCommentingAllowed      = "is_commenting_allowed"
        static let answers                  = "answers"
        static let images                   = "media"
        static let startDate                = "start_date"
        static let endDate                  = "end_date"
        static let modifiedAt               = "modified_at"
        static let likes                    = "likes"
        static let views                    = "views"
        static let userprofile              = "userprofile"
        static let type                     = "type"
        static let watchers                 = "watchers"
        static let totalVotes               = "votes_total"
        static let result                   = "result"
        static let postHot                  = "post_hot"
    }
    struct SurveyAnswer {
        static let title                    = "title"
        static let description              = "description"
        static let url                      = "hlink"
        static let file                     = "file"
        static let image                    = "image"
        static let totalVotes               = "votes_total"
    }
    struct PriceList {
        static let like                     = "like"
        static let vote                     = "vote"
//        static let anonPost                 = "anonimity"
        static let hotPost                  = "post_hot"
        static let extraAnswers             = "extra_answers"
    }
//    struct FieldRestrictions {
//        struct Survey {
//            struct Title {
//                minLength =
//            }
//        }
//        static let surveyTitleLength        = 30
//        static let surveyQuestionLength     = 10000
//        static let surveyAnswerLength       = 100
//    }
}

class ModelProperties {
    static let shared = ModelProperties()
    private init() {}
    private var _surveyTitleMinLength:       Int = 0
    private var _surveyTitleMaxLength:       Int = 0
    private var _surveyDescriptionMinLength: Int = 0
    private var _surveyDescriptionMaxLength: Int = 0
    private var _surveyQuestionMinLength:    Int = 0
    private var _surveyQuestionMaxLength:    Int = 0
    private var _surveyAnswerTitleMinLength: Int = 0
    private var _surveyAnswerTitleMaxLength: Int = 0
    private var _surveyAnswerTextMinLength:  Int = 0
    private var _surveyAnswerTextMaxLength:  Int = 0
    private var _surveyAnswerMaxFreeCount:   Int = 0
    

    var surveyTitleMinLength:       Int { return { _surveyTitleMinLength }()}
    var surveyTitleMaxLength:       Int { return { _surveyTitleMaxLength }()}
    var surveyDescriptionMinLength: Int { return { _surveyDescriptionMinLength }()}
    var surveyDescriptionMaxLength: Int { return { _surveyDescriptionMaxLength }()}
    var surveyAnswerTitleMinLength: Int { return { _surveyAnswerTitleMinLength }()}
    var surveyAnswerTitleMaxLength: Int { return { _surveyAnswerTitleMaxLength }()}
    var surveyAnswerTextMinLength:  Int { return { _surveyAnswerTextMinLength }()}
    var surveyAnswerTextMaxLength:  Int { return { _surveyAnswerTextMaxLength }()}
    var surveyAnswerMaxFreeCount:   Int { return { _surveyAnswerMaxFreeCount }()}
    var surveyQuestionMinLength:  Int { return { _surveyQuestionMinLength }()}
    var surveyQuestionMaxLength:   Int { return { _surveyQuestionMaxLength }()}
    
    func importJson(_ json: JSON) {
        for i in json {
            if i.0 == "survey" {
                for j in i.1 {
                    if j.0 == "title", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
                        _surveyTitleMinLength = dict["min_length"]!
                        _surveyTitleMaxLength = dict["max_length"]!
                    } else if j.0 == "description", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
                        _surveyDescriptionMinLength = dict["min_length"]!
                        _surveyDescriptionMaxLength = dict["max_length"]!
                    } else if j.0 == "question", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
                        _surveyQuestionMinLength = dict["min_length"]!
                        _surveyQuestionMaxLength = dict["max_length"]!
                    }
                }
            } else if i.0 == "survey_answer" {
                for j in i.1 {
                    if j.0 == "title", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
                        _surveyAnswerTitleMinLength = dict["min_length"]!
                        _surveyAnswerTitleMaxLength = dict["max_length"]!
                    } else if j.0 == "description", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
                        _surveyAnswerTextMinLength = dict["min_length"]!
                        _surveyAnswerTextMaxLength = dict["max_length"]!
                    } else if j.0 == "free_count", let value = j.1.intValue as? Int {
                        _surveyAnswerMaxFreeCount = value
                    }
                }
            }
        }
    }
}

class PriceList {
    static let shared = PriceList()
    private init() {}
    private var _like:              Int = 0
    private var _vote:              Int = 0
//    private var _anonPost:          Int = 0
    private var _hotPost:           Int = 0
    private var _extraAnswers:  Int = 0
    
    var like:       Int { return { _like }()}
    var vote:       Int { return { _vote }()}
//    var anonPost:       Int { return { _anonPost }()}
    var hotPost:       Int { return { _hotPost }()}
    var extraAnswers:       Int { return { _extraAnswers }()}
    
    func importJson(_ json: JSON) {
        for i in json {
            if let dict = i.1.dictionaryObject, let key = dict["type"] as? String, let value = dict["cost"] as? Int {
                if key == DjangoVariables.PriceList.like {
                    _like = value
//                } else if key == DjangoVariables.PriceList.anonPost {
//                    _anonPost = value
                } else if key == DjangoVariables.PriceList.vote {
                    _vote = value
                } else if key == DjangoVariables.PriceList.hotPost {
                    _hotPost = value
                } else if key == DjangoVariables.PriceList.extraAnswers {
                    _extraAnswers = value
                }
            }
        }
    }
}
