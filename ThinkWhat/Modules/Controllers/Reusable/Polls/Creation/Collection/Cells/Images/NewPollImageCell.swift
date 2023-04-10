//
//  NewPollImageCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollImageCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var item: NewPollImage! {
    didSet {
      guard !item.isNil else { return }

      setupUI()
    }
  }
  ///**Publishers**
//  @Published public private(set) var isAnimationComplete: Bool?
  public private(set) var boundsPublisher = PassthroughSubject<CGRect, Never>()
  ///**UI**
  public var minHeight: CGFloat = 0
  public var minLength: Int = 0
  public var maxLength: Int = 0
  public var isMovingToParent = false
  public var isKeyboardOnScreen: Bool = false
  public var font: UIFont!
  public var color: UIColor = .systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      textView.tintColor = color
      
      guard let toolBar = textView.inputAccessoryView as? UIToolbar else { return }
      
      toolBar.tintColor = color
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var imageView: UIImageView = {
    let instance = UIImageView()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.backgroundColor = .systemGray4
    instance.contentMode = .scaleAspectFit
//    instance.publisher(for: \.bounds)
//      .sink { instance.cornerRadius = $0.width*0.05 }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.textContainerInset = .uniform(size: padding)
    instance.delegate = self
    instance.font = font
    instance.isUserInteractionEnabled = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.isEditable = true
    instance.isSelectable = true
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
    toolBar.isTranslucent = true
    toolBar.backgroundColor = .tertiarySystemBackground
    toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolBar.superview?.backgroundColor = .tertiarySystemBackground
    let doneButton = UIBarButtonItem(title: "ready".localized, style: .done, target: nil, action: #selector(self.hideKeyboard))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.items = [space, doneButton]
    toolBar.barStyle = .default
    toolBar.tintColor = .red//Colors.getColor(forId: order)
    instance.inputAccessoryView = toolBar
    instance.publisher(for: \.bounds)
      .sink { [unowned self] in instance.cornerRadius = $0.width*0.05; self.imageView.cornerRadius = instance.cornerRadius }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      imageView,
      textView
    ])
    instance.spacing = padding
    instance.axis = .horizontal
    
    return instance
  }()
  private lazy var placeholder: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 10
    instance.font = font
    instance.text = "new_poll_image_placeholder".localized
    instance.textColor = .secondaryLabel
    instance.textAlignment = .center
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    
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
    
//    topicPublisher = PassthroughSubject<Topic, Never>()
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
private extension NewPollImageCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    
    imageView.image = item.image
    
//    contentView.translatesAutoresizingMaskIntoConstraints = false
//    contentView.heightAnchor.constraint(equalToConstant: minHeight).isActive = true
//
    stack.place(inside: contentView, bottomPriority: .defaultLow)
    stack.heightAnchor.constraint(equalToConstant: minHeight).isActive = true
    
//
//    stack.translatesAutoresizingMaskIntoConstraints = false
//    stack.place(inside: contentView, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: <#T##CGFloat#>))
    
//    addSubview(stack)
//    stack.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      stack.topAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutYAxisAnchor>#>)
//    ])
    
    guard item.text.isEmpty else { return }
    
    placeholder.placeInCenter(of: textView, leadingInset: padding, trailingInset: padding)
  }
  
  @objc
  func handleTap() {
    textView.becomeFirstResponder()
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
}

extension NewPollImageCell: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      guard let self = self else { return }
      
      self.placeholder.alpha = 0
      self.placeholder.transform = .init(scaleX: 0.75, y: 0.75)
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.placeholder.removeFromSuperview()
    }
    
    return true
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    guard !isMovingToParent else {
      UIView.animate(withDuration: 0.2) { [unowned self] in
        textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        self.imageView.tintColor = .systemGray4
      }//.systemGray4.withAlphaComponent(0.2) }
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
    
    if textView.text.isEmpty {
      placeholder.placeInCenter(of: textView, leadingInset: padding, trailingInset: padding)
    }
    
    UIView.animate(withDuration: 0.2) { [unowned self] in
      textView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      self.imageView.tintColor = .systemGray4
      
      if textView.text.isEmpty {
        self.placeholder.alpha = 1
        self.placeholder.transform = .identity
      }
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
    
    self.item.text = text
  }
}

