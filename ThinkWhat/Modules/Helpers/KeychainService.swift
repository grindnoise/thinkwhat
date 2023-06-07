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
let account = "AuthenticatedUser"
let accessGroup = "SecurityService"

let passwordKey                 = "KeyForPassword"
let access_token                = "access_token"
let apns_token                  = "apns_token"
let refresh_token               = "refresh_token"
let expires_in                  = "expires_in"
//let instagram_access_token      = "instagram_access_token"
let facebook_access_token       = "facebook_access_token"
let vk_access_token             = "vk_access_token"
let google_access_token         = "google_access_token"

let secrets = [
  //    apns_token,
  passwordKey,
  access_token,
  refresh_token,
  expires_in,
  facebook_access_token,
  vk_access_token,
  google_access_token
]

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
    self.save(service: access_token as NSString, string: token)
  }
  
  public class func saveApnsToken(token: Data) {
    self.save(service: apns_token as NSString, data: token)
  }
  
  //    public class func saveInstagramAccessToken(token: NSString) {
  //        self.save(service: instagram_access_token as NSString, string: token)
  //    }
  
  public class func saveFacebookAccessToken(token: NSString) {
    self.save(service: facebook_access_token as NSString, string: token)
  }
  
  public class func saveVKAccessToken(token: NSString) {
    self.save(service: vk_access_token as NSString, string: token)
  }
  
  public func saveGoogleAccessToken(token: NSString) {
    //self.save(service: google_access_token as NSString, data: token)
  }
  
  public class func saveRefreshToken(token: NSString) {
    self.save(service: refresh_token as NSString, string: token)
  }
  
  public class func saveTokenExpireDateTime(token: NSString) {
    self.save(service: expires_in as NSString, string: token)
  }
  
  public class func savePassword(token: NSString) {
    self.save(service: passwordKey as NSString, string: token)
  }
  
  
  
  
  public class func loadAccessToken() -> NSString? {
    return load(service: access_token as NSString)
  }
  
  public class func removeApnsToken() {
    delete(service: access_token, account: account)
  }
  
  public class func loadApnsToken() -> Data? {
    return load(service: apns_token as NSString)
  }
  //    public class func loadInstagramAccessToken() -> NSString? {
  //        return self.load(service: instagram_access_token as NSString)
  //    }
  
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
  
  public class func deleteData() {
    secrets.forEach { delete(service: $0, account: account) }
  }
  
  /**
   * Internal methods for querying the keychain.
   */
  
  private class func save(service: NSString, data: Data) {
    // Create query
    let query = [
      kSecValueData: data,
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    ] as [CFString : Any] as CFDictionary
    
    let deleteStatus = SecItemDelete(query as CFDictionary)
    
    //#if DEBUG
    //      print("delete", deleteStatus)
    //#endif
    
    let status = SecItemAdd(query, nil)
    if status != errSecSuccess {
#if DEBUG
      print("Error: \(status)")
#endif
    }
    
    if status == errSecDuplicateItem {
      // Item already exist, thus update it.
      let query = [
        kSecAttrService: service,
        kSecAttrAccount: account,
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      ] as [CFString : Any] as CFDictionary
      
      let attributesToUpdate = [kSecValueData: data] as CFDictionary
      
      // Update existing item
      let code = SecItemUpdate(query, attributesToUpdate)
#if DEBUG
      print("update", code)
#endif
    }
  }
  
  private class func save(service: NSString, string: NSString) {
    //        let dataFromString: NSData = string.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
    //
    //        // Instantiate a new default keychain query
    //        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [
    //            kSecClassGenericPasswordValue,
    //            service,
    //            account,
    //            dataFromString
    //        ], forKeys: [
    //            kSecClassValue,
    //            kSecAttrServiceValue,
    //            kSecAttrAccountValue,
    //            kSecValueDataValue
    //        ])
    //
    //        // Delete any existing items
    //        SecItemDelete(keychainQuery as CFDictionary)
    //
    //        // Add the new keychain item
    //        let code = SecItemAdd(keychainQuery as CFDictionary, nil)
    //        print(code)
    guard let data = string.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) else { fatalError() }
    // Create query
    let query = [
      kSecValueData: data,
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    ] as [CFString : Any] as CFDictionary
    
    let deleteStatus = SecItemDelete(query as CFDictionary)
    
#if DEBUG
    print("delete", deleteStatus)
#endif
    
    // Add data in query to keychain
    let status = SecItemAdd(query, nil)
    
    if status != errSecSuccess {
#if DEBUG
      print("Error: \(status)")
#endif
    }
    
    if status == errSecDuplicateItem {
      // Item already exist, thus update it.
      let query = [
        kSecAttrService: service,
        kSecAttrAccount: account,
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      ] as CFDictionary
      
      let attributesToUpdate = [kSecValueData: data] as CFDictionary
      
      // Update existing item
      let code = SecItemUpdate(query, attributesToUpdate)
#if DEBUG
      print("update", code)
#endif
    }
  }
  
  private class func load(service: NSString) -> NSString? {
    //        // Instantiate a new default keychain query
    //        // Tell the query to return a result
    //        // Limit our results to one item
    //        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
    //
    //        var dataTypeRef :AnyObject?
    //
    //        // Search for the keychain items
    //        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
    //        var contentsOfKeychain: NSString? = nil
    //
    //        if status == errSecSuccess {
    //            if let retrievedData = dataTypeRef as? NSData {
    //                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
    //            }
    //        } else {
    //            print("Nothing was retrieved from the keychain. Status code \(status)")
    //        }
    //
    //        return contentsOfKeychain
    
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
      kSecReturnData: true,
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      kSecMatchLimitValue: 1
      
    ] as CFDictionary
    
    var result: AnyObject?
    let code = SecItemCopyMatching(query, &result)
    //#if DEBUG
    //      print("load", code)
    //#endif
    
    guard let data = result as? Data,
          let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    else { return nil }
    
    return string
  }
  
  private class func load(service: NSString) -> Data? {
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
      kSecReturnData: true,
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      kSecMatchLimitValue: 1
      
    ] as [CFString : Any] as CFDictionary
    
    var result: AnyObject?
    SecItemCopyMatching(query, &result)
    
    guard let data = result as? Data else { return nil }
    
    return data
  }
  
  private class func delete(service: String, account: String) {
    //
    //        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [
    //            kSecClassGenericPasswordValue,
    //            service,
    //            account,
    //        ], forKeys: [
    //            kSecClassValue,
    //            kSecAttrServiceValue,
    //            kSecAttrAccountValue,
    //        ])
    //
    //        // Delete any existing items
    //        let code = SecItemDelete(keychainQuery as CFDictionary)
    
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
    ] as [CFString : Any] as CFDictionary
    
    // Delete item from keychain
    let code = SecItemDelete(query)
    
#if DEBUG
    print("delete", code)
#endif
  }
}

