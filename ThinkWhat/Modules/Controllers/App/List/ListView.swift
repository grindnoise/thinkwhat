//
//  ListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ListView: UIView {
    
    weak var viewInput: ListViewInput?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private lazy var collectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(category: .New)
        
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
            
            let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: 0.7)
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
//    private lazy var featheredView: UIView = {
//        let instance = UIView()
//        instance.accessibilityIdentifier = "feathered"
//        instance.layer.masksToBounds = true
//        instance.backgroundColor = .clear
//        instance.addEquallyTo(to: background)
//        observers.append(instance.observe(\UIView.bounds, options: .new) { [weak self] view, change in
//            guard let self = self, let newValue = change.newValue, newValue.size != self.featheredLayer.bounds.size else { return }
//            self.featheredLayer.frame = newValue
//        })
//        collectionView.addEquallyTo(to: instance)
//        return instance
//    }()
//    private lazy var featheredLayer: CAGradientLayer = {
//        let instance = CAGradientLayer()
//        let outerColor = UIColor.clear.cgColor
////        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.bl.cgColor : UIColor.secondarySystemBackground.cgColor
//        let innerColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black.cgColor : UIColor.white.cgColor
//        instance.colors = [outerColor, innerColor, innerColor, outerColor]
//        instance.locations = [0.0, 0.0075, 0.985, 1.0]
//        instance.frame = frame
//        return instance
//    }()
//    private var hMaskLayer: CAGradientLayer!
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = false
        instance.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.75)
        //        collectionView.addEquallyTo(to: instance)
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        
        collectionView.addEquallyTo(to: instance)
        
        return instance
    }()

    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
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
            observers.append(shadowView.observe(\UIView.bounds, options: .new) { view, change in
                guard let newValue = change.newValue else { return }
                view.layer.shadowPath = UIBezierPath(roundedRect: newValue, cornerRadius: newValue.width*0.05).cgPath
            })
            background.addEquallyTo(to: shadowView)
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
        setupUI()
    }
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
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
//        featheredView.layer.mask = featheredLayer
    }
}

// MARK: - Controller Output
extension ListView: ListControllerOutput {
    func onAddFavoriteCallback(_ result: Result<Bool, Error>) {
#if DEBUG
      print(result)
#endif
    }
    
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        collectionView.endRefreshing()
    }
    
    func onDataSourceChanged() {
        guard let category = viewInput?.surveyCategory else { return }
        collectionView.category = category
    }
    
    func onDidLoad() {
//        collectionView.reload()
    }
    
    func onDidLayout() {}
}

// MARK: - UI Setup
extension ListView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

// MARK: - CallbackObservable
extension ListView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instances = sender as? [SurveyReference] {
            
        }
    }
}

// MARK: - BannerObservable
extension ListView: BannerObservable {
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
