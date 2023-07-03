//
//  UserSettingsEmailCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

import UIKit
import Combine

class UserSettingsEmailCell: UICollectionViewListCell {
  
  public weak var userprofile: Userprofile? {
    didSet {
      guard !userprofile.isNil else { return }
      
      setTasks()
      setupUI()
      
      // When user confirms new email
      userprofile?.$email
        .receive(on: DispatchQueue.main)
        .filter { _ in AppData.isEmailVerified }
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.textField.text = $0
        }
        .store(in: &subscriptions)
    }
  }
  ///`UI`
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      confirmSign.tintColor = AppData.isEmailVerified ? color : traitCollection.userInterfaceStyle == .dark ? .tertiaryLabel : .systemGray4
      textField.tintColor = color
    }
  }
  @Published public private(set) var scrollPublisher: CGPoint?
  public var padding: CGFloat = 8
  public var insets: UIEdgeInsets?
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private lazy var backgroundLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(roundedRect: .zero, cornerRadius: 0).cgPath
    instance.fillColor = Colors.textField(color: .white, traitCollection: traitCollection).cgColor
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let headerStack = UIStackView(arrangedSubviews: [
      headerImage,
      headerLabel,
      UIView.opaque()
    ])
    headerStack.axis = .horizontal
      headerStack.spacing = padding/2
    
    let contentStack: UIStackView = {
      let rightSpacer = UIView.opaque()
      rightSpacer.widthAnchor.constraint(equalToConstant: 8).isActive = true
      let instance = UIStackView()
      instance.layer.addSublayer(backgroundLayer)
      instance.publisher(for: \.bounds, options: .new)
        .sink { [unowned self] in self.backgroundLayer.path = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.025).cgPath }
        .store(in: &subscriptions)
      instance.addArrangedSubview(rightSpacer)
      instance.addArrangedSubview(textField)
      instance.addArrangedSubview(confirmSign)
      instance.axis = .horizontal
      instance.spacing = 0
      instance.clipsToBounds = false
  
      return instance
    }()

    let instance = UIStackView(arrangedSubviews: [
      headerStack,
      contentStack
    ])
    instance.axis = .vertical
    instance.spacing = padding

    return instance
  }()
  private lazy var textField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
//    instance.insets = UIEdgeInsets(top: 8,
//                                   left: 0,
//                                   bottom: 8,
//                                   right: 0)
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    if let userprofile = userprofile, !userprofile.email.isEmpty {
      instance.text = userprofile.email
    }
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.delegate = self
    let constraint = instance.heightAnchor.constraint(equalToConstant: 10)
    constraint.identifier = "height"
    constraint.isActive  = true
    instance.spellCheckingType = .no
    instance.autocorrectionType = .no
    instance.keyboardType = .asciiCapable
    instance.attributedPlaceholder = NSAttributedString(string: "mail_example_placeholder".localized,
                                                        attributes: [
                                                          .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any
                                                        ])
//  private lazy var textField: UnderlinedSignTextField = {
//      let instance = UnderlinedSignTextField()//lowerTextFieldTopConstant: -4)
      instance.customRightView = nil
//      instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//      instance.clearButtonMode = .always
//      instance.text = ""
//      instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .headline)
//      instance.spellCheckingType = .no
//      instance.autocorrectionType = .no
    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
    instance.delegate = self
    instance.clipsToBounds = false
    instance.layer.masksToBounds = false
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }

        self.setNeedsLayout()
        constraint.constant = max(rect.height, 40)
        self.layoutIfNeeded()
//        let constraint = instance.heightAnchor.constraint(equalToConstant: max(rect.height, 40))
//        constraint.identifier = "height"
//        constraint.isActive = true
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var confirmSign: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
    instance.accessibilityIdentifier = "chevron"
    instance.clipsToBounds = true
    instance.tintColor = AppData.isEmailVerified ? color : traitCollection.userInterfaceStyle == .dark ? .tertiaryLabel : .systemGray4
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .large)
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:))))
    
    let constraint = instance.widthAnchor.constraint(equalTo: instance.heightAnchor)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "envelope.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = .secondaryLabel
    instance.contentMode = .scaleAspectFit
//    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.text = "mailTF".localized.uppercased()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Medium, forTextStyle: .footnote)

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
  
  
  
  // MARK: - Private properties
  ///**Publishers**
  public private(set) var emailPublisher = PassthroughSubject<String, Never>()
  
  
  
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
  
        backgroundLayer.fillColor = Colors.textField(color: .white, traitCollection: traitCollection).cgColor
//          facebookTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//          instagramTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//          tiktokTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//
//          tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//          contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
//
//          guard !userprofile.isNil else { return }
//
//          setupButtons()
      }
  
    override func prepareForReuse() {
      super.prepareForReuse()
  
      emailPublisher = PassthroughSubject<String, Never>()
      scrollPublisher = headerLabel.convert(headerLabel.frame.origin, to: self)
  //    facebookPublisher = CurrentValueSubject<String?, Never>(nil)
  //    instagramPublisher = CurrentValueSubject<String?, Never>(nil)
  //    tiktokPublisher = CurrentValueSubject<String?, Never>(nil)
  //    googlePublisher = CurrentValueSubject<String?, Never>(nil)
  //    twitterPublisher = CurrentValueSubject<String?, Never>(nil)
  //    openURLPublisher = CurrentValueSubject<URL?, Never>(nil)
    }
}

// MARK: - Private
private extension UserSettingsEmailCell {
  @MainActor
  func setupUI() {
    clipsToBounds = false
    stack.place(inside: self,
                insets: insets ?? .uniform(size: padding),
                bottomPriority: .defaultLow)
  }
  
  func setTasks() {

  }
  
  @objc
  func handleIO(_ instance: UnderlinedSignTextField) {
    guard let text = instance.text else { return }
    
    instance.text = text.lowercased()
  }
  
  @objc
  func handleTap(sender: UIButton) {
    switch AppData.isEmailVerified {
    case true:
      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "checkmark.circle.fill")!,
                                                            text: "email_is_confirmed".localizedDescription,
                                                            tintColor: .systemOrange,
                                                            fontName: Fonts.Rubik.Regular,
                                                            textStyle: .headline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &subscriptions)
    case false:
      guard let text = textField.text,
            text.isValidEmail
      else { return }
      
    }
  }
}

extension UserSettingsEmailCell: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    scrollPublisher = headerLabel.convert(headerLabel.frame.origin, to: self)
    
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField,
          let text = textField.text
    else { return true }
    
    textField.hideSign()
    if !text.isValidEmail {
      textField.showSign(state: .EmailIsIncorrect)
      delay(seconds: 3) {
        guard !textField.isFirstResponder else { return }
        
        textField.hideSign()
        textField.text = Userprofiles.shared.current?.email
      }
    } else {
      guard Userprofiles.shared.current?.email != text else { return true }
      // Confirm new email
      let banner = NewPopup(padding: padding*2,
                            contentPadding: .uniform(size: padding*2))
      let content = AccountManagementPopupContent(mode: .EmailChange,
                                                  color: Colors.main)
      content.actionPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self,
                let action = $0.keys.first
          else { return }
          
          banner.dismiss()
          
          guard action == .Confirm else {
            // Revert change
            textField.text = Userprofiles.shared.current?.email
            
            return
          }
          
          self.emailPublisher.send(text)
        }
        .store(in: &banner.subscriptions)
      
      banner.setContent(content)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview() }
        .store(in: &self.subscriptions)
    }
    
    return true
  }
}

