//
//  UserInfoCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserInfoCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      label.attributedText = NSAttributedString(string: userprofile.description,
                                                attributes: attributes())
      setupUI()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 16
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      disclosureLabel,
      label
    ])
    instance.axis = .vertical
    instance.spacing = 8
    
    return instance
  }()
  private lazy var background: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.05 }
      .store(in: &subscriptions)
    
    stack.place(inside: instance,
                insets: .uniform(size: padding),
                bottomPriority: .defaultLow)
    
    return instance
  }()
  private lazy var disclosureLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "userprofile_about".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    
    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    heightConstraint.identifier = "height"
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    
    return instance
  }()
  
  
  
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
}

private extension UserInfoCell {
  @MainActor
  func setupUI() {
    background.place(inside: self,
                     insets: UIEdgeInsets(top: padding,
                                          left: padding,
                                          bottom: 0,
                                          right: padding))
  }
  
  func attributes() -> [NSAttributedString.Key: Any] {
    let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    let paragraphStyle = NSMutableParagraphStyle()
    if #available(iOS 15.0, *) {
      paragraphStyle.usesDefaultHyphenation = true
    } else {
      paragraphStyle.hyphenationFactor = 1
    }
    return [
      .font: font as Any,
      .foregroundColor: UIColor.label,
      .paragraphStyle: paragraphStyle
    ]
  }
}



