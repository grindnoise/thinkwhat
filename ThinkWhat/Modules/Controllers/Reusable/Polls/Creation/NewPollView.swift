//
//  NewPollView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: NewPollViewInput?
  ///**Publishers**
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private lazy var collectionView: NewPollCollectionView = {
    let instance = NewPollCollectionView()
    instance.progressPublisher
      .sink { [weak self] in
        guard let self = self else { return }
      
        self.viewInput?.setProgress($0)
      }
      .store(in: &subscriptions)
    
    
    return instance
  }()
  
  
  
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
//    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension NewPollView: NewPollControllerOutput {
  func willMoveToParent() {
    collectionView.isMovingToParent = true
  }
  
  
}


private extension NewPollView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    collectionView.place(inside: self)
//    let touch = UITapGestureRecognizer(target: self, action:#selector(self.hideKeyboard))
//    addGestureRecognizer(touch)
  }
  
//  func setTasks() {
//    tasks.append( Task {@MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardWillHideNotification) {
//        guard let self = self else { return }
//
//        collectionView.isKeyboardOnScreen = false
//        self.getSubview(type: UIView.self, identifier: "opaque")?.removeFromSuperview()
//      }
//    })
//    tasks.append( Task {@MainActor [weak self] in
//      for await _ in NotificationCenter.default.notifications(for: UIApplication.keyboardWillShowNotification) {
//        guard let self = self else { return }
//
//        collectionView.isKeyboardOnScreen = true
//        let opaque = UIView.opaque()
//        opaque.place(inside: self)
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
//        opaque.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard)))
//      }
//    })
//  }
//
//  @objc
//  func hideKeyboard() {
//    endEditing(true)
//  }
}


