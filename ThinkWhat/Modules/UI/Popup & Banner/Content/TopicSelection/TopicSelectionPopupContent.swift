//
//  TopicSelectionPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicSelectionPopupContent: UIView {
  enum Mode { case ForceSelect, Default }
 
  // MARK: - Public properties
  public let topicPublisher = PassthroughSubject<Topic?, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let mode: Mode
  private var topic: Topic? {
    didSet {
      guard let topic = topic else { return }
      
      tagCapsule.iconCategory = topic.iconCategory
      tagCapsule.text = topic.title
      tagCapsule.color = topic.tagColor
      UIView.animate(withDuration: 0.2) { [unowned self] in
        if #available(iOS 15, *) {
          self.confirmButton.configuration?.baseBackgroundColor = topic.tagColor
        } else {
          self.confirmButton.backgroundColor = topic.tagColor
        }
      }
    }
  }
  ///**UI**
  private let padding: CGFloat
  private let color: UIColor
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    top.heightAnchor.constraint(equalToConstant: 60).isActive = true
    tagCapsule.placeInCenter(of: top)//,
//                        topInset: padding*2,
//                        bottomInset: padding)
    
    let bottom = UIView.opaque()
    let buttonsStack = UIStackView(arrangedSubviews: [
      confirmButton,
//      cancelButton
    ])
    if mode == .Default {
      buttonsStack.addArrangedSubview(cancelButton)
    }
    buttonsStack.distribution = .fillEqually
    buttonsStack.contentMode = .left
    buttonsStack.axis = .horizontal
    buttonsStack.spacing = 4
    buttonsStack.placeInCenter(of: bottom,
                        topInset: padding,
                        bottomInset: padding)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      collectionView,
      bottom
    ])
    instance.axis = .vertical
    instance.spacing = padding
    bottom.translatesAutoresizingMaskIntoConstraints = false
    bottom.heightAnchor.constraint(equalTo: top.heightAnchor).isActive = true
    
    return instance
  }()
  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: "new_poll_survey_topic".localized.uppercased(),
                                                         padding: 4,
                                                         color: Colors.Logo.Flame.rawValue,
                                                         font: UIFont(name: Fonts.Bold, size: 20)!,
                                                         iconCategory: .Logo) }()
  private lazy var label: UIStackView = {
    let label = InsetLabel()
    label.font = UIFont(name: Fonts.Bold, size: 20)//.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)
    label.text = "new_poll_survey_topic".localized.uppercased()
    label.textColor = .white
    label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

    let icon = UIImageView(image: UIImage(systemName: "chart.bar.doc.horizontal.fill",
                                          withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
    icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1/1).isActive = true
    icon.tintColor = .white
    icon.contentMode = .center

    let opaque = UIView.opaque()
    opaque.widthAnchor.constraint(equalToConstant: padding/2).isActive = true

    let instance = UIStackView(arrangedSubviews: [
      opaque,
      icon,
      label
    ])
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: label.font)).isActive = true
    instance.axis = .horizontal
    instance.spacing = padding/2
    instance.backgroundColor = color
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    return instance
  }()
  private lazy var collectionView: TopicsCollectionView = {
    let instance = TopicsCollectionView(mode: .Selection)
    let constraint = instance.heightAnchor.constraint(equalToConstant: 10)
    constraint.isActive = true
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && constraint.constant != $0.height }
      .sink { [unowned self] in
        self.setNeedsLayout()
        constraint.constant = min($0.height, UIScreen.main.bounds.height*0.5)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    instance.topicSelected
      .sink { [unowned self] in self.topic = $0}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var confirmButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = color
      config.attributedTitle = AttributedString("select".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "confirm".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: color as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  private lazy var cancelButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets = .uniform(size: 0)
      config.attributedTitle = AttributedString("cancel".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.secondaryLabel as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "cancel".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: UIColor.secondaryLabel as Any
                                                     ]),
                                  for: .normal)
    }
    
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
  init(mode: Mode,
       color: UIColor,
       padding: CGFloat = 8) {
    
    
    self.mode = mode
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

private extension TopicSelectionPopupContent {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  @objc
  func handleTap(sender: UIButton) {
    topicPublisher.send(topic)
    topicPublisher.send(completion: .finished)
  }
}
