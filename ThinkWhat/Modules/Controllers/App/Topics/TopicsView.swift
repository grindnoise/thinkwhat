//
//  TopicsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicsView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: (TopicsViewInput & TintColorable)? {
    didSet {
      guard let viewInput = viewInput else { return }
      
      setupUI()
      
      viewInput.filter.changePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          // If topic case
          if viewInput.filter.getMain() == .topic, let topic = viewInput.filter.topic {
            // Set filters color
            self.filtersCollectionView.setColor(topic.tagColor)
          }
        }
        .store(in: &subscriptions)
    }
  }
  public private(set) var searchPublisher = PassthroughSubject<String, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private var tempColor = UIColor.clear { // Used for color transition from topic selection to surveys
    didSet {
      // Change scroll to top button color
      guard oldValue != tempColor,
            let gradient = scrollToTopButton.getLayer(identifier: "background") as? CAGradientLayer
      else { return }
      
      gradient.colors = CAGradientLayer.getGradientColors(color: tempColor)
      
      // Change search field/cancel button/activity indicator color
      searchField.tintColor = tempColor
      searchCancelButton.setAttributedTitle(NSAttributedString(string: "cancel".localized.capitalized, attributes: [
        .font: UIFont(name: Fonts.Rubik.Regular, size: 16) as Any,
        .foregroundColor: tempColor
      ]), for: .normal)
      if let indicator = searchField.rightView as? UIActivityIndicatorView {
        indicator.color = tempColor
      }
    }
  }
  private lazy var surveysCollectionView: SurveysCollectionView = {
    let instance = SurveysCollectionView(filter: viewInput!.filter, showSeparators: true, topicMode: true)
    instance.backgroundColor = .clear
    instance.alpha = 0
    instance.isOnScreen = false

    // Pagination
    instance.paginationPublisher
      .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
      .eraseToAnyPublisher()
      .sink { [unowned self] in self.viewInput?.getDataItems(excludeList: $0) }
      .store(in: &subscriptions)
    
    // Refresh
    instance.refreshPublisher
      .sink { [unowned self] in self.viewInput?.getDataItems(excludeList: []) }
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
        // Hide keyboard for convenience
        self.searchField.resignFirstResponder()
      }
      .store(in: &subscriptions)
    
    instance.scrolledToTopPublisher
      .sink { [weak self] _ in
        guard let self = self, self.isScrolledDown else { return }
        
        self.isScrolledDown = false
      }
      .store(in: &subscriptions)

//    instance.emptyPublicationsPublisher
//      .filter { !$0.isNil }
//      .sink { [weak self] in
//        guard let self = self else { return }
//
//        self.isEmpty = $0!
//      }
//      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var filtersCollectionView: SurveyFiltersCollectionView = {
    let instance = SurveyFiltersCollectionView(items: [
      SurveyFilterItem(main: .new,
                       additional: .period,
                       isFilterEnabled: true,
                       text: Enums.Period.unlimited.description,
                       image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                       period: .unlimited,
                       periodThreshold: .unlimited),
      SurveyFilterItem(main: .rated, additional: .disabled, text: "filter_rated"),
      SurveyFilterItem(main: .own, additional: .disabled, text: "filter_own"),
      SurveyFilterItem(main: .disabled, additional: .watchlist, text: "filter_watchlist"),
      SurveyFilterItem(main: .disabled, additional: .discussed, text: "filter_discussed"),
      SurveyFilterItem(main: .disabled, additional: .completed, text: "filter_completed"),
      SurveyFilterItem(main: .disabled, additional: .notCompleted, text: "filter_not_completed"),
      SurveyFilterItem(main: .disabled, additional: .anonymous, text: "filter_anonymous")
    ],
                                               contentInsets: .uniform(padding)
    )
    
    // Filtering
    instance.filterPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.isScrolledDown = false
        self.viewInput?.filter.setBoth(main: $0.main,
                                       topic: self.viewInput!.filter.topic,
                                       userprofile: $0.userprofile,
                                       compatibility: $0.compatibility,
                                       additional: $0.additional,
                                       period: $0.period)
        
        delay(seconds: 0.3) { [weak self] in
          guard let self = self else { return }
          
          self.scrollToTop()
        }
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var topicsCollectionView: TopicsCollectionView = {
    let instance = TopicsCollectionView()
    instance.backgroundColor = .clear
    
    // Subscription listener
    instance.topicSubscriptionPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self,
              let topic = $0.keys.first,
              let val = $0.values.first
        else { return }
          
        self.viewInput?.subscribe(topic: topic, subscribe: val)
      }
      .store(in: &subscriptions)
    
    // Tap listener
    instance.touchSubject
      .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        guard let self = self,
              let dict = $0,
              let point = dict.values.first,
              let topic = dict.keys.first,
              !topic.activeCount.isZero
        else { return }

        self.viewInput?.filter.setMain(filter: .topic, topic: topic)
        self.touchLocation = point
        self.surveysCollectionView.isOnScreen = true
        self.setBackgroundColor()
        self.surveysCollectionView.alpha = 1
        self.topicsCollectionView.isUserInteractionEnabled = false
        Animations.unmaskLayerCircled(layer: surveysCollectionView.layer,
                                      location: point,
                                      duration: 0.6,
                                      timingFunction: .easeInEaseOut,
                                      animateOpacity: false,
                                      delegate: self)
        let blurEffect = UIVisualEffectView(effect: nil)
        self.background.insertSubview(blurEffect, belowSubview: self.surveysCollectionView)
        blurEffect.edgesToSuperview()
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
          guard let self = self else { return }
          
          blurEffect.effect = UIBlurEffect(style: .prominent)
        }) { _ in blurEffect.removeFromSuperview() }
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var background: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "bg"
    instance.layer.masksToBounds = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.surveyCollectionDark : Constants.UI.Colors.surveyCollectionLight
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width *  0.05 }
      .store(in: &subscriptions)
    
    topicsCollectionView.addEquallyTo(to: instance)
    surveysCollectionView.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.layer.masksToBounds = false
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UISettings.Shadows.color // UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = UISettings.Shadows.radius(padding: padding)
    instance.layer.shadowOffset = .zero
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .throttle(for: .seconds(0.3), scheduler: DispatchQueue.main, latest: false)
      .filter { $0 != .zero }
      .sink {
        instance.layer.add(Animations.get(property: .ShadowPath,
                                          fromValue: instance.layer.shadowPath as Any,
                                          toValue: UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath,
                                          duration: 0.2,
                                          delay: 0,
                                          repeatCount: 0,
                                          autoreverses: false,
                                          timingFunction: .linear,
                                          delegate: nil,
                                          isRemovedOnCompletion: false,
                                          completionBlocks: nil),
                           forKey: nil)
        
//        instance.layer.shadowPath = path//UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath
      }
      .store(in: &subscriptions)
    background.place(inside: instance)
    
    return instance
  }()
  private lazy var filterViewHeight: CGFloat = .zero
  // Search
  private lazy var searchStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      searchField,
      searchCancelButton
    ])
    instance.spacing = padding
  
    return instance
  }()
  private lazy var searchField: InsetTextField = {
    let instance = InsetTextField(rightViewVerticalScaleFactor: 1.25)
    instance.autocorrectionType = .no
    let v = UIActivityIndicatorView()
    v.color = Constants.UI.Colors.main
    v.alpha = 0
    instance.rightView = v
    instance.rightViewMode = .always
    instance.attributedPlaceholder = NSAttributedString(string: "search".localized, attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
      .foregroundColor: UIColor.secondaryLabel,
    ])
    instance.delegate = self
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = .secondarySystemBackground
    instance.tintColor = Constants.UI.Colors.main
    instance.addTarget(self, action: #selector(TopicsView.textFieldDidChange(_:)), for: .editingChanged)
    instance.returnKeyType = .done
    instance.publisher(for: \.bounds)
      .sink { rect in
        instance.cornerRadius = rect.width*0.025
        
        guard instance.insets == .zero else { return }
        
        instance.insets = UIEdgeInsets(top: instance.insets.top,
                                       left: rect.height/3,
                                       bottom: instance.insets.top,
                                       right: rect.height/3)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var searchCancelButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self, action: #selector(self.cancelSearch), for: .touchUpInside)
    instance.width("cancel".localized.capitalized.width(withConstrainedHeight: 100, font: UIFont(name: Fonts.Rubik.Regular, size: 16)!))
    instance.setAttributedTitle(NSAttributedString(string: "cancel".localized.capitalized,
                                                  attributes: [
                                                    .font: UIFont(name: Fonts.Rubik.Regular, size: 16) as Any,
                                                    .foregroundColor: Constants.UI.Colors.main
                                                  ]), for: .normal)
    return instance
  }()
  // Scroll to top
  private lazy var scrollToTopButton: UIButton = {
    let instance = UIButton()
    instance.backgroundColor = .clear
    instance.tintColor = .white
    instance.addTarget(self, action: #selector(self.scrollToTop), for: .touchUpInside)
    instance.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))
//    instance.size(.uniform(size: 40))
    let bgLayer = CAGradientLayer()
    bgLayer.type = .radial
    bgLayer.colors = CAGradientLayer.getGradientColors(color: Constants.UI.Colors.main)
    bgLayer.locations = [0, 0.5, 1.15]
    bgLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
    bgLayer.endPoint = CGPoint(x: 1, y: 1)
    bgLayer.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { bgLayer.cornerRadius = $0.height/2 }
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
  private var isScrolledDown = false { // Use to show/hide arrow button
    didSet {
      guard oldValue != isScrolledDown,
            !scrollToTopButtonAnimates
      else { return }

      toggleScrollButton(on: isScrolledDown) { [unowned self] in self.scrollToTopButtonAnimates = false }
    }
  }
  ///**Logic**
  private var touchLocation: CGPoint = .zero
  
  // MARK: - IB outlets
  @IBOutlet var contentView: UIView!
  
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
    super.init(coder: coder)
    
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }

    addSubview(contentView)
  }

  // MARK: - Overrriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    topicsCollectionView.backgroundColor = .clear
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    setBackgroundColor()
  }
}

// MARK: - Private
private extension TopicsView {
  @MainActor
  func setupUI() {
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
    
    filtersCollectionView.setColor(viewInput?.tintColor ?? Constants.UI.Colors.filterEnabled)
    
    addSubview(contentView)
    contentView.edgesToSuperview(usingSafeArea: true)
    
    let views = [
      filtersCollectionView,
      shadowView,
    ]
  
    contentView.addSubviews(views)
    let leadingConstraint = filtersCollectionView.leadingToSuperview()
    leadingConstraint.identifier = "leading"
    filtersCollectionView.width(appDelegate.window!.bounds.width)
    filtersCollectionView.topToSuperview(offset: padding*1)
    filterViewHeight = padding*2 + "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)
    let heightConstraint = filtersCollectionView.height(0)
    heightConstraint.identifier = "height"
    
    addSubview(searchStack)
    searchStack.height(UINavigationController.Constants.NavBarHeightSmallState - padding)
    searchStack.trailingToLeading(of: filtersCollectionView, offset: -padding)
    searchStack.centerY(to: filtersCollectionView)
    searchStack.width(to: self, offset: -padding*2)
    
    let constraint = shadowView.topToBottom(of: filtersCollectionView, offset: 0)//padding*2)
    constraint.identifier = "top"
    shadowView.leadingToSuperview(offset: padding)
    shadowView.trailingToSuperview(offset: padding)
    shadowView.bottomToSuperview(offset: -padding)
    
    background.addSubview(scrollToTopButton)
    let leading = scrollToTopButton.leading(to: background, offset: padding)
    leading.identifier = "leading"
    let constraint_2 = scrollToTopButton.topToBottom(of: background, offset: padding)
    constraint_2.identifier = "top"
    scrollToTopButton.size(.uniform(size: 40))
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
//        constraint.constant = max(padding, min(velocity*0.05, background.bounds.width - scrollToTopButton.bounds.width - padding))
        constraint.constant += distance
        self.layoutIfNeeded()
      }) { [weak self] _ in
        guard let self = self else { return }
       
        self.scrollToTopButtonX = constraint.constant
      }
    }
    //
    //    if yTranslation > 0 {
    //      constraint.constant = min(constraint.constant, statusBarFrame.height)
    //    }
    //    constraint.constant = constraint.constant < minConstant ? minConstant : constraint.constant
//
//    recognizer.setTranslation(.zero, in: background)
//    var point = convert(scrollToTopButton.frame.origin, to: background).x
//    print(point)
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
      constraint.constant = on ? -(self.scrollToTopButton.bounds.width + self.padding) : self.padding
      self.background.layoutIfNeeded()
    }) { _ in completion?() }
  }
  
  @objc
  func hideKeyboard() {
    if let recognizer = gestureRecognizers?.first {
      removeGestureRecognizer(recognizer)
    }
    endEditing(true)
  }
  
  @objc
  func cancelSearch() {
    viewInput?.searchMode = .off
    hideKeyboard()
    searchField.text = ""
  }
  
  func setSearchSpinnerEnabled(enabled: Bool, animated: Bool) {
    guard let spinner = searchField.rightView as? UIActivityIndicatorView else { return }
    
    if enabled && !spinner.alpha.isZero || !enabled && spinner.alpha.isZero {
      return
    }
    
    if enabled {
      spinner.startAnimating()
    }
    
    switch animated {
    case true:
      spinner.alpha = !enabled ? 1 : 0
      spinner.transform = enabled ? .init(scaleX: 0.5, y: 0.5) : .identity
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: enabled ? 0 : 0.25, options: .curveEaseInOut, animations: {
        spinner.alpha = enabled ? 1 : 0
        spinner.transform = enabled ? .identity : .init(scaleX: 0.5, y: 0.5)
      }) { _ in
        if !enabled {
          spinner.stopAnimating()
        }
      }
    case false:
      spinner.alpha = enabled ? 1 : 0
      if !enabled {
        spinner.stopAnimating()
      }
    }
  }
  
  func setBackgroundColor() {
    UIView.animate(withDuration: 0.15) { [weak self] in
      guard let self = self else { return }
      
      self.background.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .white
      self.surveysCollectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .white
    }
  }
  
  func toggleTopView(on: Bool, delay: TimeInterval = 0, animationClosure: Closure? = nil, completionClosure: Closure? = nil) {
    guard let topConstraint = shadowView.getConstraint(identifier: "top"),
          let heightConstraint = filtersCollectionView.getConstraint(identifier: "height")
    else { return }
    
    // Check if top view is already revealed
    if on && !topConstraint.constant.isZero && !heightConstraint.constant.isZero {
      return
    }
    
    // If users cancels search in topic mode, than we don't need to hide top view
    if !on && viewInput?.mode == .Topic {
      return
    }
    
    UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      self.setNeedsLayout()
      topConstraint.constant = on ? padding*2 : 0
      heightConstraint.constant = on ? self.filterViewHeight : 0
      self.layoutIfNeeded()
      animationClosure?()
    } completion: { _ in completionClosure?() }
  }
}

// MARK: - Controller Output
extension TopicsView: TopicsControllerOutput {
  func setColor(_ color: UIColor) {
    tempColor = color
  }
  
  func resetFilters() {
    filtersCollectionView.resetFilters()
  }
  
  func didAppear() {
//    guard isEmpty else { return }

//    emptyPublicationsView.setAnimationsEnabled(true)
//    collectionView.didAppear()
  }
  
  func didDisappear() {
//    emptyPublicationsView.setAnimationsEnabled(false)
    
//    collectionView.didDisappear()
  }

  func onRequestCompleted(_ result: Result<Bool, Error>) {
    surveysCollectionView.refreshControl?.endRefreshing()
  }
  
  func setFiltersHidden(_ hidden: Bool) {
    guard let leading = filtersCollectionView.getConstraint(identifier: "leading") else { return }
    
    leading.constant = -filtersCollectionView.bounds.width
    if !hidden {
//      // If filters are visible, than skip (came from other app tab)
      guard let heightConstraint = filtersCollectionView.getConstraint(identifier: "height"), heightConstraint.constant.isZero else { return }
      
      filtersCollectionView.alpha = 0
      toggleTopView(on: true, completionClosure:  { [weak self] in
        guard let self = self, !hidden else { return }
        
        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          usingSpringWithDamping: 0.8,
          initialSpringVelocity: 0.2,
          options: [.curveEaseInOut]) { [weak self] in
          guard let self = self else { return }
          
          self.setNeedsLayout()
          // Set offset
          leading.constant = 0
          self.layoutIfNeeded()
          self.filtersCollectionView.alpha = 1
        } completion: {  _ in }
      })
    } else {
      filtersCollectionView.alpha = 1
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25,
                                                     delay: 0,
                                                     options: .curveEaseInOut) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        // Set offset
        leading.constant = -self.filtersCollectionView.bounds.width
        self.layoutIfNeeded()
        self.filtersCollectionView.alpha = 0
      } completion: { [weak self] _ in
        guard let self = self else { return }
        
        self.toggleTopView(on: false)
        self.filtersCollectionView.alpha = 0
      }
    }
  }
  
  func setSearchModeEnabled(enabled: Bool, delay: TimeInterval = 0) {
    toggleTopView(on: enabled,
                  delay: delay,
                  animationClosure: viewInput?.mode == .Default ? { [weak self] in
      guard let self = self else { return }
      
      if enabled {
        self.topicsCollectionView.alpha = 0
        self.surveysCollectionView.alpha = 1
      } else {
        self.surveysCollectionView.alpha = 0
        self.topicsCollectionView.alpha = 1
      }
    } : nil)
    
    isScrolledDown = false
    
    // Clear surveys collection
//    if enabled {
      surveysCollectionView.setSearchModeEnabled(enabled)
//    }
    
    guard let leading = filtersCollectionView.getConstraint(identifier: "leading") else { return }
    
    if enabled {
      filtersCollectionView.alpha = viewInput?.mode == .Topic ? 1 : 0
      searchStack.alpha = viewInput?.mode == .Topic ? 1 : 0
      searchField.becomeFirstResponder()
      UIView.animate(
        withDuration: 0.3,
        delay: viewInput?.mode == .Default ? 0.15 : 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.2,
        options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        // Set offset
        leading.constant = self.filtersCollectionView.bounds.width
        if self.viewInput?.mode == .Topic {
          self.filtersCollectionView.alpha = 0
        }
        self.layoutIfNeeded()
      } completion: {  _ in }
      if viewInput?.mode != .Topic {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.15, options: .curveEaseInOut) { [weak self] in
          guard let self = self else { return }
          
          self.searchStack.alpha = 1
          //        self.searchCancelButton.alpha = 1
          //        self.searchCancelButton.transform = .identity
        } completion: {  _ in }
      }
    } else {
      searchField.resignFirstResponder()
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.2,
        options: [.curveEaseInOut]) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        leading.constant = 0
        self.layoutIfNeeded()
        self.searchStack.alpha = 0
        if self.viewInput?.mode == .Topic {
          self.filtersCollectionView.alpha = 1
        }
      }
//      { [weak self] _ in
//        guard let self = self else { return }
//        
//        self.surveysCollectionView.setSearchModeEnabled(false)
//      }
    }
  }
  
  func onSearchCompleted(_ instances: [SurveyReference], localSearch: Bool) {
    surveysCollectionView.endSearchRefreshing()
    surveysCollectionView.setSearchResult(instances)
    if !localSearch {
      setSearchSpinnerEnabled(enabled: false, animated: true)
    }
  }
  
//  func setTopicModeEnabled(_ topic: Topic) {
//    UIView.animate(withDuration: 0.2) { [unowned self] in
//      if self.isEmpty {
//        self.emptyLabel.alpha = 1
//      }
//    }
////    surveysCollectionView.topic = topic
//  }
  
  func beginSearchRefreshing() {
    surveysCollectionView.beginSearchRefreshing()
  }
  
  func onSearchCompleted(_ instances: [SurveyReference]) {
    fatalError()
//    surveysCollectionView.endSearchRefreshing()
//    surveysCollectionView.fetchResult = instances
  }
  
  @objc
  func scrollToTop() {
    surveysCollectionView.scrollToTop()
    toggleScrollButton(on: false) { delay(seconds: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.scrollToTopButtonAnimates = false
    }}
    isScrolledDown = false
  }
  
  func showTopics() {
    Animations.unmaskLayerCircled(unmask: false,
                                  layer: surveysCollectionView.layer,
                                  location: surveysCollectionView.convert(touchLocation, to: surveysCollectionView),
                                  duration: 0.45,
                                  timingFunction: .easeInEaseOut,
                                  animateOpacity: false,
                                  delegate: self) { [weak self] in
      guard let self = self else { return }
      
      self.surveysCollectionView.alpha = 0
      self.topicsCollectionView.isUserInteractionEnabled = true
    }
    
    // Blur reversed animation
    let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    background.insertSubview(blurEffect, belowSubview: surveysCollectionView)
    blurEffect.edgesToSuperview()
    UIView.animate(withDuration: 0.45,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: {
      blurEffect.effect = nil
    }) { _ in blurEffect.removeFromSuperview() }
  }
}

extension TopicsView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completion") as? Closure {
      completionBlocks()
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
    }
  }
}

extension TopicsView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    gestureRecognizers = []
    let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsView.hideKeyboard))
    addGestureRecognizer(touch)
    
    return true
  }
  
  @objc
  func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else { return }
    
    if text.isEmpty {
      onSearchCompleted([], localSearch: false)
      setSearchSpinnerEnabled(enabled: false, animated: true)
    } else if text.count > 2 {
      surveysCollectionView.beginSearchRefreshing()
      setSearchSpinnerEnabled(enabled: true, animated: true)
      searchPublisher.send(text)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let recognizer = gestureRecognizers?.first {
      removeGestureRecognizer(recognizer)
    }
    textField.resignFirstResponder()
    return true
  }
}
