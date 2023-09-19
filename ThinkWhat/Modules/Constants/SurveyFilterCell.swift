//
//  SurveyFilterCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.08.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class SurveyFilterCell: UICollectionViewListCell {
  // MARK: - Overridden properties
  override var bounds: CGRect {
    didSet {
      updateLayers()
    }
  }
  
  // MARK: - Public properties
  public var filterPublisher = PassthroughSubject<SurveyFilterItem, Never>()
  public var boundsPublisher = PassthroughSubject<Void, Never>()
  public var color: UIColor = Colors.filterEnabled {
    didSet {
      guard oldValue != color else { return }
      
      fgLayer.fillColor = color.cgColor
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  public var item: SurveyFilterItem! {
    didSet {
      guard !item.isNil else { return }
      
      isViewLayedOut ? updateUI() : setupUI()
      setTasks()
    }
  }
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var button: UIButton = {
    let instance = UIButton()
    instance.titleLabel?.numberOfLines = 1
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    instance.backgroundColor = .clear
    instance.tintColor = .white
    instance.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding*2, bottom: padding, right: padding*2)
    if let image = item.getImage() {
      instance.semanticContentAttribute = .forceRightToLeft
      instance.setImage(image, for: .normal)
      //      instance.imageView?.contentMode = .center
      instance.adjustsImageWhenHighlighted = false
      instance.imageView?.layer.masksToBounds = false
      instance.imageEdgeInsets.left = padding/2
      //      instance.imageEdgeInsets.right = padding/4
    }
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, above: bgLayer)
    instance.publisher(for: \.bounds)
      .filter { [unowned self] in $0.size != bgLayer.bounds.size && $0.size != fgLayer.bounds.size }
      .sink { [unowned self] in
        self.bgLayer.frame = $0
        self.fgLayer.frame = $0
        self.bgLayer.path = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        self.fgLayer.path = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
      }
      .store(in: &subscriptions)
    instance.setAttributedTitle(NSAttributedString(string: item.getText().localized.firstCapitalized,
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.Regular, size: 12) as Any,
                                                    .foregroundColor: UIColor.white as Any,
                                                   ]), for: .normal)
    
    return instance
  }()
  private lazy var bgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.fillColor = traitCollection.userInterfaceStyle == .dark ? Colors.filterDisabledDark.cgColor : Colors.filterDisabledLight.cgColor
    
    return instance
  }()
  private lazy var fgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.opacity = item.isFilterEnabled ? 1 : 0
    instance.fillColor = color.cgColor
    
    return instance
  }()
  private var touchLocation: CGPoint = .zero
  private var isViewLayedOut = false
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
    
    debugPrint("\(String(describing: type(of: self))).\(#function)")
  }
  
  // MARK: - Overridden
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    if point.x > 0 && point.y > 0 {
      touchLocation = point
    }
    if view == self {
      return nil //avoid delivering touch events to the container view (self)
    } else {
      return view //the subviews will still receive touch events
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    item = nil
    filterPublisher = PassthroughSubject<SurveyFilterItem, Never>()
//    boundsPublisher = PassthroughSubject<Void, Never>()
    button.showsMenuAsPrimaryAction = false
    subscriptions.forEach { $0.cancel() }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    bgLayer.fillColor = traitCollection.userInterfaceStyle == .dark ? Colors.filterDisabledDark.cgColor : Colors.filterDisabledLight.cgColor
  }
}


// MARK: - Private
private extension SurveyFilterCell {
  @MainActor
  func setupUI() {
    isViewLayedOut = true
    backgroundColor = .clear
    contentView.addSubview(button)
    
    button.top(to: contentView)
    button.left(to: contentView)
    button.right(to: contentView, priority: .defaultLow)
    button.bottom(to: contentView)
  }
  
  @MainActor
  func updateUI() {
    // Update button
    if let image = item.getImage() {
      button.semanticContentAttribute = .forceRightToLeft
      button.setImage(image, for: .normal)
      button.adjustsImageWhenHighlighted = false
      button.imageView?.layer.masksToBounds = false
      button.imageEdgeInsets.left = padding/2
      button.imageView?.alpha = 1
      button.imageView?.layer.opacity = 1
      button.imageView?.tintColor = .white
    } else {
      button.setImage(nil, for: .normal)
      button.imageEdgeInsets.left = 0
    }
    fgLayer.opacity = item.isFilterEnabled ? 1 : 0
//    if item.isFilterEnabled {
//      fgLayer.mask = nil
//      fgLayer.opacity = 1
//    }
    button.setAttributedTitle(NSAttributedString(string: item.getText().localized.firstCapitalized,
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.Regular, size: 12) as Any,
                                                    .foregroundColor: UIColor.white as Any,
                                                   ]), for: .normal)
    
    updateLayers()
  }
  
  @objc
  func handleTap() {
    // Show menu only after highlighting
    if item.additional == .period {
      button.showsMenuAsPrimaryAction = item.isFilterEnabled
      button.menu = item.getMenu()
    }

    item.setEnabled()
    filterPublisher.send(item)
  }
  
  @MainActor
  func deselect() {
    fgLayer.add(Animations.get(property: .Opacity,
                               fromValue: 1,
                               toValue: 0,
                               duration: 0.1,
                               timingFunction: .linear,
                               delegate: self,
                               isRemovedOnCompletion: true),
//                               completionBlocks: [{ [unowned self] in self.fgLayer.opacity = 0 }]),
                forKey: nil)
    fgLayer.opacity = 0
  }
  
  func setTasks() {
    // Update button menu behaviour for period mode
    item.$isFilterEnabled
      .filter { [unowned self] _ in self.item.additional == .period }
      .sink { [unowned self] in
        self.button.showsMenuAsPrimaryAction = $0
        self.button.menu = item.getMenu()
      }
      .store(in: &subscriptions)
    
    // Send event and animate layers
    item.$isFilterEnabled
      .filter { [unowned self] in self.fgLayer.opacity.isZero && $0 }
      .sink { [unowned self] _ in
//        self.filterPublisher.send(item)
//        self.fgLayer.setAffineTransform(.identity)
        Animations.unmaskLayerCircled(layer: self.fgLayer,
                                      location: self.touchLocation,
                                      duration: 0.25,
                                      timingFunction: .easeInEaseOut,
//                                      animateOpacity: false,
                                      opacityDurationMultiplier: 0.5,
                                      delegate: self) { [weak self] in
          guard let self = self else { return }
          
          self.fgLayer.mask = nil
          self.fgLayer.opacity = 1
        }
      }
      .store(in: &subscriptions)
    
    // Animate layers - disable
    item.$isFilterEnabled
      .filter { [unowned self] in !self.fgLayer.opacity.isZero && !$0 }
      .sink { [unowned self] _ in self.deselect() }
      .store(in: &subscriptions)
    
    // Set title for selected period
    item.periodPublisher
      .filter { [unowned self] _ in self.item.additional == .period }
      .sink { [unowned self] in
        self.filterPublisher.send(item)
        self.button.setAttributedTitle(NSAttributedString(string: $0.description.localized.firstCapitalized,
                                                          attributes: [
                                                           .font: UIFont(name: Fonts.Rubik.Regular, size: 11) as Any,
                                                           .foregroundColor: UIColor.white as Any,
                                                          ]), for: .normal)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.boundsPublisher.send()
      }
      .store(in: &subscriptions)
    
    // Set updated menu with currently selected item
    item.$menu
      .filter { !$0.isNil }
      .sink { [unowned self] in self.button.menu = $0 }
      .store(in: &subscriptions)
  }
  
  func updateLayers() {
    guard !item.isNil else { return }
    
    if fgLayer.bounds.size != bounds.size {
      self.fgLayer.frame = bounds
      self.fgLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2).cgPath
    }
    if bgLayer.bounds.size != bounds.size {
      self.bgLayer.frame = bounds
      self.bgLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2).cgPath
    }
  }
}
     
extension SurveyFilterCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        }
    }
}
