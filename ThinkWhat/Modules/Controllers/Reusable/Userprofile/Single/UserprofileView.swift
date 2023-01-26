//
//  UserprofileView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofileView: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  weak var viewInput: (TintColorable & UserprofileViewInput)? {
    didSet {
      guard let viewInput = viewInput else { return }
      
      collectionView.colorPublisher.send(viewInput.tintColor)
      collectionView.userprofile = viewInput.userprofile
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
//  private var color: UIColor = .systemBlue {
//    didSet {
//      guard oldValue != color else { return }
//
//    }
//  }
  private lazy var collectionView: UserprofileCollectionView = {
    let instance = UserprofileCollectionView()//color: color)
    
    instance.imagePublisher
      .sink { [weak self] in
        guard let self = self,
              let image = $0
        else { return }
        
        self.viewInput?.openImage(image)
      }
      .store(in: &self.subscriptions)
    
    instance.subscriptionPublisher
      .sink { [weak self] in
        guard let self = self,
              let value = $0 else { return }
        
        value ? {self.viewInput?.subscribe()}() : {self.viewInput?.unsubscribe()}()
      }
      .store(in: &self.subscriptions)
    
    instance.urlPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.openURL($0)
      }
      .store(in: &self.subscriptions)
    
    instance.topicPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.viewInput?.onTopicSelected($0)
      }
      .store(in: &subscriptions)
    
    instance.publicationsPublisher
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.viewInput?.publications()
      }
      .store(in: &subscriptions)
    
    instance.subscribersPublisher
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.viewInput?.subscribers()
      }
      .store(in: &subscriptions)
    
    instance.commentsPublisher
      .sink { [weak self] _ in
        guard let self = self else { return }
        
        self.viewInput?.comments()
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
//  init(color: UIColor) {
//    self.color = color
//
//    super.init(frame: .zero)
//
//    setupUI()
//    setTasks()
//  }
  
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

private extension UserprofileView {
  
  func setupUI() {
    backgroundColor = .systemBackground
    collectionView.place(inside: self)
//    collectionView.color = color
//    collectionView.colorPublisher.send(color)
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


extension UserprofileView: UserprofileControllerOutput {
  
  // Implement methods
  
}
