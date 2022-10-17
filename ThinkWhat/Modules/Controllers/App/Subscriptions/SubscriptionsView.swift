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
    private var isCollectionViewSetupCompleted = false
    private var needsAnimation = true
    private var isRevealed = false
    private lazy var surveysCollectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(category: .Subscriptions)
        
        //Pagination #1
        let paginationPublisher = instance.paginationPublisher
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
        
        paginationPublisher
            .sink { [unowned self] in
                guard let category = $0 else { return }
                
                self.viewInput?.onDataSourceRequest(source: category, topic: nil)
            }
            .store(in: &subscriptions)
        
        //Pagination #2
        let paginationByTopicPublisher = instance.paginationByTopicPublisher
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
        
        paginationByTopicPublisher
            .sink { [unowned self] in
                guard let topic = $0 else { return }

                self.viewInput?.onDataSourceRequest(source: .Topic, topic: topic)
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
        instance.isDirectionalLockEnabled = true
        instance.userPublisher
            .sink { [weak self] in
                guard let self = self,
                      let userprofile = $0
                else { return }
                
                self.viewInput?.setUserprofileFilter(userprofile)
                self.surveysCollectionView.userprofile = userprofile
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
//            upperContainer.alpha = 0
//            verticalStack.addEquallyTo(to: upperContainer)
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
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    
    
    // MARK: - Private properties
    private func setupUI() {
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
    
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        let outerColor = UIColor.clear.cgColor
//        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
//        featheredLayer.colors = [outerColor, innerColor,innerColor,outerColor]
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
//        guard let v = self.card.subviews.filter({ $0.accessibilityIdentifier == "cardBlur" }).first as? UIVisualEffectView, isRevealed else { return }
//                v.effect = UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
}

// MARK: - Controller Output
extension SubscriptionsView: SubsciptionsControllerOutput {
    func setDefaultFilter() {
        surveysCollectionView.category = .Subscriptions
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
