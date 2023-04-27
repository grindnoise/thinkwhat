//
//  SettingsModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingsModel {
  
  weak var modelOutput: SettingsModelOutput?
}

// MARK: - Controller Input
extension SettingsModel: SettingsControllerInput {
  func updateAppSettings(_ settings: [AppSettings : Any]) {
    Task {
      do {
        guard let setting = settings.keys.first else { return }
        
        var parameters: [String: Any] = [:]
        
        switch setting {
        case .languages(.App):
          guard let value = settings.values.first as? String else { return }
          
          parameters = [setting.identifier: value]
        case .languages(.Content):
          fatalError()
        default:
          var dict: [String: Any] = [:]
          settings.forEach { key, value in
            dict[key.identifier] = value
          }
          
          parameters = ["notifications": dict]
        }
        
        try await API.shared.system.updateAppSettings(parameters)
        
        settings.forEach { key, value in
          switch key {
          case .notifications(.Completed):
            UserDefaults.App.notifyOnOwnCompleted = value as? Bool
          case .notifications(.Watchlist):
            UserDefaults.App.notifyOnWatchlistCompleted = value as? Bool
          case .notifications(.Subscriptions):
            UserDefaults.App.notifyOnNewSubscription = value as? Bool
          case .languages(.App):
            guard let languageCode = value as? String else { return }
            
            Bundle.setLanguageAndPublish(languageCode, in: Bundle(for: Self.self))
            NotificationCenter.default.post(name: Notifications.System.AppLanguage, object: nil)
          case .languages(.Content):
            NotificationCenter.default.post(name: Notifications.System.ContentLanguage, object: nil)
          }
        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
      }
    }
  }
  
  func fetchCity(userprofile: Userprofile, string: String) {
    Task { await GeoNamesWorker.search(userprofile: userprofile, string: string) }
  }
  
  func saveCity(_ city: City,
                completion: @escaping (Bool) -> ()) {
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
//        await MainActor.run {
//          NotificationCenter.default.post(name: Notifications.Userprofiles.CurrentUserImageUpdated, object: nil)
//          //                                    NotificationCenter.default.post(name: Notifications.Userprofiles.ImageDownloaded, object: Userprofiles.shared.current)
//        }
      } catch {
#if DEBUG
        error.printLocalized(class: type(of: self), functionName: #function)
#endif
        //                await MainActor.run {
        //                    guard !image.isNil, let userpofile = Userprofiles.shared.current else {
        //                        modelOutput?.onError(error)
        //                        return
        //                    }
        //
        NotificationCenter.default.post(name: Notifications.System.ImageUploadFailure, object: Userprofiles.shared.current)
        //                }
      }
    }
  }
}

