//
//  EmailVerificationPopupContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.05.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine

class EmailVerificationPopupContent: UIView {
  enum Mode { case ForceSelect, Default }
 
  
  
  // MARK: - Public properties
  public let verifiedPublisher = PassthroughSubject<Void, Never>()
  public let retryPublisher = PassthroughSubject<Void, Never>()
  public let cancelPublisher = PassthroughSubject<Void, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let retryTimeout: Int
  private var code: Int
  private let email: String
  private var input: String = "" {
    didSet {
      guard let intValue = Int(input) else { return }
      
      if input.count == 4, intValue != code {
        UIView.animate(withDuration: 0.2) { [unowned self] in self.label.alpha = 1 }
      } else if input.count < 4 {
        UIView.animate(withDuration: 0.2) { [unowned self] in self.label.alpha = 0 }
      } else {
        textField_4.resignFirstResponder()
        verifiedPublisher.send()
        verifiedPublisher.send(completion: .finished)
      }
    }
  }
  ///**UI**
  private let padding: CGFloat
  private let color: UIColor
  private let canCancel: Bool
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.alpha = 0
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)
    instance.text = "invalid_verification_code".localized.lowercased()
    instance.textColor = .systemRed
    
    return instance
  }()
  private lazy var mailNotDeliveredLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .center
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)
    instance.text = "email_not_delivered".localized
    instance.textColor = .secondaryLabel
    
    return instance
  }()
  private lazy var retryLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .center
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)
    instance.text = "repeat_after".localized + String(describing: retryTimeout)
    instance.textColor = .secondaryLabel
    
    return instance
  }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.isUserInteractionEnabled = false
    instance.backgroundColor = .clear
//    instance.textContainerInset = UIEdgeInsets(top: padding*2,
//                                               left: 0,
//                                               bottom: padding*2,
//                                               right: 0)
    let paragraph = NSMutableParagraphStyle()
    if #available(iOS 15.0, *) {
        paragraph.usesDefaultHyphenation = true
    } else {
      paragraph.hyphenationFactor = 1
    }
    paragraph.alignment = .natural
    paragraph.firstLineHeadIndent = padding * 2
    let constraint = instance.heightAnchor.constraint(equalToConstant: 10)
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize, options: .new) { [weak self] view, value in
      guard let self = self,
            let height = value.newValue?.height,
            constraint.constant != height
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = height
      self.layoutIfNeeded()
    })
    var attrString = NSMutableAttributedString(string: "email_verification_code_sent".localized,
                                               attributes: [
                                                .paragraphStyle: paragraph,
                                                .font: UIFont(name: Fonts.Regular, size: 14) as Any,
                                                .foregroundColor: UIColor.label
                                               ])
    attrString.append(NSMutableAttributedString(string: " \(email)",
                                                attributes: [
                                                  .paragraphStyle: paragraph,
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.label
                                                ]))
    instance.attributedText = attrString
    
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    top.heightAnchor.constraint(equalToConstant: 60).isActive = true
    tagCapsule.placeInCenter(of: top)//,
//                        topInset: padding*2,
//                        bottomInset: padding)
    
    let middle = UIView.opaque()
    let nested = UIStackView(arrangedSubviews: [
      textField_1,
      textField_2,
      textField_3,
      textField_4
    ])
    nested.spacing = padding*2
    nested.placeXCentered(inside: middle, topInset: padding*0, bottomInset: padding*0)
    let middle_2 = UIView.opaque()
    middle_2.heightAnchor.constraint(equalToConstant: padding*4).isActive = true
    label.placeInCenter(of: middle_2)
//    descriptionLabel.place(inside: middle2, insets: .init(top: padding*4, left: padding, bottom: padding, right: padding))
//    let bottom = UIView.opaque()
//    let buttonsStack = UIStackView(arrangedSubviews: [
//      confirmButton,
//    ])
//    buttonsStack.distribution = .fillEqually
//    buttonsStack.contentMode = .left
//    buttonsStack.axis = .horizontal
//    buttonsStack.spacing = 4
//    buttonsStack.placeInCenter(of: bottom,
//                        topInset: padding,
//                        bottomInset: padding)
    let bottom = UIView.opaque()
    let remains = UIStackView(arrangedSubviews: [
      mailNotDeliveredLabel,
      retryLabel
    ])
    if canCancel {
      let v = UIView.opaque()
      cancelButton.placeXCentered(inside: v, topInset: padding*2, bottomInset: -padding*2)
      remains.addArrangedSubview(v)
    }
    remains.spacing = padding/2
    remains.axis = .vertical
    remains.placeXCentered(inside: bottom, topInset: padding, bottomInset: 0)
    retryButton.placeInCenter(of: remains)
    
    let instance = UIStackView(arrangedSubviews: [
      top,
      UIView.verticalSpacer(padding*4),
      middle,
      middle_2,
      textView,
      bottom
//      middle,
//      middle2,
//      bottom
    ])
    
    instance.axis = .vertical
//    instance.spacing = padding*4
//    bottom.translatesAutoresizingMaskIntoConstraints = false
//    bottom.heightAnchor.constraint(equalTo: top.heightAnchor).isActive = true
    
    return instance
  }()
  private lazy var tagCapsule: TagCapsule = { TagCapsule(text: "verification_code".localized.uppercased(),
                                                         padding: padding,
                                                         textPadding: .uniform(size: padding),
                                                         color: color,
                                                         font: UIFont(name: Fonts.Rubik.SemiBold, size: 20)!,
                                                         iconCategory: .Key) }()
  private lazy var textField_1: UITextField = {
    let instance = UITextField()
    instance.delegate = self
    instance.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    instance.textAlignment = .center
    instance.tintColor = color
    instance.keyboardType = .numberPad
    instance.font = UIFont.scaledFont(fontName: Fonts.Extrabold, forTextStyle: .largeTitle)
    instance.backgroundColor = .systemGray.withAlphaComponent(0.1)
    instance.widthAnchor.constraint(equalToConstant: "9".width(withConstrainedHeight: 100, font: instance.font!) + padding*2).isActive = true
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height * 0.05}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var textField_2: UITextField = {
    let instance = UITextField()
    instance.delegate = self
    instance.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    instance.textAlignment = .center
    instance.tintColor = color
    instance.keyboardType = .numberPad
    instance.font = UIFont.scaledFont(fontName: Fonts.Extrabold, forTextStyle: .largeTitle)
    instance.backgroundColor = .systemGray.withAlphaComponent(0.1)
    instance.widthAnchor.constraint(equalToConstant: "9".width(withConstrainedHeight: 100, font: instance.font!) + padding*2).isActive = true
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height * 0.05}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var textField_3: UITextField = {
    let instance = UITextField()
    instance.delegate = self
    instance.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    instance.textAlignment = .center
    instance.tintColor = color
    instance.keyboardType = .numberPad
    instance.font = UIFont.scaledFont(fontName: Fonts.Extrabold, forTextStyle: .largeTitle)
    instance.backgroundColor = .systemGray.withAlphaComponent(0.1)
    instance.widthAnchor.constraint(equalToConstant: "9".width(withConstrainedHeight: 100, font: instance.font!) + padding*2).isActive = true
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height * 0.05}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var textField_4: UITextField = {
    let instance = UITextField()
    instance.delegate = self
    instance.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    instance.textAlignment = .center
    instance.tintColor = color
    instance.keyboardType = .numberPad
    instance.font = UIFont.scaledFont(fontName: Fonts.Extrabold, forTextStyle: .largeTitle)
    instance.backgroundColor = .systemGray.withAlphaComponent(0.1)
    instance.widthAnchor.constraint(equalToConstant: "9".width(withConstrainedHeight: 100, font: instance.font!) + padding*2).isActive = true
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height * 0.05}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var retryButton: UIButton = {
    let instance = UIButton()
    instance.alpha = 0
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    instance.setAttributedTitle(NSAttributedString(string: "resend_mail".localized,
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.SemiBold, size: 20) as Any,
                                                    .foregroundColor: color as Any
                                                   ]),
                                for: .normal)
    
    return instance
  }()
  private lazy var cancelButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.cancel),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets = .uniform(size: 0)
      config.attributedTitle = AttributedString("cancel".localized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.secondaryLabel as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.contentEdgeInsets = .uniform(size: 0)
      instance.setAttributedTitle(NSAttributedString(string: "cancel".localized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
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
  init(code: Int,
       retryTimeout: Int,
       email: String,
       color: UIColor,
       padding: CGFloat = 8,
       canCancel: Bool = false) {
    self.canCancel = canCancel
    self.email = email
    self.code = code
    self.retryTimeout = retryTimeout
    self.color = color
    self.padding = padding
    
    super.init(frame: .zero)
    
    setupUI()
    
//    textField_1.becomeFirstResponder()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  public func onEmailSent(_ code: Int) {
    self.code = code
    countdown()
  }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    

  }
}

private extension EmailVerificationPopupContent {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
    
    countdown()
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
    retryPublisher.send()
    textField_1.text = ""
    textField_2.text = ""
    textField_3.text = ""
    textField_4.text = ""
  }
  
  @objc
  func cancel() {
    cancelPublisher.send()
  }
  
  func countdown() {
    self.retryLabel.text = "repeat_after".localized + String(describing: retryTimeout)
    self.retryLabel.alpha = 1
    self.mailNotDeliveredLabel.alpha = 1
    self.retryButton.alpha = 0
    
    Publishers.countdown(queue: .main,
                         interval: .seconds(1),
                         times: .max(retryTimeout))
    .sink { [unowned self] int in
      guard int == 1 else {
        self.retryLabel.text = "repeat_after".localized + String(describing: int)
        
        return
      }
      
      self.retryLabel.text = "repeat_after".localized + "1"
      delay(seconds: 1) {
        self.retryLabel.alpha = 0
        self.mailNotDeliveredLabel.alpha = 0
        self.retryButton.alpha = 1
      }
    }
    .store(in: &subscriptions)
  }
  
  func attributes() -> [NSAttributedString.Key: Any] {
    let font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
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
    guard let isEmpty = textField.text?.isEmpty,
          let digit_1 = textField_1.text,
          let digit_2 = textField_2.text,
          let digit_3 = textField_3.text,
          let digit_4 = textField_4.text
    else { return }
    
    if textField === textField_1, !isEmpty {
      textField_2.becomeFirstResponder()
    } else if textField === textField_2, !isEmpty {
      textField_3.becomeFirstResponder()
    } else if textField === textField_3, !isEmpty {
      textField_4.becomeFirstResponder()
    }
    input = (digit_1+digit_2+digit_3+digit_4).replacingOccurrences(of: " ", with: "")
  }
}

extension EmailVerificationPopupContent: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text,
          (text + string).count < 2
    else { return false }
    
    if string.isEmpty {
      textField_1.text = ""
      textField_2.text = ""
      textField_3.text = ""
      textField_4.text = ""
      textField_1.becomeFirstResponder()
      UIView.animate(withDuration: 0.2) { [unowned self] in self.label.alpha = 0 }
    }
//
//    if textField === textField_2, string.isEmpty {
//      textField_1.becomeFirstResponder()
//      textField_2.text = ""
//    } else if textField === textField_3, string.isEmpty {
//      textField_2.becomeFirstResponder()
////      textField_3.text = ""
//    } else if textField === textField_4, string.isEmpty {
////      textField_4.text = ""
//      textField_3.becomeFirstResponder()
//    }
    if let digit_1 = textField_1.text,
       let digit_2 = textField_2.text,
       let digit_3 = textField_3.text,
       let digit_4 = textField_4.text
    {
      input = (digit_1+digit_2+digit_3+digit_4).replacingOccurrences(of: " ", with: "")
    }
    
    return true
  }
}

