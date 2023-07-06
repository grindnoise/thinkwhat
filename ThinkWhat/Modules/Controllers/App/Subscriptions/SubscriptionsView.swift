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
      usernameLabel.text = userprofile.firstNameSingleWord + (userprofile.lastNameSingleWord.isEmpty ? "" : " \(userprofile.lastNameSingleWord)")
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
  private var isEmpty = false {
    didSet {
      guard isEmpty != oldValue else { return }
      
      switchEmptyLabel(isEmpty: isEmpty)
    }
  }
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var filterView: UIView = {
    let instance = UIView()
    instance.backgroundColor = .clear
//    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Rubik.SemiBold, size: 14)!)).isActive = true

    let shadowView = UIView.opaque()
    shadowView.layer.masksToBounds = false
    shadowView.accessibilityIdentifier = "shadow"
    shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.35).cgColor
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
    instance.imageEdgeInsets.left = padding
    instance.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding*2, bottom: padding, right: padding*2)
    instance.semanticContentAttribute = .forceRightToLeft
    instance.setImage(UIImage(systemName: ("slider.horizontal.3"), withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var emptySubscriptionsView: EmptySubscriptionsView = { EmptySubscriptionsView() }()
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
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.isEmpty = $0
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
    instance.dataItemsCountPublisher
      .sink { [weak self] in
        guard let self = self,
              let isEmpty = $0
        else { return }
        
        self.viewInput?.onSubcriptionsCountEvent(zeroSubscriptions: isEmpty)
        self.emptySubscriptionsView.place(inside: self)
        if isEmpty {
          self.emptySubscriptionsView.addEquallyTo(to: self)
          self.emptySubscriptionsView.transform = .init(scaleX: 0.75, y: 0.75)
        }
        
        UIView.animate(
          withDuration: 0.4,
          delay: 0,
          usingSpringWithDamping: 0.8,
          initialSpringVelocity: 0.3,
          options: [.curveEaseInOut],
          animations: { [weak self] in
            guard let self = self else { return }
            
          self.emptySubscriptionsView.alpha =  isEmpty ? 1 : 0
          self.emptySubscriptionsView.transform = isEmpty ? .identity : .init(scaleX: 0.75, y: 0.75)
          self.shadowView.alpha = isEmpty ? 0 : 1
          self.filterView.alpha = isEmpty ? 0 : 1
        }) { _ in
          if !isEmpty { self.emptySubscriptionsView.removeFromSuperview() }
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
    instance.isShadowed = traitCollection.userInterfaceStyle != .dark
    
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
  private lazy var profileButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self, action: #selector(self.onProfileButtonTapped), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.title = "open_userprofile".localized.uppercased()
      config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [unowned self] incoming in
        var outgoing = incoming
        outgoing.foregroundColor = Colors.System.Purple.rawValue//self.traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
        outgoing.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)
        return outgoing
      }
      config.baseBackgroundColor = Colors.System.Purple.rawValue.withAlphaComponent(0.15)//traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR.withAlphaComponent(0.15) : .systemBlue.withAlphaComponent(0.15)
      config.cornerStyle = .small
      config.buttonSize = .mini
      config.contentInsets.leading = 4
      config.contentInsets.top = 2
      config.contentInsets.bottom = 2
      config.contentInsets.trailing = 4
      config.imagePlacement = .trailing
      config.imagePadding = 4.0
      config.imageColorTransformer = UIConfigurationColorTransformer { _ in return Colors.System.Purple.rawValue }//[unowned self] _ in return self.traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue }
      config.image = UIImage(systemName: "person.fill",
                             withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
      instance.configuration = config
    } else {
      let attrString = NSMutableAttributedString(string: "open_userprofile".localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
        NSAttributedString.Key.foregroundColor: Colors.System.Purple.rawValue//traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
      ])
      instance.setAttributedTitle(attrString, for: .normal)
      instance.semanticContentAttribute = .forceRightToLeft
      instance.setImage(UIImage(systemName: "person.fill",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                        for: .normal)
      instance.tintColor = Colors.System.Purple.rawValue//traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
      instance.imageEdgeInsets.left = 4.0
    }
    
    return instance
  }()
  private lazy var subscriptionButton: UIButton = {
    let instance = UIButton()
    instance.addTarget(self, action: #selector(self.unsubscribe), for: .touchUpInside)
    
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.title = "unsubscribe".localized.uppercased()
      config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.foregroundColor = UIColor.systemRed
        outgoing.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote)
        return outgoing
      }
      config.baseBackgroundColor = .systemRed.withAlphaComponent(0.15)
      config.cornerStyle = .small
      config.buttonSize = .mini
      config.contentInsets.leading = 4
      config.contentInsets.top = 2
      config.contentInsets.bottom = 2
      config.contentInsets.trailing = 4
      config.imagePlacement = .trailing
      config.imagePadding = 4.0
      config.activityIndicatorColorTransformer = UIConfigurationColorTransformer { _ in return .systemRed }
      config.imageColorTransformer = UIConfigurationColorTransformer { _ in return .systemRed }
      config.image = UIImage(systemName: "hand.raised.slash.fill",
                             withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
      instance.configuration = config
      //            instance.publisher(for: \.bounds, options: .new)
      //                .sink { rect in
      //                    instance.cornerRadius = rect.height/2.25
      //                }
      //                .store(in: &subscriptions)
    } else {
      let attrString = NSMutableAttributedString(string: "unsubscribe".localized.uppercased(), attributes: [
        NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
        NSAttributedString.Key.foregroundColor: UIColor.systemRed
      ])
      instance.setAttributedTitle(attrString, for: .normal)
      instance.semanticContentAttribute = .forceRightToLeft
      instance.setImage(UIImage(systemName: "hand.raised.slash.fill",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                        for: .normal)
      instance.tintColor = .systemRed
      instance.imageEdgeInsets.left = 4.0
    }
    
    return instance
  }()
  private lazy var userStack: UIStackView = {
    let nested = UIStackView(arrangedSubviews: [
      usernameLabel,
      profileButton,
      subscriptionButton,
      UIView.opaque()
    ])
    nested.alignment = .leading
    nested.axis = .vertical
    nested.spacing = 4
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
    opaque.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.3).isActive = true
    avatar.translatesAutoresizingMaskIntoConstraints = false
    avatar.centerXAnchor.constraint(equalTo: opaque.centerXAnchor).isActive = true
    avatar.centerYAnchor.constraint(equalTo: opaque.centerYAnchor).isActive = true
    avatar.leadingAnchor.constraint(equalTo: opaque.leadingAnchor).isActive = true
    avatar.trailingAnchor.constraint(equalTo: opaque.trailingAnchor).isActive = true
    
    return instance
//    let opaque = UIView()
//    opaque.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
//
//    let instance = UIStackView(arrangedSubviews: [
//      usernameLabel,
//      profileButton,
//      subscriptionButton,
//      opaque
//    ])
//    instance.alignment = .leading
//    instance.axis = .vertical
//    instance.spacing = 4
//    instance.accessibilityIdentifier = "userStack"
//
//    return instance
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
    
    //        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .label : .darkGray
    //        userView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    if #available(iOS 15, *) {
      periodButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    } else {
//      periodButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
      let attrString_1 = NSMutableAttributedString(string: "open_userprofile".localized.uppercased(),
                                                   attributes: [
                                                    .font: UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .footnote) as Any,
                                                    .foregroundColor: Colors.main
      ])
      profileButton.setAttributedTitle(attrString_1, for: .normal)
    }
    avatar.isShadowed = traitCollection.userInterfaceStyle != .dark
    userView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .black : .secondarySystemBackground
    periodButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .white
    periodButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : Colors.main
    updatePeriodButton()
    
    filterView.getSubview(type: UIView.self, identifier: "shadow")?.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    
    guard let background = userView.getSubview(type: UIView.self, identifier: "background") else { return }
    
    background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
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
          if #available(iOS 15, *), !self.subscriptionButton.configuration.isNil {
            self.subscriptionButton.configuration!.showsActivityIndicator = false
          } else {
            guard let imageView = self.subscriptionButton.imageView,
                  let indicator = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator")
            else { return }
            
            indicator.removeFromSuperview()
            imageView.tintColor = .systemRed
          }
          delayAsync(delay: 0.45) { [unowned self] in self.feedCollectionView.removeItem(unsubscribed) }
        } else {
          self.feedCollectionView.removeItem(unsubscribed)
          self.feedCollectionView.alpha = 1
          self.userView.alpha = 0
        }
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
    
    tasks.append(Task {@MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionOperationFailure) {
        guard let self = self,
              let userprofile = notification.object as? Userprofile,
              self.userprofile == userprofile
        else { return }
        
        if #available(iOS 15, *), !self.subscriptionButton.configuration.isNil {
          self.subscriptionButton.configuration!.showsActivityIndicator = false
        } else {
          guard let imageView = self.subscriptionButton.imageView,
                let indicator = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator")
          else { return }
          
          indicator.removeFromSuperview()
          imageView.tintColor = .systemRed
        }
      }
    })
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
    func animateStackView() {
      delayAsync(delay: 0.075) { [weak self] in
        guard let self = self else { return }
        
        self.isCardOnScreen = true
        self.userStack.arrangedSubviews.enumerated().forEach { index, item in
          item.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
          
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
          let topViewConstraint = topView.getConstraint(identifier: "height")
    else { return }
    
    setNeedsLayout()
    avatar.userprofile = userprofile

    let temp = UIImageView(image: userprofile.image)
    temp.contentMode = .scaleAspectFill
    temp.frame = CGRect(origin: cell.avatar.convert(cell.avatar.imageView.frame.origin, to: topView), size: cell.avatar.bounds.size)
    temp.cornerRadius = cell.avatar.bounds.height/2
    topView.addSubview(temp)
    cell.avatar.alpha = 0
    
    let destinationFrame = CGRect(origin: userView.convert(avatar.frame.origin, to: topView),
                                  size: .init(width: cell.avatar.bounds.size.width * 2.23, height: cell.avatar.bounds.size.width * 2.23))
    
    userView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    userStack.arrangedSubviews.forEach { $0.alpha = 0 }
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 0.3,
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
        animateStackView()
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
  func onProfileButtonTapped() {
    guard let userprofile = userprofile else { return }
    
    viewInput?.openUserprofile(userprofile)
  }
  
  @objc
  func unsubscribe() {
    guard let userprofile = userprofile else { return }
    
    viewInput?.unsubscribe(from: userprofile)
    subscriptionButton.isUserInteractionEnabled = false
    
    if #available(iOS 15, *), !subscriptionButton.configuration.isNil {
      subscriptionButton.configuration!.showsActivityIndicator = true
    } else {
      guard let imageView = subscriptionButton.imageView else { return }
      
      imageView.clipsToBounds = false
      let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                            size: CGSize(width: imageView.bounds.height,
                                                                         height: imageView.bounds.height)))
      indicator.layoutCentered(in: imageView)
      indicator.color = .systemRed
      indicator.startAnimating()
      indicator.accessibilityIdentifier = "indicator"
      UIView.animate(withDuration: 0.2) {
        indicator.alpha = 1
        imageView.tintColor = .clear
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
  func toggleDateFilter(on: Bool) {
    guard let heightConstraint = filterView.getConstraint(identifier: "height"),
          let constraint1 = filterView.getConstraint(identifier: "top_1"),
          let constraint2 = shadowView.getConstraint(identifier: "top")
            //              let constraint3 = shadowView.getConstraint(identifier: "leading"),
            //              let constraint4 = shadowView.getConstraint(identifier: "trailing")
            //              let constraint5 = shadowView.getConstraint(identifier: "bottom")
    else { return }
    
    setNeedsLayout()
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
  
  func switchEmptyLabel(isEmpty: Bool) {
    func emptyLabel() -> UILabel {
      let label = UILabel()
      label.accessibilityIdentifier = "emptyLabel"
      label.backgroundColor = .clear
      label.alpha = 0
      label.font = UIFont.scaledFont(fontName: Fonts.Rubik.SemiBold, forTextStyle: .title3)
      label.text = "publications_not_found".localized// + "\n⚠︎"
      label.textColor = .secondaryLabel
      label.numberOfLines = 0
      label.textAlignment = .center
      
      return label
    }
    
    if isEmpty {
      let label = shadowView.getSubview(type: UILabel.self, identifier: "emptyLabel") ?? emptyLabel()
      label.place(inside: shadowView,
                  insets: .uniform(size: self.padding*2))
      label.transform = .init(scaleX: 0.75, y: 0.75)
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          label.transform = .identity
          label.alpha = 1
          self.surveysCollectionView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .clear
        }) { _ in }
    } else if let label = shadowView.getSubview(type: UILabel.self, identifier: "emptyLabel") {
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.3,
        options: [.curveEaseInOut],
        animations: { [weak self] in
          guard let self = self else { return }
          
          label.transform = .init(scaleX: 0.75, y: 0.75)
          label.alpha = 0
          self.surveysCollectionView.backgroundColor = .clear
        }) { _ in label.removeFromSuperview() }
    }
  }
}

extension SubscriptionsView: SubsciptionsControllerOutput {
  func hideUserCard(_ completion: Closure? = nil) {
    mode = .Default
    surveysCollectionView.category = .Subscriptions
    guard let viewInput = viewInput,
          viewInput.isOnScreen,
          let cell = self.feedCollectionView.cellForItem(at: self.indexPath) as? UserprofileCell,
          let subview = userView.getSubview(type: UIView.self, identifier: "opaque"),
          let constraint = subview.getConstraint(identifier: "trailing"),
          let userprofile = userprofile
    else {
      guard let subview = userView.getSubview(type: UIView.self, identifier: "opaque"),
            let constraint = subview.getConstraint(identifier: "trailing")
      else { return }
      
      avatar.alpha = 0
      isCardOnScreen = false
      constraint.constant = 16
      if let cells = feedCollectionView.visibleCells.filter({ $0.isKind(of: UserprofileCell.self )}) as? [UserprofileCell] {
        cells.forEach { $0.avatar.alpha = 1 }
      }
      
      return
    }
    
//    mode = .Default
//    surveysCollectionView.category = .Subscriptions
    
    let temp = UIImageView(image: userprofile.image)
    temp.contentMode = .scaleAspectFill
    temp.frame = CGRect(origin: userView.convert(avatar.frame.origin, to: topView),
                        size: avatar.bounds.size)
    temp.cornerRadius = temp.bounds.height/2
    avatar.alpha = 0
    topView.addSubview(temp)
    cell.avatar.alpha = 0
    
    let destinationFrame = CGRect(origin: cell.avatar.convert(cell.avatar.imageView.frame.origin, to: topView),
                                  size: cell.avatar.imageView.bounds.size)
    
    setNeedsLayout()
    //        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15,
    //                                                       delay: 0,
    //                                                       options: .curveEaseInOut,
    //                                                       animations: { [weak self] in
    //            guard let self = self else { return }
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      //            usingSpringWithDamping: 0.8,
      //            initialSpringVelocity: 0.3,
      options: [.curveEaseInOut],
      animations: { [weak self] in
        guard let self = self else { return }
        
        temp.frame = destinationFrame
        temp.cornerRadius = cell.avatar.bounds.height/2
        self.feedCollectionView.alpha = 1
        self.userView.alpha = 0
        self.userView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        subview.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        //                self.userStack.spacing = 100
        constraint.constant = self.userView.bounds.width/3
        if let topViewConstraint = self.topView.getConstraint(identifier: "height") {
          topViewConstraint.constant = self.topViewHeight
        }
        self.layoutIfNeeded()
      }) { _ in
        subview.transform = .identity
        self.userView.transform = .identity
        constraint.constant = 16
        //            self.userStack.spacing = 4
        
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
