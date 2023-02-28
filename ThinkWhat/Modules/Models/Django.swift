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
    static let description              = "description"
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
    static let surveysAnsweredTotal     = "completed_surveys_count"
    static let surveysFavoriteTotal     = "favorite_surveys_count"
    static let surveysCreatedTotal      = "own_surveys_count"
    static let lastVisit                = "last_visit"
    static let balance                  = "balance"
    static let topPublicationCategories = "top_pub_categories"
    static let tiktokURL                = "tiktok_url"
    static let instagramURL             = "instagram_url"
    static let facebookURL              = "facebook_url"
    static let vkURL                    = "vk_url"
    static let city                     = "city"
    static let locale                   = "locale"
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
  
  public private(set) var surveyTitleMinLength:           Int!
  public private(set) var surveyTitleMaxLength:           Int!
  public private(set) var surveyDescriptionMinLength:     Int!
  public private(set) var surveyDescriptionMaxLength:     Int!
  public private(set) var surveyAnswerTitleMinLength:     Int!
  public private(set) var surveyAnswerTitleMaxLength:     Int!
  public private(set) var surveyAnswerTextMinLength:      Int!
  public private(set) var surveyAnswerTextMaxLength:      Int!
  public private(set) var surveyAnswerMaxFreeCount:       Int!
  public private(set) var surveyQuestionMinLength:        Int!
  public private(set) var surveyQuestionMaxLength:        Int!
  public private(set) var surveyMediaTitleMinLength:      Int!
  public private(set) var surveyMediaTitleMaxLength:      Int!
  public private(set) var commentMinLength:               Int!
  public private(set) var commentMaxLength:               Int!
  public private(set) var anonMinLength:                  Int!
  public private(set) var anonMaxLength:                  Int!
  public private(set) var feedbackDescriptionMinLength:   Int!
  public private(set) var feedbackDescriptionMaxLength:   Int!
  public private(set) var userprofileDescriptionMinLength:Int!
  public private(set) var userprofileDescriptionMaxLength:Int!
  
  
  func importJson(_ json: JSON) {
    for i in json {
      if i.0 == "survey" {
        for j in i.1 {
          if j.0 == "title", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            surveyTitleMinLength = dict["min_length"]!
            surveyTitleMaxLength = dict["max_length"]!
          } else if j.0 == "description", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            surveyDescriptionMinLength = dict["min_length"]!
            surveyDescriptionMaxLength = dict["max_length"]!
          } else if j.0 == "question", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            surveyQuestionMinLength = dict["min_length"]!
            surveyQuestionMaxLength = dict["max_length"]!
          }
        }
      } else if i.0 == "survey_answer" {
        for j in i.1 {
          if j.0 == "title", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            surveyAnswerTitleMinLength = dict["min_length"]!
            surveyAnswerTitleMaxLength = dict["max_length"]!
          } else if j.0 == "description", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            surveyAnswerTextMinLength = dict["min_length"]!
            surveyAnswerTextMaxLength = dict["max_length"]!
          } else if j.0 == "free_count", let value = j.1.int {
            surveyAnswerMaxFreeCount = value
          }
        }
      } else if i.0 == "survey_media" {
        for j in i.1 {
          if j.0 == "title", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            surveyMediaTitleMinLength = dict["min_length"]!
            surveyMediaTitleMaxLength = dict["max_length"]!
          }
        }
      } else if i.0 == "comment" {
        for j in i.1 {
          if j.0 == "body", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            commentMinLength = dict["min_length"]!
            commentMaxLength = dict["max_length"]!
          } else if j.0 == "anon", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            anonMinLength = dict["min_length"]!
            anonMaxLength = dict["max_length"]!
          }
        }
      } else if i.0 == "feedback" {
        for j in i.1 {
          if j.0 == "description", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            feedbackDescriptionMinLength = dict["min_length"]!
            feedbackDescriptionMaxLength = dict["max_length"]!
          }
        }
      } else if i.0 == "userprofile" {
        for j in i.1 {
          if j.0 == "description", let dict = j.1.dictionaryObject as? Dictionary<String, Int>  {
            userprofileDescriptionMinLength = dict["min_length"]!
            userprofileDescriptionMaxLength = dict["max_length"]!
          }
        }
      }
      
    }
  }
}

class PriceList {
  
  static let shared = PriceList()
  
  private init() {}
  
  
  public private(set) var like:           Int!
  public private(set) var vote:           Int!
  //    public private(set) var anonPost:       Int { return { _anonPost }()}
  public private(set) var hotPost:        Int!
  public private(set) var extraAnswers:   Int!
  
  func importJson(_ json: JSON) {
    for i in json {
      if let dict = i.1.dictionaryObject, let key = dict["type"] as? String, let value = dict["cost"] as? Int {
        if key == DjangoVariables.PriceList.like {
          like = value
          //                } else if key == DjangoVariables.PriceList.anonPost {
          //                    _anonPost = value
        } else if key == DjangoVariables.PriceList.vote {
          vote = value
        } else if key == DjangoVariables.PriceList.hotPost {
          hotPost = value
        } else if key == DjangoVariables.PriceList.extraAnswers {
          extraAnswers = value
        }
      }
    }
  }
}
