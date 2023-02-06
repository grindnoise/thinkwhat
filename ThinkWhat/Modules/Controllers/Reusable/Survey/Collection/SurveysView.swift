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
  weak var viewInput: (TintColorable & SurveysViewInput)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
      //            switch viewInput.mode {
      //            case .Topic:
      //                collectionView.topic = viewInput.topic
      //            case .Own:
      //                collectionView.category = .Own
      //            case .Favorite:
      //                collectionView.category = .Favorite
      //            case .ByOwner:
      //                collectionView.category = .ByOwner
      //            default:
      //#if DEBUG
      //                print("")
      //#endif
      //            }
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var collectionView: SurveysCollectionView = {
    guard let viewInput = viewInput else { return SurveysCollectionView() }
    
    var instance: SurveysCollectionView!
    
    switch viewInput.mode {
    case .Topic:
      guard let topic = viewInput.topic else { return SurveysCollectionView() }
      
      instance = SurveysCollectionView(topic: topic)
    case .Own, .Favorite:
      instance = SurveysCollectionView(category: viewInput.mode,
                                       color: viewInput.tintColor)
    case .ByOwner:
      guard let userprofile = viewInput.userprofile else { return SurveysCollectionView() }

      instance = SurveysCollectionView(userprofile: userprofile,
                                       category: .ByOwner,
                                       color: viewInput.tintColor)
    case .Compatibility:
      guard let compatibility = viewInput.compatibility else { return SurveysCollectionView() }
      
      instance = SurveysCollectionView(compatibility: compatibility,
                                       color: viewInput.tintColor)
    default:
#if DEBUG
      return SurveysCollectionView()
#endif
    }
    
    //        let instance = SurveysCollectionView(topic: viewInput.topic)
    
    //Pagination #1
    let paginationPublisher = instance.paginationPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
    
    paginationPublisher
      .sink { [unowned self] in
        guard let source = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: source, dateFilter: period, topic: nil, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Pagination #2
    let paginationByTopicPublisher = instance.paginationByTopicPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
    
    paginationByTopicPublisher
      .sink { [weak self] in
        guard let self = self,
              let topic = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .Topic, dateFilter: period, topic: topic, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Pagination #3
    let paginationByOwnerPublisher = instance.paginationByOwnerPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
    
    paginationByOwnerPublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .ByOwner, dateFilter: period, topic: nil, userprofile: userprofile)
      }
      .store(in: &subscriptions)
    
    //Refresh #1
    instance.refreshPublisher
      .sink { [weak self] in
        guard let self = self,
              let category = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: category, dateFilter: period, topic: nil, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Refresh #2
    instance.refreshByTopicPublisher
      .sink { [weak self] in
        guard let self = self,
              let topic = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .Topic, dateFilter: period, topic: topic, userprofile: nil)
      }
      .store(in: &subscriptions)
    
    //Refresh #3
    instance.refreshByOwnerPublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0.keys.first,
              let period = $0.values.first
        else { return }
        
        self.viewInput?.onDataSourceRequest(source: .ByOwner, dateFilter: period, topic: nil, userprofile: userprofile)
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
      
      let banner = Popup(callbackDelegate: self, bannerDelegate: self, heightScaleFactor: 0.7)
      banner.accessibilityIdentifier = "claim"
      let claimContent = ClaimPopupContent(parent: banner, surveyReference: surveyReference)
      
      claimContent.claimPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.viewInput?.claim(surveyReference: surveyReference, claim: $0)
        }
        .store(in: &self.subscriptions)
      
      banner.present(content: claimContent)
      banner.didDisappearPublisher
        .sink { [weak self] _ in
          guard let self = self else { return }
          
          banner.removeFromSuperview()
        }
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
    
    instance.unsubscribePublisher
      .sink { [weak self] in
        guard let self = self,
              let userprofile = $0
        else { return }
        
        self.viewInput?.unsubscribe(from: userprofile)
      }
      .store(in: &self.subscriptions)
    
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
    
    //        setupUI()
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
  func onSearchCompleted(_ instances: [SurveyReference]) {
      collectionView.endSearchRefreshing()
      collectionView.fetchResult = instances
  }
  
  func toggleSearchMode(_ on: Bool) {
    print("toggleSearchMode", on)
  }
  
  func beginSearchRefreshing() {
    collectionView.beginSearchRefreshing()
  }
  
  func viewDidDisappear() {
    collectionView.deinitPublisher.send(true)
  }
  
  func onRequestCompleted(_: Result<Bool, Error>) {
    collectionView.endRefreshing()
  }
}

private extension SurveysView {
  
  private func setupUI() {
    backgroundColor = .systemGroupedBackground
    collectionView.place(inside: self)
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
