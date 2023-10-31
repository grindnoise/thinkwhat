//
//  AppSettings.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

struct Constants {
  struct TimeIntervals {
    static let updateStatsComments = 10.0
    static let updateStats = 10.0
    static let requestPublications = 5.0
    static let bannerAutoDismiss = 2.0
  }
  
  struct Pagination {
    static let threshold = 10 // To request new chunk of data when sroll near list end
  }
  
  struct DataControl {
    static let shareLinkArraySize = 2 // It should be hash and enc - last two params in deeplink https://www.thinkwhat.app/share/04bc64dd3146/eJzTyCkw4PI0NDPmSgwzNNIzNNAzMjAyVjA0sAIiUyOuAkOuRD0AmUAHyw==/
  }
  
  struct Validators {
    static let usernameMinLenth = 4
  }
  
  struct UI {
    struct Colors {
    //  case system(System)
    //  case logo(Logo)
    //  case tag(Tag)
      
      enum System: RawRepresentable, CaseIterable {
        typealias RawValue = UIColor
        
        case Red//Persian red
        case Purple
        
        init?(rawValue: RawValue) {
          switch rawValue.toHexString().lowercased() {
          case "#cc3333".lowercased(): self = .Red
          case "#666699".lowercased(): self = .Purple
          default: return nil
          }
        }
        
        var rawValue: RawValue {
          switch self {
          case .Red:      return UIColor(hexString: "#cc3333")
          case .Purple:   return UIColor(hexString: "#666699")
          }
        }
        
        public func next() -> System {
          switch self {
          case .Red: return .Purple
          case .Purple: return .Red
          }
        }
      }
      
      enum Logo: RawRepresentable, CaseIterable {
        typealias RawValue = UIColor
        
        case Main
        case Flame            //= UIColor(hexString: "#e4572e")
        case CoolGray   //= UIColor(hexString: "#AFC2D5")
        case Marigold         //= UIColor(hexString: "#F3A712")
        case GreenMunshell          //= UIColor(hexString: "#A8C686")
        case AirBlue          //= UIColor(hexString: "#669BBC")
        
        init?(rawValue: RawValue) {
          switch rawValue.toHexString().lowercased() {
          case "#009800".lowercased(): self = .Main
          case "#e4572e".lowercased(): self = .Flame
          case "#8B8BAE".lowercased(): self = .CoolGray
          case "#F3A712".lowercased(): self = .Marigold
          case "#00A878".lowercased(): self = .GreenMunshell
          case "#669BBC".lowercased(): self = .AirBlue
          default: return nil
          }
        }
        
        var rawValue: RawValue {
          switch self {
          case .Main:                 return UIColor(hexString: "#009800")
          case .Flame:                return UIColor(hexString: "#e4572e")
          case .CoolGray:             return UIColor(hexString: "#8B8BAE")
          case .Marigold:             return UIColor(hexString: "#F3A712")
          case .GreenMunshell:        return UIColor(hexString: "#00A878")
          case .AirBlue:              return UIColor(hexString: "#669BBC")
          }
        }
        
        public func next() -> Logo {
          switch self {
          case .Main: return .Flame
          case .Flame: return .CoolGray
          case .CoolGray: return .Marigold
          case .Marigold: return .GreenMunshell
          case .GreenMunshell: return .AirBlue
          case .AirBlue: return .Flame
          }
        }
      }
      
      enum Tag: RawRepresentable, CaseIterable {
        typealias RawValue = UIColor
        
        case RoyalPurple
        case PacificBlue
        case LaserLemon
        case CoyoteBrown
        case EnglishVermillion
        case BudGreen
        case Corn
        case Saffron
        case OrangeSoda
        case DarkSlateBlue
        case BleuDeFrance
        case SandyBrown
        case CafeNoir
        case Cardinal
        case GreenPantone
        case HoneyYellow
        case VioletBlueCrayola
        case Avocado
        
        init?(rawValue: RawValue) {
          switch rawValue.toHexString().lowercased() {
          case "#6C4FB2".lowercased(): self = .RoyalPurple
          case "#47A8BD".lowercased(): self = .PacificBlue
          case "#F0F757".lowercased(): self = .LaserLemon
          case "#8F5D35".lowercased(): self = .CoyoteBrown
          case "#D14C57".lowercased(): self = .EnglishVermillion
          case "#72BC71".lowercased(): self = .BudGreen
          case "#F2E86D".lowercased(): self = .Corn
          case "#F8C630".lowercased(): self = .Saffron
          case "#F2542D".lowercased(): self = .OrangeSoda
          case "#4E4187".lowercased(): self = .DarkSlateBlue
          case "#3083DC".lowercased(): self = .BleuDeFrance
          case "#FC9F5B".lowercased(): self = .SandyBrown
          case "#4E3822".lowercased(): self = .CafeNoir
          case "#AD343E".lowercased(): self = .Cardinal
          case "#4DAA57".lowercased(): self = .GreenPantone
          case "#FBB02D".lowercased(): self = .HoneyYellow
          case "#7776BC".lowercased(): self = .VioletBlueCrayola
          case "#5C8001".lowercased(): self = .Avocado
          default: return nil
          }
        }
        
        var rawValue: RawValue {
          switch self {
          case .RoyalPurple:          return UIColor(hexString: "#6C4FB2")
          case .PacificBlue:          return UIColor(hexString: "#47A8BD")
          case .LaserLemon:           return UIColor(hexString: "#F0F757")
          case .CoyoteBrown:          return UIColor(hexString: "#8F5D35")
          case .EnglishVermillion:    return UIColor(hexString: "#D14C57")
          case .BudGreen:             return UIColor(hexString: "#72BC71")
          case .Corn:                 return UIColor(hexString: "#F2E86D")
          case .Saffron:              return UIColor(hexString: "#F8C630")
          case .OrangeSoda:           return UIColor(hexString: "#F2542D")
          case .DarkSlateBlue:        return UIColor(hexString: "#4E4187")
          case .BleuDeFrance:         return UIColor(hexString: "#3083DC")
          case .SandyBrown:           return UIColor(hexString: "#FC9F5B")
          case .CafeNoir:             return UIColor(hexString: "#4E3822")
          case .Cardinal:             return UIColor(hexString: "#AD343E")
          case .GreenPantone:         return UIColor(hexString: "#4DAA57")
          case .HoneyYellow:          return UIColor(hexString: "#FBB02D")
          case .VioletBlueCrayola:    return UIColor(hexString: "#7776BC")
          case .Avocado:              return UIColor(hexString: "#5C8001")
          }
        }
        
        public func next() -> Tag {
          switch self {
          case .RoyalPurple: return .PacificBlue
          case .PacificBlue: return .LaserLemon
          case .LaserLemon: return .CoyoteBrown
          case .CoyoteBrown: return .EnglishVermillion
          case .EnglishVermillion: return .BudGreen
          case .BudGreen: return .Corn
          case .Corn: return .Saffron
          case .Saffron: return .OrangeSoda
          case .OrangeSoda: return .DarkSlateBlue
          case .DarkSlateBlue: return .BleuDeFrance
          case .BleuDeFrance: return .SandyBrown
          case .SandyBrown: return .CafeNoir
          case .CafeNoir: return .Cardinal
          case .Cardinal: return .GreenPantone
          case .GreenPantone: return .HoneyYellow
          case .HoneyYellow: return .VioletBlueCrayola
          case .VioletBlueCrayola: return .Avocado
          case .Avocado: return .RoyalPurple
          }
        }
        
        static func all() -> [UIColor] {
          return [
            Tag.GreenPantone.rawValue,
            Tag.EnglishVermillion.rawValue,
            Tag.HoneyYellow.rawValue,
            Tag.RoyalPurple.rawValue,
            Tag.Saffron.rawValue,
            Tag.CoyoteBrown.rawValue,
            Tag.BudGreen.rawValue,
            Tag.PacificBlue.rawValue,
            Tag.LaserLemon.rawValue,
            Tag.Corn.rawValue,
            Tag.Saffron.rawValue,
            Tag.OrangeSoda.rawValue,
            Tag.DarkSlateBlue.rawValue,
            Tag.BleuDeFrance.rawValue,
            Tag.SandyBrown.rawValue,
            Tag.CafeNoir.rawValue,
            Tag.Cardinal.rawValue,
            Tag.VioletBlueCrayola.rawValue,
            Tag.Avocado.rawValue
          ]
        }
      }
      
      static func getColor(forId id: Int) -> UIColor {
        let colors = [
          UIColor(hexString: "#6C4FB2"),
          UIColor(hexString: "#47A8BD"),
          UIColor(hexString: "#8F5D35"),
          UIColor(hexString: "#D14C57"),
          UIColor(hexString: "#72BC71"),
          UIColor(hexString: "#F2E86D"),
          UIColor(hexString: "#F8C630"),
          UIColor(hexString: "#F2542D"),
          UIColor(hexString: "#4E4187"),
          UIColor(hexString: "#3083DC"),
          UIColor(hexString: "#FC9F5B"),
          UIColor(hexString: "#4E3822"),
          UIColor(hexString: "#AD343E"),
          UIColor(hexString: "#4DAA57"),
          UIColor(hexString: "#FBB02D"),
          UIColor(hexString: "#7776BC"),
          UIColor(hexString: "#5C8001"),
          UIColor(hexString: "#F0F757"),
        ]
        
        guard (0...colors.count-1).contains(id) else { return .systemGray }
        
        return colors[id]
      }
      
      static func textField(color: UIColor,
                            traitCollection: UITraitCollection) -> UIColor {
        return color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.05 : 0.6)
      }
      
      static let tabBarLight = UIColor(red: 0.416, green: 0.400, blue: 0.639, alpha: 1.000)
      static let tabBarDark = UIColor.white
      static let main = UIColor(hexString: "#21A038")
      static let lightTheme = UIColor.white
      static let darkTheme = UIColor(hexString: "#1C1C1C")
      static let bannerDark = UIColor(hexString: "#494949")
      static let bannerLight = UIColor.systemBackground
      static let cellHeader = UIColor.lightGray
      static let spiralLight = UIColor.white.blended(withFraction: 0.04, of: UIColor.lightGray)
      static let spiralDark = UIColor(hexString: "#202020")
      static let surveyCollectionLight = UIColor.white//.blended(withFraction: 0.075, of: .lightGray)
      static let surveyCollectionDark = UIColor.secondarySystemBackground
      static let surveyCellLight = UIColor.white
      static let surveyCellDark = UIColor(hexString: "#1C1C1C")
      static let filterEnabled = UIColor(hexString: "#21A038")
      static let filterDisabledLight = UIColor.systemGray4
      static let filterDisabledDark = UIColor.systemGray4
      static let deselected = UIColor.systemGray4
      
      struct SubscriptionsController {
        static let subscribersButton = UIColor(red: 0.416, green: 0.400, blue: 0.639, alpha: 1.000)
      }
      
      struct Poll {
        static let choiceBackgroundLight = UIColor.systemBackground
        static let choiceBackgroundDark = UIColor.systemBackground
        static let choiceSelectedBackgroundLight = UIColor.systemBackground
        static let choiceSelectedBackgroundDark = UIColor.tertiarySystemBackground
      }
      
      struct Shimmer {
        static let backgroundLightForLight = UIColor.systemBackground.darker(0.025)
        static let backgroundDarkForLight = UIColor.systemBackground.darker(0.05)
        static let backgroundLightForDark = UIColor.tertiarySystemBackground.lighter(0.05)
        static let backgroundDarkForDark = UIColor.tertiarySystemBackground.lighter(0.15)
      }
      
      struct Banner {
          static let Error             = UIColor(hexString: "#DD1C1A")
          static let Warning           = UIColor(hexString: "#FE7F2D")//UIColor(hexString: "#FCCA46")
          static let Success           = UIColor(hexString: "#A1C181")
          static let Info              = UIColor(hexString: "#619B8A")
      }
      
      struct UpperButtons {
          static let VioletBlueCrayola = UIColor(hexString: "#7776BC")
          static let Avocado           = UIColor(hexString: "#5C8001")
          static let HoneyYellow       = UIColor(hexString: "#FBB02D")
          static let MaximumRed        = UIColor(hexString: "#DD1C1A")
      }
      
      struct Tags {

          static let RoyalPurple      = UIColor(hexString: "#6C4FB2")
          static let PacificBlue      = UIColor(hexString: "#47A8BD")
          static let LaserLemon       = UIColor(hexString: "#F0F757")
          static let CoyoteBrown      = UIColor(hexString: "#8F5D35")
          static let EnglishVermillion = UIColor(hexString: "#D14C57")
          static let BudGreen         = UIColor(hexString: "#72BC71")
          static let Corn             = UIColor(hexString: "#F2E86D")
          static let Saffron          = UIColor(hexString: "#F8C630")
          static let OrangeSoda       = UIColor(hexString: "#F2542D")
          static let DarkSlateBlue    = UIColor(hexString: "#4E4187")
          static let BleuDeFrance     = UIColor(hexString: "#3083DC")
          static let SandyBrown       = UIColor(hexString: "#FC9F5B")
          static let CafeNoir         = UIColor(hexString: "#4E3822")
          static let Cardinal         = UIColor(hexString: "#AD343E")
          static let GreenPantone     = UIColor(hexString: "#4DAA57")
          static let HoneyYellow       = UIColor(hexString: "#FBB02D")
          static let VioletBlueCrayola = UIColor(hexString: "#7776BC")
          static let Avocado           = UIColor(hexString: "#5C8001")
      }
      
      static func tags() -> [UIColor] {
          return [
              Tags.GreenPantone,
              Tags.EnglishVermillion,
              Tags.HoneyYellow,
              Tags.RoyalPurple,
              Tags.Saffron,
              Tags.CoyoteBrown,
              Tags.BudGreen,
              Tags.PacificBlue,
              Tags.LaserLemon,
              Tags.Corn,
              Tags.Saffron,
              Tags.OrangeSoda,
              Tags.DarkSlateBlue,
              Tags.BleuDeFrance,
              Tags.SandyBrown,
              Tags.CafeNoir,
              Tags.Cardinal,

              
              Tags.VioletBlueCrayola,
              Tags.Avocado
          ]
      }
      
      
    //  static let CadetBlue        = UIColor(hexString: "#699999")
    //  static let RussianViolet    = UIColor(hexString: "#1F2143")
    //  static let Hyperlink        = UIColor(hexString: "#CAE4F1")
    }





    //extension Color: RawRepresentable {
    //    typealias RawValue = UIColor
    //
    //    init?(rawValue: RawValue) {
    //        switch rawValue.toHexString().lowercased() {
    //        case "#e4572e".lowercased(): self = .Flame
    //        case "#AFC2D5".lowercased(): self = .LightSteelBlue
    //        case "#F3A712".lowercased(): self = .Marigold
    //        case "#A8C686".lowercased(): self = .Olivine
    //        case "#669BBC".lowercased(): self = .AirBlue
    //        default: return nil
    //        }
    //    }
    //
    //    var rawValue: RawValue {
    //        switch self {
    //        case .Flame:            return UIColor(hexString: "#e4572e")
    //        case .LightSteelBlue:   return UIColor(hexString: "#AFC2D5")
    //        case .Marigold:         return UIColor(hexString: "#F3A712")
    //        case .Olivine:          return UIColor(hexString: "#A8C686")
    //        case .AirBlue:          return UIColor(hexString: "#669BBC")
    //        }
    //    }
    //}


    
    static let padding: CGFloat = 8
  }
}

import Foundation
import UIKit
import MapKit
import Alamofire
import SwiftyJSON
//import Swinject
import CoreData
import UserNotifications

typealias Closure = (()->Void)

var localhost: Bool {
    //    let dict = ProcessInfo.processInfo.environment
    //    guard dict.keys.contains("localhost") else { return false }
#if LOCAL
    return true
#else
    return false
#endif
}
let tabAnimationDuration: TimeInterval = 0.3
var logger = TimeLogger(sinceOrigin: true)
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter
} ()

func replaceWithExisting<T>(_ source: [T], _ elements: [T]) -> [T] where T: Equatable {
  elements.reduce(into: [T]()) { result, instance in result.append(source.filter({ $0 == instance }).first ?? instance) }
}

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
var internetConnection: Enums.InternetConnection = .Available {
    didSet {
        if internetConnection != oldValue {
            NotificationCenter.default.post(name: Notifications.Network.InternetConnectionChange, object: nil)
        }
    }
}
var apiReachability: Enums.ApiReachabilityState = .Reachable {
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




