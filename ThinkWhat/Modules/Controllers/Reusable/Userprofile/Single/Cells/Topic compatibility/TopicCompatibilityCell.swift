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
      guard let compatibility = compatibility else { return }
      
      setupUI()
    }
  }
  //Publishers

  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      label
    ])
    instance.axis = .horizontal
    instance.spacing = padding
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = compatibility.topic.tagColor
    instance.text = compatibility.topic.title.localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    constraint.identifier = "height"
    constraint.priority = .defaultHigh
    constraint.isActive = true
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
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
                insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding),
                bottomPriority: .defaultLow)
  }
  
//  @objc
//  func hintTapped() {
//    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
//                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
//                                                          text: "userprofile_сompatibility_hint",
//                                                          tintColor: .clear,
//                                                          fontName: Fonts.Regular,
//                                                          textStyle: .headline,
//                                                          textAlignment: .natural),
//                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                           isModal: false,
//                           useContentViewHeight: true,
//                           shouldDismissAfter: 2)
//    banner.didDisappearPublisher
//      .sink { _ in banner.removeFromSuperview() }
//      .store(in: &self.subscriptions)
//  }
}


