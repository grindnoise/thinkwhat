//
//  BadgeExtension.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

extension UserDefaults {
  static let suiteName = "group.bukharovpavel.thinkwhat"
  static let extensions = UserDefaults(suiteName: suiteName)!
  
  private enum Keys {
    static let badge = "badge"
  }
  
  var badge: Int {
    get { UserDefaults.extensions.integer(forKey: Keys.badge) }
    set { UserDefaults.extensions.set(newValue, forKey: Keys.badge) }
  }
}
