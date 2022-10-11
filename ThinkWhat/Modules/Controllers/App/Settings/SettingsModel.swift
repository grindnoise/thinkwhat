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
                
                try await API.shared.profiles.updateAppSettings(parameters)
                
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
    
    
    func fetchCity(_ name: String) {
        Task {
            var cities = [City]()
            do {
                let value = try await GeoNamesWorker.searchByName(startsWith: name)
                let json = try JSON(data: value, options: .mutableContainers)
                
                guard let array = json["geonames"].array,
                      !array.isEmpty
                else {
//                    await MainActor.run {
                        NotificationCenter.default.post(name: Notifications.Cities.FetchResult, object: cities)
//                    }
                    return
                }
                
                guard let data = try json["geonames"].rawData() as? Data else {
//                    await MainActor.run {
                        NotificationCenter.default.post(name: Notifications.Cities.FetchError, object: nil)
//                    }
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                let instances = try decoder.decode([City].self, from: data)
                instances.forEach { instance in
                    cities.append(Cities.shared.all.filter({ $0 == instance }).first ?? instance)
                }
//                await MainActor.run {
                    NotificationCenter.default.post(name: Notifications.Cities.FetchResult, object: cities)
//                }
            } catch {
//                await MainActor.run {
                    NotificationCenter.default.post(name: Notifications.Cities.FetchError, object: nil)
//                }
            }
        }
    }
    
    func saveCity(_ city: City) {
        Task {
            do {
                let data = try await GeoNamesWorker.getByGeonameId(city.geonameID)
                
                guard let dict = JSON(data).dictionaryObject else { return }
                
                city.id = try await API.shared.saveCity(dict)
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                           DateFormatter.dateTimeFormatter,
                                                           DateFormatter.dateFormatter ]
                Userprofiles.shared.current = try decoder.decode(Userprofile.self, from: data)
                Userprofiles.shared.current?.image = image
                await MainActor.run {
                    NotificationCenter.default.post(name: Notifications.Userprofiles.CurrentUserImageUpdated, object: nil)
                    //                                    NotificationCenter.default.post(name: Notifications.Userprofiles.ImageDownloaded, object: Userprofiles.shared.current)
                }
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
