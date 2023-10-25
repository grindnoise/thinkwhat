//
//  SurveysView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class SurveysView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: (TintColorable & SurveysViewInput)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var containerView = UIView.opaque()
  private lazy var collectionView: SurveysCollectionView = {
    guard let viewInput = viewInput else { return SurveysCollectionView() }
      
    let instance = SurveysCollectionView(filter: viewInput.filter, color: viewInput.tintColor, showSeparators: true)

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
  private lazy var filterViewHeight: CGFloat = .zero
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
      SurveyFilterItem(main: .disabled, additional: .watchlist, text: "filter_watchlist"),
      SurveyFilterItem(main: .disabled, additional: .discussed, text: "filter_discussed"),
      SurveyFilterItem(main: .disabled, additional: .completed, text: "filter_completed"),
      SurveyFilterItem(main: .disabled, additional: .notCompleted, text: "filter_not_completed"),
    ],
                                               contentInsets: .uniform(padding))
//    instance.layer.masksToBounds = false
    // Filtering
    instance.filterPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self,
              let viewInput = self.viewInput
        else { return }
        
        viewInput.filter.setAdditional(filter: $0.additional, period: $0.period)
        self.isScrolledDown = false
        delay(seconds: 0.4) { [weak self] in
          guard let self = self else { return }
          
          self.scrollToTop()
        }
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var emptyPublicationsView: EmptyPublicationsView = {
    let instance = EmptyPublicationsView(showsButton: false,
                                         backgroundLightColor: .systemBackground,
                                         backgroundDarkColor: Constants.UI.Colors.darkTheme,
                                         spiralLightColor: Constants.UI.Colors.spiralLight,
                                         spiralDarkColor: Constants.UI.Colors.spiralDark)
    instance.alpha = 0
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)
    
    return instance
  }()
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
  ///**Logic**
  private var isEmpty = false {
    didSet {
      guard isEmpty != oldValue else { return }
      
      onEmptyList(isEmpty: isEmpty)
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
  
  
  // MARK: - Deinitialization
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
    debugPrint("\(String(describing: type(of: self))).\(#function) \(DebuggingIdentifiers.destructing)")
  }
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
   
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
  }
}

// MARK: - Controller Output
extension SurveysView: SurveysControllerOutput {
  func onSearchCompleted(_ instances: [SurveyReference]) {
    collectionView.endSearchRefreshing()
    collectionView.setSearchResult(instances)
  }
  
  func setSearchModeEnabled(_ enabled: Bool) {
    isScrolledDown = false
    collectionView.setSearchModeEnabled(enabled)
    
    guard let constraint = filtersCollectionView.getConstraint(identifier: "height"),
          let leading = filtersCollectionView.getConstraint(identifier: "leading")
    else { return }
    
    if enabled {
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseIn) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        leading.constant = self.filtersCollectionView.bounds.width
        self.layoutIfNeeded()
      } completion: {  _ in
        delay(seconds: 0.15) { [weak self] in
          guard let self = self else { return }
          
          self.setNeedsLayout()
          constraint.constant = 0
          self.layoutIfNeeded()
        }
      }
    } else {
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        constraint.constant = self.filterViewHeight
        self.layoutIfNeeded()
      } completion: { _ in
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseOut) { [weak self] in
          guard let self = self else { return }
          
          self.setNeedsLayout()
          leading.constant = 0
          self.layoutIfNeeded()
        }
      }
    }
  }
  
  func beginSearchRefreshing() {
    collectionView.beginSearchRefreshing()
  }
  
  func viewDidDisappear() {
    collectionView.deinitPublisher.send(true)
  }
  
  func onRequestCompleted(_: Result<Bool, Error>) {
    collectionView.refreshControl?.endRefreshing()
  }
}

private extension SurveysView {
  @MainActor
  func setupUI() {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Constants.UI.Colors.darkTheme : .systemBackground
//    collectionView.place(inside: self)
    
    filtersCollectionView.setColor(viewInput?.tintColor ?? Constants.UI.Colors.filterEnabled)
    collectionView.color = viewInput!.tintColor
    
    let views = [
      filtersCollectionView,
      containerView
    ]
  
    addSubviews(views)
    let leadingConstraint = filtersCollectionView.leadingToSuperview()
    leadingConstraint.identifier = "leading"
    filtersCollectionView.widthToSuperview()
    filtersCollectionView.topToSuperview(offset: padding, usingSafeArea: true)
    filterViewHeight = padding*2 + "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)
    let constraint = filtersCollectionView.height(filterViewHeight)
    constraint.identifier = "height"
    
    containerView.topToBottom(of: filtersCollectionView, offset: padding)
    containerView.leadingToSuperview()
    containerView.trailingToSuperview()
    containerView.bottomToSuperview(usingSafeArea: true)
    
    containerView.addSubview(collectionView)
    collectionView.edgesToSuperview()
    
    containerView.addSubview(scrollToTopButton)
    let leading = scrollToTopButton.leading(to: containerView, offset: padding)
    leading.identifier = "leading"
    let constraint_2 = scrollToTopButton.topToBottom(of: containerView)
    constraint_2.identifier = "top"
    scrollToTopButton.size(.uniform(size: 40))
  }
  
  @objc
  func scrollToTop() {
    collectionView.scrollToTop()
    toggleScrollButton(on: false) { delay(seconds: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.scrollToTopButtonAnimates = false
    }}
    isScrolledDown = false
  }
  
  func toggleScrollButton(on: Bool, completion: Closure? = nil) {
    guard let constraint = scrollToTopButton.getConstraint(identifier: "top") else { return }
    
    scrollToTopButtonAnimates = true
    UIView.animate(withDuration: on ? 0.45 : 0.25,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: { [weak self] in
      guard let self = self else { return }
      
      self.containerView.setNeedsLayout()
      constraint.constant = on ? -(self.scrollToTopButton.bounds.width + self.padding + self.safeAreaInsets.bottom*2) : 0
      self.containerView.layoutIfNeeded()
    }) { _ in completion?() }
  }
  
  @objc
  func handlePan(_ recognizer: UIPanGestureRecognizer) {
    guard let constraint = scrollToTopButton.getConstraint(identifier: "leading") else { return }
    
    let xTranslation = recognizer.translation(in: containerView).x + scrollToTopButtonX
    constraint.constant = max(padding, min(xTranslation, containerView.bounds.width - scrollToTopButton.bounds.width - padding)) // scrollToTopButtonX
    
    let velocity = recognizer.velocity(in: containerView).x
    
    if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
      scrollToTopButtonX = constraint.constant
      
      guard abs(velocity) > 200 else { return }
      
      let maxDistance = containerView.bounds.width - scrollToTopButton.bounds.width - padding
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
      emptyPublicationsView.alpha = 0
      emptyPublicationsView.setAnimationsEnabled(true)
    }


    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }

        self.emptyPublicationsView.alpha =  isEmpty ? 1 : 0
      }) { [weak self] _ in
        guard let self = self, !isEmpty else { return }

        self.emptyPublicationsView.setAnimationsEnabled(false)
      }
  }
}

extension SurveysView: CallbackObservable {
  func callbackReceived(_ sender: Any) {
    
  }
}

//extension SurveysView: BannerObservable {
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
