//
//  PollPostedPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class PollPostedPopupContent: UIView {
  
  enum Mode { case ForceSelect, Default }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat
  private let color: UIColor
  private let сategory: Icon.Category
  private lazy var icon: Icon = {
    let instance = Icon(category: сategory, iconColor: color)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.scaleMultiplicator = 1.5
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.text = "new_poll_posted".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)

    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    label.heightAnchor.constraint(equalToConstant: 100).isActive = true
    icon.placeInCenter(of: top,
                       topInset: padding,
                       bottomInset: padding)
  
    let instance = UIStackView(arrangedSubviews: [
//      UIView.verticalSpacer(60),
      top,
      label,
    ])
    instance.axis = .vertical
    instance.spacing = 0//padding*2
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    
    return instance
  }()
  
  
  
  // MARK: - Deinitialization
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
  init(сategory: Icon.Category,
       color: UIColor,
       padding: CGFloat = 8) {
    
    self.сategory = сategory
    self.color = color
    self.padding = padding
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension PollPostedPopupContent {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
    
    delay(seconds: 1.5) { [weak self] in
      guard let self = self else { return }
      
      let pathAnim = Animations.get(property: .Path,
                                    fromValue: (self.icon.icon as! CAShapeLayer).path!,
                                    toValue: (self.icon.getLayer(.Checkmark) as! CAShapeLayer).path!.getScaledPath(size: icon.bounds.size, scaleMultiplicator: 1.8),
                                    duration: 0.4,
                                    delay: 0,
                                    repeatCount: 0,
                                    autoreverses: false,
                                    timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                    delegate: nil,
                                    isRemovedOnCompletion: false)
      self.icon.icon.add(pathAnim, forKey: nil)

      let fillAnim = Animations.get(property: .FillColor,
                                    fromValue: self.icon.iconColor,
                                    toValue: UIColor.systemGreen.cgColor,
                                    duration: 0.4,
                                    delay: 0,
                                    delegate: nil)
      self.icon.icon.add(fillAnim, forKey: nil)
      (self.icon.icon as! CAShapeLayer).fillColor = UIColor.systemGreen.cgColor
    }
  }
}

