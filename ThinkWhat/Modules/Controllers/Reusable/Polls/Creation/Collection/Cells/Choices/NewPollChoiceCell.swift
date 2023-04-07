//
//  NewPollChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollChoiceCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage! 
  public var stageGlobal: NewPollController.Stage!
  public var order: Int! {
    didSet {
      guard !item.isNil else { return }
      
      imageView.image = UIImage(systemName: "\(order + 1).circle.fill")
      
      guard let toolBar = textView.inputAccessoryView as? UIToolbar else { return }
      
      toolBar.tintColor = Colors.getColor(forId: order)
    }
  }
  public var item: NewPollChoice! {
    didSet {
      guard !item.isNil else { return }
      
      setupUI()
    }
  }
  ///**Publishers**
//  @Published public private(set) var wasEdited: Bool?
  public private(set) var wasEditedPublisher = CurrentValueSubject<Bool?, Never>(nil)
  public private(set) var boundsPublisher = PassthroughSubject<CGRect, Never>()
  ///**UI**
  public var minHeight: CGFloat = 0
  public var minLength: Int = 0
  public var maxLength: Int = 0
  public var isMovingToParent = false
  public var isKeyboardOnScreen: Bool = false
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let lineSpacing: CGFloat = 4
  private let padding: CGFloat = 8
  private var color: UIColor { order.isNil ? .systemGray4 : Colors.getColor(forId: order) }
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "\(order + 1).circle.fill"))
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!.pointSize + lineSpacing/2).isActive = true
    instance.tintColor = .systemGray4
    instance.contentMode = .scaleAspectFit
    
    return instance
  }()
  public lazy var textView: UITextView = {
    let instance = UITextView()
    instance.textContainerInset = .uniform(size: padding)
    instance.delegate = self
    instance.isUserInteractionEnabled = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.isEditable = true
    instance.isSelectable = true
//    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
    toolBar.isTranslucent = true
    toolBar.backgroundColor = .tertiarySystemBackground
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.superview?.backgroundColor = .tertiarySystemBackground
    let doneButton = UIBarButtonItem(title: "ready".localized, style: .done, target: nil, action: #selector(self.hideKeyboard))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.items = [space, doneButton]
    toolBar.barStyle = .default
    toolBar.tintColor = Colors.getColor(forId: order)
    instance.inputAccessoryView = toolBar
    instance.attributedText = NSAttributedString(string: "", attributes: attributes(inactive: order == 0))
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
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
    
    guard !textView.isFirstResponder,
          stage == stageGlobal || stage == .Ready
    else { return }
    
    textView.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
//    textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
//    topicPublisher = PassthroughSubject<Topic, Never>()
    wasEditedPublisher = CurrentValueSubject<Bool?, Never>(nil)
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
//    delay(seconds: seconds) { [weak self] in
//      guard let self = self else { return }
//
//      let banner = NewPopup(padding: self.padding*2,
//                            contentPadding: .uniform(size: self.padding*2))
//      let content = TopicSelectionPopupContent(mode: self.topic.isNil ? .ForceSelect : .Default,
//                                               color: Colors.Logo.Flame.rawValue)
//      content.topicPublisher
//        .sink { topic in
//          banner.dismiss()
//
//          delay(seconds: 0.15) { [unowned self] in
//            self.topic = topic
//          }
//        }
//        .store(in: &banner.subscriptions)
//
//      banner.setContent(content)
//      banner.didDisappearPublisher
//        .sink { _ in banner.removeFromSuperview() }
//        .store(in: &self.subscriptions)
//    }
  }
}

// MARK: - Private
private extension NewPollChoiceCell {
  @MainActor
  func setupUI() {
    let inset = padding + lineSpacing/2
    backgroundColor = .clear
    textView.place(inside: contentView, bottomPriority: .defaultLow)
    textView.attributedText = NSAttributedString(string: item.text, attributes: attributes(inactive: order == 0))
    imageView.placeTopLeading(inside: contentView, leadingInset: inset, topInset: inset)
  }
  
  @objc
  func handleTap() {
    present()
  }
  
  @objc
  func hideKeyboard() {
    endEditing(true)
  }
  
  func drawLine(line: Line,
                strokeEnd: CGFloat = 0,
                lineCap: CAShapeLayerLineCap = .round) {
    let lineWidth = imageView.bounds.width*0.1
    let imageCenter = imageView.convert(imageView.center, to: contentView)
    let xPos = imageCenter.x //- lineWidth/2
    let yPos = imageCenter.y + imageView.bounds.height/2 - lineWidth
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: xPos, y: yPos))
    path.addLine(to: CGPoint(x: xPos, y: bounds.maxY + lineWidth))
    
    line.path = path
    line.layer.strokeStart = 0
    line.layer.strokeEnd = strokeEnd
    line.layer.lineCap = lineCap
    line.layer.lineWidth = lineWidth
    line.layer.path = line.path.cgPath
  }
  
  func attributes(inactive: Bool = false) -> [NSAttributedString.Key: Any] {
    let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.firstLineHeadIndent = font!.pointSize + padding + lineSpacing
    paragraphStyle.lineSpacing = lineSpacing
    if #available(iOS 15.0, *) {
      paragraphStyle.usesDefaultHyphenation = true
    } else {
      paragraphStyle.hyphenationFactor = 1
    }
    
    return [
      .font: font as Any,
      .foregroundColor: inactive ? UIColor.secondaryLabel : UIColor.label,
      .paragraphStyle: paragraphStyle
    ]
  }
}

extension NewPollChoiceCell: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    guard stageGlobal == .Ready || stage == stageGlobal else { return false }
        
    UIView.animate(withDuration: 0.2) { [weak self] in
      guard let self = self else { return }

      textView.textColor = .label
      textView.attributedText = NSAttributedString(string: self.item.text, attributes: self.attributes(inactive: false))
      self.imageView.tintColor = self.color
      textView.backgroundColor = self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
    }
    
//    textView.layer.add(CABasicAnimation(path: "borderWidth", fromValue: 0, toValue: 1.5, duration: 0.2), forKey: nil)
//    textView.layer.add(CABasicAnimation(path: "borderColor", fromValue: textView.layer.borderColor, toValue: color.cgColor, duration: 0.2), forKey: nil)
    
    return true
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    guard !isMovingToParent else {
//      UIView.animate(withDuration: 0.2) { [unowned self] in
//        textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
////        self.imageView.tintColor = .systemGray4
//      }//.systemGray4.withAlphaComponent(0.2) }
      return true
    }
    
//    textView.layer.add(CABasicAnimation(path: "borderWidth", fromValue: 1.5, toValue: 0, duration: 0.2), forKey: nil)
    
    if textView.text.count <= minLength {
      textView.text = "new_poll_choice_placeholder".localized + (order.isNil ? "" : String(describing: order!))
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
    }
//    UIView.animate(withDuration: 0.2) { [unowned self] in
//      textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
////      self.imageView.tintColor = .systemGray4
//    }//.systemGray4.withAlphaComponent(0.2) }
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
    
    item.text = text
//    wasEdited = true
//    print("cell.wasEditedPublisher")
    wasEditedPublisher.send(true)
  }
}
