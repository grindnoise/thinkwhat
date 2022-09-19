//
//  UIEdgeInsets.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    static func uniform(size: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: size, left: size, bottom: size, right: size)
    }
    
}
