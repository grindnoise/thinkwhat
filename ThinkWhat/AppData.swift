//
//  UserData.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKLoginKit

class AppData {
    
    static let shared = AppData()
//    var user = User()
    var profile = UserprofileInternal()
    var system = System()
    lazy var userprofile: Userprofile = {
        
        return Userprofiles.shared.all.filter({ $0.id == profile.id && $0.name == "\(String(describing: profile.firstName)) \(String(describing: profile.lastName))" }).first ?? Userprofile(id: profile.id!,
                           name: "\(String(describing: profile.firstName)) \(String(describing: profile.lastName))",
                           age: profile.birthDate?.age ?? 0,
                           image: UIImage(contentsOfFile: profile.imagePath ?? ""),
                           gender: profile.gender ?? .Unassigned,
                           imageURL: profile.imageURL,
                           instagramURL: profile.instagramURL,
                           tiktokURL: profile.tiktokURL,
                           vkURL: profile.vkURL,
                           facebookURL: profile.facebookURL)
    }()
    
    struct UserprofileInternal: StorageProtocol {
        var id: Int? {
            didSet {
                if id != nil {
                    UserDefaults.standard.set(id!, forKey: "userProfileID")
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
                    UserDefaults.standard.set(birthDate!, forKey: "birthDate")
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
        var imageURL: URL? {
            didSet {
                if imageURL != nil {
                    UserDefaults.standard.set(imageURL!, forKey: "imageURL")
                }
            }
        }
        var instagramURL: URL? {
            didSet {
                if instagramURL != nil {
                    UserDefaults.standard.set(instagramURL!, forKey: "instagramURL")
                }
            }
        }
        var tiktokURL: URL? {
            didSet {
                if tiktokURL != nil {
                    UserDefaults.standard.set(tiktokURL!, forKey: "tiktokURL")
                }
            }
        }
        var vkURL: URL? {
            didSet {
                if vkURL != nil {
                    UserDefaults.standard.set(vkURL!, forKey: "vkURL")
                }
            }
        }
        var facebookURL: URL? {
            didSet {
                if facebookURL != nil {
                    UserDefaults.standard.set(facebookURL!, forKey: "facebookURL")
                }
            }
        }
        
        init() {
            getData()
        }
        
        mutating func getData() {
            id              = UserDefaults.standard.integer(forKey: "userProfileID")
            firstName       = UserDefaults.standard.string(forKey: "firstName")
            lastName        = UserDefaults.standard.string(forKey: "lastName")
            username        = UserDefaults.standard.string(forKey: "username")
            email           = UserDefaults.standard.string(forKey: "userMail")
            imagePath       = UserDefaults.standard.string(forKey: "userImagePath")
            birthDate       = UserDefaults.standard.object(forKey: "birthDate") as? Date
            gender          = Gender(rawValue: UserDefaults.standard.string(forKey: "userGender") ?? "") ?? .Unassigned
            isEdited        = UserDefaults.standard.bool(forKey: "userProfileEdited")
            isBanned        = UserDefaults.standard.bool(forKey: "userProfileBanned")
            isEmailVerified = UserDefaults.standard.bool(forKey: "userEmailVerified")
            imageURL        = UserDefaults.standard.url(forKey: "imageURL")
            instagramURL    = UserDefaults.standard.url(forKey: "instagramURL")
            tiktokURL       = UserDefaults.standard.url(forKey: "tiktokURL")
            vkURL           = UserDefaults.standard.url(forKey: "vkURL")
            facebookURL     = UserDefaults.standard.url(forKey: "facebookURL")
        }
        
        mutating func eraseData() {
            if imagePath != nil {
                storeManager.deleteFile(path: imagePath!)
                imagePath       = nil
            }
            birthDate       = nil
            gender          = nil
            id              = nil
            isEdited        = nil
            isBanned        = nil
            isEmailVerified = nil
            imageURL        = nil
            instagramURL    = nil
            tiktokURL       = nil
            vkURL           = nil
            facebookURL     = nil
            firstName               = nil
            lastName                = nil
            username                = nil
            id                      = nil
            email                   = nil
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "firstName")
            UserDefaults.standard.removeObject(forKey: "lastName")
            UserDefaults.standard.removeObject(forKey: "userMail")
            UserDefaults.standard.removeObject(forKey: "userProfileID")
            UserDefaults.standard.removeObject(forKey: "userGender")
            UserDefaults.standard.removeObject(forKey: "birthDate")
            UserDefaults.standard.removeObject(forKey: "userImagePath")
            UserDefaults.standard.removeObject(forKey: "userProfileEdited")
            UserDefaults.standard.removeObject(forKey: "userProfileBanned")
            UserDefaults.standard.removeObject(forKey: "userEmailVerified")
            UserDefaults.standard.removeObject(forKey: "imageURL")
            UserDefaults.standard.removeObject(forKey: "vkURL")
            UserDefaults.standard.removeObject(forKey: "instagramURL")
            UserDefaults.standard.removeObject(forKey: "tiktokURL")
            UserDefaults.standard.removeObject(forKey: "facebookURL")
            KeychainService.saveAccessToken(token: "")
            KeychainService.saveRefreshToken(token: "")
        }
    }
    
    struct System {
        var session: SessionType! {
            if AppData.shared.profile.id == nil || AppData.shared.profile.id == 0 {
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
////                        emailResponse = EmailResponse(confirmation_code: emailemail ResponseConfirmationCode!, expiresIn: emailResponseExpirationDate!)
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
        guard let data = json.dictionaryObject as? [String: Any] else {
            fatalError()
        }
        self.profile.email              = data["email"] as! String
        self.profile.firstName          = data["first_name"] as! String
        self.profile.lastName           = data["last_name"] as! String
//        self.profile.username           = data["username"] as! String
        self.profile.id                 = data["id"] as! Int
        self.profile.birthDate          = data["birth_date"] is NSNull ? nil : Date(dateString:data["birth_date"] as! String)
        self.profile.gender             = data["gender"] is NSNull ? Gender.Unassigned : Gender(rawValue: data["gender"] as! String)
        self.profile.isBanned           = data["is_banned"] is NSNull ? false : data["is_banned"] as! Bool
        self.profile.isEdited           = data["is_edited"] is NSNull ? false : data["is_edited"] as! Bool
        self.profile.isEmailVerified    = data["is_email_verified"] is NSNull ? false : data["is_email_verified"] as! Bool
        
        if imagePath != nil {
            self.profile.imagePath = imagePath!
        }
    }
    
    func eraseData() {
//        self.user.eraseData()
        self.profile.eraseData()
        self.system.eraseData()
        AccessToken.current = nil
    }
    
    private init() {}
}

