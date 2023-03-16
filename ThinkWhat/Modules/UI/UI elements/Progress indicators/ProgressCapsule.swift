//
//  ProgressCapsule.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ProgressCapsule: UIView {
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  ///Constants
  private let padding: CGFloat
  private let bgColor: UIColor
  private let fgColor: UIColor
  private let font: UIFont
  private let iconCategory: Icon.Category
  private let placeholder: String
  ///**Logic**
  @Published var progress: Double = 0
  ///Elements
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
//      UIView.horizontalSpacer(padding),
      icon,
      label,
      UIView.horizontalSpacer(padding)
    ])
    instance.layer.insertSublayer(progressLayer, at: 0)
    instance.publisher(for: \.bounds, options: .new)
      .filter { $0 != .zero }
      .sink { [unowned self] in
        instance.cornerRadius = $0.height/2.25
        self.progressLayer.frame = $0
      }
      .store(in: &subscriptions)
    instance.backgroundColor = .systemGray4
    instance.spacing = padding
    
    return instance
  }()
  private lazy var icon: Icon = {
//    let instance = Icon(category: Icon.Category.Logo)
//    instance.iconColor = .white//Colors.Logo.Flame.rawValue
//    instance.isRounded = false
//    instance.clipsToBounds = false
//    instance.scaleMultiplicator = 1.65
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    let instance = Icon(category: iconCategory)
    instance.iconColor = .white
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.65
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.font = font
    instance.text = placeholder.isEmpty ? "100%" : placeholder + ": 100%"
    instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: font)).isActive = true
    instance.textColor = .white
    
    return instance
  }()
  private lazy var progressLayer: CAGradientLayer = {
    let instance = CAGradientLayer()
    instance.startPoint = CGPoint(x: 0, y: 0.5)
    instance.endPoint = CGPoint(x: 1.0, y: 0.5)
    let bleached = UIColor.white.blended(withFraction: 0.85, of: fgColor).cgColor
    let saturated = UIColor.white.blended(withFraction: 1, of: fgColor).cgColor
    instance.setGradient(colors: [bleached, saturated],
                         locations: [0.0, 1])
    
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
  init(placeholder: String = "",
       padding: CGFloat = 8,
       backgroundColor: UIColor = .systemGray4,
       foregroundColor: UIColor = Colors.Logo.Flame.rawValue,
       font: UIFont,
       iconCategory: Icon.Category) {
    self.placeholder = placeholder
    self.padding = padding
    self.bgColor = backgroundColor
    self.fgColor = foregroundColor
    self.font = font
    self.iconCategory = iconCategory
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Public methods
  /// Animates progress bar & text
  /// - Parameters:
  ///   - value: 0.0 up to 1.0
  ///   - animated: Animation flag
  @MainActor
  public func setProgress(value: Double,
                          animated: Bool = true) {
    // TODO: - implent
  }
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension ProgressCapsule {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self,
                bottomPriority: .defaultLow)
  }
  
  @MainActor
  func updateUI() {
    
  }
}

