//
//  HelpPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import CoreData

class PopupContent: UIView {
  
  
  
  // MARK: - Public properties
  public private(set) var content: UIView? {
    didSet {
      //            guard let content = content else { return }
      
    }
  }
  public var buttonTitle: String {
    didSet {
      if #available(iOS 15, *) {
        guard !actionButton.configuration.isNil else { return }
        let attrString = AttributedString(buttonTitle.localized.uppercased(), attributes: AttributeContainer([
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.white
        ]))
        actionButton.configuration!.attributedTitle = attrString
      } else {
        let attrString = NSMutableAttributedString(string: buttonTitle.localized.uppercased(), attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        actionButton.setAttributedTitle(attrString, for: .normal)
      }
    }
  }
  
  //Publishers
  public let exitPublisher = CurrentValueSubject<Bool?, Never>(nil)
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  public var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  
  //UI
  private weak var parent: Popup?
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.alpha = 1
    instance.numberOfLines = 0
    instance.textAlignment = .center
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title2)
    instance.translatesAutoresizingMaskIntoConstraints = false
    
    if !fixedSize, content.isNil {
      instance.publisher(for: \.bounds, options: .new)
        .sink { [weak self] rect in
          guard let self = self else { return }
          
          self.parent?.onContainerHeightChange(self.topContainer.bounds.height +
                                               instance.text!.height(withConstrainedWidth: rect.width, font: instance.font) +
                                               self.bottomContainer.bounds.height +
                                               self.verticalStackView.spacing * CGFloat(self.verticalStackView.arrangedSubviews.count - 1))
        }
        .store(in: &subscriptions)
    }
    
    return instance
  }()
  private lazy var verticalStackView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [topContainer, middleContainer, bottomContainer])
    instance.axis = .vertical
    instance.spacing = spacing
    
    topContainer.translatesAutoresizingMaskIntoConstraints = false
    bottomContainer.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      topContainer.heightAnchor.constraint(equalToConstant: 75),//equalTo: instance.heightAnchor, multiplier: 0.2),
      bottomContainer.heightAnchor.constraint(equalToConstant: 50),//equalTo: instance.heightAnchor, multiplier: 0.075),
    ])
    
    if !fixedSize, let content = content {
      if let collectionView = content as? UICollectionView {
        collectionView.publisher(for: \.contentSize)
          .filter { $0 != .zero }
          .sink { [weak self] size in
            guard let self = self else { return }
            
            self.parent?.onContainerHeightChange(self.topContainer.bounds.height +
                                                 size.height +
                                                 self.bottomContainer.bounds.height +
                                                 instance.spacing * CGFloat(instance.arrangedSubviews.count - 1))
          }
          .store(in: &subscriptions)
      }
    }
    
    return instance
  }()
  private lazy var icon: Icon = {
    let instance = Icon()
    instance.backgroundColor = .clear
    instance.isRounded = false
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.scaleMultiplicator = 1
    instance.iconColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    instance.category = iconCategory ?? .Null
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView()
    if !image.isNil {
      instance.image = image
      instance.contentMode = .scaleAspectFit
    } else if !systemImage.isNil {
      instance.contentMode = .center
      instance.publisher(for: \.bounds, options: .new)
        .sink { [weak self] rect in
          guard let self = self,
                let systemImage = self.systemImage
          else { return }
          
          instance.setImage(UIImage(systemName: systemImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*1.0))!)
        }
        .store(in: &subscriptions)
    }
    instance.backgroundColor = .clear
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    instance.tintColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    
    
    return instance
  }()
  private lazy var topContainer: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    
    if iconCategory.isNil {
      instance.addSubview(imageView)
      imageView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        imageView.topAnchor.constraint(equalTo: instance.topAnchor),
        imageView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        imageView.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
      ])
    } else {
      instance.addSubview(icon)
      icon.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        icon.topAnchor.constraint(equalTo: instance.topAnchor),
        icon.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        icon.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
      ])
    }
    
    return instance
  }()
  private lazy var middleContainer: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    
    if content.isNil {
      instance.addSubview(label)
      label.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: instance.topAnchor),
        label.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        label.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
        label.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
      ])
    } else {
      content!.addEquallyTo(to: instance)
      
      return instance
    }
    
    //        instance.publisher(for: \.bounds)
    //            .sink { rect in
    //                instance.cornerRadius = rect.width * 0.05
    //            }
    //            .store(in: &subscriptions)
    //
    return instance
  }()
  private lazy var actionButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self, action: #selector(self.close), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      let attrString = AttributedString(buttonTitle.localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.attributedTitle = attrString
      config.baseBackgroundColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large
      instance.configuration = config
      instance.publisher(for: \.bounds, options: .new)
        .sink { rect in
          instance.cornerRadius = rect.height/2.25
        }
        .store(in: &subscriptions)
    } else {
      let attrString = NSMutableAttributedString(string: buttonTitle.localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ])
      
      instance.titleEdgeInsets.left = 20
      instance.titleEdgeInsets.right = 20
      instance.setAttributedTitle(attrString, for: .normal)
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: buttonTitle.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2)!))
      constraint.identifier = "width"
      constraint.isActive = true
      
      instance.publisher(for: \.bounds, options: .new)
        .sink { [weak self] rect in
          instance.cornerRadius = rect.height/2.25
          
          guard let self = self,
                let constraint = instance.getConstraint(identifier: "width")
          else { return }
          
          self.setNeedsLayout()
          constraint.constant = self.buttonTitle.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + instance.titleEdgeInsets.left + instance.titleEdgeInsets.right
          self.layoutIfNeeded()
        }
        .store(in: &subscriptions)
    }
    
    return instance
  }()
  private lazy var bottomContainer: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.addSubview(actionButton)
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      actionButton.topAnchor.constraint(equalTo: instance.topAnchor),
      actionButton.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
      actionButton.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
    ])
    
    return instance
  }()
  
  private let color: UIColor
  private var iconCategory: Icon.Category?
  private var image: UIImage?
  private var systemImage: String?
  private let spacing: CGFloat
  private let fixedSize: Bool
  
  
  
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
  //    init(parent: Popup, image: UIImage? = nil, iconCategory: Icon.Category? = nil, text: String? = nil, content: UIView? = nil) {
  //        self.parent = parent
  //
  //        super.init(frame: .zero)
  //
  //        self.image = image
  //        self.iconCategory = iconCategory
  //        self.content = content
  //        self.label.text = text
  //
  //        setupUI()
  //    }
  //
  init(parent: Popup,
       color: UIColor = Constants.UI.Colors.System.Red.rawValue,
       systemImage: String,
       content: UIView? = nil,
       text: String? = nil,
       buttonTitle: String,
       fixedSize: Bool = true,
       spacing: CGFloat = 16) {
    self.color = color
    self.parent = parent
    self.fixedSize = fixedSize
    self.buttonTitle = buttonTitle
    self.spacing = spacing
    
    super.init(frame: .zero)
    
    self.content = content
    self.systemImage = systemImage
    self.label.text = text
    
    setupUI()
  }
  
  init(parent: Popup,
       color: UIColor = Constants.UI.Colors.System.Red.rawValue,
       iconCategory: Icon.Category,
       content: UIView? = nil,
       text: String? = nil,
       buttonTitle: String,
       fixedSize: Bool = true,
       spacing: CGFloat = 16) {
    self.parent = parent
    self.color = color
    self.fixedSize = fixedSize
    self.buttonTitle = buttonTitle
    self.spacing = spacing
    
    super.init(frame: .zero)
    
    self.content = content
    self.iconCategory = iconCategory
    self.label.text = text
    
    setupUI()
  }
  
  init(parent: Popup,
       color: UIColor = Constants.UI.Colors.System.Red.rawValue,
       image: UIImage,
       content: UIView? = nil,
       text: String? = nil,
       buttonTitle: String,
       fixedSize: Bool = true,
       spacing: CGFloat = 16) {
    self.color = color
    self.parent = parent
    self.fixedSize = fixedSize
    self.buttonTitle = buttonTitle
    self.spacing = spacing
    
    super.init(frame: .zero)
    
    self.content = content
    self.image = image
    self.content = content
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }
  
  // MARK: - Private methods
  private func setupUI() {
    verticalStackView.addEquallyTo(to: self)
  }
  
  @objc
  private func close() {
    exitPublisher.send(true)
    parent?.dismiss()
  }
  
  
  
  // MARK: - Public methods
  //    func setButtonTitle(title: String) {
  //        butt
  //    }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if !image.isNil || !systemImage.isNil {
      imageView.tintColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    } else {
      icon.setIconColor(color)//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED)
    }
    
    if #available(iOS 15, *) {
      guard !actionButton.configuration.isNil else { return }
      actionButton.configuration?.baseBackgroundColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    } else {
      actionButton.backgroundColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
  }
}
