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
    
    static let shared = AppData()
    
    private init() {}
    
    public var locales: [String] = []
    
    class func loadData(_ json: JSON) throws {
        guard let apiVersion = json["api_version"].double,
              let fieldProperties = json["field_properties"] as? JSON,
              let pricelist = json["pricelist"] as? JSON,
              let topics = json["categories"] as? JSON,
              let claims = json["claim_categories"] as? JSON,
              let settings = json["client_settings"].dictionary,
              let locales = json["locales"].arrayObject as? [String]
        else { throw AppError.server }
        
        do {
            shared.locales = locales
            UserDefaults.App.minAPIVersion = apiVersion
            ModelProperties.shared.importJson(fieldProperties)
            PriceList.shared.importJson(pricelist)
            try Topics.shared.load(topics.rawData())
            try Claims.shared.load(claims.rawData())
            UserDefaults.App.notifyOnOwnCompleted = settings["NOTIFICATIONS_OWN_COMPLETED"]?.boolValue
            UserDefaults.App.notifyOnWatchlistCompleted = settings["NOTIFICATIONS_WATCHLIST_COMPLETED"]?.boolValue
            UserDefaults.App.notifyOnNewSubscription = settings["NOTIFICATIONS_NEW_SUBSCRIPTIONS"]?.boolValue
        } catch {
            throw AppError.server
        }
    }
}
