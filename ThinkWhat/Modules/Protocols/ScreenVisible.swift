//
//  ScreenVisible.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import Foundation

protocol ScreenVisible {
  var isOnScreen: Bool { get }
  
  func setActive(_: Bool)
}
