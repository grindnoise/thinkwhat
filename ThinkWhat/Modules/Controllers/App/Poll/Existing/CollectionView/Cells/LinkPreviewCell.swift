//
//  LinkPreviewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import LinkPresentation

class LinkPreviewCell: UICollectionViewCell {
  
  // MARK: - Overriden properties
  override var isSelected: Bool { didSet { updateAppearance() } }
  
  // MARK: - Public Properties
  var item: Survey! {
    didSet {
      guard !item.isNil, data.isNil, let url = item.url else { return }
      
      setupUI()
      
      LPMetadataProvider().startFetchingMetadata(for: url) { [weak self] data, error in
        guard let self = self,
              let data = data,
              error.isNil
        else { return }
        
        self.data = data
       
//        Task {
////          await MainActor.run {
//            self.linkPreview.metadata = data
////          }
//        }
//
//        delayAsync(delay: 1) {  [weak self] in
//          guard let self = self,
//                let shimmer = self.linkPreview.getSubview(type: Shimmer.self)
//          else { return }
//
//          shimmer.stopShimmering()
//        }
      }
    }
  }
  public var tapPublisher = PassthroughSubject<URL, Never>()
  public var mode: PollCollectionView.ViewMode = .Default
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .scaleAspectFit
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Colors.cellHeader
    instance.text = "web_link".localized.uppercased()
    instance.font = Fonts.cellHeader

    let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
    heightConstraint.identifier = "height"
    heightConstraint.priority = .defaultHigh
    heightConstraint.isActive = true

    instance.publisher(for: \.bounds, options: .new)
      .sink { [weak self] rect in
        guard let self = self,
              let constraint = instance.getConstraint(identifier: "height")
        else { return }

        self.setNeedsLayout()
        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)

    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView()
    instance.image = UIImage(systemName: "chevron.down")
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    
    return instance
  }()
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [headerImage,
                                                  headerLabel,
                                                  disclosureIndicator,
                                                  UIView.opaque()])
    instance.alignment = .center
    let constraint = instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font))
    constraint.identifier = "height"
    constraint.isActive = true
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let verticalStack = UIStackView()//arrangedSubviews: [horizontalStack, imageContainer])
    if mode == .Default {
      verticalStack.addArrangedSubview(horizontalStack)
    }
    verticalStack.addArrangedSubview(shadowView)
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    
    return verticalStack
  }()
  // Constraints
  private var closedConstraint: NSLayoutConstraint!
  private var openConstraint: NSLayoutConstraint!
  private lazy var shadowView: UIView = {
    let instance = UIView.opaque()
    instance.layer.masksToBounds = false
    instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.35).cgColor
    instance.layer.shadowOffset = .zero
    instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    instance.layer.shadowRadius = padding*0.65///2
    instance.publisher(for: \.bounds)
      .sink { instance.layer.shadowPath = UIBezierPath(roundedRect: $0, cornerRadius: $0.width*0.025).cgPath }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var linkPreview: LPLinkView = {
    let instance = LPLinkView()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
    instance.place(inside: shadowView)
    instance.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink { instance.cornerRadius = $0.width*0.025 }
      .store(in: &subscriptions)
    let shimmer = Shimmer()
    shimmer.layer.zPosition = 100
    shimmer.place(inside: instance)
    shimmer.startShimmering()
    
    return instance
  }()
  private let padding: CGFloat = 8
  // Cache data
  private var data: LPLinkMetadata? {
    didSet {
      guard !data.isNil else { return }
      
      DispatchQueue.main.async { [weak self] in
        guard let self = self,
              let shimmer = self.linkPreview.getSubview(type: Shimmer.self)
        else { return }
        
        self.linkPreview.metadata = self.data!
        shimmer.stopShimmering()
        shimmer.removeFromSuperview()
      }
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
    
//    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : !isSelected ? 1 : 0
    //        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
    //        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        if let imageView = icon.get(all: UIImageView.self).first {
    //            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        }
    
//    //Set dynamic font size
//    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
//
//    disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
//                                             forTextStyle: .caption1)
//    guard let constraint = horizontalStack.getConstraint(identifier: "height"),
//          let constraint_2 = disclosureLabel.getConstraint(identifier: "width")
//    else { return }
//
//    setNeedsLayout()
//    constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
//    constraint_2.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
//    layoutIfNeeded()
  }
}

// MARK: - Private methods
private extension LinkPreviewCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    contentView.addSubview(verticalStack)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    verticalStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding*2),
      verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
    ])
    
    closedConstraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    closedConstraint.priority = .defaultLow
    
    openConstraint = linkPreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    openConstraint.priority = .defaultLow
    
    updateAppearance(animated: false)
//
//    if let subview = linkPreview.viewByClassName(className: "LPFlippedView") {
//      subview.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
//    }
  }
  
  /// Updates the views to reflect changes in selection
  private func updateAppearance(animated: Bool = true) {
    closedConstraint?.isActive = isSelected
    openConstraint?.isActive = !isSelected
    
    guard animated else {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2)
      disclosureIndicator.transform = isSelected ? upsideDown : .identity
      shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : !isSelected ? 1 : 0
      
      return
    }
    UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) { [weak self] in
      guard let self = self else { return }
      
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2)
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
      self.shadowView.alpha = !self.isSelected ? 1 : 0
    }
  }
  
  @objc
  private func openURL() {
    guard let url = item.url else { return }
    
    tapPublisher.send(url)
  }
}
