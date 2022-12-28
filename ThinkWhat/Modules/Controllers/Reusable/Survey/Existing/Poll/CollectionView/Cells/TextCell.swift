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
    }
  }
  public var attributes: [NSAttributedString.Key: Any] = [:]
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var container: UIStackView = { UIStackView(arrangedSubviews: [textView]) }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.textContainerInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: 0)
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
            value.height > 0,
            constraint.constant != value.height
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = value.height
      self.layoutIfNeeded()
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
    
    setupUI()
    setTasks()
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
                    insets: .uniform(size: 8),//UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8),
                    bottomPriority: .defaultLow)
    
    //        setNeedsLayout()
    //        layoutIfNeeded()
  }
  
  func setTasks() {
    //        tasks.append( Task {@MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
    //                guard let self = self else { return }
    //
    //
    //            }
    //        })
  }
}

