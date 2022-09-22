//
//  AppData.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppData {
    
    class func loadData(_ json: JSON) throws {
        guard let apiVersion = json["api_version"].double,
              let fieldProperties = json["field_properties"] as? JSON,
              let pricelist = json["pricelist"] as? JSON,
              let topics = json["categories"] as? JSON,
              let claims = json["claim_categories"] as? JSON
        else { throw AppError.server }
        
        do {
            UserDefaults.App.minAPIVersion = apiVersion
            ModelProperties.shared.importJson(fieldProperties)
            PriceList.shared.importJson(pricelist)
            try Topics.shared.load(topics.rawData())
            try Claims.shared.load(claims.rawData())
        } catch {
            throw AppError.server
        }
    }
}
