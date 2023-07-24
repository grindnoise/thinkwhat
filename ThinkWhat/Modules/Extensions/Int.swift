//
//  Int.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(Int(round(million*10)/10))M"
        }
        else if thousand >= 1.0 {
            return "\(Int(round(thousand*10)/10))K"
        }
        else {
            return "\(self)"
        }
    }
  var isZero: Bool {
    return self == 0
  }
}
