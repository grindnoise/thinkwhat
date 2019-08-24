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

enum TokenState {
    case Received, Error, Unassigned, WrongCredentials, Expired, Revoked, ConnectionError
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
    case InvalidGrant = "invalid_grant"
}

enum ClientSettingsMode {
    case Reminder, Language
}
var tokenState: TokenState    = .Unassigned {
    didSet {
        switch tokenState {
        case .Received:
            NotificationCenter.default.post(name: kNotificationTokenReceived, object: nil)
        case .Error:
            NotificationCenter.default.post(name: kNotificationTokenError, object: nil)
        case .Revoked:
            NotificationCenter.default.post(name: kNotificationTokenRevoked, object: nil)
        case .WrongCredentials:
            NotificationCenter.default.post(name: kNotificationTokenWrongCredentials, object: nil)
        case .ConnectionError:
            NotificationCenter.default.post(name: kNotificationTokenConnectionError, object: nil)
        default:
            print("TODO")
        }
    }
}
var emailResponse: EmailResponse? {
    didSet {
        if emailResponse != nil {
            NotificationCenter.default.post(name: kNotificationEmailResponseReceived, object: nil)
        }
    }
}
var firstLaunch                                 = true
var internetConnection: InternetConnection      = .Available {
    didSet {
        if internetConnection != oldValue {
            NotificationCenter.default.post(name: kNotificationInternetConnectionChange, object: nil)
        }
    }
}
var apiReachability: ApiReachabilityState = .Reachable {
    didSet {
        if apiReachability == .None {
            NotificationCenter.default.post(name: kNotificationApiNotReachable, object: nil)
        } else {
            NotificationCenter.default.post(name: kNotificationApiReachable, object: nil)
        }
    }
}

let kNotificationInternetConnectionChange        = Notification.Name("InternetConnectionChange")
let kNotificationTokenReceived                   = Notification.Name("NotificationTokenReceived")
let kNotificationTokenError                      = Notification.Name("NotificationTokenError")
let kNotificationTokenRevoked                    = Notification.Name("NotificationTokenRevoked")
let kNotificationTokenWrongCredentials           = Notification.Name("NotificationTokenWrongCredentials")
let kNotificationTokenConnectionError            = Notification.Name("NotificationTokenConnectionError")
let kNotificationEmailResponseReceived           = Notification.Name("NotificationEmailResponseReceived")
let kNotificationEmailResponseExpired            = Notification.Name("NotificationEmailResponseExpired")

let kNotificationApiReachable                    = Notification.Name("smsNotificationApiReachable")
let kNotificationApiNotReachable                 = Notification.Name("smsNotificationApiNotReachable")

let appDelegate                                  = UIApplication.shared.delegate as! AppDelegate


//MARKS: - Segues
let kSegueApp                                    = "APP"
let kSegueAppFromMailSignin                      = "APP_FROM_MAIL_SIGNIN"
let kSegueAppFromTerms                           = "APP_FROM_TERMS"
let kSegueAuth                                   = "AUTH"
let kSegueSocialAuth                             = "SOCIAL"
let kSegueMailValidationFromSignup               = "MAIL_VALID_SIGNUP"
let kSegueMailValidationFromSignin               = "MAIL_VALID_SIGNIN"
let kSegueTermsFromValidation                    = "TERMS_VALID"
let kSegueTermsFromStartScreen                   = "TERMS_START_SCREEN"
let kSegueMailAuth                               = "MAILAUTH"
let kSeguePwdRecovery                            = "PWD_RECOVERY"


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
let K_COLOR_RED                                 = UIColor(red:0.805, green: 0.342, blue:0.339, alpha:1)
let K_COLOR_GRAY                                = UIColor(red:0.574, green: 0.574, blue:0.574, alpha:1)
let options: UNAuthorizationOptions             = [.alert, .sound, .badge]

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
        var ID: String! {
            didSet {
                if ID != oldValue {
                    UserDefaults.standard.set(ID, forKey: "userId")
                } else if ID.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "userId")
                }
            }
        }
        var username: String! {
            didSet {
                if username != oldValue {
                    UserDefaults.standard.set(username, forKey: "username")
                } else if username.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "username")
                }
            }
        }
        var firstName: String! {
            didSet {
                if firstName != oldValue {
                    UserDefaults.standard.set(firstName, forKey: "firstName")
                } else if firstName.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "firstName")
                }
            }
        }
        var lastName: String! {
            didSet {
                if lastName != oldValue {
                    UserDefaults.standard.set(lastName, forKey: "lastName")
                } else if lastName.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "lastName")
                }
            }
        }
        var email: String! {
            didSet {
                if email != oldValue {
                    UserDefaults.standard.set(email, forKey: "userMail")
                } else if email.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "userMail")
                }
            }
        }
        
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kFirstName = UserDefaults.standard.object(forKey: "firstname") {
                self.firstName = kFirstName as? String
            }
            if let kLastName = UserDefaults.standard.object(forKey: "lastname") {
                self.lastName = kLastName as? String
            }
            if let kUserName = UserDefaults.standard.object(forKey: "userName") {
                self.username = kUserName as? String
            }
            if let kUserMail = UserDefaults.standard.object(forKey: "userMail") {
                self.email = kUserMail as? String
            }
            if let kUserID = UserDefaults.standard.object(forKey: "userID") {
                self.ID = kUserID as? String
            }
        }
        
        mutating func eraseData() {
            firstName               = ""
            lastName                = ""
            username                = ""
            ID                      = ""
            email                   = ""
            KeychainService.saveAccessToken(token: "")
            KeychainService.saveRefreshToken(token: "")
        }
    }
    
    struct UserProfile {
        var ID: String! {
            didSet {
                if ID != oldValue {
                    UserDefaults.standard.set(ID, forKey: "userProfileID")
                } else if ID.isEmpty {
                    UserDefaults.standard.removeObject(forKey: "userProfileID")
                }
            }
        }
        var imagePath: String! {
            didSet {
                if !imagePath.isEmpty {
                    UserDefaults.standard.set(imagePath, forKey: "userImagePath")
                } else {
                    UserDefaults.standard.removeObject(forKey: "userImagePath")
                }
            }
        }
        var gender: Gender! {
            didSet {
                if gender == nil {
                    UserDefaults.standard.removeObject(forKey: "userGender")
                } else if gender != oldValue {
                    UserDefaults.standard.set(gender.rawValue, forKey: "userGender")
                }
            }
        }
        var birthDate: Date! {
            didSet {
                let defaultDate = Date(dateString: "01.01.0001")
                if (birthDate != oldValue) && (birthDate != defaultDate)  {
                    UserDefaults.standard.set(birthDate, forKey: "userBirthDate")
                } else {
                    UserDefaults.standard.removeObject(forKey: "userBirthDate")
                }
            }
        }
        
        init() {
            getData()
        }
        
        mutating func getData() {
            if let kImagePath = UserDefaults.standard.object(forKey: "userImagePath") {
                self.imagePath = kImagePath as? String
            }
            if let kUserBirthDate = UserDefaults.standard.object(forKey: "userBirthDate") {
                self.birthDate = kUserBirthDate as? Date
            }
            if let kUserGender = UserDefaults.standard.object(forKey: "userGender") {
                self.gender = Gender(rawValue: kUserGender as! String)!
            }
            if let kUserID = UserDefaults.standard.object(forKey: "userProfileID") {
                self.ID = kUserID as? String
            }
        }
        
        mutating func eraseData() {
            imagePath = ""
            birthDate = Date(dateString: "01.01.0001")
            gender    = .none
            ID        = ""
        }
    }
    
    struct System {
        var session: SessionType! = .unauthorized {
            didSet {
                if session == .authorized {
                    UserDefaults.standard.set(SessionType.authorized.rawValue, forKey: "session")
                } else {
                    UserDefaults.standard.set(SessionType.unauthorized.rawValue, forKey: "session")
                }
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
            
            if let kSession = UserDefaults.standard.object(forKey: "session") {
                self.session = SessionType(rawValue: kSession as! String)!
            }
//            print(UserDefaults.standard.object(forKey: "emailResponseExpirationDate"))
//            if let kEmailResponseExpirationDate = UserDefaults.standard.object(forKey: "emailResponseExpirationDate") as? Date, let kEmailResponseConfirmationCode = UserDefaults.standard.object(forKey: "emailResponseConfirmationCode") as? Int {
//                if Date() < kEmailResponseExpirationDate {
//                    emailResponse = EmailResponse(confirmation_code: kEmailResponseConfirmationCode, expiresIn: kEmailResponseExpirationDate)
//                }
//            }
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
        }
        
        mutating func eraseData() {
            session = .unauthorized
//            emailResponseExpirationDate = nil
//            emailResponseConfirmationCode = nil
            session = .unauthorized
            let langStr = Locale.current.languageCode
            if langStr == "en-US" {
                language = .English
            } else if langStr == "ru_RU" {
                language = .Russian
            }
            KeychainService.saveAccessToken(token: "")
            KeychainService.saveRefreshToken(token: "")
        }
    }
    
    func importUserData(_ json: JSON) {
        var userProfileData         = json.dictionaryObject  as! [String: Any]
        var userData                = userProfileData.removeValue(forKey: "user") as! [String: Any]
        self.user.email             = userData["email"] as! String
        self.user.firstName         = userData["first_name"] as! String
        self.user.lastName          = userData["last_name"] as! String
        self.user.username          = userData["username"] as! String
        self.user.ID                = String(describing: userData["id"] as! Int)
        self.userProfile.ID         = String(describing: userProfileData["id"] as! Int)
        self.userProfile.birthDate  = userProfileData["birth_date"] is NSNull ? Date(dateString: "01.01.0001") : Date(dateString:userProfileData["birth_date"] as! String)
        self.userProfile.gender     = userProfileData["gender"] is NSNull ? Gender.Unassigned : Gender(rawValue: userProfileData["gender"] as! String)
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
    static let BASE                     = "http://127.0.0.1:8000/"//"https://damp-oasis-64585.herokuapp.com/"
    static let CLIENT_ID                = "o1Flzw2j8yaRVhSnLJr0JY5Hd6hcA8C0aiv2EUAS"//"bdOS2la5RAgkZNq4uSq0esOIa0kZmlL05nt2OjSw"
    static let CLIENT_SECRET            = "IQnHcT6s6RqPJhws0mi3e8zWc9uXiTugkclkY9l2xd0FGFnUqmgr27q6d9kEvXhj64uWOlvrQTJCE4bI6PWPYS9mduml9z57glPqSOPgLBnqx8ucyYhew50CkzaUnWNH"
    //"Swx6TUPhgYpGqOe2k1B0UGxjeX19aRhb5RkkVzpPzYEluzPlHse5OaB5NSV3Ttj0n0sWBFOvZvAGef1qdcNOfJ56t15QDIvNftqdUB8WXukLJsowfuVtrcj415t28nCO"
    static let SIGNUP                   = "api/sign_up/"
    static let TOKEN                    = "api/social/token/"
    static let TOKEN_CONVERT            = "api/social/convert-token/"
    static let TOKEN_REVOKE             = "api/social/revoke-token/"
    static let USERNAME_EXISTS          = "api/profiles/username_exists"
    static let EMAIL_EXISTS             = "api/profiles/email_exists"
    static let GET_CONFIRMATION_CODE    = "api/send-confirmation-code"
    static let GET_EMAIL_VERIFIED       = "api/profiles/get_email_verified"
    
    static let PROFILE_NEEDS_UPDATE     = "api/profiles/needs_social_update/"
    static let PROFILE                  = "api/profiles/"
    static let CURRENT_USER             = "api/profiles/current/"
    static let USER                     = "api/users/"
    
    static let SURVEY                   = "api/surveys/"
    
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
    
    AppData.shared.system.session = .authorized
    
    //    let refresh_token = KeychainService.loadRefreshToken()
    //    let access_token  = KeychainService.loadAccessToken()
    //
    //    print("refresh_token \(refresh_token!)")
    //    print("access_token \(access_token!)")
    
}

func showAlert(type: CustomAlertView.AlertType, buttons: [String : [CustomAlertView.ButtonType : Closure?]]?, title: String?, body: String?) {
    DispatchQueue.main.async() {
        let singleLineAlert = body == ""
        alert.setupView(singleLineAlert, type: type, buttons: buttons, title: title, body: body)
        if (!alertIsActive()) {
            alert.presentAlert()
        }
    }
}

func showAlert(type: CustomAlertView.AlertType, buttons: [String : [CustomAlertView.ButtonType : Closure?]]?, text: String?) {
    DispatchQueue.main.async() {
        alert.setupView(true, type: type, buttons: buttons, title: text, body: "")
        if (!alertIsActive()) {
            alert.presentAlert()
        }
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

func loadImageFromPath(path: String) -> UIImage? {
    let image = UIImage(contentsOfFile: path)
    if image == nil {
        print("missing image at: (path)")
    }
    return image
}

@objc protocol ApiReachability {
    @objc func handleReachabilitySignal()
}
