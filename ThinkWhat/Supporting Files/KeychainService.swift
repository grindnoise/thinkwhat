//
//  KeychainService.swift
//  Burb
//
//  Created by Pavel Bukharov on 26.04.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import Security

// Constant Identifiers
let userAccount = "AuthenticatedUser"
let accessGroup = "SecuritySerivice"

let passwordKey                 = "KeyForPassword"
let access_token                = "access_token"
let refresh_token               = "refresh_token"
let expires_in                  = "expires_in"
let instagram_access_token      = "instagram_access_token"
let facebook_access_token       = "facebook_access_token"
let vk_access_token             = "vk_access_token"
let google_access_token         = "google_access_token"

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class KeychainService: NSObject {

    public class func saveAccessToken(token: NSString) {
        self.save(service: access_token as NSString, data: token)
    }
    
    public class func saveInstagramAccessToken(token: NSString) {
        self.save(service: instagram_access_token as NSString, data: token)
    }
    
    public class func saveFacebookAccessToken(token: NSString) {
        self.save(service: facebook_access_token as NSString, data: token)
    }
    
    public class func saveVKAccessToken(token: NSString) {
        self.save(service: vk_access_token as NSString, data: token)
    }
    
    public func saveGoogleAccessToken(token: NSString) {
        //self.save(service: google_access_token as NSString, data: token)
    }
    
    public class func saveRefreshToken(token: NSString) {
        self.save(service: refresh_token as NSString, data: token)
    }
    
    public class func saveTokenExpireDateTime(token: NSString) {
        self.save(service: expires_in as NSString, data: token)
    }
    
    public class func savePassword(token: NSString) {
        self.save(service: passwordKey as NSString, data: token)
    }
    
    
    
    
    public class func loadAccessToken() -> NSString? {
        return self.load(service: access_token as NSString)
    }
    
    public class func loadInstagramAccessToken() -> NSString? {
        return self.load(service: instagram_access_token as NSString)
    }
    
    public class func loadFacebookAccessToken() -> NSString? {
        return self.load(service: facebook_access_token as NSString)
    }
    
    public class func loadGoogleAccessToken() -> NSString? {
        return self.load(service: google_access_token as NSString)
    }
    
    public class func loadVKAccessToken() -> NSString? {
        return self.load(service: vk_access_token as NSString)
    }
    
    public class func loadRefreshToken() -> NSString? {
        return self.load(service: refresh_token as NSString)
    }
    
    public class func loadTokenExpireDateTime() -> NSString? {
        return self.load(service: expires_in as NSString)
    }
    
    public class func loadPassword() -> NSString? {
        return self.load(service: passwordKey as NSString)
    }
    
    /**
     * Internal methods for querying the keychain.
     */
    
    private class func save(service: NSString, data: NSString) {
        let dataFromString: NSData = data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}

