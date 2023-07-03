//
//  ChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine

class AnswerCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public var item: Answer! {
    didSet {
      guard let item = item else { return }
      
      setNeedsLayout()
      layoutIfNeeded()
      
      color = Colors.getColor(forId: item.order)
      
      setupUI()
      
//      delayAsync(delay: 2) { [weak self] in
//        guard let self = self else { return }
//
//        self.votersStack.push(userprofile: Userprofile.anonymous)
//      }
//      updateUI(animated: false)
//
      guard let survey = item.survey else { return }

      survey.reference.isCompletePublisher
        .filter { $0 }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }

          self.observeVoters()
          self.closedConstraint.isActive = false
          self.openConstraint.isActive = true
          self.updatePublisher.send(true)
          self.setChosen()
//          self.setSelected(forceDeselect: true) { [weak self] _ in
//            guard let self = self else { return }
//
//            self.setChosen()
//          }
//          DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//            guard let self = self else { return }
//
//            self.observeVoters()
//          }
        }
        .store(in: &subscriptions)
      ///Update stats
      survey.reference.votesPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }

          UIView.transition(with: self.percentageLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.percentageLabel.text = item.percentString
          } completion: { _ in }

          UIView.transition(with: self.votersCountLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.votersCountLabel.text = item.totalVotes.roundedWithAbbreviations
          } completion: { _ in }

          self.percentageView.setPercent(value: item.percent, animated: true)
          
          guard item.totalVotes > 0 else { return }
          
          self.disclosureIndicator.alpha = 1
        }
        .store(in: &subscriptions)

      guard survey.reference.isComplete else { return }
      ///Voters append
      observeVoters()
    }
  }
  ///**Publishers**
  public let selectionPublisher = PassthroughSubject<Answer, Never>()
  public let deselectionPublisher = PassthroughSubject<Bool, Never>()
  ///Used to refresh `collectionView`
  public let updatePublisher = PassthroughSubject<Bool, Never>()
  public let votersPublisher = PassthroughSubject<Answer, Never>()
  ///**Logic**
  public var isAnswerSelected = false {
    didSet {
      guard oldValue != isAnswerSelected else { return }

      setSelected() { _ in }
    }
  }
  //Flag for user interaction
  public var isVoting = false {
    didSet {
      textView.isUserInteractionEnabled = !isVoting
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var isChosen: Bool {
    guard let survey = item.survey,
          let result = survey.result,
          result.keys.first == item.id else {
      return false
    }
    return true
  }
  private let avatarsThreshold = 5
  ///**UI**
  private var touchLocation: CGPoint = .zero
  private let statsHeight: CGFloat = 44
  private let padding: CGFloat = 8
  private let lineSpacing: CGFloat = 4
  private var color = UIColor.clear
  private lazy var stackView: UIStackView = {
    let opaque = UIView.opaque()
    opaque.heightAnchor.constraint(equalToConstant: statsHeight).isActive = true
    statsStack.place(inside: opaque,
                          insets: UIEdgeInsets(top: 0, left: padding, bottom: padding, right: padding))
    
    let instance = UIStackView(arrangedSubviews: [
      textView,
      opaque
    ])
    instance.clipsToBounds = false
    instance.axis = .vertical
    instance.spacing = 0
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
    return instance
  }()
  ///Top part
  private lazy var textView: UITextView = {
    let instance = UITextView()
    instance.textContainerInset = UIEdgeInsets(top: padding,
                                               left: 0,
                                               bottom: padding,
                                               right: 0)
    instance.backgroundColor = .clear
    instance.isEditable = false
    instance.isSelectable = false
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(sender:))))
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize, options: .new) { [weak self] _, change in
      guard let self = self,
            let value = change.newValue,
            value.height > 0,
            constraint.constant != value.height
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = value.height
      self.layoutIfNeeded()
    })
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView()
    instance.contentMode = .center
    instance.tintColor = .systemGray
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.heightAnchor.constraint(equalToConstant: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!.pointSize + lineSpacing/2).isActive = true
    //    instance.publisher(for: \.bounds)
    return instance
  }()
  ///Bottom part
  private lazy var statsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      percentageLabel,
      percentageView,
      checkmark,
//      UIView.opaque(),
    ])
    
    if let survey = item.survey, !survey.isAnonymous {
      instance.addArrangedSubview(votersStack)
    }
    instance.addArrangedSubview(votersCountLabel)
    instance.addArrangedSubview(disclosureIndicator)
    instance.axis = .horizontal
    instance.clipsToBounds = false
    instance.spacing = 4
    
    return instance
  }()
  private lazy var percentageLabel: UILabel = {
    let instance = UILabel()
    instance.backgroundColor = .clear
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption1)
    instance.textAlignment = .center
    instance.widthAnchor.constraint(equalToConstant: "100 %".width(withConstrainedHeight: 100, font: instance.font)).isActive = true
    instance.textColor = color
    
    return instance
  }()
  private lazy var percentageView: PercentageView = {
    PercentageView(lineWidth: 10,
                   foregoundColor: color,
    backgroundColor: (isAnswerSelected || isChosen) ? .systemBackground : traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground)
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "chevron.right"))
    instance.accessibilityIdentifier = "chevron"
    instance.clipsToBounds = true
    instance.tintColor = .label
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .headline, scale: .small)
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(sender:))))
    instance.alpha = item.totalVotes == 0 ? 0 : 1
    instance.tintColor = color
    
    let constraint = instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/3)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var checkmark: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
    instance.contentMode = .center
    instance.alpha = (isAnswerSelected || isChosen) ? 1 : 0
    instance.tintColor = color
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 2/3).isActive = true
//    instance.widthAnchor.constraint(equalToConstant: 30).isActive = true
    
    return instance
  }()
  private lazy var votersCountLabel: UILabel = {
    let instance = UILabel()
    instance.accessibilityIdentifier = "votersLabel"
    instance.backgroundColor = .clear
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.75).isActive = true
    instance.textAlignment = .center
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(sender:))))
    instance.textColor = color
    instance.text = "999"
    
    return instance
  }()
  private lazy var votersStack: VotersStack = {
    let instance = VotersStack(userprofiles: Array(item.voters.prefix(avatarsThreshold)),
                               capacity: avatarsThreshold,
                               lightBorderColor: (isChosen || isAnswerSelected) ? color.withAlphaComponent(0.2) : .clear,
                               darkBorderColor: (isChosen || isAnswerSelected) ? color.withAlphaComponent(0.4) : .clear,
                               height: statsHeight-padding)
    instance.tapPublisher
      .sink { [weak self] _ in
        guard let self = self,
              let survey = self.item.survey,
              survey.isComplete,
              !survey.isAnonymous,
              self.item.totalVotes > 0
        else { return }
        
        self.votersPublisher.send(self.item)
      }
      .store(in: &subscriptions)
    //    let opaque = UIView.opaque()
//    opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(sender: ))))
//    opaque.addEquallyTo(to: instance)
    
    return instance
  }()
  ///Constraints
  private var openConstraint: NSLayoutConstraint!
  private var closedConstraint: NSLayoutConstraint!
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
    guard let selection = stackView.getLayer(identifier: "selection") else { return }
    
    selection.removeAllAnimations()
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overridden properties
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
//    updateUI(animated: false)
    
    stackView.backgroundColor = !isChosen ? .clear : color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
  }
}

private extension AnswerCell {
  @MainActor
  func setupUI() {
    guard let survey = item.survey else { return }
    
    let attributes: [NSAttributedString.Key: Any] = {
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
        .foregroundColor: UIColor.label,
        .paragraphStyle: paragraphStyle
      ]
    }()
    
    backgroundColor = .clear
    clipsToBounds = true
    let inset = padding + lineSpacing/2
    let views = [
      stackView,
      imageView,
    ]
    addSubviews(views)
    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: inset),
      imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: inset),
    ])
    
    openConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    openConstraint.priority = .defaultLow
    closedConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor)
    closedConstraint.priority = .defaultLow
    
    ///Set data
    textView.attributedText = NSAttributedString(string: item.description, attributes: attributes)
    percentageLabel.text = item.percentString
    votersCountLabel.text = item.totalVotes.roundedWithAbbreviations
    ///UI settings
    imageView.tintColor = survey.isComplete ? color : (isChosen || isAnswerSelected) ? survey.topic.tagColor : .systemGray
    imageView.setImage(UIImage(systemName: "\(item.order+1).circle.fill")!)
    
    if survey.isComplete {
      openConstraint.isActive = true
      percentageView.setPercent(value: item.percent, animated: false)
      votersCountLabel.alpha = 1
//      stackView.backgroundColor = !isChosen ? .clear : self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.2)
      stackView.backgroundColor = !isChosen ? .clear : color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
      if survey.isAnonymous {
//        votersView.alpha = 0
        disclosureIndicator.alpha = 0
      }
    } else {
      closedConstraint.isActive = true
      stackView.backgroundColor = !isChosen ? .clear : color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
//      stackView.backgroundColor = !isChosen ? .clear : self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : survey.topic.tagColor.withAlphaComponent(0.1)
    }
  }
  
  @MainActor
  func setSelected(forceDeselect: Bool = false,
                   completion: @escaping (Bool)-> ()) {
    guard let survey = item.survey else { return }
    
    if forceDeselect {
      guard let selection = stackView.getLayer(identifier: "selection") else { return }
      
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
        selection.opacity = 0
        selection.transform = CATransform3DMakeTranslation(1, 0.01, 1)
      } completion: { _ in selection.removeFromSuperlayer(); completion(true) }
      
      return
    }
    
    guard !item.survey!.isComplete else { return }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      self.imageView.tintColor = self.isAnswerSelected ? survey.topic.tagColor : .systemGray
    }
    
    switch isAnswerSelected {
    case true:
      selectionPublisher.send(item)
      let selection = CALayer()
      selection.name  = "selection"
      selection.backgroundColor = survey.topic.tagColor.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      selection.frame = CGRect(origin: .zero, size: textView.bounds.size)
      selection.cornerRadius = stackView.cornerRadius
      selection.opacity = 0
      stackView.layer.insertSublayer(selection, at: 0)
      
      Animations.unmaskLayerCircled(layer: selection,
                                    location: touchLocation,
                                    duration: 0.4,
                                    opacityDurationMultiplier: 0.5,
                                    delegate: self) { completion(true) }
    case false:
      guard let selection = stackView.getLayer(identifier: "selection") else { return }
      
      selection.add(Animations.get(property: .Opacity,
                                   fromValue: 1,
                                   toValue: 0,
                                   duration: 0.2,
                                   timingFunction: .easeOut,
                                   delegate: self,
                                   isRemovedOnCompletion: false,
                                   completionBlocks: [{
//        selection.opacity = 0
//        selection.removeAllAnimations()
        selection.removeFromSuperlayer() }]),
                    forKey: nil)
      selection.add(Animations.get(property: .Scale,
                                   fromValue: selection.affineTransform(),
                                   toValue: selection.setAffineTransform(CGAffineTransform(scaleX: 1, y: 0.1)),//0.1,
                                   duration: 0.2,
                                   timingFunction: .easeOut,
                                   delegate: self,
                                   isRemovedOnCompletion: false,
                                   completionBlocks: [{
//        selection.setAffineTransform(CGAffineTransform(scaleX: 1, y: 0.1))
//        selection.removeAllAnimations()
        selection.removeFromSuperlayer() }]),
                    forKey: nil)
    }
  }
  
  @MainActor
  func setChosen() {
    votersStack.setColors(lightBorderColor: (isChosen || isAnswerSelected) ? color.withAlphaComponent(0.2) : .clear,
                          darkBorderColor: (isChosen || isAnswerSelected) ? color.withAlphaComponent(0.4) : .clear)
//    votersStack.setColors(lightBorderColor: (isChosen || isAnswerSelected) ? color.withAlphaComponent(0.2) : .clear,
//                          darkBorderColor: (isChosen || isAnswerSelected) ? color.withAlphaComponent(0.4) : .clear)
    
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }

        self.imageView.tintColor = self.color
        self.textView.backgroundColor = .clear
        self.checkmark.alpha = (self.isChosen || self.isAnswerSelected) ? 1 : 0
      }
    
    guard let selection = stackView.getLayer(identifier: "selection") else {
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut]) { [weak self] in
          guard let self = self else { return }
          
          self.stackView.backgroundColor = (self.isChosen || self.isAnswerSelected) ?  self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2) : .clear
        }
      
      return
    }
//    stackView.publisher(for: \.bounds)
//      .sink { selection.bounds.size.height = $0.height }
    //      .store(in: &subscriptions)
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }
        
        selection.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? self.color.withAlphaComponent(0.4).cgColor : self.color.withAlphaComponent(0.2).cgColor
        selection.frame = self.stackView.frame
      }
  }
  
  func observeVoters() {
    guard let item = item else { return }
    
    item.votersPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.votersStack.push(userprofiles: $0.suffix(5))
      }
      .store(in: &subscriptions)
  }
  
  @objc
  func handleGesture(sender: UITapGestureRecognizer) {
    guard let view = sender.view else { return }
    
    touchLocation = sender.location(ofTouch: 0, in: self)
    
    if view == textView {
      isAnswerSelected = !isAnswerSelected
      if !isAnswerSelected {
        deselectionPublisher.send(true)
      }
    } else if let survey = item.survey,
              survey.isComplete,
              !survey.isAnonymous,
              item.totalVotes > 0,
              (view == disclosureIndicator || view == votersCountLabel) {//} || view.accessibilityIdentifier == "opaque") {
      votersPublisher.send(item)
    }
  }
}

extension AnswerCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        }
    }
}
