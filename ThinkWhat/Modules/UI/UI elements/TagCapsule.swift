//
//  TagCapsule.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TagCapsule: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  ///**Logic**
  public var text: String = "" {
    didSet {
      guard oldValue != text,
            let constraint = label.getConstraint(identifier: "widthAnchor")
      else { return }
      
      UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve) {[weak self] in
        guard let self = self else { return }
          
        self.label.text = self.text.uppercased()
      } completion: { _ in }

      
      setNeedsLayout()
      UIView.animate(withDuration: 0.3,
                     delay: 0,
                     options: .curveEaseInOut) { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = self.text.uppercased().width(withConstrainedHeight: 100, font: self.font)
        self.layoutIfNeeded()
      }
    }
  }
  public var iconCategory: Icon.Category {
    didSet {
      guard oldValue != iconCategory else { return }
      
          icon.icon.add(Animations.get(property: .Path,
                                       fromValue: (self.icon.icon as! CAShapeLayer).path!,
                                       toValue: (self.icon.getLayer(iconCategory) as! CAShapeLayer).path!,
                                       duration: 0.3,
                                       delay: 0,
                                       repeatCount: 0,
                                       autoreverses: false,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: nil,
                                       isRemovedOnCompletion: false),
                        forKey: nil)
    }
  }
  public var color: UIColor {
    didSet {
      guard oldValue != color else { return }
      
      UIView.animate(withDuration: 0.3) { [weak self] in
        guard let self = self else { return }
        
        self.stack.backgroundColor = self.color
      }
    }
  }
  ///**UI**
  public let font: UIFont
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
//      UIView.horizontalSpacer(padding),
      icon,
      label,
      UIView.horizontalSpacer(padding),
    ])
    instance.publisher(for: \.bounds, options: .new)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    instance.backgroundColor = color
    instance.spacing = padding
    
    return instance
  }()
  private lazy var icon: Icon = {
    let instance = Icon(category: iconCategory)
    instance.iconColor = .white
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.65
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.font = font
    instance.textAlignment = .center
    let constraint = instance.widthAnchor.constraint(equalToConstant: text.width(withConstrainedHeight: 100, font: font))
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    instance.text = text
    instance.textColor = .white
    
    return instance
  }()
  
  
  
  // MARK: - Deinitialization
  deinit {
    icon.icon.removeAllAnimations()
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  init(text: String,
       padding: CGFloat = 4,
       color: UIColor = Colors.Logo.Flame.rawValue,
       font: UIFont,
       iconCategory: Icon.Category = .Logo) {
    self.text = text
    self.padding = padding
    self.color = color
    self.font = font
    self.iconCategory = iconCategory
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension TagCapsule {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self,
                bottomPriority: .defaultLow)
  }
}


