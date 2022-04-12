//
//  Double.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
