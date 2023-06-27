//
//  LoaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class LoaderCell: UICollectionReusableView {
  
  // MARK: - Public properties
  public var color: UIColor = Colors.Logo.Flame.rawValue {
    didSet {
      guard color != oldValue else { return }
      
      setupUI()
//      loadingIndicator.color = color
//      loadingIndicator.setIconColor(color)
    }
  }
  public var isLoading: Bool = false {
    didSet {
      guard oldValue != isLoading else { return }
      
//      if isLoading {
//        spinner.start(duration: 1)
////        loadingIndicator.start()
//      } else {
//        spinner.stop()
////        loadingIndicator.stop()
////        loadingIndicator.reset()
//      }
      if isLoading {
        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        //    spinner.backgroundColor = .red
        
        NSLayoutConstraint.activate([
          spinner.topAnchor.constraint(equalTo: topAnchor, constant: 8),
          spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
          spinner.heightAnchor.constraint(equalToConstant: 40)
        ])
        let constraint = spinner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        spinner.start(duration: 1)
      }
      
      spinner.transform = isLoading ? CGAffineTransform(scaleX: 0.5, y: 0.5) : .identity
      spinner.alpha = isLoading ? 0 : 1
      UIView.animate(withDuration: 0.2, animations: { [weak self] in
        guard let self = self else { return }
        
        self.spinner.alpha = self.isLoading ? 1 : 0
        self.spinner.transform = self.isLoading ? .identity : CGAffineTransform(scaleX: 0.25, y: 0.25)
      }) { [weak self] _ in
        guard let self = self,
              !self.isLoading
        else { return }
        
        self.spinner.removeFromSuperview()
      }
//      }) { [weak self] _ in
//        guard let self = self else { return }
//
//        if self.isLoading {
//          self.animateLoaderColor()
//        } else {
//          self.loadingIndicator.layer.removeAllAnimations()
//          self.colorAnimation = nil
//          self.scaleAnimation = nil
//        }
//      }
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
//  private var colorAnimation: CAAnimation?
//  private var scaleAnimation: CAAnimation?
  private lazy var spinner: SpiralSpinner = { SpiralSpinner() }()
//  private lazy var loadingIndicator: LoadingIndicator = { LoadingIndicator(color: color, shouldSendCompletion: false) }()
//  private lazy var loadingIndicator: Icon = {
//    let instance = Icon(category: Icon.Category.Logo)
//    instance.iconColor = color
//    instance.isRounded = false
//    instance.clipsToBounds = false
//    instance.scaleMultiplicator = 1.65
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
////    instance.alpha = 0
//
//    return instance
//  }()
  
  
  // MARK: - Destructor
  deinit {
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
    
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  
  public func cancelAllAnimations() {
    spinner.stop()
//    loadingIndicator.layer.removeAllAnimations()
//    colorAnimation = nil
//    scaleAnimation = nil
  }
}

private extension LoaderCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
//    addSubview(spinner)
//    spinner.translatesAutoresizingMaskIntoConstraints = false
////    spinner.backgroundColor = .red
//
//    NSLayoutConstraint.activate([
//      spinner.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//      spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
//      spinner.heightAnchor.constraint(equalToConstant: 40)
//    ])
//    let constraint = spinner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
//    constraint.priority = .defaultLow
//    constraint.isActive = true
    //      loadingIndicator.placeInCenter(of: self)
    
//    addSubview(loadingIndicator)
//    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//
//    NSLayoutConstraint.activate([
//      loadingIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//      loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -8),
//      loadingIndicator.heightAnchor.constraint(equalToConstant: 40)
//    ])
//    let constraint = loadingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor)
//    constraint.priority = .defaultLow
//    constraint.isActive = true
    
    //      let constraint = heightAnchor.constraint(equalToConstant: 30)
    //      constraint.isActive = true
    //      constraint.identifier = "height"
  }
  
//  @MainActor
//  func animateLoaderColor() {//from: UIColor, to: UIColor) {
//    colorAnimation = Animations.get(property: .FillColor,
//                               fromValue: color.cgColor as Any,
//                               toValue: color.lighter(0.25).cgColor as Any,
//                               duration: 1,
//                               delay: 0,
//                               repeatCount: .infinity,
//                               autoreverses: true,
//                               timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                               delegate: self,
//                               isRemovedOnCompletion: true,
//                               completionBlocks: [
//                                {[weak self] in
//                                  guard let self = self else { return }
//
//                                  if !self.isLoading {
//                                    self.animateLoaderColor()//from: to, to: from)
//                                  }
//                                }])
//    scaleAnimation = Animations.get(property: .Scale,
//                               fromValue: 1 as Any,
//                               toValue: 0.97 as Any,
//                               duration: 1,
//                               delay: 0,
//                               repeatCount: .infinity,
//                               autoreverses: true,
//                               timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                               delegate: self,
//                               isRemovedOnCompletion: true,
//                               completionBlocks: [
//                                {[weak self] in
//                                  guard let self = self else { return }
//
//                                  if !self.isLoading {
//                                    self.animateLoaderColor()//from: to, to: from)
//                                  }
//                                }])
//
//    loadingIndicator.icon.add(scaleAnimation!, forKey: nil)
//    loadingIndicator.icon.add(colorAnimation!, forKey: nil)
//    //      loadingIndicator.iconColor = to
//  }
}

//extension LoaderCell: CAAnimationDelegate {
//  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
//      completionBlocks.forEach{ $0() }
//    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
//      completionBlocks.forEach{ $0() }
//    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
//      initialLayer.path = path as! CGPath
//      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
//        completionBlock()
//      }
//    }
//  }
//}
