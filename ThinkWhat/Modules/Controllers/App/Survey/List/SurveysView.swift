//
//  SurveysView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SurveysView: UIView {
    
    // MARK: - Public properties
    weak var viewInput: SurveysViewInput? {
        didSet {
            guard let viewInput = viewInput else { return }
            
            switch viewInput.mode {
            case .Topic:
                collectionView.topic = viewInput.topic
                collectionView.indicatorColor = .white
            case .Own:
                collectionView.category = .Own
            default:
#if DEBUG
                print("")
#endif
            }
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private lazy var collectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(delegate: self, topic: viewInput?.topic)
        
        //Pagination
        instance.paginationPublisher
            .sink { [unowned self] in
            guard let category = $0
            else { return }
                  
            self.viewInput?.onDataSourceRequest(source: category, topic: nil)
        }
            .store(in: &subscriptions)
        
        //Pagination by topic
        instance.paginationByTopicPublisher
            .sink { [unowned self] in
            guard let topic = $0
                else { return }
                
                self.viewInput?.onDataSourceRequest(source: .Topic, topic: topic)
            }
            .store(in: &subscriptions)
        
        //Row selected
        instance.rowPublisher
            .sink { [weak self] in
            guard let self = self,
                  let instance = $0
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
    
    // MARK: - Deinitialization
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
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func layoutSubviews() {
        
    }
}

// MARK: - Controller Output
extension SurveysView: SurveysControllerOutput {
    
    func onRequestCompleted(_: Result<Bool, Error>) {
        collectionView.endRefreshing()
    }
}

private extension SurveysView {
    
    private func setupUI() {
        backgroundColor = .systemGroupedBackground
        collectionView.addEquallyTo(to: self)
    }
}

extension SurveysView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        
    }
}

extension SurveysView: BannerObservable {
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
