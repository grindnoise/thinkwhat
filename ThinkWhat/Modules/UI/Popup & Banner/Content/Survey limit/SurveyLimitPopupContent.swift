//
//  SurveyLimitPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyLimitPopupContent: UIView {
  enum Mode { case ForceSelect, Default }
 
  // MARK: - Public properties
  public let limitPublisher = PassthroughSubject<Int, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let mode: Mode
  private var limit: Int {
    didSet {
//      textField.text = limit.formattedWithSeparator
    }
  }
  ///**UI**
  private let padding: CGFloat
  private let color: UIColor
  private var isBannerOnScreen = false
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    top.heightAnchor.constraint(equalToConstant: 60).isActive = true
    tagCapsule.placeInCenter(of: top)//,
//                        topInset: padding*2,
//                        bottomInset: padding)
    
    let middle = UIView.opaque()
    textField.placeXCentered(inside: middle,
                             widthMultiplier: 0.6,
                             topInset: padding,
                             bottomInset: padding)
    let middle2 = UIView.opaque()
    descriptionLabel.place(inside: middle2, insets: .init(top: padding*4, left: padding, bottom: padding, right: padding))
    let bottom = UIView.opaque()
    let buttonsStack = UIStackView(arrangedSubviews: [
      confirmButton,
    ])
    if mode == .Default {
      buttonsStack.addArrangedSubview(cancelButton)
    }
    buttonsStack.distribution = .fillEqually
    buttonsStack.contentMode = .left
    buttonsStack.axis = .horizontal
    buttonsStack.spacing = 4
    buttonsStack.placeInCenter(of: bottom,
                        topInset: padding,
                        bottomInset: padding)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      middle,
//      middle2,
      bottom
    ])
    instance.axis = .vertical
    instance.spacing = padding*4
    bottom.translatesAutoresizingMaskIntoConstraints = false
    bottom.heightAnchor.constraint(equalTo: top.heightAnchor).isActive = true
    
    return instance
  }()
  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: "new_poll_limit".localized.uppercased(),
                                                         padding: 4,
                                                         color: color,
                                                         font: UIFont(name: Fonts.Bold, size: 20)!,
                                                         iconCategory: .Speedometer) }()
  private lazy var label: UIStackView = {
    let label = InsetLabel()
    label.font = UIFont(name: Fonts.Bold, size: 20)//.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)
    label.text = "new_poll_topic".localized.uppercased()
    label.textColor = .white
    label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

    let icon = UIImageView(image: UIImage(systemName: "chart.bar.doc.horizontal.fill",
                                          withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
    icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: 1/1).isActive = true
    icon.tintColor = .white
    icon.contentMode = .center

    let opaque = UIView.opaque()
    opaque.widthAnchor.constraint(equalToConstant: padding/2).isActive = true

    let instance = UIStackView(arrangedSubviews: [
      opaque,
      icon,
      label
    ])
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: label.font)).isActive = true
    instance.axis = .horizontal
    instance.spacing = padding/2
    instance.backgroundColor = color
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    return instance
  }()
  private lazy var descriptionLabel: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.attributedText = NSAttributedString(string: "new_poll_limit_hint".localized, attributes: attributes())
//    let constraint = instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: instance.font))
//    constraint.identifier = "heightAnchor"
//    constraint.isActive = true
    
    return instance
  }()
  private lazy var textField: UITextField = {
    let instance = UITextField()
    instance.delegate = self
    instance.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    instance.textAlignment = .center
    instance.text = limit.formattedWithSeparator
    instance.tintColor = color
    instance.keyboardType = .numberPad
    instance.font = UIFont.scaledFont(fontName: Fonts.Extrabold, forTextStyle: .title1)
    instance.backgroundColor = .systemGray.withAlphaComponent(0.1)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height * 0.05}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var confirmButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = color
      config.attributedTitle = AttributedString("ready".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "ready".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: color as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  private lazy var cancelButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets = .uniform(size: 0)
      config.attributedTitle = AttributedString("cancel".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.secondaryLabel as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "cancel".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: UIColor.secondaryLabel as Any
                                                     ]),
                                  for: .normal)
    }
    
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
  init(limit: Int,
       mode: Mode,
       color: UIColor,
       padding: CGFloat = 8) {
    
    self.limit = limit
    self.mode = mode
    self.color = color
    self.padding = padding
    
    super.init(frame: .zero)
    
    setupUI()
    
    textField.becomeFirstResponder()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    

  }
}

private extension SurveyLimitPopupContent {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
    
//    publisher(for: \.bounds)
//      .sink { [weak self] in
//        guard let self = self else { return }
//
//        let height = self.descriptionLabel.text!.height(withConstrainedWidth: $0.width,
//                                                        font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)!)
//
//        guard let constraint = self.descriptionLabel.getConstraint(identifier: "heightAnchor"),
//              constraint.constant != height
//        else { return }
//
//        self.setNeedsLayout()
//        constraint.constant = height
//        self.layoutIfNeeded()
//      }
//      .store(in: &subscriptions)
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  @objc
  func handleTap(sender: UIButton) {
    let minLength = ModelProperties.shared.minVotes!
    
    guard limit >= minLength,
          !isBannerOnScreen
    else {
      isBannerOnScreen = true
      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                            text: "minimum_votes".localized + String(describing: minLength),
                                                            tintColor: .systemOrange,
                                                            fontName: Fonts.Semibold,
                                                            textStyle: .headline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: true,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview(); self.isBannerOnScreen = false }
        .store(in: &self.subscriptions)
      
      return
    }
    
    endEditing(true)
    if sender == confirmButton {
      limitPublisher.send(limit)
      limitPublisher.send(completion: .finished)
    } else {
      
    }
  }
  
  func attributes() -> [NSAttributedString.Key: Any] {
    let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.firstLineHeadIndent = font!.pointSize + padding
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
  
  @objc
  func textFieldDidChange(textField: UITextField) {
    guard let text = textField.text,
          let int = Int(text.replacingOccurrences(of: " ", with: ""))
    else { return }
    
    limit = int
    textField.text = limit.formattedWithSeparator
  }
}

extension SurveyLimitPopupContent: UITextFieldDelegate {
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
//    let minLength = ModelProperties.shared.minVotes!
//
//    guard limit > minLength,
//          !isBannerOnScreen
//    else {
//      isBannerOnScreen = true
//      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
//                                                            text: "minimum_votes".localized + String(describing: minLength),
//                                                            tintColor: .systemOrange,
//                                                            fontName: Fonts.Semibold,
//                                                            textStyle: .headline,
//                                                            textAlignment: .natural),
//                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                             isModal: false,
//                             useContentViewHeight: true,
//                             shouldDismissAfter: 2)
//      banner.didDisappearPublisher
//        .sink { _ in banner.removeFromSuperview(); self.isBannerOnScreen = false }
//        .store(in: &self.subscriptions)
//
//      return false
//    }
    
    return true
  }
}
