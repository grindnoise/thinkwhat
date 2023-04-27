////
////  FBManager.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 25.06.2019.
////  Copyright © 2019 Pavel Bukharov. All rights reserved.
////
//
//import Foundation
//import FBSDKLoginKit
//import SwiftyJSON
//
//class FBWorker {
//    static let shared = LoginManager()
//    
//    class func wakeUp() {
//        ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
//    }
//    
//    class func authorizeAsync(viewController: UIViewController) async throws -> AccessToken {
//        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<AccessToken, Error>) in
//            if let token = AccessToken.current {
//                continuation.resume(returning: token)
//                return
//            }
//            shared.logIn(permissions: ["public_profile", "email"], from: viewController) { (result, error) in
//                if let token = AccessToken.current {
//                    continuation.resume(returning: token)
//                    return
//                } else if let error = error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//                continuation.resume(throwing: "Facebook error")
//                return
//            }
//        }
//    }
//    
//    class func accountInfoAsync() async throws -> JSON {
//        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<JSON, Error>) in
//            guard AccessToken.current != nil else {
//                continuation.resume(throwing: "Facebook token is nil")
//                return
//            }
//            GraphRequest(graphPath: "me", parameters: ["fields" : "name, first_name, last_name, email, picture.type(large)"]).start() { (connection, result, error) in
//                if let data = result {
//                    continuation.resume(returning: JSON(data))
//#if DEBUG
//                    print(JSON(data))
//#endif
//                    return
//                } else if let error = error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//            }
//        }
//    }
//    
//    class func prepareDjangoData(id: String, firstName: String, lastName: String, email: String, image: UIImage? = nil) -> [String: Any] {
//        var parameters = [String: Any]()
//        parameters["owner.\(DjangoVariables.User.firstName)"] = firstName
//        parameters["owner.\(DjangoVariables.User.lastName)"] = lastName
//        parameters["owner.\(DjangoVariables.User.email)"] = email
//        parameters[DjangoVariables.UserProfile.facebookID] = id
//        if let image = image {
//            parameters[DjangoVariables.UserProfile.image] = image
//        }
//        return parameters
//    }
//    
//    public class func logout() {
//        shared.logOut()
//    }
//}
