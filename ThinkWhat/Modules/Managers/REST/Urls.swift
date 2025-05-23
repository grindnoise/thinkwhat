//
//  Urls.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

struct API_URLS {
  static let BASE                     = localhost ? "http://127.0.0.1:8000/" : "https://www.thinkwhat.app/" //"https://damp-oasis-64585.herokuapp.com/"////
  static let CLIENT_ID                = localhost ? "o1Flzw2j8yaRVhSnLJr0JY5Hd6hcA8C0aiv2EUAS" : "bdOS2la5RAgkZNq4uSq0esOIa0kZmlL05nt2OjSw"//"o1Flzw2j8yaRVhSnLJr0JY5Hd6hcA8C0aiv2EUAS"//
  static let CLIENT_SECRET            = localhost ? "IQnHcT6s6RqPJhws0mi3e8zWc9uXiTugkclkY9l2xd0FGFnUqmgr27q6d9kEvXhj64uWOlvrQTJCE4bI6PWPYS9mduml9z57glPqSOPgLBnqx8ucyYhew50CkzaUnWNH" : "Swx6TUPhgYpGqOe2k1B0UGxjeX19aRhb5RkkVzpPzYEluzPlHse5OaB5NSV3Ttj0n0sWBFOvZvAGef1qdcNOfJ56t15QDIvNftqdUB8WXukLJsowfuVtrcj415t28nCO" // "IQnHcT6s6RqPJhws0mi3e8zWc9uXiTugkclkY9l2xd0FGFnUqmgr27q6d9kEvXhj64uWOlvrQTJCE4bI6PWPYS9mduml9z57glPqSOPgLBnqx8ucyYhew50CkzaUnWNH"
  static let CURRENT_TIME             = "api/current_time/"
  static let TOKEN_REVOKE             = "auth/revoke-token/"
  static let RESET_PASSWORD           = "api/password_reset/"
  static let APP_LAUNCH               = "api/app_launch/load/"
  //Profiles
  static let USERS                    = "api/users/"
  static let GET_EMAIL_VERIFIED       = "api/profiles/get_email_verified/"
  static let USER_PROFILE_STATS       = "api/profiles/get_profile_stats/"
  static let USER_PROFILE_TOP_PUBS    = "api/profiles/get_top_active_publications/"
  static let SURVEYS                  = "api/surveys/"
  static let SURVEYS_MEDIA            = "api/media/"
  static let SURVEYS_TOP              = "api/surveys/top/"
  static let SURVEYS_NEW              = "api/surveys/new/"
  static let SURVEYS_OWN              = "api/surveys/own/"
  static let SURVEYS_HOT              = "api/surveys/hot/"
  //    static let SURVEYS_HOT_EXCEPT       = "api/surveys/hot_except/"
  static let SURVEYS_FAVORITE         = "api/surveys/favorite/"
  static let SURVEYS_TOTAL_COUNT      = "api/surveys/total_count/"
  static let SURVEYS_REJECT           = "api/surveys/reject/"
  static let VOTE                     = "api/vote/"
  static let CATEGORIES               = "api/categories/"
  static let BALANCE                  = "api/current_balance_price/"
  static let CREATE_CITY              = "api/cities/create_city/"
  
  struct Geocoding {
    static let countryByIP = "http://ip-api.com/json/?fields=status,message,country,countryCode,region,regionName"
  }
  
  struct Profiles {
    static let baseString = "api/profiles/"
    static let base:                URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent(baseString)}()
    static let subscribeToTopic:    URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/subscribe_to_topic/")}()
    static let subscribe:           URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/subscribe/")}()
    static let unsubscribe:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/unsubscribe/")}()
    static let removeSubscribers:   URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/remove_subscribers/")}()
    static let subscribedFor:       URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/get_subscribed_for/")}()
    static let subscribers:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/get_subscribers/")}()
    static let updateCurrentStats:  URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/get_current_user_data/")}()
    static let updateAppSettings:   URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/set_app_settings/")}()
    static let feedback:            URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/feedback/")}()
    static let compatibility:       URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/get_compatibility/")}()
    static let switchNotifications: URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/switch_subscription_notifications/")}()
    static let registerDevice:      URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent(baseString + "register_device/")}()
    static let unregisterDevice:    URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent(baseString + "unregister_device/")}()
    static let deleteAccount:       URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent(baseString + "delete_account/")}()
//    static let setDeviceState:      URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent(baseString + "set_device_state/")}()
  }
  
  struct Topics {
    static let updateStats:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/total_count/")}()
  }
  
  struct Surveys {
    static let getPublications:     URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_publications/")}()
    static let surveyById:          URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/by_id/")}()
    static let surveyBySharedLink:  URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/by_share_link/")}()
    static let listByIds:           URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/list_by_ids/")}()
    static let subscriptions:       URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/subscriptions/")}()
    static let new:                 URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/new/")}()
    static let top:                 URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/top/")}()
    static let favorite:            URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/favorite/")}()
    static let all:                 URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/all/")}()
    static let own:                 URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/own/")}()
    static let hot:                 URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/hot/")}()
    static let ids:                 URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/ids/")}()
    static let byTopic:             URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/by_category/")}()
    static let byUserprofile:       URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/by_owner/")}()
    static let searchBySubstring:   URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/by_substring/")}()
    static let search:              URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/search/")}()
    static let root:                URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/")}()
    static let media:               URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/media/")}()
    static let share:               URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("share/")}()
//    static let share:               URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/share/")}()
    static let claim:               URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/claim/")}()
    static let reject:              URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/reject/")}()
    static let addFavorite:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/add_favorite/")}()
    static let removeFavorite:      URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/remove_favorite/")}()
    static let updateStats:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_survey_stats/")}()
    static let getCommentsSurveyStateCommentsUpdates:  URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_new_comments_survey_stats_comments_stats/")}()
    static let getSurveyState:      URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_publication_state/")}()
    static let updateCommentsStats: URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_comments_stats/")}()
    static let postComment:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/post_comment/")}()
    static let claimComment:        URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/claim_comment/")}()
    static let deleteComment:       URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/delete_comment/")}()
//    static let getRootComments:     URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_root_comments/")}()
    static let getComments:         URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_comments/")}()
    static let getSurveyThreadComments: URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/get_survey_and_thread_comments/")}()
    static let voters:              URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/voters/")}()
    static let vote:                URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/vote/")}()
    static let incrementViews:      URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/surveys/add_view_count/")}()
  }
  
  
  struct Auth {
    static let emailExists          = URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/email_exists")
    static let usernameExists       = URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/username_exists")
    static let current              = URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/current/")
    static let signUp               = URL(string: API_URLS.BASE)?.appendingPathComponent("api/sign_up/")
    static let getCodeViaMail       = URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/send_confirmation_code/")
    static let token                = URL(string: API_URLS.BASE)?.appendingPathComponent("auth/token/")
    static let getTokenByPassword   = URL(string: API_URLS.BASE)?.appendingPathComponent("api/profiles/get_token/")
    static let convertToken         = URL(string: API_URLS.BASE)?.appendingPathComponent("auth/convert-token/")
    static let appleSignIn          = URL(string: API_URLS.BASE)?.appendingPathComponent("auth/apple/")
  }
  
  struct System {
    static let termsOfUse:          URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("terms_of_use/")}()
    static let licenses:            URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("licenses_ios/")}()
    //        static let updateStats:     URL? = {return URL(string: API_URLS.BASE)?.appendingPathComponent("api/get_updates/")}()
  }
}
