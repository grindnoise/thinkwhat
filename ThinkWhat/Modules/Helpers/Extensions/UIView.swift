//
//  UIView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIView {
    var parentController: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.parentController
        } else {
            return nil
        }
    }
    
    var statusBarFrame: CGRect {
        guard let window = window,
              let windowScene = window.windowScene,
              let statusBarManager = windowScene.statusBarManager else {
                  return .zero
              }
        return statusBarManager.statusBarFrame
    }
}
