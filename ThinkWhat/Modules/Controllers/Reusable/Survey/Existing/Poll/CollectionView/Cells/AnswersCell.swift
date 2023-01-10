//
//  AnswersCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class AnswersCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public var item: Survey! {
    didSet {
      guard let item = item else { return }
      
      collectionView.item = item
    }
  }
  //Publishers
  public let selectionPublisher = PassthroughSubject<Answer, Never>()
  public let deselectionPublisher = PassthroughSubject<Bool, Never>()
  public let isVotingPublisher = PassthroughSubject<Bool, Never>()
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var collectionView: AnswersCollectionView = {
    let instance = AnswersCollectionView()
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.isActive = true
    
    setNeedsLayout()
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && constraint.constant != $0.height }
      .sink { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = $0.height
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    instance.selectionPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.selectionPublisher.send($0)
      }
      .store(in: &subscriptions)
    instance.deselectionPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.deselectionPublisher.send($0)
      }
      .store(in: &subscriptions)
    isVotingPublisher
      .sink { instance.isVotingPublisher.send($0) }
      .store(in: &subscriptions)
    
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
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension AnswersCell {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    collectionView.place(inside: contentView,
                         insets: .uniform(size: padding),//UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding),
                         bottomPriority: .defaultLow)
  }
  
  func setTasks() {
    //        tasks.append( Task {@MainActor [weak self] in
    //            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
    //                guard let self = self else { return }
    //
    //
    //            }
    //        })
  }
}
