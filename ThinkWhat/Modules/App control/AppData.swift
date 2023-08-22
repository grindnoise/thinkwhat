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
  
  static var isEmailVerified = false
  static var isSocialAuth = false
  
  static var emailVerificationCode: Int?
  
  static var accessToken: String? { KeychainService.loadAccessToken() as? String }
  
  static let shared = AppData()
  
  private init() {}
  
  private var isDataLoaded = false
  
  public var locales: [String] = []
  ///Country code
  public var countryByIP: String = ""
  
  class func loadData(_ json: JSON) throws {
    guard !shared.isDataLoaded else { return }
    
    guard let supportedAPI = json["api_version"].double,
          let fieldProperties = json["field_properties"] as? JSON,
          let pricelist = json["pricelist"] as? JSON,
          let topics = json["categories"] as? JSON,
          let claims = json["claim_categories"] as? JSON,
          let settings = json["client_settings"].dictionary,
          let locales = json["locales"].arrayObject as? [String],
          let value = Bundle.main.object(forInfoDictionaryKey: "ApiVersion") as? String,
          let currentAPI = Double(value) as? Double,
          let isEmailVerified = json["is_email_verified"].bool,
          let emailVerificationString = json["email_verification_code"].rawString(),
          let isSocialAuth = json["is_social_auth"].bool
    else { throw AppError.server }
    
    if let emailVerificationCode = Int(emailVerificationString) {
      AppData.emailVerificationCode = emailVerificationCode
    }
    AppData.isEmailVerified = isEmailVerified
    AppData.isSocialAuth = isSocialAuth
    shared.isDataLoaded = true
    //Check current API supported version and compare with backend
    if currentAPI.rounded(toPlaces: 1) < supportedAPI.rounded(toPlaces: 1) {
      throw AppError.apiNotSupported
    }
    
    do {
      shared.locales = locales
      UserDefaults.App.minAPIVersion = supportedAPI
      
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
