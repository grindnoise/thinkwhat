//
//  AccountManagementCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AccountManagementCell: UICollectionViewListCell {
  
  enum Mode: String {
    case Logout = "logout"
    case Delete = "delete_account"
  }
  
  // MARK: - Public properties
  ///**Publishers**
  public private(set) var actionPublisher = PassthroughSubject<Mode, Never>()
  ///`Logic`
  public var mode: Mode = .Logout {
    didSet {
      updateUI()
    }
  }
  ///`UI`
  public var padding: CGFloat = 8 {
    didSet {
      updateUI()
    }
  }
  public var color: UIColor = .systemBlue
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private lazy var button: UIButton = {
    let instance = UIButton()
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets.top = 0
      config.contentInsets.bottom = 0
      config.contentInsets.leading = 0
      config.imagePlacement = .trailing
      config.imagePadding = 8.0
      config.buttonSize = .large
      
      instance.configuration = config
    } else {
      instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : .label
      instance.imageEdgeInsets.left = 8
      instance.contentEdgeInsets.top = 0
      instance.contentEdgeInsets.bottom = 0
      instance.contentEdgeInsets.left = 0
      instance.semanticContentAttribute = .forceRightToLeft
    }
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView()
    instance.contentMode = .left
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 1/1).isActive = true
    imageView.placeInCenter(of: opaque)
    
    let instance = UIStackView(arrangedSubviews: [
      button,
      UIView.opaque(),
      opaque
    ])
    instance.axis = .horizontal
    
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
    
    setupUI()
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

private extension AccountManagementCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    stack.place(inside: self)
  }
  
  @MainActor
  func updateUI() {
    guard let image = UIImage(systemName: (mode == .Logout ? "rectangle.portrait.and.arrow.forward" : "trash")) else { return }
    
    let string = (mode == .Logout ? "logout" : "delete_account").localized
    let color: UIColor = mode == .Logout ? .label : .systemRed
    imageView.tintColor = color
    imageView.image = image
    
    if #available(iOS 15, *) {
      let attrString = AttributedString(string,
                                        attributes: AttributeContainer([
                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                          .foregroundColor: color
                                        ]))
      button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.foregroundColor = color
        return outgoing
      }
      button.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in color }
//      button.configuration?.image = image
      button.configuration?.attributedTitle = attrString
    } else {
      let attrString = NSMutableAttributedString(string: string,
                                                 attributes: [
                                                  .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                  .foregroundColor: color
                                                 ])
//      button.setImage(image, for: .normal)
      button.setAttributedTitle(attrString, for: .normal)
//      button.imageView?.tintColor = color
    }
  }
  
  @objc
  func handleTap() {
    let banner = NewPopup(padding: padding*2,
                          contentPadding: .uniform(size: padding*2))
    let content = AccountManagementPopupContent(mode: mode,
                                               color: mode == .Logout ? color : .systemRed)
    content.actionPublisher
      .sink { [weak self] in
        guard let self = self,
              let action = $0.keys.first,
              let mode = $0.values.first
        else { return }
        
        banner.dismiss()
        
        guard action == .Confirm else { return }
        
        self.actionPublisher.send(mode)
      }
      .store(in: &banner.subscriptions)
    
    banner.setContent(content)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
  }
}
