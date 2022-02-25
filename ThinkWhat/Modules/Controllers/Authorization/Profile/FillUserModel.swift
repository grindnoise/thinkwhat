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
    
    func saveData() {
        
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
