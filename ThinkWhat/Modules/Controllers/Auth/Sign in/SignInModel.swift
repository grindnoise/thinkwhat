//
//  SignInModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SignInModel {
  
  weak var modelOutput: SignInModelOutput?
}

extension SignInModel: SignInControllerInput {
  /**
   Performs sign in via providers token.
   - parameter provider: Social media provider.
   - parameter instance: For Google instance is `GIDGoogleUser`, for VK instance is.
   - returns: Void. Completion is handled via `modelOutput.providerSignInCallback()` protocol func
   */
  func providerSignIn(provider: AuthProvider, accessToken: String) {
    @Sendable
    func providerLogout() {
      switch provider {
      case .VK:
        VKWorker.logout()
//      case .Facebook:
//        FBWorker.logout()
      case .Google:
        GoogleWorker.logout()
      default:
#if DEBUG
        fatalError("Not implemented")
#endif
      }
    }
    
    @Sendable
    func getProviderData() async throws -> [String: Any] {
      var userImage: UIImage?
      
      func prepareData(json: JSON) async throws -> [String: Any] {
        switch provider {
        case .VK:
          guard let id = json[1]["user_id"].string,
                let email = json[1]["email"].string,
                let firstName = json[0]["first_name"].string,
                let lastName = json[0]["last_name"].string,
                let gender = json[0]["sex"].int,
                let domain = json[0]["domain"].string else {
            throw "VK json serialization failure"
          }
          let birthDate = json[0]["bdate"].string
          if let pictureURL = json[0]["photo_400_orig"].string, let url = URL(string: pictureURL) {
            do {
              userImage = try await API.shared.system.downloadImageAsync(from: url)
              return VKWorker.prepareDjangoData(id: id,
                                                firstName: firstName,
                                                lastName: lastName,
                                                email: email,
                                                gender: gender,
                                                domain: domain,
                                                birthDate: birthDate,
                                                image: userImage)
            } catch {
              return VKWorker.prepareDjangoData(id: id,
                                                firstName: firstName,
                                                lastName: lastName,
                                                email: email,
                                                gender: gender,
                                                domain: domain,
                                                birthDate: birthDate)
            }
          } else {
            return VKWorker.prepareDjangoData(id: id,
                                              firstName: firstName,
                                              lastName: lastName,
                                              email: email,
                                              gender: gender,
                                              domain: domain,
                                              birthDate: birthDate)
          }
//        case .Facebook:
//          guard let id = json["id"].string,
//                let email = json["email"].string,
//                let firstName = json["first_name"].string,
//                let lastName = json["last_name"].string else {
//            throw "VK json serialization failure"
//          }
//          if let pictureURL = json["picture"]["data"]["url"].string, let url = URL(string: pictureURL) {
//            do {
//              userImage = try await API.shared.system.downloadImageAsync(from: url)
//              return FBWorker.prepareDjangoData(id: id,
//                                                firstName: firstName,
//                                                lastName: lastName,
//                                                email: email,
//                                                image: userImage)
//            } catch {
//              return FBWorker.prepareDjangoData(id: id,
//                                                firstName: firstName,
//                                                lastName: lastName,
//                                                email: email)
//            }
//          } else {
//            return FBWorker.prepareDjangoData(id: id,
//                                              firstName: firstName,
//                                              lastName: lastName,
//                                              email: email)
//          }
        default:
          throw "Not implemented"
        }
      }
      
      do {
        switch provider {
        case .VK:
          let json = try await VKWorker.accountInfoAsync()
          return try await prepareData(json: json)
//        case .Facebook:
//          let json = try await FBWorker.accountInfoAsync()
//          return try await prepareData(json: json)
        case .Google:
          var dict = try await GoogleWorker.accountInfoAsync()
          if let url = dict[DjangoVariables.UserProfile.image] as? URL {
            do {
              userImage = try await API.shared.system.downloadImageAsync(from: url)
              dict[DjangoVariables.UserProfile.image] = userImage
              return dict
            } catch {
              return dict
            }
          } else {
            return dict
          }
        default:
          throw "Not implemented"
        }
      } catch let error {
        throw error
      }
    }
    
    Task {
      do {
        ///API authorization
        try await API.shared.auth.loginViaProviderAsync(provider: provider, token: accessToken)
        
        ///Get profile from API
        let json = try JSON(data: try await API.shared.profiles.current(),
                            options: .mutableContainers)
        
        guard let appData = json["app_data"] as? JSON,
              let current = json["current_user"] as? JSON
        else { throw AppError.server }
        
        ///Load necessary data before creating user
        try AppData.loadData(appData)
        
        var userprofile = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self,
                                                                                          from: current.rawData())
        Userprofiles.shared.current = userprofile
        ///Detext if profile was edited by user
        guard let wasEdited = userprofile.wasEdited else { fatalError() }
        
        ///If profile wasn't prieviously edited by user, then update it with provider's data
        if !wasEdited {
          let providerData = try await getProviderData()
          userprofile = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self,
                                                                                        from:  try await API.shared.profiles.updateUserprofileAsync(data: providerData) { _ in })
          Userprofiles.shared.current = userprofile
        }
        
//        UserDefaults.Profile.id = userprofile.id
        try await Userprofiles.shared.current?.downloadImageAsync()
        providerLogout()
        
        await MainActor.run {
          modelOutput?.providerSignInCallback(result: .success(true))
        }
      } catch let error {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        providerLogout()
        await MainActor.run {
          modelOutput?.providerSignInCallback(result: .failure(error))
        }
      }
    }
  }
  
  func mailSignIn(username: String, password: String) {
    Task {
      do {
        try await API.shared.auth.loginAsync(username: username, password: password)
        
        ///Get profile from API
        let json = try JSON(data: try await API.shared.profiles.current(),
                            options: .mutableContainers)
        
        guard let appData = json["app_data"] as? JSON,
              let current = json["current_user"] as? JSON
        else { throw AppError.server }
        
        ///Load necessary data before creating user
        try AppData.loadData(appData)
        
        Userprofiles.shared.current = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self,
                                                                                          from: current.rawData())
        await MainActor.run {
          modelOutput?.mailSignInCallback(.success(true))
        }
      } catch {
        UserDefaults.clear()
        await MainActor.run {
#if DEBUG
          error.printLocalized(class: type(of: self), functionName: #function)
#endif
          modelOutput?.mailSignInCallback(.failure(error))
        }
      }
    }
  }
  
  func sendVerificationCode(_ completion: @escaping (Result<[String : Any], Error>) -> ()) {
    Task {
      do {
        let data = try await API.shared.auth.sendEmailVerificationCode()
        await MainActor.run {
          completion(.success(JSON(data).dictionaryObject!))
        }
      } catch {
        await MainActor.run {
          completion(.failure(error))
        }
      }
    }
  }
  
  func updateUserprofile(parameters: [String: Any], image: UIImage? = nil) throws {
    Task {
      do {
        let data = try await API.shared.profiles.updateUserprofileAsync(data: parameters, uploadProgress: { progress in
#if DEBUG
          print(progress)
#endif
        })
        let instance = try JSONDecoder.withDateTimeDecodingStrategyFormatters().decode(Userprofile.self, from: data)
        Userprofiles.shared.current?.update(from: instance)
        Userprofiles.shared.current?.image = image
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        NotificationCenter.default.post(name: Notifications.System.ImageUploadFailure, object: Userprofiles.shared.current)
        throw error
      }
    }
  }
}
