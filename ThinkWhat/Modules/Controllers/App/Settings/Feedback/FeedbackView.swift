//
//  FeedbackView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class FeedbackView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: (UIViewController & FeedbackViewInput & TintColorable)? {
    didSet {
      guard let viewInput = viewInput else { return }
      
      setupUI()
      setTasks()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private var state: Enums.ButtonState = .Send
  //UI
  private let padding: CGFloat = 16
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.text = "feedback_hint".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .headline)

    return instance
  }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.contentInset = UIEdgeInsets.uniform(size: 10)
    instance.backgroundColor = .secondarySystemBackground
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)
    instance.tintColor = viewInput?.tintColor ?? .systemGray
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
    toolBar.accessibilityIdentifier = "toolBar"
    toolBar.isTranslucent = true
    toolBar.backgroundColor = .tertiarySystemBackground
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.superview?.backgroundColor = .tertiarySystemBackground
    let doneButton = UIBarButtonItem(title: "ready".localized, style: .done, target: nil, action: #selector(self.hideKeyboard))
    doneButton.accessibilityIdentifier = "ready"
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.items = [space, doneButton]
    toolBar.barStyle = .default
    toolBar.tintColor = viewInput?.tintColor ?? .systemGray
    instance.inputAccessoryView = toolBar
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.025 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var actionButton: UIButton = {
    let instance = UIButton()
    
    instance.addTarget(self, action: #selector(self.send), for: .touchUpInside)
    if #available(iOS 15, *) {
      let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.attributedTitle = attrString
      config.baseBackgroundColor = viewInput?.tintColor ?? .systemRed
      config.image = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
      config.imagePlacement = .trailing
      config.imagePadding = 8.0
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.buttonSize = .large
      
      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: state.rawValue.localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ])
      instance.titleEdgeInsets.left = 20
      instance.titleEdgeInsets.right = 20
      instance.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
      instance.imageView?.tintColor = .white
      instance.imageEdgeInsets.left = 8
      //            instance.imageEdgeInsets.right = 8
      instance.setAttributedTitle(attrString, for: .normal)
      instance.semanticContentAttribute = .forceRightToLeft
      instance.backgroundColor = Constants.UI.Colors.main//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
      
      let constraint = instance.widthAnchor.constraint(equalToConstant: state.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2)!))
      constraint.identifier = "width"
      constraint.isActive = true
      
      observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
        guard let self = self,
              let newValue = change.newValue
        else { return }
        
        view.cornerRadius = newValue.height/2.25
        self.setNeedsLayout()
        constraint.constant = self.state.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (view.imageView?.bounds.width ?? 0) + 60
        self.layoutIfNeeded()
      })
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
  
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      textView,
      label,
      bottomContainer
    ])
    instance.axis = .vertical
    instance.spacing = padding
    
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
    
//    setupUI()
//    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Constants.UI.Colors.main
    
    if #available(iOS 15, *) {
      guard !actionButton.configuration.isNil else { return }
      actionButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : Constants.UI.Colors.main
    } else {
      actionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
    }
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
  }
}

extension FeedbackView: FeedbackControllerOutput {}

private extension FeedbackView {
  func setupUI() {
    backgroundColor = .systemBackground
    
    addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding),
      stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding),
      stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding),
      textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),
    ])
    
    let touch = UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard))
    addGestureRecognizer(touch)
  }
  
  func setTasks() {
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.System.FeedbackSent) {
        guard let self = self else { return }
        
        self.onSuccessCallback()
      }
    })
    //Error
    tasks.append(Task { @MainActor [weak self] in
      for await _ in NotificationCenter.default.notifications(for: Notifications.System.FeedbackFailure) {
        guard let self = self else { return }
        
        self.onFailureCallback()
      }
    })
  }
  
  func onSuccessCallback() {
    state = .Back
    actionButton.isUserInteractionEnabled = true
    
    textView.isEditable = false
    
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "envelope.fill")!,
                                                          text: "feedback_sent",
                                                          tintColor: .systemGreen,
                                                          fontName: Fonts.Regular,
                                                          textStyle: .headline),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: true,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &subscriptions)
    
    //        showBanner(bannerDelegate: self, text: "feedback_sent".localized,
    //                   content: UIImageView(image: UIImage(systemName: "envelope.fill",
    //                                                       withConfiguration: UIImage.SymbolConfiguration(scale: .small))),
    //                   color: UIColor.white,
    //                   textColor: .white,
    //                   dismissAfter: 0.75,
    //                   backgroundColor: UIColor.systemGreen,
    //                   shadowed: true)
    
    if #available(iOS 15, *) {
      guard !actionButton.configuration.isNil else { return }
      
      let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      self.actionButton.configuration!.showsActivityIndicator = false
//      self.actionButton.configuration!.imagePlacement = .leading
      UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
        self.actionButton.configuration!.attributedTitle = attrString
        self.actionButton.configuration!.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
      }
    } else {
      guard let indicator = actionButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
      
      UIView.animate(withDuration: 0.25) {
        indicator.alpha = 0
      } completion: { _ in
        indicator.removeFromSuperview()
        let attrString = NSMutableAttributedString(string: self.state.rawValue.localized.uppercased(), attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        //                self.actionButton.semanticContentAttribute = .forceLeftToRight
        self.actionButton.titleEdgeInsets.left = 20
        self.actionButton.titleEdgeInsets.right = 20
        self.actionButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        self.actionButton.imageView?.tintColor = .white
        self.actionButton.imageEdgeInsets.left = 8
        self.actionButton.setAttributedTitle(attrString, for: .normal)
        self.actionButton.semanticContentAttribute = .forceRightToLeft
      }
    }
  }
  
  func onFailureCallback() {
    state = .Send
    actionButton.isUserInteractionEnabled = true
    
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          text: AppError.server.localizedDescription.localized,
                                                          tintColor: .systemRed,
                                                          fontName: Fonts.Regular,
                                                          textStyle: .headline),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: true,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
    
    if #available(iOS 15, *) {
      guard !actionButton.configuration.isNil else { return }
      
      let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.white
      ]))
      self.actionButton.configuration!.showsActivityIndicator = false
      UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
        self.actionButton.configuration!.attributedTitle = attrString
        self.actionButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
      }
    } else {
      guard let indicator = actionButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
      
      UIView.animate(withDuration: 0.2) {
        indicator.alpha = 0
      } completion: { _ in
        indicator.removeFromSuperview()
        let attrString = NSMutableAttributedString(string: self.state.rawValue.localized.uppercased(), attributes: [
          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
          NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        self.actionButton.titleEdgeInsets.left = 20
        self.actionButton.titleEdgeInsets.right = 20
        self.actionButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        self.actionButton.imageView?.tintColor = .white
        self.actionButton.imageEdgeInsets.left = 8
        self.actionButton.setAttributedTitle(attrString, for: .normal)
        self.actionButton.semanticContentAttribute = .forceRightToLeft
      }
    }
  }
  
  @objc
  private func send() {
    
    endEditing(true)
    
    switch state {
    case .Send:
      
      state = .Sending
      viewInput?.sendFeedback(textView.text)
      actionButton.isUserInteractionEnabled = false
      
      if #available(iOS 15, *) {
        if !actionButton.configuration.isNil {
          let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
            NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.white
          ]))
          UIView.transition(with: actionButton, duration: 0.15, options: .transitionCrossDissolve) {
            self.actionButton.configuration!.attributedTitle = attrString
          }
          actionButton.configuration!.showsActivityIndicator = true
          //                delayAsync(delay: 2) { [weak self] in
          //                    self?.onSuccessCallback()
          //                }
        }
      } else {
        actionButton.setImage(UIImage(), for: .normal)
        actionButton.setAttributedTitle(nil, for: .normal)
        let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                              size: CGSize(width: actionButton.frame.height,
                                                                           height: actionButton.frame.height)))
        indicator.alpha = 0
        indicator.layoutCentered(in: actionButton)
        indicator.startAnimating()
        indicator.color = .white
        indicator.accessibilityIdentifier = "indicator"
        UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        
        //        delayAsync(delay: 2) { [weak self] in
        ////            self?.onSuccessCallback()
        //            self?.onFailureCallback()
        //        }
      }
    case .Back:
      viewInput?.navigationController?.popViewController(animated: true)
    default:
      print("")
    }
  }
  
  @objc
  func hideKeyboard() {
    endEditing(true)
  }
}
