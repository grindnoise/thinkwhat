//
//  UIApplication.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIApplication {
  class func topViewController(_ base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
    
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    
    if let tab = base as? UITabBarController {
      let moreNavigationController = tab.moreNavigationController
      
      if let top = moreNavigationController.topViewController, top.view.window != nil {
        return topViewController(top)
      } else if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    
    return base
  }
}
