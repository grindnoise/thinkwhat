//
//  Shimmer.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class Shimmer: UIView {
  
  
  
  // MARK: - Private methods
  private lazy var subscriptions = Set<AnyCancellable>()
  ///**UI**
  private var lightColor: UIColor!
  private var darkColor: UIColor!
  private lazy var gradient: CAGradientLayer = {
    backgroundColor = .clear
    var light: CGColor!
    var dark: CGColor!
    if traitCollection.userInterfaceStyle == .dark {
      light = darkColor.cgColor
      dark = lightColor.lighter(0.025).cgColor
    } else {
      light = lightColor.darker(0.025).cgColor
      dark = lightColor.cgColor
    }
    
    let instance = CAGradientLayer()
    instance.colors = [light, dark, light]
    instance.startPoint = CGPoint(x: 0.0, y: 0.5)
    instance.endPoint = CGPoint(x: 1.0, y: 0.5)
    instance.locations = [0.2, 0.5, 0.9]
    instance.zPosition = 100//.greatestFiniteMagnitude
    layer.addSublayer(instance)
    
    return instance
  }()
  private var isShimmering = false {
    didSet {
      if isShimmering {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.isRemovedOnCompletion = false
        animation.duration = 1.5
        animation.repeatCount = 100//.greatestFiniteMagnitude
        gradient.add(animation, forKey: "shimmering")
      } else {
        self.gradient.removeAllAnimations()
        self.gradient.removeAnimation(forKey: "shimmering")
        self.gradient.opacity = 0
        self.gradient.removeFromSuperlayer()
        //                gradient.add(Animations.get(property: .Opacity, fromValue: 1, toValue: 0, duration: 0.35, delegate: self, completionBlocks: [
        //                    { [weak self] in
        //                        guard let self = self else { return }
        //
        //                        self.gradient.removeAnimation(forKey: "shimmering")
        ////                        self.gradient.removeFromSuperlayer()
        //                        self.gradient.opacity = 0
        //                    }
        //                ]), forKey: nil)
        //                gradient.opacity = 0
      }
    }
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.lightColor = traitCollection.userInterfaceStyle == .dark ? Colors.Shimmer.backgroundLightForDark : Colors.Shimmer.backgroundLightForLight
    self.darkColor = traitCollection.userInterfaceStyle == .dark ? Colors.Shimmer.backgroundDarkForDark : Colors.Shimmer.backgroundDarkForLight
    
    backgroundColor = .clear
  }
  
  init(lightColor: UIColor = .systemBackground,
       darkColor: UIColor = .tertiarySystemBackground) {
    self.lightColor = lightColor.darker(0.025)
    self.darkColor = darkColor.darker(0.05)
    
    super.init(frame: .zero)
    
    backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  
  // MARK: - Destructor
  deinit {
    subscriptions.forEach { $0.cancel() }
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  public func startShimmering(lightColor: UIColor? = nil, darkColor: UIColor? = nil) {
    guard !isShimmering else { return }
    
    if let lightColor = lightColor, let darkColor = darkColor {
      gradient.colors = [darkColor, lightColor, darkColor]
    }
    
    isShimmering = true
    
    publisher(for: \.bounds)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.gradient.frame = CGRect(x: -$0.size.width, y: 0, width: 3*$0.size.width, height: $0.height)
      }
      .store(in: &subscriptions)
  }
  
  func stopShimmering(animated: Bool = false) {
    isShimmering = false
    subscriptions.forEach { $0.cancel() }
    
    func stopShimmering(animated: Bool = false) {
      isShimmering = false
      subscriptions.forEach { $0.cancel() }
      
      guard animated else {
        gradient.removeAllAnimations()
        gradient.removeFromSuperlayer()
        removeFromSuperview()
        
        return
      }
      
      UIView.animate(withDuration: 0.25, delay: 0, animations: { [weak self] in
        guard let self = self else { return }
        
        self.alpha = 0
      }) { _ in
        self.gradient.removeAllAnimations()
        self.gradient.removeFromSuperlayer()
        self.removeFromSuperview()
      }
    }
  }
}

extension Shimmer: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}
