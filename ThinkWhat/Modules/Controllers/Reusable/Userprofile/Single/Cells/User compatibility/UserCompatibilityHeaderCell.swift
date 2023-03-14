//
//  UserCompatibilityHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserCompatibilityHeaderCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      setupUI()
      compatibilityView.username = userprofile.firstNameSingleWord
      
      userprofile.compatibilityPublisher//.shareReplay()
        .receive(on: DispatchQueue.main)
        .sink { error in
          print(error)
        } receiveValue: { [weak self] in
          guard let self = self else { return }
          
          self.compatibilityView.percent = Double($0.percent)
//          self.compatibilityView.animate(duration: 1, delay: 0.5)
        }
        .store(in: &subscriptions)
    }
  }
  //Publishers
  @Published public var showDetails = false
  //UI
  public var color: UIColor = .clear {
    didSet {
      compatibilityView.color = color
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 16
  private lazy var hintButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "questionmark",
                              withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                      for: .normal)
    instance.tintColor = .secondaryLabel
    instance.addTarget(self, action: #selector(self.hintTapped), for: .touchUpInside)
    
    return instance
  }()
  private lazy var compatibilityView: CompatibilityView = {
    let instance = CompatibilityView()
    instance.heightAnchor.constraint(equalToConstant: 100).isActive = true
    instance.$showDetails
      .sink { [unowned self] in self.showDetails = $0 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      stack,
      compatibilityView
    ])
    instance.axis = .vertical
    instance.spacing = padding
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [
      label,
      UIView.opaque(),
      hintButton
    ])
    stack.axis = .horizontal
    
    let instance = UIStackView(arrangedSubviews: [
      stack,
      compatibilityView
    ])
    instance.axis = .vertical
    instance.spacing = padding
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "userprofile_compatibility".localized.uppercased()
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

private extension UserCompatibilityHeaderCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    stack.place(inside: self,
                insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding),
                bottomPriority: .defaultLow)
  }
  
  @objc
  func hintTapped() {
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                          text: "userprofile_сompatibility_hint",
                                                          tintColor: .clear,
                                                          fontName: Fonts.Regular,
                                                          textStyle: .headline,
                                                          textAlignment: .natural),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
}


