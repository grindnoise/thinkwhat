//
//  UserprofilesView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofilesView: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  public weak var viewInput: (UserprofilesViewInput & TintColorable)? {
    didSet {
      guard !viewInput.isNil else { return }
      
      collectionView.addEquallyTo(to: self)

    }
  }
  var gridItemSizePublisher = CurrentValueSubject<UserprofilesController.GridItemSize?, Never>(nil)
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  
  //UI
  private lazy var collectionView: UserprofilesCollectionView = {
    guard let color = viewInput?.tintColor,
          let mode = viewInput?.mode
    else { return UserprofilesCollectionView() }
    
    var instance: UserprofilesCollectionView!
    
    switch mode {
    case .Subscribers, .Subscriptions:
      guard let userprofile = viewInput?.userprofile else { return UserprofilesCollectionView() }

      instance = UserprofilesCollectionView(userprofile: userprofile, mode: mode, color: color)
    case .Voters:
      guard let answer = viewInput?.answer else { return UserprofilesCollectionView() }

      instance = UserprofilesCollectionView(answer: answer, mode: mode, color: Colors.getColor(forId: answer.order))
    }

    //Pagination #1
    let paginationPublisher = instance.requestPublisher
      .debounce(for: .seconds(3), scheduler: DispatchQueue.main)

    paginationPublisher
      .sink { [unowned self] _ in
        guard let viewInput = self.viewInput else { return }

        switch viewInput.mode {
        case .Subscribers, .Subscriptions:
          guard let userprofile = viewInput.userprofile else { return }
          
          self.viewInput?.loadUsers(for: userprofile, mode: viewInput.mode)
        case .Voters:
          guard let answer = viewInput.answer else { return }
          
          self.viewInput?.loadVoters(for: answer)
        }
      }
      .store(in: &subscriptions)

    gridItemSizePublisher.subscribe(instance.gridItemSizePublisher).store(in: &subscriptions)

    instance.userPublisher
      .sink { [unowned self] in self.viewInput?.onUserprofileTap($0) }
      .store(in: &subscriptions)

    instance.selectionPublisher
      .sink { [unowned self] in self.viewInput?.onSelection($0) }
      .store(in: &subscriptions)


    instance.refreshPublisher
      .filter { !$0.isNil }
      .sink { [unowned self] _ in
        guard let viewInput = self.viewInput,
              let userprofile = viewInput.userprofile
        else { return }

        self.viewInput?.loadUsers(for: userprofile, mode: viewInput.mode)
      }
      .store(in: &subscriptions)
    //Subscribe
    instance.subscribePublisher
      .sink { [unowned self] in self.viewInput?.subscribe(at: $0) }
      .store(in: &subscriptions)

    //Unsubscribe
    instance.unsubscribePublisher
      .sink { [unowned self] in

        switch self.viewInput?.mode {
        case .Subscriptions:
          self.viewInput?.unsubscribe(from: $0)
        case .Subscribers:
          self.viewInput?.removeSubscribers($0)
        default:
          print("")
        }
      }
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
    super.init(frame: .zero)
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension UserprofilesView {
  
  func setupUI() {
    
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

extension UserprofilesView: UserprofilesControllerOutput {
  func setEditingMode(_ on: Bool) {
    collectionView.editingMode(on)
    if !on {
      collectionView.cancelSelection()
    }
  }
  
  func filter() {
    collectionView.filter()
  }
}
