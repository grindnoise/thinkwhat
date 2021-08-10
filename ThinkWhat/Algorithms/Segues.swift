//
//  Segues.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.07.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation

struct Segues {
    struct Launch {
        static let App                      = "APP"
        static let Auth                     = "AUTH"
    }
    
    struct Auth {
        static let AppFromMailSignin        = "APP_FROM_MAIL_SIGNIN"
        static let AppFromTerms             = "APP_FROM_TERMS"
        static let AppFromProfile           = "APP_FROM_PROFILE"
        static let SocialAuth               = "SOCIAL"
        static let MailValidationFromSignup = "MAIL_VALID_SIGNUP"
        static let MailValidationFromSignin = "MAIL_VALID_SIGNIN"
        static let Terms                    = "TERMS"
        static let TermsFromValidation      = "TERMS_VALID"
        static let TermsFromStartScreen     = "TERMS_START_SCREEN"
        static let MailAuth                 = "MAILAUTH"
        static let PasswordRecovery         = "PWD_RECOVERY"
        static let ProfileFromConfirmation  = "PROFILE_FROM_CONFIRMATION"
        static let ProfileFromAuth          = "PROFILE_FROM_AUTH"
    }
    
    struct App {
        static let ProfileToSettingsSelection           = "PROFILE_SETINGS_SELECTION"
        static let ProfileToInfo                        = "INFO"
        static let Logout                               = "BACK_TO_AUTH"
        static let FeedToSurveyFromTop                  = "FEED_TO_SURVEY_FROM_TOP"
        static let FeedToSurvey                         = "FEED_TO_SURVEY"
        static let FeedToNewSurvey                      = "FEED_TO_NEW_SURVEY"
        static let FeedToUser                           = "FEED_TO_USER"
        static let FeedToCategory                       = "FEED_TO_CATEGORY"
        static let UserSurveysToSurvey                  = "USER_SURVEYS_TO_SURVEY"
        static let UserSurveysToNewSurvey               = "OWN_TO_NEW_SURVEY"
        static let NewSurveyToAnonymity                 = "NEW_TO_ANONYMITY"
        static let NewSurveyToCategorySelection         = "NEW_TO_CATEGORY_SELECTION"
        static let NewSurveyToAnonimitySelection        = "NEW_TO_ANONIMITY_SELECTION"
        static let NewSurveyToPrivacySelection          = "NEW_TO_PRIVACY_SELECTION"
        static let NewSurveyToCommentingSelection       = "NEW_TO_COMMENTING_SELECTION"
        static let NewSurveyToHotSelection              = "NEW_TO_HOT_SELECTION"
        static let NewSurveyToTypingViewController      = "NEW_TO_TYPE"
        static let NewSurveyToVotesCountViewController  = "NEW_TO_VOTES_COUNT"
        static let NewSurveyToHyperlinkViewController   = "NEW_TO_HYPERLINK"
        static let NewSurveyToImagePreviewViewController = "NEW_TO_IMAGES"
        static let SurveyToUser                         = "SURVEY_TO_USER"
        static let SurveyToClaim                        = "SURVEY_TO_CLAIM"
        static let UserToUserSurveys                    = "USER_TO_USER_SURVEYS"
        static let UserToUserFavoriteSurveys            = "USER_TO_FAVORITE_USER_SURVEYS"
        static let CategoryToSurveys                    = "CATEGORY_TO_SURVEYS"
    }
    
    struct NewSurvey {
        static let Poll             = "POLL"
        static let Rating           = "RATING"
        static let Results          = "RESULTS"
        static let BackToEditing    = "RESULTS_TO_NEW"
        static let BackToSurveys    = "RESULTS_TO_SURVEYS"
    }
    
    struct Survey {
        static let Name             = "NAME"
    }
}
