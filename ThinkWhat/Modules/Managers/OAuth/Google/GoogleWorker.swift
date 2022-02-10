//
//  GoogleWorker.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 09.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import SwiftyJSON
import GoogleSignIn

class GoogleWorker {
    static let signInConfig = GIDConfiguration.init(clientID: Bundle.main.object(forInfoDictionaryKey: "GoogleAppID") as! String)
    
    class func wakeUp() {
        GIDSignIn.sharedInstance.restorePreviousSignIn()
    }
    
    class func authorizeAsync(viewController: UIViewController) async throws -> String  {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<String, Error>) in
        if let token = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken {
            continuation.resume(returning: token)
            return
        }
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: viewController) { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = user else {
                    continuation.resume(throwing: "GoogleSignIn error")
                    return
                }
                user.authentication.do { authentication, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let authentication = authentication else {
                        continuation.resume(throwing: "GoogleSignIn authentication error")
                        return
                    }
                    continuation.resume(returning: authentication.accessToken)
                    return
                }
            }
        }
    }
    
    class func accountInfoAsync(viewController: UIViewController) async throws -> [String: Any] {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<[String: Any], Error>) in
            guard let user = GIDSignIn.sharedInstance.currentUser else {
                continuation.resume(throwing: "Google user is nil")
                return
            }
            var parameters = [String: Any]()
            parameters["owner.\(DjangoVariables.User.firstName)"] = user.profile?.givenName
            parameters["owner.\(DjangoVariables.User.lastName)"] = user.profile?.familyName
            parameters["owner.\(DjangoVariables.User.email)"] = user.profile?.email
            parameters[DjangoVariables.UserProfile.image] = user.profile?.imageURL(withDimension: 500)
            continuation.resume(returning: parameters)
            return
        }
    }
    
    static func prepareDjangoData(id: String, firstName: String, lastName: String, email: String, image: UIImage? = nil) -> [String: Any] {
        var parameters = [String: Any]()
        parameters["owner.\(DjangoVariables.User.firstName)"] = firstName
        parameters["owner.\(DjangoVariables.User.lastName)"] = lastName
        parameters["owner.\(DjangoVariables.User.email)"] = email
        parameters[DjangoVariables.UserProfile.facebookID] = id
        if let image = image {
            parameters[DjangoVariables.UserProfile.image] = image
        }
        return parameters
    }
    
    //    static func _prepareDjangoData(_ data: [String : Any]) -> [String : Any] {
    //        var userProfile = [String: Any]()
    //        for (key, value) in data {
    //            if key == "first_name" || key == "last_name" || key == "email" {
    //                userProfile["owner."+key] = value
    //            } else if key == "id" {
    //                userProfile["facebook_ID"] = value
    //            } else if key == "image" {
    //                userProfile[key] = value
    //            }
    //        }
    //        return userProfile
    //    }
    
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
        GIDSignIn.sharedInstance.signOut()
    }
    
//    public class func getUserData(completionHandler: @escaping(JSON?) -> Void) {
//        if AccessToken.current != nil {
//            GraphRequest(graphPath: "me", parameters: ["fields" : "name, first_name, last_name, email, picture.type(large)"]).start() {
//                (connection, result, error) in
//                if let conn = connection {
//                    print(conn)
//                }
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//                if result != nil {
//                    if let json = JSON(result!) as? JSON {
//                        completionHandler(json)
//                    }
//                }
//            }
//        }
//    }
    
//    private func initializeServerAPI() -> APIManagerProtocol {
//        return appDelegate.container.resolve(APIManagerProtocol.self)!
//    }
}
