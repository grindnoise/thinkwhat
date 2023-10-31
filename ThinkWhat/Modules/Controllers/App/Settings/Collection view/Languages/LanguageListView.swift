//
//  LanguageListView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class LanguageListView: UIView {
  
  // MARK: - Public properties
  weak var viewInput: LanguageListViewInput?
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var collectionView: LanguagesCollectionView = {
    let instance = LanguagesCollectionView(dataItems: [])
    fatalError()
//    instance.contentLanguagePublisher
//      .sink { [weak self] in
//        guard let self = self,
//              let dict = $0,
//              let language = dict.keys.first,
//              let value = dict.values.first
//        else { return }
//        
//        self.viewInput?.updateContentLanguage(language: language, use: value)
//      }
//      .store(in: &subscriptions)
    
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

private extension LanguageListView {
  
  func setupUI() {
    backgroundColor = .systemBackground
    collectionView.addEquallyTo(to: self)
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

extension LanguageListView: LanguageListControllerOutput {
  
  // Implement methods
  
}

