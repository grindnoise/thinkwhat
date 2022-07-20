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

extension UIView {

    class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
        return parenView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }

    class func getAllSubviews(from parenView: UIView, types: [UIView.Type]) -> [UIView] {
        return parenView.subviews.flatMap { subView -> [UIView] in
            var result = getAllSubviews(from: subView) as [UIView]
            for type in types {
                if subView.classForCoder == type {
                    result.append(subView)
                    return result
                }
            }
            return result
        }
    }

    func getAllSubviews<T: UIView>() -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get<T: UIView>(all type: T.Type) -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get(all types: [UIView.Type]) -> [UIView] { return UIView.getAllSubviews(from: self, types: types) }
    func getSubview<T: UIView>(type: T.Type, identifier: String) -> T? {
        return self.get(all: type).filter({ $0.accessibilityIdentifier == identifier }).first
    }
}
