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
    }
    
    struct Surveys {
        static let UpdateFavorite                   = Notification.Name("NotificationFavoriteSurveysUpdated")
        static let UpdateTopSurveys                 = Notification.Name("NotificationTopSurveysUpdated")
        static let UpdateNewSurveys                 = Notification.Name("NotificationNewSurveysUpdated")
        static let UpdateHotSurveys                 = Notification.Name("NotificationSurveysStackReceived")
        static let UpdateSubscriptions              = Notification.Name("NotificationSubscriptionsReceived")
        static let UpdateOwn                        = Notification.Name("NotificationOwnSurveysUpdated")
        static let UpdateAll                        = Notification.Name("NotificationAllSurveysUpdated")
        
        static let ZeroSubscriptions                = Notification.Name("NotificationZeroSubscriptionsReceived")
        static let Completed                        = Notification.Name("NotificationSurveyCompleted")
        static let Views                            = Notification.Name("NotificationSurveyViews")
        static let Watchers                         = Notification.Name("NotificationSurveyWatchers")
        
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
