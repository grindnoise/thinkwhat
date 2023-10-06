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
  ///**Publishers**
  public private(set) var searchPublisher = PassthroughSubject<String, Never>()
  public let subscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
  public let unsubscribePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
  public let userprofilePublisher = CurrentValueSubject<[Userprofile]?, Never>(nil)
  
  public weak var viewInput: (ListViewInput & TintColorable)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
//  public var isOnScreen: Bool = true {
//    didSet {
//      guard oldValue != isOnScreen else { return }
//
//      collectionView.isOnScreen = isOnScreen
//
//      // Animate empty view
//      guard !emptyPublicationsView.alpha.isZero else { return }
//
//      emptyPublicationsView.setAnimationsEnabled(isOnScreen)
//    }
//  }
  
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
  private lazy var collectionView: SurveysCollectionView = {
    let instance = SurveysCollectionView(filter: viewInput!.filter, color: viewInput?.tintColor, showSeparators: true)
    
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
  private lazy var filtersCollectionView: SurveyFiltersCollectionView = {
    let instance = SurveyFiltersCollectionView(items: [
      SurveyFilterItem(main: .new,
                       additional: .period,
                       isFilterEnabled: true,
                       text: Enums.Period.month.description,
                       image: UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                       period: viewInput?.filter.period ?? .unlimited,
                       periodThreshold: .unlimited),
      SurveyFilterItem(main: .rated, additional: .disabled, text: "filter_rated"),
      SurveyFilterItem(main: .own, additional: .disabled, text: "filter_own"),
      SurveyFilterItem(main: .disabled, additional: .watchlist, text: "filter_watchlist"),
      SurveyFilterItem(main: .disabled, additional: .discussed, text: "filter_discussed"),
      SurveyFilterItem(main: .disabled, additional: .completed, text: "filter_completed"),
      SurveyFilterItem(main: .disabled, additional: .notCompleted, text: "filter_not_completed"),
      SurveyFilterItem(main: .disabled, additional: .anonymous, text: "filter_anonymous")
    ], contentInsets: .uniform(padding)
    )
    
    // Filtering
    instance.filterPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        
        self.viewInput?.filter.setBoth(main: $0.main,
                                       topic: $0.topic,
                                       userprofile: $0.userprofile,
                                       compatibility: $0.compatibility,
                                       additional: $0.additional,
                                       period: $0.period)
        
//        self.filter.setAdditional(filter: $0.additional, period: $0.period)
        self.isScrolledDown = false
        delay(seconds: 0.3) { [weak self] in
          guard let self = self else { return }
          
          self.scrollToTop()
        }
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
    instance.layer.shadowColor = UISettings.Shadows.color
    instance.layer.shadowRadius = UISettings.Shadows.radius(padding: padding)
    instance.layer.shadowOffset = .zero
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
  private var isEmpty = false {
    didSet {
      guard isEmpty != oldValue else { return }
      
      onEmptyList(isEmpty: isEmpty)
    }
  }
//  private var isSearching = false

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
    v.color = Colors.main
    v.alpha = 0
    instance.rightView = v
    instance.rightViewMode = .always
    instance.attributedPlaceholder = NSAttributedString(string: "search".localized, attributes: [
      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .footnote) as Any,
      .foregroundColor: UIColor.secondaryLabel,
    ])
    instance.delegate = self
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)
    instance.backgroundColor = .secondarySystemBackground//traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    instance.tintColor = Colors.main
    instance.addTarget(self, action: #selector(ListView.textFieldDidChange(_:)), for: .editingChanged)
    instance.returnKeyType = .done
    instance.publisher(for: \.bounds)
      .sink { rect in
        instance.cornerRadius = rect.width*0.025
        
        guard instance.insets == .zero else { return }
        
        instance.insets = UIEdgeInsets(top: instance.insets.top,
                                       left: rect.height/2.25,
                                       bottom: instance.insets.top,
                                       right: rect.height/2.25)
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
                                                    .foregroundColor: Colors.main
                                                  ]), for: .normal)
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
    
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.surveyCollectionDark : Colors.surveyCollectionLight
    if let bgLayer = scrollToTopButton.getLayer(identifier: "background") as? CAShapeLayer {
      bgLayer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
  }
}

private extension ListView {
  @MainActor
  func setupUI() {
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
    
    filtersCollectionView.setColor(viewInput?.tintColor ?? Colors.filterEnabled)
    collectionView.color = viewInput!.tintColor
    
    addSubview(contentView)
    contentView.edgesToSuperview(usingSafeArea: true)
    
    let views = [
      filtersCollectionView,
      shadowView,
    ]
  
    contentView.addSubviews(views)
    let leadingConstraint = filtersCollectionView.leadingToSuperview()
    leadingConstraint.identifier = "leading"
    filtersCollectionView.trailingToSuperview()
    filtersCollectionView.topToSuperview(offset: padding*1)
    filterViewHeight = padding*2 + "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)
    filtersCollectionView.height(filterViewHeight)
    
    addSubview(searchStack)
    searchStack.height(UINavigationController.Constants.NavBarHeightSmallState - padding)
    searchStack.trailingToLeading(of: filtersCollectionView, offset: -padding)
    searchStack.centerY(to: filtersCollectionView)
    searchStack.width(to: self, offset: -16)
    
    shadowView.topToBottom(of: filtersCollectionView, offset: padding*2)
    shadowView.leadingToSuperview(offset: padding)
    shadowView.trailingToSuperview(offset: padding)
    shadowView.bottomToSuperview(offset: -padding)
    
    background.addSubview(scrollToTopButton)
    let leading = scrollToTopButton.leading(to: background, offset: padding)
    leading.identifier = "leading"
    let constraint_2 = scrollToTopButton.topToBottom(of: background)
    constraint_2.identifier = "top"
    scrollToTopButton.size(.uniform(size: 40))
    
    background.addSubview(emptyPublicationsView)
    emptyPublicationsView.edgesToSuperview()
  }

  func onEmptyList(isEmpty: Bool) {
    guard viewInput?.searchMode == .off else { return }
  
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
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {
  func beginSearchRefreshing() {
    collectionView.beginSearchRefreshing()
  }
  
  func setSearchModeEnabled(_ enabled: Bool) {
    isScrolledDown = false
    collectionView.setSearchModeEnabled(enabled)
    
    guard let leading = filtersCollectionView.getConstraint(identifier: "leading") else { return }
    
    if enabled {
      searchCancelButton.alpha = 0
      searchCancelButton.transform = .init(scaleX: 0.5, y: 0.5)
      searchField.becomeFirstResponder()
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        leading.constant = self.filtersCollectionView.bounds.width
        self.layoutIfNeeded()
        self.emptyPublicationsView.alpha = 0
      } completion: {  _ in }
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.15, options: .curveEaseInOut) { [weak self] in
        guard let self = self else { return }
        
        self.searchCancelButton.alpha = 1
        self.searchCancelButton.transform = .identity
      } completion: {  _ in }
    } else {
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: .curveEaseInOut) { [weak self] in
        guard let self = self else { return }
        
        self.setNeedsLayout()
        leading.constant = 0
        self.layoutIfNeeded()
        self.searchCancelButton.alpha = 0
        self.searchCancelButton.transform = .init(scaleX: 0.5, y: 0.5)
        if self.isEmpty {
          self.emptyPublicationsView.alpha = 1
        }
      }
    }
  }
  
  func onSearchCompleted(_ instances: [SurveyReference], localSearch: Bool) {
    collectionView.endSearchRefreshing()
    collectionView.setSearchResult(instances)
    if !localSearch {
      setSearchSpinnerEnabled(enabled: false, animated: true)
    }
  }

  func didAppear() {
    guard isEmpty else { return }

    emptyPublicationsView.setAnimationsEnabled(true)
//    collectionView.didAppear()
  }
  
  func didDisappear() {
    emptyPublicationsView.setAnimationsEnabled(false)
    
//    collectionView.didDisappear()
  }

  func onRequestCompleted(_ result: Result<Bool, Error>) {
    collectionView.refreshControl?.endRefreshing()
  }
  
  @objc
  func scrollToTop() {
    collectionView.scrollToTop()
    toggleScrollButton(on: false) { delay(seconds: 0.3) { [weak self] in
      guard let self = self else { return }
      
      self.scrollToTopButtonAnimates = false
    }}
    isScrolledDown = false
//    delay(seconds: 0.3) { [weak self] in
//      guard let self = self else { return }
//      
//      self.isScrolledDown = false
//    }
  }
}

extension ListView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    gestureRecognizers = []
    let touch = UITapGestureRecognizer(target:self, action:#selector(ListView.hideKeyboard))
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
      collectionView.beginSearchRefreshing()
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
