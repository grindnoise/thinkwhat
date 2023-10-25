//
//  CurrentUserSocialMediaCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsSocialMediaCell: UICollectionViewListCell {
  
  enum Mode: Int, CaseIterable {
    case Instagram, Facebook, Twitter, TikTok
  }
  
  // MARK: - Public properties
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      setupUI()
    }
  }
  public var mode: Mode!
  ///`Publishers`
  public let urlStringPublisher = PassthroughSubject<String, Never>()
  public var openURLPublisher = PassthroughSubject<URL, Never>()
  public let keyboardWillAppear = PassthroughSubject<Bool, Never>()
  ///`UI`
  public var color: UIColor = Constants.UI.Colors.System.Red.rawValue {
    didSet {
      disclosureIndicator.tintColor = color
      textField.tintColor = color
    }
  }
  @Published public private(set) var scrollPublisher: CGPoint?
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private let padding: CGFloat = 8
  private lazy var backgroundLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(roundedRect: .zero, cornerRadius: 0).cgPath
    instance.fillColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection).cgColor
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
//    let leftSpacer = UIView.opaque()
//    leftSpacer.widthAnchor.constraint(equalToConstant: 4).isActive = true
    let rightSpacer = UIView.opaque()
    rightSpacer.widthAnchor.constraint(equalToConstant: 8).isActive = true
    let instance = UIStackView()
    instance.layer.addSublayer(backgroundLayer)
    instance.publisher(for: \.bounds, options: .new)
      .sink { [unowned self] in self.backgroundLayer.path = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.025).cgPath }
      .store(in: &subscriptions)
    instance.addArrangedSubview(opaque)
    instance.addArrangedSubview(textField)
    instance.addArrangedSubview(disclosureIndicator)
    instance.addArrangedSubview(rightSpacer)
    instance.axis = .horizontal
    instance.spacing = userprofile.isCurrent ? padding/2 : 0
    instance.clipsToBounds = false

    opaque.translatesAutoresizingMaskIntoConstraints = false
    opaque.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor).isActive = true

    if userprofile.isCurrent {
      icon.placeInCenter(of: opaque, heightMultiplier: 0.75)
    } else {
      icon.placeLeadingYCentered(inside: opaque)
      icon.widthAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 0.75).isActive = true
    }

    return instance
  }()
//  private lazy var stack: UIStackView = {
//      let opaque = UIView.opaque()
//      let instance = UIStackView(arrangedSubviews: [
//        icon,
//        textField,
//        disclosureIndicator
//      ])
//      instance.axis = .horizontal
//      instance.spacing = padding/2
//        instance.backgroundColor = .secondarySystemFill
//        instance.publisher(for: \.bounds, options: .new)
//          .sink { instance.cornerRadius = $0.width*0.05 }
//          .store(in: &subscriptions)
//      instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100,
//                                                                      font: leftLabel.font)).isActive  = true
//
//      return instance
//    }()
  private lazy var leftLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .label
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular,
                                      forTextStyle: .body)
    
    return instance
  }()
  //  private lazy var rightLabel: UILabel = {
  //    let instance = UILabel()
  //    instance.textColor = .label
  //    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
  //
  //    return instance
  //  }()
  private lazy var icon: UIView = {
    let instance = UIView.opaque()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var textField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
//    instance.insets = UIEdgeInsets(top: 8,
//                                   left: 0,
//                                   bottom: 8,
//                                   right: 0)
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.translatesAutoresizingMaskIntoConstraints = false
    // Set static 40 height due to app crash on 01.07.2023
    let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
    constraint.identifier = "height"
    constraint.isActive  = true
    instance.spellCheckingType = .no
    instance.autocorrectionType = .no
//  private lazy var textField: UnderlinedSignTextField = {
//      let instance = UnderlinedSignTextField()//lowerTextFieldTopConstant: -4)
      instance.customRightView = nil
//      instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//      instance.clearButtonMode = .always
//      instance.text = ""
//      instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
//      instance.spellCheckingType = .no
//      instance.autocorrectionType = .no
    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
    instance.delegate = self
    instance.clipsToBounds = false
    instance.layer.masksToBounds = false
//    instance.textColor = userprofile.isCurrent ? .label : .blue
    
    // Commented due to app crash 01.07.2023
//    instance.publisher(for: \.bounds, options: .new)
//      .filter { $0 != instance.frame }
//      .sink { [weak self] rect in
//        guard let self = self,
//              let constraint = instance.getConstraint(identifier: "height")
//        else { return }
//
//        self.setNeedsLayout()
//        constraint.constant = max(rect.height, 40)
//        self.layoutIfNeeded()
////        let constraint = instance.heightAnchor.constraint(equalToConstant: max(rect.height, 40))
////        constraint.identifier = "height"
////        constraint.isActive = true
//      }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "chevron.right"))
    instance.accessibilityIdentifier = "chevron"
    instance.clipsToBounds = true
    instance.tintColor = color
    instance.alpha = 0
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:))))
    
    let constraint = instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/3)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
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
    setTasks()
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
      override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
          super.traitCollectionDidChange(previousTraitCollection)
  
        backgroundLayer.fillColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection).cgColor
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
  
  //  override func prepareForReuse() {
  //    super.prepareForReuse()
  //
  //    facebookPublisher = CurrentValueSubject<String?, Never>(nil)
  //    instagramPublisher = CurrentValueSubject<String?, Never>(nil)
  //    tiktokPublisher = CurrentValueSubject<String?, Never>(nil)
  //    googlePublisher = CurrentValueSubject<String?, Never>(nil)
  //    twitterPublisher = CurrentValueSubject<String?, Never>(nil)
  //    openURLPublisher = CurrentValueSubject<URL?, Never>(nil)
  //  }
}

// MARK: - Private
private extension UserSettingsSocialMediaCell {
  @MainActor
  func setupUI() {
    clipsToBounds = false
    stack.place(inside: contentView,
                bottomPriority: .defaultLow)
    
    var logo: UIView!
    var url: URL?
    var placeholder = ""
    
    switch mode {
    case .Facebook:
      logo = FacebookLogo()
      url = userprofile.facebookURL
      placeholder = "facebook_link".localized
    case .Instagram:
      logo = InstagramLogo()
      url = userprofile.instagramURL
      placeholder = "instagram_link".localized
    case .TikTok:
      logo = TikTokLogo()
      url = userprofile.tiktokURL
      placeholder = "tiktok_link".localized
      //    case .Twitter:
      //      logo = UIView.opaque()
      //      url = userprofile.facebookURL?.absoluteString ?? ""
    default:
      logo = UIView.opaque()
#if DEBUG
      print("")
#endif
    }
    
    if !url.isNil {
      if userprofile.isCurrent {
        textField.text = url!.absoluteString
      } else {
        guard var string = url?.absoluteString else { return }
        
        if string.last == "/" { string.removeLast() }
        
        textField.text = string.components(separatedBy: "/").last
      }
    }
    textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
    ])
    logo.isOpaque = false
    logo.place(inside: icon)
//    setNeedsLayout()
//    layoutIfNeeded()
//    logo.placeInCenter(of: icon, heightMultiplier: 1)
    disclosureIndicator.alpha = url.isNil ? 0 : 1
  }
  
  func setTasks() {
//    tasks.append( Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: UIApplication.keyboardWillShowNotification) {
//        guard let self = self else { return }
//
//        self.keyboardWillAppear.send(true)
//      }
//    })
    //        tasks.append( Task {@MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.InstagramURL) {
    //                guard let self = self,
    //                      self.mode == .SocialMedia,
    //                      let userprofile = notification.object as? Userprofile,
    //                      userprofile.isCurrent
    //                else { return }
    //
    //                self.isBadgeEnabled = false
    //            }
    //        })
    //        tasks.append( Task {@MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.TikTokURL) {
    //                guard let self = self,
    //                      let userprofile = notification.object as? Userprofile,
    //                      userprofile.isCurrent
    //                else { return }
    //
    //                self.isBadgeEnabled = false
    //            }
    //        })
  }
  
  @objc
  func handleIO(_ instance: UnderlinedSearchTextField) {
    //        guard let text = instance.text, text.count >= 4 else { return }
    //        fatalError()
  }

  
  @objc
  func handleTap(sender: UIButton) {
    guard let url = getURL() else { return }
    
    openURLPublisher.send(url)
  }
  
  func getURL() -> URL? {
    switch mode {
    case .Facebook:
      return userprofile.facebookURL
    case .Instagram:
      return userprofile.instagramURL
    case .TikTok:
      return userprofile.tiktokURL
    default:
      return nil
    }
  }
}

extension UserSettingsSocialMediaCell: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if userprofile.isCurrent {
      scrollPublisher = textField.convert(textField.frame.origin, to: self)
      
      return true
    } else {
      guard let url = getURL() else { return false }
      
      openURLPublisher.send(url)
    }
    
    return false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField else { return true }
    
    if textField.isShowingSign {
      textField.hideSign()
      textField.text = ""
    }
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let tf = textField as? UnderlinedSignTextField,
          let text = textField.text
    else {  return }
    
    
    guard !text.isEmpty else {
      urlStringPublisher.send("")
      tf.hideSign()
      disclosureIndicator.alpha = 0
      return
    }
    
    switch mode {
    case .Facebook:
      guard text.isFacebookLink,
            let url = URL(string: text)
      else {
        urlStringPublisher.send("")
        tf.showSign(state: .InvalidHyperlink)
        disclosureIndicator.alpha = 0
        return
      }
      
      tf.hideSign()
      disclosureIndicator.alpha = 1
      urlStringPublisher.send(url.absoluteString)
    case .Instagram:
      guard text.isInstagramLink,
            let url = URL(string: text)
      else {
        urlStringPublisher.send("")
        disclosureIndicator.alpha = 0
        tf.showSign(state: .InvalidHyperlink)
        return
      }
    
      disclosureIndicator.alpha = 1
      tf.hideSign()
      urlStringPublisher.send(url.absoluteString)
    case .TikTok:
      guard text.isTikTokLink,
            let url = URL(string: text)
      else {
        urlStringPublisher.send("")
        disclosureIndicator.alpha = 0
        tf.showSign(state: .InvalidHyperlink)
        return
      }
      
      disclosureIndicator.alpha = 1
      tf.hideSign()
      urlStringPublisher.send(url.absoluteString)
    default:
#if DEBUG
      print("")
#endif
    }
  }
}

