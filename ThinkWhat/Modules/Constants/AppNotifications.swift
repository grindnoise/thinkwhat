//
//  AppNotifications.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

struct Notifications {
    struct Network {
        static let InternetConnectionChange        = Notification.Name("InternetConnectionChange")
        static let RemoteReachable                 = Notification.Name("smsNotificationApiReachable")
        static let RemoteNotReachable              = Notification.Name("smsNotificationApiNotReachable")
    }
    
    struct OAuth {
        static let TokenReceived                   = Notification.Name("NotificationTokenReceived")
        static let TokenError                      = Notification.Name("NotificationTokenError")
        static let TokenRevoked                    = Notification.Name("NotificationTokenRevoked")
        static let TokenWrongCredentials           = Notification.Name("NotificationTokenWrongCredentials")
        static let TokenConnectionError            = Notification.Name("NotificationTokenConnectionError")
        static let TokenAccessDenied               = Notification.Name("NotificationTokenAccessDenied")
    }
    
    struct EmailResponse {
        static let Received                        = Notification.Name("NotificationEmailResponseReceived")
        static let Expired                         = Notification.Name("NotificationEmailResponseExpired")
    }

    struct Userprofiles {
        static let SubscribedForUpdated             = Notification.Name("NotificationUpdateSubscribedFor")
        static let SubscribersUpdated               = Notification.Name("NotificationSubscribersUpdated")
        static let ImageDownloaded                  = Notification.Name("ImageDownloaded")
    }
    
    struct System {
        static let UpdateStats                      = Notification.Name("NotificationUpdateStats")
        static let HideKeyboard                     = Notification.Name("NotificationHideKeyboard")
    }
    
    struct SurveyAnswers {
        static let TotalVotes                       = Notification.Name("SurveyAnswerTotalVotes")
        static let VotersAppend                     = Notification.Name("SurveyAnswerVotersAppend")
    }
    
    struct Comments {
        static let Append                           = Notification.Name("NotificationCommentAppend")
    }
    
    struct Surveys {
        static let SubscriptionAppend               = Notification.Name("SurveysSubscriptionAppend")
        static let NewAppend                        = Notification.Name("SurveysNewAppend")
        static let TopAppend                        = Notification.Name("SurveysTopAppend")
        static let OwnAppend                        = Notification.Name("SurveysOwnAppend")
        static let FavoriteAppend                   = Notification.Name("SurveysFavoriteAppend")
        static let TopicAppend                      = Notification.Name("SurveysTopicAppend")
        static let Claim                            = Notification.Name("SurveyClaim")
        static let Ban                              = Notification.Name("SurveyBan")
        
        
        static let UnsetFavorite                    = Notification.Name("NotificationFavoriteSurveyUnset")
        static let SetFavorite                      = Notification.Name("NotificationFavoriteSurveySet")
        static let SwitchFavorite                   = Notification.Name("NotificationSwitchFavorite")
        static let UpdateFavorite                   = Notification.Name("NotificationFavoriteSurveysUpdated")
        static let UpdateTopSurveys                 = Notification.Name("NotificationTopSurveysUpdated")
        static let UpdateNewSurveys                 = Notification.Name("NotificationNewSurveysUpdated")
        static let SwitchHot                        = Notification.Name("NotificationSwitchHot")
        static let UpdateSubscriptions              = Notification.Name("NotificationSubscriptionsReceived")
        static let UpdateOwn                        = Notification.Name("NotificationOwnSurveysUpdated")
        static let UpdateAll                        = Notification.Name("NotificationAllSurveysUpdated")
        static let Empty                            = Notification.Name("NotificationZeroReceived")
//        static let Empty                            = Notification.Name("NotificationZeroSubscriptionsReceived")
        
        static let ZeroFavorites                    = Notification.Name("NotificationZeroFavoritesReceived")
        static let ZeroSubscriptions                = Notification.Name("NotificationZeroSubscriptionsReceived")
        static let ZeroTop                          = Notification.Name("NotificationZeroTopReceived")
        static let ZeroOwn                          = Notification.Name("NotificationZeroOwnReceived")
        static let ZeroNew                          = Notification.Name("NotificationZeroNewReceived")
        
        static let Rejected                         = Notification.Name("NotificationReject")
        
        static let Completed                        = Notification.Name("NotificationSurveyCompleted")
        static let Progress                         = Notification.Name("NotificationSurveyProgress")
        static let Views                            = Notification.Name("NotificationSurveyViews")
        static let Rating                           = Notification.Name("NotificationSurveyRating")
        static let Watchers                         = Notification.Name("NotificationSurveyWatchers")
        static let Likes                            = Notification.Name("NotificationSurveyLikes")
        static let CommentsTotal                    = Notification.Name("NotificationCommentsTotal")
        
        
        static let SurveysStackUpdated              = Notification.Name("NotificationSurveysStackUpdated")
        static let OwnSurveysUpdated                = Notification.Name("NotificationOwnSurveysUpdated")
        static let OwnSurveysReceived               = Notification.Name("NotificationOwnSurveysReceived")
        static let SurveysByCategoryUpdated         = Notification.Name("NotificationSurveysByCategoryUpdated")
        
        static let UserSurveysUpdated               = Notification.Name("NotificationUserSurveysUpdated")
        static let UserFavoriteSurveysUpdated       = Notification.Name("NotificationUserFavoriteSurveysUpdated")
        static let NewSurveyPostError               = Notification.Name("NotificationNewSurveyPostError")
        
    }
    
    struct UI {
        static let ClaimSignAppeared               = Notification.Name("ClaimSignAppeared")
        static let CategorySelected                = Notification.Name("CategorySelected")
        static let UserImageChanged                = Notification.Name("NotificationUserImageChanged")
        static let ImageReceived                   = Notification.Name("NotificationProfileImageReceived")
        static let LineWidth                       = Notification.Name("LineWidth")
        static let SuveyViewsCountReceived         = Notification.Name("SuveyViewsCountReceived")
        static let LanguageChanged                 = Notification.Name("LANGUAGE_CHANGED")
    }
}
