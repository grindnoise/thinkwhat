//
//  NewPollChoicesCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollChoicesCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage!
  public var stageGlobal: NewPollController.Stage!
  public var choices: [NewPollChoice]! {
    didSet {
      guard !choices.isNil else { return }
      
      setupUI()
    }
  }
  public var topicColor: UIColor = .systemGray //{
//    didSet {
//      guard !stage.isNil else { return }
//
//      button.setAttributedTitle(NSAttributedString(string: "new_poll_survey_choice_add".localized,
//                                                     attributes: [
//                                                      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
//                                                      .foregroundColor: topicColor as Any
//                                                     ]),
//                                  for: .normal)
//    }
//  }
  ///**Publishers**
  @Published public private(set) var wasEdited: Bool?
  @Published public var removedChoice: NewPollChoice?
  @Published public private(set) var isAnimationComplete: Bool?
  @Published public private(set) var stageAnimationFinished: NewPollController.Stage!
  @Published public var isKeyboardOnScreen: Bool!
  @Published public var isMovingToParent: Bool!
  public private(set) var addChoicePublisher = PassthroughSubject<Void, Never>()
  public private(set) var boundsPublisher = PassthroughSubject<Bool, Never>()
  ///**UI**
  @Published public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      UIView.animate(withDuration: 0.4) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
      }
      
      button.setAttributedTitle(NSAttributedString(string: "new_poll_choice_add".localized,
                                                     attributes: [
                                                      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                      .foregroundColor: topicColor as Any
                                                     ]),
                                  for: .normal)
      
      let colorAnim = CABasicAnimation(path: "strokeColor", fromValue: fgLine.layer.strokeColor, toValue: color.cgColor, duration: 0.4)
      colorAnim.delegate = self
      colorAnim.setValue({ [weak self] in
        guard let self = self else { return }
        
        self.fgLine.layer.removeAnimation(forKey: "color")
      }, forKey: "completion")
      
      fgLine.layer.strokeColor = color.cgColor
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var collectionView: NewPollChoicesCollectionView = {
    let instance = NewPollChoicesCollectionView(choices)
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.isActive = true
    
    instance.$removedChoice
      .sink { [unowned self] in self.removedChoice = $0 }
      .store(in: &subscriptions)
    instance.$wasEdited
      .sink { [unowned self] in self.wasEdited = $0 }
      .store(in: &subscriptions)
    
    $isMovingToParent
      .filter { !$0.isNil }
      .eraseToAnyPublisher()
      .sink { instance.isMovingToParent = $0!}
      .store(in: &subscriptions)
    $isKeyboardOnScreen
      .filter { !$0.isNil }
      .eraseToAnyPublisher()
      .sink { instance.isKeyboardOnScreen = $0!}
      .store(in: &subscriptions)
    
    setNeedsLayout()
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && constraint.constant != $0.height }
      .sink { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = $0.height
        self.layoutIfNeeded()
        self.boundsPublisher.send(true)
      }
      .store(in: &subscriptions)
    
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: stage.numImage)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.tintColor = color
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
  private lazy var button: UIButton = {
    let instance = UIButton()
    instance.setAttributedTitle(NSAttributedString(string: "new_poll_choice_add".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                    .foregroundColor: topicColor as Any
                                                   ]),
                                for: .normal)
    instance.addTarget(self, action: #selector(self.addChoice), for: .touchUpInside)
    
    return instance
  }()
  private lazy var nextButton: UIButton = {
    let instance = UIButton()
    instance.setAttributedTitle(NSAttributedString(string: "new_poll_choice_next".localized,
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                                    .foregroundColor: topicColor as Any
                                                   ]),
                                for: .normal)
    instance.addTarget(self, action: #selector(self.nextStage), for: .touchUpInside)
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [button])
    instance.spacing = padding
    instance.axis = .vertical
//    instance.alignment = .center
    
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
    
    addChoicePublisher = PassthroughSubject<Void, Never>()
//    topicPublisher = PassthroughSubject<Topic, Never>()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.drawLine(line: self.bgLine, strokeEnd: 1, xPoint: 500)
    self.drawLine(line: self.fgLine)
  }
  
  // MARK: - Public methods
  public func present(first: Bool = true, seconds: Double = .zero) {
    if !first {
      buttonsStack.addArrangedSubview(nextButton)
      boundsPublisher.send(true)
    }
    
    guard seconds != .zero else {
      collectionView.present(first: first)
      
      return
    }
    
    delay(seconds: seconds) { [unowned self] in
      self.collectionView.present(first: first)
    }
  }
  
  public func refreshChoices(_ instances: [NewPollChoice]) {
    collectionView.refreshChoices(instances)
  }
  
  public func addSecondChoice() {
    addChoice()
  }
}

// MARK: - Private
private extension NewPollChoicesCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)
    addSubview(collectionView)
    addSubview(buttonsStack)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    buttonsStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*2),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
      buttonsStack.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: padding),
      buttonsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
    
    let constraint = buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*2)
    constraint.isActive = true
    constraint.priority = .defaultLow
    
    layer.insertSublayer(bgLine.layer, at: 0)
    layer.insertSublayer(fgLine.layer, at: 1)
  }
  
  @objc
  func handleTap() {
    present()
  }
  
  @objc
  func nextStage() {
    buttonsStack.removeArrangedSubview(nextButton)
    boundsPublisher.send(true)
    nextButton.removeFromSuperview()
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() { [unowned self] in self.isAnimationComplete = true }
    fgLine.layer.strokeColor = color.cgColor
    fgLine.layer.add(CABasicAnimation(path: "strokeEnd", fromValue: 0, toValue: 1, duration: 0.4), forKey: "strokeEnd")
    CATransaction.commit()
  }
  
  @objc
  func addChoice() {
    addChoicePublisher.send()
//    collectionView.addChoice()
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
}

extension NewPollChoicesCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}

