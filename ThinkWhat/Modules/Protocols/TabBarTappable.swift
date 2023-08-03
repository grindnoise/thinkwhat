//
//  TabBarTappable.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol TabBarTappable: UIViewController {
  func tabBarTapped(_: TabBarTapMode)
}
