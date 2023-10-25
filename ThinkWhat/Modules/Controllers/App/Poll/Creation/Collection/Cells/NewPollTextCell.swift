//
//  NewPollTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollTextCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage! {
    didSet {
      guard !stage.isNil, oldValue != stage else { return }
      
      setupUI()
    }
  }
  public var stageGlobal: NewPollController.Stage!
  public var isKeyboardOnScreen: Bool = false
  public var externalSubscriptions = Set<AnyCancellable>()
  ///**UI**
  public var textAlignment: NSTextAlignment = .center
  public var placeholderFont: UIFont! {
    didSet {
      //      guard !stage.isNil else { return }
      //
      //      textView.font = placeholderFont
      //      placeholder.font = placeholderFont
    }
  }
  public var font: UIFont! //{
  //    didSet {
  //      guard !stage.isNil else { return }
  //
  //      textView.font = font
  //    }
  //  }
  public var minHeight: CGFloat = 0
  public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      textView.tintColor = color
      fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      
      UIView.animate(withDuration: 0.2) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
        
        guard let imageView = self.contentView.getSubview(type: UIImageView.self, identifier: "imageView") else { return }
        
        imageView.tintColor = self.color
      }
      
      let colorAnim = CABasicAnimation(path: "strokeColor", fromValue: fgLine.layer.strokeColor, toValue: color.cgColor, duration: 0.4)
      colorAnim.delegate = self
      colorAnim.setValue({ [weak self] in
        guard let self = self else { return }
        
        self.fgLine.layer.removeAnimation(forKey: "color")
      }, forKey: "completion")
      
      fgLine.layer.strokeColor = color.cgColor
      
      guard let toolBar = textView.inputAccessoryView as? UIToolbar else { return }
      
      toolBar.tintColor = color
    }
  }
  public var isMovingToParent = false
  ///**Publishers**
  public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var stageCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var firstResponderPublisher = PassthroughSubject<Bool, Never>()
  @Published public var text: String! {
    didSet {
      updateUI()
      guard text != oldValue else { return }
      
      guard stage == stageGlobal else { return }
      
      stageCompletePublisher.send()
      stageCompletePublisher.send(completion: .finished)
      
      UIView.transition(with: self.label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
      } completion: { _ in }
      
      if oldValue.isNil || oldValue.isEmpty {
        CATransaction.begin()
        CATransaction.setCompletionBlock() { [unowned self] in
          self.animationCompletePublisher.send()
          self.animationCompletePublisher.send(completion: .finished)
        }
        fgLine.layer.strokeColor = color.cgColor
        fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
        CATransaction.commit()
      }
      
      UIView.animate(withDuration: 0.2) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
      }
    }
  }
  public private(set) var boundsPublisher = PassthroughSubject<CGRect, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var isBannerOnScreen = false
  private var isPresenting = false
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: stage.numImage)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.tintColor = .systemGray4
    instance.contentMode = .scaleAspectFit
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    instance.text = stage.title.uppercased()
    
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    //    instance.publisher(for: \.bounds)
    //      .sink {
    //        print($0)
    //      }
    //      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var fgLine: Line = {
    let instance = Line()
    instance.layer.strokeColor = Constants.UI.Colors.Logo.Flame.rawValue.cgColor
    
    return instance
  }()
  private lazy var bgLine: Line = {
    let instance = Line()
    instance.layer.strokeColor = UIColor.systemGray4.cgColor
    
    return instance
  }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.textContainerInset = .uniform(size: padding)//.init(top: padding*2, left: padding, bottom: padding*2, right: padding)
    instance.delegate = self
//    instance.layer.borderWidth = 0
//    instance.layer.borderColor = UIColor.systemGray5.cgColor
    //    instance.textContainerInset = .uniform(size: .zero)
    instance.isUserInteractionEnabled = true
    //    instance.isScrollEnabled = false
    instance.backgroundColor = .clear// traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.isEditable = true
    instance.isSelectable = true
    //    instance.font = placeholderFont// UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .body)//font
    instance.text = (text.isNil || text.isEmpty) ? "\n" : text
    instance.textColor = (text.isNil || text.isEmpty) ? .clear : .label
    instance.textAlignment = textAlignment
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
    toolBar.tintColor = color
    instance.inputAccessoryView = toolBar
    instance.publisher(for: \.bounds)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.bgLayer.frame = $0
        self.bgLayer.cornerRadius = $0.width*0.025
        self.fgLayer.frame = $0
        self.fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
//    instance.publisher(for: \.bounds)
//      .sink { instance.cornerRadius = $0.width*0.025 }
//      .store(in: &subscriptions)
    
    //    let v = UIView()
    //    v.backgroundColor = .red
    //    v.placeXCentered(inside: instance, topInset: 0, size: .uniform(size: 50))
    //    placeholder.placeInCenter(of: instance, heightMultiplier: 1.1)
    
    //    placeholder.translatesAutoresizingMaskIntoConstraints = false
    //    instance.addSubview(placeholder)
    //    NSLayoutConstraint.activate([
    //      placeholder.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
    //      placeholder.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
    //      placeholder.topAnchor.constraint(equalTo: instance.topAnchor),
    ////      placeholder.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
    //    ])
    //
    //    let placeholderConstraint = placeholder.heightAnchor.constraint(equalToConstant: 10)
    //    placeholderConstraint.isActive = true
    
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize, options: .new) { [weak self] _, change in
      guard let self = self,
            let value = change.newValue,
            constraint.constant != value.height
      else { return }
      
      UIView.animate(withDuration: 0.3) {
        self.setNeedsLayout()
        constraint.constant = value.height <= self.minHeight ? self.minHeight : value.height
        self.layoutIfNeeded()
      }
      self.boundsPublisher.send(.zero)
    })
    
    return instance
  }()
  private lazy var placeholder: InsetLabel = {
    let instance = InsetLabel()
    instance.insets = .uniform(size: padding)
    instance.numberOfLines = 0
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)//placeholderFont
    instance.text = stage.placeholder
    instance.textColor = .tertiaryLabel
    instance.textAlignment = .center
    
    return instance
  }()
  private lazy var bgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.backgroundColor = UIColor.clear.cgColor//(traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor

    return instance
  }()
  private lazy var fgLayer: CALayer = {
    let instance = CAShapeLayer()
    instance.opacity = 0
    instance.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
    
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    guard textView.isFirstResponder else { return }
    
    fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
//    textView.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    boundsPublisher = PassthroughSubject<CGRect, Never>()
    animationCompletePublisher = PassthroughSubject<Void, Never>()
    stageCompletePublisher = PassthroughSubject<Void, Never>()
    externalSubscriptions.forEach { $0.cancel() }
    firstResponderPublisher = PassthroughSubject<Bool, Never>()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    func disclose() {
      Animations.unmaskLayerCircled(layer: fgLayer,
                                    location: CGPoint(x: textView.bounds.midX, y: textView.bounds.midY),
                                    duration: 0.5,
                                    opacityDurationMultiplier: 0.6,
                                    delegate: self)
      
      bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
      
      UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.label.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption2)
      } completion: { _ in }
      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        guard let self = self else { return }
        
//        self.textView.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
        self.placeholder.textColor = .label
//        self.placeholder.transform = .init(scaleX: 1.025, y: 1.025)
      }) { [weak self] _ in
        guard let self = self else { return }
        
        UIView.animate(withDuration: 0.2, delay: 1.25, options: .curveEaseIn) {
          self.placeholder.alpha = 0
          self.placeholder.transform = .init(scaleX: 0.75, y: 0.75)
        } completion: { _ in
          self.textView.becomeFirstResponder()
          self.placeholder.removeFromSuperview()
          
          guard !self.textView.isFirstResponder else { return }
          
          self.textView.becomeFirstResponder()
        }
      }
    }
    
    isPresenting = true
    if seconds == .zero {
      disclose()
    } else {
      delay(seconds: seconds) {
        disclose()
      }
    }
  }
}

// MARK: - Private
private extension NewPollTextCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)
    addSubview(textView)
    textView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textView.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*3),
      textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
    constraint.isActive = true
    constraint.priority = .defaultLow
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
    
    guard stageGlobal.rawValue <= stage.rawValue else { return }
    
    addSubview(placeholder)
    placeholder.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      placeholder.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*3),
      placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      placeholder.heightAnchor.constraint(equalTo: textView.heightAnchor),
      placeholder.widthAnchor.constraint(equalTo: textView.widthAnchor)
    ])
    
//    let constraint_2 = placeholder.bottomAnchor.constraint(equalTo: nextButton.bottomAnchor)
//    constraint_2.isActive = true
    
//    collectionView.alpha = 0
//    buttonsStack.alpha = 0
  }
  
  func drawLine(line: Line,
                strokeEnd: CGFloat = 0,
                lineCap: CAShapeLayerLineCap = .round,
                xPoint: CGFloat? = nil) {
    let lineWidth = imageView.bounds.width*0.1
    let imageCenter = imageView.convert(imageView.center, to: contentView)
    let xPos = imageCenter.x
    let yPos = imageCenter.y + imageView.bounds.height/2 - lineWidth
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: xPos, y: yPos))
    path.addLine(to: CGPoint(x: xPos, y: xPoint ?? bounds.maxY + lineWidth))
    
    line.path = path
    line.layer.strokeStart = 0
    line.layer.strokeEnd = strokeEnd
    line.layer.lineCap = lineCap
    line.layer.lineWidth = lineWidth
    line.layer.path = line.path.cgPath
  }
  
  @objc
  func hideKeyboard() {
    endEditing(true)
  }
  
  @MainActor
  func updateUI() {
    if text.isNil || text.isEmpty {
//      placeholder.placeXCentered(inside: textView, widthMultiplier: 1)
//      placeholder.placeInCenter(of: textView)
      textView.font = placeholderFont
//      placeholder.font = placeholderFont
    } else {
      textView.font = font
    }
  }
}


extension NewPollTextCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}

extension NewPollTextCell: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        guard !isKeyboardOnScreen else { return false }
    guard stageGlobal == .Ready || stage == stageGlobal else { return false }
    
    if text.isNil || text.isEmpty {
      textView.font = font//UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .body)//font
      textView.text = ""
      textView.textColor = .label
    }
    
//    textView.layer.add(CABasicAnimation(path: "borderWidth", fromValue: 0, toValue: 1.5, duration: 0.2), forKey: nil)
//    textView.layer.add(CABasicAnimation(path: "borderColor", fromValue: textView.layer.borderColor, toValue: color.cgColor, duration: 0.2), forKey: nil)
    
    if !isPresenting {
      Animations.unmaskLayerCircled(layer: fgLayer,
                                    location: .init(x: textView.bounds.midX, y: textView.bounds.midY),
                                    duration: 0.5,
                                    opacityDurationMultiplier: 0.6,
                                    delegate: self)
      
      bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    }
    
    guard let imageView = self.contentView.getSubview(type: UIImageView.self,
                                                      identifier: "imageView")
    else {
      firstResponderPublisher.send(true)
      return true
    }
    
    UIView.animate(withDuration: 0.2, animations: { [unowned self] in
//      textView.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
      
      imageView.alpha = 0
      imageView.transform = .init(scaleX: 0.75, y: 0.75)
    }) { _ in
      guard let imageView = self.contentView.getSubview(type: UIImageView.self, identifier: "imageView") else { return }
      
      imageView.removeFromSuperview()
    }
    
    firstResponderPublisher.send(true)
    return true
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    guard !isMovingToParent else {
      //      UIView.animate(withDuration: 0.2, animations: { [unowned self] in
      //        textView.backgroundColor = .clear//self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground }//.systemGray4.withAlphaComponent(0.2)
      //        guard let imageView = self.contentView.getSubview(type: UIImageView.self, identifier: "imageView") else { return }
      //
      //        imageView.alpha = 0
      //        imageView.transform = .init(scaleX: 0.75, y: 0.75)
      //      }) { _ in
      //        guard let imageView = self.contentView.getSubview(type: UIImageView.self, identifier: "imageView") else { return }
      //
      //        imageView.removeFromSuperview()
      //      }
      return true
    }
    
    guard textView.text.count >= stage.minLength else {
      guard !isBannerOnScreen else { return false }
      
      isBannerOnScreen = true
      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                            text: "new_poll_survey_min_text_length_error_begin".localized + String(describing: stage.minLength) + "new_poll_survey_min_text_length_error_end".localized,
                                                            tintColor: .systemOrange,
                                                            fontName: Fonts.Semibold,
                                                            textStyle: .headline,
                                                            textAlignment: .natural),
                             contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                             isModal: false,
                             useContentViewHeight: true,
                             shouldDismissAfter: 2)
      banner.didDisappearPublisher
        .sink { _ in banner.removeFromSuperview(); self.isBannerOnScreen = false }
        .store(in: &self.subscriptions)
      
      return false
    }
    if self.text.isNil {
      drawLine(line: bgLine, strokeEnd: 1)
      drawLine(line: fgLine)
    }
    
    
    Animations.unmaskLayerCircled(unmask: false,
                                  layer: fgLayer,
                                  location: .init(x: textView.bounds.midX, y: textView.bounds.midY),
                                  duration: 0.35,
                                  animateOpacity: false,
                                  delegate: self)
    
    bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 0, toValue: 1, duration: 0.5), forKey: nil)
    isPresenting = false
    
//    textView.layer.add(CABasicAnimation(path: "borderWidth", fromValue: 1.5, toValue: 0, duration: 0.2), forKey: nil)
    
//    UIView.animate(withDuration: 0.2, animations: {
//      textView.backgroundColor = .clear//self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }) { [unowned self] _ in
      guard let endPosition = self.textView.position(from: self.textView.endOfDocument, offset: 0),
            let textRange = self.textView.textRange(from: endPosition, to: endPosition)
      else { return true }
      
      let rect = self.textView.firstRect(for: textRange)
      let test = UIView(frame: CGRect(origin: rect.origin, size: .uniform(size: rect.size.height)))
      test.alpha = 0
      self.textView.addSubview(test)
      
      let convertedOrigin = self.textView.convert(test.frame.origin, to: self.contentView)
      test.removeFromSuperview()
      
      let imageView = UIImageView(frame: CGRect(origin: convertedOrigin,
                                                size: .uniform(size: rect.size.height)))
      imageView.image = UIImage(systemName: "pencil",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.size.height * 0.75, weight: .heavy))
      imageView.accessibilityIdentifier = "imageView"
      imageView.isUserInteractionEnabled = false
      imageView.tintColor = self.color
      imageView.alpha = 0
      imageView.contentMode = .center
      imageView.transform = .init(scaleX: 0.75, y: 0.75)
      self.contentView.addSubview(imageView)
      
      UIView.animate(withDuration: 0.2) {
        imageView.alpha = 1
        imageView.transform = .identity
      }
//    }
    return true
  }
  
  func textView(_ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
    let currentText = textView.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }
    let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    
    return updatedText.count <= stage.maxLength
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    guard let text = textView.text,
          !text.isEmpty
    else { return }
    
    self.text = text
  }
}
