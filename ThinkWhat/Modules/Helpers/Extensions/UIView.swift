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
    
//    var statusBarWindow: UIWindow {
//        guard let window = window,
//              let windowScene = window.windowScene,
//              let statusBarManager = windowScene.statusBarManager else {
//                  return .zero
//              }
//        return statusBarManager.
//    }
    func setAttributedText(text: String, font: String, width: CGFloat, widthDivisor: CGFloat, lightColor: UIColor, style: UIUserInterfaceStyle) {
        if let btn = self as? UIButton {
            btn.setAttributedTitle(NSAttributedString(string: text.localized,
                                                      attributes: StringAttributes.getAttributes(font: UIFont(name: font, size: width * widthDivisor)!, foregroundColor: style == .dark ? .systemBlue : lightColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]),
                                   for: .normal)
        }
    }

    func setAttributedText(text: String, font: String, height: CGFloat, heightDivisor: CGFloat, lightColor: UIColor, style: UIUserInterfaceStyle) {
        if let btn = self as? UIButton {
            btn.setAttributedTitle(NSAttributedString(string: text.localized,
                                                      attributes: StringAttributes.getAttributes(font: UIFont(name: font, size: height * heightDivisor)!, foregroundColor: style == .dark ? .systemBlue : lightColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]),
                                   for: .normal)
        }
    }

}

