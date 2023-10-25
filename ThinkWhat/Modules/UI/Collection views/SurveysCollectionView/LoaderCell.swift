//
//  LoaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class LoaderCell: UICollectionReusableView {
  
  // MARK: - Public properties
  public var color: UIColor = Constants.UI.Colors.main {
    didSet {
      guard color != oldValue else { return }

      if !uiSetupCompleted  { setupUI() }
      
      spinner.setColor(color)
    }
  }
  public var isLoading: Bool = false {
    didSet {
      if !uiSetupCompleted  { setupUI() }
      
      guard oldValue != isLoading else { return }
      
      if isLoading {
        spinner.start(duration: 1)
      }
      
      spinner.transform = isLoading ? .init(scaleX: 0.25, y: 0.25) : .identity
      spinner.alpha = isLoading ? 0 : 1
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
        guard let self = self else { return }
        
        self.spinner.alpha = self.isLoading ? 1 : 0
        self.spinner.transform = self.isLoading ? .identity : CGAffineTransform(scaleX: 0.25, y: 0.25)
      }) { [weak self] _ in
        guard let self = self,
              !self.isLoading
        else { return }

        self.spinner.stop()
      }
    }
  }
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private var uiSetupCompleted = false
  private lazy var spinner: SpiralSpinner = { SpiralSpinner(frame: .zero, color: color) }()
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    tasks.forEach { $0?.cancel() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
    debugPrint("\(String(describing: type(of: self))).\(#function) \(DebuggingIdentifiers.destructing)")
  }
  
  public func cancelAllAnimations() {
    spinner.stop()
  }
  
  @MainActor
  public func setupUI() {
    backgroundColor = .clear
    addSubview(spinner)
    
    spinner.alpha = 0
    spinner.topToSuperview(offset: 4)
    spinner.centerXToSuperview()
    spinner.height(40)
    spinner.bottomToSuperview(offset: -4, priority: .defaultLow)
    
    uiSetupCompleted = true
  }
}
