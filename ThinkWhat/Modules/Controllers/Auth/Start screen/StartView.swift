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
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var logoIcon: Icon = {
    let instance = Icon(category: .Logo, scaleMultiplicator: 1, iconColor: Colors.Logo.Flame.rawValue)
    instance.alpha = 0
    
    return instance
  }()
  private lazy var logoText: Icon = {
    let instance = Icon(category: .LogoText, scaleMultiplicator: 1, iconColor: Colors.Logo.Flame.rawValue)
    instance.alpha = 0
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4.5).isActive = true
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.numberOfLines = 0
    instance.backgroundColor = .clear
    instance.textAlignment = .center
    instance.alpha = 0
    instance.text = ""//welcomeLabel".localized
    instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title3)
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let top = UIView.opaque()
    logoIcon.placeInCenter(of: top,
                           topInset: 0,
                           bottomInset: 0)
    let bottom = UIView.opaque()
    logoText.placeInCenter(of: bottom,
                           topInset: 0,
                           bottomInset: 0)
    let instance = UIStackView(arrangedSubviews: [
      top,
      UIView.verticalSpacer(padding*2),
      label,
      UIView.verticalSpacer(padding),
      bottom
    ])
    instance.axis = .vertical
    instance.spacing = padding*2
    
    return instance
  }()
  public lazy var button: UIButton = {
    let instance = UIButton()
    instance.addTarget(self,
                       action: #selector(self.handleTap(sender:)),
                       for: .touchUpInside)
    if #available(iOS 15, *) {
      var config = UIButton.Configuration.filled()
      config.cornerStyle = .small
      config.contentInsets = .init(top: 0, leading: padding, bottom: 0, trailing: padding)
      config.baseBackgroundColor = Colors.Logo.Flame.rawValue
      config.contentInsets.top = padding
      config.contentInsets.bottom = padding
      config.contentInsets.leading = 20
      config.contentInsets.trailing = 20
      config.attributedTitle = AttributedString("getStartedButton".localized.uppercased(),
                                                attributes: AttributeContainer([
                                                  .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                  .foregroundColor: UIColor.white as Any
                                                ]))
      instance.configuration = config
    } else {
      instance.publisher(for: \.bounds)
        .sink { instance.cornerRadius = $0.width * 0.025 }
        .store(in: &subscriptions)
      instance.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.uppercased(),
                                                     attributes: [
                                                      .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                      .foregroundColor: UIColor.white as Any
                                                     ]),
                                  for: .normal)
    }
    
    return instance
  }()
  
  
  
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
}

extension StartView: StartControllerOutput {
  func didAppear() {
    logoIcon.transform = .init(scaleX: 0.75, y: 0.75)
    logoText.transform = .init(scaleX: 0.75, y: 0.75)
    label.transform = .init(scaleX: 0.75, y: 0.75)
    
    UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn) { [weak self] in
      guard let self = self else { return }
      
      self.label.transform = .identity
      self.label.alpha = 1
      
      Task {
        let phrase = "welcomeLabel".localized
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
    } completion: { [weak self] _ in
      guard let self = self,
            let constraint = self.button.getConstraint(identifier: "bottomAnchor")
      else { return }
      
      self.setNeedsLayout()
      UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = -self.padding*4
        self.logoText.transform = .identity
        self.logoText.alpha = 1
        self.layoutIfNeeded()
      }
    }
    
    UIView.animate(withDuration: 0.75, delay: 0.2, options: .curveEaseIn) { [weak self] in
      guard let self = self else { return }
      
//      [weak self] _ in
//        guard let self = self else { return }
        
        
      
      
      self.logoIcon.transform = .identity
      self.logoIcon.alpha = 1
    }
  }
}

private extension StartView {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    setNeedsLayout()
    layoutIfNeeded()
    
    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    let constraint = button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 100)
      constraint.isActive = true
    constraint.identifier = "bottomAnchor"
    
    stack.placeInCenter(of: self)
    logoIcon.translatesAutoresizingMaskIntoConstraints = false
    logoIcon.heightAnchor.constraint(equalTo: logoIcon.widthAnchor).isActive = true
    logoIcon.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
    logoText.translatesAutoresizingMaskIntoConstraints = false
    logoText.widthAnchor.constraint(equalTo: logoIcon.widthAnchor, multiplier: 1.2).isActive = true
  }
  
  @objc
  func handleTap(sender: UIButton) {
    viewInput?.nextScene()
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
      button.configuration?.attributedTitle = AttributedString("getStartedButton".localized.uppercased(),
                                                               attributes: AttributeContainer([
                                                                .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                                .foregroundColor: UIColor.white as Any
                                                               ]))
    } else {
      button.setAttributedTitle(NSAttributedString(string: "getStartedButton".localized.uppercased(),
                                                   attributes: [
                                                    .font: UIFont(name: Fonts.Bold, size: 20) as Any,
                                                    .foregroundColor: UIColor.white as Any
                                                   ]),
                                for: .normal)
    }
    label.text = #keyPath(WelcomeView.welcomeLabel).localized
  }
}
