//
//  FillUserModel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class FillUserModel {
    
    weak var modelOutput: FillUserModelOutput?

}

// MARK: - Controller Input
extension FillUserModel: FillUserControllerInput {
    func saveCity(_ city: City) {
        Task {
            do {
                let data = try await GeoNamesWorker.getByGeonameId(city.geonameID)
                guard let dict = JSON(data).dictionaryObject else { return }
#if DEBUG
                print(dict)
#endif
                city.id = try await API.shared.saveCity(dict)
            } catch {
#if DEBUG
                print(error)
#endif
            }
        }
    }
    
    func updateUserprofile(image: UIImage?, firstName: String, lastName: String, gender: Gender, birthDate: String?, city: City?, vkID: String?, vkURL: String?, facebookID: String?, facebookURL: String?) {
        Task {
            do {
                let parameters = API.prepareUserData(firstName: firstName,
                                                     lastName: lastName,
                                                     email: nil,
                                                     gender: gender,
                                                     birthDate: birthDate,
                                                     city: city,
                                                     image: image,
                                                     vkID: vkID,
                                                     vkURL: vkURL,
                                                     facebookID: facebookID,
                                                     facebookURL: facebookURL)
#if DEBUG
                    print(parameters)
#endif
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
                modelOutput?.onUpdateProfileComplete(.success(true))
            } catch {
#if DEBUG
                print(error)
#endif
                modelOutput?.onUpdateProfileComplete(.failure(error))
            }
        }
    }
    
    func fetchCity(_ name: String) async {
        var cities = [City]()
        do {
            let value = try await GeoNamesWorker.searchByName(startsWith: name)
            let json = try JSON(data: value, options: .mutableContainers)
            guard let array = json["geonames"].array, !array.isEmpty else { modelOutput?.onFetchCityComplete([]); return }
            guard let data = try json["geonames"].rawData() as? Data else { modelOutput?.onFetchCityError("Geonames.org json parse error"); return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategyFormatters = [ DateFormatter.ddMMyyyy,
                                                       DateFormatter.dateTimeFormatter,
                                                       DateFormatter.dateFormatter ]
            let instances = try decoder.decode([City].self, from: data)
            instances.forEach { instance in
                cities.append(Cities.shared.all.filter({ $0.hashValue == instance.hashValue }).first ?? instance)
            }
            modelOutput?.onFetchCityComplete(cities)
        } catch {
            modelOutput?.onFetchCityError(error)
        }
    }
    
    func validateHyperlink(socialMedia: SocialMedia, hyperlink: String) throws {
        switch socialMedia {
        case .VK:
            guard hyperlink.isVKLink else { throw "" }
        case .Facebook:
            guard hyperlink.isFacebookLink else { throw "" }
        case .TikTok:
            guard hyperlink.isTikTokLink else { throw "" }
        case .Instagram:
            guard hyperlink.isInstagramLink else { throw "" }
        }
    }
}
