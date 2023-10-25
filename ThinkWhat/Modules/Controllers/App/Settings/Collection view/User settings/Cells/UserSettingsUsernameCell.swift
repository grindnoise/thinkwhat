//
//  UserSettingsUsernameCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class UserSettingsUsernameCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var username: String! {
    didSet {
      guard let username = username,
            oldValue != username
      else { return }
      
      textField.text = username
      setupUI()
    }
  }
  public var insets: UIEdgeInsets = .uniform(Constants.UI.padding)
  ///**Publishers**
  public var editingPublisher = PassthroughSubject<String, Never>()
  public var signTapPublisher = PassthroughSubject<Void, Never>()
  public var usernamePublisher = PassthroughSubject<String, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var stack: UIStackView = {
    // Header stack
    let label: UILabel = {
      let instance = UILabel()
      instance.textColor = Constants.UI.Colors.cellHeader
      instance.text = "new_profile_username".localized.uppercased()
      instance.font = Fonts.cellHeader
      
      let constraint = instance.height(instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
      
//      instance.publisher(for: \.bounds)
//        .sink { [weak self] in
//          guard let self = self else { return }
//          
//          self.setNeedsLayout()
//          constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
//          self.layoutIfNeeded()
//        }
//        .store(in: &subscriptions)
      
      return instance
    }()
    let image: UIImageView = {
      let instance = UIImageView(image: UIImage(systemName: "person.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
      instance.tintColor = Constants.UI.Colors.cellHeader
      instance.contentMode = .center
      instance.height("T".height(withConstrainedWidth: 100, font: label.font))
      
      return instance
    }()
    let header = UIStackView(arrangedSubviews: [
      image,
      label,
      UIView.opaque(),
    ])
    header.axis = .horizontal
    header.spacing = Constants.UI.padding/2
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
  private lazy var textField: InsetTextField = {
    let instance = InsetTextField(rightViewVerticalScaleFactor: 1.25,
                                  insets: .uniform(Constants.UI.padding))
    instance.autocorrectionType = .no
    instance.rightViewMode = .always
    instance.autocapitalizationType = .none
    instance.attributedPlaceholder = NSAttributedString(string: "search".localized, attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
      .foregroundColor: UIColor.secondaryLabel,
    ])
    instance.delegate = self
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = Constants.UI.Colors.textField(color: .white, traitCollection: traitCollection)
    instance.tintColor = Constants.UI.Colors.main
    instance.addTarget(self, action: #selector(ListView.textFieldDidChange(_:)), for: .editingChanged)
    instance.returnKeyType = .done
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
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    editingPublisher = PassthroughSubject<String, Never>()
    signTapPublisher = PassthroughSubject<Void, Never>()
    usernamePublisher = PassthroughSubject<String, Never>()
  }
  
  // MARK: - Public
  func clear() {
    setSign(image: nil, enabled: false, animated: true)
    setLoading(enabled: false, animated: true)
  }
  
  func setSign(image: UIImage?, 
               color: UIColor = Constants.UI.Colors.main,
               enabled: Bool,
               animated: Bool, 
               completion: Closure? = nil) {
    func action() {
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
          sign.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
          
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
    
    if let _ = textField.rightView as? UIActivityIndicatorView {
      setLoading(enabled: false, animated: true) {
        action()
      }
    } else {
      action()
    }
  }
  
  func setLoading(enabled: Bool, animated: Bool, completion: Closure? = nil) {
    func action() {
      switch enabled {
      case true:
        let spinner = textField.rightView as? UIActivityIndicatorView ?? {
          
          let v = UIActivityIndicatorView()
          v.color = Constants.UI.Colors.main
          v.alpha = 0
          self.textField.rightView = v
          
          return v
        }()
        spinner.startAnimating()
        
        // Skip if is visible
        if !spinner.alpha.isZero { completion?(); return }
        
        switch animated {
        case true:
          spinner.alpha = 0
          spinner.transform = .init(scaleX: 0.5, y: 0.5)
          UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            spinner.alpha = 1
            spinner.transform = .identity
          }) { _ in completion?() }
        case false:
          spinner.alpha = 1
          completion?()
        }
      case false:
        // Skip if not found
        guard let spinner = textField.rightView as? UIActivityIndicatorView else { completion?(); return }
        
        switch animated {
        case true:
          spinner.alpha = 1
          UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            spinner.alpha = 0
            spinner.transform = .init(scaleX: 0.5, y: 0.5)
          }) { [weak self] _ in
            guard let self = self else { return }
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self.textField.rightView = nil
            completion?()
          }
        case false:
          spinner.alpha = 0
          spinner.stopAnimating()
          spinner.removeFromSuperview()
          textField.rightView = nil
          completion?()
        }
      }
    }
    
    if let _ = textField.rightView as? UIImageView {
      setSign(image: nil, enabled: false, animated: true) {
        action()
      }
    } else {
      action()
    }
  }
}

// MARK: - Private
private extension UserSettingsUsernameCell {
  @MainActor
  func setupUI() {
    contentView.addSubview(stack)
    stack.edgesToSuperview(insets: insets)
  }
  
  @MainActor
  func updateUI() {
    stack.removeFromSuperview()
    stack.edgesToSuperview(insets: insets)
  }
  
  @objc
  func editingChanged(_ textField: UnderlinedSignTextField) {
    guard let text = textField.text else { return }
    
    textField.text = text.lowercased()
  }
  
  @objc
  func handleTap() {
    signTapPublisher.send()
  }
}

extension UserSettingsUsernameCell: UITextFieldDelegate {
  @objc
  func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else { return }
    
    editingPublisher.send(text)
  }
}


