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
      guard !stage.isNil else { return }
      
      setupUI()
    }
  }
  public var stageGlobal: NewPollController.Stage!
  public var isKeyboardOnScreen: Bool = false
  ///**UI**
  public var minLength: Int = 0
  public var maxLength: Int = 0
  public var textAlignment: NSTextAlignment = .center
  public var font: UIFont! {
    didSet {
      guard !stage.isNil else { return }
      
      textView.font = font
    }
  }
  public var placeholderText: String!
  public var labelText: String! {
    didSet {
      guard !stage.isNil else { return }
      
      label.text = labelText.uppercased()
    }
  }
  public var minHeight: CGFloat = 0
  public var topicColor: UIColor = .systemGray4 {
    didSet {
      guard let toolBar = textView.inputAccessoryView as? UIToolbar else { return }
      
      toolBar.tintColor = topicColor
    }
  }
  public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      textView.tintColor = color
      
      UIView.animate(withDuration: 0.4) { [weak self] in
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
      guard text != oldValue else { return }
      
      if oldValue.isNil || oldValue.isEmpty {
        CATransaction.begin()
        CATransaction.setCompletionBlock() { [unowned self] in self.isAnimationComplete = true }
        fgLine.layer.strokeColor = color.cgColor
        fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
        CATransaction.commit()
      }
      
      UIView.animate(withDuration: 0.4) { [weak self] in
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
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "\(stage.rawValue + 1).circle.fill"))
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
    instance.text = labelText.uppercased()
    
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.publisher(for: \.bounds)
      .sink {
        print($0)
      }
      .store(in: &subscriptions)
    
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
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.textContainerInset = .uniform(size: padding)//.init(top: padding*2, left: padding, bottom: padding*2, right: padding)
    instance.delegate = self
//    instance.textContainerInset = .uniform(size: .zero)
    instance.isUserInteractionEnabled = true
//    instance.isScrollEnabled = false
    instance.backgroundColor = color.withAlphaComponent(0.2)
    instance.isEditable = true
    instance.isSelectable = true
    instance.font = font
    instance.text = "new_poll_survey_enter_title".localized
    instance.textColor = .clear
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
    toolBar.tintColor = topicColor
    instance.inputAccessoryView = toolBar
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.05 }
      .store(in: &subscriptions)
    
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
  private lazy var placeholder: UILabel = {
    let instance = UILabel()
//    instance.backgroundColor = .red
    instance.numberOfLines = 10
    instance.font = font//UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .footnote)
    instance.text = placeholderText
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    
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

  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    boundsPublisher = PassthroughSubject<CGRect, Never>()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    textView.becomeFirstResponder()
    
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      guard let self = self else { return }
      
      print(self.placeholder.frame)
      print(self.placeholder.alpha)
      self.placeholder.alpha = 0
      self.placeholder.transform = .init(scaleX: 0.75, y: 0.75)
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.placeholder.removeFromSuperview()

      guard !self.textView.isFirstResponder else { return }
      
      self.textView.becomeFirstResponder()
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
      textView.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*2),
      textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*3)
    constraint.isActive = true
    constraint.priority = .defaultLow
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
    
    setNeedsLayout()
    layoutIfNeeded()
    
    placeholder.placeInCenter(of: textView)
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
}

extension NewPollTextCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}

extension NewPollTextCell: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//    guard !isKeyboardOnScreen else { return false }
    guard stageGlobal == .Ready || stage == stageGlobal else { return false }
    
    if text.isNil || text.isEmpty {
      textView.text = ""
      textView.textColor = .label
    }
    
    UIView.animate(withDuration: 0.2) { [weak self] in
      guard let self = self else { return }

      textView.backgroundColor = self.color.withAlphaComponent(0.2)
    }
    
    return true
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    guard !isMovingToParent else {
      UIView.animate(withDuration: 0.2) { [unowned self] in
        textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground }//.systemGray4.withAlphaComponent(0.2) }
      return true
    }
    
    guard textView.text.count >= minLength else {
      let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                            text: "new_poll_survey_min_text_length_error_begin".localized + String(describing: minLength) + "new_poll_survey_min_text_length_error_end".localized,
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
      
      return false
    }
    if self.text.isNil {
      drawLine(line: bgLine, strokeEnd: 1)
      drawLine(line: fgLine)
    }
    UIView.animate(withDuration: 0.2) { [unowned self] in
      textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    }//.systemGray4.withAlphaComponent(0.2) }
    return true
  }
  
  func textView(_ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
      let currentText = textView.text ?? ""
      guard let stringRange = Range(range, in: currentText) else { return false }
      let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    
    return updatedText.count <= maxLength
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    guard let text = textView.text,
          !text.isEmpty
    else { return }
    
    self.text = text
  }
}
