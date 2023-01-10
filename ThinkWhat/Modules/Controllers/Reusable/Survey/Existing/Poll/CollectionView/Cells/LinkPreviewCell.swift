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
      guard !item.isNil, !item.url.isNil else { return }
      guard let url = item.url else { return }
      LPMetadataProvider().startFetchingMetadata(for: url) { [weak self] data, error in
        guard let self = self,
              let data = data,
              error.isNil
        else { return }
        
        Task {
//          await MainActor.run {
            self.linkPreview.metadata = data
//          }
        }

        delayAsync(delay: 1) {  [weak self] in
          guard let self = self,
                let shimmer = self.linkPreview.getSubview(type: Shimmer.self)
          else { return }
          
          shimmer.stopShimmering()
        }
      }
    }
  }
  public var tapPublisher = PassthroughSubject<URL, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var disclosureLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
    instance.text = "web_link".localized.uppercased()
    
    let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
    constraint.identifier = "width"
    constraint.isActive = true
    
    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView()
    instance.image = UIImage(systemName: "chevron.down")
    instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
    instance.tintColor = .secondaryLabel
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    
    return instance
  }()
  private lazy var icon: UIView = {
    let imageView = UIImageView(image: UIImage(systemName: "link"))
    imageView.tintColor = .secondaryLabel
    imageView.contentMode = .center
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/1).isActive = true
    imageView.publisher(for: \.bounds)
      .filter { $0 != .zero }
      .sink {
        imageView.image = UIImage(systemName: "link",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: $0.height*0.75))
      }
      .store(in: &subscriptions)
    
    return imageView
  }()
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
    instance.alignment = .center
    let constraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)!))
    constraint.identifier = "height"
    constraint.isActive = true
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    return instance
  }()
  private lazy var verticalStack: UIStackView = {
    let opaque = UIView()
    opaque.backgroundColor = .clear
    opaque.addSubview(horizontalStack)
    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
    horizontalStack.leadingAnchor.constraint(equalTo: opaque.leadingAnchor, constant: padding).isActive = true
    horizontalStack.topAnchor.constraint(equalTo: opaque.topAnchor).isActive = true
    horizontalStack.bottomAnchor.constraint(equalTo: opaque.bottomAnchor).isActive = true
    
    let verticalStack = UIStackView(arrangedSubviews: [opaque, linkPreview])
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    return verticalStack
  }()
  // Constraints
  private var closedConstraint: NSLayoutConstraint!
  private var openConstraint: NSLayoutConstraint!
  private lazy var linkPreview: LPLinkView = {
    let instance = LPLinkView()
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
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
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    //        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white
    //        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        if let imageView = icon.get(all: UIImageView.self).first {
    //            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    //        }
    
    //Set dynamic font size
    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
    
    disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                             forTextStyle: .caption1)
    guard let constraint = horizontalStack.getConstraint(identifier: "height"),
          let constraint_2 = disclosureLabel.getConstraint(identifier: "width")
    else { return }
    
    setNeedsLayout()
    constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
    constraint_2.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
    layoutIfNeeded()
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
    
    setNeedsLayout()
    layoutIfNeeded()
    
    closedConstraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    closedConstraint.priority = .defaultLow
    
    openConstraint = linkPreview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    openConstraint.priority = .defaultLow
    
    updateAppearance(animated: false)
  }
  
  /// Updates the views to reflect changes in selection
  private func updateAppearance(animated: Bool = true) {
    closedConstraint?.isActive = isSelected
    openConstraint?.isActive = !isSelected
    
    guard animated else {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2)
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
      return
    }
    UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2)
      self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
    }
  }
  
  @objc
  private func openURL() {
    guard let url = item.url else { return }
    
    tapPublisher.send(url)
  }
}
