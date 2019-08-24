//
//  SignupCredentials.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.08.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class TemporaryUserCredentials {
    
    static let shared = TemporaryUserCredentials()
    
    private init() {}
    
    fileprivate var _username: String?
    fileprivate var _password: String?
    public var username: String? {
        get {
            return _username
        }
    }
    public var password: String? {
        get {
            return _password
        }
    }

    public func importJson(_ json: JSON) {
        var dict = json.dictionaryObject as! [String: Any]
        _username = dict["username"] as! String
        _password = dict["password"] as! String
    }
    
    public func eraseData() {
        _username = nil
        _password = nil
    }
}

