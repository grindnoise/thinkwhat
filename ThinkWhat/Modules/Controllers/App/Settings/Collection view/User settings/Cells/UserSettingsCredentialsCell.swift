//
//  CurrentUserCredentialsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsCredentialsCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var mode: UserSettingsCollectionView.Mode = .Default
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil, userprofile.isCurrent else { return }
      
//      if mode == .Creation {
        if userprofile.imageURL == nil {
          avatar.setUserprofileDefaultImage()
        }
      setupLabels()
//        if userprofile.fullName.isEmpty {
//          username.text = userprofile.username
//        }
//      }
      
      userprofile.$firstName
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }

          self.setupLabels(animated: true)
        }
        .store(in: &subscriptions)
      
      userprofile.$lastName
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }

          self.setupLabels(animated: true)
        }
        .store(in: &subscriptions)
      
      userprofile.$gender
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self,
                $0 != .Unassigned
          else { return }

          self.setupButtons()
          self.setColors()
        }
        .store(in: &subscriptions)
      
      userprofile.$birthDate
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self,
                $0 != nil
          else { return }

          
          var ageString = ""
          let estimatedBirthday = Calendar.current.date(byAdding: .year, value: self.userprofile.age == 0 ? -18 : -self.userprofile.age, to: Date())!
          let fullComponents = Date.dateComponents(from: estimatedBirthday, to: Date())
          var components: DateComponents!
          
          var years = 0
          if let _years = fullComponents.year, _years > 0 {
            years = _years
            components = Calendar.current.dateComponents([.year], from: estimatedBirthday, to: Date())
            ageString = (DateComponentsFormatter.localizedString(from: components, unitsStyle: .full) ?? "").uppercased()
          }
          
          let ageAttributedString = NSAttributedString(string: ageString,
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: UIColor.white,
                                                       ])
          
          if #available(iOS 15, *) {
            self.ageButton.configuration?.baseBackgroundColor = self.color
            self.ageButton.configuration?.title = ageString
          } else {
            self.ageButton.setAttributedTitle(ageAttributedString, for: .normal)
            self.ageButton.backgroundColor = self.color
            
//            guard let ageConstraint = ageButton.getConstraint(identifier: "width") else { return }
//
//            self.setNeedsLayout()
//            ageConstraint.constant = ("age".localized + ": " + String(describing: self.userprofile.age))
//              .width(withConstrainedHeight: self.ageButton.bounds.height,
//                     font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                             forTextStyle: .subheadline)!) + self.ageButton.imageEdgeInsets.left + self.ageButton.imageEdgeInsets.right + (self.ageButton.imageView?.bounds.width ?? 0) + self.ageButton.titleEdgeInsets.left*4
//            self.layoutIfNeeded()
          }
        }
        .store(in: &subscriptions)
      
//      userprofile.imagePublisher
//        .receive(on: DispatchQueue.main)
//        .sink(receiveCompletion: { [weak self] _ in
//          guard let self = self else { return }
//
//          let banner = NewBanner(contentView: TextBannerContent(image:  UIImage(systemName: "xmark.circle.fill")!,
//                                                                text: AppError.server.localizedDescription,
//                                                                tintColor: .systemRed,
//                                                                fontName: Fonts.Regular,
//                                                                textStyle: .subheadline,
//                                                                textAlignment: .natural),
//                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                                 isModal: false,
//                                 useContentViewHeight: true,
//                                 shouldDismissAfter: 2)
//          banner.didDisappearPublisher
//            .sink { _ in banner.removeFromSuperview() }
//            .store(in: &self.subscriptions)
//        }, receiveValue: { [weak self] image in
//          guard let self = self else { return }
//
//          self.avatar.imageUploadFinished(image)
//
//          let banner = NewBanner(contentView: TextBannerContent(image: image,
//                                                                text: "image_uploaded",
//                                                                tintColor: self.color,
//                                                                fontName: Fonts.Regular,
//                                                                textStyle: .headline,
//                                                                textAlignment: .natural,
//                                                                cornerRadius: 0.05),
//                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                                 isModal: false,
//                                 useContentViewHeight: true,
//                                 shouldDismissAfter: 2)
//          banner.didDisappearPublisher
//            .sink { _ in banner.removeFromSuperview() }
//            .store(in: &self.subscriptions)
//        })
//        .store(in: &subscriptions)
      
      setupUI()
      avatar.userprofile = userprofile
      setupLabels()
      setupButtons()
    }
  }
  ///**Publishers**
  public var namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
  public var datePublisher = CurrentValueSubject<Date?, Never>(nil)
  public var genderPublisher = CurrentValueSubject<Enums.Gender?, Never>(nil)
  public var galleryPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var cameraPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public var previewPublisher = CurrentValueSubject<UIImage?, Never>(nil)
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      setColors()
    }
  }
  ///**UI**
  public var padding: CGFloat = 16
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var insets = { UIEdgeInsets(top: self.padding*2,
                                           left: self.padding,
                                           bottom: self.padding,
                                           right: self.padding) }()
  private var currentConstraints = [NSLayoutConstraint]()
//  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: "userprofile".localized.uppercased(),
//                                                         padding: 4,
//                                                         color: color,
//                                                         font: UIFont(name: Fonts.Bold, size: 20)!,
//                                                         iconCategory: userprofile.gender == .Male ? .ManFace : .GirlFace) }()
  private lazy var username: UILabel = {
    let instance = UILabel()
    instance.isUserInteractionEnabled = true
    instance.textAlignment = .center
    instance.numberOfLines = 2
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.edit(recognizer:))))
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    //        instance.publisher(for: \.contentSize, options: .new)
    //            .sink { [unowned self] size in
    //                guard let constraint = instance.getConstraint(identifier: "height") else { return }
    //
    //                self.setNeedsLayout()
    //                constraint.constant = size.height// * 1.5
    //                self.layoutIfNeeded()
    //                let space = constraint.constant - size.height
    //                let inset = max(0, space/2)
    //                instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    //            }
    //            .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var genderButton: UIButton = {
    let instance = UIButton()
    instance.titleLabel?.numberOfLines = 1
    instance.showsMenuAsPrimaryAction = true
    instance.menu = prepareMenu()
    
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
      config.imagePlacement = .trailing
      config.imagePadding = 6
      config.contentInsets.leading = 8
      config.contentInsets.trailing = 4
      config.contentInsets.top = 2
      config.contentInsets.bottom = 2
      config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outcoming = incoming
        outcoming.font = UIFont(name: Fonts.Bold, size: 18)
        outcoming.foregroundColor = .white
        return outcoming
      }
      config.imageColorTransformer = UIConfigurationColorTransformer { _ in return .white }
      config.buttonSize = .large
      //      config.baseForegroundColor = .white
      
      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white,
      ])
      instance.setAttributedTitle(attrString, for: .normal)
      instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      instance.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
      instance.imageView?.tintColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
      instance.imageView?.contentMode = .scaleAspectFit
      instance.imageEdgeInsets.left = 10
      instance.imageEdgeInsets.top = 2
      instance.imageEdgeInsets.bottom = 2
      instance.imageEdgeInsets.right = 2
      instance.semanticContentAttribute = .forceRightToLeft
      instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
      constraint.identifier = "width"
      constraint.isActive = true
    }
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { instance.cornerRadius = $0.height / 2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var ageButton: UIButton = {
    let instance = UIButton()
    
    instance.addTarget(self, action: #selector(self.editAge), for: .touchUpInside)
    if #available(iOS 15, *) {
      let attrString = AttributedString("TEST", attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      //            config.cornerStyle = .medium
      config.attributedTitle = attrString
      config.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
      config.imagePlacement = .trailing
      config.imagePadding = 6
      config.contentInsets.leading = 8
      config.contentInsets.trailing = 4
      config.contentInsets.top = 2
      config.baseBackgroundColor = (mode == .Creation && userprofile.age == 18) ? .systemGray2 : color
      config.contentInsets.bottom = 2
      config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outcoming = incoming
        outcoming.font = UIFont(name: Fonts.Bold, size: 18)
        outcoming.foregroundColor = .white
        return outcoming
      }
      config.imageColorTransformer = UIConfigurationColorTransformer { _ in return .white }
      //            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
      //                guard let self = self else { return .systemGray }
      //
      //                return self.color
      //            }
      //            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
      //                guard let self = self else { return .systemGray }
      //
      //                return self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
      //            }
      config.buttonSize = .large
      //            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      //      config.baseForegroundColor = .white
      
      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white,
      ])
      instance.setAttributedTitle(attrString, for: .normal)
      instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      instance.titleEdgeInsets.left = 2
      instance.backgroundColor = (mode == .Creation && userprofile.age == 18) ? .systemGray2 : color
      //            instance.titleEdgeInsets.right = 8
      instance.titleEdgeInsets.top = 2
      instance.titleEdgeInsets.bottom = 2
      instance.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
      instance.imageView?.tintColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
      instance.imageView?.contentMode = .scaleAspectFit
      instance.imageEdgeInsets.left = 10
      instance.imageEdgeInsets.top = 2
      instance.imageEdgeInsets.bottom = 2
      instance.imageEdgeInsets.right = 2
      instance.semanticContentAttribute = .forceRightToLeft
      instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
      constraint.identifier = "width"
      constraint.isActive = true
    }
    
    instance.publisher(for: \.bounds, options: .new)
      .sink { instance.cornerRadius = $0.height / 2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var avatar: Avatar = {
    let instance = Avatar(userprofile: userprofile, isShadowed: true, mode: .Editing)
    //    instance.mode = .Editing
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    
    //Catch image tap
    instance.previewPublisher.sink { [weak self] in
      guard let self = self,
            let image = $0
      else { return }
      
      self.previewPublisher.send(image)
    }.store(in: &subscriptions)
    
    //Catch camera tap
    instance.cameraPublisher.sink { [weak self] in
      guard let self = self, !$0.isNil else { return }
      
      self.cameraPublisher.send(true)
    }.store(in: &subscriptions)
    
    //Catch photo tap
    instance.galleryPublisher.sink { [weak self] in
      guard let self = self, !$0.isNil else { return }
      
      self.galleryPublisher.send(true)
    }.store(in: &subscriptions)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let nested = UIStackView(arrangedSubviews: [
      genderButton,
      ageButton
    ])
    nested.axis = .horizontal
    nested.clipsToBounds = false
    nested.spacing = padding
    //    nested.distribution = .fillEqually
    
    let opaque = UIView.opaque()
    opaque.isUserInteractionEnabled = true
    opaque.heightAnchor.constraint(equalToConstant: 200).isActive = true
    avatar.place(inside: opaque)
    //    avatar.placeInCenter(of: opaque, topInset: 4, bottomInset: 4)
    
    let instance = UIStackView(arrangedSubviews: [
//      tagCapsule,
      opaque,
      username,
      nested
    ])
    instance.axis = .vertical
    instance.alignment = .center
    //    instance.clipsToBounds = false
    instance.spacing = padding*2
    
    //    userView.translatesAutoresizingMaskIntoConstraints = false
    //    username.translatesAutoresizingMaskIntoConstraints = false
    
    //    NSLayoutConstraint.activate([
    //      userView.widthAnchor.constraint(equalTo: instance.widthAnchor),
    //      userView.heightAnchor.constraint(equalToConstant: 200),
    //      username.widthAnchor.constraint(equalTo: instance.widthAnchor),
    //    ])
    
    return instance
  }()
  private lazy var credentialsTextField: UsernameInputTextField = {
    let instance = UsernameInputTextField(font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!, delegate: self)
    addSubview(instance)
    
    return instance
  }()
  private lazy var ageTextField: UITextField = {
    let instance = UITextField(frame: .zero)
    instance.inputView = datePicker
    
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
    toolBar.isTranslucent = true
    toolBar.accessibilityIdentifier = "toolBar"
    toolBar.backgroundColor = .tertiarySystemBackground
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.superview?.backgroundColor = .tertiarySystemBackground
    let doneButton = UIBarButtonItem(title: "select".localized, style: .done, target: nil, action: #selector(self.dateSelected))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.items = [space, doneButton]
    toolBar.barStyle = .default
    toolBar.tintColor = color
    instance.inputAccessoryView = toolBar
    let tenYearsAgo = Calendar.current.date(byAdding: DateComponents(year: -10), to: Date())
    datePicker.maximumDate = tenYearsAgo
    datePicker.layer.zPosition = 10000
    
    addSubview(instance)
    
    return instance
  }()
  private lazy var datePicker: UIDatePicker = {
    let instance = UIDatePicker()
    instance.date = Date()
    instance.datePickerMode = .date
    instance.locale = .current
    instance.preferredDatePickerStyle = .inline
    //        instance.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
    instance.datePickerMode = .date
    instance.backgroundColor = .tertiarySystemBackground
    instance.tintColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    
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
  //  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
  //    super.traitCollectionDidChange(previousTraitCollection)
  //
  //    //        datePicker.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
  //
  //    if #available(iOS 15, *) {
  //      if !genderButton.configuration.isNil, !ageButton.configuration.isNil {
  //        genderButton.configuration!.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  //        ageButton.configuration!.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  //      }
  //    } else {
  //      genderButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  //      ageButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  //    }
  //
  //    //Set dynamic font size
  //    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
  //
  //    guard let constraint_1 = username.getConstraint(identifier: "height"),
  //          //              let constraint_2 = gender.getConstraint(identifier: "height"),
  //          !username.text.isNil
  //    else { return }
  //
  //    username.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
  //    //        gender.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
  //    //        age.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
  //
  //    setNeedsLayout()
  //    constraint_1.constant = username.text!.height(withConstrainedWidth: username.bounds.width, font: username.font)
  //    //        constraint_2.constant = "test".height(withConstrainedWidth: gender.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
  //    layoutIfNeeded()
  //  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    datePublisher = CurrentValueSubject<Date?, Never>(nil)
    genderPublisher = CurrentValueSubject<Enums.Gender?, Never>(nil)
    galleryPublisher = CurrentValueSubject<Bool?, Never>(nil)
    cameraPublisher = CurrentValueSubject<Bool?, Never>(nil)
    previewPublisher = CurrentValueSubject<UIImage?, Never>(nil)
  }
  
  
  
  // MARK: - Public methods
  public func setInsets(_ insets: UIEdgeInsets) {
    self.insets = insets
    
    setupUI()
  }
  
  public func setPadding(_ padding: CGFloat) {
    self.insets = .zero
    self.padding = padding
    
    setupUI()
  }
}

// MARK: - Private
private extension UserSettingsCredentialsCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    //    stack.removeConstraints(currentConstraints)
    //    stack.removeFromSuperview()
    currentConstraints = stack.place(inside: self,
                                     insets: insets == .zero ? .uniform(size: padding) : insets,
                                     bottomPriority: .defaultLow)
  }
  
  @MainActor
  func updateUI() {
    //    stack.removeFromSuperview()
    //
    //    guard let insets = insets else {
    //      stack.place(inside: self,
    //                          insets: .uniform(size: padding),
    //                          bottomPriority: .defaultLow)
    //      return
    //    }
    //    stack.place(inside: self,
    //                        insets: insets,
    //                        bottomPriority: .defaultLow)
  }
  
  func setTasks() {
    //Hide keyboard
    tasks.append( Task {@MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.System.HideKeyboard) {
        guard let self = self else { return }
        
        if self.ageTextField.isFirstResponder {
          let _ = self.ageTextField.resignFirstResponder()
        } else {
          let _ = self.credentialsTextField.resignFirstResponder()
        }
      }
    })
    
    //First name change
    tasks.append( Task { [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FirstNameChanged) {
        guard let self = self,
              let instance = notification.object as? Userprofile,
              instance.isCurrent
        else { return }
        
        self.setupLabels(animated: true)
      }
    })
    
    //Last name change
    tasks.append( Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.LastNameChanged) {
        guard let self = self,
              let instance = notification.object as? Userprofile,
              instance.isCurrent
        else { return }
        
        self.setupLabels(animated: true)
      }
    })
    
//    //Birth date change
//    tasks.append( Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.BirthDateChanged) {
//        guard let self = self,
//              let instance = notification.object as? Userprofile,
//              instance.isCurrent
//        else { return }
//
//        self.setupButtons(animated: true)
//      }
//    })
    
//    //Gender change
//    tasks.append( Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.GenderChanged) {
//        guard let self = self,
//              let instance = notification.object as? Userprofile,
//              instance.isCurrent
//        else { return }
//
//        self.setupButtons(animated: true)
//      }
//    })
    
    //Image upload began
    tasks.append( Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.System.ImageUploadStart) {
        guard let self = self,
              let dict = notification.object as? [Userprofile: UIImage],
              let userprofile = dict.keys.first,
              let image = dict.values.first,
              userprofile.isCurrent
        else { return }
        
        delayAsync(delay: 0.15) {
          self.avatar.imageUploadStarted(image)
        }
      }
    })
    
    //Image upload finished
    tasks.append( Task { [weak self] in//@MainActor
      //            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.ImageDownloaded) {
      //                guard let self = self,
      //                      let instance = notification.object as? Userprofile,
      //                      instance.isCurrent,
      //                      let image = instance.image,
      //                      self.avatar.isUploading
      //                else { return }
      
      //      for await _ in NotificationCenter.default.notifications(for: Notifications.Userprofiles.CurrentUserImageUpdated) {
      //        guard let self = self,
      //              let instance = Userprofiles.shared.current,
      //              let image = instance.image
      //        else { return }
      //
      //        await MainActor.run {
      //          self.avatar.imageUploadFinished(image)
      //
      //          let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "photo")!,
      //                                                                text: "image_uploaded",
      //                                                                tintColor: .systemOrange,
      //                                                                fontName: Fonts.Semibold,
      //                                                                textStyle: .headline,
      //                                                                textAlignment: .natural),
      //                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
      //                                 isModal: false,
      //                                 useContentViewHeight: true,
      //                                 shouldDismissAfter: 2)
      //          banner.didDisappearPublisher
      //            .sink { _ in banner.removeFromSuperview() }
      //            .store(in: &self.subscriptions)
      //
      //          //                    showBanner(bannerDelegate: self, text: "".localized, content: UIImageView(image: UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemGreen, shadowed: true)
      //        }
      //      }
    })
    
    //Image upload failure
    tasks.append( Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.System.ImageUploadFailure) {
        guard let self = self,
              let instance = notification.object as? Userprofile,
              instance.isCurrent
        else { return }
        
        let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                              text: AppError.server.localizedDescription.localized,
                                                              tintColor: .systemOrange,
                                                              fontName: Fonts.Semibold,
                                                              textStyle: .headline,
                                                              textAlignment: .natural),
                               contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                               isModal: false,
                               useContentViewHeight: true,
                               shouldDismissAfter: 2)
        banner.didDisappearPublisher
          .sink { _ in banner.removeFromSuperview() }
          .store(in: &self.subscriptions)
        
        //                showBanner(bannerDelegate: self, text: AppError.server.localizedDescription.localized, content: UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))), color: UIColor.white, textColor: .white, dismissAfter: 0.75, backgroundColor: UIColor.systemRed, shadowed: true)
      }
    })
  }
  
  @objc
  func edit(recognizer: UITapGestureRecognizer) {
    guard let v = recognizer.view else { return }
    
    if v === username {
      let _ = credentialsTextField.becomeFirstResponder()
    }
    Fade.shared.present()
  }
  
  @objc
  func editAge() {
    Fade.shared.present()
    let _ = ageTextField.becomeFirstResponder()
    
    guard let date = Userprofiles.shared.current?.birthDate else { return }
    
    datePicker.date = date
  }
  
  @objc
  func editImage() {
    
  }
  
  @MainActor
  func setupLabels(animated: Bool = false) {
//    titleLabel.backgroundColor = color
    
    guard let userprofile = Userprofiles.shared.current else { return }
    
    if animated {
      UIView.transition(with: username, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.username.text = userprofile.fullName.isEmpty ? userprofile.username : userprofile.fullName
      }
      
      return
    }
    username.text = userprofile.fullName.isEmpty ? userprofile.username : userprofile.fullName
//    if !userprofile.firstNameSingleWord.isEmpty {
//      if animated {
//        UIView.transition(with: username, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
//          guard let self = self else { return }
//
//          self.username.text = userprofile.firstNameSingleWord
//        } completion: { _ in }
//      } else {
//        username.text = userprofile.firstNameSingleWord
//      }
//    }
//
//    if !userprofile.lastNameSingleWord.isEmpty {
//      if animated {
//        UIView.transition(with: username, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
//          guard let self = self else { return }
//
//          self.username.text! += self.username.text!.isEmpty ? self.userprofile.lastNameSingleWord : " " + userprofile.lastNameSingleWord
//        } completion: { _ in }
//      } else {
//        username.text! += username.text!.isEmpty ? userprofile.lastNameSingleWord : " " + userprofile.lastNameSingleWord
//      }
//    }
    
    //        if animated {
    //            UIView.transition(with: age, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
    //                guard let self = self else { return }
    //
    //                self.age.text = String(describing: userprofile.age)
    //            } completion: { _ in }
    //        } else {
    //            age.text = String(describing: userprofile.age)
    //        }
    
    
    //        gender.text = userprofile.gender.rawValue.localized.lowercased() + ","
    
    guard let constraint_1 = username.getConstraint(identifier: "height"),
          !username.text.isNil
            //              let constraint_2 = gender.getConstraint(identifier: "width"),
            //              let constraint_3 = age.getConstraint(identifier: "width")
    else { return }
    
    setNeedsLayout()
    constraint_1.constant = username.text!.height(withConstrainedWidth: username.bounds.width, font: username.font)
    //        constraint_2.constant = gender.text!.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
    //        constraint_3.constant = age.text!.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
    layoutIfNeeded()
  }
  
  @MainActor
  func setupButtons(animated: Bool = false) {
    guard let userprofile = userprofile else { return }
    
    var ageString = ""
    let estimatedBirthday = Calendar.current.date(byAdding: .year, value: userprofile.age == 0 ? -18 : -userprofile.age, to: Date())!
    let fullComponents = Date.dateComponents(from: estimatedBirthday, to: Date())
    var components: DateComponents!
    
    if let _years = fullComponents.year, _years > 0 {
      components = Calendar.current.dateComponents([.year], from: estimatedBirthday, to: Date())
      ageString = (DateComponentsFormatter.localizedString(from: components, unitsStyle: .full) ?? "").uppercased()
    }
    
    let ageAttributedString = NSAttributedString(string: ageString,//(mode == .Creation && ageString == "18") ? "age".localized.uppercased() : ageString,
                                                 attributes: [
                                                  .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                                                  .foregroundColor: UIColor.white,
                                                 ])
    
    let genderAttributedString = NSAttributedString(string: userprofile.gender == .Unassigned ? "age".localized.uppercased() : userprofile.gender.rawValue.localized.capitalized,
                                                    attributes: [
                                                      .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                                                      .foregroundColor: UIColor.white,
                                                    ])
    
    if #available(iOS 15, *) {
      if userprofile.gender != .Unassigned {
        genderButton.configuration?.image = UIImage(systemName: userprofile.gender == .Male ? "mustache.fill" : "mouth.fill",
                                                    withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
      }
      ageButton.configuration?.title = ageString//(mode == .Creation && years == 18) ? "age".localized.uppercased() : ageString
      genderButton.configuration?.title = userprofile.gender == .Unassigned ? "gender".localized.uppercased() : userprofile.gender.rawValue.localized.uppercased()
    } else {
      if userprofile.gender != .Unassigned {
        genderButton.setImage(UIImage(systemName: userprofile.gender == .Male ? "mustache.fill" : "mouth.fill",
                                      withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
      }
      genderButton.setAttributedTitle(genderAttributedString, for: .normal)
      ageButton.setAttributedTitle(ageAttributedString, for: .normal)
      
      guard let ageConstraint = ageButton.getConstraint(identifier: "width"),
            let genderConstraint = genderButton.getConstraint(identifier: "width")
      else { return }
      
      setNeedsLayout()
      ageConstraint.constant = ("age".localized + ": " + String(describing: userprofile.age)).width(withConstrainedHeight: ageButton.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline)!) + ageButton.imageEdgeInsets.left + ageButton.imageEdgeInsets.right + (ageButton.imageView?.bounds.width ?? 0) + ageButton.titleEdgeInsets.left*4
      genderConstraint.constant = userprofile.gender.rawValue.localized.capitalized.width(withConstrainedHeight: genderButton.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline)!) + genderButton.imageEdgeInsets.left + genderButton.imageEdgeInsets.right + (genderButton.imageView?.bounds.width ?? 0) + genderButton.titleEdgeInsets.left*4
      layoutIfNeeded()
    }
  }
  
  @objc
  func dateSelected() {
    ageTextField.resignFirstResponder()
    Fade.shared.dismiss()
    datePublisher.send(datePicker.date)
  }
  
  func prepareMenu() -> UIMenu {
    var actions: [UIAction]!
    
    let male: UIAction = .init(title: Enums.Gender.Male.rawValue.localized.capitalized, image: UIImage(systemName: "mustache.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.genderPublisher.send(Enums.Gender.Male)
    })
    
    let female: UIAction = .init(title: Enums.Gender.Female.rawValue.localized.capitalized, image: UIImage(systemName: "mouth.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.genderPublisher.send(Enums.Gender.Female)
    })
    
    
    actions = [male, female]
    
    return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
  }
  
  func setColors() {
    avatar.color = color
//    tagCapsule.color = color
    
    if #available(iOS 15, *) {
      genderButton.configuration?.baseBackgroundColor = (mode == .Creation && userprofile.gender == .Unassigned) ? .systemGray2 : color
//      ageButton.configuration?.baseBackgroundColor = (mode == .Creation && userprofile.age == 18) ? .systemGray2 : color
      
      //          UIConfigurationColorTransformer { [weak self] _ in
      //                guard let self = self else { return .systemGray }
      //
      //                return self.color
      //            }
      //        ageButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
      //          guard let self = self else { return .systemGray }
      //
      //          return self.color
      //            }
    } else {
      genderButton.backgroundColor = (mode == .Creation && userprofile.gender == .Unassigned) ? .systemGray2 : color
//      ageButton.backgroundColor = (mode == .Creation && userprofile.age == 18) ? .systemGray2 : color
      //            genderButton.imageView?.tintColor = color
      //            ageButton.imageView?.tintColor = color
    }
  }
}

// MARK: - UsernameInputTextFieldDelegate
extension UserSettingsCredentialsCell: UsernameInputTextFieldDelegate {
  func onSendEvent(_ credentials: [String: String]) {
    let _ = credentialsTextField.resignFirstResponder()
    Fade.shared.dismiss()
    guard !credentials.isEmpty else { return }
    
    namePublisher.send(credentials)
  }
}

//extension UserSettingsCredentialsCell: BannerObservable {
//    func onBannerWillAppear(_ sender: Any) {}
//
//    func onBannerWillDisappear(_ sender: Any) {}
//
//    func onBannerDidAppear(_ sender: Any) {}
//
//    func onBannerDidDisappear(_ sender: Any) {
//        if let banner = sender as? Banner {
//            banner.removeFromSuperview()
//        } else if let popup = sender as? Popup {
//            popup.removeFromSuperview()
//        }
//    }
//}
