//
//  EmptyCard.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class EmptyHotCard: UIView, Card {
  enum Action { case Next, Claim, Vote }
  
  // MARK: - Public properties
  public var subscriptions = Set<AnyCancellable>()
  public let buttonTapEvent = PassthroughSubject<Void, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var body: UIView = {
    let instance = UIView()
    emptyPublicationsView.place(inside: instance)
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.05 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var shadowView: UIView = {
    let instance = UIView()
    instance.clipsToBounds = false
    instance.backgroundColor = .clear
    instance.accessibilityIdentifier = "shadow"
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowColor = Shadows.Cards.color
    instance.layer.shadowRadius = Shadows.radius(padding: padding)
    instance.layer.shadowOffset = Shadows.Cards.offset
    body.addEquallyTo(to: instance)
    
    return instance
  }()
  private lazy var emptyPublicationsView: EmptyPublicationsView = {
    let instance = EmptyPublicationsView(labelText: "waiting_for_new_posts",
                                         showsButton: true,
                                         showsLogo: true,
                                         buttonText: "create_post",
                                         buttonColor: Colors.main,
                                         backgroundLightColor: .systemBackground,
                                         backgroundDarkColor: Colors.darkTheme,
                                         spiralLightColor: UIColor.white.blended(withFraction: 0.04, of: UIColor.lightGray),
                                         spiralDarkColor: Colors.spiralDark)
    instance.buttonTapEvent
      .sink { [unowned self] in self.buttonTapEvent.send() }
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
  init() {
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Public
  public func toggleAnimations(_ on: Bool) {
    emptyPublicationsView.setAnimationsEnabled(on)
  }
  
  
  
  // MARK: - Overridden
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
  }
}

private extension EmptyHotCard {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    shadowView.place(inside: self)
    emptyPublicationsView.setAnimationsEnabled(true)
  }
}
