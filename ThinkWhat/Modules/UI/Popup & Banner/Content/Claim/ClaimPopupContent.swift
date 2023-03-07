//
//  ClaimPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import CoreData

class ClaimPopupContent: UIView {
  
  // MARK: - Public properties
  ///**Publishers**
  @Published public private(set) var claim: [SurveyReference: Claim]?
  @Published private var item: Claim?
  
  // MARK: - Private properties
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let surveyReference: SurveyReference
  private weak var parent: NewPopup?
  private var state: ButtonState = .Send
  ///**UI**
  private let padding: CGFloat
  private lazy var collectionView: ClaimCollectionView = {
    let instance = ClaimCollectionView()
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.isActive = true
    instance.$claim
      .filter { !$0.isNil }
      .assign(to: &self.$item)
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero }
      .sink { [unowned self] size in
        self.setNeedsLayout()
        constraint.constant = size.height
        self.setNeedsLayout()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var label: UIStackView = {
    let label = InsetLabel()
    label.font = UIFont(name: Fonts.Bold, size: 20)
    label.text = "claim".localized.uppercased()
    label.textColor = .white
    label.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill",
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
    instance.backgroundColor = .systemRed
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    return instance
  }()
  private lazy var sentLabel: UILabel = {
    let instance = UILabel()
    instance.alpha = 0
    instance.numberOfLines = 0
    instance.textAlignment = .center
    
    let textContent_1 = "claim_sent".localized + "\n" + "\n"
    let textContent_2 = "thanks_for_feedback".localized
    let paragraph = NSMutableParagraphStyle()
    
    if #available(iOS 15.0, *) {
      paragraph.usesDefaultHyphenation = true
    } else {
      paragraph.hyphenationFactor = 1
    }
    paragraph.alignment = .center
    
    let attributedString = NSMutableAttributedString()
    attributedString.append(NSAttributedString(string: textContent_1,
                                               attributes: [
                                                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title1) as Any,
                                                NSAttributedString.Key.foregroundColor: UIColor.label,
                                               ] as [NSAttributedString.Key : Any]))
    
    attributedString.append(NSAttributedString(string: textContent_2,
                                               attributes: [
                                                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title2) as Any,
                                                NSAttributedString.Key.foregroundColor: UIColor.label,
                                               ] as [NSAttributedString.Key : Any]))
    instance.attributedText = attributedString
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    label.placeInCenter(of: top,
                        topInset: padding*2,
                        bottomInset: padding)
    
    let bottom = UIView.opaque()
    let buttonsStack = UIStackView(arrangedSubviews: [
      confirmButton,
      cancelButton
    ])
    buttonsStack.accessibilityIdentifier = "buttonsStack"
    buttonsStack.distribution = .fillEqually
    buttonsStack.contentMode = .left
    buttonsStack.axis = .horizontal
    buttonsStack.spacing = 4
    buttonsStack.placeInCenter(of: bottom,
                               topInset: padding,
                               bottomInset: padding)
    let middle = UIView.opaque()
    middle.accessibilityIdentifier = "middle"
    middle.translatesAutoresizingMaskIntoConstraints = false
    
    collectionView.place(inside: middle,
                         bottomPriority: .defaultLow)
    middle.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      middle,
      bottom
    ])
    instance.axis = .vertical
    instance.spacing = padding
    bottom.translatesAutoresizingMaskIntoConstraints = false
    bottom.heightAnchor.constraint(equalTo: top.heightAnchor).isActive = true
    
    return instance
  }()
  private lazy var icon: Icon = {
    let instance = Icon()
    instance.backgroundColor = .clear
    instance.isRounded = false
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.scaleMultiplicator = 0.8
    instance.iconColor = .systemRed//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
    instance.category = .ExclamationMark
    
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
      config.baseBackgroundColor = .systemGray
      config.imagePlacement = .trailing
      config.imagePadding = padding
      config.attributedTitle = AttributedString("sendButton".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
      instance.imageEdgeInsets.left = padding
      
    } else {
      instance.semanticContentAttribute = .forceRightToLeft
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "sendButton".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                                      .foregroundColor: UIColor.systemRed as Any
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
  
  
  // MARK: - Destructor
  deinit {
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Initialization
  init(parent: NewPopup,
       surveyReference: SurveyReference,
       padding: CGFloat = 8) {
    self.padding = padding
    self.surveyReference = surveyReference
    self.parent = parent
    
    super.init(frame: .zero)
    
    setupUI()
    setTasks()
    setSubscriptions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }
}

private extension ClaimPopupContent {
  @MainActor
  func setupUI() {
    stack.place(inside: self)
  }
  
  func setSubscriptions() {
    $item
      .filter { !$0.isNil }
      .sink { [unowned self] _ in
        UIView.animate(withDuration: 0.2) { [unowned self] in
          if #available(iOS 15, *) {
            self.confirmButton.configuration?.baseBackgroundColor = .systemRed
          } else { self.confirmButton.backgroundColor = .systemRed }
        }
      }
      .store(in: &subscriptions)
    
    surveyReference.isClaimedPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        if case .failure(let error) = $0 {
          self.onFailureCallback()
#if DEBUG
          error.printLocalized(class: type(of: self), functionName: #function)
#endif
        }
      } receiveValue: { [unowned self] _ in
        self.onSuccessCallback()
      }
      .store(in: &subscriptions)
  }
  
  func setTasks() {
    tasks.append(Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.Claim) {
        guard let self = self,
              let instance = notification.object as? Comment,
              instance.survey?.reference == self.surveyReference
        else { return }
        
        self.onSuccessCallback()
      }
    })
    tasks.append( Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Comments.ClaimFailure) {
        guard let self = self,
              let instance = notification.object as? Comment,
              instance.survey?.reference == self.surveyReference
        else { return }
        
        self.onFailureCallback()
      }
    })
  }
  
  func onSuccessCallback() {
    
    guard let buttonsStack = stack.getSubview(type: UIStackView.self, identifier: "buttonsStack"),
          let middle = stack.getSubview(type: UIView.self, identifier: "middle")
    else { return }
    
    buttonsStack.removeArrangedSubview(cancelButton)
    cancelButton.removeFromSuperview()
    
    state = .Close
    confirmButton.isUserInteractionEnabled = true
    sentLabel.place(inside: middle)
    sentLabel.transform = .init(scaleX: 0.75, y: 0.75)
    
    UIView.animate(withDuration: 0.3, animations: { [unowned self] in
      self.collectionView.alpha = 0
      self.collectionView.transform = .init(scaleX: 0.75, y: 0.75)
      self.sentLabel.alpha = 1
      self.sentLabel.transform = .identity
    }) { _ in
      
    }
    
    if #available(iOS 15, *) {
      let attrString = AttributedString("continueButton".localized,
                                        attributes: AttributeContainer([
                                          .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                          .foregroundColor: UIColor.white as Any
                                        ]))
      confirmButton.configuration?.showsActivityIndicator = false
      UIView.transition(with: self.confirmButton, duration: 0.15, options: .transitionCrossDissolve) { [unowned self] in
        self.confirmButton.configuration?.attributedTitle = attrString
      }
    } else {
      guard let indicator = confirmButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
      
      UIView.animate(withDuration: 0.2) {
        indicator.alpha = 0
      } completion: { _ in
        indicator.removeFromSuperview()
        let attrString = NSAttributedString(string: "continueButton".localized,
                                            attributes: [
                                              .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                              .foregroundColor: UIColor.secondaryLabel as Any
                                            ])
        self.confirmButton.imageView?.tintColor = .white
        self.confirmButton.imageEdgeInsets.left = 8
        self.confirmButton.setAttributedTitle(attrString, for: .normal)
      }
    }
    
    //    //Path animation
    //    let pathAnim = Animations.get(property: .Path, fromValue: (self.icon.icon as! CAShapeLayer).path!, toValue: (self.icon.getLayer(.Letter) as! CAShapeLayer).path!, duration: 0.5, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: nil, isRemovedOnCompletion: false)
    //    self.icon.icon.add(pathAnim, forKey: nil)
    //
    //    self.parent?.resize(400, animationDuration: 0.7)
    //
    //    //Hide close btn
    //    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: { [weak self] in
    //      guard let self = self else { return }
    //
    //      self.collectionView.alpha = 0
    //      self.closeButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    //      self.closeButton.alpha = 0
    //    }) { _ in
    //      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0) { [weak self] in
    //        guard let self = self else { return }
    //
    //        self._label.alpha = 1
    //      }
    //    }
    //
    //    if #available(iOS 15, *) {
    //      guard !actionButton.configuration.isNil else { return }
    //
    //      let attrString = AttributedString(state.rawValue.localized.uppercased(), attributes: AttributeContainer([
    //        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
    //        NSAttributedString.Key.foregroundColor: UIColor.white
    //      ]))
    //      self.actionButton.configuration!.showsActivityIndicator = false
    //      UIView.transition(with: self.actionButton, duration: 0.15, options: .transitionCrossDissolve) {
    //        self.actionButton.configuration!.attributedTitle = attrString
    //        self.actionButton.configuration!.image = UIImage(systemName: "arrow.forward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
    //      }
    //    } else {
    //      guard let indicator = actionButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
    //
    //      UIView.animate(withDuration: 0.25) {
    //        indicator.alpha = 0
    //      } completion: { _ in
    //        indicator.removeFromSuperview()
    //        let attrString = NSMutableAttributedString(string: self.state.rawValue.localized.uppercased(), attributes: [
    //          NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title2) as Any,
    //          NSAttributedString.Key.foregroundColor: UIColor.white
    //        ])
    //        self.actionButton.titleEdgeInsets.left = 20
    //        self.actionButton.titleEdgeInsets.right = 20
    //        self.actionButton.setImage(UIImage(systemName: "arrow.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
    //        self.actionButton.imageView?.tintColor = .white
    //        self.actionButton.imageEdgeInsets.left = 8
    //        self.actionButton.setAttributedTitle(attrString, for: .normal)
    //        self.actionButton.semanticContentAttribute = .forceRightToLeft
    //      }
    //    }
  }
  
  func onFailureCallback() {
    state = .Send
    confirmButton.isUserInteractionEnabled = true
    collectionView.isUserInteractionEnabled = true
    
    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                          icon: Icon.init(category: .Logo,
                                                                          scaleMultiplicator: 1.5,
                                                                          iconColor: .systemRed),
                                                          text: AppError.server.localizedDescription.localized,
                                                          tintColor: .clear,
                                                          fontName: Fonts.Regular,
                                                          textStyle: .headline,
                                                          textAlignment: .natural),
                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                           isModal: false,
                           isShadowed: false,
                           useContentViewHeight: true,
                           shouldDismissAfter: 2)
    banner.didDisappearPublisher
      .sink { _ in banner.removeFromSuperview() }
      .store(in: &self.subscriptions)
    
    if #available(iOS 15, *) {
      let attrString = AttributedString("sendButton".localized,
                                        attributes: AttributeContainer([
                                          .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                          .foregroundColor: UIColor.white as Any
                                        ]))
      self.confirmButton.configuration?.showsActivityIndicator = false
      UIView.transition(with: self.confirmButton, duration: 0.15, options: .transitionCrossDissolve) { [unowned self] in
        self.confirmButton.configuration?.attributedTitle = attrString
      }
    } else {
      guard let indicator = confirmButton.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator") else { return }
      
      UIView.animate(withDuration: 0.2) {
        indicator.alpha = 0
      } completion: { _ in
        indicator.removeFromSuperview()
        let attrString = NSAttributedString(string: "sendButton".localized,
                                            attributes: [
                                              .font: UIFont(name: Fonts.Semibold, size: 20) as Any,
                                              .foregroundColor: UIColor.secondaryLabel as Any
                                            ])
        self.confirmButton.imageView?.tintColor = .white
        self.confirmButton.imageEdgeInsets.left = 8
        self.confirmButton.setAttributedTitle(attrString, for: .normal)
        self.confirmButton.semanticContentAttribute = .forceRightToLeft
      }
    }
  }
  
  @objc
  func handleTap(sender: UIButton) {
    guard state != .Sending else { return }
    
    switch state {
    case .Send:
      if let item = item, sender == confirmButton {
        state = .Sending
        collectionView.isUserInteractionEnabled = false
        confirmButton.isUserInteractionEnabled = false
        claim = [surveyReference: item]
        if #available(iOS 15, *) {
          let attrString = AttributedString(state.rawValue.localized,
                                            attributes: AttributeContainer([
                                              NSAttributedString.Key.font: UIFont(name: Fonts.OpenSans.Semibold.rawValue, size: 20) as Any,
                                              NSAttributedString.Key.foregroundColor: UIColor.white
                                            ]))
          UIView.transition(with: confirmButton, duration: 0.15, options: .transitionCrossDissolve) { [unowned self] in
            self.confirmButton.configuration!.attributedTitle = attrString
          }
          confirmButton.configuration?.showsActivityIndicator = true
        } else {
          confirmButton.setImage(UIImage(), for: .normal)
          confirmButton.setAttributedTitle(nil, for: .normal)
          let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                size: CGSize(width: confirmButton.frame.height,
                                                                             height: confirmButton.frame.height)))
          indicator.alpha = 0
          indicator.layoutCentered(in: confirmButton)
          indicator.startAnimating()
          indicator.color = .white
          indicator.accessibilityIdentifier = "indicator"
          UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        }
      } else {
        parent?.dismiss()
      }
    default:
      parent?.dismiss()
    }
  }
}
