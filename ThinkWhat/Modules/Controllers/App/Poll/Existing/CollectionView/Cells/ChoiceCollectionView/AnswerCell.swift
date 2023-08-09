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
      
//      setNeedsLayout()
//      layoutIfNeeded()
      
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
      
//      votersStack.push(userprofiles: item.voters)
      
      survey.reference.isCompletePublisher
        .filter { $0 }
        .delay(for: .seconds(0.35), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
//          self.observeVoters()
          self.closedConstraint.isActive = false
          self.openConstraint.isActive = true
          self.updatePublisher.send(true)
          self.setChosen()
          
          self.rightButton.imageView?.alpha = (item.totalVotes > 0 && !survey.isAnonymous) ? 1 : 0
          self.rightButton.setAttributedTitle(NSAttributedString(string: self.item.totalVotes.roundedWithAbbreviations, attributes: [
            .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .subheadline) as Any,
            .foregroundColor: item.totalVotes > 0 ? self.color : .secondaryLabel
           ]), for: .normal)
          
          UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            
            self.statsStack.alpha = 1
          }
          
          self.percentageView.setBackgroundDarkColor(self.isAnswerSelected || self.isChosen ? .secondarySystemBackground : .tertiarySystemBackground)
          self.percentageView.setBackgroundDarkColor(self.isAnswerSelected || self.isChosen ? .secondarySystemBackground : .systemFill)
        }
        .store(in: &subscriptions)
      ///Update stats
      survey.reference.votesPublisher
        .receive(on: DispatchQueue.main)
        .delay(for: .seconds(Double.random(in: 0.4...0.8)), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }

          UIView.transition(with: self.percentageLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.percentageLabel.text = item.percentString
          } completion: { _ in }

          self.rightButton.imageView?.alpha = (item.totalVotes > 0 && !survey.isAnonymous) ? 1 : 0
          self.rightButton.setAttributedTitle(NSAttributedString(string: self.item.totalVotes.roundedWithAbbreviations, attributes: [
            .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .subheadline) as Any,
            .foregroundColor: self.item.totalVotes > 0 ? self.color : .secondaryLabel
           ]), for: .normal)
          self.percentageView.setPercent(value: item.percent, animated: true)
        }
        .store(in: &subscriptions)

      item.votersPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.votersStack.push(userprofiles: $0.suffix(5))
        }
        .store(in: &subscriptions)
//      guard survey.reference.isComplete else { return }
//      ///Voters append
//      observeVoters()
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

      setSelected()
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
  private let avatarsThreshold = 3
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
                          insets: UIEdgeInsets(top: 0, left: padding, bottom: padding, right: 0))
    
    let instance = UIStackView(arrangedSubviews: [
      textView,
      opaque
    ])
    instance.layer.masksToBounds = false
    instance.axis = .vertical
    instance.spacing = 0
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.35).cgColor
    instance.layer.shadowOffset = .zero
    instance.layer.shadowOpacity = (isChosen || isSelected) ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    instance.layer.shadowRadius = padding*0.65///2
    
    // Add layer
    let sublayer = CALayer()
    sublayer.name  = "bgLayer"
    sublayer.backgroundColor = isChosen ? traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.systemBackground.cgColor : UIColor.clear.cgColor
    instance.layer.insertSublayer(sublayer, at: 0)
    instance.publisher(for: \.bounds)
      .filter { sublayer.bounds.height != $0.height || sublayer.bounds.width != $0.width }
      .sink {
        let cornerRadius = $0.width*0.025
        sublayer.frame = $0
        sublayer.cornerRadius = cornerRadius
        instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: cornerRadius).cgPath
      }
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
    instance.heightAnchor.constraint(equalToConstant: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)!.pointSize + lineSpacing/2).isActive = true
    //    instance.publisher(for: \.bounds)
    return instance
  }()
  ///Bottom part
  private lazy var statsStack: UIStackView = {
    let opaque = UIView.opaque()
    checkmark.placeInCenter(of: opaque, leadingInset: 0, trailingInset: 0)
    
    let instance = UIStackView(arrangedSubviews: [
//      UIView.opaque(),
      percentageView,
//      opaque,
      //      UIView.opaque(),
    ])
    percentageView.translatesAutoresizingMaskIntoConstraints = false
    percentageView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: item.survey!.isAnonymous ? 0.85 : 0.575).isActive = true
    instance.addArrangedSubview(UIView.opaque())
    
    if let survey = item.survey, !survey.isAnonymous {
      instance.addArrangedSubview(votersStack)
    }
    
    
    //    let opaque2 = UIView.opaque()
    //    opaque2.accessibilityIdentifier = "opaque2"
    //    opaque2.translatesAutoresizingMaskIntoConstraints = false
    //    let constraint = opaque2.widthAnchor.constraint(equalToConstant: 999_999_999.roundedWithAbbreviations.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)!) + padding/2)
    //      constraint.isActive = true
    //    constraint.identifier = "widthAnchor"
    //    opaque2.addSubview(rightButton)
    //    rightButton.translatesAutoresizingMaskIntoConstraints = false
    //    rightButton.trailingAnchor.constraint(equalTo: opaque2.trailingAnchor).isActive = true
    //    rightButton.centerYAnchor.constraint(equalTo: opaque2.centerYAnchor).isActive = true
    
    //    instance.addSubview(votersStack)
    //    votersStack.translatesAutoresizingMaskIntoConstraints = false
    //    votersStack.topAnchor.constraint(equalTo: instance.topAnchor).isActive = true
    //    votersStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor).isActive = true
    //    let trailing = votersStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: rightButton.bounds.width)
    //    trailing.identifier = "trailingAnchor"
    //    trailing.isActive = true
    ////    votersStack.trailingAnchor.constraint(equalTo: rightButton.imageView!.leadingAnchor, constant: instance.spacing).isActive = true
    
    instance.addArrangedSubview(rightButton)
    instance.axis = .horizontal
    instance.clipsToBounds = false
    instance.spacing = 4
    if let survey = item.survey {
      instance.alpha = survey.isComplete ? 1 : 0
    }
    
    return instance
  }()
  private lazy var percentageLabel: UILabel = {
    let instance = UILabel()
    instance.backgroundColor = .clear
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption2)
    instance.textAlignment = .center
//    instance.widthAnchor.constraint(equalToConstant: "100 %".width(withConstrainedHeight: 100, font: instance.font)).isActive = true
    instance.textColor = .white // color
    
    return instance
  }()
  private lazy var percentageView: PercentageView = {
    let instance = PercentageView(lineWidth: "1".height(withConstrainedWidth: 100,
                                                        font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular,
                                                                                forTextStyle: .caption2)!) + padding/8,
                                  foregoundColor: traitCollection.userInterfaceStyle == .dark ? color : .white.blended(withFraction: 0.85, of: color),
                                  backgroundLightColor: (isAnswerSelected || isChosen) ? .secondarySystemBackground : .systemFill,
                                  backgroundDarkColor: (isAnswerSelected || isChosen) ? .secondarySystemBackground : .tertiarySystemBackground)
    instance.addSubview(checkmark)
    instance.addSubview(percentageLabel)
    checkmark.translatesAutoresizingMaskIntoConstraints = false
    percentageLabel.translatesAutoresizingMaskIntoConstraints = false
    checkmark.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: padding/2).isActive = true
    checkmark.centerYAnchor.constraint(equalTo: instance.centerYAnchor).isActive = true
    checkmark.heightAnchor.constraint(equalToConstant: instance.lineWidth - padding/2).isActive = true
//    checkmark.widthAnchor.constraint(equalTo: checkmark.heightAnchor).isActive = true
    if isChosen, let widthAnchor = checkmark.getConstraint(identifier: "widthAnchor") {
      widthAnchor.constant = instance.lineWidth // - padding/2
    }

    percentageLabel.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: padding/2).isActive = true
    percentageLabel.centerYAnchor.constraint(equalTo: instance.centerYAnchor).isActive = true
    percentageLabel.heightAnchor.constraint(equalTo: checkmark.heightAnchor).isActive = true
    
    
//    checkmark.widthAnchor.constraint(equalTo: checkmark.heightAnchor).isActive = true
    
//    checkmark.placeLeadingYCentered(inside: instance, leadingInset: padding/2)
//    percentageLabel.placeLeadingYCentered(inside: instance, leadingInset: padding/2)
    
    return instance
  }()
  private lazy var rightButton: UIButton = {
    let instance = UIButton()
    instance.imageEdgeInsets.left = padding/4
    instance.semanticContentAttribute = .forceRightToLeft
    instance.adjustsImageWhenHighlighted = false
    instance.layer.masksToBounds = false
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
    instance.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: padding)
    instance.setImage(UIImage(systemName: ("chevron.right"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? color : .white.blended(withFraction: 0.85, of: color)
    instance.publisher(for: \.bounds)
      .filter { $0.width > 0 }
      .sink { [weak self] in
        guard let self = self,
              let opaque2 = self.statsStack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "opaque2" }).first,
              let constraint = opaque2.getConstraint(identifier: "widthAnchor"),
              $0.width > constraint.constant
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = $0.width
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    //    instance.setAttributedTitle(NSAttributedString(string: "999 K", attributes: [
    //      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
    //      .foregroundColor: self.color
    //     ]), for: .normal)
    
    return instance
  }()
  //  private lazy var disclosureIndicator: UIImageView = {
  //    let instance = UIImageView(image: UIImage(systemName: "chevron.right"))
  //    instance.accessibilityIdentifier = "chevron"
  //    instance.clipsToBounds = true
  //    instance.tintColor = .label
  //    instance.contentMode = .center
  //    instance.preferredSymbolConfiguration = .init(textStyle: .headline, scale: .small)
  //    instance.isUserInteractionEnabled = true
  //    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(sender:))))
  //    instance.alpha = item.totalVotes == 0 ? 0 : 1
  //    instance.tintColor = color
  //
  //    let constraint = instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/3)
  //    constraint.identifier = "widthAnchor"
  //    constraint.isActive = true
  //
  //    return instance
  //  }()
  private lazy var checkmark: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.contentMode = .scaleAspectFit
    instance.alpha = (isAnswerSelected || isChosen) ? 1 : 0
    instance.tintColor = .white//traitCollection.userInterfaceStyle == .dark ? color : .white.blended(withFraction: 0.85, of: color)
    
    let widthAnchor = instance.widthAnchor.constraint(equalToConstant: 0)
    widthAnchor.isActive = true
    widthAnchor.identifier = "widthAnchor"
    //    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)!)).isActive = true
    //    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    
    //    instance.widthAnchor.constraint(equalToConstant: 30).isActive = true
    
    return instance
  }()
  private lazy var votersStack: VotersStack = {
    let instance = VotersStack(userprofiles: Array(item.voters.prefix(avatarsThreshold)),
                               capacity: avatarsThreshold,
                               lightBorderColor: isChosen ? Colors.Poll.choiceSelectedBackgroundLight : Colors.Poll.choiceBackgroundLight,
                               darkBorderColor: isChosen ? Colors.Poll.choiceSelectedBackgroundDark : Colors.Poll.choiceBackgroundDark,
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
    
//    stackView.backgroundColor = !isChosen ? .clear : color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2)
    stackView.layer.shadowOpacity = isChosen ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    if let bgLayer = stackView.layer.getSublayer(name: "bgLayer") {
      bgLayer.backgroundColor = isChosen ? traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.systemBackground.cgColor : UIColor.clear.cgColor
    }
  }
}

private extension AnswerCell {
  @MainActor
  func setupUI() {
    guard let survey = item.survey else { return }
    
    let attributes: [NSAttributedString.Key: Any] = {
      let font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
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
    contentView.layer.masksToBounds = false
    let inset = padding/2 + lineSpacing
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
    
    textView.attributedText = NSAttributedString(string: item.description, attributes: attributes)
    
    percentageLabel.text = item.percentString
    ///UI settings
    imageView.tintColor = survey.isComplete ? traitCollection.userInterfaceStyle == .dark ? color : .white.blended(withFraction: 0.85, of: color) : (isChosen || isAnswerSelected) ? traitCollection.userInterfaceStyle == .dark ? color : .white.blended(withFraction: 0.85, of: color) : .systemGray
    imageView.setImage(UIImage(systemName: "\(item.order+1).circle.fill")!)
    
    if survey.isComplete {
      openConstraint.isActive = true
      percentageView.setPercent(value: item.percent, animated: false)
//      stackView.backgroundColor = !isChosen ? .clear : color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.1)
      stackView.layer.shadowOpacity = isChosen ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    } else {
      closedConstraint.isActive = true
//      stackView.backgroundColor = !isChosen ? .clear : color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.1)
      stackView.layer.shadowOpacity = isChosen ? traitCollection.userInterfaceStyle == .dark ? 0 : 1 : 0
    }
    
    if let survey = item.survey {
      self.rightButton.setAttributedTitle(NSAttributedString(string: self.item.totalVotes.roundedWithAbbreviations, attributes: [
        .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .subheadline) as Any,
        .foregroundColor: item.totalVotes > 0 ? self.color : .secondaryLabel
       ]), for: .normal)
      rightButton.imageView?.alpha = (item.totalVotes > 0 && !survey.isAnonymous) ? 1 : 0
    }
  }
  
  @MainActor
  func setSelected(forceDeselect: Bool = false, _ completion: Closure? = nil) {
    guard let survey = item.survey else { return }
    
    if forceDeselect {
      guard let selection = stackView.getLayer(identifier: "selection") else { return }
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
        selection.opacity = 0
        selection.transform = CATransform3DMakeTranslation(1, 0.01, 1)
      } completion: { _ in selection.removeFromSuperlayer(); completion?() }
      
      return
    }
    
    guard !survey.isComplete else { return }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      self.imageView.tintColor = self.isAnswerSelected ? traitCollection.userInterfaceStyle == .dark ? self.color : .white.blended(withFraction: 0.85, of: self.color) : .systemGray
    }
    
    switch isAnswerSelected {
    case true:
      stackView.getLayer(identifier: "selection")?.removeFromSuperlayer()
      selectionPublisher.send(item)
      let selection = CALayer()
      selection.name  = "selection"
      selection.backgroundColor = /*survey.topic.tagColor*/color.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2).cgColor
      selection.frame = CGRect(origin: .zero, size: textView.bounds.size)
      selection.cornerRadius = stackView.bounds.width*0.025
      selection.opacity = 0
      stackView.layer.insertSublayer(selection, at: 1)
      
      Animations.unmaskLayerCircled(layer: selection,
                                    location: touchLocation,
                                    duration: 0.3,
                                    opacityDurationMultiplier: 0.5,
                                    delegate: self) { completion?() }
    case false:
      deselect()
    }
  }
  
  @MainActor
  func setChosen() {
    votersStack.setColors(lightBorderColor: Colors.Poll.choiceSelectedBackgroundLight,
                          darkBorderColor: Colors.Poll.choiceSelectedBackgroundDark)
    
    deselect()
    if let bgLayer = self.stackView.layer.getSublayer(name: "bgLayer"), isChosen || isAnswerSelected {
      
      bgLayer.add(Animations.get(property: .BackgroundColor,
                                 fromValue: bgLayer.backgroundColor as Any,
                                 toValue:  self.traitCollection.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground.cgColor : UIColor.systemBackground.cgColor,
                                 duration: 0.2,
                                 delegate: nil), forKey: nil)
      bgLayer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
    }
    
    if traitCollection.userInterfaceStyle != .dark, isChosen || isAnswerSelected {
      stackView.layer.add(Animations.get(property: .ShadowOpacity, fromValue: 0, toValue: 1, duration: 0.2, delegate: nil), forKey: nil)
      stackView.layer.shadowOpacity = 1
    }
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }

        self.imageView.tintColor = self.traitCollection.userInterfaceStyle == .dark ? self.color : .white.blended(withFraction: 0.85, of: self.color)
        self.checkmark.alpha = (self.isChosen || self.isAnswerSelected) ? 1 : 0
        if self.isChosen || self.isAnswerSelected, let constraint = checkmark.getConstraint(identifier: "widthAnchor") {
          self.percentageView.setNeedsLayout()
          constraint.constant = self.percentageView.lineWidth
          self.percentageView.setNeedsLayout()
        }
      }
    
//    guard let selection = stackView.getLayer(identifier: "selection") else {
//      UIView.animate(
//        withDuration: 0.3,
//        delay: 0,
//        usingSpringWithDamping: 0.8,
//        initialSpringVelocity: 0.3,
//        options: [.curveEaseInOut]) { [weak self] in
//          guard let self = self else { return }
//
//          self.stackView.backgroundColor = (self.isChosen || self.isAnswerSelected) ?  self.color.withAlphaComponent(self.traitCollection.userInterfaceStyle == .dark ? 0.4 : 0.2) : .clear
//        }
//
//      return
//    }
    
    
//    stackView.publisher(for: \.bounds)
//      .sink { selection.bounds.size.height = $0.height }
    //      .store(in: &subscriptions)
//    UIView.animate(
//      withDuration: 0.3,
//      delay: 0,
//      usingSpringWithDamping: 0.8,
//      initialSpringVelocity: 0.3,
//      options: [.curveEaseInOut]) { [weak self] in
//        guard let self = self else { return }
//
//        selection.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? self.color.withAlphaComponent(0.4).cgColor : self.color.withAlphaComponent(0.2).cgColor
//        selection.frame = self.stackView.frame
//      }
  }
  
//  func observeVoters() {
//    guard let item = item else { return }
//
//    item.votersPublisher
//      .receive(on: DispatchQueue.main)
//      .sink { [weak self] in
//        guard let self = self else { return }
//
//        self.votersStack.push(userprofiles: $0.suffix(5))
//      }
//      .store(in: &subscriptions)
//  }
  
  @objc
  func handleGesture(sender: UITapGestureRecognizer) {
    guard let view = sender.view else { return }
    
    touchLocation = sender.location(ofTouch: 0, in: self)
    
    if view == textView {
      isAnswerSelected = !isAnswerSelected
      if !isAnswerSelected {
        deselectionPublisher.send(true)
      }
//    } else if let survey = item.survey,
//              survey.isComplete,
//              !survey.isAnonymous,
//              item.totalVotes > 0,
//              (view == disclosureIndicator || view == votersCountLabel) {//} || view.accessibilityIdentifier == "opaque") {
//      votersPublisher.send(item)
    }
  }
  
  @objc
  func handleTap() {
    guard let survey = item.survey, !survey.isAnonymous else { return }
    
    votersPublisher.send(item)
  }
  
  func deselect(_ completion: Closure? = nil) {
    guard let selection = stackView.getLayer(identifier: "selection") else { return }
    
    selection.add(Animations.get(property: .Opacity,
                                 fromValue: 1,
                                 toValue: 0,
                                 duration: 0.2,
                                 timingFunction: .easeOut,
                                 delegate: self,
                                 isRemovedOnCompletion: false,
                                 completionBlocks: [{
      selection.removeFromSuperlayer(); completion?()}]),
                  forKey: nil)
    selection.add(Animations.get(property: .Scale,
                                 fromValue: selection.affineTransform(),
                                 toValue: selection.setAffineTransform(CGAffineTransform(scaleX: 1, y: 0.1)),//0.1,
                                 duration: 0.2,
                                 timingFunction: .easeOut,
                                 delegate: self,
                                 isRemovedOnCompletion: false,
                                 completionBlocks: [{
      selection.removeFromSuperlayer(); completion?()}]),
                  forKey: nil)
  }
}

extension AnswerCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        }
    }
}
