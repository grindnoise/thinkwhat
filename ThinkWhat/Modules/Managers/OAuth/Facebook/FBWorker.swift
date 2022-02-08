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

class FBWorker {
    static let shared = LoginManager()
    
//    private init() {}
    
    class func authorizeAsync(viewController: UIViewController) async throws -> AccessToken {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<AccessToken, Error>) in
            if let token = AccessToken.current {
                continuation.resume(returning: token)
                return
            }
            shared.logIn(permissions: ["public_profile", "email"], from: viewController) { (result, error) in
                if let token = AccessToken.current {
                    continuation.resume(returning: token)
                    return
                } else if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                fatalError("shouldn't get here")
            }
        }
    }
    
    class func accountInfoAsync() async throws -> JSON {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<JSON, Error>) in
            guard AccessToken.current != nil else {
                continuation.resume(throwing: "Facebook token is nil")
                return
            }
            GraphRequest(graphPath: "me", parameters: ["fields" : "name, first_name, last_name, email, picture.type(large)"]).start() { (connection, result, error) in
                if let data = result {
                    continuation.resume(returning: JSON(data))
                    print(JSON(data))
                    return
                } else if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
//    public class func performLogin(viewController: UIViewController, completionHandler: @escaping(Bool) -> Void) {
//
//        shared.logIn(permissions: ["public_profile", "email"],
//                               from: viewController) { (result, error) in
//                                if error == nil {
//                                    completionHandler(true)
//                                } else {
//                                    print(error!.localizedDescription)
//                                    completionHandler(false)
//                                }
//        }
//    }
    
    public class func logout() {//(completionHandler: @escaping(Bool) -> Void) {
        shared.logOut()
    }
    
    public class func getUserData(completionHandler: @escaping(JSON?) -> Void) {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields" : "name, first_name, last_name, email, picture.type(large)"]).start() {
                (connection, result, error) in
                if let conn = connection {
                    print(conn)
                }
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

extension FBWorker: UserDataPreparatory {
    static func prepareUserData(_ data: [String : Any]) -> [String : Any] {
        var userProfile = [String: Any]()
        for (key, value) in data {
            if key == "first_name" || key == "last_name" || key == "email" {
                userProfile["owner."+key] = value
            } else if key == "id" {
                userProfile["facebook_ID"] = value
            } else if key == "image" {
                userProfile[key] = value
            }
        }
        print(userProfile)
        return userProfile
    }
    
}


func convertImageToBase64(image: UIImage) -> String {
    let imageData = image.jpegData(compressionQuality: 1)!
    return imageData.base64EncodedString(options:   Data.Base64EncodingOptions.lineLength64Characters)
}
