//
//  BadgeExtension.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

extension UserDefaults {
  // 1
  static let suiteName = "group.bukharovpavel.thinkwhat"
  static let extensions = UserDefaults(suiteName: suiteName)!
  // 2
  private enum Keys {
    static let badge = "badge"
  }
  // 3
  var badge: Int {
    get { UserDefaults.extensions.integer(forKey: Keys.badge) }
    set { UserDefaults.extensions.set(newValue, forKey: Keys.badge) }
  }
}
