//
//  StartView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class StartView: UIView {
  
  // MARK: - Public properties
  public private(set) lazy var logoText: LogoText = { LogoText() }()
  public private(set) lazy var logo: Logo = {
    let instance = Logo()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    
    return instance
  }()
  public private(set) lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    logo.placeInCenter(of: opaque, topInset: 0, bottomInset: 0)
    
    let instance = UIStackView(arrangedSubviews: [
      opaque,
      logoText
    ])
    instance.axis = .vertical
    instance.spacing = 30

    return instance
  }()
  public private(set) lazy var button: UIView = {
    let opaque = UIView.opaque()
    opaque.layer.masksToBounds = false
    
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .capsule
      config.baseBackgroundColor = Colors.main
      config.attributedTitle = AttributedString("getStartedButton".localized.capitalized,
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.backgroundColor = Colors.main
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.height/2 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.capitalized,
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Rubik.SemiBold, size: 14) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    opaque.heightAnchor.constraint(equalTo: opaque.widthAnchor, multiplier: 52/188).isActive = true
    opaque.publisher(for: \.bounds)
      .filter { $0 != .zero && opaque.layer.shadowPath?.boundingBox != $0 }
      .sink { [unowned self] in
        opaque.layer.shadowOpacity = 1 
        opaque.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.height/2).cgPath
        opaque.layer.shadowColor = self.traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
        opaque.layer.shadowRadius = self.traitCollection.userInterfaceStyle == .dark ? 8 : 4
        opaque.layer.shadowOffset = self.traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
      }
      .store(in: &subscriptions)
    instance.place(inside: opaque)
    
    return opaque
  }()
  public private(set) lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 1
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor : "#8C96A3".hexColor
    instance.text = ""// "start_tap_to_continue".localized
    instance.font = UIFont(name: Fonts.Rubik.Regular, size: 11)
    
    return instance
  }()
  public private(set) lazy var spiral: Icon = { Icon(frame: .zero, category: .Spiral, scaleMultiplicator: 1, iconColor: "#1E1E1E".hexColor!.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.7 : 0.03)) }()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private var shouldTerminate = false
  private let padding: CGFloat = 8
  private let maxItems = 16
  private var items = [Icon]() {
    didSet {
      guard !shouldTerminate && items.count < maxItems else { return }
      
      generateItems(maxItems - items.count)
    }
  }
  
  
  // MARK: - Public properties
  weak var viewInput: StartViewInput? {
    didSet {
      guard !viewInput.isNil else { return }
      
      setupUI()
    }
  }
  
  
  
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
    
    ProtocolSubscriptions.subscribe(self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overridden
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    label.textColor = traitCollection.userInterfaceStyle == .dark ? "#828487".hexColor : "#8C96A3".hexColor
    spiral.setIconColor("#1E1E1E".hexColor!.withAlphaComponent(traitCollection.userInterfaceStyle == .dark ? 0.7 : 0.03))
    button.layer.shadowRadius = traitCollection.userInterfaceStyle == .dark ? 8 : 4
    button.layer.shadowOffset = traitCollection.userInterfaceStyle == .dark ? .zero : .init(width: 0, height: 3)
    button.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.main.withAlphaComponent(0.25).cgColor : UIColor.black.withAlphaComponent(0.25).cgColor
    logoText.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.systemBackground.cgColor
  }
}

extension StartView: StartControllerOutput {
  func didAppear() {
    
    Task {
      try? await Task.sleep(nanoseconds: 8_000_000_0)
      
      let phrase = "start_tap_to_continue".localized
      var index = phrase.startIndex
      
      let stream = AsyncStream<String?> {
        guard index < phrase.endIndex else { return nil }
        
        do {
          try await Task.sleep(nanoseconds: 2_000_000_0)
        } catch {
          return ""
        }
        
        defer { index = phrase.index(after: index) }
        
        return String(phrase[phrase.startIndex...index])
      }
      
      for try await substring in stream {
        guard let substring = substring else { return }
        await MainActor.run {
          self.label.text! = substring
        }
      }
    }
    
    logo.alpha = 0
    logo.transform = .init(scaleX: 0.25, y: 0.25)
    logoText.transform = .init(scaleX: 0.75, y: 0.75)
    
    guard let constraint = self.label.getConstraint(identifier: "bottomAnchor") else { return }
    
    self.setNeedsLayout()
    UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) { [weak self] in
      guard let self = self else { return }
      
      constraint.constant = 0
      self.logoText.transform = .identity
      self.logoText.alpha = 1
      self.layoutIfNeeded()
    }
    
    UIView.animate(withDuration: 0.75, delay: 0.2, options: .curveEaseIn) { [weak self] in
      guard let self = self else { return }
      
      self.logo.transform = .identity
      self.logo.alpha = 1
    }
  }
  
  func didDisappear() {
    shouldTerminate = true
  }
}

private extension StartView {
  @MainActor
  func setupUI() {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme : .systemBackground
    
    stack.placeInCenter(of: self)
    
    insertSubview(spiral, belowSubview: stack)
    spiral.translatesAutoresizingMaskIntoConstraints = false
    spiral.heightAnchor.constraint(equalTo: spiral.widthAnchor).isActive = true
    spiral.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.5).isActive = true
    spiral.centerXAnchor.constraint(equalTo: logo.centerXAnchor).isActive = true
    spiral.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
    spiral.startRotating(duration: 15)
    
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    let constraint = label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: padding*4)
      constraint.isActive = true
    constraint.identifier = "bottomAnchor"
    
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    button.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -padding*2).isActive = true
    
    logo.translatesAutoresizingMaskIntoConstraints = false
    logo.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.31).isActive = true
    logoText.translatesAutoresizingMaskIntoConstraints = false
    logoText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    
    stack.layer.masksToBounds = false
    logoText.layer.masksToBounds = false
    logoText.layer.shadowPath = UIBezierPath(roundedRect: logoText.bounds, cornerRadius: logoText.bounds.height/2).cgPath
    logoText.layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? Colors.darkTheme.cgColor : UIColor.systemBackground.cgColor
    logoText.layer.shadowOffset = .zero
    logoText.layer.shadowRadius = logoText.bounds.height/2
    logoText.layer.shadowOpacity = 1
    
    logo.layer.masksToBounds = false
    logo.layer.shadowColor = Colors.main.cgColor
    logo.layer.shadowOffset = .zero
    logo.layer.shadowRadius = padding
    logo.layer.shadowOpacity = 0.5
    
    generateItems(maxItems)
  }
  
  @objc
  func handleTap(sender: UIButton) {
    viewInput?.nextScene()
  }
  
  func generateItems(_ count: Int) {
    func getRandomCategory() -> Icon.Category {
      let all = [
        11002, // Anon
        10015, // Plus
        10062, // Comments
        25,    // Style
        40,    // Misc
        10027, // Hot
        10033, // !
        10034, // ?
        10043, // Rocket
        10047, // Eye
        10064, // Binoculars
        10066, // Oval
        10068, // Megaphone
        10081, // Spiral
        10074, // Triangle
        10078, // Thunder
      ].map { Icon.Category(rawValue: $0)! }
      
      let current = Set(items.map { $0.category })
      let diff = Set(all).subtracting(current)
      
      guard diff.count > 1 else { return diff.first! }
      
      return Array(diff)[Int.random(in: 0..<diff.count-1)]
    }
    
    delay(seconds: Double.random(in: 0.2...2)) {[weak self] in
      guard let self = self,
            self.items.count < self.maxItems
      else { return }
      
      let category = getRandomCategory()
      let random = Icon(frame: CGRect(origin: self.randomPoint(), size: .uniform(size: CGFloat.random(in: 20...40))))
      let color = UIColor.random()
      random.iconColor = color
      random.scaleMultiplicator = 1
      random.category = category
      random.transform = .init(scaleX: 0.5, y: 0.5)
      random.alpha = 0
      random.startRotating(duration: Double.random(in: 5...30),
                           repeatCount: .infinity,
                           clockwise: Int.random(in: 1...3) % 2 == 0 ? true : false)
      random.setAnchorPoint(CGPoint(x: Int.random(in: -5...5), y: Int.random(in: -5...5)))
      random.layer.masksToBounds = false
      random.icon.shadowOffset = .zero
      random.icon.shadowOpacity = Float.random(in: 0.3...0.8)
      random.icon.shadowColor = color.cgColor
      random.icon.shadowRadius = random.bounds.width * 0.3
      
      self.insertSubview(random, belowSubview: self.stack)
      self.items.append(random)
      let duration = TimeInterval.random(in: 4...12)
      UIView.animate(withDuration: duration) {
        random.transform = CGAffineTransform(rotationAngle: Int.random(in: 0...9) % 2 == 0 ? .pi : -.pi)//Float.random(in: 0...360).degreesToRadians)
      }
      Timer.scheduledTimer(withTimeInterval: duration*0.9, repeats: false, block: { _ in
        UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) {
          random.alpha = 0
          random.transform = .init(scaleX: 0.5, y: 0.5)
        } completion: { _ in
          random.removeFromSuperview()
          self.items.remove(object: random)
        }
      })
      
      UIView.animate(withDuration: TimeInterval.random(in: 0.3...0.8)) {
        random.alpha = CGFloat.random(in: 0.2...0.6)
        random.transform = .identity
      }
    }
  }
}

extension StartView: Localizable {
  @objc
  func subscribeLocalizable() {
    NotificationCenter.default.addObserver(self, selector: #selector(onLanguageChange), name: Notifications.UI.LanguageChanged, object: nil)
  }
  
  @objc
  func onLanguageChange() {
    if #available(iOS 15, *) {
      button.getSubview(type: UIButton.self)!.configuration?.attributedTitle = AttributedString("getStartedButton".localized.uppercased(),
                                                               attributes: AttributeContainer([
                                                                .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                .foregroundColor: UIColor.white as Any
                                                               ]))
    } else {
      button.getSubview(type: UIButton.self)!.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.uppercased(),
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                    .foregroundColor: UIColor.white as Any
                                                   ]),
                                for: .normal)
    }
        label.text = "welcomeLabel".localized
  }
}

