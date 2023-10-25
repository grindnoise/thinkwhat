//
//  UserSettingsBirthDateCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class UserSettingsBirthDateCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var birthDate: Date! {
    didSet {
      guard let birthDate = birthDate else { return }
      
      setupUI()
      
      datePicker.date = birthDate
//      // Update text & sign
//      if gender != .Unassigned {
//        textField.text = gender.rawValue.localized.capitalized
//        setSign(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, color: .systemGreen, enabled: true, animated: true)
//      } else {
        setSign(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, color: .systemRed, enabled: true, animated: true)
//      }
    }
  }
  public var insets: UIEdgeInsets = .uniform(Constants.UI.padding) {
    didSet {
      guard oldValue != insets else { return }
      
      setupUI()
    }
  }
  ///**Publishers**
  public var datePublisher = PassthroughSubject<Date, Never>()
  public var signTapPublisher = PassthroughSubject<Void, Never>()
  public var color: UIColor = Constants.UI.Colors.main {
    didSet {
      setColors()
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var header: UIStackView = {
    // Header stack
    let label: UILabel = {
      let instance = UILabel()
      instance.textColor = Constants.UI.Colors.cellHeader
      instance.text = "new_profile_birth_date".localized.uppercased()
      instance.font = Fonts.cellHeader
      instance.height(instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
      
      return instance
    }()
    let image: UIImageView = {
      let instance = UIImageView(image: UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
      instance.tintColor = Constants.UI.Colors.cellHeader
      instance.contentMode = .center
      instance.height("T".height(withConstrainedWidth: 100, font: label.font))
      
      return instance
    }()
    let instance = UIStackView(arrangedSubviews: [
      image,
      label,
      UIView.opaque(),
    ])
    instance.axis = .horizontal
    instance.spacing = Constants.UI.padding/2
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    // 1303 Водельникова Ольга проект перепланировки
    // Main stack
    let instance = UIStackView(arrangedSubviews: [
      header,
      textField
    ])
    instance.axis = .vertical
    instance.spacing = Constants.UI.padding
    
    return instance
  }()
  private lazy var toolBar: UIToolbar = {
    let instance = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
    instance.isTranslucent = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//    instance.superview?.backgroundColor = .tertiarySystemBackground
    let doneButton = UIBarButtonItem(title: "select".localized, style: .done, target: nil, action: #selector(self.dateSelected))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    instance.items = [space, doneButton]
    instance.barStyle = .default
    instance.tintColor = color
    
    return instance
  }()
  private lazy var textField: InsetTextField = {
    let instance = InsetTextField(rightViewVerticalScaleFactor: 1.25,
                                  insets: .uniform(Constants.UI.padding))
    instance.rightViewMode = .always
    // instance.isUserInteractionEnabled = false
    instance.placeholder = "new_profile_birth_date_placeholder".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection)
    instance.inputAccessoryView = toolBar
    instance.inputView = datePicker
    instance.publisher(for: \.bounds)
      .sink { rect in
        instance.cornerRadius = rect.width*0.025
        
        guard instance.insets == .zero else { return }
        
        instance.insets = UIEdgeInsets(top: instance.insets.top,
                                       left: rect.height/2.25,
                                       bottom: instance.insets.top,
                                       right: rect.height/2.25)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var btn: UIButton = {
    let instance = UIButton()
    instance.setTitle("", for: .normal)
    instance.addTarget(self, action: #selector(self.selectDate), for: .touchUpInside)
    
    return instance
  }()
  private lazy var datePicker: UIDatePicker = {
    let instance = UIDatePicker()
    instance.maximumDate = Calendar.current.date(byAdding: DateComponents(year: -18), to: Date())
instance.datePickerMode = .date
    instance.layer.zPosition = 10000
    instance.datePickerMode = .date
    instance.locale = .current
    instance.preferredDatePickerStyle = .inline
    instance.datePickerMode = .date
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.tintColor = color
    
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    updateTraits()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    datePublisher = PassthroughSubject<Date, Never>()
    signTapPublisher = PassthroughSubject<Void, Never>()
  }
  
  // MARK: - Public
  func setSign(image: UIImage?,
               color: UIColor = Constants.UI.Colors.main,
               enabled: Bool,
               animated: Bool,
               completion: Closure? = nil) {
    switch enabled {
    case true:
      guard let image = image else { return }
      
      // Check if right view is already image view
      if let present = textField.rightView as? UIImageView {
        // Change image
        if animated {
          Animations.changeImageCrossDissolve(imageView: present, image: image, animations: [{ present.tintColor = color }])
        } else {
          present.image = image
        }
      } else {
        let sign = UIImageView(image: image)
        sign.isUserInteractionEnabled = true
        sign.tintColor = color
        sign.contentMode = .center
        
        // Set right view
        textField.rightView = sign
        textField.rightView?.isUserInteractionEnabled = true
        
        // Skip if is visible
        if !sign.alpha.isZero { completion?(); return }
        
        switch animated {
        case true:
          sign.alpha = 0
          sign.transform = .init(scaleX: 0.5, y: 0.5)
          UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            sign.alpha = 1
            sign.transform = .identity
          }) { _ in completion?() }
        case false:
          sign.alpha = 1
          completion?()
        }
      }
    case false:
      // Skip if not found
      guard let sign = textField.rightView as? UIImageView else { completion?(); return }
      
      switch animated {
      case true:
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
          sign.alpha = 0
          sign.transform = .init(scaleX: 0.5, y: 0.5)
        }) { [weak self] _ in
          guard let self = self else { return }
          
          sign.removeFromSuperview()
          self.textField.rightView = nil
          completion?()
        }
      case false:
        sign.alpha = 0
        sign.stopAnimating()
        sign.removeFromSuperview()
        textField.rightView = nil
        completion?()
      }
    }
  }
  
  // MARK: - Overridden
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    var point = point
    point.y -= (stack.bounds.height - stack.spacing - header.bounds.height)
    
    if btn.frame.contains(point) {
      return btn
    }
    
    if textField.frame.contains(point) {
      signTapPublisher.send()
      return textField
    }
    
    return nil
  }
}

// MARK: - Private
private extension UserSettingsBirthDateCell {
  @MainActor
  func setupUI() {
    stack.removeFromSuperview()
    btn.removeFromSuperview()
    contentView.addSubview(stack)
    stack.edgesToSuperview(insets: insets)
    
    textField.addSubview(btn)
    btn.bottomToSuperview()
    btn.leadingToSuperview()
    btn.width(to: textField, multiplier: 0.9)
    btn.height(to: textField)
//    btn.layer.zPosition = 1000
    
    if #available(iOS 17.0, *) {
      registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(self.updateTraits))
    }
  }
  
  func setTasks() {
    Notifications.System.hideKeyboardPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.endEditing(true)
      }
      .store(in: &subscriptions)
  }
  
  @objc
  func updateTraits() {
    datePicker.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    toolBar.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  }

  func setColors() {
    
  }
  
  @objc
  func dateSelected() {
    textField.resignFirstResponder()
    Fade.shared.dismiss()
    datePublisher.send(datePicker.date)
  }
  
  @objc
  func selectDate() {
    Fade.shared.present()
    datePicker.date = birthDate
    textField.becomeFirstResponder()
  }
}
