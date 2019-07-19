//
//  FBManager.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.06.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class FBManager {
    
    static let shared = LoginManager()
    
    private init() {}
//    private lazy var serverAPI:     APIManagerProtocol          = self.initializeServerAPI()
    
    public class func performLogin(viewController: UIViewController, completionHandler: @escaping(Bool) -> Void) {
        
        shared.logIn(permissions: ["public_profile", "email"],
                               from: viewController) { (result, error) in
                                if error == nil {
                                    completionHandler(true)
                                } else {
                                    print(error!.localizedDescription)
                                    completionHandler(false)
                                }
        }
    }
    
    public class func performLogout() {//(completionHandler: @escaping(Bool) -> Void) {
        shared.logOut()
    }
    
    public class func getUserData(completionHandler: @escaping(JSON?) -> Void) {//(completionHandler: @escaping() -> Void) {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields" : "name, first_name, last_name, email, picture.type(large)"]).start() {
                (connection, result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if result != nil {
                    if let json = JSON(result!) as? JSON {
                        completionHandler(json)
                    }
                }
            }
        }
    }
    
//    private func initializeServerAPI() -> APIManagerProtocol {
//        return appDelegate.container.resolve(APIManagerProtocol.self)!
//    }
}

extension FBManager: UserDataPreparatory {
    static func prepareUserData(_ dict: [String : Any]) -> [String : Any] {
        print(dict)
        var userProfile = [String: Any]()
        var user = [String: Any]()
        for (key, value) in dict {
            if key == "first_name" || key == "last_name" {
                userProfile[key] = value
            } else if key == "id" {
                userProfile["facebook_ID"] = value
            } else if key == "image" {
                userProfile[key] = value
            }
        }
        userProfile["user"] = user
        return userProfile
    }
}

