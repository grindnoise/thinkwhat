//
//  TextCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TextCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public var text: String! {
    didSet {
      guard let text = text else { return }
      
      textView.attributedText = NSAttributedString(string: text, attributes: attributes)
      setupUI()
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  public var attributes: [NSAttributedString.Key: Any] = [:]
  public var insets: UIEdgeInsets = .uniform(size: 8)
  ///**Publishers**
  public let boundsPublisher = PassthroughSubject<CGRect, Never>()
  ///**UI**
  public var padding: CGFloat = 8
  
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
//  private let padding: CGFloat = 8
  private lazy var container: UIStackView = { UIStackView(arrangedSubviews: [textView]) }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.textContainerInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: padding)
    instance.isUserInteractionEnabled = false
    instance.backgroundColor = .clear
    instance.isEditable = false
    instance.isSelectable = false
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    //        Not working!
    //        instance.publisher(for: \UITextView.contentSize, options: .new)
    //            .receive(on: DispatchQueue.main)
    //            .filter { $0 != .zero && $0.height > 0 }
    //            .sink { [weak self] in
    //                guard let self = self, constraint.constant != $0.height else { return }
    //
    //                self.setNeedsLayout()
    //                constraint.constant = $0.height
    //                self.layoutIfNeeded()
    //            }
    //            .store(in: &subscriptions)
    
    observers.append(instance.observe(\.contentSize, options: .new) { [weak self] _, change in
      guard let self = self,
            let value = change.newValue,
//            !value.height.isZero,
//            !value.width.isZero,
            constraint.constant != value.height
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = value.height
      self.layoutIfNeeded()
//      self.boundsPublisher.send(.init(origin: .zero, size: value))
    })
    
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
  override init(frame: CGRect) {
    super.init(frame: frame)
    
//    setupUI()
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

private extension TextCell {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    container.place(inside: contentView,
                    insets: insets,
                    bottomPriority: .defaultLow)
  }
}

