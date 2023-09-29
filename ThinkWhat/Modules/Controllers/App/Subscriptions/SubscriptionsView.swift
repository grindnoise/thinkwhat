//
//  SubsciptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class SubscriptionsView: UIView {
  
  private enum Mode {
    case User, Default
  }
  
  // MARK: - Public properties
  @IBOutlet var contentView: UIView!
  weak var viewInput: (SubscriptionsViewInput & TintColorable)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  public private(set) var isCardOnScreen = false
  public var isOnScreen: Bool = true {
    didSet {
      guard oldValue != isOnScreen else { return }
      
      surveysCollectionView.isOnScreen = isOnScreen

      // Animate empty view
      guard !collectionEmptyPublicationsView.alpha.isZero else { return }
      
      collectionEmptyPublicationsView.setAnimationsEnabled(isOnScreen)
    }
  }
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var mode: Mode = .Default
  private let filter = SurveyFilter(main: .subscriptions, additional: .disabled, period: .unlimited)
  private var indexPath: IndexPath = IndexPath(row: 0, section: 0)
  private var isEmpty = false {
    didSet {
      guard isEmpty != oldValue else { return }
      
      onEmptyList(isEmpty: isEmpty)
    }
  }
  private var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
      viewInput?.toggleUserSelected(true)
      viewInput?.setUserprofileFilter(userprofile)
      // Set userprofile filter
      filter.setMain(filter: .user, userprofile: userprofile)
      //        surveysCollectionView.userprofile = userprofile
      onUserSelected(userprofile: userprofile)
      usernameLabel.text = userprofile.username
      mode = .User
    }
  }
  private var isScrolledDown = false { // Use to show/hide arrow button
    didSet {
      guard oldValue != isScrolledDown,
            !scrollToTopButtonAnimates
      else { return }
      
      toggleScrollButton(on: isScrolledDown) { [unowned self] in self.scrollToTopButtonAnimates = false }
    }
  }
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var filtersCollectionView: SurveyFiltersCollectionView = {
    let instance = SurveyFiltersCollectionView(items: [
      SurveyFilterItem(main: .subscriptions, additional: .disabled, isFilterEnabled: true, text: "all"),
      SurveyFilterItem(main: .subscriptions,
                       additional:  .period,
                       text: Enums.Period.unlimited.description,
                       image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                       periodThreshold: .unlimited),
      SurveyFilterItem(main: .subscriptions, additional: .discussed, text: "filter_discussed"),
      SurveyFilterItem(main: .subscriptions, additional: .watchlist, text: "filter_watchlist"),
      SurveyFilterItem(main: .subscriptions, additional: .completed, text: "filter_completed"),
      SurveyFilterItem(main: .subscriptions, additional: .notCompleted, text: "filter_not_completed")
    ],
                                               contentInsets: .uniform(padding))

    // Filtering
    instance.filterPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        self.filter.setAdditional(filter: $0.additional, period: $0.period)
        self.isScrolledDown = false
        delay(seconds: 0.4) { [weak self] in
          guard let self = self else { return }
          
          self.scrollToTop()
        }
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var emptyPublicationsView: EmptyPublicationsView?
  private lazy var collectionEmptyPublicationsView: EmptyPublicationsView = {
    let instance = EmptyPublicationsView(showsButton: false,
                                         buttonText: "create_post",
                                         buttonColor: viewInput?.tintColor ?? Colors.main,
                                         backgroundLightColor: .systemBackground,
                                         backgroundDarkColor: Colors.darkTheme,
                                         spiralLightColor: Colors.spiralLight,
                                         spiralDarkColor: Colors.spiralDark)
    instance.alpha = 0
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var surveysCollectionView: SurveysCollectionView = {
    let instance = SurveysCollectionView(filter: filter, color: viewInput?.tintColor)
    
    // Pagination
    instance.paginationPublisher
      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
      .eraseToAnyPublisher()
      .sink { [unowned self] in self.viewInput?.getDataItems(filter: self.filter, excludeList: $0) }
      .store(in: &subscriptions)
    
    // Refresh
    instance.refreshPublisher
      .sink { [unowned self] in self.viewInput?.getDataItems(filter: self.filter, excludeList: []) }
      .store(in: &subscriptions)

    // Publication selected
    instance.selectionPublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.onSurveyTapped($0!) }
      .store(in: &subscriptions)
    
    // Update stats (exclude refs)
    instance.updateStatsPublisher
      .filter { !$0.isNil && $0!.isEmpty }
      .sink { [unowned self] in self.viewInput?.updateSurveyStats($0!) }
      .store(in: &subscriptions)
    
    // Add to watch list
    instance.watchSubject
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.addFavorite($0!) }
      .store(in: &self.subscriptions)
    
    // Share
    instance.shareSubject
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.share($0!) }
      .store(in: &self.subscriptions)
    
    // Complain
    instance.claimSubject
      .filter { !$0.isNil }
      .sink { [weak self] in
      guard let self = self,
            let surveyReference = $0
      else { return }
      
        let popup = NewPopup(padding: self.padding, contentPadding: .uniform(size: self.padding*2))
        let content = ClaimPopupContent(parent: popup, object: surveyReference)
        content.$claim
          .filter { !$0.isNil && !$0!.isEmpty && $0!.keys.first is SurveyReference }
          .map { [$0!.keys.first as! SurveyReference: $0!.values.first!] }
          .sink { [unowned self] in self.viewInput?.claim($0!) }
          .store(in: &popup.subscriptions)
        popup.setContent(content)
        popup.didDisappearPublisher
          .sink { _ in popup.removeFromSuperview() }
          .store(in: &self.subscriptions)
      }
      .store(in: &self.subscriptions)
    
    // Open userprofile
    instance.userprofilePublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.openUserprofile($0!) }
      .store(in: &self.subscriptions)
    
    // Subscribe to user
    instance.unsubscribePublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.unsubscribe(from: $0!) }
      .store(in: &self.subscriptions)

    instance.scrolledDownPublisher
      .filter { $0 }
      .sink { [weak self] _ in
        guard let self = self, !self.isScrolledDown else { return }
        
        self.isScrolledDown = true
      }
      .store(in: &subscriptions)
    
    instance.scrolledToTopPublisher
      .sink { [weak self] _ in
        guard let self = self, self.isScrolledDown else { return }
        
        self.isScrolledDown = false
      }
      .store(in: &subscriptions)

    instance.emptyPublicationsPublisher
      .filter { !$0.isNil }
      .sink { [weak self] in
        guard let self = self else { return }

        self.isEmpty = $0!
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var feedCollectionView: UserprofilesFeedCollectionView = {
    let instance = UserprofilesFeedCollectionView(userprofile: Userprofiles.shared.current!, mode: .Subscriptions)
    instance.alwaysBounceHorizontal = true
    //        instance.clipsToBounds = false
    instance.isDirectionalLockEnabled = true
    instance.userPublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0.keys.first,
              let indexPath = $0.values.first
        else { return }
        
        
        self.indexPath = indexPath
        self.userprofile = userprofile
        self.filter.userprofile = userprofile
      }
      .store(in: &subscriptions)
    
    instance.footerPublisher
      .sink { [weak self] in
        guard let self = self,
              let mode = $0
        else { return }
        
        self.viewInput?.onAllUsersTapped(mode: mode)
      }
      .store(in: &subscriptions)
    
    ///If zero subscriptions -> show info label
    instance.zeroSubscriptions
//      .filter { $0 == true }
      .sink { [weak self] in
        guard let self = self,
              let zero = $0
        else { return }
        
        if zero {
          self.emptyPublicationsView = EmptyPublicationsView(mode: .subscriptions,
                                                             backgroundLightColor: .systemBackground,
                                                             backgroundDarkColor: .systemBackground,
                                                             spiralLightColor: Colors.spiralLight,
                                                             spiralDarkColor: Colors.spiralDark)
          self.addSubview(self.emptyPublicationsView!)
          self.emptyPublicationsView?.translatesAutoresizingMaskIntoConstraints = false
          self.emptyPublicationsView?.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
          self.emptyPublicationsView?.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
          self.emptyPublicationsView?.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
          self.emptyPublicationsView?.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
          self.emptyPublicationsView?.setAnimationsEnabled(true)
        }
        
        
        UIView.animate(
          withDuration: 0.4,
          delay: 0,
          usingSpringWithDamping: 0.8,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut],
          animations: { [weak self] in
            guard let self = self else { return }
            
          self.emptyPublicationsView?.alpha =  zero ? 1 : 0
          self.emptyPublicationsView?.transform = zero ? .identity : .init(scaleX: 0.75, y: 0.75)
          self.shadowView.alpha = zero ? 0 : 1
          self.filtersCollectionView.alpha = zero ? 0 : 1
        }) { _ in
//          delay(seconds: 3) { [weak self] in
//            guard let self = self else { return }
//
//            self.emptyPublicationsView?.setAnimationsEnabled(false)
//            self.emptyPublicationsView?.removeFromSuperview()
//            self.emptyPublicationsView = nil
//          }
          if !zero {
            self.emptyPublicationsView?.setAnimationsEnabled(false)
            self.emptyPublicationsView?.removeFromSuperview()
            self.emptyPublicationsView = nil
          }
        }
      }
      .store(in: &subscriptions)
    //        instance.contentSize.height = 1.0
    //        instance.publisher(for: \.contentSize, options: .new)
    //            .sink { [weak self] rect in
    //                guard let self = self else { return }
    //
    //                print(rect.height)
    //            }
    //            .store(in: &subscriptions)
    //        //Pagination #1
    //        let paginationPublisher = instance.paginationPublisher
    //            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
    //
    //        paginationPublisher
    //            .sink { [unowned self] in
    //                guard let category = $0 else { return }
    //
    //                self.viewInput?.onDataSourceRequest(source: category, topic: nil)
    //            }
    //            .store(in: &subscriptions)
    //
    //        instance.shareSubject.sink {
    //            print($0)
    //        } receiveValue: { [weak self] in
    //            guard let self = self,
    //                let value = $0
    //            else { return }
    //
    //            self.viewInput?.share(value)
    //        }.store(in: &self.subscriptions)
    
    return instance
  }()
  //User view on selection
  private lazy var avatar: Avatar = {
    let instance = Avatar()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.alpha = 0
    instance.tapPublisher
      .sink { [unowned self] in self.viewInput?.openUserprofile($0) }
      .store(in: &subscriptions)
//    instance.isShadowed = traitCollection.userInterfaceStyle != .dark
    
    return instance
  }()
  private lazy var usernameLabel: UILabel = {
    let instance = UILabel()
    //        instance.insets.top = -4
    instance.textAlignment = .left
    instance.numberOfLines = 1
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .title2)
    instance.adjustsFontSizeToFitWidth = true
    
    return instance
  }()
  private lazy var profileButton: UIView = {
    let shadowView = UIView.opaque()
    shadowView.layer.masksToBounds = false
    shadowView.accessibilityIdentifier = "profileButton"
    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    shadowView.layer.shadowOffset = .zero
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.publisher(for: \.bounds)
      .sink {
        shadowView.layer.shadowRadius = $0.height/8
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
      }
      .store(in: &subscriptions)
    let button = UIButton()
    button.setAttributedTitle(NSAttributedString(string: "open_userprofile".localized.uppercased(),
                                                 attributes: [
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                  .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : Colors.main as Any
                                                 ]),
                              for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: padding/1.5, left: padding, bottom: padding/1.5, right: padding)
    button.accessibilityIdentifier = "profileButton"
    button.imageEdgeInsets.left = padding/2
    button.semanticContentAttribute = .forceRightToLeft
    button.adjustsImageWhenHighlighted = false
    button.setImage(UIImage(systemName: ("arrow.right"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
    button.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
    button.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
    button.publisher(for: \.bounds)
      .sink { button.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    button.place(inside: shadowView)
    
    return shadowView
  }()
  private lazy var subscriptionButton: UIView = {
    let shadowView = UIView.opaque()
    shadowView.layer.masksToBounds = false
    shadowView.accessibilityIdentifier = "subscriptionButton"
    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    shadowView.layer.shadowOffset = .zero
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.publisher(for: \.bounds)
      .sink {
        shadowView.layer.shadowRadius = $0.height/8
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
      }
      .store(in: &subscriptions)
    let button = UIButton()
    button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                 attributes: [
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                  .foregroundColor: UIColor.systemRed as Any
                                                 ]),
                              for: .normal)
    button.accessibilityIdentifier = "subscriptionButton"
    button.contentEdgeInsets = UIEdgeInsets(top: padding/1.5, left: padding, bottom: padding/1.5, right: padding)
    button.imageEdgeInsets.left = padding/2
    button.adjustsImageWhenHighlighted = false
    button.semanticContentAttribute = .forceRightToLeft
    button.setImage(UIImage(systemName: ("xmark"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
    button.tintColor = .systemRed
    button.addTarget(self, action: #selector(self.handleTap(_:)), for: .touchUpInside)
    button.publisher(for: \.bounds)
      .sink { button.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    button.place(inside: shadowView)
    
    return shadowView
  }()
  private lazy var userStack: UIStackView = {
    let nested = UIStackView(arrangedSubviews: [
      usernameLabel,
      UIView.opaque(),
      profileButton,
      subscriptionButton,
    ])
    nested.alignment = .leading
    nested.axis = .vertical
    nested.spacing = padding
    nested.accessibilityIdentifier = "nested"
    
    let opaque = UIView.opaque()
    opaque.addSubview(avatar)
    
    let instance = UIStackView(arrangedSubviews: [
      opaque,
      nested,
    ])
    instance.axis = .horizontal
    instance.spacing = padding*2
    instance.alignment = .center
    
    opaque.translatesAutoresizingMaskIntoConstraints = false
    opaque.widthAnchor.constraint(equalTo: opaque.heightAnchor).isActive = true
    opaque.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.centerXAnchor.constraint(equalTo: opaque.centerXAnchor).isActive = true
    avatar.centerYAnchor.constraint(equalTo: opaque.centerYAnchor).isActive = true
    avatar.leadingAnchor.constraint(equalTo: opaque.leadingAnchor).isActive = true
    avatar.trailingAnchor.constraint(equalTo: opaque.trailingAnchor).isActive = true
    
    return instance
  }()
  private lazy var userView: UIView = {
    let instance = UIView()
    instance.layer.masksToBounds = false
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
    instance.alpha = 1
    instance.place(inside: topView,
                   insets: UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding))
    let background = UIView()
    background.accessibilityIdentifier = "background"
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    background.place(inside: instance)
    instance.publisher(for: \.bounds)
      .sink { [weak self] in
        instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath
        background.cornerRadius = $0.width * 0.05
      }
      .store(in: &subscriptions)
    
    userStack.place(inside: background, insets: .uniform(size: padding*2))
//    let backgroundView = UIView()
//    backgroundView.accessibilityIdentifier = "background"
//    backgroundView.clipsToBounds = true
//    backgroundView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
//    backgroundView.publisher(for: \.bounds)
//      .sink { rect in
//        backgroundView.cornerRadius = rect.width * 0.05
//      }
//      .store(in: &subscriptions)
//
//    backgroundView.place(inside: instance)
//    backgroundView.addSubview(avatar)
//    avatar.translatesAutoresizingMaskIntoConstraints = false
//
//    let opaque = UIView()
//    opaque.accessibilityIdentifier = "opaque"
//    opaque.clipsToBounds = true
//    backgroundView.addSubview(opaque)
//    opaque.backgroundColor = .clear
//    userStack.translatesAutoresizingMaskIntoConstraints = false
//    opaque.translatesAutoresizingMaskIntoConstraints = false
//    opaque.addSubview(userStack)
//
//    NSLayoutConstraint.activate([
//      avatar.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
//      avatar.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
//      avatar.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -8),
//      //            opaque.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
//      opaque.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 6),
//      opaque.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -6),
//      opaque.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
//      userStack.leadingAnchor.constraint(equalTo: opaque.leadingAnchor),
//      userStack.trailingAnchor.constraint(equalTo: opaque.trailingAnchor),
//      userStack.centerYAnchor.constraint(equalTo: opaque.centerYAnchor),
//    ])
//
//    let constraint = opaque.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16)
//    constraint.identifier = "trailing"
//    constraint.isActive = true
    
    return instance
  }()
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.layer.masksToBounds = false
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UISettings.Shadows.color//UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = UISettings.Shadows.radius(padding: padding)
    instance.layer.shadowOffset = UISettings.Shadows.offset
    instance.publisher(for: \.bounds)
      .sink { [unowned self] rect in
        instance.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.width*0.05).cgPath
      }
      .store(in: &subscriptions)
    
    background.place(inside: instance)
    
    return instance
  }()
  private lazy var background: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "bg"
    instance.layer.masksToBounds = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.surveyCollectionDark : Colors.surveyCollectionLight
    //        instance.addEquallyTo(to: shadowView)
    surveysCollectionView.place(inside: instance)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      feedCollectionView
    ])
    instance.axis = .vertical
    
    return instance
  }()
  private lazy var topView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.identifier = "height"
    constraint.isActive = true
    
    feedCollectionView.translatesAutoresizingMaskIntoConstraints = false
    instance.addSubview(feedCollectionView)
    
    feedCollectionView.topAnchor.constraint(equalTo: instance.topAnchor).isActive = true
    feedCollectionView.leadingAnchor.constraint(equalTo: instance.leadingAnchor).isActive = true
    feedCollectionView.trailingAnchor.constraint(equalTo: instance.trailingAnchor).isActive = true
    feedCollectionView.heightAnchor.constraint(equalToConstant: topViewHeight).isActive = true
    
    return instance
  }()
  private lazy var filterViewHeight: CGFloat = .zero
  private lazy var topViewHeight: CGFloat = 100
  private lazy var scrollToTopButton: UIButton = {
    let instance = UIButton()
    instance.backgroundColor = .clear
    instance.tintColor = .white
    instance.addTarget(self, action: #selector(self.scrollToTop), for: .touchUpInside)
    instance.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))
//    instance.size(.uniform(size: 40))
    let bgLayer = CAGradientLayer()
    bgLayer.type = .radial
    bgLayer.colors = CAGradientLayer.getGradientColors(color: Colors.main)
    bgLayer.locations = [0, 0.5, 1.15]
    bgLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
    bgLayer.endPoint = CGPoint(x: 1, y: 1)
    bgLayer.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { bgLayer.cornerRadius = $0.height/2}
      .store(in: &subscriptions)
    bgLayer.name = "background"
    bgLayer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    bgLayer.shadowColor = UISettings.Shadows.color//UIColor.lightGray.withAlphaComponent(0.5).cgColor
    bgLayer.shadowRadius = UISettings.Shadows.radius(padding: padding*1.5)
    bgLayer.shadowOffset = UISettings.Shadows.offset
    instance.setImage(UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
    instance.adjustsImageWhenHighlighted = false
    instance.imageView?.layer.masksToBounds = false
    instance.layer.insertSublayer(bgLayer, at: 0)
    instance.publisher(for: \.bounds)
      .filter { [unowned self] in $0.size != bgLayer.bounds.size }
      .sink {
        bgLayer.frame = $0
        bgLayer.shadowPath = UIBezierPath(ovalIn: $0).cgPath
      }
      .store(in: &subscriptions)
    instance.imageView?.layer.zPosition = 1
    
    return instance
  }()
  private var scrollToTopButtonX = CGFloat.zero
  private var scrollToTopButtonAnimates = false

  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setTasks()
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setTasks()
//    setupUI()
  }
  
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
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

//    avatar.isShadowed = traitCollection.userInterfaceStyle != .dark
    userView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.surveyCollectionDark : Colors.surveyCollectionLight
    profileButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    if let profileBtn = profileButton.getSubview(type: UIButton.self)  {
      profileBtn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
      profileBtn.setAttributedTitle(NSAttributedString(string: "open_userprofile".localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                        .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : Colors.main as Any
                                                       ]),
                                    for: .normal)
      profileBtn.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : Colors.main
    }
    if let bgLayer = scrollToTopButton.getLayer(identifier: "background") as? CAShapeLayer {
      bgLayer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
    subscriptionButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    subscriptionButton.getSubview(type: UIButton.self)?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
    userView.getSubview(type: UIView.self, identifier: "background")?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
  }
}

private extension SubscriptionsView {
  func setTasks() {
    guard let userprofile = Userprofiles.shared.current else { return }
    ///Subscription events
    userprofile.subscriptionsRemovePublisher
      .filter { !$0.isEmpty }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in },
            receiveValue: { [unowned self] in
        guard let unsubscribed = $0.first,
              let viewInput = self.viewInput
        else { return }
        
        if viewInput.isOnScreen {
          self.subscriptionButton.isUserInteractionEnabled = true
          self.viewInput?.setDefaultMode()
          self.subscriptionButton.setSpinning(on: false) { [weak self] in
            guard let self = self,
                  let button = subscriptionButton.getSubview(type: UIButton.self)
            else { return }
            
            button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                         attributes: [
                                                          .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                          .foregroundColor: UIColor.systemRed as Any
                                                         ]),
                                      for: .normal)
            button.imageView?.tintColor = .systemRed
          }
          delay(seconds: 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.feedCollectionView.removeItem(unsubscribed)
          }
        } else {
          self.feedCollectionView.removeItem(unsubscribed)
          self.feedCollectionView.alpha = 1
          self.userView.alpha = 0
          self.viewInput?.setDefaultMode()
          if let constraint = self.topView.getConstraint(identifier: "height") {
            self.setNeedsLayout()
            constraint.constant = self.topViewHeight
            self.layoutIfNeeded()
          }
        }
      })
      .store(in: &subscriptions)
    
//    // We need to show filterView on new subscription when view is not on screen
//    userprofile.subscriptionsPublisher
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: {
//        if case .failure(let error) = $0 {
//#if DEBUG
//          print(error)
//#endif
//        }
//      }, receiveValue: { [weak self] subscribers in
//        guard let self = self,
//              let viewInput = self.viewInput,
//              !viewInput.isOnScreen
//        else { return }
//
//        viewInput.setNavigationBarHidden(false)
////        self.toggleDateFilter(on: true)
//      })
//      .store(in: &subscriptions)
    
//    tasks.append( Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
//        guard let self = self,
//              let dict = notification.object as? [Userprofile: Userprofile],
//              let owner = dict.keys.first,
//              owner == Userprofiles.shared.current,
//              let userprofile = dict.values.first,
//              let viewInput = self.viewInput
//        else { return }
//
//        if viewInput.isOnScreen {
//          self.subscriptionButton.isUserInteractionEnabled = true
//          self.viewInput?.setDefaultMode()
//          if #available(iOS 15, *), !self.subscriptionButton.configuration.isNil {
//            self.subscriptionButton.configuration!.showsActivityIndicator = false
//          } else {
//            guard let imageView = self.subscriptionButton.imageView,
//                  let indicator = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator")
//            else { return }
//
//            indicator.removeFromSuperview()
//            imageView.tintColor = .systemRed
//          }
//          delayAsync(delay: 0.45) { self.feedCollectionView.removeItem(userprofile) }
//        } else {
//          self.feedCollectionView.removeItem(userprofile)
//          self.feedCollectionView.alpha = 1
//          self.userView.alpha = 0
//        }
//      }
//    })
    
    
    //Subscription operation API error
    Userprofiles.shared.subscriptionFailure
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.subscriptionButton.setSpinning(on: false) { [weak self] in
          guard let self = self,
                let button = subscriptionButton.getSubview(type: UIButton.self)
          else { return }
          
          button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                        .foregroundColor: UIColor.systemRed as Any
                                                       ]),
                                    for: .normal)
          button.imageView?.tintColor = .systemRed
        }
      }
      .store(in: &subscriptions)
    
//    tasks.append(Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionOperationFailure) {
//        guard let self = self,
//              let userprofile = notification.object as? Userprofile,
//              self.userprofile == userprofile
//        else { return }
//
//        self.subscriptionButton.setSpinning(on: false) { [weak self] in
//          guard let self = self,
//                let button = subscriptionButton.getSubview(type: UIButton.self)
//          else { return }
//
//          button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
//                                                       attributes: [
//                                                        .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
//                                                        .foregroundColor: UIColor.systemRed as Any
//                                                       ]),
//                                    for: .normal)
//          button.imageView?.tintColor = .systemRed
//        }
////        if #available(iOS 15, *), !self.subscriptionButton.configuration.isNil {
////          self.subscriptionButton.configuration!.showsActivityIndicator = false
////        } else {
////          guard let imageView = self.subscriptionButton.imageView,
////                let indicator = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator")
////          else { return }
////
////          indicator.removeFromSuperview()
////          imageView.tintColor = .systemRed
////        }
//      }
//    })
  }
  
  @MainActor
  func setupUI() {
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
    
    surveysCollectionView.color = viewInput!.tintColor
    
    addSubview(contentView)
    contentView.edgesToSuperview(usingSafeArea: true)
    
    let views = [
      topView,
      filtersCollectionView,
      shadowView,
    ]
  
    contentView.addSubviews(views)
    
//    topView.leadingToSuperview(usingSafeArea: true)
//    topView.trailingToSuperview(usingSafeArea: true)
//    topView.topToSuperview(usingSafeArea: true)
//
//    filtersCollectionView.leadingToSuperview(offset: padding)
//    filtersCollectionView.trailingToSuperview(offset: -padding)
//    filtersCollectionView.topToBottom(of: topView, offset: padding)
//    filterViewHeight = padding*2 + "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)
//    filtersCollectionView.height(filterViewHeight)
//
//    shadowView.topToBottom(of: filtersCollectionView, offset: padding)
//    shadowView.leadingToSuperview(offset: padding)
//    shadowView.trailingToSuperview(offset: padding)
//    shadowView.bottomToSuperview(offset: -padding)
    
    
    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    NSLayoutConstraint.activate([
//      contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//      contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
//      contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
//      contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: padding),
      topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      filtersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      filtersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    userView.alpha = 0
    let shadowLeading = shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding)
    shadowLeading.identifier = "leading"
    shadowLeading.isActive = true

    let shadowTrailing = shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding)
    shadowTrailing.identifier = "trailing"
    shadowTrailing.isActive = true

    let shadowBottom = shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding)
    shadowBottom.identifier = "bottom"
    shadowBottom.isActive = true

    let topConstraint_1 = filtersCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: padding)
    topConstraint_1.identifier = "top_1"
    topConstraint_1.isActive = true

    let topConstraint_2 = shadowView.topAnchor.constraint(equalTo: filtersCollectionView.bottomAnchor, constant: padding*2)
    topConstraint_2.identifier = "top"
    topConstraint_2.isActive = true


    filterViewHeight = padding*2 + "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)

    let constraint = filtersCollectionView.height(filterViewHeight)
    constraint.identifier = "height"
    
    contentView.addSubview(collectionEmptyPublicationsView)
    collectionEmptyPublicationsView.edges(to: background)
    
    background.addSubview(scrollToTopButton)
    let leading = scrollToTopButton.leading(to: background, offset: padding)
    leading.identifier = "leading"
    let constraint_2 = scrollToTopButton.topToBottom(of: background)
    constraint_2.identifier = "top"
    scrollToTopButton.size(.uniform(size: 40))
  }
  
  @MainActor
  func onUserSelected(userprofile: Userprofile) {
    func animateStackView(_ stack: UIStackView) {
      delayAsync(delay: 0.005) { [weak self] in
        guard let self = self else { return }
        
        self.isCardOnScreen = true
        stack.arrangedSubviews.enumerated().forEach { index, item in
          UIView.animate(
            withDuration: 0.3,
            delay: Double(index)*0.045,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: [.curveEaseInOut],
            animations: {
              item.alpha = 1
              item.transform = .identity
            }) { _ in }
        }
      }
    }
    
    guard let cell = self.feedCollectionView.cellForItem(at: self.indexPath) as? UserprofileCell,
          let constraint = shadowView.getConstraint(identifier: "top"),
          let constraint1 = filtersCollectionView.getConstraint(identifier: "top_1"),
          let topViewConstraint = topView.getConstraint(identifier: "height"),
          let stack = userStack.arrangedSubviews.filter({ $0 is UIStackView }).first as? UIStackView
    else { return }
    
    avatar.userprofile = userprofile

    let temp = UIImageView(image: userprofile.image ?? UIImage(named: "person"))
    if userprofile.image.isNil {
//      temp.tintColor = .systemGray
//      temp.contentMode = .center
//      temp.publisher(for: \.bounds)
//        .sink {
          temp.backgroundColor = .secondarySystemBackground
//          temp.image = UIImage(systemName: "person.fill",
//                               withConfiguration: UIImage.SymbolConfiguration(pointSize: $0.height * 0.65))
//        }
//        .store(in: &subscriptions)
    }
    temp.contentMode = .scaleAspectFill
    temp.frame = CGRect(origin: cell.avatar.superview!.convert(cell.avatar.frame.origin, to: topView), size: cell.avatar.bounds.size)
    temp.cornerRadius = cell.avatar.bounds.height/2
    topView.addSubview(temp)
    cell.avatar.alpha = 0
    
    let destinationFrame = CGRect(origin: .init(x: padding*3, y: padding*2),//avatar.superview!.convert(avatar.frame.origin, to: topView),
                                  size: .init(width: cell.avatar.bounds.size.width * 1.96, height: cell.avatar.bounds.size.width * 1.96))
    
    userView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    stack.arrangedSubviews.forEach { $0.alpha = 0; $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75) }
//    toggleDateFilter(on: true)
//    viewInput?.setNavigationBarHidden(false)
    setNeedsLayout()
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
//      usingSpringWithDamping: 0.8,
//      initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        temp.frame = destinationFrame
        temp.cornerRadius = destinationFrame.height/2
        self.feedCollectionView.alpha = 0
        self.userView.alpha = 1
        self.userView.transform = .identity
        constraint.constant = self.filtersCollectionView.alpha == 1 ? 16 : 8
        constraint1.constant = self.filtersCollectionView.alpha == 1 ? 16 : 8//8
        topViewConstraint.constant = self.topViewHeight * 1.5
        self.layoutIfNeeded()
        animateStackView(stack)
      }) { [weak self] _ in
        guard let self = self else { return }
        let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
          self.avatar.alpha = 1
        }) { _ in
          temp.removeFromSuperview()
        }
      }
  }
  
  @objc
  func handleTap(_ button: UIButton) {
//    guard let userprofile = userprofile else { return }
    guard let userprofile = filter.userprofile else { return }
    
    if button.accessibilityIdentifier == "profileButton" {
      viewInput?.openUserprofile(userprofile)
    } else if button.accessibilityIdentifier == "subscriptionButton" {
      
      viewInput?.unsubscribe(from: userprofile)
      subscriptionButton.isUserInteractionEnabled = false
      subscriptionButton.setSpinning(on: true, color: .systemRed) { [weak self] in
        guard let self = self,
              let button = self.subscriptionButton.getSubview(type: UIButton.self)
        else { return }
        
        button.imageView?.tintColor = .clear
        button.setAttributedTitle(NSAttributedString(string: "unsubscribe".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 11) as Any,
                                                      .foregroundColor: UIColor.clear as Any
                                                     ]),
                                  for: .normal)
      }
    }
  }
  
  @objc
  func handlePan(_ recognizer: UIPanGestureRecognizer) {
    guard let constraint = scrollToTopButton.getConstraint(identifier: "leading") else { return }
    
    let xTranslation = recognizer.translation(in: background).x + scrollToTopButtonX
    constraint.constant = max(padding, min(xTranslation, background.bounds.width - scrollToTopButton.bounds.width - padding)) // scrollToTopButtonX
    
    let velocity = recognizer.velocity(in: background).x
    
    if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
      scrollToTopButtonX = constraint.constant
      
      guard abs(velocity) > 200 else { return }
      
      let maxDistance = background.bounds.width - scrollToTopButton.bounds.width - padding
      let estimatedDistance = scrollToTopButtonX - abs(velocity*0.05)
      var distance = CGFloat.zero
      if velocity < 0 {
        distance = estimatedDistance < padding ? scrollToTopButtonX - padding : estimatedDistance
        if distance > 0 {
          distance = distance * -1
        }
        distance = max(-maxDistance/4, distance)
      } else {
        distance = estimatedDistance + scrollToTopButtonX > maxDistance ? maxDistance - scrollToTopButtonX : estimatedDistance
        if distance < 0 {
          distance = distance * -1
        }
        distance = min(maxDistance/4, distance)
      }
      
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant += distance
        self.layoutIfNeeded()
      }) { [weak self] _ in
        guard let self = self else { return }
       
        self.scrollToTopButtonX = constraint.constant
      }
    }
  }
  
  func onEmptyList(isEmpty: Bool) {
    if isEmpty {
      collectionEmptyPublicationsView.alpha = 0
      collectionEmptyPublicationsView.setAnimationsEnabled(true)
    }
    
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        self.collectionEmptyPublicationsView.alpha =  isEmpty ? 1 : 0
      }) { [weak self] _ in
        guard let self = self,
              !isEmpty
        else { return }
        
        self.collectionEmptyPublicationsView.setAnimationsEnabled(false)
      }
  }
  
  func toggleScrollButton(on: Bool, completion: Closure? = nil) {
    guard let constraint = scrollToTopButton.getConstraint(identifier: "top") else { return }
    
    scrollToTopButtonAnimates = true
    UIView.animate(withDuration: on ? 0.25 : 0.15,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: { [weak self] in
      guard let self = self else { return }
      
      self.background.setNeedsLayout()
      constraint.constant = on ? -(self.scrollToTopButton.bounds.width + self.padding) : 0
      self.background.layoutIfNeeded()
    }) { _ in completion?() }
  }

}

extension SubscriptionsView: SubsciptionsControllerOutput {
  @objc
  func scrollToTop() {
    surveysCollectionView.scrollToTop()
    toggleScrollButton(on: false) { delay(seconds: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.scrollToTopButtonAnimates = false
    }}
    isScrolledDown = false
  }
  
  func didAppear() {
    guard let current = Userprofiles.shared.current, current.subscriptions.isEmpty else { return }
    
    emptyPublicationsView?.setAnimationsEnabled(true)
  }
  
  func didDisappear() {
    emptyPublicationsView?.setAnimationsEnabled(false)
  }
  
  func hideUserCard(_ completion: Closure? = nil) {
    mode = .Default
//    surveysCollectionView. = .Subscriptions
    guard let viewInput = viewInput,
          viewInput.isOnScreen,
          let cell = self.feedCollectionView.cellForItem(at: self.indexPath) as? UserprofileCell,
//          let subview = userView.getSubview(type: UIView.self, identifier: "opaque"),
          let constraint = topView.getConstraint(identifier: "height"),
          let userprofile = filter.userprofile
    else {
//      guard let subview = userView.getSubview(type: UIView.self, identifier: "opaque"),
//            let constraint = subview.getConstraint(identifier: "trailing")
//      else { return }
      
      filter.setMain(filter: .disabled, userprofile: nil)
      avatar.alpha = 0
      isCardOnScreen = false
//      constraint.constant = 16
      if let cells = feedCollectionView.visibleCells.filter({ $0.isKind(of: UserprofileCell.self )}) as? [UserprofileCell] {
        cells.forEach { $0.avatar.alpha = 1 }
      }
      
      return
    }
    
    let temp = UIImageView(image: userprofile.image ?? UIImage(named: "person"))
    if userprofile.image.isNil {
      temp.backgroundColor = .secondarySystemBackground
    }
    temp.contentMode = .scaleAspectFill
    temp.frame = CGRect(origin: avatar.superview!.convert(avatar.frame.origin, to: topView),
                        size: avatar.bounds.size)
    temp.cornerRadius = temp.bounds.height/2
    avatar.alpha = 0
    topView.addSubview(temp)
    cell.avatar.alpha = 0
    filter.setMain(filter: .disabled, userprofile: nil)
    
    let destinationFrame = CGRect(origin: cell.avatar.convert(cell.avatar.imageView.frame.origin, to: topView),
                                  size: cell.avatar.imageView.bounds.size)
    
    setNeedsLayout()
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }

        temp.frame = destinationFrame
        temp.cornerRadius = cell.avatar.bounds.height/2
        self.feedCollectionView.alpha = 1
        self.userView.alpha = 0
        self.userView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        constraint.constant = topViewHeight
        self.layoutIfNeeded()
      }) { [weak self] _ in
        guard let self = self else { return }
        
        self.userView.transform = .identity

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
          cell.avatar.alpha = 1
        }) { [unowned self] _ in
          temp.removeFromSuperview()
          self.isCardOnScreen = false

          guard let completion = completion else { return }

          completion()
        }
      }
  }
  
  //    func setPeriod(_ period: Period) {
  //        surveysCollectionView.period = period
  //    }
  
  func onRequestCompleted(_ result: Result<Bool, Error>) {
    surveysCollectionView.refreshControl?.endRefreshing()
  }
  
  func onWillAppear() {
    surveysCollectionView.deselect()
  }
}
//
//extension SubscriptionsView: BannerObservable {
//  func onBannerWillAppear(_ sender: Any) {}
//  
//  func onBannerWillDisappear(_ sender: Any) {}
//  
//  func onBannerDidAppear(_ sender: Any) {}
//  
//  func onBannerDidDisappear(_ sender: Any) {
//    if let banner = sender as? Banner {
//      banner.removeFromSuperview()
//    } else if let popup = sender as? Popup {
//      popup.removeFromSuperview()
//    }
//  }
//}

extension SubscriptionsView: CallbackObservable {
  func callbackReceived(_ sender: Any) {
    
  }
}
