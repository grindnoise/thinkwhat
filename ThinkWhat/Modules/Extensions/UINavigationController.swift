//
//  UINavigationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit



extension UINavigationController {
  struct Constants {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 40
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    
    static let NavBarHeightLargeState: CGFloat = 96.5
  }

  open override var childForStatusBarStyle: UIViewController? {
    return self.topViewController
  }
  
  open override var childForStatusBarHidden: UIViewController? {
    return self.topViewController
  }
  
  public final func setBarTintColor(_ color: UIColor) {
    navigationBar.tintColor = color
  }
  
  public final func setBarShadow(on: Bool,
                    color: UIColor = .lightGray.withAlphaComponent(0.25),
                    animated: Bool = false) {
    if on {
      guard navigationBar.layer.shadowOpacity.isZero else { return }
      
      navigationBar.layer.masksToBounds = false
      navigationBar.layer.shadowColor = color.cgColor
      navigationBar.layer.shadowOffset = .zero
      navigationBar.layer.shadowRadius = 8
      navigationBar.layer.shadowPath = UIBezierPath(rect: navigationBar.bounds).cgPath
      
      guard animated else {
        navigationBar.layer.shadowOpacity = on ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
        
        return
      }
      
      navigationBar.layer.add(Animations.get(property: .ShadowOpacity,
                                             fromValue: 0,
                                             toValue: 1,
                                             duration: 0.2,
                                             delegate: nil),
                              forKey: nil)
      navigationBar.layer.shadowOpacity = on ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    } else {
      guard !navigationBar.layer.shadowOpacity.isZero else { return }
      
      guard animated else {
        navigationBar.layer.shadowOpacity = 0
        return
      }
      
      navigationBar.layer.add(Animations.get(property: .ShadowOpacity,
                                             fromValue: 1,
                                             toValue: 0,
                                             duration: 0.2,
                                             delegate: nil),
                              forKey: nil)
      navigationBar.layer.shadowOpacity = 0
    }
  }
  
  func setBarColor(_ color: UIColor = .systemBackground, _ shadowColor: UIColor? = nil) {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = color
    appearance.shadowColor = shadowColor
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    
    if #available(iOS 15.0, *) { navigationBar.compactScrollEdgeAppearance = appearance }
  }
  
  func setBarOpaque() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    
    if #available(iOS 15.0, *) { navigationBar.compactScrollEdgeAppearance = appearance }
  }
  
  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    navigationBar.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
}

extension UITabBarController {
  open override var childForStatusBarStyle: UIViewController? {
    return self.children.first
  }
  
  open override var childForStatusBarHidden: UIViewController? {
    return self.children.first
  }
}

extension UISplitViewController {
  open override var childForStatusBarStyle: UIViewController? {
    return self.children.first
  }
  
  open override var childForStatusBarHidden: UIViewController? {
    return self.children.first
  }
}
