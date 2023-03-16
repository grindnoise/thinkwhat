//
//  NewPollViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollController: UIViewController, TintColorable {
  
  // MARK: - Public properties
  var controllerOutput: NewPollControllerOutput?
  var controllerInput: NewPollControllerInput?
  var tintColor: UIColor
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**Logic**
  private var isTitleOnScreen = true
  ///**UI**
  private let progressCapsule: ProgressCapsule = ProgressCapsule(placeholder: "new_poll_readiness".localized.uppercased(),
                                                                 padding: 4,
                                                                 font: UIFont(name: Fonts.Bold, size: 20)!,
                                                                 iconCategory: .MegaphoneFill)
  
  

  // MARK: - Initialization
  init(color: UIColor) {
    self.tintColor = color
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  

  // MARK: - Destructor
  deinit {
    progressCapsule.removeFromSuperview()
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let view = NewPollView()
    let model = NewPollModel()
    
    self.controllerOutput = view
    self.controllerOutput?
      .viewInput = self
    self.controllerInput = model
    self.controllerInput?
      .modelOutput = self
    
    self.view = view as UIView
    
    setupUI()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    guard let constraint = progressCapsule.getConstraint(identifier: "centerYAnchor"),
    let navigationBar = self.navigationController?.navigationBar
    else { return }
    
    UIView.animate(withDuration: 0.1, animations: { [weak self] in
      guard let self = self else { return }
      
      navigationBar.setNeedsLayout()
      constraint.constant = -(navigationBar.bounds.height + self.view.statusBarFrame.height)
      navigationBar.layoutIfNeeded()
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.isTitleOnScreen = false
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard !isTitleOnScreen,
          let constraint = progressCapsule.getConstraint(identifier: "centerYAnchor")
    else { return }
    
    UIView.animate(withDuration: 0.1, animations: { [weak self] in
      guard let self = self else { return }
      
      self.navigationController?.navigationBar.setNeedsLayout()
      constraint.constant = 0
      self.navigationController?.navigationBar.layoutIfNeeded()
    }) { [weak self] _ in
      guard let self = self else { return }
      
      self.isTitleOnScreen = true
    }
  }
}

extension NewPollController: NewPollViewInput {
  
}

extension NewPollController: NewPollModelOutput {
  
}

// MARK: - Private
private extension NewPollController {
  func setupUI() {
    setNavigationBarTintColor(tintColor)
    
    guard let navigationBar = navigationController?.navigationBar else { return }
    
    progressCapsule.placeInCenter(of: navigationBar)
    navigationBar.setNeedsLayout()
    navigationBar.layoutIfNeeded()
  }
}
