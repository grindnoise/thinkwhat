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
  public var mode: Mode! {
    didSet {
      guard !mode.isNil else { return }
      
      updateUI()
    }
  }
  ///`Publishers`
  public let urlStringPublisher = PassthroughSubject<String, Never>()
  public var openURLPublisher = PassthroughSubject<URL, Never>()
  public let keyboardWillAppear = PassthroughSubject<Bool, Never>()
  ///`UI`
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      disclosureIndicator.tintColor = color
      textField.tintColor = color
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`UI`
  private let padding: CGFloat = 8
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    let instance = UIStackView(arrangedSubviews: [
      icon,
      textField,
      disclosureIndicator
    ])
    instance.axis = .horizontal
    instance.spacing = padding/2
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100,
                                                                    font: leftLabel.font)).isActive  = true
    
    return instance
  }()
  private lazy var leftLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
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
    let instance = UnderlinedSignTextField()//lowerTextFieldTopConstant: -4)
    instance.customRightView = nil
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    instance.clearButtonMode = .always
    instance.text = ""
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
    instance.spellCheckingType = .no
    instance.autocorrectionType = .no
    instance.attributedPlaceholder = NSAttributedString(string: "facebook_link".localized, attributes: [
      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
    ])
    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
    instance.delegate = self
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard instance.getConstraint(identifier: "height").isNil else { return }
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: rect.height)
        constraint.identifier = "height"
        constraint.isActive = true
      }
      .store(in: &subscriptions)
    
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
  
  
  
  
  //  private lazy var facebookIcon: FacebookLogo = {
  //    let instance = FacebookLogo()
  //    instance.isOpaque = false
  //    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
  //
  //    return instance
  //  }()
  //  private lazy var facebookTextField: UnderlinedSignTextField = {
  //    let instance = UnderlinedSignTextField()//lowerTextFieldTopConstant: -4)
  //    instance.customRightView = nil
  //    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //    instance.clearButtonMode = .always
  //    instance.text = ""
  //    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
  //    instance.spellCheckingType = .no
  //    instance.autocorrectionType = .no
  //    instance.attributedPlaceholder = NSAttributedString(string: "facebook_link".localized, attributes: [
  //      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
  //      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
  //    ])
  //    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
  //    instance.delegate = self
  //
  //    instance.publisher(for: \.bounds, options: .new)
  //      .sink { [weak self] rect in
  //        guard instance.getConstraint(identifier: "height").isNil else { return }
  //
  //        let constraint = instance.heightAnchor.constraint(equalToConstant: rect.height)
  //        constraint.identifier = "height"
  //        constraint.isActive = true
  //      }
  //      .store(in: &subscriptions)
  //
  //    return instance
  //  }()
  //  private lazy var facebookButton: UIButton = {
  //    let instance = UIButton()
  //    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
  //    instance.imageView?.contentMode = .center
  //    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
  //    instance.publisher(for: \.bounds, options: .new)
  //      .sink { rect in
  //        instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
  //      }
  //      .store(in: &subscriptions)
  //
  //    return instance
  //  }()
  //  private lazy var facebookView: UIStackView = {
  //    let instance = UIStackView(arrangedSubviews: [facebookIcon, facebookTextField, facebookButton])
  //    instance.axis = .horizontal
  //    instance.spacing = 8
  //
  //    return instance
  //  }()
  //  private lazy var instagramIcon: InstagramLogo = {
  //    let instance = InstagramLogo()
  //    instance.isOpaque = false
  //    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
  //
  //    return instance
  //  }()
  //  private lazy var instagramTextField: UnderlinedSignTextField = {
  //    let instance = UnderlinedSignTextField()//lowerTextFieldTopConstant: -4)
  //    instance.text = ""
  //    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
  //    instance.spellCheckingType = .no
  //    instance.autocorrectionType = .no
  //    instance.attributedPlaceholder = NSAttributedString(string: "instagram_link".localized, attributes: [
  //      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
  //      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
  //    ])
  //    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
  //    instance.delegate = self
  //
  //    return instance
  //  }()
  //  private lazy var instagramButton: UIButton = {
  //    let instance = UIButton()
  //    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
  //    instance.imageView?.contentMode = .center
  //    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
  //    instance.publisher(for: \.bounds, options: .new)
  //      .sink { rect in
  //        instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
  //      }
  //      .store(in: &subscriptions)
  //
  //    return instance
  //  }()
  //  private lazy var instagramView: UIStackView = {
  //    let instance = UIStackView(arrangedSubviews: [instagramIcon, instagramTextField, instagramButton])
  //    instance.axis = .horizontal
  //    instance.spacing = 8
  //
  //    return instance
  //  }()
  //  private lazy var tiktokIcon: TikTokLogo = {
  //    let instance = TikTokLogo()
  //    instance.isOpaque = false
  //    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
  //
  //    return instance
  //  }()
  //  private lazy var tiktokTextField: UnderlinedSignTextField = {
  //    let instance = UnderlinedSignTextField()//lowerTextFieldTopConstant: -8)
  //    instance.text = ""
  //    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
  //    instance.spellCheckingType = .no
  //    instance.autocorrectionType = .no
  //    instance.attributedPlaceholder = NSAttributedString(string: "tiktok_link".localized, attributes: [
  //      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
  //      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
  //    ])
  //    instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
  //    instance.delegate = self
  //
  //    return instance
  //  }()
  //  private lazy var tiktokButton: UIButton = {
  //    let instance = UIButton()
  //    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
  //    instance.imageView?.contentMode = .center
  //    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
  //    instance.publisher(for: \.bounds, options: .new)
  //      .sink { rect in
  //        instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
  //      }
  //      .store(in: &subscriptions)
  //
  //    return instance
  //  }()
  //  private lazy var tiktokView: UIStackView = {
  //    let instance =  UIStackView(arrangedSubviews: [tiktokIcon, tiktokTextField, tiktokButton])
  //    instance.axis = .horizontal
  //    instance.spacing = 8
  //
  //
  //    return instance
  //  }()
  //  private lazy var verticalStack: UIStackView = {
  //    let instance = UIStackView(arrangedSubviews: [facebookView, instagramView, tiktokView])
  //    instance.axis = .vertical
  //    instance.spacing = 8
  //    instance.distribution = .fillEqually
  //
  //    return instance
  //  }()
  
  
  
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
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  //    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
  //        super.traitCollectionDidChange(previousTraitCollection)
  //
  //        facebookTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //        instagramTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //        tiktokTextField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //
  //        tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
  //
  //        guard !userprofile.isNil else { return }
  //
  //        setupButtons()
  //    }
  
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
    stack.place(inside: contentView,
                bottomPriority: .defaultLow)
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
  
  @MainActor
  func updateUI() {
    guard let userprofile = Userprofiles.shared.current else { return }
    
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
    textField.text = url.isNil ? "" : url!.absoluteString
    textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.font : UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline) as Any,
      NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
    ])
    logo.isOpaque = false
    logo.place(inside: icon)
    disclosureIndicator.alpha = url.isNil ? 0 : 1
  }
  
  @objc
  func handleTap(sender: UIButton) {
    guard let text = textField.text, let url = URL(string: text) else { return }
    
    openURLPublisher.send(url)
  }
}

extension UserSettingsSocialMediaCell: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return true
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
          let text = textField.text,
          let userprofile = Userprofiles.shared.current
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

