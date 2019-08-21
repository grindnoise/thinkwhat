//
//  EmailResponse.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.08.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class EmailResponse {
    
    static let shared = EmailResponse()
    
    private init() {
        if let kEmailResponseExpirationDate = UserDefaults.standard.object(forKey: "emailResponseExpirationDate") as? Date, let kEmailResponseConfirmationCode = UserDefaults.standard.object(forKey: "emailResponseConfirmationCode") as? Int {
            if Date() < kEmailResponseExpirationDate {
                self.confirmation_code  = kEmailResponseConfirmationCode
                self.expiresIn          = kEmailResponseExpirationDate
                print(self.confirmation_code)
                print(self.expiresIn)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(EmailResponse.eraseData), name: kNotificationEmailResponseExpired, object: nil)
    }
    fileprivate var confirmation_code:  Int?
    fileprivate var expiresIn:          Date?
    public var isEmpty:                 Bool {
        return confirmation_code == nil || expiresIn == nil
    }
    public var isActive:                Bool {
        if expiresIn != nil {
            return expiresIn! > Date()
        }
        return false
    }
    
    public func getExpireDate() -> Date? {
        return expiresIn
    }
    
    public func getConfirmationCode() -> Int? {
        return confirmation_code
    }
    
    public func importJson(_ json: JSON) {
        var dict = json.dictionaryObject as! [String: Any]
        confirmation_code = dict["confirmation_code"] as! Int
        expiresIn         = Date(dateTimeString:dict["expires_in"] as! String)
        storeData()
    }
    
    fileprivate func storeData() {
        UserDefaults.standard.set(confirmation_code, forKey: "emailResponseConfirmationCode")
        UserDefaults.standard.set(expiresIn, forKey: "emailResponseExpirationDate")
    }
    
    @objc fileprivate  func eraseData() {
        confirmation_code = nil
        expiresIn         = nil
        UserDefaults.standard.removeObject(forKey: "emailResponseConfirmationCode")
        UserDefaults.standard.removeObject(forKey: "emailResponseExpirationDate")
    }
}
