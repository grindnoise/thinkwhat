//
//  CommentHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentSupplementaryCell: UICollectionReusableView {
  
  // MARK: - Override
  //    override var isSelected: Bool { didSet { updateAppearance() }}
  
  // MARK: - Public properties
  //  public var callback: (() -> ())?//Closure?//(() -> Void)?
  public let tapPublisher = PassthroughSubject<Bool, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var label: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.isUserInteractionEnabled = true
    instance.translatesAutoresizingMaskIntoConstraints = false
    
    let label = UILabel()
    label.accessibilityIdentifier = "label"
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap)))
    label.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote)
    label.text = "add_comment".localized
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    label.backgroundColor = .clear
    
    let constraint = label.heightAnchor.constraint(equalToConstant: "add_comment".height(withConstrainedWidth: 1000, font: label.font))
    constraint.identifier = "height"
    constraint.isActive = true
    
    instance.addSubview(label)
    
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
      label.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
      label.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
      instance.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
    ])
    
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
    return instance
  }()
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private methods
  private func setupUI() {
    label.place(inside: self,
                insets: UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0),
                bottomPriority: .defaultLow)
  }
  
  @objc
  private func onTap() {
    tapPublisher.send(true)
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    label.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
    guard let instance = label.getSubview(type: UILabel.self, identifier: "label"),
          let constraint = instance.getConstraint(identifier: "height")
    else { return }
    
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote)
    setNeedsLayout()
    constraint.constant = "add_comment".height(withConstrainedWidth: 1000, font: instance.font)
    layoutIfNeeded()
  }
}
