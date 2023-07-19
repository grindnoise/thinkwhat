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
      guard !viewInput.isNil else { return }
      
      setupUI()
      updatePeriodButton()
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = [] {
    didSet {
      guard let viewInput = viewInput else { return }
      
      if #available(iOS 15, *) {
        if !periodButton.configuration.isNil {
          periodButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in return viewInput.tintColor }
        }
      } else {
        periodButton.imageView?.tintColor = viewInput.tintColor
        periodButton.tintColor = viewInput.tintColor
      }
    }
  }
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var filterView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear

    let shadowView = UIView.opaque()
    shadowView.layer.masksToBounds = false
    shadowView.accessibilityIdentifier = "shadow"
    shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    shadowView.layer.shadowOffset = .zero
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.publisher(for: \.bounds)
      .sink {
        shadowView.layer.shadowRadius = $0.height/8
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2.25).cgPath
      }
      .store(in: &subscriptions)

    periodButton.placeInCenter(of: instance)
    
    shadowView.translatesAutoresizingMaskIntoConstraints = false
        instance.insertSubview(shadowView, belowSubview: periodButton)
    
    NSLayoutConstraint.activate([
      shadowView.leadingAnchor.constraint(equalTo: periodButton.leadingAnchor),
      shadowView.topAnchor.constraint(equalTo: periodButton.topAnchor),
      shadowView.trailingAnchor.constraint(equalTo: periodButton.trailingAnchor),
      shadowView.bottomAnchor.constraint(equalTo: periodButton.bottomAnchor),
    ])

    return instance
  }()
  private lazy var periodButton: UIButton = {
    let instance = UIButton()
    instance.titleLabel?.numberOfLines = 1
    instance.showsMenuAsPrimaryAction = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
    instance.imageEdgeInsets.left = padding
    instance.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding*2, bottom: padding, right: padding*2)
    instance.semanticContentAttribute = .forceRightToLeft
    instance.setImage(UIImage(systemName: ("slider.horizontal.3"), withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()

  private lazy var surveysCollectionView: SurveysCollectionView = {
    let instance = SurveysCollectionView(category: .Search)
    instance.backgroundColor = .clear
    instance.alpha = 0
    instance.isOnScreen = false
    
    //Pagination #2
    let paginationByTopicPublisher = instance.paginationByTopicPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
    
    paginationByTopicPublisher
      .sink { [unowned self] in
        guard let topic = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(dateFilter: period, topic: topic)
      }
      .store(in: &subscriptions)
    
    //Refresh #2
    instance.refreshByTopicPublisher
      .sink { [unowned self] in
        guard let topic = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(dateFilter: period, topic: topic)
      }
      .store(in: &subscriptions)
    
    //Row selected
    instance.rowPublisher
      .sink { [unowned self] in
        guard let instance = $0
        else { return }
        
        self.viewInput?.onSurveyTapped(instance)
      }
      .store(in: &subscriptions)
    
    //Update stats (exclude refs)
    instance.updateStatsPublisher
      .sink { [weak self] in
        guard let self = self,
              let instances = $0
        else { return }
        
        self.viewInput?.updateSurveyStats(instances)
      }
      .store(in: &subscriptions)
    
    //Add to watch list
    instance.watchSubject.sink {
      print($0)
    } receiveValue: { [weak self] in
      guard let self = self,
            let value = $0
      else { return }
      
      self.viewInput?.addFavorite(value)
    }.store(in: &self.subscriptions)
    
    instance.shareSubject
      .sink { [weak self] in
        guard let self = self,
              let value = $0
        else { return }
        
        self.viewInput?.share(value)
      }
      .store(in: &self.subscriptions)
    
    instance.claimSubject.sink {
      print($0)
    } receiveValue: { [weak self] in
      guard let self = self,
            let surveyReference = $0
      else { return }
      
      let popup = NewPopup(padding: self.padding,
                           contentPadding: .uniform(size: self.padding*2))
      let content = ClaimPopupContent(parent: popup,
                                      surveyReference: surveyReference)
      content.$claim
        .filter { !$0.isNil }
        .sink { [unowned self] in self.viewInput?.claim($0!) }
        .store(in: &popup.subscriptions)
      popup.setContent(content)
      popup.didDisappearPublisher
        .sink { _ in popup.removeFromSuperview() }
        .store(in: &self.subscriptions)
      
      //            self.viewInput?.addFavorite(surveyReference: value)
    }.store(in: &self.subscriptions)
    
    instance.userprofilePublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0
        else { return }
        
        self.viewInput?.openUserprofile(userprofile)
      }
      .store(in: &self.subscriptions)
    
    instance.settingsTapPublisher
      .sink { [weak self] in
        guard let self = self,
              !$0.isNil
        else { return }
        
        self.viewInput?.openSettings()
      }
      .store(in: &self.subscriptions)
    
    instance.subscribePublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0
        else { return }
        
        self.viewInput?.subscribe(to: userprofile)
      }
      .store(in: &self.subscriptions)
    
    instance.unsubscribePublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0
        else { return }
        
        self.viewInput?.unsubscribe(from: userprofile)
      }
      .store(in: &self.subscriptions)
    
    instance.scrollPublisher
      .sink { [weak self] in
        guard let self = self,
              self.viewInput?.mode == .Topic
        else { return }
        
//        self.toggleDateFilter(on: !$0)
        self.isDateFilterOnScreen = !$0
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var collectionView: TopicsCollectionView = {
    let instance = TopicsCollectionView()
    instance.backgroundColor = .clear
    
    instance.touchSubject
      .sink { [weak self] in
        guard let self = self,
              let dict = $0,
              let point = dict.values.first,
              let topic = dict.keys.first
        else { return }
        
        self.viewInput?.onTopicSelected(topic)
        self.viewInput?.navigationController?.setBarTintColor(topic.tagColor)//.setNavigationBarTintColor(topic.tagColor)
        self.touchLocation = point
        self.surveysCollectionView.topic = topic
        self.surveysCollectionView.isOnScreen = true
        self.isDateFilterOnScreen = true
        //      self.toggleDateFilter(on: true)
        self.setBackgroundColor()//.secondarySystemBackground)
        self.surveysCollectionView.alpha = 1
        //            self.surveysCollectionView.backgroundColor = self.background.backgroundColor
        //      self.reveal(present: true, location: point, view: self.surveysCollectionView, color: self.surveysCollectionView.topic!.tagColor, fadeView: self.collectionView, duration: 0.35)//, animateOpacity: false)
        Animations.reveal(present: true,
                          location: point,
                          view: self.surveysCollectionView,
                          fadeView: self.collectionView,
                          color: self.surveysCollectionView.topic!.tagColor,
                          duration: 0.35,
                          delegate: self)
        if #available(iOS 15, *) {
          self.periodButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in return self.topic?.tagColor ?? Colors.main }
          self.periodButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outcoming = incoming
            outcoming.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3)
            outcoming.foregroundColor = self.topic?.tagColor
            return outcoming
          }
        } else {
          self.periodButton.imageView?.tintColor = self.topic?.tagColor
          self.periodButton.tintColor = self.topic?.tagColor
        }
      }.store(in: &subscriptions)
    
    return instance
  }()
  private lazy var background: UIView = {
    let instance = UIView()
    instance.accessibilityIdentifier = "bg"
    instance.layer.masksToBounds = true
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    instance.publisher(for: \.bounds)
      .sink { [unowned self] rect in
        guard self.filterView.alpha != 0 else { return }
        
        instance.cornerRadius = rect.width *  0.05
      }
      .store(in: &subscriptions)
    
    collectionView.addEquallyTo(to: instance)
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
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .throttle(for: .seconds(0.3), scheduler: DispatchQueue.main, latest: false)
      .filter { $0 != .zero }
      .sink {
        let path = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.05).cgPath
        instance.layer.add(Animations.get(property: .ShadowPath,
                                          fromValue: instance.layer.shadowPath as Any,
                                          toValue: path,
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
  private lazy var emptyLabel: UILabel = {
    let label = UILabel()
    label.accessibilityIdentifier = "emptyLabel"
    label.backgroundColor = .clear
    label.alpha = 0
    label.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .title3)
    label.text = "publications_not_found".localized// + "\n⚠︎"
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.textAlignment = .center
    
    return label
  }()
  private lazy var filterViewHeight: CGFloat = .zero
  ///**Logic**
  private var touchLocation: CGPoint = .zero
  private var period: Period = .AllTime {
    didSet {
      guard oldValue != period else { return }
      
      surveysCollectionView.period = period
      updatePeriodButton()
    }
  }
  private var isDateFilterOnScreen = false {
    didSet {
      guard oldValue != isDateFilterOnScreen else { return }
      
      toggleDateFilter(on: isDateFilterOnScreen)
    }
  }
  private var isEmpty = false {
    didSet {
      guard isEmpty != oldValue else { return }
      
      switchEmptyLabel(isEmpty: isEmpty)
    }
  }
  
  
  
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
    
//    setupUI()
    guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
    
    //        let zeroSized = UIView()
    //        zeroSized.backgroundColor = .clear
    //        zeroSized.heightAnchor.constraint(equalToConstant: 0).isActive = true
    
    addSubview(contentView)
  }
  
  
  
  // MARK: - Overrriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    collectionView.backgroundColor = .clear
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    
//    if #available(iOS 15, *) {
//      periodButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    } else {
//      periodButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
    periodButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
    periodButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
    updatePeriodButton()
    setBackgroundColor()
    
    filterView.getSubview(type: UIView.self, identifier: "shadow")?.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
}

// MARK: - Private
private extension TopicsView {
  @MainActor
  func setupUI() {
    contentView.addSubview(filterView)
    contentView.addSubview(shadowView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    filterView.translatesAutoresizingMaskIntoConstraints = false
    shadowView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      filterView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
      filterView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
    ])
    
    let shadowLeading = shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10)
    shadowLeading.identifier = "leading"
    shadowLeading.isActive = true
    
    let shadowTrailing = shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
    shadowTrailing.identifier = "trailing"
    shadowTrailing.isActive = true
    
    let shadowBottom = shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
    shadowBottom.identifier = "bottom"
    shadowBottom.isActive = true
    
    let topConstraint_1 = filterView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10)
    topConstraint_1.identifier = "top_1"
    topConstraint_1.isActive = true
    
    let topConstraint_2 = shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 0)
    topConstraint_2.identifier = "top"
    topConstraint_2.isActive = true
    
    setNeedsLayout()
    layoutIfNeeded()
    filterViewHeight = periodButton.bounds.height
    let constraint = filterView.heightAnchor.constraint(equalToConstant: filterViewHeight)
    constraint.identifier = "height"
    constraint.isActive = true
    constraint.priority = .defaultLow

    //        let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
    //        constraint.identifier = "height"
    //        constraint.isActive = true
    filterView.alpha = 0
    filterView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    toggleDateFilter(on: false, animated: false)
  }
  
//  func reveal(present: Bool, location: CGPoint = .zero, view revealView: UIView, color: UIColor, fadeView: UIView, duration: TimeInterval, animateOpacity: Bool = true) {
//
//    let circlePathLayer = CAShapeLayer()
//
//    var circleFrameTouchPosition: CGRect {
//      return CGRect(origin: location, size: .zero)
//    }
//
//    var circleFrameTopLeft: CGRect {
//      return CGRect.zero
//    }
//
//    func circlePath(_ rect: CGRect) -> UIBezierPath {
//      return UIBezierPath(ovalIn: rect)
//    }
//
//    circlePathLayer.frame = revealView.bounds
//    circlePathLayer.path = circlePath(location == .zero ? circleFrameTopLeft : circleFrameTouchPosition).cgPath
//    revealView.layer.mask = circlePathLayer
//
//    let radiusInset =  sqrt(revealView.bounds.height*revealView.bounds.height + revealView.bounds.width*revealView.bounds.width + location.x*location.x + location.y*location.y)
//
//    let outerRect = circleFrameTouchPosition.insetBy(dx: -radiusInset, dy: -radiusInset)
//
//    let toPath = UIBezierPath(ovalIn: outerRect).cgPath
//
//    let fromPath = circlePathLayer.path
//
//    let anim = Animations.get(property: .Path,
//                              fromValue: present ? fromPath as Any : toPath,
//                              toValue: !present ? fromPath as Any : toPath,
//                              duration: duration,
//                              delay: 0,
//                              repeatCount: 0,
//                              autoreverses: false,
//                              timingFunction: present ? .easeInEaseOut : .easeOut,
//                              delegate: self,
//                              isRemovedOnCompletion: true,
//                              completionBlocks: [{
//      revealView.layer.mask = nil
//      if !present {
//        //                circlePathLayer.path = CGPath(rect: .zero, transform: nil)
//        revealView.layer.opacity = 0
//        //////                animatedView.alpha = 0
//        ////                            animatedView.layer.mask = nil
//      }
//    }])
//
//    circlePathLayer.add(anim, forKey: "path")
//    circlePathLayer.path = !present ? fromPath : toPath
//
//    let colorLayer = CALayer()
//    if let collectionView = fadeView as? UICollectionView {
//      colorLayer.frame = CGRect(origin: .zero, size: CGSize(width: collectionView.bounds.width, height: 3000))
//    } else {
//      colorLayer.frame = fadeView.layer.bounds
//    }
//    colorLayer.backgroundColor = color.cgColor
//    colorLayer.opacity = present ? 0 : 1
//
//    fadeView.layer.addSublayer(colorLayer)
//
//    let opacityAnim = Animations.get(property: .Opacity, fromValue: present ? 0 : 1, toValue: present ? 1 : 0, duration: duration*(present ? 1.15 : 1.35), timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, completionBlocks: [{
//      colorLayer.removeFromSuperlayer()
//    }])
//    colorLayer.add(opacityAnim, forKey: nil)
//    colorLayer.opacity = !present ? 0 : 1
//
//    if #available(iOS 15, *) {
//      if !periodButton.configuration.isNil {
//        periodButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in return color }
//        periodButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
//          var outcoming = incoming
//          outcoming.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3)
//          outcoming.foregroundColor = color
//          return outcoming
//        }
//      }
//    } else {
//      periodButton.imageView?.tintColor = color
//      periodButton.tintColor = color
//    }
//  }
  
  func setBackgroundColor() {
    UIView.animate(withDuration: 0.15) { [weak self] in
      guard let self = self else { return }
      
      self.background.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
      self.surveysCollectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
    }
  }
  
  @MainActor
  func toggleDateFilter(on: Bool, animated: Bool = true) {
    guard let heightConstraint = filterView.getConstraint(identifier: "height"),
          let constraint1 = filterView.getConstraint(identifier: "top_1"),
          let constraint2 = filterView.getConstraint(identifier: "top")
    else { return }
    
    setNeedsLayout()
    guard animated else {
      filterView.alpha = on ? 1 : 0
      filterView.transform = on ? .identity : CGAffineTransform(scaleX: 0.75, y: 0.75)
      constraint1.constant = on ? 16 : 0
      constraint2.constant = on ? 16 : 0
      heightConstraint.constant = on ? filterViewHeight : 0
      layoutIfNeeded()
      
      return
    }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      self.filterView.alpha = on ? 1 : 0
      self.filterView.transform = on ? .identity : CGAffineTransform(scaleX: 0.75, y: 0.75)
      constraint1.constant = on ? 16 : 8
      constraint2.constant = on ? 16 : 8
      heightConstraint.constant = on ? self.filterViewHeight : 0
      self.layoutIfNeeded()
    }
  }
  
  @MainActor
  func prepareMenu(zeroSubscriptions: Bool = false) -> UIMenu {
    let perDay: UIAction = .init(title: "per_\(Period.PerDay.rawValue)".localized.lowercased(),
                                 image: nil,
                                 identifier: nil,
                                 discoverabilityTitle: nil,
                                 attributes: .init(),
                                 state: period == .PerDay ? .on : .off,
                                 handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.period = .PerDay
    })
    
    let perWeek: UIAction = .init(title: "per_\(Period.PerWeek.rawValue)".localized.lowercased(),
                                  image: nil,
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .init(),
                                  state: period == .PerWeek ? .on : .off,
                                  handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.period = .PerWeek
    })
    
    let perMonth: UIAction = .init(title: "per_\(Period.PerMonth.rawValue)".localized.lowercased(),
                                   image: nil,
                                   identifier: nil,
                                   discoverabilityTitle: nil,
                                   attributes: .init(),
                                   state: period == .PerMonth ? .on : .off,
                                   handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.period = .PerMonth
    })
    
    let allTime: UIAction = .init(title: "per_\(Period.AllTime.rawValue)".localized.lowercased(),
                                  image: nil,
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .init(),
                                  state: period == .AllTime ? .on : .off,
                                  handler: { [weak self] _ in
      guard let self = self else { return }
      
      self.period = .AllTime
    })
    
    return UIMenu(title: "",//"publications_per".localized,
                  image: nil,
                  identifier: nil,
                  options: .init(),
                  children: [
                    perDay,
                    perWeek,
                    perMonth,
                    allTime
                  ])
  }
  
  @MainActor
  func updatePeriodButton() {
    periodButton.menu = prepareMenu()
    let buttonText = "publications".localized.uppercased() + ": " +  "per_\(period.rawValue.lowercased())".localized.uppercased()
    let attrString = NSMutableAttributedString(string: buttonText,
                                               attributes: [
                                                .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.white : viewInput?.tintColor as Any,
                                               ])
    periodButton.setAttributedTitle(attrString, for: .normal)
    let attrString1 = NSMutableAttributedString(string: buttonText,
                                               attributes: [
                                                .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                .foregroundColor: traitCollection.userInterfaceStyle == .dark ? UIColor.secondaryLabel : viewInput?.tintColor as Any,
                                               ])
    periodButton.setAttributedTitle(attrString1, for: .highlighted)
  }
  
  func switchEmptyLabel(isEmpty: Bool) {
    guard viewInput?.mode != .Default else { return }
    
    if isEmpty {
      emptyLabel.place(inside: shadowView,
                  insets: .uniform(size: self.padding*2))
      emptyLabel.transform = .init(scaleX: 0.75, y: 0.75)
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          self.emptyLabel.transform = .identity
          self.emptyLabel.alpha = 1
          self.collectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .clear
        }) { _ in }
    } else {
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          self.emptyLabel.transform = .init(scaleX: 0.75, y: 0.75)
          self.emptyLabel.alpha = 0
          self.collectionView.backgroundColor = .clear
        }) { _ in self.emptyLabel.removeFromSuperview() }
    }
  }
}

// MARK: - Controller Output
extension TopicsView: TopicsControllerOutput {
  var topic: Topic? { surveysCollectionView.topic }
  
  func setTopicMode(_ topic: Topic) {
    UIView.animate(withDuration: 0.2) { [unowned self] in
      if self.isEmpty {
        self.emptyLabel.alpha = 1
      }
    }
    surveysCollectionView.topic = topic
  }
  
  
  func beginSearchRefreshing() {
    surveysCollectionView.beginSearchRefreshing()
  }

  func onDefaultMode(color: UIColor? = nil) {
    UIView.animate(withDuration: 0.2) { [unowned self] in
      if self.isEmpty {
        self.emptyLabel.alpha = 0
      }
    }
    surveysCollectionView.isOnScreen = false
    surveysCollectionView.alpha = 1
    Animations.reveal(present: false,
                      location: CGPoint(x: bounds.maxX, y: bounds.minY)/*touchLocation*/,
                      view: surveysCollectionView,
                      fadeView: collectionView,
                      color: color ?? surveysCollectionView.topic!.tagColor,
                      duration: 0.3,
                      delegate: self)
    setBackgroundColor()//traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground)//)
//    toggleDateFilter(on: false)
    isDateFilterOnScreen = false
  }
  
  func onSearchMode() {
    guard let viewInput = viewInput else { return }
    
    surveysCollectionView.isOnScreen = false
    surveysCollectionView.category = .Search
    surveysCollectionView.color = viewInput.mode == .TopicSearch ? (topic.isNil ? .systemGray4 : topic!.tagColor) : viewInput.tintColor
    surveysCollectionView.alpha = 1
    surveysCollectionView.backgroundColor = background.backgroundColor
    touchLocation = CGPoint(x: bounds.maxX,
                            y: bounds.minY)
    
    guard viewInput.mode == .GlobalSearch else { return }
    
    Animations.reveal(present: true,
                      location: touchLocation,
                      view: surveysCollectionView,
                      fadeView: collectionView,
                      color: viewInput.tintColor,
                      duration: 0.35,
                      delegate: self)
  }
  
  func onSearchCompleted(_ instances: [SurveyReference]) {
    surveysCollectionView.endSearchRefreshing()
    surveysCollectionView.fetchResult = instances
  }
}

extension TopicsView: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
      completionBlocks.forEach{ $0() }
    } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
      initialLayer.path = path as! CGPath
      if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
        completionBlock()
      }
    }
  }
}
