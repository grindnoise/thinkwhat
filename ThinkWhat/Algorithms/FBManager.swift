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
    
    static let shared = FBSDKLoginManager()
    private lazy var serverAPI:     APIServerProtocol          = self.initializeServerAPI()
    
    public class func performLogin(viewController: UIViewController, completionHandler: @escaping(Bool) -> Void) {
        
        shared.logIn(withReadPermissions: ["public_profile", "email"],
                               from: viewController) { (result, error) in
                                if error == nil {
                                    completionHandler(true)
//                                    getUserData()
                                } else {
                                    print(error!.localizedDescription)
                                    completionHandler(false)
                                }
        }
    }
    
    public class func performLogout() {//(completionHandler: @escaping(Bool) -> Void) {
        
        shared.logOut()
        
    }
    
    public class func getUserData() {//(completionHandler: @escaping() -> Void) {
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "name, first_name, last_name, email, picture.type(normal)"]).start() {
                (connection, result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if result != nil {
                    if let json = JSON(result!) as? JSON {
                        self.serverAPI.
                        
                        appData.importFacebookData(json)
                        
                    }
                }
            }
        }
    }
    
    private func initializeServerAPI() -> APIServerProtocol {
        return appDelegate.container.resolve(APIServerProtocol.self)!
    }
}

