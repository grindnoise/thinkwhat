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
    
    public class func getUserData(completion: @escaping(Result<JSON, Error>) -> ()) {
        guard let token = VKSdk.accessToken() else { completion(.failure("VK token is nil")); return }
        VKRequest(method: "users.get", parameters: ["user_ids": token.userId, "fields":"first_name, last_name, photo_200_orig, sex, bdate"]).execute { _response in
            guard let response = _response else { completion(.failure("Error retrieving VK ")); return }
            completion(.success(JSON(parseJSON: response.responseString)))
        } errorBlock: { _error in
            guard let error = _error else { completion(.failure("Error retrieving VK ")); return }
            completion(.failure(error))
        }
    }
    
    public class func performLogout() {
        VKSdk.forceLogout()
    }
//}
//
//extension VKManager: UserDataPreparatory {
    static func prepareUserData(_ data: [String : Any]) -> [String : Any] {
        var userProfile = [String: Any]()
        let nestedDict = data.filter{ $0.key == "image" }.isEmpty
        var owner: [String: Any] = [:]
        let ownerPrefix = nestedDict ? "" : "owner."
        
        for (key, value) in data {
            if key == "first_name" || key == "last_name" {
                if nestedDict {
                    owner[ownerPrefix + key] = value
                } else {
                    userProfile[ownerPrefix + key] = value
                }
            } else if key == "id" {
                userProfile["vk_ID"] = value
            } else if key == "image" {
                userProfile[key] = value as! UIImage
            } else if key == "bdate" {
                userProfile["birth_date"] = value as! String//Date(dateString: value as! String)//dateFormatter.string(for: Date(dateString: value as! String))
            } else if key == "sex" {
                if value as! Int == 0 {
                    userProfile["gender"] = Gender.Unassigned.rawValue
                } else if value as! Int == 1 {
                    userProfile["gender"] = Gender.Female.rawValue
                } else if value as! Int == 2 {
                    userProfile["gender"] = Gender.Male.rawValue
                }
            }
        }
        
        if nestedDict {
            owner[ownerPrefix + "email"] = VKSdk.accessToken()?.email
            userProfile["owner"] = owner
        } else {
            userProfile[ownerPrefix + "email"] = VKSdk.accessToken()?.email
        }
        
        return userProfile
    }
}
