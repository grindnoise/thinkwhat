//
//  VKManager.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.07.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import VK_ios_sdk
import SwiftyJSON
import Alamofire

class VKManager {
    let shared = VKManager()
    
    private init() {}
    
    public class func getUserData(completionHandler: @escaping(JSON?, Error?) -> Void) {
        var json: JSON?
        var error: Error?
        VKRequest(method: "users.get", parameters: ["user_ids": VKSdk.accessToken()?.userId, "fields":"first_name, last_name, photo_200_orig, sex, bdate"])?.execute(resultBlock: { (response) in
            guard response != nil else { return }
            do {
                json =  JSON(parseJSON: response!.responseString)//JSON(arrayLiteral: (response!.responseString as! Dictionary <String, AnyObject>))
                print(json)
                completionHandler(json, error)
            } catch {
                print(error.localizedDescription)
                completionHandler(json, error)
            }
        }, errorBlock: { (error) in
            completionHandler(json, error!)
        })
    }
    
    private func initializeFileStoringProtocol() -> FileStoringProtocol {
        return appDelegate.container.resolve(FileStoringProtocol.self)!
    }
    
}

extension VKManager: UserDataPreparatory {
    static func prepareUserData(_ data: [String : Any]) -> [String : Any] {
        var userProfile = [String: Any]()
        
        for (key, value) in data {
            if key == "first_name" || key == "last_name" {
                userProfile["user."+key] = value
            } else if key == "id" {
                userProfile["vk_ID"] = value
            } else if key == "image" {
                userProfile[key] = value as! UIImage
            } else if key == "bdate" {
                userProfile["birth_date"] = "1986-12-07"//Date(dateString: value as! String)
            } else if key == "sex" {
                if value as! Int == 0 {
                    userProfile["gender"] = Gender.Unassigned.rawValue
                } else if value as! Int == 1 {
                    userProfile["gender"] = Gender.Female.rawValue
                } else if value as! Int == 2 {
                    userProfile["gender"] = Gender.Male.rawValue
                }
//                userProfile["gender"] = 1
            }
        }
        userProfile["email"] = VKSdk.accessToken()?.email
        print(userProfile)
        return userProfile
    }
}
