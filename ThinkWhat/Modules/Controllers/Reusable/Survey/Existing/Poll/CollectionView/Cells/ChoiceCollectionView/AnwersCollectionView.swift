//
//  ChoiceCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AnswersCollectionView: UICollectionView {
  
  typealias Source = UICollectionViewDiffableDataSource<Section, Answer>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Answer>
  
  // MARK: - Enums
  enum Section: Int {
    case main
  }
  
  // MARK: - Public properties
  public weak var item: Survey! {
    didSet {
      guard !item.isNil else { return }
      
//      item.reference.isCompletePublisher
//        .filter { $0 }
//        .sink { [weak self] _ in
//          guard let self = self,
//                let source = self.source
//          else { return }
//
//          source.refresh()
//        }
//        .store(in: &subscriptions)
      setupUI()
    }
  }
  //Publishers
  public let selectionPublisher = PassthroughSubject<Answer, Never>()
  public let deselectionPublisher = PassthroughSubject<Bool, Never>()
  public let isVotingPublisher = PassthroughSubject<Bool, Never>()
  public let updatePublisher = PassthroughSubject<Bool, Never>()
//  public var dataItems: [Answer] {
//    didSet {
//      reload(sorted: false, animatingDifferences: false)
//      //            reload(sorted: mode == .ReadOnly, animatingDifferences: true, shouldChangeColor: mode == .ReadOnly)
//    }
//  }
  //  public weak var answerListener: AnswerListener?
  //  public weak var boundsListener: BoundsListener?
  //    public var mode: PollController.Mode = .Write {
  //        didSet {
  //            modeSubject.send(mode)
  //            modeSubject.send(completion: .finished)
  //            allowsMultipleSelection = mode == .ReadOnly ? true : false
  //
  //            if oldValue != mode, mode == .ReadOnly {
  ////                reload(animatingDifferences: true, shouldChangeColor: true)
  ////                visibleCells.enumerated().forEach {
  ////                    guard let cell = $1 as? ChoiceCell else { return }
  ////                    cell.color = Colors.tags()[$0]
  ////                    cell.mode = mode
  ////                }
  ////                var snapshot = NSDiffableDataSourceSnapshot<Section, Answer>()
  ////                snapshot.appendSections([.main,])
  ////                snapshot.appendItems(dataItems, toSection: .main)
  ////                source.apply(snapshot, animatingDifferences: true)
  ////                var snap = source.snapshot()
  ////                snap.reloadSections([.main])
  //                source.refresh()
  //            }
  //        }
  //    }
  public var colorSubject = CurrentValueSubject<UIColor?, Never>(nil)
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private var selectedAnswer: Answer? {
    didSet {
      guard !item.isComplete,
            let instance = selectedAnswer
      else { return }
      
      selectedAnswerPunblisher.send(instance)
    }
  }
  private var source: Source!
  //Publishers
  private var selectedAnswerPunblisher = PassthroughSubject<Answer, Never>()
  
  // MARK: - Destructor
  deinit {
    subscriptions.forEach { $0.cancel() }
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  // MARK: - Initialization
  init() { super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout()) }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public methods
  public func refresh() {
    source.refresh()
  }
}

// MARK: - Private
private extension AnswersCollectionView {
  @MainActor
  func setupUI() {
    delegate = self
    clipsToBounds = false
//    allowsMultipleSelection = //mode == .ReadOnly ? true : false
    
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: sectionLayout.contentInsets.leading, bottom: 0, trailing: sectionLayout.contentInsets.trailing)
      sectionLayout.interGroupSpacing = 8
      return sectionLayout
    }
    
    let cellRegistration = UICollectionView.CellRegistration<AnswerCell, Answer> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      cell.item = item
      
      cell.selectionPublisher
        .sink { [unowned self] in
          self.selectionPublisher.send($0)
          self.selectedAnswer = $0
        }
        .store(in: &self.subscriptions)
      cell.deselectionPublisher
        .sink { [unowned self] in
          self.deselectionPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      cell.updatePublisher
        .sink { [unowned self] in
          
          self.source.refresh()
          self.updatePublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      //Deselect if other one is selected
      self.selectedAnswerPunblisher
        .filter { cell.item != $0 }
        .sink { _ in cell.isAnswerSelected = false }
        .store(in: &self.subscriptions)
      self.isVotingPublisher
        .sink { cell.isVoting = $0 }
        .store(in: &self.subscriptions)
      
//      cell.callbackDelegate = self
//      //            if cell.item.isNil {
//      var configuration = UIBackgroundConfiguration.listPlainCell()
//      configuration.backgroundColor = .clear
//      cell.backgroundConfiguration = configuration
//      cell.item = item
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//      //            }
//      cell.mode = self.mode
//      //            guard self.shouldChangeColor else { return }
//      cell.color = Colors.Tag.all()[indexPath.row]
//      cell.index = indexPath.row + 1
//
//      self.modeSubject.sink {
//#if DEBUG
//        print("receiveCompletion: \($0)")
//#endif
//      } receiveValue: { [weak self] in
//        guard let self = self else { return }
//        cell.mode = $0
//        self.colorSubject.send(completion: .finished)
//      }.store(in: &self.subscriptions)
//
//
//      cell.colorSubject.sink {
//#if DEBUG
//        print("receiveCompletion: \($0)")
//#endif
//      } receiveValue: { [weak self] in
//        guard let self = self,
//              let color = $0
//        else { return }
//        self.colorSubject.send(color)
//      }.store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    applySnapshot()
    //    reload(animatingDifferences: false)
  }
  
  func applySnapshot(animated: Bool = false) {
    guard let item = item else { return }
    
    var snapshot = Snapshot()
    snapshot.appendSections([.main,])
    snapshot.appendItems(item.answers.sorted{ $0.order < $1.order }, toSection: .main)
    source.apply(snapshot, animatingDifferences: animated)
  }
  
//  func reload(sorted: Bool = false, animatingDifferences: Bool = true) {
//    guard !dataItems.isEmpty else { return }
//
//    var snapshot = snapshot<Section, Answer>()
//    snapshot.appendSections([.main,])
//    snapshot.appendItems(sorted ? dataItems.sorted{ $0.totalVotes > $1.totalVotes } : dataItems, toSection: .main)
//    source.apply(snapshot, animatingDifferences: animatingDifferences)
//  }
}

// MARK: - UICollectionViewDelegate
extension AnswersCollectionView: UICollectionViewDelegate {
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    guard let cell = collectionView.cellForItem(at: indexPath) as? AnswerCell else { return }
//
//    answerListener?.onChoiceMade(cell.item)
//  }
  
//  func collectionView(_ collectionView: UICollectionView,
//                      shouldSelectItemAt indexPath: IndexPath) -> Bool {
//    if let _ = cellForItem(at: indexPath) as? ChoiceCell {
//      if mode == .ReadOnly {
//        selectItem(at: indexPath, animated: true, scrollPosition: [])
//        source.refresh {
//          self.boundsListener?.onBoundsChanged(self.frame)
//          //                    self.boundsListener?.onBoundsChanged(CGRect(origin: .zero, size: self.contentSize))
//        }
//      }
//    }
//    return true
//  }
  
//  func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//    collectionView.deselectItem(at: indexPath, animated: true)
//    if mode == .ReadOnly {
//      source.refresh {
//        //                self.boundsListener?.onBoundsChanged(CGRect(origin: .zero, size: self.contentSize))
//        //                    self.boundsListener?.onBoundsChanged(CGRect(origin: .zero, size: self.contentSize))
//      }
//    }
//    return false
//  }
  
  //    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
  //        guard mode == .Write else { return false }
  //        return true
  //    }
}
