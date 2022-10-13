//
//  CALayer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension CALayer {
    var identifier: String {
        get {
            guard let value = self.value(forKey: "identifier") as? String else { return "" }
            return value
        }
    }
    
    func setIdentifier(_ identifier: String) {
        self.setValue(identifier, forKey: "identifier")
    }
    
    func getSublayer(identifier value: String) -> CALayer? {
        return self.sublayers?.filter({
            return $0.identifier == value
        }).first
    }
    
    func getSublayers(identifier value: String) -> [CALayer] {
        guard !self.sublayers.isNil, !self.sublayers!.isEmpty else {
            return []
        }
        
        return self.sublayers!.filter({
            return $0.identifier == value
        })
    }

}
