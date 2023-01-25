//
//  UserStatsPlainCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.01.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserStatsPlainCell: UICollectionViewListCell {
  
  enum Mode: String {
    case DateJoined = "userprofile_is_in_community"
  }
  
  // MARK: - Public properties
  public var mode: Mode!
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      setupUI()
    }
  }
  //Publishers
  //    public let topicPublisher = PassthroughSubject<Topic, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    let instance = UIStackView(arrangedSubviews: [
      leftLabel,
      opaque,
      
    ])
    instance.axis = .horizontal
    instance.spacing = 0
    
    return instance
  }()
  private lazy var leftLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    
    return instance
  }()
  private lazy var rightLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .label
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
    
    return instance
  }()
  
  
  
  // MARK: - Destructor
  deinit {
    observers.forEach { $0.invalidate() }
    subscriptions.forEach { $0.cancel() }
    NotificationCenter.default.removeObserver(self)
#if DEBUG
    print("\(String(describing: type(of: self))).\(#function)")
#endif
  }
  
  
  
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
  }
}

private extension UserStatsPlainCell {
  @MainActor
  func setupUI() {
    guard let mode = mode,
          let userprofile = userprofile
    else { return }
    
    switch mode {
    case .DateJoined:
      stack.addArrangedSubview(rightLabel)
      leftLabel.text = mode.rawValue.uppercased()
      
      let fullComponents = Date.dateComponents(from: userprofile.dateJoined, to: Date())
//
//      let formatter = DateComponentsFormatter()
//      formatter.unitsStyle = .full
//      formatter.includesApproximationPhrase = true
//      formatter.includesTimeRemainingPhrase = true
//      formatter.allowedUnits = [.year]
//      formatter.string(from: years)
      
      if let years = fullComponents.year, years > 0 {
        let components = Calendar.current.dateComponents([.year], from: userprofile.dateJoined, to: Date())
        rightLabel.text = DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
      } else if let months = fullComponents.month, months > 0 {
        let components = Calendar.current.dateComponents([.month], from: userprofile.dateJoined, to: Date())
        rightLabel.text = DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
      } else if let days = fullComponents.day, days > 0 {
        let components = Calendar.current.dateComponents([.day], from: userprofile.dateJoined, to: Date())
        rightLabel.text = DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
      }
    }
    
    stack.place(inside: self,
                insets: .uniform(size: padding))
  }
}



