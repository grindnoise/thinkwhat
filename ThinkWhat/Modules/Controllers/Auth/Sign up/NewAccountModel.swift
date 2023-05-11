//
//  NewAccountModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit

class NewAccountModel {
  
  weak var modelOutput: NewAccountModelOutput?
}

extension NewAccountModel: NewAccountControllerInput {
  
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
