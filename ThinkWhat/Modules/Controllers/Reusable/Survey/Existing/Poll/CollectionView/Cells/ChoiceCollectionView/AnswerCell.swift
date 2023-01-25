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
      
      updateUI(animated: false)
      
      guard let survey = item.survey else { return }
      
      survey.reference.isCompletePublisher
        .filter { $0 }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.closedConstraint.isActive = false
          self.openConstraint.isActive = true
          self.updatePublisher.send(true)
          
          self.updateUI()
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            self.observeVoters()
          }
        }
        .store(in: &subscriptions)
      //Update stats
      survey.reference.votesPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          UIView.transition(with: self.percentageLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.percentageLabel.text = item.percentString
          } completion: { _ in }
          
          UIView.transition(with: self.votersLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.votersLabel.text = item.totalVotes == 0 ? "no_votes".localized.uppercased() : item.totalVotes.roundedWithAbbreviations
          } completion: { _ in }
          
          self.percentageView.setPercent(value: item.percent, animated: true)
        }
        .store(in: &subscriptions)
      
      guard survey.reference.isComplete else { return }
      //Voters append
      observeVoters()
    }
  }
  //Publishers
  public let selectionPublisher = PassthroughSubject<Answer, Never>()
  public let deselectionPublisher = PassthroughSubject<Bool, Never>()
  public let updatePublisher = PassthroughSubject<Bool, Never>()
  public let votersPublisher = PassthroughSubject<Answer, Never>()
  //Logic
  public var isAnswerSelected = false {
    didSet {
      guard oldValue != isAnswerSelected else { return }
      
      updateUI(animated: true)
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
  //Logic
  private var isChosen: Bool {
    guard let survey = item.survey,
          let result = survey.result,
          result.keys.first == item.id else {
      return false
    }
    return true
  }
  //UI
  private let padding: CGFloat = 8
  private let lineSpacing: CGFloat = 4
  private var avatars: [Avatar] = []
  private lazy var horizontalStack: UIStackView = {
    let spacer = UIView.opaque()
    
    let instance = UIStackView(arrangedSubviews: [
      percentageLabel,
      percentageView,
      checkmark,
      spacer,
      votersLabel,
      votersView,
//      votersCountLabel,
      disclosureIndicator
    ])
    instance.axis = .horizontal
    instance.clipsToBounds = false
    instance.spacing = 4
    
    votersLabel.translatesAutoresizingMaskIntoConstraints = false
    votersView.translatesAutoresizingMaskIntoConstraints = false
    disclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
    percentageView.translatesAutoresizingMaskIntoConstraints = false
    spacer.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      votersLabel.heightAnchor.constraint(equalTo: instance.heightAnchor),
      votersView.heightAnchor.constraint(equalTo: instance.heightAnchor),
//      checkmark.heightAnchor.constraint(equalTo: instance.heightAnchor),
//      checkmark.widthAnchor.constraint(equalTo: checkmark.heightAnchor, multiplier: 1/1),
      disclosureIndicator.heightAnchor.constraint(equalTo: instance.heightAnchor),
      spacer.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.065),
      percentageView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.45)
      //            votersLabel.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.6)
    ])
    
    return instance
  }()
  private lazy var percentageLabel: UILabel = {
    let instance = UILabel()
    instance.backgroundColor = .clear
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption1)
    instance.textAlignment = .right
    instance.widthAnchor.constraint(equalToConstant: "100 %".width(withConstrainedHeight: 100, font: instance.font)).isActive = true
    
    return instance
  }()
  private lazy var percentageView: PercentageView = {
    let instance = PercentageView(lineWidth: 10)
    instance.backgroundColor = .clear
    
    return instance
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
    
    let constraint = instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/3)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var checkmark: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(scale: .small)))
    instance.contentMode = .left
    instance.alpha = 0
//    instance.widthAnchor.constraint(equalToConstant: 30).isActive = true
    
    return instance
  }()
  private lazy var votersStack: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    
    horizontalStack.place(inside: instance,
                          insets: UIEdgeInsets(top: 0, left: padding, bottom: padding, right: padding))
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 44)
    constraint.identifier = "height"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var votersView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.alpha = 0
    instance.accessibilityIdentifier = "votersView"
    
    let constraint = instance.widthAnchor.constraint(equalToConstant: 0)
    constraint.identifier = "width"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var votersLabel: UILabel = {
    let instance = UILabel()
    instance.accessibilityIdentifier = "votersLabel"
    instance.backgroundColor = .clear
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .caption2)
    instance.textAlignment = .right
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGesture(sender:))))
    
    return instance
  }()
  private lazy var stackView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      textView,
      votersStack
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
  //Constraints
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
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overridden properties
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    updateUI(animated: false)
  }
}

private extension AnswerCell {
  @MainActor
  func setupUI() {
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
    closedConstraint.isActive = true
  }
  
  @MainActor
  func updateUI(animated: Bool = true) {
    guard let survey = item.survey,
          let image = UIImage(systemName: "\(item.order+1).circle.fill")
    else { return }
    
    let color = Colors.getColor(forId: item.order)
    
    if survey.isComplete, !item.voters.isEmpty { setVoters() }
    checkmark.alpha = 0
    votersLabel.alpha = 0
    percentageLabel.alpha = 0
    disclosureIndicator.alpha = 0
    percentageLabel.alpha = 0
    checkmark.tintColor = color
    disclosureIndicator.tintColor = color
    votersLabel.text = item.totalVotes == 0 ? "no_votes".localized.uppercased() : item.totalVotes.roundedWithAbbreviations
    percentageLabel.text = item.percentString
    votersLabel.textColor = item.totalVotes == 0 ? .secondaryLabel : color
    percentageLabel.textColor = color
    percentageView.setColor(foregound: color,
                            background: (isAnswerSelected || isChosen) ? .systemBackground : traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground,
                            animated: false)
    
    func attributes() -> [NSAttributedString.Key: Any] {
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
    }
    
    func animate() {
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self,
                let survey = self.item.survey
          else { return }
          
          if survey.isComplete {
//            self.setVoters()
//            self.percentageView.setPercent(value: self.item.percent, animated: true)
            self.imageView.tintColor = color
            self.imageView.transform = .identity
            self.votersLabel.textColor = self.item.totalVotes == 0 ? .secondaryLabel : color
            self.percentageLabel.textColor = color
            self.checkmark.alpha = (self.isAnswerSelected || self.isChosen) ? 1 : 0
            self.percentageLabel.alpha = 1
            if survey.isAnonymous {
              self.votersView.alpha = 0
              self.disclosureIndicator.alpha = 0
            } else {
              self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
            }
            self.votersLabel.alpha = 1
          } else {
            self.imageView.tintColor = self.isAnswerSelected ? survey.topic.tagColor : .systemGray
//            self.imageView.transform = self.isAnswerSelected ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
          }
        }) { _ in }
      
      UIView.transition(with: textView, duration: 0.15, options: .transitionCrossDissolve) { [weak self] in
        guard let self = self else { return }
        
        self.textView.attributedText = NSAttributedString(string: self.item.description,
                                                          attributes: attributes())
        if survey.isComplete {
          self.stackView.backgroundColor = !self.isAnswerSelected ? .clear : self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.1)
          self.textView.backgroundColor = .clear
        } else {
          self.stackView.backgroundColor = .clear
          self.textView.backgroundColor = !self.isAnswerSelected ? .clear : self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : survey.topic.tagColor.withAlphaComponent(0.1)
        }
      } completion: { _ in }
    }
    
    guard animated else {
      //Set attributed text
      textView.attributedText = NSAttributedString(string: item.description,
                                                   attributes: attributes())
      percentageLabel.alpha = 1
      self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
      checkmark.alpha = (isAnswerSelected || isChosen) ? 1 : 0
      votersLabel.alpha = survey.isComplete ? 1 : 0
      //Color
      imageView.tintColor = survey.isComplete ?color : (isChosen || isAnswerSelected) ? survey.topic.tagColor : .systemGray
      imageView.setImage(image)

      if survey.isComplete {
        closedConstraint.isActive = false
        openConstraint.isActive = true
        percentageView.setPercent(value: item.percent, animated: false)
        stackView.backgroundColor = !isChosen ? .clear : self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.1)
//        setVoters()
        if survey.isAnonymous {
          votersView.alpha = 0
          disclosureIndicator.alpha = 0
        }
      } else {
//        setNeedsLayout()
        openConstraint.isActive = false
        closedConstraint.isActive = true
//        layoutIfNeeded()
        stackView.backgroundColor = !isChosen ? .clear : self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : survey.topic.tagColor.withAlphaComponent(0.1)
      }
      return
    }
    
    animate()
  }
  
  @MainActor
  func setVoters() {
    guard votersView.alpha == 0,
          let survey = item.survey
    else { return }
    
    let color = Colors.getColor(forId: item.order)
    
    votersView.alpha = survey.isAnonymous ? 0 : 1
    votersLabel.text = item.totalVotes == 0 ? "no_votes".localized.uppercased() : item.totalVotes.roundedWithAbbreviations
    votersLabel.textColor = item.totalVotes == 0 ? .secondaryLabel : color
    
    guard !item.voters.isEmpty else {
      horizontalStack.getSubview(type: UIImageView.self, identifier: "chevron")?.alpha = 0
      if let constraint_2 = votersView.getConstraint(identifier: "width") {
        setNeedsLayout()
        constraint_2.constant = 0
        layoutIfNeeded()
      }
      
      return
    }
    
    votersLabel.textColor = color
    disclosureIndicator.tintColor = color
    self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
////    votersLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
//    if let constraint = horizontalStack.getConstraint(identifier: "height") {
//      setNeedsLayout()
//      constraint.constant = "test".height(withConstrainedWidth: 1000, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)!)
//      layoutIfNeeded()
//    }
    
    //Reverse by timestamp
    var _voters = item.voters.reversed().map { $0 }
    
    //Place user at first position
    if (isChosen || isAnswerSelected), _voters.contains(Userprofiles.shared.current!) {
      _voters.remove(object: Userprofiles.shared.current!)
      _voters.insert(Userprofiles.shared.current!, at: 0)
    }
    
    let voters = Array(_voters.suffix(3))
    
    if let constraint = votersView.getConstraint(identifier: "width") {
      setNeedsLayout()
      if voters.count == 0 {
        constraint.constant = 0
      } else if voters.count == 1 {
        constraint.constant = votersView.bounds.height
      } else if voters.count == 2 {
        constraint.constant = votersView.bounds.height * CGFloat(1.5)
      } else if voters.count == 3 {
        constraint.constant = votersView.bounds.height * CGFloat(2)
      }
      layoutIfNeeded()
    }
    
    voters.enumerated().forEach { index, userprofile in
      let avatar = Avatar(isBordered: true,
                          borderColor: (isChosen || isAnswerSelected) ? (traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.1)) : .clear)
      avatar.layer.zPosition = 10 - CGFloat(index)
      avatars.append(avatar)
      votersView.addSubview(avatar)
      avatar.translatesAutoresizingMaskIntoConstraints = false
      avatar.userprofile = userprofile.isCurrent ? Userprofiles.shared.current! : userprofile
      avatar.heightAnchor.constraint(equalTo: votersView.heightAnchor).isActive = true
      avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1/1).isActive = true
      avatar.tapPublisher
//        .filter { !$0.isNil }
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.votersPublisher.send(self.item)
        }
        .store(in: &subscriptions)
      
      
      //Set layout
      switch voters.count {
      case 1:
        if index == 0 {
          let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
          constraint.identifier = "centerXAnchor"
          constraint.isActive = true
        }
      case 2:
        if index == 0 {
          let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: -votersView.bounds.height/4)
          constraint.identifier = "centerXAnchor"
          constraint.isActive = true
        } else if index == 1 {
          let constraint =  avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: votersView.bounds.height/4)
          constraint.identifier = "centerXAnchor"
          constraint.isActive = true
        }
      default:
        if index == 0 {
          let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: -votersView.bounds.height/2)
          constraint.identifier = "centerXAnchor"
          constraint.isActive = true
        } else if index == 1 {
          let constraint =  avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
          constraint.identifier = "centerXAnchor"
          constraint.isActive = true
        } else if index == 2 {
          let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor, constant: votersView.bounds.height/2)
          constraint.identifier = "centerXAnchor"
          constraint.isActive = true
        }
      }
    }
  }
  
  func observeVoters() {
    guard let item = item else { return }
    
    item.votersPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.appendVoter(userprofile: $0)
      }
      .store(in: &subscriptions)
  }
  
  //Live voters update
  func appendVoter(userprofile: Userprofile) {
//    setVoters()
    votersView.alpha = 1
    let color = Colors.getColor(forId: item.order)

    guard avatars.map({ $0.userprofile }).filter({ $0 == userprofile }).isEmpty else { return }

    self.votersLabel.text = self.item.totalVotes == 0 ? "no_votes".localized.uppercased() : self.item.totalVotes.roundedWithAbbreviations

    let avatar = Avatar(isBordered: true,
                        borderColor: (isChosen || isAnswerSelected) ? (traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : color.withAlphaComponent(0.1)) : .clear)
    avatar.layer.zPosition = 10
    avatar.alpha = 0
    avatar.userprofile = userprofile.isCurrent ? Userprofiles.shared.current! : userprofile
    avatars.forEach{ $0.layer.zPosition -= 1 }
    votersView.addSubview(avatar)
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.tapPublisher
//      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self else { return }

        self.votersPublisher.send(self.item)
      }
      .store(in: &subscriptions)
    avatar.heightAnchor.constraint(equalTo: votersView.heightAnchor).isActive = true
    avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor, multiplier: 1/1).isActive = true

    //Check if it's a first voter
    if avatars.isEmpty, let widthConstraint = votersView.getConstraint(identifier: "width") {
      let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
      constraint.identifier = "centerXAnchor"
      constraint.isActive = true
      UIView.transition(with: votersLabel, duration: 0.5, options: .transitionCrossDissolve) {
        self.votersLabel.textColor = self.item.totalVotes == 0 ? .secondaryLabel : color
        //        self.votersLabel.text = self.item.totalVotes == 0 ? "no_votes".localized.uppercased() : self.item.totalVotes.roundedWithAbbreviations
        self.votersLabel.alpha = 1
        self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
        avatar.alpha = 1
        self.setNeedsLayout()
        widthConstraint.constant = self.votersView.bounds.height
        self.layoutIfNeeded()
      } completion: { _ in }

      return
    }

    switch avatars.count {
    case 1:
      let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor,
                                                       constant: -votersView.bounds.height/4)
//                                                       constant: (isChosen || isAnswerSelected) ? votersView.bounds.height/4 : -votersView.bounds.height/4)
      constraint.identifier = "centerXAnchor"
      constraint.isActive = true

      guard let last = avatars.last,
            let lastConstraint = last.getConstraint(identifier: "centerXAnchor"),
            let widthConstraint = votersView.getConstraint(identifier: "width")
      else { return }

      avatar.layer.zPosition = 10
      last.layer.zPosition = last.layer.zPosition - 1
//      avatar.layer.zPosition = (isChosen || isAnswerSelected) ? last.layer.zPosition - 1 : 10
//      last.layer.zPosition = (isChosen || isAnswerSelected) ? last.layer.zPosition : last.layer.zPosition - 1

      avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, animations: {
        avatar.alpha = 1
        avatar.transform = .identity
        self.setNeedsLayout()
        self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
        widthConstraint.constant += self.votersView.bounds.height/2
//        lastConstraint.constant += (self.isChosen || self.isAnswerSelected) ? -last.frame.width/4 : last.frame.width/4
        lastConstraint.constant +=  last.frame.width/4
        self.layoutIfNeeded()
      }) { _ in
//        if self.isChosen {
//          self.avatars.append(avatar)
//        } else {
          self.avatars.insert(avatar, at: 0)
//        }
      }
    case 2:
//      if isChosen {
//        let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
//        constraint.identifier = "centerXAnchor"
//        constraint.isActive = true
//      } else {
        let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor,
                                                         constant: -votersView.bounds.height/2)
        constraint.identifier = "centerXAnchor"
        constraint.isActive = true
//      }

      guard let leading = avatars.first,
            let trailing = avatars.last,
            let leadingConstraint = leading.getConstraint(identifier: "centerXAnchor"),
            let trailingConstraint = trailing.getConstraint(identifier: "centerXAnchor"),
            let widthConstraint = votersView.getConstraint(identifier: "width")
      else { return }

//      if isChosen {
//        avatar.layer.zPosition = leading.layer.zPosition - 1
//        trailing.layer.zPosition -= 1
//      } else {
        avatars.forEach { $0.layer.zPosition -= 1}
//      }

      avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, animations: {
        avatar.alpha = 1
        avatar.transform = .identity
        self.setNeedsLayout()
        widthConstraint.constant += self.votersView.bounds.height / 2
        self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
//        if self.isChosen || self.isAnswerSelected {
//          leadingConstraint.constant -= leading.frame.width/4
//          trailingConstraint.constant += leading.frame.width/4
//        } else {
          trailingConstraint.constant += leading.frame.width/4
          leadingConstraint.constant += leading.frame.width/4
//        }
        self.layoutIfNeeded()
      }) { _ in
//        if self.isChosen {
//          self.avatars.insert(avatar, at: 1)
//        } else {
          self.avatars.insert(avatar, at: 0)
//        }
      }
    default:
//      if isChosen || isAnswerSelected {
//        let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor)
//        constraint.identifier = "centerXAnchor"
//        constraint.isActive = true
//      } else {
        let constraint = avatar.centerXAnchor.constraint(equalTo: votersView.centerXAnchor,
                                                         constant: -votersView.bounds.height/2)
        constraint.identifier = "centerXAnchor"
        constraint.isActive = true
//      }

      guard let leading = avatars.first,
            let middle = avatars[1] as? Avatar,
            let trailing = avatars.last,
            let leadingConstraint = leading.getConstraint(identifier: "centerXAnchor"),
            let middleConstraint = middle.getConstraint(identifier: "centerXAnchor"),
            let trailingConstraint = trailing.getConstraint(identifier: "centerXAnchor")
      else { return }

//      if isChosen || isAnswerSelected {
//        avatar.layer.zPosition = leading.layer.zPosition - 1
//        middle.layer.zPosition -= 1
//        trailing.layer.zPosition -= 1
//      } else {
        avatars.forEach { $0.layer.zPosition -= 1}
//      }

      avatar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.35, delay: 0, animations: {
        avatar.alpha = 1
        avatar.transform = .identity
        trailing.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        trailing.alpha = 0
        self.setNeedsLayout()
        self.disclosureIndicator.alpha = self.item.totalVotes == 0 ? 0 : 1
//        leadingConstraint.constant += (self.isChosen || self.isAnswerSelected) ? 0 : leading.frame.width/2
        leadingConstraint.constant += leading.frame.width/2
        middleConstraint.constant += leading.frame.width/2
        trailingConstraint.constant += leading.frame.width/2
        self.layoutIfNeeded()
      }) { _ in
//        if self.isChosen || self.isAnswerSelected {
//          self.avatars.insert(avatar, at: 1)
//        } else {
          self.avatars.insert(avatar, at: 0)
//        }
        self.avatars.remove(object: trailing)
        trailing.removeFromSuperview()
      }
    }
  }
  
  @objc
  func handleGesture(sender: UITapGestureRecognizer) {
    if sender.view == textView {
      guard !item.survey!.isComplete else { return }
      
      isAnswerSelected = !isAnswerSelected
      switch isAnswerSelected {
      case true:
        selectionPublisher.send(item)
      case false:
        deselectionPublisher.send(true)
      }
    } else if let survey = item.survey, survey.isComplete, (sender == disclosureIndicator || sender == votersLabel) {
      votersPublisher.send(self.item)
    }
  }
}
