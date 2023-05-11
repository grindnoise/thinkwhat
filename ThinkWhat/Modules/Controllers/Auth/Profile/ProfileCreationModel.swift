//
//  ProfileCreationModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit

class ProfileCreationModel {
  
  weak var modelOutput: ProfileCreationModelOutput?
}

extension ProfileCreationModel: ProfileCreationControllerInput {
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
    
  }
  
  func saveCity(_: City, completion: @escaping (Bool) -> ()) {
    
  }
  
  
}
