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

enum DjangoError: String {
    case InvalidGrant = "invalid credentials given."
    case AccessDenied = "access_denied"
    enum Authentication: String {
        case ConnectionFailed = "failed to establish a new connection"
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
        static let TopSurveysUpdated               = Notification.Name("NotificationTopSurveysUpdated")
        static let NewSurveysUpdated               = Notification.Name("NotificationNewSurveysUpdated")
        static let SurveysStackReceived            = Notification.Name("NotificationSurveysStackReceived")
        static let SurveysStackUpdated             = Notification.Name("NotificationSurveysStackUpdated")
        static let OwnSurveysUpdated               = Notification.Name("NotificationOwnSurveysUpdated")
        static let OwnSurveysReceived              = Notification.Name("NotificationOwnSurveysReceived")
        static let SurveysByCategoryUpdated        = Notification.Name("NotificationSurveysByCategoryUpdated")
        static let FavoriteSurveysUpdated          = Notification.Name("NotificationFavoriteSurveysUpdated")
        static let UserSurveysUpdated              = Notification.Name("NotificationUserSurveysUpdated")
        static let UserFavoriteSurveysUpdated      = Notification.Name("NotificationUserFavoriteSurveysUpdated")
    }
    
    struct UI {
        static let ClaimSignAppeared               = Notification.Name("ClaimSignAppeared")
        static let CategorySelected                = Notification.Name("CategorySelected")
        static let UserImageChanged                = Notification.Name("NotificationUserImageChanged")
        static let ProfileImageReceived            = Notification.Name("NotificationProfileImageReceived")
        
    }
}


let appDelegate                                  = UIApplication.shared.delegate as! AppDelegate
let MIN_STACK_SIZE                               = 4//Min quantity of hot surveys to request another portion

struct TimeIntervals {
    static let ClearRejectedSurveys: TimeInterval = 60//Timer parameter to wipe out rejectedSurveys container
    static let NetworkInactivity: TimeInterval = 15//Timer parameter to wipe out rejectedSurveys container
    static let UserStatsTimeOutdated: TimeInterval = 5//Timer parameter to update user stats (called in UI)
}



//MARK: - Segues
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
        static let NewSurveyToTypingViewController      = "NEW_TO_TYPE"
        static let NewSurveyToVotesCountViewController  = "NEW_TO_VOTES_COUNT"
        static let SurveyToUser                         = "SURVEY_TO_USER"
        static let SurveyToClaim                        = "SURVEY_TO_CLAIM"
        static let UserToUserSurveys                    = "USER_TO_USER_SURVEYS"
        static let UserToUserFavoriteSurveys            = "USER_TO_FAVORITE_USER_SURVEYS"
        static let CategoryToSurveys                    = "CATEGORY_TO_SURVEYS"
    }
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
let K_COLOR_RED                                 = UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)//C03E45 English Vermillion//UIColor(red:0.805, green: 0.342, blue:0.339, alpha:1)
let K_COLOR_GRAY                                = UIColor(red:0.574, green: 0.574, blue:0.574, alpha:1)
let K_COLOR_TABBAR                              = UIColor(red: 0.416, green: 0.400, blue: 0.639, alpha: 1.000)//UIColor(red: 0.227, green: 0.337, blue: 0.514, alpha: 1.000)//UIColor(red: 0.753, green: 0.243, blue: 0.271, alpha: 1.000)//UIColor(red: 0.035, green: 0.016, blue: 0.275, alpha: 1.000)//UIColor(red: 0.157, green: 0.188, blue: 0.267, alpha: 1.000)//283044 Space Cadet//UIColor(red:0.592, green: 0.46, blue:0.574, alpha:1)
let K_COLOR_CONTAINER_BG                        = UIColor(red: 0.910, green: 0.929, blue: 0.929, alpha: 1.000)
//let K_COLOR_TABBAR_INACTIVE                     = UIColor(red:0.636, green: 0.636, blue:0.636, alpha:1)
let K_COLOR_PEACH                               = UIColor(red: 0.910, green: 0.929, blue: 0.929, alpha: 1.000)
let K_COLOR_XANADU                              = UIColor(red: 0.482, green: 0.533, blue: 0.435, alpha: 1.000)
let K_COLOR_TUMBLEWEED                          = UIColor(red: 0.945, green: 0.671, blue: 0.525, alpha: 1.000)
let K_COLOR_SPACE_CADET                         = UIColor(red: 0.157, green: 0.188, blue: 0.267, alpha: 1.000)
let K_COLOR_INDIAN_YELLOW                       = UIColor(red: 0.859, green: 0.616, blue: 0.278, alpha: 1.000)
let K_COLOR_DARK_RURPLE                         = UIColor(red: 0.161, green: 0.024, blue: 0.157, alpha: 1.000)

struct Colors {
    struct UpperButtons {
        static let VioletBlueCrayola = UIColor(hexString: "#7776BC")
        static let Avocado           = UIColor(hexString: "#5C8001")
        static let HoneyYellow       = UIColor(hexString: "#FBB02D")
        static let MaximumRed        = UIColor(hexString: "#DD1C1A")
    }
    static let CadetBlue        = UIColor(hexString: "#699999")
    static let RussianViolet    = UIColor(hexString: "#1F2143")
}

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
            UserDefaults.standard.removeObject(forKey: "userEmailVerified")
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
    
    static let SURVEYS_RESULTS          = "api/survey_results/"
    
    static let CATEGORIES               = "api/categories/"
    
    
//    static let SMS_VALIDATION_URL   = "http://burber.pythonanywhere.com/passcode/generate/"
    
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
    }
    struct Survey {
        static let category                 = "category"
        static let owner                    = "owner"
        static let title                    = "title"
        static let description              = "description"
        static let hlink                    = "hlink"
        static let voteCapacity             = "vote_capacity"
        static let isPrivate                = "is_private"
        static let answers                  = "answers"
        static let images                   = "media"
        static let startDate                = "start_date"
        static let endDate                  = "end_date"
        static let likes                    = "likes"
        static let userprofile              = "userprofile"
    }
    struct FieldRestrictions {
        static let surveyTitleLength        = 30
        static let surveyQuestionLength     = 10000
        static let surveyAnswerLength       = 100
    }
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

struct StringAttributes {
    
    static func getFont(name: String, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont()
    }
    
    static func getAttributes(font: UIFont, foregroundColor: UIColor, backgroundColor: UIColor) -> [NSAttributedString.Key : Optional<NSObject>] {
        var stringAttrs: [NSAttributedString.Key : Optional<NSObject>] = [:]
        
        stringAttrs[NSAttributedString.Key.font]            = font
        stringAttrs[NSAttributedString.Key.foregroundColor] = foregroundColor
        stringAttrs[NSAttributedString.Key.backgroundColor] = backgroundColor
//        stringAttrs[NSAttributedString.Key.] = backgroundColor
        
        return stringAttrs
    }
    
    struct Fonts {
        
        
        
        struct Style {
            static let Semibold     = "OpenSans-Semibold"
            static let Bold         = "OpenSans-Bold"
            static let Regular      = "OpenSans"
            static let Light        = "OpenSans-Light"
            static let Italic       = "OpenSans-Italic"
            static let Extrabold    = "OpenSans-ExtraBold"
        }
    }
    
    struct SemiBold {
        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 12),
                                                 NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                                 NSAttributedString.Key.backgroundColor: UIColor.clear]
        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 11),
                                                 NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                                 NSAttributedString.Key.backgroundColor: UIColor.clear]
    }
    
    struct Bold {
        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 12),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    }
    
    struct Regular {
        static let red_12       = [NSAttributedString.Key.font : UIFont(name: "OpenSans", size: 12),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
        static let red_11       = [NSAttributedString.Key.font : UIFont(name: "OpenSans", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    }

}

