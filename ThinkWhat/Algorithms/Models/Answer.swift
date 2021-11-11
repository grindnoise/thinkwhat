//
//  Answer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Answer {
    let ID: Int
    var description: String
    var totalVotes: Int = 0
    var title: String
    var userprofiles: [UserProfile] = []
    
    //TODO: - Add results for userprofiles
    
    init?(json: JSON) {
        if let _description = json["description"].stringValue as? String,
            let _title = json["title"].stringValue as? String,
            let _ID = json["id"].intValue as? Int {
//            let _totalVotes = json["votes_count"].intValue as? Int {
            ID = _ID
            description =  _description
            title = _title
//            totalVotes = _totalVotes
        } else {
            print("JSON parse error")
            return nil
        }
    }
    
    func appendUserprofile(_ userprofile: UserProfile) {
        if userprofiles.filter({ $0.hashValue == userprofile.hashValue }).isEmpty {
            userprofiles.append(userprofile)
        }
    }
}
