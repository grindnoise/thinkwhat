//
//  ProfileCreationModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import L10n_swift

class ProfileCreationModel {
  
  weak var modelOutput: ProfileCreationModelOutput?
}

extension ProfileCreationModel: ProfileCreationControllerInput {
  func checkUsernameAvailability(_ username: String) {
    Task { [weak self] in
      guard let self = self else { return }
      
//      await MainActor.run {
//        self.modelOutput?.usernameLoadingCallback()
//      }
      
      do {
        let response = try await API.shared.auth.checkUsernameAvailibilty(username)
        
        await MainActor.run {
          self.modelOutput?.usernameAvailabilityCallback(.success(response))
        }
      } catch {
        await MainActor.run {
          self.modelOutput?.usernameAvailabilityCallback(.failure(error))
        }
      }
    }
  }
  
  func updateUserprofile(parameters: [String: Any], image: UIImage? = nil) {
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
      }
    }
  }
  
  func fetchCity(userprofile: Userprofile, string: String) {
    Task { await GeoNamesWorker.search(userprofile: userprofile, string: string) }
  }
  
  func saveCity(_ city: City, completion: @escaping (Bool) -> ()) {
    Task {
      do {
        let data = try await GeoNamesWorker.getByGeonameId(city.geonameId)
        
        guard let dict = JSON(data).dictionaryObject else { return }
        
        try await API.shared.system.saveCity(dict)
        completion(true)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func setLocales() {
    Task {
      do {
        var parameters: [String: Any] = [
          "locales": [[L10n.shared.language: true]],
          "default_locale": L10n.shared.language
        ]
        
        try await API.shared.system.updateAppSettings(parameters)
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
}
