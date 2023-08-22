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
  // MARK: - Public properties
  public let filterPublisher = PassthroughSubject<SurveyFilterItem, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var item: SurveyFilterItem! {
    didSet {
      guard !item.isNil else { return }
      
//      item.$isFilterEnabled
//        .sink { [unowned self] in button.backgroundColor = $0 ? Colors.filterEnabled : Colors.filterDisabled }
//        .store(in: &subscriptions)
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
                                                        .font: UIFont(name: Fonts.Rubik.Medium, size: 11) as Any,
                                                        .foregroundColor: UIColor.white as Any,
                                                       ]), for: .normal)
    
    return instance
  }()
  private lazy var bgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.fillColor = Colors.filterDisabled.cgColor

    return instance
  }()
  private lazy var fgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.opacity = item.isFilterEnabled ? 1 : 0
    instance.fillColor = Colors.filterEnabled.cgColor
    
    return instance
  }()
  private var touchLocation: CGPoint = .zero
  
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
  
  // MARK: - Public methods
  @MainActor
  public func setupUI(item: SurveyFilterItem) {
    self.item = item
    
    backgroundColor = .clear
    contentView.addSubview(button)
    
    button.top(to: contentView)
    button.left(to: contentView)
    button.right(to: contentView, priority: .defaultLow)
    button.bottom(to: contentView)
    
    // Update button menu behaviour for period mode
    item.$isFilterEnabled
      .filter { [unowned self] _ in self.item.mode == .period }
      .sink { [unowned self] in
        self.button.showsMenuAsPrimaryAction = $0
        self.button.menu = item.getMenu()
      }
      .store(in: &subscriptions)
    
    // Send event and animate layers
    item.$isFilterEnabled
      .filter { [unowned self] in self.fgLayer.opacity.isZero && $0 }
      .sink { [unowned self] _ in
        self.filterPublisher.send(item)
//        self.fgLayer.setAffineTransform(.identity)
        Animations.unmaskLayerCircled(layer: self.fgLayer,
                                      location: self.touchLocation,
                                      duration: 0.275,
                                      opacityDurationMultiplier: 0.5,
                                      delegate: self) {  }
      }
      .store(in: &subscriptions)
    
    // Animate layers - disable
    item.$isFilterEnabled
      .filter { [unowned self] in !self.fgLayer.opacity.isZero && !$0 }
      .sink { [unowned self] _ in self.deselect() }
      .store(in: &subscriptions)
    
    // Set title for selected period
    item.$period
      .filter { [unowned self] in self.item.mode == .period && !$0.isNil }
      .sink { [unowned self] in
        self.filterPublisher.send(item)
        self.button.setAttributedTitle(NSAttributedString(string: $0!.description.localized.firstCapitalized,
                                                          attributes: [
                                                           .font: UIFont(name: Fonts.Rubik.Medium, size: 11) as Any,
                                                           .foregroundColor: UIColor.white as Any,
                                                          ]), for: .normal)
      }
      .store(in: &subscriptions)
    
    // Set updated menu with currently selected item
    item.$menu
      .filter { !$0.isNil }
      .sink { [unowned self] in self.button.menu = $0 }
      .store(in: &subscriptions)
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
}


// MARK: - Private
private extension SurveyFilterCell {
  @objc
  func handleTap() {
    // Show menu only after highlighting
    if item.mode == .period {
      button.showsMenuAsPrimaryAction = item.isFilterEnabled
      button.menu = item.getMenu()
    }
    
    item.setEnabled()
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
    fgLayer.add(Animations.get(property: .Scale,
                               fromValue: fgLayer.affineTransform(),
                               toValue: fgLayer.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5)),//0.1,
                               duration: 0.25,
                               timingFunction: .linear,
                               delegate: self,
                               isRemovedOnCompletion: true),
//                               completionBlocks: [{ [unowned self] in self.fgLayer.setAffineTransform(CGAffineTransform.identity) }]),
                forKey: nil)
    fgLayer.setAffineTransform(CGAffineTransform(scaleX: 0.5, y: 0.5))
    delay(seconds: 0.3) {[weak self] in
      guard let self = self else { return }
      
      self.fgLayer.setAffineTransform(.identity)
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
// 0504071 2.1 гр 5
