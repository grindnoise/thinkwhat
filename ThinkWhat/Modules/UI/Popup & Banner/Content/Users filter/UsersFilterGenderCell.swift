//
//  UsersFilterGenderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UsersFilterGenderCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public var selectedGender: Enums.User.Gender = .Unassigned {
    didSet {
      guard oldValue != selectedGender else { return }
      
      switch selectedGender {
      case .Unassigned:
        genderControl.selectedSegmentIndex = 2
      case .Female:
        genderControl.selectedSegmentIndex = 1
      case .Male:
        genderControl.selectedSegmentIndex = 0
      }
    }
  }
  //UI
  public var color: UIColor = Constants.UI.Colors.System.Red.rawValue {
    didSet {
      genderControl.selectedSegmentTintColor = color
    }
  }
  //Publishers
  public let genderPublisher = CurrentValueSubject<Enums.User.Gender?, Never>(nil)
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //Logic
  private let minAge = 18
  private let maxAge = 99
  
  //UI
  private let padding: CGFloat = 8
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.text = "gender".localized.capitalized
    instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    instance.textAlignment = .left
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
    //        instance.publisher(for: \.bounds, options: .new)
    //            .sink { [weak self] rect in
    //                guard let self = self,
    //                      instance.getConstraint(identifier: "height").isNil,
    //                      let text = instance.text
    //                else { return }
    //
    //                let constraint = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
    //                constraint.identifier = "height"
    //                constraint.isActive = true
    //            }
    //            .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var genderControl: UISegmentedControl = {
    let instance = UISegmentedControl(items: [
      UIImage(systemName: "mustache.fill") as Any,
      UIImage(systemName: "mouth.fill") as Any,
      "all_genders".localized.lowercased()
    ])
    instance.selectedSegmentIndex = 2
    instance.selectedSegmentTintColor = color//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    instance.addTarget(self, action: #selector(self.onGenderSelected(_:)), for: .valueChanged)
    
    let normalAttribute: [NSAttributedString.Key: Any] = [
      .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline) as Any,
      .foregroundColor: UIColor.label
    ]
    instance.setTitleTextAttributes(normalAttribute, for: .normal)
    
    let selectedAttribute: [NSAttributedString.Key: Any] = [
      .font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .subheadline) as Any,
      .foregroundColor: UIColor.white
    ]
    instance.setTitleTextAttributes(selectedAttribute, for: .selected)
    
    return instance
  }()
  private lazy var horizontalStack: UIStackView = {
    let opaque = UIView.opaque()
    opaque.addSubview(genderControl)
    
    let instance = UIStackView(arrangedSubviews: [
      label,
      opaque
    ])
    instance.alignment = .leading
    instance.axis = .horizontal
    instance.spacing = 8
    
    label.translatesAutoresizingMaskIntoConstraints = false
    genderControl.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      label.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.25),
      genderControl.leadingAnchor.constraint(equalTo: opaque.leadingAnchor),
      genderControl.topAnchor.constraint(equalTo: opaque.topAnchor),
      genderControl.bottomAnchor.constraint(equalTo: opaque.bottomAnchor),
    ])
    
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
    super.init(frame: .zero)
    
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
    
    label.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
    genderControl.selectedSegmentTintColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
  }
}

private extension UsersFilterGenderCell {
  func setupUI() {
    contentView.backgroundColor = .clear
    clipsToBounds = false
    
    contentView.addSubview(horizontalStack)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
      horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
      horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    ])
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
  
  @objc
  func onGenderSelected(_ value: UISegmentedControl) {
    switch value.selectedSegmentIndex {
    case 0:
      genderPublisher.send(.Male)
    case 1:
      genderPublisher.send(.Female)
    default:
      genderPublisher.send(.Unassigned)
    }
  }
}


