//
//  UserNotificationContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserBannerContentView: UIView {
  
  enum Mode: String {
    case Username = ""
    case Subscribe = "subscribe_to_user_notification"
    case Unsubscribe = "unsubscribe_from_user_notification"
    case NotifyOnPublication = "user_publication_notification_on"
    case DontNotifyOnPublication = "user_publication_notification_off"
    
    func localizedDescription(userprofile: Userprofile) -> String {
      switch self {
      case .Username:
        return userprofile.username
      case .Subscribe:
        return self.rawValue.localized + " " + userprofile.username + " ✅"
      case .Unsubscribe:
        return self.rawValue.localized + " " + userprofile.username + " ⛔️"
      case .NotifyOnPublication:
        return "user_publication_notification_begin".localized + userprofile.username + self.rawValue.localized + " 🔔"
      case .DontNotifyOnPublication:
        return "user_publication_notification_begin".localized + userprofile.username + self.rawValue.localized + " 🔕"
      }
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let mode: Mode
  private let textColor: UIColor
  private weak var userprofile: Userprofile!
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: userprofile.image)
    instance.contentMode = .scaleAspectFill
    instance.clipsToBounds = true
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    instance.publisher(for: \.bounds)
      .sink { instance.cornerRadius = $0.height/2 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = textColor
    instance.numberOfLines = 0
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .subheadline)
    instance.text = mode.localizedDescription(userprofile: userprofile)
    instance.textAlignment = .center
    
    return instance
  }()
  private lazy var stack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      imageView,
      label
    ])
    instance.axis = .horizontal
    instance.alignment = .center
    instance.spacing = 8
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.15).isActive = true
    
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
  init(mode: Mode,
       userprofile: Userprofile,
       textColor: UIColor = .label) {
    self.userprofile = userprofile
    self.mode = mode
    self.textColor = textColor
    
    super.init(frame: .zero)
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension UserBannerContentView {
  func setupUI() {
    backgroundColor = .clear
    stack.place(inside: self)
  }
}

