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
//    func setAttributedText(text: String, font: String, width: CGFloat, widthDivisor: CGFloat, lightColor: UIColor, style: UIUserInterfaceStyle) {
//        if let btn = self as? UIButton {
//            btn.setAttributedTitle(NSAttributedString(string: text.localized,
//                                                      attributes: StringAttributes.getAttributes(font: UIFont(name: font, size: width * widthDivisor)!, foregroundColor: style == .dark ? .systemBlue : lightColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]),
//                                   for: .normal)
//        }
//    }
//
//    func setAttributedText(text: String, font: String, height: CGFloat, heightDivisor: CGFloat, lightColor: UIColor, style: UIUserInterfaceStyle) {
//        if let btn = self as? UIButton {
//            btn.setAttributedTitle(NSAttributedString(string: text.localized,
//                                                      attributes: StringAttributes.getAttributes(font: UIFont(name: font, size: height * heightDivisor)!, foregroundColor: style == .dark ? .systemBlue : lightColor, backgroundColor: .clear) as [NSAttributedString.Key : Any]),
//                                   for: .normal)
//        }
//    }

}

//Get subview(s)
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
    
    func getSubview<T: UIView>(type: T.Type, identifier: String?) -> T? {
        return self.get(all: type).filter({ $0.accessibilityIdentifier == identifier }).first
    }
}

//UI
extension UIView {
    func blur(on: Bool, duration: TimeInterval, effectStyle: UIBlurEffect.Style, withAlphaComponent: Bool, animations: Closure?, completion: Closure?) {
        switch on {
        case true:
            var effectView: UIVisualEffectView!
            if let _effectView = self.getSubview(type: UIVisualEffectView.self, identifier: "blurView") {
                effectView = _effectView
            } else {
                effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
                effectView.addEquallyTo(to: self)
            }
            effectView.effect = nil
            effectView.accessibilityIdentifier = "blurView"
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                           delay: 0,
                                                           options: [.curveEaseInOut],
                                                           animations: { [weak self] in
                guard let self = self else { return }
                
                effectView.effect = UIBlurEffect(style: effectStyle)
                if withAlphaComponent {
                    self.alpha = 0
                }
                
                guard let animations = animations else { return }
                
                animations()
            }) {
                _ in
                
                guard let completion = completion else { return }
                
                completion()
            }
        case false:
            guard let effectView = self.getSubview(type: UIVisualEffectView.self, identifier: "blurView") else { return }
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                           delay: 0,
                                                           options: [.curveEaseInOut],
                                                           animations: { [weak self] in
                guard let self = self else { return }
                
                effectView.effect = nil
                if withAlphaComponent {
                    self.alpha = 1
                }
                
                guard let animations = animations else { return }
                
                animations()
            }) {
                _ in
                
                effectView.removeFromSuperview()
                
                guard let completion = completion else { return }
                
                completion()
            }
        }
    }
}

//extension UIView {
//    func startShimmering() {
//        
//        var subscriptions = Set<AnyCancellable>()
//        
//        let instance = UIView()
//        instance.accessibilityIdentifier = "shimmer"
//        instance.addEquallyTo(to: self)
//        instance.backgroundColor = .red
//        
//        let light = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
//        let dark = UIColor.black.cgColor
//        
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.colors = [dark, light, dark]
//        gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3*instance.bounds.size.width, height: instance.bounds.height)
//        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
//        gradient.locations = [0.4, 0.5, 0.6]
//        instance.layer.addSublayer(gradient)
////        instance.layer.mask = gradient
//        
//        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
//        animation.fromValue = [0.0, 0.1, 0.2]
//        animation.toValue = [0.8, 0.9, 1.0]
//        
//        animation.duration = 1.5
//        animation.repeatCount = HUGE
//        gradient.add(animation, forKey: "gradient")
//        
//        let publisher = instance.publisher(for: \.bounds)
//            .sink {
//                print($0)
//            }.store(in: &subscriptions)
//    }
//
//    func stopShimmeringEffect() {
//            self.layer.mask = nil
//    }
//}
