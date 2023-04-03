//
//  NewPollChoicesCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 21.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//


import UIKit
import Combine

class NewPollChoicesCollectionView: UICollectionView {
  enum Section { case main }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, NewPollChoice>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NewPollChoice>
  
  // MARK: - Public properties
  ///**Publishers**
  @Published public var stage: NewPollController.Stage
  @Published public var stageGlobal: NewPollController.Stage
  @Published public private(set) var dataItems: [NewPollChoice]
  @Published public private(set) var stageAnimationFinished: NewPollController.Stage!
  @Published public var isKeyboardOnScreen: Bool!
  @Published public var isMovingToParent: Bool!
  @Published public var removedChoice: NewPollChoice?
  @Published public private(set) var wasEdited: Bool?
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var source: Source!
  ///**UI**
  private let padding: CGFloat = 8
  
  
  
  // MARK: - Initialization
  init(dataItems: [NewPollChoice],
       stage: NewPollController.Stage,
       stageGlobal: NewPollController.Stage) {
    self.dataItems = dataItems
    self.stage = stage
    self.stageGlobal = stageGlobal
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  // MARK: - Public methods
  public func present(index: Int) {
    guard let cell = cellForItem(at: IndexPath(item: index, section: 0)) as? NewPollChoiceCell else { return }
    
    cell.textView.becomeFirstResponder()
  }
  
  public func refreshChoices(_ instances: [NewPollChoice]) {
    ///Only append
    guard dataItems.count < instances.count else { return }
    
    var snap = self.source.snapshot()
    let existingSet = Set(snap.itemIdentifiers)
    let appendingSet = Set(instances)
    let items = Array(appendingSet.subtracting(existingSet))
    snap.appendItems(items,
                     toSection: .main)
    dataItems += items
    //    } else {
    //      let existingSet = Set(snap.itemIdentifiers)
    //      let deletingSet = Set(instances)
    //      let crossingSet = existingSet.subtracting(deletingSet)
    //
    //      guard !crossingSet.isEmpty else { return }
    //
    //      snap.deleteItems(Array(crossingSet)
    
    source.apply(snap, animatingDifferences: true) { [unowned self] in
//      guard let cells = self.visibleCells as? [NewPollChoiceCell] else { return }
//
//      cells.forEach { $0.order = self.indexPath(for: $0)?.row ?? 0 }
    }
  }
}

private extension NewPollChoicesCollectionView {
  @MainActor
  func setupUI() {
    isScrollEnabled = false
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false
      layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
        guard let self = self else { return UISwipeActionsConfiguration(actions: []) }
        
        let action = UIContextualAction(style: .destructive, title: "delete".localized) { [weak self] action, view, completion in
          guard let self = self,
                let item = self.source.itemIdentifier(for: indexPath)
          else { return }
          
          guard self.dataItems.count > 2 else {
            completion(false)
            let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                                  text: "new_poll_survey_choice_delete_notification",
                                                                  tintColor: .systemRed),
                                   contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                   isModal: false,
                                   useContentViewHeight: true,
                                   shouldDismissAfter: 2)
            banner.didDisappearPublisher
              .sink { _ in banner.removeFromSuperview() }
              .store(in: &self.subscriptions)
            
            return
          }
          
//          self.removedChoice = item
          self.dataItems.remove(object: item)
          var snap = self.source.snapshot()
          if let indent = self.source.itemIdentifier(for: indexPath) {
            snap.deleteItems([indent])
//            self.removedChoice = item
            //                  self.listener?.deleteImage(indent)
          }
          self.source.apply(snap, animatingDifferences: true) { [unowned self] in
            self.removedChoice = item
            
            guard let cells = self.visibleCells as? [NewPollChoiceCell] else { return }
            
            cells.forEach { $0.order = self.indexPath(for: $0)?.row ?? 0 }
          }
          completion(true)
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)

          return UISwipeActionsConfiguration(actions: [action])
      }
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      sectionLayout.contentInsets = .uniform(size: .zero)//NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
      sectionLayout.interGroupSpacing = 8
      return sectionLayout
    }
    
    let cellRegistration = UICollectionView.CellRegistration<NewPollChoiceCell, NewPollChoice> { [unowned self] cell, indexPath, item in
//      cell.minHeight = 50
      cell.stage = self.stage
      cell.stageGlobal = self.stageGlobal
      cell.minLength = ModelProperties.shared.surveyAnswerTextMinLength
      cell.maxLength = ModelProperties.shared.surveyAnswerTextMaxLength
      cell.order = indexPath.row
      cell.item = item
      
      cell.boundsPublisher
        .sink { [unowned self] _ in self.source.refresh() }
        .store(in: &subscriptions)
      cell.$wasEdited
        .sink { [unowned self] in self.wasEdited = $0 }
        .store(in: &subscriptions)

      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.$isMovingToParent
        .filter { !$0.isNil }
        .eraseToAnyPublisher()
        .sink { cell.isMovingToParent = $0!}
        .store(in: &self.subscriptions)
      self.$isKeyboardOnScreen
        .filter { !$0.isNil }
        .eraseToAnyPublisher()
        .sink { cell.isKeyboardOnScreen = $0!}
        .store(in: &self.subscriptions)
      self.$stage
        .sink { cell.stage = $0 }
        .store(in: &subscriptions)
      self.$stageGlobal
        .sink { cell.stageGlobal = $0 }
        .store(in: &subscriptions)
      
//      guard self.stage == .Topic else { return }
//
//      cell.present(seconds: 0.5)
    }
  
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                   for: indexPath,
                                                   item: identifier)
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(dataItems, toSection: .main)
    source.apply(snapshot, animatingDifferences: true)
  }
}
