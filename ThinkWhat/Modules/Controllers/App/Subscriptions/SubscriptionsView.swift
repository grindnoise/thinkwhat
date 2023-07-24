//
//  SubsciptionsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SubscriptionsView: UIView {
  
  private enum Mode {
    case User, Default
  }
  
  // MARK: - Public properties
  weak var viewInput: (SubscriptionsViewInput & TintColorable)? {
    didSet {
      guard let viewInput = viewInput else { return }
      
      setupUI()
      updatePeriodButton()
      surveysCollectionView.color = viewInput.tintColor
      
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
  public private(set) var isCardOnScreen = false
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var mode: Mode = .Default {
    didSet {
      //            guard let constraint = filterView.getConstraint(identifier: "top_1") else { return }
      
      //            setNeedsLayout()
      //            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) { [weak self] in
      //                guard let self = self else { return }
      //
      //                constraint.constant = self.mode == .User ? 20 : 0
      //                self.layoutIfNeeded()
      //            }
    }
  }
  private var indexPath: IndexPath = IndexPath(row: 0, section: 0) {
    didSet {
      print(indexPath)
    }
  }
  private var userprofile: Userprofile! {
    didSet {
      guard let userprofile = userprofile else { return }
      
//      assert(userprofile == Userprofiles.shared.current)
//      setTasks()
      viewInput?.toggleUserSelected(true)
      viewInput?.setUserprofileFilter(userprofile)
      surveysCollectionView.userprofile = userprofile
      onUserSelected(userprofile: userprofile)
      usernameLabel.text = userprofile.username//userprofile.firstNameSingleWord + (userprofile.lastNameSingleWord.isEmpty ? "" : " \(userprofile.lastNameSingleWord)")
      mode = .User
    }
  }
  private var period: Period = .AllTime {
    didSet {
      guard oldValue != period else { return }
      
      surveysCollectionView.period = period
      
      updatePeriodButton()
    }
  }
  private var isDateFilterHidden = false {
    didSet {
      guard oldValue != isDateFilterHidden else { return }
      
      toggleDateFilter(on: !isDateFilterHidden)
    }
  }
  private var isCollectionViewSetupCompleted = false
  private var needsAnimation = true
  private var isRevealed = false
  private var isEmpty = false //{
//    didSet {
//      guard isEmpty != oldValue else { return }
//
//      switchEmptyLabel(isEmpty: isEmpty)
//    }
//  }
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var filterView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)).isActive = true

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
    instance.menu = prepareMenu()
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
    instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
//    instance.setTitleColor(traitCollection.userInterfaceStyle == .dark ? .white : viewInput?.tintColor, for: .normal)
    instance.adjustsImageWhenHighlighted = false
    instance.imageEdgeInsets.left = padding
    instance.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding*2, bottom: padding, right: padding*2)
    instance.semanticContentAttribute = .forceRightToLeft
    instance.setImage(UIImage(systemName: ("slider.horizontal.3"), withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private var emptyPublicationsView: EmptyPublicationsView?
  private lazy var surveysCollectionView: SurveysCollectionView = {
    let instance = SurveysCollectionView(category: .Subscriptions)
    
    //Pagination #1
    instance.paginationPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { [unowned self] in
        guard let source = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: source, dateFilter: period, topic: nil, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Pagination #2
    instance.paginationByTopicPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { [unowned self] in
        guard let topic = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .Topic,
                                            dateFilter: period,
                                            topic: topic,
                                            userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Pagination #3
    instance.paginationByOwnerPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { [unowned self] in
        guard let userprofile = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .ByOwner,
                                            dateFilter: period,
                                            topic: nil,
                                            userprofile: userprofile)
      }
      .store(in: &subscriptions)
    
    //Refresh #1
    instance.refreshPublisher
      .sink { [unowned self] in
        guard let category = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: category, dateFilter: period, topic: nil, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Refresh #2
    instance.refreshByTopicPublisher
      .sink { [unowned self] in
        guard let topic = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .Topic, dateFilter: period, topic: topic, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Refresh #3
    instance.refreshByOwnerPublisher
      .sink { [unowned self] in
        guard let userprofile = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .ByOwner,
                                            dateFilter: period,
                                            topic: nil,
                                            userprofile: userprofile)
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
    
    instance.shareSubject.sink {
      print($0)
    } receiveValue: { [weak self] in
      guard let self = self,
            let value = $0
      else { return }
      
      self.viewInput?.share(value)
    }.store(in: &self.subscriptions)
      
      instance.claimSubject
        .sink { [weak self] in
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
        }
        .store(in: &self.subscriptions)
    
    instance.userprofilePublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0
        else { return }
        
        self.viewInput?.openUserprofile(userprofile)
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
        guard let self = self else { return }
        
        self.isDateFilterHidden = $0
        //                self.toggleDateFilter(on: !$0)
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
          self.emptyPublicationsView = EmptyPublicationsView(mode: .Subscriptions,
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
          self.filterView.alpha = zero ? 0 : 1
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
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
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
    instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground//.secondarySystemBackground.withAlphaComponent(0.75)
    //        instance.addEquallyTo(to: shadowView)
    surveysCollectionView.place(inside: instance)
    instance.publisher(for: \.bounds)
      .sink { rect in
        instance.cornerRadius = rect.width * 0.05
      }
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
  
  @IBOutlet var contentView: UIView!
  
  
  
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
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

//    avatar.isShadowed = traitCollection.userInterfaceStyle != .dark
    userView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
    periodButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
    periodButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
    updatePeriodButton()
    
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
    subscriptionButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    subscriptionButton.getSubview(type: UIButton.self)?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemFill : .systemBackground
    filterView.getSubview(type: UIView.self, identifier: "shadow")?.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
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
    
    // We need to show filterView on new subscription when view is not on screen
    userprofile.subscriptionsPublisher
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: {
        if case .failure(let error) = $0 {
#if DEBUG
          print(error)
#endif
        }
      }, receiveValue: { [weak self] subscribers in
        guard let self = self,
              let viewInput = self.viewInput,
              !viewInput.isOnScreen
        else { return }

        self.toggleDateFilter(on: true)
      })
      .store(in: &subscriptions)
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
    
    addSubview(contentView)
    
    var views = [
      topView,
      filterView,
      shadowView,
    ]
  
    contentView.addSubviews(views)
    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      //            filterView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
      filterView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
      filterView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
      //            shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 10),
      //            shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
      //            shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
      //            shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
    ])
    
//    periodButton.backgroundColor = viewInput!.tintColor
    userView.alpha = 0
    
    let shadowLeading = shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8)
    shadowLeading.identifier = "leading"
    shadowLeading.isActive = true
    
    let shadowTrailing = shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8)
    shadowTrailing.identifier = "trailing"
    shadowTrailing.isActive = true
    
    let shadowBottom = shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
    shadowBottom.identifier = "bottom"
    shadowBottom.isActive = true
    
    let topConstraint_1 = filterView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8)
    topConstraint_1.identifier = "top_1"
    topConstraint_1.isActive = true
    
    let topConstraint_2 = shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 16)
    topConstraint_2.identifier = "top"
    topConstraint_2.isActive = true
    
    
    setNeedsLayout()
    layoutIfNeeded()
    filterViewHeight = periodButton.bounds.height
    let constraint = filterView.heightAnchor.constraint(equalToConstant: filterViewHeight)
    constraint.identifier = "height"
    constraint.isActive = true
    constraint.priority = .defaultLow
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
          let constraint1 = filterView.getConstraint(identifier: "top_1"),
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
    toggleDateFilter(on: true)
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
        constraint.constant = self.filterView.alpha == 1 ? 16 : 8
        constraint1.constant = self.filterView.alpha == 1 ? 16 : 8//8
        topViewConstraint.constant = topViewHeight * 1.5
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
    guard let userprofile = userprofile else { return }
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
    let buttonText = "publications".localized.uppercased() + ": " + "per_\(period.rawValue.lowercased())".localized.uppercased()
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
  
  @MainActor
  func toggleDateFilter(on: Bool, animated: Bool = true) {
    guard let heightConstraint = filterView.getConstraint(identifier: "height"),
          let constraint1 = filterView.getConstraint(identifier: "top_1"),
          let constraint2 = shadowView.getConstraint(identifier: "top")
            //              let constraint3 = shadowView.getConstraint(identifier: "leading"),
            //              let constraint4 = shadowView.getConstraint(identifier: "trailing")
            //              let constraint5 = shadowView.getConstraint(identifier: "bottom")
    else { return }
    
    setNeedsLayout()
    
    guard animated else {
      filterView.alpha = on ? 1 : 0
      filterView.transform = on ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
      constraint1.constant = on ? 16 : mode == .Default ? 0 : 10
      constraint2.constant = on ? 16 : 0
      heightConstraint.constant = on ? filterViewHeight : 0
      layoutIfNeeded()
      
      return
    }
    UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) { [weak self] in
      guard let self = self else { return }
      
      //            self.shadowView.layer.shadowRadius = on ? 5 : self.mode == .Default ? 5 : 2.5
      //            self.background.cornerRadius = self.background.bounds.width*(on ? 0.05 : 0.035)
      self.filterView.alpha = on ? 1 : 0
      self.filterView.transform = on ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
      constraint1.constant = on ? 16 : self.mode == .Default ? 0 : 10
      constraint2.constant = on ? 16 : 0
      //            constraint3.constant = on ? 8 : 4
      //            constraint4.constant = on ? -8 : -4
      //            constraint5.constant = on ? -8 : -4
      heightConstraint.constant = on ? self.filterViewHeight : 0
      self.layoutIfNeeded()
    }
  }
  
//  func switchEmptyLabel(isEmpty: Bool) {
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
//          self.surveysCollectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .clear
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
//          self.surveysCollectionView.backgroundColor = .clear
//        }) { _ in label.removeFromSuperview() }
//    }
//  }
}

extension SubscriptionsView: SubsciptionsControllerOutput {
  func didAppear() {
    guard let current = Userprofiles.shared.current, current.subscriptions.isEmpty else { return }
    
    emptyPublicationsView?.setAnimationsEnabled(true)
  }
  
  func didDisappear() {
//    guard let current = Userprofiles.shared.current, !current.subscriptions.isEmpty else { return }
    
    emptyPublicationsView?.setAnimationsEnabled(false)
  }
  
  func hideUserCard(_ completion: Closure? = nil) {
    mode = .Default
    surveysCollectionView.category = .Subscriptions
    guard let viewInput = viewInput,
          viewInput.isOnScreen,
          let cell = self.feedCollectionView.cellForItem(at: self.indexPath) as? UserprofileCell,
//          let subview = userView.getSubview(type: UIView.self, identifier: "opaque"),
          let constraint = topView.getConstraint(identifier: "height"),
          let userprofile = userprofile
    else {
//      guard let subview = userView.getSubview(type: UIView.self, identifier: "opaque"),
//            let constraint = subview.getConstraint(identifier: "trailing")
//      else { return }
      
      avatar.alpha = 0
      isCardOnScreen = false
//      constraint.constant = 16
      if let cells = feedCollectionView.visibleCells.filter({ $0.isKind(of: UserprofileCell.self )}) as? [UserprofileCell] {
        cells.forEach { $0.avatar.alpha = 1 }
      }
      
      return
    }
    
//    mode = .Default
//    surveysCollectionView.category = .Subscriptions
    toggleDateFilter(on: true)
    
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
    surveysCollectionView.endRefreshing()
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
