//
//  HotCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 03.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class HotCard: UIView, Card {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private let item: Survey
  ///**UI**
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    instance.layer.shadowRadius = 5
    instance.layer.shadowOffset = .zero
    body.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var body: UIView = {
    let instance = UIView()
    instance.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .secondarySystemBackground
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.05 }
      .store(in: &subscriptions)
    let collectionView = PollCollectionView(item: item)
    collectionView.place(inside: instance)
    collectionView.isUserInteractionEnabled = false
    
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
  init(_ item: Survey) {
    self.item = item
    
    super.init(frame: .zero)
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
   
    body.backgroundColor = traitCollection.userInterfaceStyle != .dark ? .systemBackground : .secondarySystemBackground
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
}

private extension HotCard {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = false
    
    shadowView.place(inside: self)
  }
  
  @MainActor
  func updateUI() {
    
  }
  
  func setTasks() {
//    tasks.append( Task {@MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
//        guard let self = self else { return }
//
//
//      }
//    })
  }
}

