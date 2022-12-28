//
//  SurveyLoadingCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class LoaderHeader: UICollectionReusableView {
    
  // MARK: - Public properties
  public var color: UIColor = Colors.Logo.Flame.rawValue {
    didSet {
      guard color != oldValue else { return }
      
      loadingIndicator.setIconColor(color)
//      animateLoaderColor()//from: color, to: color.lighter(0.25))
    }
  }
  public var isLoading: Bool = false {
    didSet {
      guard oldValue != isLoading else { return }
      
      
      
      if isLoading {
        animateLoaderColor()//from: color, to: color.lighter(0.25))
////      } else {
////        loadingIndicator.layer.removeAllAnimations()
      }
      
//      guard let constraint = getConstraint(identifier: "height") else { return }
      
//      setNeedsLayout()
      UIView.animate(withDuration: 0.2) { [weak self] in
        guard let self = self else { return }
        
//        constraint.constant = self.isLoading ? 70 : 1
//        self.loadingIndicator.transform = self.isLoading ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.loadingIndicator.alpha = self.isLoading ? 1 : 0
//        self.layoutIfNeeded()
      }
    }
  }
  
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
  //UI
  private var animation: CAAnimation?
  private lazy var loadingIndicator: Icon = {
    let instance = Icon(category: Icon.Category.Logo)
    instance.iconColor = color
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.65
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
//    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
//    constraint.isActive = true
//    constraint.identifier = "height"

        return instance
    }()
    
    
    // MARK: - Destructor
    deinit {
      loadingIndicator.layer.removeAllAnimations()
      animation = nil
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension LoaderHeader {
  @MainActor
    func setupUI() {
      backgroundColor = .clear
      
//      loadingIndicator.placeInCenter(of: self)
      
      addSubview(loadingIndicator)
      loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        loadingIndicator.topAnchor.constraint(equalTo: topAnchor),
        loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        loadingIndicator.heightAnchor.constraint(equalToConstant: 40)
      ])
      let constraint = loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
      constraint.priority = .defaultLow
      constraint.isActive = true
      
//      let constraint = heightAnchor.constraint(equalToConstant: 30)
//      constraint.isActive = true
//      constraint.identifier = "height"
    }
  
  @MainActor
  func animateLoaderColor() {//from: UIColor, to: UIColor) {
      animation = Animations.get(property: .FillColor,
                                fromValue: color.cgColor as Any,
                                toValue: color.lighter(0.25).cgColor as Any,
                                duration: 1,
                                delay: 0,
                                repeatCount: 0,
                                autoreverses: true,
                                timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                delegate: self,
                                isRemovedOnCompletion: true,
                                completionBlocks: [
                                  {[weak self] in
                                      guard let self = self else { return }
                                      
                                      if !self.isLoading {
                                          self.animateLoaderColor()//from: to, to: from)
                                      }
                                  }])
      
      loadingIndicator.icon.add(animation!, forKey: nil)
//      loadingIndicator.iconColor = to
  }
}

extension LoaderHeader: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
            initialLayer.path = path as! CGPath
            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
                completionBlock()
            }
        }
    }
}
