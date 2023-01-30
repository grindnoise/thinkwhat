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

var localhost: Bool {
    //    let dict = ProcessInfo.processInfo.environment
    //    guard dict.keys.contains("localhost") else { return false }
#if LOCAL
    return true
#else
    return false
#endif
}
var logger = TimeLogger(sinceOrigin: true)
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

func delayAsync(delay: Double, completion:@escaping ()->()) {
    Task {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        await MainActor.run {
            completion()
        }
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

enum FileFormat: String, CaseIterable {
    case PNG        = "png"
    case JPEG       = "jpg"
    case TIFF       = "tiff"
    case GIF        = "gif"
    case Unknown    = "thinkwhat"
    
    static func fromString(_ string: String) -> Self {
        for value in Self.allCases {
            guard string.lowercased() == value.rawValue else { continue }
            return value
        }
        return .Unknown
    }
}

enum State {
    case enabled, disabled
}

//enum TokenState {
//    case Received
//    case Error
//    case Unassigned
//    case WrongCredentials
//    case Expired
//    case Revoked
//    case ConnectionError
//    case AccessDenied
//}

enum ApiReachabilityState {
    case Reachable, None
}

enum SessionType: String {
    case authorized     = "authorized"
    case unauthorized   = "unauthorized"
}

enum Gender: String, CaseIterable {
    case Male           = "Male"
    case Female         = "Female"
    case Unassigned     = "all_genders"
}

enum InternetConnection {
    case Available
    case None
}

enum AuthProvider: String {
    case VK         = "vk-oauth2"
    case Facebook   = "Facebook"
    case Google     = "google-oauth2"
    case Phone      = "Phone"
    case Mail       = "Mail"
    case Username   = "Username"
}

enum SocialMedia: String {
    case VK, Facebook, TikTok, Instagram
}

enum ThirdPartyApp: String {
    case TikTok     = "TikTok"
    case Youtube    = "Youtube"
    case Null       = ""
    
    func logo() -> UIView {
      var instance = UIView()
      switch self {
      case .Youtube:
        instance = YoutubeLogo()
      case .TikTok:
        instance = TikTokLogo()
      default:
        return UIView()
      }
      instance.isOpaque = false
      
      return instance
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
//var tokenState: TokenState    = .Unassigned {
//    didSet {
//        switch tokenState {
//        case .Received:
//            NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
//        case .Error:
//            NotificationCenter.default.post(name: Notifications.OAuth.TokenError, object: nil)
//        case .Revoked:
//            NotificationCenter.default.post(name: Notifications.OAuth.TokenRevoked, object: nil)
//        case .WrongCredentials:
//            NotificationCenter.default.post(name: Notifications.OAuth.TokenWrongCredentials, object: nil)
//        case .ConnectionError:
//            NotificationCenter.default.post(name: Notifications.OAuth.TokenConnectionError, object: nil)
//        case .AccessDenied:
//            NotificationCenter.default.post(name: Notifications.OAuth.TokenAccessDenied, object: nil)
//        default:
//            print(tokenState)
//        }
//    }
//}
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






//MARK: - Methods

@discardableResult
func saveTokenInKeychain(json: JSON) -> Result<Bool, Error> {//}, tokenState: inout TokenState) {
    var success = false
    for attr in json {
        if attr.0 == "refresh_token" {
            KeychainService.saveRefreshToken(token: attr.1.stringValue as NSString)
            success = true
//            tokenState = TokenState.Received
        } else if attr.0 == "access_token" {
            KeychainService.saveAccessToken(token: attr.1.stringValue as NSString)
            success = true
        } else if attr.0 == "expires_in" {
            let date = Date().addingTimeInterval(Double(attr.1.intValue as Int))
            KeychainService.saveTokenExpireDateTime(token: date.toDateTimeString() as NSString)
            success = true
        } else {
            continue
        }
    }
    return success ? .success(true) : .failure("No keys found")
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

//func initImage(path: String) -> UIImage? {
//        return UIImage(contentsOfFile: path)
////    if FileManager.default.fileExists(atPath: path) {
////        return nil
////    }
////    let image = UIImage(contentsOfFile: path)
////    if image == nil {
////        print("missing image at: (path)")
////    }
////    return image
//}

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



