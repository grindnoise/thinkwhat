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
    
    weak var viewInput: SubscriptionsViewInput?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    private var isCollectionViewSetupCompleted = false
    private let reuseIdentifier = "voter"
    private var needsAnimation = true
    private var isRevealed = false
    private lazy var collectionView: SurveysCollectionView = {
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
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = true
        instance.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.75)
        instance.addEquallyTo(to: shadowView)
        collectionView.addEquallyTo(to: instance)
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        return instance
    }()
    private var shadowObserver: NSKeyValueObservation!
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var upperContainer: UIView! {
        didSet {
            upperContainer.backgroundColor = .systemBackground
//            upperContainer.alpha = 0
        }
    }
    @IBOutlet weak var subscriptionsCollectionView: UICollectionView!
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
            background.addEquallyTo(to: shadowView)
        }
    }
    @IBOutlet weak var upperContainerHeightConstraint: NSLayoutConstraint! {
        didSet {
            upperContainerHeightConstraint.constant = 0
        }
    }
    @IBOutlet weak var subscribers: UIButton! {
        didSet {
            subscribers.setTitle("subscribers".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func subscribersTapped(_ sender: UIButton) {
        viewInput?.onSubscribersTapped()
    }
    @IBOutlet weak var more: UIButton! {
        didSet {
            more.setAttributedTitle(NSAttributedString(string: "more".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.08), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]), for: .normal)
        }
    }
    @IBAction func moreTapped(_ sender: UIButton) {
        viewInput?.onSubscpitionsTapped()
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Private properties
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
    }
        
    private func setupUI() {
        subscriptionsCollectionView.register(UINib(nibName: "VoterCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        setText()
//        featheredView.layer.mask = featheredLayer
    }
    
    private func setText() {
        guard !more.isNil, !subscribers.isNil else { return }
//        more.setAttributedText(text: "more".localized.uppercased(),
//                               font: Fonts.Semibold,
//                               width: bounds.width,
//                               widthDivisor: 0.0325,
//                               lightColor: K_COLOR_RED,
//                               style: traitCollection.userInterfaceStyle)
//        subscribers.setAttributedText(text: "subscribers".localized.uppercased(),
//                                      font: Fonts.Semibold,
//                                      width: bounds.width,
//                                      widthDivisor: 0.0325,
//                                      lightColor: K_COLOR_RED,
//                                      style: traitCollection.userInterfaceStyle)
    }
    
    private func setFlowLayout() {
        guard !isCollectionViewSetupCompleted else { return }
        isCollectionViewSetupCompleted = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: subscriptionsCollectionView.bounds.height, height: subscriptionsCollectionView.bounds.height)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        subscriptionsCollectionView.collectionViewLayout = flowLayout
        subscriptionsCollectionView.delegate = self
        subscriptionsCollectionView.dataSource = self
    }
    
    @objc
    private func hideMenu() {
        viewInput?.toggleBarButton()
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        let outerColor = UIColor.clear.cgColor
//        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground.cgColor : UIColor.white.cgColor
//        featheredLayer.colors = [outerColor, innerColor,innerColor,outerColor]
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        setText()
//        guard let v = self.card.subviews.filter({ $0.accessibilityIdentifier == "cardBlur" }).first as? UIVisualEffectView, isRevealed else { return }
//                v.effect = UIBlurEffect(style: self.traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
}

// MARK: - Controller Output
extension SubscriptionsView: SubsciptionsControllerOutput {
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        collectionView.endRefreshing()
    }
    
    func onWillAppear() {
        collectionView.deselect()
    }
    
    func onUpperContainerShown(_ reveal: Bool) {
        isRevealed = reveal
//        let cardBlur: UIView = {
//            guard let v = self.card.subviews.filter({ $0.accessibilityIdentifier == "cardBlur" }).first else {
//                let v = UIView(frame: card.bounds)
//                v.backgroundColor = .black.withAlphaComponent(0.5)
//                v.alpha = 0
//                card.addSubview(v)
//                v.accessibilityIdentifier = "cardBlur"
//                v.isUserInteractionEnabled = true
//                v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideMenu)))
//                return v
//            }
//            return v
//        }()
//        let menuBlur: UIVisualEffectView =  {
//            guard let v = self.upperContainer.subviews.filter({ $0.accessibilityIdentifier == "menuBlur" }).first as? UIVisualEffectView else {
//                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
//                blur.frame = upperContainer.bounds
////                upperContainer.addSubview(blur)
//                blur.addEquallyTo(to: upperContainer)
//                blur.setNeedsLayout()
//                blur.layoutIfNeeded()
//                blur.accessibilityIdentifier = "menuBlur"
//                blur.isUserInteractionEnabled = false
//                return blur
//            }
//            return v
//        }()
//
//        cardBlur.alpha = reveal ? 0 : 1
//        menuBlur.effect = !reveal ? nil : UIBlurEffect(style: .prominent)
//        if !reveal {
//            menuBlur.setNeedsLayout()
//            menuBlur.layoutIfNeeded()
//        }
        //        observers.forEach({ $0.invalidate()})
//        if !reveal {
            shadowObserver.invalidate()
        let initialPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: shadowView.bounds.width, height: reveal ? background.bounds.height  : background.bounds.height - self.frame.height * 0.2)),
                                               cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
        
        let destinationPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: shadowView.bounds.width, height: shadowView.bounds.height + (reveal ? -self.frame.height * 0.2 : self.frame.height * 0.2))),
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
                                                       animations: {
//            cardBlur.alpha = !reveal ? 0 : 1
//            menuBlur.effect = reveal ? nil : UIBlurEffect(style: .prominent)
            self.setNeedsLayout()
            self.upperContainerHeightConstraint.constant += reveal ? self.frame.height * 0.2 : -self.upperContainerHeightConstraint.constant
            self.layoutIfNeeded()
            self.upperContainer.subviews.forEach {
                $0.alpha = reveal ? 1 : 0
            }
//            self.shadowView.layer.shadowOpacity = 0
//            self.upperContainer.alpha = reveal ? 1 : 0
        })
        {
            [weak self] _ in
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) {
//                self?.shadowView.layer.shadowOpacity = 1
//            }
            guard !self.isNil else { return }
            self!.setFlowLayout()
            guard !reveal else { return }
        }
        
//        let destinationPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: shadowView.bounds.width, height: shadowView.bounds.height)),
//                                                       cornerRadius: self.shadowView.bounds.width * 0.05).cgPath
//                    let anim = Animations.get(property: .ShadowPath,
//                                              fromValue: self.shadowView.layer.shadowPath as Any,
//                                              toValue: destinationPath,
//                                              duration: 0.1,
//                                              delay: 0,
//                                              repeatCount: 0,
//                                              autoreverses: false,
//                                              timingFunction: .linear,
//                                              delegate: nil,
//                                              isRemovedOnCompletion: true,
//                                              completionBlocks: nil)
//                    self.shadowView.layer.add(anim, forKey: nil)
//                    self.shadowView.layer.shadowPath = destinationPath
    }
}

// MARK: - UI Setup
extension SubscriptionsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0//viewInput?.userprofiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VoterCell,
//           let userprofile = viewInput?.userprofiles[indexPath.row] as? Userprofile {
//            cell.setupUI(callbackDelegate: self, userprofile: userprofile, mode: .FirstnameLastname, lightColor: K_COLOR_RED)
//            return cell
//        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard needsAnimation else { return }
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.15, delay: 0.04 * Double(indexPath.row)) {
            cell.alpha = 1
            cell.transform = .identity
        }
        needsAnimation = (collectionView.visibleCells.count < (indexPath.row + 1))
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
