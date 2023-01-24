//
//  SubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveyCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public weak var item: SurveyReference! {
    didSet {
      guard !item.isNil else { return }
      
      updateUI()
      updateProgress(animated: false)
      
      setSubscriptions()
      
      item.isCompletePublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          self.comleteButton.tintColor = self.item.isComplete ? self.item.topic.tagColor : .systemGray4
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
    let instance = Avatar(isShadowed: true)
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
  let padding: CGFloat = 8
  //Header
  private lazy var headerView: UIStackView = {
    func createStack() -> UIStackView {
      //Topic & progress
      let nestedStack = UIStackView(arrangedSubviews: [
        topicView,
        progressView
      ])
      nestedStack.axis = .horizontal
      nestedStack.accessibilityIdentifier = "nestedStack"
      nestedStack.spacing = 4
      
      let stack = UIStackView(arrangedSubviews: [
        nestedStack,
        dateLabel
      ])
      stack.axis = .vertical
      stack.spacing = 4
      
      return stack
    }
    
    let spacer = UIView()
    spacer.backgroundColor = .clear
    
    let instance = UIStackView(arrangedSubviews: [
      createStack(),
      spacer,
      avatar
    ])
    instance.axis = .horizontal
    
    return instance
  }()
  //    private lazy var headerView: UIView = {
  //        func createStack() -> UIStackView {
  //            //Topic & progress
  //            let nestedStack = UIStackView(arrangedSubviews: [
  //                topicView,
  //                progressView
  //            ])
  //            //            nestedStack.alignment = .leading
  //            nestedStack.axis = .horizontal
  //            nestedStack.spacing = 4
  //
  //            let stack = UIStackView(arrangedSubviews: [
  //                nestedStack,
  //                dateLabel
  //            ])
  //            stack.axis = .vertical
  ////            stack.distribution = .fillEqually
  //            stack.spacing = 4
  //
  //            return stack
  //        }
  //
  //        let instance = UIView()
  //        instance.backgroundColor = .clear
  //
  //        let stack = createStack()
  //        instance.addSubview(stack)
  //        instance.addSubview(avatar)
  //        stack.translatesAutoresizingMaskIntoConstraints = false
  //        avatar.translatesAutoresizingMaskIntoConstraints = false
  //        NSLayoutConstraint.activate([
  //            avatar.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
  //            avatar.topAnchor.constraint(equalTo: instance.topAnchor),
  //            avatar.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
  //            stack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
  //            stack.topAnchor.constraint(equalTo: instance.topAnchor),
  //            stack.bottomAnchor.constraint(equalTo: instance.bottomAnchor)
  //        ])
  //
  //        return instance
  //    }()
  private lazy var topicGradient: CAGradientLayer = {
    let instance = CAGradientLayer()
    instance.type = .radial
    instance.colors = getGradientColors(color: .systemGray)
    instance.locations = [0, 0.5, 1.15]
    instance.setIdentifier("radialGradient")
    instance.startPoint = CGPoint(x: 0.5, y: 0.5)
    instance.endPoint = CGPoint(x: 1, y: 1)
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.height/2.25}
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var topicIcon: Icon = {
    let instance = Icon(category: Icon.Category.Logo)
    instance.iconColor = .white//Colors.Logo.Flame.rawValue
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.65
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var topicTitle: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Bold, forTextStyle: .subheadline)
#if DEBUG
    instance.text = "TEST TOPIC"
#endif
    instance.textColor = .white
    instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    return instance
  }()
  private lazy var topicView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.backgroundColor = .clear
    instance.axis = .horizontal
    instance.spacing = 2
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100, font: topicTitle.font)).isActive = true
    instance.layer.insertSublayer(topicGradient, at: 0)//(gradient)
    instance.publisher(for: \.bounds)
    //            .filter { $0 != .zero }
      .sink {
        instance.cornerRadius = $0.height/2.25
        
        guard let layer = instance.layer.getSublayer(identifier: "radialGradient") else { return }
        
        layer.frame = $0
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var progressView: UIView = {
    //        let font = UIFont(name: Fonts.Bold, size: 20)
    let font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .subheadline)
    let instance = UIView()
    instance.alpha = 0
    instance.backgroundColor = .systemGray4
    instance.accessibilityIdentifier = "progressView"
    instance.widthAnchor.constraint(equalToConstant: "000000".width(withConstrainedHeight: 100, font: font!)).isActive = true
    //        instance.layer.insertSublayer(topicGradient, at: 0)//(gradient)
    //        instance.publisher(for: \.bounds)
    //            .filter { $0 != .zero && $0 != instance.bounds }
    //            .sink {
    //                instance.cornerRadius = $0.height/2.25
    //
    //                guard let layer = instance.layer.getSublayer(identifier: "radialGradient") else { return }
    //
    //                layer.frame = $0
    //            }
    //            .store(in: &subscriptions)
    
    instance.publisher(for: \.bounds, options: .new)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    
    let progressBar = UIView()
    instance.addSubview(progressBar)
    progressBar.accessibilityIdentifier = "progress"
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      progressBar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
      progressBar.topAnchor.constraint(equalTo: instance.topAnchor),
      progressBar.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
    ])
    
    let constraint = progressBar.widthAnchor.constraint(equalToConstant: 30)
    constraint.identifier = "width"
    constraint.isActive = true
    
    let label = UILabel()
    label.accessibilityIdentifier = "progressLabel"
    label.font = font
    label.textAlignment = .center
    label.textColor = .white
    label.place(inside: instance)
#if DEBUG
    label.text = "100%"
#endif
    
    return instance
  }()
  private lazy var dateLabel: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.textAlignment = .left
    instance.insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: instance.font)).isActive = true
#if DEBUG
    instance.text = "01.02.2013"
#endif
    
    return instance
  }()
  //Content
  private lazy var middleView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      titleLabel,
      descriptionLabel,
      imageContainer
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  private lazy var titleLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .left
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title1)
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
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
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
    instance.translatesAutoresizingMaskIntoConstraints = false
    instance.contentMode = .scaleAspectFill
    
    return instance
  }()
  private lazy var imageContainer: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    instance.clipsToBounds = true
    //        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    imageView.place(inside: instance)
    
    return instance
  }()
  //Stats
  private lazy var bottomView: UIStackView = {
    let spacer = UIView()
    spacer.backgroundColor = .clear
    let instance = UIStackView(arrangedSubviews: [
      statsStack,
      spacer,
      buttonsStack
    ])
    instance.axis = .horizontal
    instance.spacing = 8
    
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
    instance.tintColor = Colors.Logo.Marigold.rawValue//.systemGray//
    instance.contentMode = .center
    return instance
  }()
  private lazy var ratingLabel: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
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
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
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
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    return instance
  }()
  private lazy var buttonsStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      comleteButton,
      watchButton,
      claimButton,
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
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
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
    
    ratingLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    viewsLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    commentsLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    viewsImage.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    commentsImage.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
    
    comleteButton.tintColor = item.isComplete ? item.topic.tagColor : .systemGray4
    watchButton.tintColor = item.isFavorite ? traitCollection.userInterfaceStyle == .dark ? .label : .systemGray : .systemGray4
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
    progressView.alpha = 0
    
    guard let constraint = imageContainer.getConstraint(identifier: "imageContainer") else { return }
    
    imageContainer.removeConstraint(constraint)
  }
  
  //    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
  //        //Exhibit A - We need to cache our calculation to prevent a crash.
  //            if !isHeightCalculated {
  //                setNeedsLayout()
  //                layoutIfNeeded()
  //                let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
  //                var newFrame = layoutAttributes.frame
  //                newFrame.size.width = CGFloat(ceilf(Float(size.width)))
  //                newFrame.size.height = CGFloat(ceilf(Float(size.height)))
  //                layoutAttributes.frame = newFrame
  //                isHeightCalculated = true
  //            }
  //            return layoutAttributes
  //    }
  //    override func updateConfiguration(using state: UICellConfigurationState) {
  //        super.updateConfiguration(using: state)
  //
  //        var config = UIBackgroundConfiguration.listPlainCell()
  //        config.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
  //        backgroundConfiguration = config
  //    }
  //    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
  //        print(layoutAttributes)
  //    }
}



// MARK: - Private
private extension SurveyCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    //        testView.place(inside: contentView)
    
    //        let items = [
    //            headerView,
    //            middleView,
    //            bottomView
    //        ]
    //        items.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    //        contentView.addSubviews(items)
    //        contentView.translatesAutoresizingMaskIntoConstraints = false
    ////        contentView.autoresizingMask = .flexibleHeight
    //
    //        NSLayoutConstraint.activate([
    //            contentView.topAnchor.constraint(equalTo: topAnchor),
    //            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
    //            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    //            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
    //            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
    //            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
    //            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
    ////            middleView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding*2),
    ////            middleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
    ////            middleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
    //            bottomView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding*2),
    //            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
    //            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
    ////            bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    //        ])
    //
    //        let constraint = bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    //        constraint.priority = .defaultLow
    //        constraint.isActive = true
    
    let stackView = UIStackView(arrangedSubviews: [
      headerView,
      middleView,
      bottomView
    ])
    stackView.axis = .vertical
    stackView.spacing = padding
    
    stackView.place(inside: contentView, insets: .uniform(size: 8), bottomPriority: .defaultLow)
  }
  
  func setTasks() {
    tasks.append(Task { [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Rating) {
        await MainActor.run {
          guard let self = self,
                let item = self.item,
                let object = notification.object as? SurveyReference,
                item === object
          else { return }
          
          //                        self.ratingLabel.text = String(describing: String(describing: item.rating))
        }
      }
    })
    
    tasks.append(Task { [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Completed) {
        await MainActor.run {
          
          guard let self = self,
                let item = self.item,
                let object = notification.object as? SurveyReference,
                item === object
          else { return }
          
          //                        self.menuButton.menu = self.prepareMenu()
          //                        switch item.isComplete {
          //                        case true:
          //                            self.titleLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
          //                            self.descriptionLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray
          //                            self.topicHorizontalStackView.insertArrangedSubview(self.progressView, at: 1)
          //
          //                            var stackView: UIStackView!
          //                            if let _stackView = self.topicHorizontalStackView.getSubview(type: UIStackView.self, identifier: "marksStackView") {
          //                                stackView = _stackView
          //                            } else {
          //                                stackView = UIStackView()
          //                                stackView.spacing = 2
          //                                stackView.backgroundColor = .clear
          //                                stackView.accessibilityIdentifier = "marksStackView"
          //                                stackView.publisher(for: \.bounds, options: .new)
          //                                    .sink { rect in
          //
          //                                        stackView.cornerRadius = rect.height/2.25
          //                                }
          //                                    .store(in: &self.subscriptions)
          //
          //                                self.topicHorizontalStackView.addArrangedSubview(stackView)
          //                            }
          //                            guard stackView.arrangedSubviews.filter({ $0.accessibilityIdentifier == "isComplete"}).isEmpty else { return }
          //                            let container = UIView()
          //                            container.backgroundColor = .clear
          //                            container.accessibilityIdentifier = "isComplete"
          //                            container.widthAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/1).isActive = true
          //
          //
          //
          //                            let instance = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
          //                            instance.contentMode = .center
          //                            instance.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .white : self.item.topic.tagColor
          //                            instance.contentMode = .scaleAspectFit
          //                            instance.addEquallyTo(to: container)
          //                            stackView.insertArrangedSubview(container, at: 0)
          //
          //                            instance.publisher(for: \.bounds, options: .new)
          //                                .sink { rect in
          //
          //                                    instance.cornerRadius = rect.height/2
          //                                    let largeConfig = UIImage.SymbolConfiguration(pointSize: rect.height * 1.9, weight: .semibold, scale: .medium)
          //                                    let image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: largeConfig)
          //                                    instance.image = image
          //                                }
          //                                .store(in: &self.subscriptions)
          //
          //                        case false:
          //                            guard let stackView = self.topicHorizontalStackView.get(all: UIStackView.self).filter({ $0.accessibilityIdentifier == "marksStackView" }).first,
          //                                  let mark = stackView.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "isComplete" }).first else { return }
          //                            stackView.removeArrangedSubview(mark)
          //                            mark.removeFromSuperview()
          //                        }
        }
      }
    })
    
    tasks.append(Task { [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.Progress) {
        await MainActor.run {
          guard let self = self,
                let item = self.item,
                let object = notification.object as? SurveyReference,
                item === object//,
                  //                              let progressIndicator = self.progressView.getSubview(type: UIView.self, identifier: "progress"),
                  //                              let progressLabel = self.progressView.getSubview(type: UIView.self, identifier: "progressLabel") as? UILabel,
                  //                              let constraint = progressIndicator.getConstraint(identifier: "width")
          else { return }
          
          //                        progressLabel.text = String(describing: item.progress) + "%"
          //                        let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
          //                            self.progressView.setNeedsLayout()
          //                            constraint.constant = constraint.constant * CGFloat(item.progress)/100
          //                            self.progressView.layoutIfNeeded()
          //                        }
        }
      }
    })
    
    tasks.append(Task { [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.CommentsTotal) {
        await MainActor.run {
          guard let self = self,
                let item = self.item,
                let object = notification.object as? SurveyReference,
                item === object
          else { return }
          
          //                    self.commentsView.alpha = 1
          //                    self.commentsLabel.alpha = 1
          //                    self.commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
        }
      }
    })
  }
  
  func setSubscriptions() {
    guard let item = item else { return }
    
    let duration = 0.15
    
    item.isFavoritePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] flag in
        guard let self = self else { return }
        
        UIView.animate(withDuration: duration) {
          self.watchButton.tintColor = flag ? self.traitCollection.userInterfaceStyle == .dark ? .label : .systemGray : .systemGray4
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
    guard let progressIndicator = progressView.getSubview(type: UIView.self, identifier: "progress"),
          let progressLabel = progressView.getSubview(type: UIView.self, identifier: "progressLabel") as? UILabel,
          let constraint = progressIndicator.getConstraint(identifier: "width")
    else { return }
    
    progressView.setNeedsLayout()
    progressView.layoutIfNeeded()
    
    progressIndicator.backgroundColor = item.topic.tagColor
    //        progressView.setNeedsLayout()
    let progress = progressView.bounds.width * CGFloat(item.progress)*0.01
    
    guard animated else {
      progressLabel.text = String(describing: item.progress) + "%"
      constraint.constant = progress
      progressView.layoutIfNeeded()
      return
    }
    
    UIView.transition(with: progressLabel,
                      duration: 0.15,
                      options: .transitionCrossDissolve) { [weak self] in
      guard let self = self else { return }
      
      constraint.constant = progress
      self.progressView.layoutIfNeeded()
    } completion: { _ in }
  }
  
  @MainActor
  func updateUI() {
    func updateHeader() {
      if item.isComplete {
        //                titleLabel.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title2)
        progressView.alpha = 1
      }
      topicGradient.colors = getGradientColors(color: item.topic.tagColor)
      topicIcon.category = item.topic.iconCategory
      topicTitle.text = item.topic.title.uppercased()
      //            updateProgress(animated: false)
      dateLabel.text = item.startDate.timeAgoDisplay()
      
      if item.isAnonymous {
        avatar.userprofile = Userprofile.anonymous
      } else if item.owner.isCurrent {
        avatar.addInteraction(UIContextMenuInteraction(delegate: self))
        avatar.userprofile = Userprofiles.shared.current
      } else {
        avatar.addInteraction(UIContextMenuInteraction(delegate: self))
        avatar.userprofile = item.owner
      }
    }
    
    func updateMiddle() {
      guard let constraint = titleLabel.getConstraint(identifier: "height"),
            let constraint2 = descriptionLabel.getConstraint(identifier: "height")
      else { return }
      
      titleLabel.text = item.title
      descriptionLabel.text = item.truncatedDescription
      
      constraint.constant = item.title.height(withConstrainedWidth: bounds.width, font: titleLabel.font)
      constraint2.constant = item.truncatedDescription.height(withConstrainedWidth: bounds.width, font: descriptionLabel.font)
      
      //Media
      guard let media = item.media else {
        let zeroHeight = imageContainer.heightAnchor.constraint(equalToConstant: 0)
        zeroHeight.identifier = "imageContainer"
        zeroHeight.isActive = true
        
        return
      }
      
      let aspectRatio = imageContainer.heightAnchor.constraint(equalTo: imageContainer.widthAnchor, multiplier: 9/16)
      aspectRatio.identifier = "imageContainer"
      aspectRatio.isActive = true
      
      guard let image = media.image else {
        let shimmer = Shimmer()
        shimmer.backgroundColor = .clear
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.clipsToBounds = true
        shimmer.place(inside: imageContainer)
        shimmer.publisher(for: \.bounds)
          .filter { $0 != .zero }
          .sink { shimmer.cornerRadius = $0.width*0.025 }
          .store(in: &subscriptions)
        
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
      ratingLabel.text = String(describing: String(describing: item.rating))
      commentsLabel.text = String(describing: item.commentsTotal.roundedWithAbbreviations)
      viewsLabel.text = String(describing: item.views.roundedWithAbbreviations)
      
      comleteButton.tintColor = item.isComplete ? item.topic.tagColor : .systemGray4
      watchButton.tintColor = item.isFavorite ? traitCollection.userInterfaceStyle == .dark ? .label : .systemGray : .systemGray4
    }
    
    //#if DEBUG
    //        print(frame.size)
    //#endif
    
    //#if DEBUG
    //        print(frame.size)
    //#endif
    //        setNeedsLayout()
    updateHeader()
    updateMiddle()
    updateBottom()
    
    //#if DEBUG
    //        print(frame.size)
    //#endif
    //        contentView.setNeedsLayout()
    //        contentView.layoutIfNeeded()
  }
  
  @objc
  func handleTap(sender: UIButton) {
    guard !item.isNil else { return }
    
    if sender === watchButton {
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
          let stack = headerView.getSubview(type: UIStackView.self, identifier: "nestedStack")
    else { return }
    
    let imageView = UIImageView(image: UIImage(systemName: "flag.checkered.2.crossed"))
    imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/1).isActive = true
    imageView.contentMode = .center
    imageView.alpha = 0
    
    UIView.animate(withDuration: 0.2) { [weak self] in
      guard let self = self else { return }
      
      self.progressView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
      self.progressView.alpha = 0
    } completion: { _ in
      stack.removeArrangedSubview(self.progressView)
      stack.spacing = self.padding
      stack.addArrangedSubview(imageView)
      self.progressView.removeFromSuperview()
      UIView.animate(withDuration: 0.15) {
        imageView.alpha = 1
      }
    }
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

