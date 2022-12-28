//
//  Common.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit

var isTabBarHidden = false
var tabBarHeight = CGFloat.zero

enum EditMode {
    case Create, Edit
}

func setRootViewController(_ viewController: UIViewController) {
    guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first else {
                return
            }
    keyWindow.rootViewController = viewController
    keyWindow.makeKeyAndVisible()
}

