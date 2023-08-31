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
  ///**Logic**
  private let filter = SurveyFilter(main: .subscriptions,
                                    additional: .disabled,
                                    period: .unlimited,
                                    topic: nil,
                                    userprofile: nil,
                                    compatibility: nil)
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var collectionView: SurveysCollectionView = {
    guard let viewInput = viewInput else { return SurveysCollectionView() }
    let instance = SurveysCollectionView(filter: filter, color: viewInput.tintColor)

    // Pagination
    instance.paginationPublisher
      .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
      .eraseToAnyPublisher()
      .sink { [unowned self] in self.viewInput?.getDataItems(excludeList: $0) }
      .store(in: &subscriptions)
    
    // Refresh
    instance.refreshPublisher
      .sink { [weak self] _ in
        guard let self = self//,
//              let category = $0.keys.first,
//              let period = $0.values.first
        else { return }
        fatalError()
//        self.viewInput?.onDataSourceRequest(source: category,
//                                            dateFilter: period,
//                                            topic: nil,
//                                            userprofile: nil,
//                                            compatibility: nil,
//                                            substring: "",
//                                            except: [],
//                                            ownersIds: [],
//                                            topicsIds: [],
//                                            ids: [])
      }
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
    
    instance.shareSubject
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.share($0!) }
      .store(in: &self.subscriptions)
    
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
    
    instance.userprofilePublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.openUserprofile($0!) }
      .store(in: &self.subscriptions)
    
    instance.unsubscribePublisher
      .filter { !$0.isNil }
      .sink { [unowned self] in self.viewInput?.unsubscribe(from: $0!) }
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
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

// MARK: - Controller Output
extension SurveysView: SurveysControllerOutput {
  func onSearchCompleted(_ instances: [SurveyReference]) {
      collectionView.endSearchRefreshing()
      collectionView.fetchResult = instances
  }
  
  func setMode(_ mode: Enums.SurveyFilterMode) {
//    collectionView.category = mode
  }
//  func toggleSearchMode(_ on: Bool) {
//    guard let mode = viewInput?.mode else { return }
//
//
//  }
  
  func beginSearchRefreshing() {
    collectionView.beginSearchRefreshing()
  }
  
  func viewDidDisappear() {
    collectionView.deinitPublisher.send(true)
  }
  
  func onRequestCompleted(_: Result<Bool, Error>) {
    collectionView.refreshControl?.endRefreshing()
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

//extension SurveysView: BannerObservable {
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
