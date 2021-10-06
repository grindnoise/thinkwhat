//
//  Main.swift
//  Burb
//
//  Created by Pavel Bukharov on 24.03.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Swinject
import CoreData
import UserNotifications

typealias Closure = (()->())

var localhost = false

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter
} ()

func delay(seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}

//Open side app or embedded html
enum SideAppPreference: String {
    case Embedded = "embedded"
    case App = "app"
}

enum ImageType: String {
    case Profile = "profile"
    case Survey  = "survey"
}

enum Language: String {
    case English = "English"
    case Russian = "Русский"
}

enum FileFormat: String {
    case PNG        = "png"
    case JPEG       = "jpg"
    case TIFF       = "tiff"
    case GIF        = "gif"
    case Unknown    = "Unknown"
}

enum State {
    case enabled, disabled
}

enum TokenState {
    case Received
    case Error
    case Unassigned
    case WrongCredentials
    case Expired
    case Revoked
    case ConnectionError
    case AccessDenied
}

enum ApiReachabilityState {
    case Reachable, None
}

enum SessionType: String {
    case authorized     = "authorized"
    case unauthorized   = "unauthorized"
}

enum Gender: String {
    case Male           = "Male"
    case Female         = "Female"
    case Unassigned     = "Unassigned"
}

enum InternetConnection {
    case Available
    case None
}

enum AuthVariant: String {
    case VK         = "vk-oauth2"
    case Facebook   = "Facebook"
    case Google     = "Google"
    case Phone      = "Phone"
    case Mail       = "Mail"
    case Username   = "Username"
}

enum ThirdPartyApp: String {
    case TikTok     = "TikTok"
    case Youtube    = "Youtube"
    case Null       = ""
    
    func getIcon() -> UIView {
        switch self {
        case .Youtube:
            return YoutubeLogo()
        case .TikTok:
            return TikTokLogo()
        default:
            return UIView()
        }
    }
}

enum ClientSettingsMode {
    case Reminder, Language
}


//var isPushNotificationEnabled: Bool {
//    guard let settings = UIApplication.shared.currentUserNotificationSettings
//        else {
//            return false
//    }
//    
//    return UIApplication.shared.isRegisteredForRemoteNotifications
//        && !settings.types.isEmpty
//}
var tokenState: TokenState    = .Unassigned {
    didSet {
        switch tokenState {
        case .Received:
            NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
        case .Error:
            NotificationCenter.default.post(name: Notifications.OAuth.TokenError, object: nil)
        case .Revoked:
            NotificationCenter.default.post(name: Notifications.OAuth.TokenRevoked, object: nil)
        case .WrongCredentials:
            NotificationCenter.default.post(name: Notifications.OAuth.TokenWrongCredentials, object: nil)
        case .ConnectionError:
            NotificationCenter.default.post(name: Notifications.OAuth.TokenConnectionError, object: nil)
        case .AccessDenied:
            NotificationCenter.default.post(name: Notifications.OAuth.TokenAccessDenied, object: nil)
        default:
            print(tokenState)
        }
    }
}
var emailResponse: EmailResponse? {
    didSet {
        if emailResponse != nil {
            NotificationCenter.default.post(name: Notifications.EmailResponse.Received, object: nil)
        }
    }
}
var firstLaunch                                 = true
var internetConnection: InternetConnection      = .Available {
    didSet {
        if internetConnection != oldValue {
            NotificationCenter.default.post(name: Notifications.Network.InternetConnectionChange, object: nil)
        }
    }
}
var apiReachability: ApiReachabilityState = .Reachable {
    didSet {
        if apiReachability == .None {
            NotificationCenter.default.post(name: Notifications.Network.RemoteNotReachable, object: nil)
        } else {
            NotificationCenter.default.post(name: Notifications.Network.RemoteReachable, object: nil)
        }
    }
}
var temporaryTokenToRevoke = ""

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

    struct Surveys {
        static let UpdateTopSurveys               = Notification.Name("NotificationTopSurveysUpdated")
        static let UpdateNewSurveys               = Notification.Name("NotificationNewSurveysUpdated")
        static let SurveysStackReceived            = Notification.Name("NotificationSurveysStackReceived")
        static let SurveysStackUpdated             = Notification.Name("NotificationSurveysStackUpdated")
        static let OwnSurveysUpdated               = Notification.Name("NotificationOwnSurveysUpdated")
        static let OwnSurveysReceived              = Notification.Name("NotificationOwnSurveysReceived")
        static let SurveysByCategoryUpdated        = Notification.Name("NotificationSurveysByCategoryUpdated")
        static let FavoriteSurveysUpdated          = Notification.Name("NotificationFavoriteSurveysUpdated")
        static let UserSurveysUpdated              = Notification.Name("NotificationUserSurveysUpdated")
        static let UserFavoriteSurveysUpdated      = Notification.Name("NotificationUserFavoriteSurveysUpdated")
        static let NewSurveyPostError              = Notification.Name("NotificationNewSurveyPostError")
    }
    
    struct UI {
        static let ClaimSignAppeared               = Notification.Name("ClaimSignAppeared")
        static let CategorySelected                = Notification.Name("CategorySelected")
        static let UserImageChanged                = Notification.Name("NotificationUserImageChanged")
        static let ProfileImageReceived            = Notification.Name("NotificationProfileImageReceived")
        static let LineWidth                       = Notification.Name("LineWidth")
        static let SuveyViewsCountReceived         = Notification.Name("SuveyViewsCountReceived")
    }
}


let appDelegate         = UIApplication.shared.delegate as! AppDelegate
let MIN_STACK_SIZE      = 4//Min quantity of hot surveys to request another portion
let MAX_IMAGES_COUNT    = 3
let MAX_ANSWERS_COUNT   = 6
let MIN_VOTES_COUNT     = 10
let MAX_VOTES_COUNT     = 9999999

struct TimeIntervals {
    static let ClearRejectedSurveys: TimeInterval = 60//Timer parameter to wipe out rejectedSurveys container
    static let NetworkInactivity: TimeInterval = 15//Timer parameter to wipe out rejectedSurveys container
    static let UserStatsTimeOutdated: TimeInterval = 5//Timer parameter to update user stats (called in UI)
}



////MARK: Auth
//let kSegueApp                                    = "APP"
//let kSegueAppFromMailSignin                      = "APP_FROM_MAIL_SIGNIN"
//let kSegueAppFromTerms                           = "APP_FROM_TERMS"
//let kSegueAppFromProfile                         = "APP_FROM_PROFILE"
//let kSegueAuth                                   = "AUTH"
//let kSegueSocialAuth                             = "SOCIAL"
//let kSegueMailValidationFromSignup               = "MAIL_VALID_SIGNUP"
//let kSegueMailValidationFromSignin               = "MAIL_VALID_SIGNIN"
//let kSegueTerms                                  = "TERMS"
//let kSegueTermsFromValidation                    = "TERMS_VALID"
//let kSegueTermsFromStartScreen                   = "TERMS_START_SCREEN"
//let kSegueMailAuth                               = "MAILAUTH"
//let kSeguePwdRecovery                            = "PWD_RECOVERY"
//let kSegueProfileFromConfirmation                = "PROFILE_FROM_CONFIRMATION"
//let kSegueProfileFromAuth                        = "PROFILE_FROM_AUTH"
//
////MARK: App
//let kSegueAppProfileSettingsSelection            = "PROFILE_SETINGS_SELECTION"
//let kSegueAppLogout                              = "BACK_TO_AUTH"
//let kSegueAppProfileToInfo                       = "INFO"
//let kSegueAppFeedToSurvey                        = "FEED_TO_SURVEY"
//let kSegueAppFeedToNewSurvey                     = "FEED_TO_NEW_SURVEY"
//let kSegueAppFeedSurveysToCategory               = "FEED_TO_CATEGORY"
//let kSegueAppUserSurveysToSurvey                 = "USER_SURVEYS_TO_SURVEY"
//let kSegueAppNewSurveyToAnonymity                = "NEW_TO_ANONYMITY"
//let kSegueAppNewSurveyToCategorySelection        = "NEW_TO_CATEGORY_SELECTION"


//MARK: Storyboards
struct Storyboards {
    static let controllers  = UIStoryboard(name: "Controllers", bundle: nil)
    static let app          = UIStoryboard(name: "App", bundle: nil)
    static let auth         = UIStoryboard(name: "Auth", bundle: nil)
    static let root         = UIStoryboard(name: "Root", bundle: nil)
    static let survey       = UIStoryboard(name: "Survey", bundle: nil)
}


//let segueBarberData                             = "segueBarberData"
//let segueSignup                                 = "segueSignup"
//let segueConfirm                                = "segueConfirm"
//let segueCustomerOrder                          = "segueCustomerOrder"
//let segueBarberProfileFromChat                  = "segueBarberProfileFromChat"
//let segueAuth                                   = "segueAuth"
//let segueChat                                   = "segueChat"
//let segueTermsOfUse                             = "segueTermsOfUse"
//let segueTermsFromAuth                          = "segueTermsFromAuth"
//let segueSocialAuth                             = "segueSocialAuth"
//let segueSignupViaSocialMedia                   = "segueSignupViaSocialMedia"
//let segueRoleSelection                          = "segueRoleSelection"
//let segueWelcomeClient                          = "segueWelcomeClient"
//let segueWelcomeBarber                          = "segueWelcomeBarber"
//let segueClientSettingsPicker                   = "segueClientSettingsPicker"
let alert                                       = CustomAlertView(frame: (UIApplication.shared.keyWindow?.frame)!)


let options: UNAuthorizationOptions             = [.alert, .sound, .badge]

//HTTP request attempts before assertion
let MAX_REQUEST_ATTEMPTS                        = 3

//MARK: - Structs
struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

class AppData {
    
    static let shared = AppData()
    var user = User()
    var userProfile = UserProfile()
    var system = System()
    
    struct User {
        var ID: String? {
            didSet {
                if ID != nil {
                    UserDefaults.standard.set(ID!, forKey: "userID")
                }
            }
        }
        var username: String? {
            didSet {
                if username != nil {
                    UserDefaults.standard.set(username!, forKey: "username")
                }
            }
        }
        var firstName: String? {
            didSet {
                if firstName != nil {
                    UserDefaults.standard.set(firstName!, forKey: "firstName")
                }
            }
        }
        var lastName: String? {
            didSet {
                if lastName != nil {
                    UserDefaults.standard.set(lastName!, forKey: "lastName")
                }
            }
        }
        var email: String? {
            didSet {
                if email != nil {
                    UserDefaults.standard.set(email!, forKey: "userMail")
                }
            }
        }
        
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kFirstName = UserDefaults.standard.object(forKey: "firstName") {
                self.firstName = (kFirstName as! String)
            }
            if let kLastName = UserDefaults.standard.object(forKey: "lastName") {
                self.lastName = (kLastName as! String)
            }
            if let kUserName = UserDefaults.standard.object(forKey: "username") {
                self.username = (kUserName as! String)
            }
            if let kUserMail = UserDefaults.standard.object(forKey: "userMail") {
                self.email = (kUserMail as! String)
            }
            if let kUserID = UserDefaults.standard.object(forKey: "userID") {
                self.ID = (kUserID as! String)
            }
        }
        
        mutating func eraseData() {
            firstName               = nil
            lastName                = nil
            username                = nil
            ID                      = nil
            email                   = nil
            
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "firstName")
            UserDefaults.standard.removeObject(forKey: "lastName")
            UserDefaults.standard.removeObject(forKey: "userMail")
            KeychainService.saveAccessToken(token: "")
            KeychainService.saveRefreshToken(token: "")
        }
    }
    
    struct UserProfile: StorageProtocol {
        var ID: String? {
            didSet {
                if ID != nil {
                    UserDefaults.standard.set(ID!, forKey: "userProfileID")
                }
            }
        }
        //Local
        var imagePath: String? {
            didSet {
                if imagePath != nil {
                    UserDefaults.standard.set(imagePath!, forKey: "userImagePath")
                    NotificationCenter.default.post(name: Notifications.UI.UserImageChanged, object: nil)
                }
            }
        }
        var gender: Gender? {
            didSet {
                if gender != nil {
                    UserDefaults.standard.set(gender!.rawValue, forKey: "userGender")
                }
            }
        }
        var birthDate: Date? {
            didSet {
                if birthDate != nil {
                    UserDefaults.standard.set(birthDate!, forKey: "userBirthDate")
                }
            }
        }
        var isEdited: Bool? {
            didSet {
                if isEdited != nil {
                    UserDefaults.standard.set(isEdited!, forKey: "userProfileEdited")
                }
            }
        }
        var isBanned: Bool? {
            didSet {
                if isBanned != nil {
                    UserDefaults.standard.set(isBanned!, forKey: "userProfileBanned")
                }
            }
        }
        var isEmailVerified: Bool? {
            didSet {
                if isEmailVerified != nil {
                    UserDefaults.standard.set(isEmailVerified!, forKey: "userEmailVerified")
                }
            }
        }
        var balance: Int = 0
        
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kImagePath = UserDefaults.standard.object(forKey: "userImagePath") {
                self.imagePath = (kImagePath as! String)
            }
            if let kUserBirthDate = UserDefaults.standard.object(forKey: "userBirthDate") {
                self.birthDate = (kUserBirthDate as! Date)
            }
            if let kUserGender = UserDefaults.standard.object(forKey: "userGender") {
                self.gender = Gender(rawValue: kUserGender as! String)!
            }
            if let kUserID = UserDefaults.standard.object(forKey: "userProfileID") {
                self.ID = (kUserID as! String)
            }
            if let kIsEdited = UserDefaults.standard.object(forKey: "userProfileEdited") {
                self.isEdited = (kIsEdited as! Bool)
            }
            if let kIsBanned = UserDefaults.standard.object(forKey: "userProfileBanned") {
                self.isBanned = (kIsBanned as! Bool)
            }
            if let kIsEmailVerified = UserDefaults.standard.object(forKey: "userEmailVerified") {
                self.isEmailVerified = (kIsEmailVerified as! Bool)
            }
        }
        
        mutating func eraseData() {
            if imagePath != nil {
                storeManager.deleteFile(path: imagePath!)
                imagePath       = nil
            }
            birthDate       = nil
            gender          = nil
            ID              = nil
            isEdited        = nil
            isBanned        = nil
            isEmailVerified = nil
            
            UserDefaults.standard.removeObject(forKey: "userProfileID")
            UserDefaults.standard.removeObject(forKey: "userGender")
            UserDefaults.standard.removeObject(forKey: "userBirthDate")
            UserDefaults.standard.removeObject(forKey: "userImagePath")
            UserDefaults.standard.removeObject(forKey: "userProfileEdited")
            UserDefaults.standard.removeObject(forKey: "userProfileBanned")
            UserDefaults.standard.removeObject(forKey: "userEmailVerified")
        }
    }
    
    struct System {
        var session: SessionType! {
            if AppData.shared.userProfile.ID == nil || String(KeychainService.loadAccessToken()!).isEmpty {
                return .unauthorized
            } else {
                return .authorized
            }
        }
        var language: Language! {
            didSet {
                if language != oldValue {
                    UserDefaults.standard.set(language.rawValue, forKey: "language")
                } else {
                    UserDefaults.standard.removeObject(forKey: "language")
                }
            }
        }
        var APIVersion: String? {
            didSet {
                if APIVersion != nil, APIVersion != oldValue {
                    UserDefaults.standard.set(APIVersion!, forKey: "APIVersion")
                }
            }
        }
        var youtubePlayOption: SideAppPreference? {
            didSet {
                if youtubePlayOption != nil, youtubePlayOption != oldValue {
                    UserDefaults.standard.set(youtubePlayOption!.rawValue, forKey: "youtubePlayOption")
                }
            }
        }
        var tiktokPlayOption: SideAppPreference? {
            didSet {
                if tiktokPlayOption != nil, tiktokPlayOption != oldValue {
                    UserDefaults.standard.set(tiktokPlayOption!.rawValue, forKey: "tiktokPlayOption")
                }
            }
        }
        var newPollTutorialRequired: Bool = true {
            didSet {
                if newPollTutorialRequired == false {
                    UserDefaults.standard.set(newPollTutorialRequired, forKey: "newPollTutorialRequired")
                }
            }
        }
        
//        var emailResponseExpirationDate: Date? {
//            didSet {
//                if emailResponseExpirationDate != nil  {
//                    UserDefaults.standard.removeObject(forKey: "emailResponseExpirationDate")
//                    UserDefaults.standard.set(emailResponseExpirationDate, forKey: "emailResponseExpirationDate")
////                    if emailResponseConfirmationCode != nil {
////                        emailResponse = EmailResponse(confirmation_code: emailResponseConfirmationCode!, expiresIn: emailResponseExpirationDate!)
////                    }
//                } else {
//                    UserDefaults.standard.removeObject(forKey: "emailResponseExpirationDate")
////                    emailResponse = nil
//                }
//            }
//        }
//        var emailResponseConfirmationCode: Int? {
//            didSet {
//                if emailResponseConfirmationCode != nil {
//                    UserDefaults.standard.removeObject(forKey: "emailResponseConfirmationCode")
//                    UserDefaults.standard.set(emailResponseConfirmationCode, forKey: "emailResponseConfirmationCode")
////                    if emailResponseExpirationDate != nil {
////                        emailResponse = EmailResponse(confirmation_code: emailResponseConfirmationCode!, expiresIn: emailResponseExpirationDate!)
////                    }
//                } else {
//                    UserDefaults.standard.removeObject(forKey: "emailResponseConfirmationCode")
////                    emailResponse = nil
//                }
//            }
//        }
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kLanguage = UserDefaults.standard.object(forKey: "language") {
                self.language = Language(rawValue: kLanguage as! String)!
            } else {
                let langStr = Locale.current.languageCode
                if langStr == "en-US" {
                    self.language = .English
                } else if langStr == "ru" {
                    self.language = .Russian
                }
            }
            if let kAPIVersion = UserDefaults.standard.object(forKey: "APIVersion") {
                self.APIVersion = (kAPIVersion as! String)
            }
            if let kYoutubePlayOption = UserDefaults.standard.object(forKey: "youtubePlayOption") {
                self.youtubePlayOption = SideAppPreference(rawValue: kYoutubePlayOption as! String)
            }
            if let kTiktokPlayOption = UserDefaults.standard.object(forKey: "tiktokPlayOption") {
                self.tiktokPlayOption = SideAppPreference(rawValue: kTiktokPlayOption as! String)
            }
            self.newPollTutorialRequired = UserDefaults.standard.object(forKey: "newPollTutorialRequired") as? Bool ?? true
        }
        
        mutating func eraseData() {
//            emailResponseExpirationDate = nil
//            emailResponseConfirmationCode = nil
            let langStr = Locale.current.languageCode
            if langStr == "en-US" {
                language = .English
            } else if langStr == "ru_RU" {
                language = .Russian
            }
            APIVersion = ""
            youtubePlayOption = nil
            tiktokPlayOption = nil
            newPollTutorialRequired = true
            UserDefaults.standard.removeObject(forKey: "userEmailVerified")
            UserDefaults.standard.removeObject(forKey: "youtubePlayOption")
            UserDefaults.standard.removeObject(forKey: "tiktokPlayOption")
            UserDefaults.standard.removeObject(forKey: "newPollTutorialRequired")
        }
    }
    
    func importUserData(_ json: JSON, _ imagePath: String? = nil) {
        var userProfileData                 = json.dictionaryObject  as! [String: Any]
        var userData                        = userProfileData.removeValue(forKey: "owner") as! [String: Any]
        self.user.email                     = userData["email"] as! String
        self.user.firstName                 = userData["first_name"] as! String
        self.user.lastName                  = userData["last_name"] as! String
        self.user.username                  = userData["username"] as! String
        self.user.ID                        = String(describing: userData["id"] as! Int)
        self.userProfile.ID                 = String(describing: userProfileData["id"] as! Int)
        self.userProfile.birthDate          = userProfileData["birth_date"] is NSNull ? nil : Date(dateString:userProfileData["birth_date"] as! String)
        self.userProfile.gender             = userProfileData["gender"] is NSNull ? Gender.Unassigned : Gender(rawValue: userProfileData["gender"] as! String)
        self.userProfile.isBanned           = userProfileData["is_banned"] is NSNull ? false : userProfileData["is_banned"] as! Bool
        self.userProfile.isEdited           = userProfileData["is_edited"] is NSNull ? false : userProfileData["is_edited"] as! Bool
        self.userProfile.isEmailVerified    = userProfileData["is_email_verified"] is NSNull ? false : userProfileData["is_email_verified"] as! Bool
        
        if imagePath != nil {
            self.userProfile.imagePath = imagePath!
        }
    }
    
    func eraseData() {
        self.user.eraseData()
        self.userProfile.eraseData()
        self.system.eraseData()
    }
    
    private init() {}
}



struct INSTAGRAM_IDS {
    
    static let INSTAGRAM_AUTHURL        = "https://api.instagram.com/oauth/authorize/"
    
    static let INSTAGRAM_APIURl         = "https://api.instagram.com/v1/users/"
    
    static let INSTAGRAM_CLIENT_ID      = "4e57d58c2b6443b1924700534c869bed"
    
    static let INSTAGRAM_CLIENTSERCRET  = "14995ab7ffc84070ac55e3f15f6f3a20"
    
    static let INSTAGRAM_REDIRECT_URI   = "https://damp-oasis-64585.herokuapp.com/api/social/convert-token/"
    
    static let INSTAGRAM_ACCESS_TOKEN   = "access_token"
    
    static let INSTAGRAM_SCOPE          = "basic+likes+comments+relationships"
    
}

struct VK_IDS {
    
    static let APP_ID                   = "7043775"
    
}

struct SERVER_URLS {
    static let BASE                     = localhost ? "http://127.0.0.1:8000/" : "https://damp-oasis-64585.herokuapp.com/"////
    static let CLIENT_ID                = localhost ? "o1Flzw2j8yaRVhSnLJr0JY5Hd6hcA8C0aiv2EUAS" : "bdOS2la5RAgkZNq4uSq0esOIa0kZmlL05nt2OjSw"//"o1Flzw2j8yaRVhSnLJr0JY5Hd6hcA8C0aiv2EUAS"//
    static let CLIENT_SECRET            = localhost ? "IQnHcT6s6RqPJhws0mi3e8zWc9uXiTugkclkY9l2xd0FGFnUqmgr27q6d9kEvXhj64uWOlvrQTJCE4bI6PWPYS9mduml9z57glPqSOPgLBnqx8ucyYhew50CkzaUnWNH" : "Swx6TUPhgYpGqOe2k1B0UGxjeX19aRhb5RkkVzpPzYEluzPlHse5OaB5NSV3Ttj0n0sWBFOvZvAGef1qdcNOfJ56t15QDIvNftqdUB8WXukLJsowfuVtrcj415t28nCO" // "IQnHcT6s6RqPJhws0mi3e8zWc9uXiTugkclkY9l2xd0FGFnUqmgr27q6d9kEvXhj64uWOlvrQTJCE4bI6PWPYS9mduml9z57glPqSOPgLBnqx8ucyYhew50CkzaUnWNH"
    static let SIGNUP                   = "api/sign_up/"
    static let CURRENT_TIME             = "api/current_time/"
    static let TOKEN                    = "api/social/token/"
    static let TOKEN_CONVERT            = "api/social/convert-token/"
    static let TOKEN_REVOKE             = "api/social/revoke-token/"
    
    
    static let APP_LAUNCH               = "api/app_launch/load/"
    //Profiles
    static let USERS                    = "api/users/"
    static let USERNAME_EXISTS          = "api/profiles/username_exists"
    static let EMAIL_EXISTS             = "api/profiles/email_exists"
    static let GET_CONFIRMATION_CODE    = "api/profiles/send_confirmation_code/"
    static let GET_EMAIL_VERIFIED       = "api/profiles/get_email_verified/"
    static let PROFILE_NEEDS_UPDATE     = "api/profiles/needs_social_update/"
    static let PROFILES                 = "api/profiles/"
    static let CURRENT_USER             = "api/profiles/current/"
    static let USER_PROFILE_STATS       = "api/profiles/get_profile_data/"
    static let USERPOFILE_SUBSCRIBE      = "api/profiles/subscribe/"
    static let USERPOFILE_UNSUBSCRIBE    = "api/profiles/unsubscribe/"

    //Surveys
    static let SURVEYS                  = "api/surveys/"
    static let SURVEYS_MEDIA            = "api/media/"
    static let SURVEYS_TOP              = "api/surveys/top/"
    static let SURVEYS_NEW              = "api/surveys/new/"
    static let SURVEYS_ALL              = "api/surveys/all/"
    static let SURVEYS_OWN              = "api/surveys/own/"
    static let SURVEYS_HOT              = "api/surveys/hot/"
    static let SURVEYS_HOT_EXCEPT       = "api/surveys/hot_except/"
    static let SURVEYS_FAVORITE         = "api/surveys/favorite/"
    static let SURVEYS_TOTAL_COUNT      = "api/surveys/total_count/"
    static let SURVEYS_BY_CATEGORY      = "api/surveys/by_category/"
    static let SURVEYS_BY_OWNER         = "api/surveys/by_owner/"
    static let SURVEYS_FAVORITE_LIST_BY_OWNER = "api/surveys/favorite_surveys_list_by_user/"
    static let SURVEYS_ADD_FAVORITE     = "api/surveys/add_favorite/"
    static let SURVEYS_REMOVE_FAVORITE  = "api/surveys/remove_favorite/"
    static let SURVEYS_REJECT           = "api/surveys/reject/"
    static let SURVEYS_CLAIM            = "api/surveys/claim/"
    static let SURVEYS_ADD_VIEW_COUNT   = "api/surveys/add_view_count/"
    
    static let SURVEYS_RESULTS          = "api/survey_results/"
    
    static let CATEGORIES               = "api/categories/"
    static let BALANCE                  = "api/current_balance_price/"
    
//    static let SMS_VALIDATION_URL   = "http://burber.pythonanywhere.com/passcode/generate/"
    
}




//MARK: - Methods
func isValidEmail(_ testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

func saveTokenInKeychain(json: JSON, tokenState: inout TokenState) {
    for attr in json {
        if attr.0 == "refresh_token" {
            KeychainService.saveRefreshToken(token: attr.1.stringValue as NSString)
            tokenState = TokenState.Received
        } else if attr.0 == "access_token" {
            KeychainService.saveAccessToken(token: attr.1.stringValue as NSString)
        } else if attr.0 == "expires_in" {
            let date = Date().addingTimeInterval(Double(attr.1.intValue as Int))
            KeychainService.saveTokenExpireDateTime(token: date.toDateTimeString() as NSString)
        } else {
            continue
        }
    }
}

func showAlert(type: CustomAlertView.AlertType, buttons: [[String : [CustomAlertView.ButtonType : Closure?]]?], title: String?, body: String?) {
    DispatchQueue.main.async() {
        let singleLineAlert = body == ""
        alert.setupView(singleLineAlert, type: type, buttons: buttons, title: title, body: body)
        if (!alertIsActive()) {
            alert.presentAlert()
        }
    }
}

func showAlert(type: CustomAlertView.AlertType, buttons: [[String : [CustomAlertView.ButtonType : Closure?]]?], text: String?) {
    DispatchQueue.main.async() {
        alert.setupView(true, type: type, buttons: buttons, title: text, body: "")
        if (!alertIsActive()) {
            alert.presentAlert()
        }
    }
}

func hideAlert() {
    if alertIsActive() {
        alert.dismissAlert()
    }
}

//func fetchOrders(_ onlyActive: Bool = true) -> [Order] {
//
//    var orders: [Order]             = [Order]()
//    let predicate                   = NSNumber(value: !onlyActive)
//    let context                     = appDelegate.persistentContainer.viewContext
//    let fetchRequest                = NSFetchRequest<NSFetchRequestResult>(entityName: entityOrder)
//    let sortDescriptor              = NSSortDescriptor(key: "orderID", ascending: true)
//    fetchRequest.sortDescriptors    = [sortDescriptor]
//    fetchRequest.predicate          = NSPredicate(format: "isCompleted == %@", predicate)
//    let fetchedResultsController    = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//
//    do {
//        try fetchedResultsController.performFetch()
//        if let fetchedObjects = fetchedResultsController.fetchedObjects {
//
//            for entity in fetchedObjects {
//                if let order = entity as? Orders {
//                    if let preparedOrder = Order(SQLOrder: order) {
//                        orders.append(preparedOrder)
//                    }
//                }
//            }
//        }
//    } catch let error {
//        fatalError(error.localizedDescription)
//    }
//    return orders
//}

func alertIsActive() -> Bool {
    return alert.isActive
}

func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: startDate, to: endDate)
    return components.year!
}

func daysBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: startDate, to: endDate)
    return components.day!
}

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(CGPointDistanceSquared(from: from, to: to))
}

func loadImageFromPath(path: String) -> UIImage? {
    if FileManager.default.fileExists(atPath: path) {
        print("FILE AVAILABLE")
    } else {
        print("FILE NOT AVAILABLE")
    }
    let image = UIImage(contentsOfFile: path)
    if image == nil {
        print("missing image at: (path)")
    }
    return image
}

@objc protocol ApiReachability {
    @objc func handleReachabilitySignal()
}

/// Invokes a given closure with a buffer containing all metaclasses known to the Obj-C
/// runtime. The buffer is only valid for the duration of the closure call.
func withAllClasses<R>(
    _ body: (UnsafeBufferPointer<AnyClass>) throws -> R
    ) rethrows -> R {
    
    var count: UInt32 = 0
    let classListPtr = objc_copyClassList(&count)
    defer {
        free(UnsafeMutableRawPointer(classListPtr))
    }
    let classListBuffer = UnsafeBufferPointer(
        start: classListPtr, count: Int(count)
    )
    
    return try body(classListBuffer)
}
//                               .flatMap in Swift < 4.1



