//
//  Localizable.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation

/**
 Conform if localizations is needed
 */
protocol Localizable {
    
    /**
     Subscription if Bundle language changes on the fly.
     */
    func subscribeLocalizable()
    
    /**
     Class-defined implementation.
     */
    func onLanguageChange()
}
