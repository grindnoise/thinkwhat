//
//  EmptySubscriptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class EmptySubscriptionsView: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 16
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Semibold,
                                      forTextStyle: .title3)
    instance.text = "zero_subscriptions".localized
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    instance.numberOfLines = 0

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
  init() {
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

private extension EmptySubscriptionsView {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    label.place(inside: self,
                insets: .uniform(size: padding))
  }
  
  @MainActor
  func updateUI() {
    
  }
}

