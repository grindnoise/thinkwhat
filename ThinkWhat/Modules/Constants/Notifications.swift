//
//  AppNotifications.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import Combine

class Notifications {
//  static let shared = Notifications()
  
  struct UIEvents {
    static let tabItemPublisher = PassthroughSubject<[Enums.Tab: Enums.Tab], Never>() // [newValue: oldValue]
    static let topicSubscriptionPublisher = PassthroughSubject<Topic, Error>()
    static let enqueueBannerPublisher = PassthroughSubject<NewBanner, Never>()
  }
  
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
    static let FirstNameChanged                 = Notification.Name("NotificationUserprofilesFirstNameChanged")
    static let LastNameChanged                  = Notification.Name("NotificationUserprofilesLastNameChanged")
    static let BirthDateChanged                 = Notification.Name("NotificationUserprofilesBirthDateChanged")
    static let GenderChanged                    = Notification.Name("NotificationUserprofilesGenderChanged")
    static let ImageDownloaded                  = Notification.Name("NotificationUserprofilesImageDownloaded")
    static let FacebookURL                      = Notification.Name("NotificationUserprofilesFacebookURL")
    static let InstagramURL                     = Notification.Name("NotificationUserprofilesInstagramURL")
    static let TikTokURL                        = Notification.Name("NotificationUserprofilesTikTokURL")
    static let NoSocialURL                      = Notification.Name("NotificationUserprofilesNoSocialURL")
    //        static let CurrentUserImageUpdated          = Notification.Name("NotificationUserprofilesCurrentUserImageUpdated")
    static let Balance                          = Notification.Name("NotificationUserprofilesBalance")
    static let Preferences                      = Notification.Name("NotificationUserprofilesPreferences")
    //        static let PublicationsTotal                = Notification.Name("NotificationUserprofilesPublicationsTotal")
    static let CompleteTotal                    = Notification.Name("NotificationUserprofilesCompleteTotal")
    //        static let FavoritesTotal                   = Notification.Name("NotificationUserprofilesFavoritesTotal")
    //        static let SubscribersTotal                 = Notification.Name("NotificationUserprofilesSubscribersTotal")
    //        static let SubscriptionsTotal               = Notification.Name("NotificationUserprofilesSubscriptionsTotal")
    //        static let Subscribed                       = Notification.Name("Notifications.Userprofiles.Subscribed")
    //        static let Unsubscribed                     = Notification.Name("Notifications.Userprofiles.Unsubscribed")
    //        static let SubscribersAppend                = Notification.Name("Notifications.Userprofiles.SubscribersAppend")
    //        static let SubscribersRemove                = Notification.Name("Notifications.Userprofiles.SubscribersRemove")
    //        static let SubscriptionsAppend              = Notification.Name("Notifications.Userprofiles.SubscriptionsAppend")
    //        static let SubscriptionsRemove              = Notification.Name("Notifications.Userprofiles.SubscriptionsRemove")
    //        static let SubscriptionOperationFailure     = Notification.Name("Notifications.Userprofiles.SubscriptionOperationFailure")
    //        static let SubscribersEmpty                 = Notification.Name("Notifications.Userprofiles.SubscribersEmpty")
    //        static let SubscriptionsEmpty               = Notification.Name("Notifications.Userprofiles.SubscriptionsEmpty")
    //        static let NotifyOnPublications             = Notification.Name("Notifications.Userprofiles.NotifyOnPublications")
    //        static let NotifyOnPublicationsFailure      = Notification.Name("Notifications.Userprofiles.NotifyOnPublicationsFailure")
  }
  
  //    struct Cities {
  //        static let FetchResult                      = Notification.Name("NotificationCitiesFetchResult")
  //        static let FetchError                       = Notification.Name("NotificationCitiesFetchError")
  //    }
  
  struct System {
    static let hideKeyboardPublisher = PassthroughSubject<Void, Never>()
//    static let shareLinkRequestPublisher        = PassthroughSubject<Void, Never>() // When user tapped share link
//    static let shareLinkResponsePublisher       = PassthroughSubject<SurveyReference, Error>() // When
    static let UpdateStats                      = Notification.Name("NotificationUpdateStats")
    static let HideKeyboard                     = Notification.Name("NotificationHideKeyboard")
    static let ImageUploadStart                 = Notification.Name("NotificationImageUploadStart")
    static let ImageUploadFailure               = Notification.Name("NotificationImageUploadFailure")
    static let AppLanguage                      = Notification.Name("Notifications.System.AppLanguage")
    static let ContentLanguage                  = Notification.Name("Notifications.System.ContentLanguage")
//    static let Tab                              = Notification.Name("Notifications.System.Tab")
    static let FeedbackSent                     = Notification.Name("Notifications.System.FeedbackSent")
    static let FeedbackFailure                  = Notification.Name("Notifications.System.FeedbackFailure")
  }
  
  struct SurveyAnswers {
    static let TotalVotes                       = Notification.Name("SurveyAnswerTotalVotes")
    //        static let VotersAppend                     = Notification.Name("SurveyAnswerVotersAppend")
  }
  
  //    struct Comments {
  //        static let Post                             = Notification.Name("NotificationCommentPost")
  //        static let Append                           = Notification.Name("NotificationCommentAppend")
  //        static let ChildAppend                      = Notification.Name("NotificationCommentChildAppend")
  //        static let Claim                            = Notification.Name("CommentClaim")
  //        static let ClaimFailure                     = Notification.Name("CommentClaimFailure")
  //        static let Ban                              = Notification.Name("CommentBan")
  ////        static let ChildrenCountChange              = Notification.Name("CommentChildrenCountChange")
  //        static let Delete                           = Notification.Name("CommentDelete")
  //    }
  
  struct Surveys {
    //        static let SubscriptionAppend               = Notification.Name("SurveysSubscriptionAppend")
    //        static let NewAppend                        = Notification.Name("SurveysNewAppend")
    //        static let TopAppend                        = Notification.Name("SurveysTopAppend")
    //        static let OwnAppend                        = Notification.Name("SurveysOwnAppend")
    //        static let FavoriteAppend                   = Notification.Name("SurveysFavoriteAppend")
    //        static let FavoriteRemove                   = Notification.Name("SurveysFavoriteRemove")
    static let FavoriteRequestFailure           = Notification.Name("Notifications.Surveys.FavoriteRequestFailure")
    //        static let TopicAppend                      = Notification.Name("SurveysTopicAppend")
    static let Append                           = Notification.Name("Notifications.Surveys.Append")
    static let AppendReference                  = Notification.Name("Notifications.Surveys.AppendReference")
    static let Remove                           = Notification.Name("Notifications.Surveys.Remove")
    //        static let RemoveReference                  = Notification.Name("Notifications.Surveys.RemoveReference")
    //        static let Claim                            = Notification.Name("SurveyClaim")
    //        static let ClaimFailure                     = Notification.Name("SurveyClaimFailure")
    //        static let Ban                              = Notification.Name("SurveyBan")
    
    
    //        static let UnsetFavorite                    = Notification.Name("NotificationFavoriteSurveyUnset")
    //        static let SetFavorite                      = Notification.Name("NotificationFavoriteSurveySet")
    //        static let SwitchFavorite                   = Notification.Name("NotificationSwitchFavorite")
    static let UpdateFavorite                   = Notification.Name("NotificationFavoriteSurveysUpdated")
    static let UpdateTopSurveys                 = Notification.Name("NotificationTopSurveysUpdated")
    static let UpdateNewSurveys                 = Notification.Name("NotificationNewSurveysUpdated")
    //        static let SwitchHot                        = Notification.Name("NotificationSwitchHot")
    static let UpdateSubscriptions              = Notification.Name("NotificationSubscriptionsReceived")
    static let UpdateOwn                        = Notification.Name("NotificationOwnSurveysUpdated")
    //        static let UpdateAll                        = Notification.Name("NotificationAllSurveysUpdated")
    //        static let EmptyReceived                    = Notification.Name("NotificationEmptyReceived")
    //        static let Empty                            = Notification.Name("NotificationZeroSubscriptionsReceived")
    
    static let ZeroFavorites                    = Notification.Name("NotificationZeroFavoritesReceived")
    static let ZeroSubscriptions                = Notification.Name("NotificationZeroSubscriptionsReceived")
    static let ZeroTop                          = Notification.Name("NotificationZeroTopReceived")
    static let ZeroOwn                          = Notification.Name("NotificationZeroOwnReceived")
    static let ZeroNew                          = Notification.Name("NotificationZeroNewReceived")
    
    static let Rejected                         = Notification.Name("NotificationReject")
    
    static let Completed                        = Notification.Name("NotificationSurveyCompleted")
    //        static let Progress                         = Notification.Name("NotificationSurveyProgress")
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
