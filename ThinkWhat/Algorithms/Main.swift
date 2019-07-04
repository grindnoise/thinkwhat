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

//seconds
enum ReminderInterval: Int {
    case Minutes_15 = 90
    case Minutes_30 = 180
    case Minutes_45 = 270
    case Hours_1    = 3600
    case Hours_2    = 7200
    case Hours_4    = 14400
    case Hours_6    = 21600
    case Hours_12   = 43200
    case Hours_24   = 86400
}

enum Language: String {
    case English = "English"
    case Russian = "Русский"
}

enum AnnotationStatus {
    case Active
    case Completed
    case Unassigned
}

enum ImageExtension: String {
    case PNG  = "png"
    case JPEG = "jpg"
    case TIFF = "tiff"
}

enum TokenState {
    case Received, Error, Unassigned, WrongCredentials, Expired, Revoked
}

enum SessionType: String {
    case authorized     = "authorized"
    case guest          = "guest"
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
    case Instagram  = "Instagram"
    case VK         = "VK"
    case OK         = "OK"
    case Facebook   = "Facebook"
    case Google     = "Google"
    case Phone      = "Phone"
    case Mail       = "Mail"
    case Undefined  = "Undefined"
}

enum GPSstate {
    case NoSignal
    case PoorSignal
    case PreciseSignal
}

enum ClientSettingsMode {
    case Reminder, Language
}

var tokenState: TokenState    = .Unassigned {
    didSet {
        switch tokenState {
        case .Received:
            NotificationCenter.default.post(name: kNotificationSuccessToken, object: nil)
        case .Error:
            NotificationCenter.default.post(name: kNotificationFailToken, object: nil)
        case .Revoked:
            print("TODO")
        case .WrongCredentials:
            NotificationCenter.default.post(name: kNotificationFailToken, object: nil)
        default:
            print("TODO")
        }
    }
}
var userLocation = CLLocation() {
    didSet {
        userLocationPoint = MKMapPoint(userLocation.coordinate)
    }
}

let iOS_11: Bool = {
    if #available(iOS 11.0, *) {
        return true
    } else {
        return false
    }
}()

var userLocationPoint                           = MKMapPoint()
var smsResponse: SMSResponse? {
    didSet {
        if smsResponse != nil {
            NotificationCenter.default.post(name: kNotificationSMSResponse, object: nil)
        }
    }
}
var firstLaunch                                 = true
var appData                                     = AppData()
var internetConnection: InternetConnection      = .Available {
    didSet {
        if internetConnection != oldValue {
            NotificationCenter.default.post(name: kNotificationInternetConnectionChange, object: nil)
        }
    }
}
let kNotificationInternetConnectionChange        = Notification.Name("InternetConnectionChange")
let kNotificationSuccessToken                    = Notification.Name("SuccessTokenNotification")
let kNotificationFailToken                       = Notification.Name("FailTokenNotification")
let kNotificationWrongCredentialsToken           = Notification.Name("WrongCredentialsTokenNotification")
let kNotificationSMSResponse                     = Notification.Name("smsResponseNotification")

let appDelegate                                  = UIApplication.shared.delegate as! AppDelegate


//MARKS: - Segues
let kSegueApp                                    = "APP"
let kSegueAuth                                   = "AUTH"
let kSegueSocialAuth                             = "SOCIAL"
let kSegueTerms                                  = "TERMS"
let kSegueMailAuth                               = "MAILAUTH"
let kSeguePwdRecovery                            = "PWD"
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
struct AppData {
    
//    let reminderSettings: [[String: ReminderInterval]] = [["15 мин."   : ReminderInterval.Minutes_15],
//                                                          ["30 мин."   : ReminderInterval.Minutes_30],
//                                                          ["45 мин."   : ReminderInterval.Minutes_45],
//                                                          ["1 ч."      : ReminderInterval.Hours_1],
//                                                          ["2 ч."      : ReminderInterval.Hours_2],
//                                                          ["4 ч."      : ReminderInterval.Hours_4],
//                                                          ["6 ч."      : ReminderInterval.Hours_6],
//                                                          ["12 ч."     : ReminderInterval.Hours_12],
//                                                          ["24 ч."     : ReminderInterval.Hours_24]]
    let languages: [Language] = [.English, .Russian]
//
//    var reminder: ReminderInterval! {
//        didSet {
//            if reminder != oldValue {
//                UserDefaults.standard.set(reminder.rawValue, forKey: "reminder")
//            } else {
//                UserDefaults.standard.removeObject(forKey: "reminder")
//            }
//        }
//    }
    var language: Language! {
        didSet {
            if language != oldValue {
                UserDefaults.standard.set(language.rawValue, forKey: "language")
            } else {
                UserDefaults.standard.removeObject(forKey: "language")
            }
        }
    }
//    var phone: String! {
//        didSet {
//            if phone != oldValue {
//                UserDefaults.standard.set(username, forKey: "phone")
//            } else if phone.isEmpty {
//                UserDefaults.standard.removeObject(forKey: "phone")
//            }
//        }
//    }
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
    var profileImagePath: String! {
        didSet {
            if !profileImagePath.isEmpty {
                UserDefaults.standard.set(profileImagePath, forKey: "userImagePath")
            } else {
                UserDefaults.standard.removeObject(forKey: "userImagePath")
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
    var session: SessionType! = .guest {
        didSet {
            if session == .authorized {
                UserDefaults.standard.set(SessionType.authorized.rawValue, forKey: "session")
            } else {
                UserDefaults.standard.set(SessionType.guest.rawValue, forKey: "session")
            }
        }
    }
    
    init() {
        retrieveUserData()
    }
    
    mutating func retrieveUserData() {
        
        if let kSession = UserDefaults.standard.object(forKey: "session") {
            self.session = SessionType(rawValue: kSession as! String)!
        }
        
        if let kProfileImagePath = UserDefaults.standard.object(forKey: "userImagePath") {
            self.profileImagePath = kProfileImagePath as? String
        }
        if let kFirstName = UserDefaults.standard.object(forKey: "firstname") {
            self.firstName = kFirstName as? String
        }
        if let kLastName = UserDefaults.standard.object(forKey: "lastname") {
            self.lastName = kLastName as? String
        }
        if let kUserName = UserDefaults.standard.object(forKey: "userName") {
            self.username = kUserName as? String
        }
        
//        if let kPhone = UserDefaults.standard.object(forKey: "phone") {
//            self.phone = kPhone as? String
//        }
        
        if let kUserBirthDate = UserDefaults.standard.object(forKey: "userBirthDate") {
            self.birthDate = kUserBirthDate as? Date
        }
        
        if let kUserGender = UserDefaults.standard.object(forKey: "userGender") {
            self.gender = Gender(rawValue: kUserGender as! String)!
        }
        
        if let kUserMail = UserDefaults.standard.object(forKey: "userMail") {
            self.email = kUserMail as? String
        }
        
//        if let kReminder = UserDefaults.standard.object(forKey: "reminder") {
//            self.reminder = ReminderInterval(rawValue: kReminder as! Int)!
//        } else {
//            self.reminder = ReminderInterval.Hours_1
//        }
        
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
    
    mutating func clearUserData() {
        firstName               = ""
        lastName                = ""
        username                = ""
        profileImagePath        = ""
        email                   = ""
//        phone                   = ""
        gender                  = .none
        birthDate               = Date(dateString: "01.01.0001")
        session                 = .guest
//        reminder                = .Hours_1
        let langStr = Locale.current.languageCode
        if langStr == "en-US" {
            language = .English
        } else if langStr == "ru_RU" {
            language = .Russian
        }
//        KeychainService.savePassword(token: "")
        KeychainService.saveAccessToken(token: "")
        KeychainService.saveRefreshToken(token: "")
    }
    
    mutating func importFacebookData(_ json: JSON) {
        print(json)
        
    }
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
    
    static let APP_ID               = "7043775"
    
}

struct SERVER_URLS {
    
    static let BASE_URL             = "http://127.0.0.1:8000/"//"https://damp-oasis-64585.herokuapp.com/"
    
    static let CLIENT_ID            = "TK6NnHgbNmrsG18wA68pHSMcG6P74nDyhtNf4Hwt"//"bdOS2la5RAgkZNq4uSq0esOIa0kZmlL05nt2OjSw"
    
    static let CLIENT_SECRET        = "KikkeyTn2k3UpNQAR2DoYjrdrsbeu4LEmxZJHQtWGvh8fwaUY8fT3tA1ox6qjEYzcvzEVbo7Z9cq7ITLufGrQv5F8ROFuiHifYjyuh0KvG38yBgQnaiBPSvezFlnqZdj"//"Swx6TUPhgYpGqOe2k1B0UGxjeX19aRhb5RkkVzpPzYEluzPlHse5OaB5NSV3Ttj0n0sWBFOvZvAGef1qdcNOfJ56t15QDIvNftqdUB8WXukLJsowfuVtrcj415t28nCO"
    static let SIGNUP_URL           = "api/sign_up"
    
    static let TOKEN_URL            = "api/social/token/"
    
    static let TOKEN_CONVERT_URL    = "api/social/convert-token/"
    
    static let TOKEN_REVOKE_URL     = "api/social/revoke-token/"
    
    
    
    static let SURVEY_URL           = "api/surveys/"
    
    
    
    
    
    static let CURRENT_USER_URL     = "api/profiles/current/"
    
    static let GET_FACEBOOK_ID_URL  = "api/profiles/get_facebook_id/"
    
    static let USER_URL             = ""
    
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
    
    appData.session = .authorized
    
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

func hasSMSPasscodeExpired() -> Bool {
    return Date() >= smsResponse!.expiryDateTime
}

func loadImageFromPath(path: String) -> UIImage? {
    let image = UIImage(contentsOfFile: path)
    if image == nil {
        print("missing image at: (path)")
    }
    return image
}


