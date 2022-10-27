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
    
    // MARK: - Public properties
    weak var viewInput: SubscriptionsViewInput?
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    private var userprofile: Userprofile! {
        didSet {
            viewInput?.setUserprofileFilter(userprofile)
            surveysCollectionView.userprofile = userprofile
            onUserSelected(userprofile: userprofile)
        }
    }
    private var isCollectionViewSetupCompleted = false
    private var needsAnimation = true
    private var isRevealed = false
    private lazy var subscriptionsLabel: UILabel = {
       let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.Light,
                                          forTextStyle: .headline)
        instance.text = "zero_subscriptions".localized
        instance.textColor = .secondaryLabel
        instance.textAlignment = .center
        instance.alpha = 0
        
        return instance
    }()
    private lazy var surveysCollectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(category: .Subscriptions)
        
        //Pagination #1
        let paginationPublisher = instance.paginationPublisher
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        
        paginationPublisher
            .sink { [unowned self] in
                guard let category = $0 else { return }
                
                self.viewInput?.onDataSourceRequest(source: category, topic: nil)
            }
            .store(in: &subscriptions)
        
        //Pagination #2
        let paginationByTopicPublisher = instance.paginationByTopicPublisher
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        
        paginationByTopicPublisher
            .sink { [unowned self] in
                guard let topic = $0 else { return }

                self.viewInput?.onDataSourceRequest(source: .Topic, topic: topic)
            }
            .store(in: &subscriptions)
        
        //Pagination #3
        let paginationByUserprofilePublisher = instance.paginationByUserprofilePublisher
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        
        paginationByUserprofilePublisher
            .sink { [unowned self] in
                guard let topic = $0 else { return }

                self.viewInput?.onDataSourceRequest(userprofile: userprofile)
            }
            .store(in: &subscriptions)
        
        //Refresh #1
        instance.refreshPublisher
            .sink { [unowned self] in
                guard let category = $0 else { return }
                
                self.viewInput?.onDataSourceRequest(source: category, topic: nil)
            }
            .store(in: &subscriptions)
        
        //Refresh #2
        instance.refreshByTopicPublisher
            .sink { [unowned self] in
                guard let topic = $0 else { return }
                
                self.viewInput?.onDataSourceRequest(source: .Topic, topic: topic)
            }
            .store(in: &subscriptions)
        
        //Refresh #3
        instance.refreshByUserprofilePublisher
            .sink { [unowned self] in
                guard let userprofile = $0 else { return }
                
                self.viewInput?.onDataSourceRequest(userprofile: userprofile)
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
        
        instance.claimSubject.sink {
            print($0)
        } receiveValue: { [weak self] in
            guard let self = self,
                let surveyReference = $0
            else { return }
            
            let banner = Popup(callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.7)
            banner.accessibilityIdentifier = "claim"
            let claimContent = ClaimPopupContent(callbackDelegate: self, parent: banner, surveyReference: surveyReference)
            
            claimContent.claimSubject.sink {
                print($0)
            } receiveValue: { [weak self] in
                guard let self = self,
                    let claim = $0
                else { return }
                
                self.viewInput?.claim(surveyReference: surveyReference, claim: claim)
            }.store(in: &self.subscriptions)
            
            banner.present(content: claimContent)
            
//            self.viewInput?.addFavorite(surveyReference: value)
        }.store(in: &self.subscriptions)
        
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
                      let dict = $0,
                      let userprofile = dict.keys.first,
                      let indexPath = dict.values.first
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
        
        instance.dataItemsCountPublisher
            .sink { [weak self] in
                guard let self = self,
                      let isEmpty = $0
                else { return }
                
                self.viewInput?.onSubcriptionsCountEvent(zeroSubscriptions: isEmpty)
                switch isEmpty {
                case true:
                    self.subscriptionsLabel.addEquallyTo(to: self.upperContainer)
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
                        self.subscriptionsLabel.alpha = 1
                    }
                case false:
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
                        self.subscriptionsLabel.alpha = 0
                    }) { _ in
                        self.subscriptionsLabel.removeFromSuperview()
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
        guard let userprofile = userprofile else { return Avatar() }
        
        let instance = Avatar(userprofile: userprofile, isShadowed: true)
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.alpha = 0
        instance.tapPublisher
            .sink { [unowned self] in
                guard let instance = $0 else { return }
                
                self.viewInput?.onProfileButtonTapped(instance)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var profileButton: UIButton = {
        let instance = UIButton()
        instance.addTarget(self, action: #selector(self.onProfileButtonTapped), for: .touchUpInside)
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
            config.title = "open_userprofile".localized.uppercased()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [unowned self] incoming in
                var outgoing = incoming
                outgoing.foregroundColor = self.traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
                outgoing.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)
                return outgoing
            }
            config.buttonSize = .mini
            config.contentInsets.top = 0
            config.contentInsets.bottom = 0
            config.contentInsets.leading = 0
            config.imagePlacement = .trailing
            config.imagePadding = 4.0
            config.imageColorTransformer = UIConfigurationColorTransformer { [unowned self] _ in return self.traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue }
            config.image = UIImage(systemName: "arrow.turn.down.right",
                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            instance.configuration = config
            instance.publisher(for: \.bounds, options: .new)
                .sink { rect in
                    instance.cornerRadius = rect.height/2.25
                }
                .store(in: &subscriptions)
        } else {
            let attrString = NSMutableAttributedString(string: "open_userprofile".localized.uppercased(), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
            ])
        instance.setAttributedTitle(attrString, for: .normal)
        instance.semanticContentAttribute = .forceRightToLeft
        instance.setImage(UIImage(systemName: "arrow.turn.down.right",
                                  withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                          for: .normal)
        instance.tintColor = traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
        instance.imageEdgeInsets.left = 4.0
        }

        return instance
    }()
    private lazy var subscriptionButton: UIButton = {
        let instance = UIButton()
        instance.addTarget(self, action: #selector(self.unsubscribe), for: .touchUpInside)
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
            config.title = "unsubscribe".localized.uppercased()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.foregroundColor = UIColor.systemRed
                outgoing.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)
                return outgoing
            }
            config.buttonSize = .mini
            config.contentInsets.leading = 0
            config.contentInsets.top = 0
            config.contentInsets.bottom = 0
            config.imagePlacement = .trailing
            config.imagePadding = 4.0
            config.activityIndicatorColorTransformer = UIConfigurationColorTransformer { _ in return .systemRed }
            config.imageColorTransformer = UIConfigurationColorTransformer { _ in return .systemRed }
            config.image = UIImage(systemName: "hand.raised.slash.fill",
                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            instance.configuration = config
            instance.publisher(for: \.bounds, options: .new)
                .sink { rect in
                    instance.cornerRadius = rect.height/2.25
                }
                .store(in: &subscriptions)
        } else {
            let attrString = NSMutableAttributedString(string: "unsubscribe".localized.uppercased(), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
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
        let opaque = UIView()
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
//            usernameLabel,
            profileButton,
            subscriptionButton,
            opaque
        ])
        instance.alignment = .leading
        instance.axis = .vertical
        instance.spacing = 8
        instance.accessibilityIdentifier = "userStack"
        
        return instance
    }()
    private lazy var userView: UIView = {
       let instance = UIView()
        instance.backgroundColor = .clear
        instance.alpha = 0
        instance.addEquallyTo(to: upperContainer)
        instance.accessibilityIdentifier = "userView"
        
        instance.addSubview(avatar)
//        instance.addSubview(userStack)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        let opaque = UIView()
        instance.addSubview(opaque)
        opaque.backgroundColor = .clear
        userStack.translatesAutoresizingMaskIntoConstraints = false
        opaque.translatesAutoresizingMaskIntoConstraints = false
        opaque.addSubview(userStack)
        
        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 16),
            avatar.topAnchor.constraint(equalTo: instance.topAnchor, constant: 6),
            avatar.bottomAnchor.constraint(equalTo: instance.bottomAnchor, constant: -6),
            opaque.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 16),
            opaque.topAnchor.constraint(equalTo: instance.topAnchor, constant: 6),
            opaque.bottomAnchor.constraint(equalTo: instance.bottomAnchor, constant: -6),
            opaque.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
            userStack.leadingAnchor.constraint(equalTo: opaque.leadingAnchor),
            userStack.trailingAnchor.constraint(equalTo: opaque.trailingAnchor),
            userStack.centerYAnchor.constraint(equalTo: opaque.centerYAnchor),
        ])
        
        return instance
    }()
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = true
        instance.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.75)
        instance.addEquallyTo(to: shadowView)
        surveysCollectionView.addEquallyTo(to: instance)
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            feedCollectionView
        ])
        instance.axis = .vertical
        
        return instance
    }()
    private var shadowObserver: NSKeyValueObservation!
    
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var upperContainer: UIView! {
        didSet {
            upperContainer.backgroundColor = .systemBackground
            feedCollectionView.addEquallyTo(to: upperContainer)
//            feedCollectionView.translatesAutoresizingMaskIntoConstraints = false
//            upperContainer.addSubview(feedCollectionView)
//            NSLayoutConstraint.activate([
//                feedCollectionView.topAnchor.constraint(equalTo: upperContainer.topAnchor, constant: 11),
//                feedCollectionView.leadingAnchor.constraint(equalTo: upperContainer.leadingAnchor, constant: 1),
//                feedCollectionView.trailingAnchor.constraint(equalTo: upperContainer.trailingAnchor, constant: 1),
//                feedCollectionView.bottomAnchor.constraint(equalTo: upperContainer.bottomAnchor, constant: -11),
//
//            ])
//            let constraint = feedCollectionView.bottomAnchor.constraint(equalTo: upperContainer.bottomAnchor)
//            constraint.priority = .defaultLow
//            constraint.isActive = true
        }
    }
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.layer.masksToBounds = false
            shadowView.clipsToBounds = false
            shadowView.backgroundColor = .clear
            shadowView.accessibilityIdentifier = "shadow"
            shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
            shadowView.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            shadowView.layer.shadowRadius = 5
            shadowView.layer.shadowOffset = .zero
            shadowObserver = shadowView.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
            }
            //            shadowView.publisher(for: \.bounds, options: .new)
            //                .sink { [weak self] rect in
//                    guard let self = self else { return }
//
//                    self.shadowView.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.width*0.05).cgPath
//                }
//                .store(in: &subscriptions)
            
            background.addEquallyTo(to: shadowView)
        }
    }
    @IBOutlet weak var upperContainerHeightConstraint: NSLayoutConstraint! {
        didSet {
//            upperContainerHeightConstraint.constant = 0
        }
    }
    
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setTasks()
        setupUI()
    }
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #unavailable(iOS 15) {
            profileButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
            subscriptionButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
            let attrString_1 = NSMutableAttributedString(string: "open_userprofile".localized.uppercased(), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: traitCollection.userInterfaceStyle != .dark ? K_COLOR_TABBAR : .systemBlue
            ])
            profileButton.setAttributedTitle(attrString_1, for: .normal)
        }
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

private extension SubscriptionsView {
    func setTasks() {
        //Subscription events
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
                guard let self = self,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let owner = dict.keys.first,
                      owner == Userprofiles.shared.current,
                      let userprofile = dict.values.first,
                      let viewInput = self.viewInput
                else { return }

                if viewInput.isOnScreen {
                    self.setDefaultFilter { [weak self] in
                        guard let self = self else { return }
                        
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
                        delayAsync(delay: 0.25) {
                            self.feedCollectionView.removeItem(userprofile)
                        }
                    }
                } else {
                    self.feedCollectionView.removeItem(userprofile)
                }
            }
        })
    }
    
    @MainActor
    func setupUI() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    @MainActor
    func onUserSelected(userprofile: Userprofile) {
        guard let cell = self.feedCollectionView.cellForItem(at: self.indexPath) as? UserprofileCell else { return }
        
        userView.setNeedsLayout()
        avatar.userprofile = userprofile
//        usernameLabel.text = userprofile.name
//        usernameLabel.setConstraints()
//        notifyButton.setImage(UIImage(systemName: "bell.and.waves.left.and.right.fill",
//                                      withConfiguration: UIImage.SymbolConfiguration(scale: .medium)),
//                              for: .normal)
        userView.layoutIfNeeded()
        
        let temp = UIImageView(image: userprofile.image)
        temp.contentMode = .scaleAspectFill
        temp.frame = CGRect(origin: cell.avatar.convert(cell.avatar.imageView.frame.origin, to: upperContainer), size: cell.avatar.bounds.size)
        temp.cornerRadius = cell.avatar.bounds.height/2
        upperContainer.addSubview(temp)
        cell.avatar.alpha = 0
        
        let destinationFrame = avatar.frame
        
        let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15,
                                                       delay: 0,
                                                       options: .curveEaseInOut,
                                                       animations: { [weak self] in
            guard let self = self else { return }
            
            temp.frame = destinationFrame
            temp.cornerRadius = destinationFrame.height/2
            self.feedCollectionView.alpha = 0
            self.userView.alpha = 1
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
        
        viewInput?.onProfileButtonTapped(userprofile)
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
}

extension SubscriptionsView: SubsciptionsControllerOutput {
    func setDefaultFilter(_ completion: Closure? = nil) {
        guard let cell = self.feedCollectionView.cellForItem(at: self.indexPath) as? UserprofileCell else { return }
        
        surveysCollectionView.category = .Subscriptions
        
        let temp = UIImageView(image: userprofile.image)
        temp.contentMode = .scaleAspectFill
        temp.frame = avatar.frame
        temp.cornerRadius = temp.bounds.height/2
        avatar.alpha = 0
        upperContainer.addSubview(temp)
        cell.avatar.alpha = 0
        
        let destinationFrame = CGRect(origin: cell.avatar.convert(cell.avatar.imageView.frame.origin, to: upperContainer),
                                      size: cell.avatar.imageView.bounds.size)
        
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15,
                                                       delay: 0,
                                                       options: .curveEaseInOut,
                                                       animations: { [weak self] in
            guard let self = self else { return }
            
            temp.frame = destinationFrame
            temp.cornerRadius = cell.avatar.bounds.height/2
            self.feedCollectionView.alpha = 1
            self.userView.alpha = 0
        }) { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, animations: {
                cell.avatar.alpha = 1
            }) { _ in
                temp.removeFromSuperview()
                
                guard let completion = completion else { return }
                
                completion()
            }
        }
        
//        feedCollectionView.blur(on: false,
//                                duration: 0.3,
//                                effectStyle: .systemChromeMaterial,
//                                withAlphaComponent: true,
//                                animations: { [weak self] in
//            guard let self = self else { return }
//
//
//            self.userView.alpha = 0
//            self.feedCollectionView.alpha = 1
//            self.setNeedsLayout()
//            self.upperContainerHeightConstraint.constant -= 20
//            self.layoutIfNeeded()
//        }) {}
    }
    
    func setPeriod(_ period: Period) {
        surveysCollectionView.period = period
    }
    
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        surveysCollectionView.endRefreshing()
    }
    
    func onWillAppear() {
        surveysCollectionView.deselect()
    }
    
    func onUpperContainerShown(_ reveal: Bool) {
        isRevealed = reveal
        
        shadowObserver.invalidate()
        let initialPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: shadowView.bounds.width, height: reveal ? background.bounds.height  : background.bounds.height - self.frame.height * 0.125)),
                                       cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
        
        let destinationPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: shadowView.bounds.width, height: shadowView.bounds.height + (reveal ? -self.frame.height * 0.125 : self.frame.height * 0.125))),
                                           cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
        let anim = Animations.get(property: .ShadowPath,
                                  fromValue: initialPath,
                                  toValue: destinationPath,
                                  duration: 0.25,
                                  delay: 0,
                                  repeatCount: 0,
                                  autoreverses: false,
                                  timingFunction: .easeInEaseOut,
                                  delegate: nil,
                                  isRemovedOnCompletion: true,
                                  completionBlocks: nil)
        self.shadowView.layer.add(anim, forKey: nil)
        self.shadowView.layer.shadowPath = destinationPath
        //            shadowObserver = shadowView.observe(\UIView.bounds, options: .new) { view, change in
        //                guard let newValue = change.newValue else { return }
        //                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
        //            }
        //        }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0,
                                                       options: [.curveEaseInOut],
                                                       animations: { [weak self] in
            guard let self = self else { return }
            
            self.setNeedsLayout()
            self.upperContainerHeightConstraint.constant += reveal ? self.frame.height * 0.125 : -self.upperContainerHeightConstraint.constant
            self.layoutIfNeeded()
            self.upperContainer.subviews.forEach {
                $0.alpha = reveal ? 1 : 0
            }
        }) { _ in }
    }
}

//extension SubsciptionsView: CallbackObservable {
//    func callbackReceived(_ sender: Any) {
//        if let instance = sender as? SurveyReference {
//            viewInput?.onSurveyTapped(instance)
//        } else if sender is SurveysCollectionView {
//            viewInput?.onDataSourceRequest()
//        } else if let instances = sender as? [SurveyReference] {
//            viewInput?.updateSurveyStats(instances)
//        }
//    }
//}

extension SubscriptionsView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}

extension SubscriptionsView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}
