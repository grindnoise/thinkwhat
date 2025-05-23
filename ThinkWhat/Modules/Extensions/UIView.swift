//
//  UIView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

extension UIView {
  
//  func copyView<T: UIView>() -> T? {
//    //    do {
//    //      return try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false))
//    //    } catch {
//    //      return nil
//    //    }
//    //    return NSKeyedUnarchiver.unarchiveObject(ofClass: <T>, from: NSKeyedArchiver.archivedData(withRootObject: self)) as? T
//    do {
//      return try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self,
//                                                    from: try! NSKeyedArchiver.archivedData(withRootObject: self,
//                                                                                            requiringSecureCoding: false))
//    } catch {
//      return nil
//    }
//    //    return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? T
//  }
  
  func makeScreenshot() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
    return renderer.image { (context) in
      self.layer.render(in: context.cgContext)
    }
  }
  
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
  
  class func opaque() -> UIView {
    let opaque = UIView()
    opaque.accessibilityIdentifier = "opaque"
    opaque.backgroundColor = .clear
    
    return opaque
  }
  
  class func horizontalSpacer(_ width: CGFloat) -> UIView {
    let instance = UIView()
    instance.widthAnchor.constraint(equalToConstant: width).isActive = true
    instance.accessibilityIdentifier = "horizontalSpacer"
    instance.backgroundColor = .clear
    
    return instance
  }
  
  class func verticalSpacer(_ height: CGFloat) -> UIView {
    let instance = UIView()
    instance.heightAnchor.constraint(equalToConstant: height).isActive = true
    instance.accessibilityIdentifier = "verticalSpacer"
    instance.backgroundColor = .clear
    
    return instance
  }
  
  func setSpinning(on: Bool,
                   color: UIColor = .secondaryLabel,
                   animated: Bool = true,
                   completion: Closure? = nil) {
    switch on {
    case true:
      let spinner = UIActivityIndicatorView()
      spinner.accessibilityIdentifier = "spinner"
      spinner.color = color
      spinner.startAnimating()
      spinner.alpha = animated ? 0 : 1
      spinner.transform = animated ? .init(scaleX: 0.5, y: 0.5) : .identity
      spinner.placeInCenter(of: self)
      
      guard animated else {
        completion?()
        
        return
      }
      
      UIView.animate(withDuration: 0.15) {
        spinner.alpha = 1
        spinner.transform = .identity
      } completion: { _ in
        completion?()
      }
    case false:
      guard let spinner = getSubview(type: UIActivityIndicatorView.self, identifier: "spinner") else { return }
      
      guard animated else {
        spinner.removeFromSuperview()
        completion?()
        
        return
      }
      
      UIView.animate(withDuration: 0.15) {
        spinner.alpha = 0
        spinner.transform = .init(scaleX: 0.5, y: 0.5)
      } completion: { _ in
        spinner.removeFromSuperview()
        completion?()
      }
    }
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
  
  class func getAllSubviews(from parent: UIView, types: [UIView.Type]) -> [UIView] {
    return parent.subviews.flatMap { subview -> [UIView] in
      var result = getAllSubviews(from: subview) as [UIView]
      for type in types {
        if subview.classForCoder == type {
          result.append(subview)
          return result
        }
      }
      return result
    }
  }
  
  //    class func getAllSuperviews(above owner: UIView) -> [UIView] {
  //        var superviews: [UIView] = [owner] {
  //            didSet {
  //                guard let last = superviews.last,
  //                      let superview = last.superview,
  //                      !superview.contains(superview)
  //                else { return }
  //
  //                superviews.append(superview)
  //            }
  //        }
  //
  //        return superviews
  //    }
  
  class func getAllSuperviews(above owner: UIView) -> [UIView] {
    var superviews: [UIView] = [owner] {
      didSet {
        guard let last = superviews.last,
              let superview = last.superview
        else { return }
        
        superviews += UIView.getAllSuperviews(above: superview)
      }
    }
    
    guard let superview = owner.superview else { return superviews }
    //
    superviews.append(superview)
    
    return superviews
  }
  
  func getAllSubviews<T: UIView>() -> [T] { return UIView.getAllSubviews(from: self) as [T] }
  
  func get<T: UIView>(all type: T.Type) -> [T] { return UIView.getAllSubviews(from: self) as [T] }
  
  func get(all types: [UIView.Type]) -> [UIView] { return UIView.getAllSubviews(from: self, types: types) }
  
  func getSubview<T: UIView>(type: T.Type, identifier: String? = nil) -> T? {
    guard let identifier = identifier else {
      return self.get(all: type).first
    }
    
    return self.get(all: type).filter({ $0.accessibilityIdentifier == identifier }).first
  }
  
  func getLayer(identifier: String) -> CALayer? { self.layer.sublayers?.filter({ $0.name == identifier }).first }

  
  func getAllSuperviews<T: UIView>() -> [T] { UIView.getAllSuperviews(above: self).filter { $0 is T } as? [T] ?? [] }
  
  func getSuperview<T: UIView>(type: T.Type) -> T? { UIView.getAllSuperviews(above: self).filter { $0 is T }.first as? T }
  
  func addSubviews(_ items: [UIView]) { items.forEach { addSubview($0) } }
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
  
  func viewByClassName(className: String) -> UIView? {
    guard className != NSStringFromClass(type(of: self)) else { return self }
    
    return getAllSubviews().filter({ className == NSStringFromClass(type(of: $0)) }).first
  }
  
  func addShadow(shadowPath: CGPath = CGPath.init(rect: .zero, transform: nil), shadowColor: UIColor = UIColor.black,
                 shadowOffset: CGSize = CGSize.zero,
                 shadowOpacity: Float = 0.5,
                 shadowRadius: CGFloat = 3.0) {
    layer.shadowPath = shadowPath
    layer.shadowColor = shadowColor.cgColor
    layer.shadowOffset = shadowOffset
    layer.shadowOpacity = shadowOpacity
    layer.shadowRadius = shadowRadius
  }
}

//Layout
extension UIView {
  func addEquallyTo(to view: UIView) {
    
    self.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self)
    let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
    let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
    let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
    let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
    NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
  }
  
  @discardableResult
  func place(inside parent: UIView,
             insets: UIEdgeInsets = .uniform(size: 0),
             bottomPriority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
    
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    let leadingAnchorConstraint = leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: insets.left)
    leadingAnchorConstraint.isActive = true
    leadingAnchorConstraint.identifier = "leadingAnchor"
    let topAnchorConstraint = topAnchor.constraint(equalTo: parent.topAnchor, constant: insets.top)
    topAnchorConstraint.isActive = true
    topAnchorConstraint.identifier = "topAnchor"
    let trailingAnchorConstraint = trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -insets.right)
    trailingAnchorConstraint.isActive = true
    trailingAnchorConstraint.identifier = "trailingAnchor"
    let bottomAnchorConstraint = bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -insets.bottom)
    bottomAnchorConstraint.isActive = true
    bottomAnchorConstraint.priority = bottomPriority
    bottomAnchorConstraint.identifier = "bottomAnchor"
    
    return [
      leadingAnchorConstraint,
      trailingAnchorConstraint,
      topAnchorConstraint,
      bottomAnchorConstraint
    ]
  }
  
  @discardableResult
  func placeXCentered(inside parent: UIView,
                      insets: UIEdgeInsets = .uniform(size: 0)) -> [NSLayoutConstraint] {
    
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    let centerXAnchorConstraint = centerXAnchor.constraint(equalTo: parent.centerXAnchor)
    centerXAnchorConstraint.isActive = true
    centerXAnchorConstraint.identifier = "centerXAnchor"
    let widthAnchorConstraint = widthAnchor.constraint(equalTo: parent.widthAnchor, constant: -(insets.left + insets.right))
    widthAnchorConstraint.isActive = true
    widthAnchorConstraint.identifier = "widthAnchor"
    let topAnchorConstraint = topAnchor.constraint(equalTo: parent.topAnchor, constant: insets.top)
    topAnchorConstraint.isActive = true
    topAnchorConstraint.identifier = "topAnchor"
    let bottomAnchorConstraint = bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -insets.bottom)
    bottomAnchorConstraint.isActive = true
    bottomAnchorConstraint.identifier = "bottomAnchor"
    
    return [
      centerXAnchorConstraint,
      widthAnchorConstraint,
      topAnchorConstraint,
      bottomAnchorConstraint
    ]
  }
  
  @discardableResult
  func placeXCentered(inside parent: UIView,
                      topInset: CGFloat,
                      size: CGSize) -> [NSLayoutConstraint] {
    
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    let centerXAnchorConstraint = centerXAnchor.constraint(equalTo: parent.centerXAnchor)
    centerXAnchorConstraint.isActive = true
    centerXAnchorConstraint.identifier = "centerXAnchor"
    let widthAnchorConstraint = widthAnchor.constraint(equalToConstant: size.width)
    widthAnchorConstraint.isActive = true
    widthAnchorConstraint.identifier = "widthAnchor"
    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: size.height)
    heightAnchorConstraint.isActive = true
    heightAnchorConstraint.identifier = "heightAnchor"
    let topAnchorConstraint = topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset)
    topAnchorConstraint.isActive = true
    topAnchorConstraint.identifier = "topAnchor"
    
    return [
      centerXAnchorConstraint,
      widthAnchorConstraint,
      heightAnchorConstraint,
      topAnchorConstraint
    ]
  }
  
  @discardableResult
  func placeXCentered(inside parent: UIView,
                      topInset: CGFloat,
                      bottomInset: CGFloat) -> [NSLayoutConstraint] {
    
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    let centerXAnchorConstraint = centerXAnchor.constraint(equalTo: parent.centerXAnchor)
    centerXAnchorConstraint.isActive = true
    centerXAnchorConstraint.identifier = "centerXAnchor"
    let topAnchorConstraint = topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset)
    topAnchorConstraint.isActive = true
    topAnchorConstraint.identifier = "topAnchor"
    let bottomAnchorConstraint = bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottomInset)
    bottomAnchorConstraint.isActive = true
    bottomAnchorConstraint.identifier = "topAnchor"
    
    return [
      centerXAnchorConstraint,
      bottomAnchorConstraint,
      topAnchorConstraint
    ]
  }
  
  func placeInCenter(of parent: UIView,
                     topInset: CGFloat,
                     bottomInset: CGFloat) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
    bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottomInset).isActive = true
  }
  
  func placeInCenter(of parent: UIView,
                     leadingInset: CGFloat,
                     trailingInset: CGFloat) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true
//    bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leadingInset).isActive = true
    trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -trailingInset).isActive = true
  }
  
  @discardableResult
  func placeInCenter(of parent: UIView,
                     heightMultiplier: CGFloat = .zero) -> [NSLayoutConstraint] {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    let centerXAnchorConstraint = centerXAnchor.constraint(equalTo: parent.centerXAnchor)
    centerXAnchorConstraint.isActive = true
    centerXAnchorConstraint.identifier = "centerXAnchor"
    
    let centerYAnchorConstraint = centerYAnchor.constraint(equalTo: parent.centerYAnchor)
    centerYAnchorConstraint.isActive = true
    centerYAnchorConstraint.identifier = "centerYAnchor"

    var constraints = [centerYAnchorConstraint, centerXAnchorConstraint]
    
    guard heightMultiplier != .zero else { return constraints }
    
    let heightAnchorConstraint = heightAnchor.constraint(equalTo: parent.heightAnchor, multiplier: heightMultiplier)
    heightAnchorConstraint.isActive = true
    heightAnchorConstraint.identifier = "heightAnchor"
    
    constraints.append(heightAnchorConstraint)
    return constraints
  }
  
  func placeInCenter(of parent: UIView,
                     widthMultiplier: CGFloat = 1,
                     xOffset: CGFloat = .zero,
                     yOffset: CGFloat = .zero) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: yOffset).isActive = true
    centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: xOffset).isActive = true
    widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: widthMultiplier).isActive = true
  }
  
  func placeCentered(inside parent: UIView,
                     withMultiplier multiplier: CGFloat) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    
    let centerXAnchor = centerXAnchor.constraint(equalTo: parent.centerXAnchor)
    centerXAnchor.identifier = "centerXAnchor"
    centerXAnchor.isActive = true
    
    let centerYAnchor = centerYAnchor.constraint(equalTo: parent.centerYAnchor)
    centerYAnchor.identifier = "centerYAnchor"
    centerYAnchor.isActive = true
    
    let widthAnchor = widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: multiplier)
    widthAnchor.identifier = "widthAnchor"
    widthAnchor.isActive = true
    
    let heightAnchor = heightAnchor.constraint(equalTo: parent.heightAnchor, multiplier: multiplier)
    heightAnchor.identifier = "heightAnchor"
    heightAnchor.isActive = true
  }
  
  func placeXCentered(inside parent: UIView,
                      widthMultiplier: CGFloat,
                      topInset: CGFloat = .zero,
                      bottomInset: CGFloat = .zero) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: widthMultiplier).isActive = true
    heightAnchor.constraint(equalTo: parent.heightAnchor, multiplier: widthMultiplier).isActive = true
    
    guard topInset != .zero, bottomInset != .zero else {
//      topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
//      bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottomInset).isActive = true
      centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
      
      return
    }
    topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
    bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottomInset).isActive = true
//    centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
  }
  
//  @discardableResult
//  func placeInCenter(of parent: UIView,
//                     widthMultiplier: CGFloat = 1,
//                     xOffset: CGFloat = .zero,
//                     yOffset: CGFloat = .zero) {
//    parent.addSubview(self)
//    translatesAutoresizingMaskIntoConstraints = false
//
//    centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: yOffset).isActive = true
//    centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: xOffset).isActive = true
//    widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: widthMultiplier).isActive = true
//  }
//
//  func placeXCentered(inside parent: UIView,
//                      widthMultiplier: CGFloat,
//                      topInset: CGFloat = .zero,
//                      bottomInset: CGFloat = .zero) -> [NSLayoutConstraint] {
//    parent.addSubview(self)
//    translatesAutoresizingMaskIntoConstraints = false
//
//    let centerXAnchor = centerXAnchor.constraint(equalTo: parent.centerXAnchor)
//    centerXAnchor.isActive = true
//    centerXAnchor.identifier = "centerXAnchor"
//
//    let widthAnchor = widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: widthMultiplier)
//    widthAnchor.isActive = true
//    widthAnchor.identifier = "widthAnchor"
//
//    var constraints = [centerXAnchor, widthAnchor]
//
//    if topInset != .zero, bottomInset != .zero  {
//      topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
//      bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottomInset).isActive = true
//    } else {
//      let centerYAnchor = centerYAnchor.constraint(equalTo: parent.centerYAnchor)
//      centerYAnchor.isActive = true
//      centerYAnchor.identifier = "centerYAnchor"
//
//      constraints.append(centerYAnchor)
//    }
//
//    return constraints
//  }
  
  func placeLeading(inside parent: UIView,
                    leadingInset: CGFloat = .zero,
                    topInset: CGFloat = .zero,
                    bottomInset: CGFloat = .zero) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leadingInset).isActive = true
    
    guard topInset != .zero, bottomInset != .zero else {
      topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
      bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottomInset).isActive = true
      
      return
    }
    centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
  }
  
  func placeLeadingV2(inside parent: UIView,
                    leadingInset: CGFloat = .zero,
                    topInset: CGFloat = .zero,
                    bottomInset: CGFloat = .zero) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leadingInset).isActive = true
    topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
    bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: bottomInset).isActive = true
  }
  
  @discardableResult
  func placeTopLeading(inside parent: UIView,
                       leadingInset: CGFloat = .zero,
                       topInset: CGFloat = .zero,
                       width: CGFloat = .zero,
                       height: CGFloat = .zero) -> [NSLayoutConstraint] {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    
    let leading = leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leadingInset)
    leading.isActive = true
    leading.identifier = "leadingAnchor"
    
    let top = topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset)
    top.isActive = true
    top.identifier = "topAnchor"
//    topAnchor.constraint(equalTo: parent.topAnchor, constant: topInset).isActive = true
    
    var constraints = [leading, top]
    
    if height != .zero {
      let height = heightAnchor.constraint(equalToConstant: height)
      height.isActive = true
      height.identifier = "heightAnchor"
      constraints.append(height)
    }
    if width != .zero {
      let width = widthAnchor.constraint(equalToConstant: width)
      width.isActive = true
      width.identifier = "widthAnchor"
      constraints.append(width)
    }
    
    return constraints
  }
  
  func placeLeadingYCentered(inside parent: UIView,
                    leadingInset: CGFloat = .zero) {
    parent.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    
    leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: leadingInset).isActive = true
    centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
  }
  
  func addEquallyTo(to view: UIView, multiplier: CGFloat) {
    
    self.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self)
    let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
    let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
    let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: multiplier, constant: 0)
    let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: multiplier, constant: 0)
    NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
  }
  
  
  func layoutCentered(in view: UIView, multiplier: CGFloat = 1) {
    self.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self)
    let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
    let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
    let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: multiplier, constant: 0)
    let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
    NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
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

extension UIView {
  func startRotating(duration: CFTimeInterval = 3, repeatCount: Float = Float.greatestFiniteMagnitude, clockwise: Bool = true) {
    
    if self.layer.animation(forKey: "transform.rotation.z") != nil {
      return
    }
    
    let animation = CABasicAnimation(keyPath: "transform.rotation.z")
    let direction = clockwise ? 1.0 : -1.0
    animation.toValue = NSNumber(value: .pi * 2 * direction)
    animation.duration = duration
    animation.isCumulative = true
    animation.repeatCount = repeatCount
    self.layer.add(animation, forKey:"transform.rotation.z")
  }
  
  func stopRotating() {
    
    self.layer.removeAnimation(forKey: "transform.rotation.z")
    self.layer.removeAllAnimations()
  }
  
  func randomPoint(_ xRange: ClosedRange<CGFloat>? = nil, _ yRange: ClosedRange<CGFloat>? = nil) -> CGPoint {
    CGPoint(x: CGFloat.random(in: xRange.isNil ? 0.0...bounds.width : xRange!),
            y: CGFloat.random(in: yRange.isNil ? 0.0...bounds.height : yRange!))
  }
  
  func randomFrame(size: CGSize, excludeAreas: [CGRect]) -> CGRect {
    let random = CGRect(origin: CGPoint(x: CGFloat.random(in: 0.0...bounds.width),
                                        y: CGFloat.random(in: 0.0...bounds.height)),
                        size: size)
    
    let test = excludeAreas.map({ random.intersects($0) })
      .filter({ $0 == true })
    
    if excludeAreas
      .map({ random.intersects($0) })
      .filter({ $0 == true }).isEmpty {
      return random
    }
    
    return randomFrame(size: size, excludeAreas: excludeAreas)
  }
}

extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}
