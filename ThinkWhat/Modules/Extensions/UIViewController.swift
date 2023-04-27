//
//  UIViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var previousController: UIViewController? {
        let i = navigationController?.viewControllers.firstIndex(of: self)
        return navigationController?.viewControllers[i!-1]
    }
}

extension UIViewController {
  func clearNavigationBar(clear: Bool) {
    if clear {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      self.navigationController?.navigationBar.standardAppearance = appearance
      self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    } else {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      self.navigationController?.navigationBar.standardAppearance = appearance
      self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
  }
  
  func fillNavigationBar(with color: UIColor = .systemBackground,
                         shadowColor: UIColor? = nil) {
    guard let navigationBar = self.navigationController?.navigationBar else { return }

    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = color
    appearance.shadowColor = shadowColor
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.prefersLargeTitles = false

    if #available(iOS 15.0, *) { navigationBar.compactScrollEdgeAppearance = appearance }
  }
  
  func setNavigationBarTintColor(_ color: UIColor) {
    self.navigationController?.navigationBar.tintColor = color
  }
}
