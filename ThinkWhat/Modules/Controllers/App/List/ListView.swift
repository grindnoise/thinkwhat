//
//  ListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class ListView: UIView {
  
  // MARK: - Public properties
  public let subscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
  public let unsubscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
  public let userprofilePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
  public weak var viewInput: (ListViewInput & TintColorable)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  public var isOnScreen: Bool = true {
    didSet {
      guard oldValue != isOnScreen else { return }
      
      collectionView.isOnScreen = isOnScreen
    }
  }
  
  // MARK: - IB outlets
  @IBOutlet var contentView: UIView!
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var emptyPublicationsView: EmptyPublicationsView = {
    let instance = EmptyPublicationsView(showsButton: true,
                                         buttonText: "create_post",
                                         buttonColor: viewInput?.tintColor ?? Colors.main,
                                         backgroundLightColor: .systemBackground,
                                         backgroundDarkColor: Colors.darkTheme,
                                         spiralLightColor: Colors.spiralLight,
                                         spiralDarkColor: Colors.spiralDark)
    instance.alpha = 0
    
    return instance
  }()
  private let filter = SurveyFilter(main: .new, additional: .period, period: .month)
  private lazy var collectionView: SurveysCollectionView = {
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
  private lazy var filtersCollectionView: SurveyFiltersCollectionView = {
    let instance = SurveyFiltersCollectionView(items: [
      SurveyFilterItem(main: .new,
                       additional: .period,
                       isFilterEnabled: true,
                       text: Enums.Period.month.description,
                       image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                       period: .month,
                       periodThreshold: .unlimited),
      SurveyFilterItem(main: .rated, additional: .rated, text: "filter_rated"),
      SurveyFilterItem(main: .own, additional: .rated, text: "filter_own"),
      SurveyFilterItem(main: .favorite, additional: .rated, text: "filter_watchlist"),
      SurveyFilterItem(main: .disabled, additional: .discussed, text: "filter_discussed"),
      SurveyFilterItem(main: .disabled, additional: .completed, text: "filter_completed"),
      SurveyFilterItem(main: .disabled, additional: .notCompleted, text: "filter_not_completed"),
      SurveyFilterItem(main: .disabled, additional: .anonymous, text: "filter_anonymous")
      ])
    instance.layer.masksToBounds = false
    
    // Filtering
    instance.filterPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        
        self.filter.setBoth(main: $0.main,
                            topic: $0.topic,
                            userprofile: $0.userprofile,
                            compatibility: $0.compatibility,
                            additional: $0.additional,
                            period: $0.period)
        
//        self.filter.setAdditional(filter: $0.additional, period: $0.period)
        self.isScrolledDown = false
        self.scrollToTop()
      }
      .store(in: &subscriptions)
    
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
//    instance.publisher(for: \.bounds)
//      .receive(on: DispatchQueue.main)
//      .throttle(for: .seconds(0.3), scheduler: DispatchQueue.main, latest: false)
//      .filter { $0 != .zero }
//      .sink {
//        let path = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath
//        instance.layer.add(Animations.get(property: .ShadowPath,
//                                          fromValue: instance.layer.shadowPath as Any,
//                                          toValue: path,
//                                          duration: 0.2,
//                                          delay: 0,
//                                          repeatCount: 0,
//                                          autoreverses: false,
//                                          timingFunction: .linear,
//                                          delegate: nil,
//                                          isRemovedOnCompletion: false,
//                                          completionBlocks: nil),
//                           forKey: nil)
//
////        instance.layer.shadowPath = path//UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath
//      }
//      .store(in: &subscriptions)
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath }
      .store(in: &subscriptions)
    background.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var background: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "bg"
    instance.layer.masksToBounds = false
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.surveyCollectionDark : Colors.surveyCollectionLight
    instance.publisher(for: \.bounds)
      .sink { [unowned self] in instance.cornerRadius = $0.width * 0.05 }
      .store(in: &subscriptions)
    
//    collectionView.addEquallyTo(to: instance)
    instance.addSubview(collectionView)
    collectionView.edgesToSuperview()
    
    return instance
  }()
  private lazy var filterViewHeight: CGFloat = .zero
  private lazy var scrollToTopButton: UIButton = {
    let instance = UIButton()
    instance.backgroundColor = viewInput?.tintColor ?? Colors.main
    instance.setImage(UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
    instance.size(.uniform(size: 40))
    instance.tintColor = .white
    instance.addTarget(self, action: #selector(self.scrollToTop), for: .touchUpInside)
    instance.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.width/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var scrollToTopButtonX = CGFloat.zero
  private var scrollToTopButtonAnimates = false
  private var isScrolledDown = false { // Use to show/hide arrow button
    didSet {
      guard oldValue != isScrolledDown,
            !scrollToTopButtonAnimates,
            let constraint = scrollToTopButton.getConstraint(identifier: "top")
      else { return }

//      if scrollToTopButtonX == .zero {
//        scrollToTopButtonX = padding + scrollToTopButton.bounds.width
//      }
      scrollToTopButtonAnimates = true
      UIView.animate(withDuration: isScrolledDown ? 0.25 : 0.15,
                     delay: 0,
                     options: .curveEaseInOut,
                     animations: { [weak self] in
        guard let self = self else { return }
        
        self.background.setNeedsLayout()
        constraint.constant = self.isScrolledDown ? -(self.scrollToTopButton.bounds.width + self.padding) : 0
        self.background.layoutIfNeeded()
      }) { [unowned self] _ in self.scrollToTopButtonAnimates = false }
    }
  }
  ///**Logic**
  private var isEmpty = false {
    didSet {
      guard isEmpty != oldValue else { return }
      
      onEmptyList(isEmpty: isEmpty)
    }
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
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
//    setupUI()
  }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.surveyCollectionDark : Colors.surveyCollectionLight
  }
}

private extension ListView {
  @MainActor
  func setupUI() {
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
    
    filtersCollectionView.color = viewInput!.tintColor
    collectionView.color = viewInput!.tintColor
    
    addSubview(contentView)
    contentView.edgesToSuperview(usingSafeArea: true)
    
    let views = [
      filtersCollectionView,
      shadowView,
    ]
  
    contentView.addSubviews(views)
    filtersCollectionView.leadingToSuperview(offset: padding)
    filtersCollectionView.trailingToSuperview(offset: -padding)
    filtersCollectionView.topToSuperview(offset: padding*2)
    filterViewHeight = padding*2 + "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)
    filtersCollectionView.height(filterViewHeight)
    
    shadowView.topToBottom(of: filtersCollectionView, offset: padding*2)
    shadowView.leadingToSuperview(offset: padding)
    shadowView.trailingToSuperview(offset: padding)
    shadowView.bottomToSuperview(offset: -padding)
    
    background.addSubview(scrollToTopButton)
    let leading = scrollToTopButton.leading(to: background, offset: padding)
    leading.identifier = "leading"
    let constraint_2 = scrollToTopButton.topToBottom(of: background)
    constraint_2.identifier = "top"
    
    background.addSubview(emptyPublicationsView)
    emptyPublicationsView.edgesToSuperview()
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
//    func emptyLabel() -> UILabel {
//      let label = UILabel()
//      label.accessibilityIdentifier = "emptyLabel"
//      label.backgroundColor = .clear
//      label.alpha = 0
//      label.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .title3)
//      label.text = "publications_not_found".localized// + "\n⚠︎"
//      label.textColor = .secondaryLabel
//      label.numberOfLines = 0
//      label.textAlignment = .center
//
//      return label
//    }
//
//    if isEmpty {
//      let label = shadowView.getSubview(type: UILabel.self, identifier: "emptyLabel") ?? emptyLabel()
//      label.place(inside: shadowView,
//                  insets: .uniform(size: self.padding*2))
//      label.transform = .init(scaleX: 0.75, y: 0.75)
//      UIView.animate(
//        withDuration: 0.4,
//        delay: 0,
//        usingSpringWithDamping: 0.8,
//        initialSpringVelocity: 0.3,
//        options: [.curveEaseInOut],
//        animations: { [weak self] in
//          guard let self = self else { return }
//
//          label.transform = .identity
//          label.alpha = 1
//          self.collectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .clear
//        }) { _ in }
//    } else if let label = shadowView.getSubview(type: UILabel.self, identifier: "emptyLabel") {
//      UIView.animate(
//        withDuration: 0.4,
//        delay: 0,
//        usingSpringWithDamping: 0.8,
//        initialSpringVelocity: 0.3,
//        options: [.curveEaseInOut],
//        animations: { [weak self] in
//          guard let self = self else { return }
//
//          label.transform = .init(scaleX: 0.75, y: 0.75)
//          label.alpha = 0
//          self.collectionView.backgroundColor = .clear
//        }) { _ in label.removeFromSuperview() }
//    }
//  }
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {
  func didAppear() {
//    guard isEmpty else { return }
//
//    emptyPublicationsView.setAnimationsEnabled(true)
//    collectionView.didAppear()
  }
  
  func didDisappear() {
//    emptyPublicationsView.setAnimationsEnabled(false)
    
//    collectionView.didDisappear()
  }

  func onRequestCompleted(_ result: Result<Bool, Error>) {
    collectionView.refreshControl?.endRefreshing()
  }
  
  @objc
  func scrollToTop() {
    isScrolledDown = false
    collectionView.scrollToTop()
  }
}

//extension ListView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//
//    }
//}

//extension ListView: BannerObservable {
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
