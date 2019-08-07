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
    
    var confirmation_code:      Int!
    var expiresIn:              Date!
    
    init?(json: JSON) {
        var dict = json.dictionaryObject as! [String: Any]
        self.confirmation_code = dict["confirmation_code"] as! Int
        self.expiresIn         = dict["expires_in"] is NSNull ? Date(dateTimeString: "01.01.0001") : Date(dateTimeString:dict["expires_in"] as! String)
        storeEmailResponse()
    }

    init?(confirmation_code: Int, expiresIn: Date) {
        self.confirmation_code = confirmation_code
        self.expiresIn         = expiresIn
    }
    
    private func storeEmailResponse() {
        AppData.shared.system.emailResponseConfirmationCode = confirmation_code
        AppData.shared.system.emailResponseExpirationDate   = expiresIn
    }
    
    deinit {
        AppData.shared.system.emailResponseConfirmationCode = nil
        AppData.shared.system.emailResponseExpirationDate   = nil
    }
}
