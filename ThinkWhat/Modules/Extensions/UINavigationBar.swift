//
//  UINavigationBar.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.07.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UINavigationBar {
  func setShadow(on: Bool, color: UIColor = .lightGray.withAlphaComponent(0.25), animated: Bool = false) {
    if on {
      layer.masksToBounds = false
      layer.shadowColor = color.cgColor
      layer.shadowOpacity = on ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
      layer.shadowOffset = .zero
      layer.shadowRadius = 8
    } else if animated, !layer.shadowOpacity.isZero {
      guard traitCollection.userInterfaceStyle != .dark else { return }
      
      layer.add(Animations.get(property: .ShadowOpacity, fromValue: 1, toValue: 0, duration: 0.2, delegate: nil),
                forKey: nil)
    }
  }
  
  func setBackgroundColor(_ color: UIColor = .systemBackground, _ shadowColor: UIColor? = nil) {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = color
    appearance.shadowColor = shadowColor
    standardAppearance = appearance
    scrollEdgeAppearance = appearance
    
    if #available(iOS 15.0, *) { compactScrollEdgeAppearance = appearance }
  }
  
  func setOpaque() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    standardAppearance = appearance
    scrollEdgeAppearance = appearance
    
    if #available(iOS 15.0, *) { compactScrollEdgeAppearance = appearance }
  }
  
  
  func setTintColor(_ color: UIColor = .label) {
    tintColor = color
  }
  
  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
}
