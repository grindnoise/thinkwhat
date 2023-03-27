//
//  NewPollHyperlinkCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollHyperlinkCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage! {
    didSet {
      guard !stage.isNil else { return }
      
//      setupUI()
    }
  }
  public var stageGlobal: NewPollController.Stage!
  public var isKeyboardOnScreen: Bool = false
  ///**UI**
  public var font: UIFont! {
    didSet {
      guard !stage.isNil else { return }
      
      textField.font = font
    }
  }
  public var minHeight: CGFloat = 0
  public var color = UIColor.systemGray4 {
    didSet {
      guard !text.isNil, oldValue != color else { return }
      
      nextButton.tintColor = color
      textField.tintColor = color
      fgLayer.backgroundColor = color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      
      UIView.animate(withDuration: 0.2) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
      }
      
      let colorAnim = CABasicAnimation(path: "strokeColor", fromValue: fgLine.layer.strokeColor, toValue: color.cgColor, duration: 0.4)
      colorAnim.delegate = self
      colorAnim.setValue({ [weak self] in
        guard let self = self else { return }
        
        self.fgLine.layer.removeAnimation(forKey: "color")
      }, forKey: "completion")
      
      fgLine.layer.strokeColor = color.cgColor
    }
  }
  public var isMovingToParent = false
  ///**Publishers**
  @Published public private(set) var isAnimationComplete: Bool?
  @Published public var text: String! {
    didSet {
      guard !text.isNil else { return }
      
      setupUI()
    }
  }
  @Published public var skip: Bool!
  public private(set) var boundsPublisher = PassthroughSubject<Void, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var touchLocation: CGPoint = .zero
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
    instance.layer.strokeColor = Colors.Logo.Flame.rawValue.cgColor
    
    return instance
  }()
  private lazy var bgLine: Line = {
    let instance = Line()
    instance.layer.strokeColor = UIColor.systemGray4.cgColor
    
    return instance
  }()
  private lazy var textField: UnderlinedSignTextField = {
    let instance = UnderlinedSignTextField()
    instance.delegate = self
    instance.backgroundColor = .clear
    instance.font = font
    instance.clipsToBounds = false
    //    instance.attributedPlaceholder = NSAttributedString(string: "new_poll_survey_hyperlink_placeholder".localized,
    //                                                        attributes: [
    //                                                          .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .footnote) as Any,
    //                                                          .foregroundColor: UIColor.systemGray4
    //                                                        ])
    instance.textColor = .label
    //    instance.publisher(for: \.bounds)
    //      .sink { instance.cornerRadius = $0.width*0.05 }
    //      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView()
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.layer.insertSublayer(fgLayer, at: 1)
    instance.addArrangedSubview(UIView.horizontalSpacer(padding*2))
    instance.addArrangedSubview(textField)
    instance.addArrangedSubview(UIView.horizontalSpacer(padding))
    //    instance.clipsToBounds = false
//    instance.layer.masksToBounds = false
//    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.axis = .horizontal
    
    instance.publisher(for: \.bounds)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.bgLayer.frame = $0
        self.bgLayer.cornerRadius = $0.width*0.025
        self.fgLayer.frame = $0
        self.fgLayer.cornerRadius = $0.width*0.025
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var placeholder: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 1
    instance.font = font
    instance.text = stage.placeholder
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
    return instance
  }()
  private lazy var nextButton: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
    instance.isUserInteractionEnabled = true
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.contentMode = .scaleAspectFill
    instance.tintColor = color
    instance.alpha = 0
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextStage)))
    
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [nextButton])
    instance.spacing = padding
    instance.axis = .vertical
    instance.alignment = .center
    instance.distribution = .fillEqually
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: font) + padding*2).isActive = true
    
    return instance
  }()
  private var openedConstraint: NSLayoutConstraint!
  private var closedConstraint: NSLayoutConstraint!
  private lazy var bgLayer: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.backgroundColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground).cgColor

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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    guard !textField.isFirstResponder else { return }
    
//    stack.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    boundsPublisher = PassthroughSubject<Void, Never>()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
//  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    super.touchesBegan(touches, with: event)
//
//    guard let touch = touches.first else { return }
//
//    touchLocation = touch.location(in: stack)
//  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
//    textView.becomeFirstResponder()
//
//    buttonsStack.addArrangedSubview(nextButton)
    closedConstraint.isActive = false
    openedConstraint.isActive = true
    boundsPublisher.send()
    
//    delay(seconds: 0.3) { [weak self] in
//      guard let self = self else { return }
      
      self.nextButton.transform = .init(scaleX: 0.75, y: 0.75)
      UIView.animate(withDuration: 0.2) {
        self.nextButton.transform = .identity
        self.nextButton.alpha = 1
      }
//    }
  }
}

// MARK: - Private
private extension NewPollHyperlinkCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)
    addSubview(stack)
    addSubview(buttonsStack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    buttonsStack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.heightAnchor.constraint(equalToConstant: minHeight),
      stack.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*2),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      buttonsStack.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: padding*2),
//      buttonsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    openedConstraint = buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2)
    openedConstraint.isActive = false
    openedConstraint.priority = .defaultLow
    
    closedConstraint = stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2)
    closedConstraint.isActive = true
    closedConstraint.priority = .defaultLow
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
//    setNeedsLayout()
//    layoutIfNeeded()
//    print(stack.frame.size)
//    placeholder.placeInCenter(of: stack)
    if text.isNil || text.isEmpty {
      placeholder.placeInCenter(of: stack, leadingInset: padding, trailingInset: padding)
    }

//    guard stack.getSubview(type: UIView.self, identifier: "opaque").isNil else { return }
//
//    let opaque = UIView.opaque()
//    opaque.backgroundColor = .red
//    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.detectLocation(sender:))))
//    opaque.place(inside: stack)
//    opaque.layer.zPosition = 10
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
  
  @objc
  func handleTap() {
    textField.becomeFirstResponder()
  }
  
  @objc
  func nextStage() {
//    buttonsStack.removeArrangedSubview(nextButton)
    closedConstraint.isActive = true
    openedConstraint.isActive = false
    boundsPublisher.send()
    nextButton.removeFromSuperview()
    skip = true
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() { [unowned self] in self.isAnimationComplete = true }
    fgLine.layer.strokeColor = color.cgColor
    fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
    CATransaction.commit()
  }
  
//  @objc
//  func detectLocation(sender: UITapGestureRecognizer) {
//    touchLocation = sender.location(ofTouch: 0, in: self)
//  }
}

extension NewPollHyperlinkCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}

extension NewPollHyperlinkCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      
//    UIView.animate(withDuration: 0.2) { [weak self] in
//      guard let self = self else { return }
//
//      self.stack.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
    
    return textField.resignFirstResponder()
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField ,
          stageGlobal == .Ready || stage == stageGlobal
    else { return false }
    
    textField.hideSign()
    
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      guard let self = self else { return }
      
//      self.stack.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
      self.placeholder.alpha = 0
      self.placeholder.transform = .init(scaleX: 0.75, y: 0.75)
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.placeholder.removeFromSuperview()
    }
    
    Animations.unmaskLayerCircled(layer: fgLayer,
                                  location: touchLocation,
                                  duration: 0.5,
                                  opacityDurationMultiplier: 0.6,
                                  delegate: self)
    
    bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 1, toValue: 0, duration: 0.5), forKey: nil)
    
    return true
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let textField = textField as? UnderlinedSignTextField,
          let text = textField.text
    else { return true }
    
    guard !isMovingToParent else {
      return true
    }

//    stack.layer.masksToBounds = false
//    stack.clipsToBounds = false
    
    if !text.isEmpty, !text.isValidURL {
      stack.clipsToBounds = false
      textField.showSign(state: .InvalidHyperlink)
//      stack.layer.masksToBounds = false
//      stack.clipsToBounds = false
    }
    
    if textField.text!.isEmpty {
      placeholder.placeInCenter(of: textField, leadingInset: padding, trailingInset: padding)
      UIView.animate(withDuration: 0.2) { [unowned self] in
        //      textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        self.placeholder.alpha = 1
        self.placeholder.transform = .identity
      }
    }
    
    Animations.unmaskLayerCircled(unmask: false,
                                  layer: fgLayer,
                                  location: touchLocation,
                                  duration: 0.35,
                                  animateOpacity: false,
//                                  opacityDurationMultiplier: 2,
                                  delegate: self)
    
    bgLayer.add(CABasicAnimation(path: "opacity", fromValue: 0, toValue: 1, duration: 0.5), forKey: nil)
      
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let text = textField.text,
          !text.isEmpty,
          text.isValidURL
    else { return }

    self.text = text
  }
}
