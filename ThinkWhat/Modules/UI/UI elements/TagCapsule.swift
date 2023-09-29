//
//  TagCapsule.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class TagCapsule: UIView {
  // MARK: - Public properties
  ///**Logic**
  public var text: String = "" {
    didSet {
      guard oldValue != text//,
//            let constraint = label.getConstraint(identifier: "widthAnchor")
      else { return }
      
      let constraint = label.getConstraint(identifier: "widthAnchor") ?? {
            let instance = label.widthAnchor.constraint(equalToConstant: text.width(withConstrainedHeight: 100, font: font))
        instance.identifier = "widthAnchor"
        instance.isActive = true
        
        return instance
      }()
      
//      UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve) {[weak self] in
//        guard let self = self else { return }
          
        self.label.text = self.text.uppercased()
//      } completion: { _ in }

      
      setNeedsLayout()
//      UIView.animate(withDuration: 0.3,
//                     delay: 0,
//                     options: .curveEaseInOut) { [weak self] in
//        guard let self = self else { return }
//
        constraint.constant = self.text.uppercased().width(withConstrainedHeight: 100, font: self.font)
//        self.layoutIfNeeded()
//      }
    }
  }
  public var iconCategory: Icon.Category? {
    didSet {
      guard let iconCategory = iconCategory,
            oldValue != iconCategory
      else { return }
      
      icon?.category = iconCategory
//      icon?.icon.add(Animations.get(property: .Path,
//                                   fromValue: (self.icon?.icon as! CAShapeLayer).path!,
//                                   toValue: (self.icon?.getLayer(iconCategory) as! CAShapeLayer).path!,
//                                   duration: 0.3,
//                                   delay: 0,
//                                   repeatCount: 0,
//                                   autoreverses: false,
//                                   timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
//                                   delegate: nil,
//                                   isRemovedOnCompletion: false),
//                    forKey: nil)
    }
  }
  public var image: UIImage? {
    didSet {
      // Animate image change
      guard let image = image,
            oldValue != image,
            let imageView = imageView
      else { return }
      
      Animations.changeImageCrossDissolve(imageView: imageView, image: image)
    }
  }
  public var color: UIColor {
    didSet {
      guard oldValue != color else { return }
      
      bgLayer.colors = CAGradientLayer.getGradientColors(color: color)
    }
  }
  public var userprofile: Userprofile? {
    didSet {
      guard let userprofile = userprofile,
            userprofile.image.isNil
      else { return }
      
      // Subscribe for image downloaded
      userprofile.imagePublisher
        .sink {
          if case .failure(let error) = $0 {
#if DEBUG
            print(error)
#endif
          }
        } receiveValue: { [weak self] in
          guard let self = self else { return }
          
          self.imageView?.image = $0
        }
        .store(in: &subscriptions)
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
  private let textPadding: UIEdgeInsets
  private let isShadowed: Bool
  private let useGradient: Bool
  private lazy var bgLayer: CAGradientLayer = {
    let instance = CAGradientLayer()
    instance.type = .radial
    instance.colors = CAGradientLayer.getGradientColors(color: color)
    instance.locations = [0, 0.5, 1.15]
    instance.setIdentifier("radialGradient")
    instance.startPoint = CGPoint(x: 0.5, y: 0.5)
    instance.endPoint = CGPoint(x: 1, y: 1)
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { rect in
        instance.cornerRadius = rect.height/2.25
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor).isActive = true
    if !iconCategory.isNil, let icon = icon {
//      icon.place(inside: opaque)
      icon.placeInCenter(of: opaque)
    } else if !image.isNil, let imageView = imageView {
      imageView.placeInCenter(of: opaque)
    } else if !userprofile.isNil, let imageView = imageView {
      imageView.placeInCenter(of: opaque)
    }
    
    let opaque2 = UIView.opaque()
    label.place(inside: opaque2, insets: textPadding)
    
    let instance = UIStackView(arrangedSubviews: [
      UIView.horizontalSpacer(iconCategory.isNil ? padding : 0),
      opaque,
//      label,
//      opaque,
      opaque2,
      UIView.horizontalSpacer(padding),
    ])
//    instance.publisher(for: \.bounds, options: .new)
//      .filter { $0 != .zero }
//      .sink { instance.cornerRadius = $0.height/2.25 }
//      .store(in: &subscriptions)
//    instance.backgroundColor = color
    instance.spacing = 0//padding
    // Add background layer
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.publisher(for: \.bounds)
      .filter { [unowned self] in $0.size != self.bgLayer.bounds.size }
      .sink { [unowned self] in self.bgLayer.frame = $0 }
      .store(in: &subscriptions)

    
    return instance
  }()
  private lazy var icon: Icon? = {
    let instance = Icon(category: iconCategory!)
    instance.iconColor = .white
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var imageView: UIImageView? = {
    let instance = UIImageView(image: image ?? userprofile?.image)
//    instance.contentMode = !image.isNil ? .center : .scaleAspectFill
    instance.contentMode = .scaleAspectFill
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.layer.masksToBounds = true
    instance.tintColor = .white
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height / 2 }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.font = font
    instance.textAlignment = .center
    instance.text = text
    instance.textColor = .white
//    instance.height("T".height(withConstrainedWidth: 100, font: font))
    
//    let constraint = instance.widthAnchor.constraint(equalToConstant: text.width(withConstrainedHeight: 100, font: font))
//    constraint.identifier = "widthAnchor"
//    constraint.isActive = true
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: font)).isActive = true
    
    return instance
  }()
  private lazy var shadowView: UIView = {
    let instance = UIView.opaque()
    instance.layer.masksToBounds = false
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? color.cgColor : UIColor.black.withAlphaComponent(0.35).cgColor
    instance.layer.shadowOffset = .zero
    instance.layer.shadowOpacity = 1
    instance.publisher(for: \.bounds)
      .sink {
        instance.layer.shadowRadius = $0.height/8
        instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  
  // MARK: - Deinitialization
  deinit {
    if !iconCategory.isNil {
      icon?.icon.removeAllAnimations()
    }
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
       textPadding: UIEdgeInsets = .zero,
       color: UIColor = Colors.Logo.Flame.rawValue,
       font: UIFont,
       useGradient: Bool = true,
       isShadowed: Bool = false,
       iconCategory: Icon.Category? = nil,
       image: UIImage? = nil,
       userprofile: Userprofile? = nil
  ) {
    self.userprofile = userprofile
    self.image = image
    self.text = text
    self.textPadding = textPadding
    self.padding = padding
    self.color = color
    self.isShadowed = isShadowed
    self.font = font
    self.iconCategory = iconCategory
    self.useGradient = useGradient
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if isShadowed {
      shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
  }
}

private extension TagCapsule {
  @MainActor
  func setupUI() {
    layer.masksToBounds = false
    backgroundColor = .clear
    if isShadowed {
      shadowView.place(inside: self, bottomPriority: .required)
    }
    stack.place(inside: self, bottomPriority: .required)
    label.height("T".height(withConstrainedWidth: 100, font: font))
    if !iconCategory.isNil {
      icon?.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
    }
    if !image.isNil || !userprofile.isNil {
      imageView?.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
      
      if !userprofile.isNil {
//        label.height("T".height(withConstrainedWidth: 100, font: font))
        if userprofile!.image.isNil {
          imageView?.contentMode = .center
          imageView?.backgroundColor = .clear
          imageView?.image = UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
          imageView?.tintColor = .white
        } else {
          imageView?.backgroundColor = .white
        }
      }
    }
//    label.translatesAutoresizingMaskIntoConstraints = false
//    label.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: font)).isActive = true
//    label.height("T".height(withConstrainedWidth: 1000, font: font), priority: .required)
  }
}


