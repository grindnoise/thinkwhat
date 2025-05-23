//
//  VKWorker.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyVK
import SwiftyJSON
import Alamofire

final class VKWorker {
    
    static var vkDelegateReference : SwiftyVKDelegate?
    
    class func wakeUp() {
        vkDelegateReference = VKDelegate()
    }
    
    class func authorize(completion: @escaping(Result<String,Error>)->()) {
      guard let accessToken = VK.sessions.default.accessToken?.get() else {
        VK.sessions.default.logIn(
            onSuccess: { info in
              guard let token = VK.sessions.default.accessToken?.get() else { completion(.failure("Failed to recive VK access token")); return }
                completion(.success(token))
            },
            onError: { error in
                completion(.failure(error))
            }
        )
        return
      }
      
      completion(.success(accessToken))
    }
    
    @MainActor
    class func authorizeAsync() async throws -> Token {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Token, Error>) in
            if let token = VK.sessions.default.accessToken {
                continuation.resume(returning: token)
                return
            }
            VK.sessions.default.logIn(
                onSuccess: { info in
                    guard let token = VK.sessions.default.accessToken else {
                        continuation.resume(throwing: "VK access token error")
                        return
                    }
                    continuation.resume(returning: token)
                    return
                },
                onError: { error in
                    continuation.resume(throwing: error)
                    return
                }
            )
        }
    }
    
    class func logout() {
        VK.sessions.default.logOut()
        VK.release()
        print("SwiftyVK: LogOut")
    }
    
    class func captcha() {
        VK.API.Custom.method(name: "captcha.force")
            .onSuccess { print("SwiftyVK: captcha.force successed with \n \(JSON($0))") }
            .onError { print("SwiftyVK: captcha.force failed with \n \($0)") }
            .send()
    }
    
//    class func validation() {
//        VK.API.Custom.method(name: "account.testValidation")
//            .onSuccess { print("SwiftyVK: account.testValidation successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: account.testValidation failed with \n \($0)") }
//            .send()
//    }
//
//    class func usersGet() {
//        VK.API.Users.get(.empty)
//            .configure(with: Config.init(httpMethod: .POST))
//            .onSuccess { print("SwiftyVK: users.get successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: friends.get fail \n \($0)") }
//            .send()
//    }
////
//    class func friendsGet() {
////        VK.API.Friends.get(.empty)
////            .onSuccess { print("SwiftyVK: friends.get successed with \n \(JSON($0))") }
////            .onError { print("SwiftyVK: friends.get failed with \n \($0)") }
////            .send()
//    }
    
    class func accountInfo(completion: @escaping(Result<JSON,Error>)->()) {
        guard let id = VK.sessions.default.accessToken?.info["user_id"] else { fatalError() }
        guard let email = VK.sessions.default.accessToken?.info["email"] else { fatalError() }
        VK.API.Custom.method(name: "users.get",
                             parameters: [
                              Parameter.userIDs.rawValue: id,
                              Parameter.fields.rawValue: "\(Parameter.firstName.rawValue), \(Parameter.lastName.rawValue), \(Parameter.sex.rawValue), \(Parameter.bdate.rawValue), \(Parameter.photo_400.rawValue), \(Parameter.domain.rawValue)"])
            .onSuccess {
                var json = JSON($0)
                json.appendIfArray(json: JSON(["user_id": id, "email": email]))
                completion(.success(json))
            }
            .onError {
                    completion(.failure($0))
            }
            .send()
    }
    
    class func accountInfoAsync() async throws -> JSON {
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<JSON, Error>) in
            guard let id = VK.sessions.default.accessToken?.info["user_id"] else {
                continuation.resume(throwing: "VK user_id is nil")
                return
            }
            guard let email = VK.sessions.default.accessToken?.info["email"] else {
                continuation.resume(throwing: "VK email is nil")
                return
            }
            VK.API.Custom.method(name: "users.get", parameters: [Parameter.userIDs.rawValue: id, Parameter.fields.rawValue: "\(Parameter.firstName.rawValue), \(Parameter.lastName.rawValue), \(Parameter.sex.rawValue), \(Parameter.bdate.rawValue), \(Parameter.photo_400.rawValue), \(Parameter.domain.rawValue)"])
                .onSuccess {
                    var json = JSON($0)
                    json.appendIfArray(json: JSON(["user_id": id, "email": email]))
                    continuation.resume(returning: json)
                    return
                }
                .onError {
                    continuation.resume(throwing: $0 )
                    return
                }
                .send()
        }
    }
  
  class func prepareDjangoData(id: String, firstName: String, lastName: String, email: String, gender: Int, domain: String, birthDate: String?, image: UIImage? = nil) -> [String: Any] {
    
    var parameters = [String: Any]()
    parameters["owner.\(DjangoVariables.User.firstName)"] = firstName
    parameters["owner.\(DjangoVariables.User.lastName)"] = lastName
    parameters["owner.\(DjangoVariables.User.email)"] = email
    parameters[DjangoVariables.UserProfile.gender] = gender == 1 ? Enums.User.Gender.Female.rawValue : Enums.User.Gender.Male.rawValue
    parameters[DjangoVariables.UserProfile.birthDate] = birthDate
    parameters[DjangoVariables.UserProfile.vkID] = id
    parameters[DjangoVariables.UserProfile.vkURL] = "https://vk.com/\(domain)"
    if let image = image {
      parameters[DjangoVariables.UserProfile.image] = image
    }
    return parameters
  }
  
  class func uploadPhoto() {
    //        guard
    //            let pathToImage = Bundle.main.path(forResource: "testImage", ofType: "png"),
    //            let data = try? Data(contentsOf: URL(fileURLWithPath: pathToImage))
    //            else {
    //                print("Can not find testImage.png")
    //                return
//        }
//
//        let media = Media.image(data: data, type: .png)
//
//        VK.API.Upload.Photo.toWall(media, to: .user(id: "4680178"))
//            .onSuccess { print("SwiftyVK: upload successed with \n \(JSON($0))") }
//            .onError { print("SwiftyVK: upload failed with \n \($0)")}
//            .onProgress { print($0) }
//            .send()
    }
    
    class func share() {
//        guard #available(iOS 8.0, macOS 10.11, *) else {
//            print("Sharing available only on iOS 8.0+ and macOS 10.11+")
//            return
//        }
//
//        guard
//            let pathToImage = Bundle.main.path(forResource: "testImage", ofType: "png"),
//            let data = try? Data(contentsOf: URL(fileURLWithPath: pathToImage)),
//            let link = URL(string: "https://en.wikipedia.org/wiki/Hyperspace")
//            else {
//                print("Can not find testImage.png")
//                return
//        }
//
//        VK.sessions.default.share(
//            ShareContext(
//                text: "This post made with #SwiftyVK 🖖🏽",
//                images: [
//                    ShareImage(data: data, type: .jpg),
//                    ShareImage(data: data, type: .jpg),
//                    ShareImage(data: data, type: .jpg),
//                ],
//                link: ShareLink(
//                    title: "Follow the white rabbit",
//                    url: link
//                )
//            ),
//            onSuccess: { print("SwiftyVK: successfully shared with \n \(JSON($0))") },
//            onError: { print("SwiftyVK: share failed with \n \($0)") }
//        )
    }
}
