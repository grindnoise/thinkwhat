//
//  SMSResponse.swift
//  Burb
//
//  Created by Pavel Bukharov on 23.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SMSResponse {
    
    var phoneNumber:            Int
    var passcode:               Int
    var timeout:                Int
    var expiryDateTime:         Date
    
    init?(json: JSON) {
        phoneNumber     = 0
        passcode        = 0
        timeout         = 0
        expiryDateTime  = Date()
        for attr in json {
            if attr.0 == "passcode" {
                passcode = attr.1.intValue
            } else if attr.0 == "phoneNumber" {
                phoneNumber = attr.1.intValue
            } else if attr.0 == "timeout" {
                timeout = attr.1.intValue
                expiryDateTime = Date().addingTimeInterval(Double(timeout))
            } else {
                continue
            }
        }
    }
}
