//
//  TopicCompatibilityCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicCompatibilityCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var compatibility: TopicCompatibility! {
    didSet {
      guard !compatibility.isNil else { return }
      
      setupUI()
    }
  }
  //Publishers
  public let disclosurePublisher = PassthroughSubject<TopicCompatibility, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    let instance = UIStackView(arrangedSubviews: [
      tagCapsule,
      UIView.opaque(),
      rightButton,
    ])
    instance.axis = .horizontal
    instance.spacing = padding/2
    
    return instance
  }()
  private lazy var tagCapsule: TagCapsule = {
    TagCapsule(text: "\(compatibility.topic.title.uppercased()): \(compatibility.percent)%",
                              padding: padding,
                              textPadding: .init(top: padding/2, left: 0, bottom: padding/2, right: 0),
                              color: compatibility.topic.tagColor,
                              font: UIFont(name: Fonts.Rubik.Medium, size: 11)!,
                              isShadowed: false,
                              iconCategory: compatibility.topic.iconCategory,
                              image: nil)
  }()
  private lazy var rightButton: UIButton = {
    let instance = UIButton()
    instance.imageEdgeInsets.left = padding/4
    instance.semanticContentAttribute = .forceRightToLeft
    instance.adjustsImageWhenHighlighted = false
    instance.addTarget(self, action: #selector(self.disclose), for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: String(describing: compatibility.surveys.count), attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)!,
      .foregroundColor: compatibility.topic.tagColor
    ]), for: .normal)
    instance.tintColor = compatibility.topic.tagColor
    instance.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    instance.setImage(UIImage(systemName: ("chevron.right"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
  
  //    override func prepareForReuse() {
  //        super.prepareForReuse()
  //
  //        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
  //        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  //        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  //    }
}

private extension TopicCompatibilityCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    stack.place(inside: self,
                insets: .init(top: padding, left: 0, bottom: padding, right: 0),
                bottomPriority: .defaultLow)
  }
  
  @objc
  func disclose() {
    disclosurePublisher.send(compatibility)
  }
}


