//
//  SubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public weak var item: SurveyReference! {
    didSet {
      guard !item.isNil else { return }
      
//      setupUI()
      updateUI()
      updateProgress(animated: false)
      
      setSubscriptions()
      
      item.isCompletePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.comleteButton.tintColor = self.item.isComplete ? self.item.topic.tagColor : .systemGray4
          self.buttonsStack.insertArrangedSubview(self.watchButton, at: 0)
          self.buttonsStack.insertArrangedSubview(self.comleteButton, at: 1)
          self.buttonsStack.insertArrangedSubview(self.comleteButton, at: 1)
          self.buttonsStack.removeArrangedSubview(self.claimButton)
          self.claimButton.removeFromSuperview()
        }
        .store(in: &subscriptions)
      
      item.isVisitedPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          let textColor: UIColor = self.item.isOwn ? .label : self.item.isVisited ? .secondaryLabel : .label
          
          self.viewsLabel.textColor = textColor
          self.viewsImage.tintColor = textColor
          self.ratingLabel.textColor = textColor
          self.commentsLabel.textColor = textColor
          self.commentsImage.tintColor = textColor
          self.claimButton.tintColor = textColor
          self.comleteButton.tintColor = textColor
          self.titleLabel.textColor = textColor
          self.descriptionLabel.textColor = textColor
        }
        .store(in: &subscriptions)
      
      item.progressPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.updateProgress(animated: true)
        }
        .store(in: &subscriptions)
    }
  }
  //    public var updatePublisher = PassthroughSubject<SurveyReference, Never>()
  public private(set) var watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
  public private(set) var claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
  public private(set) var shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
  public private(set) var profileTapPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public private(set) var subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public private(set) var unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
  public private(set) var settingsTapPublisher = CurrentValueSubject<Bool?, Never>(nil)
  //UI
  public private(set) lazy var avatar: Avatar = {
    let instance = Avatar(isShadowed: traitCollection.userInterfaceStyle != .dark, showsProgress: true)
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.isUserInteractionEnabled = true
    instance.tapPublisher
      .filter { $0 != Userprofile.anonymous }
      .sink { [weak self] in
        guard let self = self else { return }
        
        guard $0.isCurrent else {
          self.profileTapPublisher.send($0)
          
          return
        }
        self.settingsTapPublisher.send(true)
        
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var itemSubscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  let padding: CGFloat = 10
  //Header
  private lazy var tagCapsule: TagCapsule = {
//    let title = item.topic.isOther ? "\(item.topic.parent!.title.localized)/\(item.topic.title.localized)" : { item.topic.title.localized }()
    let instance = TagCapsule(text: "",//title.uppercased(),
                              padding: padding,
                              textPadding: .init(top: padding/3, left: 0, bottom: padding/3, right: 0),
                              color: .clear,//item.topic.tagColor,
                              font: UIFont(name: Fonts.Rubik.Medium, size: 11)!,
                              isShadowed: false,
                              iconCategory: .Null,//item.topic.isOther ? item.topic.parent!.iconCategory : item.topic.iconCategory,
                              image: nil)
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: instance.font) + padding/2).isActive = true
    
    return instance
  }()
  private lazy var topView: UIStackView = {
//    func createStack() -> UIStackView {
//      //Topic & progress
//      let nestedStack = UIStackView(arrangedSubviews: [
//        topicView,
//        progressView
//      ])
//      nestedStack.axis = .horizontal
//      nestedStack.accessibilityIdentifier = "nestedStack"
//      nestedStack.spacing = 4
//
//      let stack = UIStackView(arrangedSubviews: [
//        nestedStack,
//        dateLabel
//      ])
//      stack.axis = .vertical
//      stack.spacing = 4
//
//      return stack
//    }
    
    let nested = {
      let instance = UIStackView(arrangedSubviews: [
        tagCapsule,
        dateLabel
      ])
      instance.axis = .vertical
      instance.spacing = padding/2
      instance.alignment = .leading

      return instance
    }()
    
    let opaque = UIView.opaque()
    avatar.place(inside: opaque, insets: .uniform(size: padding/2))
        
    let instance = UIStackView(arrangedSubviews: [
      UIView.horizontalSpacer(padding),
      nested,
      UIView.opaque(),
      usernameLabel,
      UIView.horizontalSpacer(padding),
      opaque,
//      avatar,
      UIView.horizontalSpacer(padding),
    ])
    instance.axis = .horizontal
    instance.spacing = 0//padding
    
    return instance
  }()
  private lazy var usernameLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption1)
    instance.textAlignment = .right
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.numberOfLines = 2
    
    return instance
  }()

  private lazy var dateLabel: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption1)
    instance.textAlignment = .left
    instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: instance.font)).isActive = true
#if DEBUG
    instance.text = "01.02.2013"
#endif
    
    return instance
  }()
  private lazy var contextInteraction: UIContextMenuInteraction = { .init(delegate: self) }()
  //Content
  private lazy var middleView: UIStackView = {
    let opaque = UIView.opaque()
    titleLabel.place(inside: opaque,
                     insets: .init(top: padding, left: padding, bottom: 0, right: padding))
    let opaque2 = UIView.opaque()
    descriptionLabel.place(inside: opaque2,
                     insets: .init(top: 0, left: padding, bottom: 0, right: padding))
    let instance = UIStackView(arrangedSubviews: [
      opaque,
      opaque2,
//      imageContainer
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var titleLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .left
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .title1)
    instance.numberOfLines = 0
    instance.lineBreakMode = .byTruncatingTail
    instance.textColor = .label
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
    constraint.identifier = "height"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var descriptionLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .left
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.numberOfLines = 0
    instance.lineBreakMode = .byTruncatingTail
    instance.textColor = .label
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
    constraint.identifier = "height"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView()
    instance.clipsToBounds = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.contentMode = .scaleAspectFill
    
    return instance
  }()
  private lazy var imageContainer: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.layer.masksToBounds = false
//    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
//    instance.layer.shadowOffset = .zero
//    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//    instance.layer.shadowRadius = padding
//    instance.publisher(for: \.bounds)
//      .sink { [unowned self] in
//        instance.layer.shadowPath = UIBezierPath(rect: $0).cgPath//roundedRect: $0, cornerRadius: $0.width*0.025).cgPath
//        self.imageView.cornerRadius = $0.width*0.025
//      }
//      .store(in: &subscriptions)
    
    imageView.place(inside: instance)
    
    return instance
  }()
  //Stats
  private lazy var bottomView: UIStackView = {
    let spacer = UIView()
    spacer.backgroundColor = .clear
    let instance = UIStackView(arrangedSubviews: [
      UIView.horizontalSpacer(padding),
      statsStack,
      spacer,
      buttonsStack,
      UIView.horizontalSpacer(padding),
    ])
    instance.axis = .horizontal
    instance.spacing = 0//8
    
    return instance
  }()
  private lazy var statsStack: UIStackView = {
    let ratingStack = UIStackView(arrangedSubviews: [ratingImage, ratingLabel])
    //        ratingView.heightAnchor.constraint(equalTo: ratingLabel.heightAnchor, multiplier: 1.5).isActive = true
    ratingStack.spacing = 2
    
    let viewsStack = UIStackView(arrangedSubviews: [viewsImage, viewsLabel])
    viewsStack.spacing = 2
    
    let commentsStack = UIStackView(arrangedSubviews: [commentsImage, commentsLabel])
    commentsStack.spacing = 2
    
    let instance = UIStackView(arrangedSubviews: [ratingStack, viewsStack, commentsStack])
    instance.spacing = 6
    instance.alignment = .center
    
    return instance
  }()
  private lazy var ratingImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "star.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                                             scale: .medium)))
    instance.tintColor = Constants.UI.Colors.Logo.Marigold.rawValue//.systemGray//
    instance.contentMode = .center
    return instance
  }()
  private lazy var ratingLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption1)
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] rect in
        guard let self = self,
              let text = instance.text,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }
        
        self.setNeedsLayout()
        constraint.constant = text.height(withConstrainedWidth: rect.width, font: instance.font) * 1.5
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var viewsImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "eye.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                                             scale: .medium)))
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.contentMode = .center
    return instance
  }()
  private lazy var viewsLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption1)
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    return instance
  }()
  private lazy var commentsImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "bubble.right.fill",
                                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                                             scale: .medium)))
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.contentMode = .center
    
    return instance
  }()
  private lazy var commentsLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .caption1)
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
//      comleteButton,
//      watchButton,
//      claimButton,
    ])
    instance.spacing = 8
    instance.alignment = .center
    
    return instance
  }()
  private lazy var comleteButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "checkmark.seal.fill",
                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                             scale: .large)),
                      for: .normal)
    instance.tintColor = .systemGray4
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.addTarget(self, action: #selector(self.handleTap(sender:)), for: .touchUpInside)
    
    return instance
  }()
  private lazy var watchButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "binoculars.fill",
                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                             scale: .large)),
                      for: .normal)
    instance.tintColor = .systemGray4
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor,
                                    multiplier: 1/1).isActive = true
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    
    return instance
  }()
  private lazy var claimButton: UIButton = {
    let instance = UIButton()
    instance.setImage(UIImage(systemName: "exclamationmark.triangle.fill",
                              withConfiguration: UIImage.SymbolConfiguration(textStyle: UIFont.TextStyle.subheadline,
                                                                             scale: .large)),
                      for: .normal)
    instance.tintColor = .systemOrange.withAlphaComponent(0.75) //traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor,
                                    multiplier: 1/1).isActive = true
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    itemSubscriptions.forEach { $0.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  

  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setTasks()
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.surveyCellDark : Constants.UI.Colors.surveyCellLight
    avatar.isShadowed = traitCollection.userInterfaceStyle != .dark
    ratingLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    viewsLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    commentsLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    viewsImage.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    commentsImage.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    comleteButton.tintColor = item.isComplete ? item.topic.tagColor : .systemGray4
    watchButton.tintColor = item.isFavorite ? .label : .systemGray4
    
//    imageContainer.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    itemSubscriptions.forEach { $0.cancel() }
    item = nil
    
    //Reset publishers
    watchSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    claimSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    shareSubject = CurrentValueSubject<SurveyReference?, Never>(nil)
    profileTapPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    subscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    unsubscribePublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    settingsTapPublisher = CurrentValueSubject<Bool?, Never>(nil)
    
    //UI clean up
    descriptionLabel.text = ""
    titleLabel.text = ""
    imageView.image = nil
//    progressView.alpha = 0
    avatar.removeInteraction(contextInteraction)
    avatar.clearImage()
    middleView.removeArrangedSubview(imageContainer)
    imageContainer.removeFromSuperview()
    
    if let constraint = imageContainer.getConstraint(identifier: "imageContainer") {
      imageContainer.removeConstraint(constraint)
    }
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
}



// MARK: - Private
private extension SurveyCell {
  @MainActor
  func setupUI() {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.surveyCellDark : Constants.UI.Colors.surveyCellLight//.white.blended(withFraction: 0.2, of: .gray)
    clipsToBounds = true
    
    let stackView = UIStackView(arrangedSubviews: [
      topView,
      middleView,
      bottomView
    ])
    stackView.axis = .vertical
    stackView.spacing = padding//*2
    
    stackView.place(inside: contentView,
                    insets: .init(top: padding, left: 0, bottom: padding, right: 0),
                    bottomPriority: .defaultLow)
  }
  
  func setTasks() { }
  
  func setSubscriptions() {
    guard let item = item else { return }
    
    let duration = 0.15
    
    item.ratingPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] rating in
        guard let self = self else { return }
        
        UIView.transition(with: self.ratingLabel, duration: duration, options: .transitionCrossDissolve) { [weak self] in
          guard let self = self else { return }
          self.ratingLabel.text = String(describing: rating)
        } completion: { _ in }
      }
      .store(in: &itemSubscriptions)
    
    item.isFavoritePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] flag in
        guard let self = self else { return }
        
        watchButton.setSpinning(on: false, animated: false) { [weak self] in
          guard let self = self else { return }
          
          self.watchButton.imageView?.tintColor = flag ? .label : .systemGray4
        }
        
        //                guard flag else { return }
        //
        //                let banner = Banner(fadeBackground: false)
        //                banner.present(content: TextBannerContent(image: UIImage(systemName: "binoculars.fill")!,
        //                                                          text: "watch_survey_notification",
        //                                                          tintColor: .label),
        //                               dismissAfter: 0.75)
        //                banner.didDisappearPublisher
        //                    .sink { _ in banner.removeFromSuperview() }
        //                    .store(in: &self.subscriptions)
      }
      .store(in: &itemSubscriptions)
    
    item.viewsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] count in
        guard let self = self else { return }
        
        UIView.transition(with: self.viewsLabel, duration: duration, options: .transitionCrossDissolve) {
          self.viewsLabel.text = String(describing: count)
        } completion: { _ in }
      }
      .store(in: &itemSubscriptions)
    
    item.isActivePublisher
      .receive(on: DispatchQueue.main)
      .filter { !$0 }
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.setFinished()
      }
      .store(in: &itemSubscriptions)
    
    item.commentsTotalPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] count in
        guard let self = self else { return }
        
        UIView.transition(with: self.commentsLabel, duration: duration, options: .transitionCrossDissolve) {
          self.commentsLabel.text = String(describing: count.roundedWithAbbreviations)
        } completion: { _ in }
      }
      .store(in: &itemSubscriptions)
    
  }
  
  @MainActor
  func updateProgress(animated: Bool = true) {
    avatar.setProgress(value: Double(item.progress), duration: 0.3)
  }
  
  @MainActor
  func updateUI() {
    func updateHeader() {
      let title = item.topic.isOther ? "\(item.topic.parent!.title.localized)/\(item.topic.title.localized)" : { item.topic.title.localized }()
      tagCapsule.text = title.uppercased()
      tagCapsule.color = item.topic.tagColor
      tagCapsule.iconCategory = item.topic.isOther ? item.topic.parent!.iconCategory : item.topic.iconCategory
//      if item.isComplete {
//        //                titleLabel.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)
//        progressView.alpha = 1
//      }
      dateLabel.text = item.startDate.timeAgoDisplay()
      dateLabel.textColor = self.item.isOwn ? .label : self.item.isVisited ? .secondaryLabel : .label
      usernameLabel.textColor = self.item.isOwn ? .label : self.item.isVisited ? .secondaryLabel : .label
      avatar.setProgressColor(item.topic.tagColor)
      
      if item.isAnonymous {
        avatar.userprofile = Userprofile.anonymous
        usernameLabel.text = ""
      } else {
        avatar.userprofile = item.owner.isCurrent ? Userprofiles.shared.current : item.owner
        usernameLabel.text = item.owner.username
        
        guard !item.owner.isCurrent else { return }

        avatar.addInteraction(UIContextMenuInteraction(delegate: self))
      }
    }
    
    func updateMiddle() {
      guard let constraint = titleLabel.getConstraint(identifier: "height"),
            let constraint2 = descriptionLabel.getConstraint(identifier: "height")
      else { return }
      
      titleLabel.text = item.title
      titleLabel.textColor = item.isOwn ? .label : item.isVisited ? .secondaryLabel : .label
      descriptionLabel.text = item.truncatedDescription
      descriptionLabel.textColor = self.item.isOwn ? .label : self.item.isVisited ? .secondaryLabel : .label
      
      constraint.constant = item.title.height(withConstrainedWidth: bounds.width, font: titleLabel.font)
      constraint2.constant = item.truncatedDescription.height(withConstrainedWidth: bounds.width, font: descriptionLabel.font)
      
      //Media
      guard let media = item.media else { return }
//        middleView.removeArrangedSubview(imageContainer)
//        imageContainer.removeFromSuperview()
//        
//        return
//      }
//      
      middleView.addArrangedSubview(imageContainer)
      
      let aspectRatio = imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 9/16)
      aspectRatio.identifier = "imageContainer"
      aspectRatio.isActive = true
      
      guard let image = media.image else {
        let shimmer = Shimmer()
        shimmer.backgroundColor = .clear
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.clipsToBounds = true
        shimmer.place(inside: imageContainer)
        shimmer.startShimmering()
        media.imagePublisher
          .receive(on: DispatchQueue.main)
          .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
#if DEBUG
              print("success")
#endif
            case .failure(let error):
#if DEBUG
              print(error)
#endif
            }
          }, receiveValue: { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.15, delay: 0, animations: {
              shimmer.alpha = 0
            }) { _ in
              shimmer.stopShimmering(animated: true)
              shimmer.removeFromSuperview()
            }
            self.imageView.image = $0
            self.imageView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
          })
          .store(in: &subscriptions)
        media.downloadImage()
        
        return
      }
      imageView.image = image
      constraint2.constant = item.truncatedDescription.height(withConstrainedWidth: bounds.width, font: descriptionLabel.font)
      //            middleView.layoutIfNeeded()
    }
    
    func updateBottom() {
      let textColor: UIColor = item.isOwn ? .label : item.isVisited ? .secondaryLabel : .label
      
      ratingLabel.text = String(describing: String(describing: item.rating))
      ratingLabel.textColor = textColor
      commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
      commentsLabel.textColor = textColor
      commentsImage.tintColor = textColor
      viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
      viewsLabel.textColor = textColor
      viewsImage.tintColor = textColor
      comleteButton.tintColor = item.isComplete ? item.topic.tagColor : .systemGray4
      watchButton.tintColor = item.isFavorite ? .label : .systemGray4
      
      if item.isOwn || item.isComplete {
        buttonsStack.removeArrangedSubview(watchButton)
        watchButton.removeFromSuperview()
        buttonsStack.removeArrangedSubview(claimButton)
        claimButton.removeFromSuperview()
        if item.isComplete && item.isOwn {
          buttonsStack.insertArrangedSubview(comleteButton, at: 0)
        } else if item.isComplete {
            buttonsStack.insertArrangedSubview(watchButton, at: 0)
            buttonsStack.insertArrangedSubview(comleteButton, at: 1)
        } else {
          buttonsStack.removeArrangedSubview(comleteButton)
          comleteButton.removeFromSuperview()
          buttonsStack.removeArrangedSubview(watchButton)
          watchButton.removeFromSuperview()
        }
      } else if buttonsStack.arrangedSubviews.filter({ $0 === claimButton }).isEmpty {
        buttonsStack.addArrangedSubview(claimButton)
        if item.isComplete && item.isOwn {
          buttonsStack.insertArrangedSubview(comleteButton, at: 0)
        } else if item.isComplete {
            buttonsStack.insertArrangedSubview(watchButton, at: 0)
            buttonsStack.insertArrangedSubview(comleteButton, at: 1)
        } else {
          buttonsStack.removeArrangedSubview(comleteButton)
          comleteButton.removeFromSuperview()
          buttonsStack.removeArrangedSubview(watchButton)
          watchButton.removeFromSuperview()
        }
      }
    }
    
    updateHeader()
    updateMiddle()
    updateBottom()
  }
  
  @objc
  func handleTap(sender: UIButton) {
    guard !item.isNil else { return }
    
    if sender === watchButton {
      watchButton.imageView?.tintColor = .clear
      watchButton.setSpinning(on: true, animated: true)
      watchSubject.send(item)
    } else if sender === claimButton {
      claimSubject.send(item)
    }
  }
  
  func userprofileContextMenuActions(for userprofile: Userprofile) -> UIMenu {
    var actions: [UIAction]!
    
    let subscribe: UIAction = .init(title: "subscribe".localized.capitalized,
                                    image: UIImage(systemName: "hand.point.left.fill",
                                                   withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                    identifier: nil,
                                    discoverabilityTitle: nil,
                                    attributes: .init(),
                                    state: .off,
                                    handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.subscribePublisher.send(userprofile)
    })
    
    let unsubscribe: UIAction = .init(title: "unsubscribe".localized,
                                      image: UIImage(systemName: "hand.raised.slash.fill",
                                                     withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .destructive,
                                      state: .off,
                                      handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.unsubscribePublisher.send(userprofile)
    })
    
    let profile: UIAction = .init(title: "profile".localized,
                                  image: UIImage(systemName: "person.fill",
                                                 withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .init(),
                                  state: .off,
                                  handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.profileTapPublisher.send(userprofile)
    })
    
    actions = [profile]
    if userprofile.subscribedAt {
      actions.append(unsubscribe)
    } else {
      actions.append(subscribe)
    }
    
    
    return UIMenu(title: "", image: nil, identifier: nil, options: .init(), children: actions)
  }
  
  func getGradientColors(color: UIColor) -> [CGColor] {
    return [
      color.cgColor,
      color.cgColor,
      color.lighter(0.05).cgColor,
    ]
  }
  
  func setFinished() {
    guard !item.isActive,
          let stack = topView.getSubview(type: UIStackView.self, identifier: "nestedStack")
    else { return }
    
    let imageView = UIImageView(image: UIImage(systemName: "flag.checkered.2.crossed"))
    imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/1).isActive = true
    imageView.contentMode = .center
    imageView.alpha = 0
    
//    UIView.animate(withDuration: 0.2) { [weak self] in
//      guard let self = self else { return }
//
//      self.progressView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
//      self.progressView.alpha = 0
//    } completion: { _ in
//      stack.removeArrangedSubview(self.progressView)
//      stack.spacing = self.padding
//      stack.addArrangedSubview(imageView)
//      self.progressView.removeFromSuperview()
//      UIView.animate(withDuration: 0.15) {
//        imageView.alpha = 1
//      }
//    }
  }
}

// MARK: - UIContextMenuInteractionDelegate
extension SurveyCell: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    
    if let sender = interaction.view as? Avatar,
       let userprofile = sender.userprofile,
       userprofile != Userprofile.anonymous,
       userprofile != Userprofiles.shared.current {
      
      return UIContextMenuConfiguration(
        identifier: nil,
        previewProvider: { AvatarPreviewController.init(userprofile: userprofile) },
        actionProvider: { [unowned self] _ in self.userprofileContextMenuActions(for: userprofile) })
    }
    return nil
  }
  
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
    
    //        animator?.addCompletion {
    //            print("addCompletion")
    //        }
    
    guard let window = UIApplication.shared.delegate?.window,
          let instance = window!.viewByClassName(className: "_UIPlatterSoftShadowView")
    else { return }
    
    instance.isHidden = true
  }
  
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, highlightPreviewForItemWithIdentifier identifier: NSCopying) -> UITargetedPreview? {
    
    if let sender = interaction.view as? Avatar {
      let parameters = UIPreviewParameters()
      parameters.backgroundColor = .clear
      parameters.visiblePath = UIBezierPath(ovalIn: sender.bounds)
      
      return UITargetedPreview(view: sender, parameters: parameters)
    }
    
    return nil
  }
  
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    if animator.previewViewController is AvatarPreviewController {
      profileTapPublisher.send(item.owner)
    }
  }
}

