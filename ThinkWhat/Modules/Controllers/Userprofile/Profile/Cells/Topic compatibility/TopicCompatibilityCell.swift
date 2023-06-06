//
//  TopicCompatibilityCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicCompatibilityCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  public var compatibility: TopicCompatibility! {
    didSet {
      guard !compatibility.isNil else { return }
      
      setupUI()
    }
  }
  //Publishers
  public let disclosurePublisher = PassthroughSubject<TopicCompatibility, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private let lineWidthMultiplier: CGFloat = 0.125
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    let instance = UIStackView(arrangedSubviews: [
//      percentageView,
      //      opaque,
      topicView,
      UIView.opaque(),
      rightButton,
      disclosureIndicator
    ])
    instance.axis = .horizontal
    instance.spacing = padding/2
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: UIFont(name: Fonts.Bold, size: 14)!)).isActive = true
//    instance.heightAnchor.constraint(equalToConstant: compatibility.topic.title.uppercased().height(withConstrainedWidth: 1000,
//                                                                                                    font: UIFont(name: Fonts.Bold, size: 14)!) * 2.25).isActive = true
//    opaque.addSubview(topicView)
//    topicView.translatesAutoresizingMaskIntoConstraints = false
//    topicView.leadingAnchor.constraint(equalTo: opaque.leadingAnchor, constant: padding/2).isActive = true
//    topicView.centerYAnchor.constraint(equalTo: opaque.centerYAnchor).isActive = true
    
    return instance
  }()
//  private lazy var label: UILabel = {
//    let instance = UILabel()
//    instance.textColor = compatibility.topic.tagColor
//    instance.text = compatibility.topic.title.localized.uppercased()
//    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
//
//    let constraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
//    constraint.identifier = "height"
//    constraint.priority = .defaultHigh
//    constraint.isActive = true
//
//    instance.publisher(for: \.bounds, options: .new)
//      .sink { [weak self] rect in
//        guard let self = self else { return }
//
//        self.setNeedsLayout()
//        constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
//        self.layoutIfNeeded()
//      }
//      .store(in: &subscriptions)
//
//    return instance
//  }()
  private lazy var descriptionLabel: UILabel = {
    let instance = UILabel()
    instance.textAlignment = .center
    instance.numberOfLines = 0
    instance.text = "100%"
    
    return instance
  }()
//  private lazy var percentageLabel: UILabel = {
//    let instance = UILabel()
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
//    instance.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink { instance.font = UIFont(name: Fonts.Semibold, size: $0.height * 0.35) }
//      .store(in: &subscriptions)
//    instance.textAlignment = .center
//    instance.numberOfLines = 1
//
//    return instance
//  }()
//  private lazy var percentageView: UIView = {
//    let instance = UIView()
//    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
//    instance.layer.addSublayer(backgroundCircle)
//    instance.layer.addSublayer(foregroundCircle)
//    instance.publisher(for: \.bounds)
//      .filter { $0 != .zero }
//      .sink { [weak self] rect in
//        guard let self = self else { return }
//
//        let lineWidth = rect.width * self.lineWidthMultiplier
//        self.backgroundCircle.lineWidth = lineWidth
//        self.backgroundCircle.path = UIBezierPath(ovalIn: rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)).cgPath
//
//        guard !self.compatibility.isNil,
//              self.compatibility.percent != 0
//        else { return }
//
//        self.foregroundCircle.path = self.getProgressPath(in: rect, progress: Double(self.compatibility.percent), lineWidth: lineWidth)
//      }
//      .store(in: &subscriptions)
//
//    percentageLabel.placeInCenter(of: instance, heightMultiplier: 0.75)
//
//    return instance
//  }()
  private lazy var backgroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1).cgColor : UIColor.systemGray.withAlphaComponent(0.1).cgColor
    instance.lineCap = .round
    
    return instance
  }()
  private lazy var foregroundCircle: CAShapeLayer = {
    let instance = CAShapeLayer()
    instance.path = UIBezierPath(ovalIn: .zero).cgPath
    instance.fillColor = UIColor.clear.cgColor
    instance.strokeColor = compatibility.topic.tagColor.cgColor
    instance.lineCap = .round
    
    return instance
  }()
  private lazy var topicView: UIStackView = {
    let topicIcon = Icon(category: compatibility.topic.iconCategory)
    topicIcon.iconColor = .white
    topicIcon.isRounded = false
    topicIcon.clipsToBounds = false
    topicIcon.scaleMultiplicator = 1.85
    topicIcon.heightAnchor.constraint(equalTo: topicIcon.widthAnchor, multiplier: 1/1).isActive = true
    
    let topicTitle = InsetLabel()
    topicTitle.font = UIFont(name: Fonts.Bold, size: 14)
    topicTitle.text = compatibility.topic.title.uppercased() + ": \(compatibility.percent)%"
    topicTitle.textColor = .white
//    topicTitle.isUserInteractionEnabled = true
//    topicTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    topicTitle.insets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: padding)
    
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.backgroundColor = compatibility.topic.tagColor
    instance.axis = .horizontal
    instance.spacing = 2
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var rightButton: UIButton = {
    let instance = UIButton()
    instance.tintColor = .systemBlue
    instance.contentHorizontalAlignment = .right
    instance.addTarget(self, action: #selector(self.disclose), for: .touchUpInside)
    
    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "chevron.right"))
    instance.accessibilityIdentifier = "chevron"
    instance.clipsToBounds = true
    instance.tintColor = .label
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.disclose)))
    
    let constraint = instance.widthAnchor.constraint(equalToConstant: compatibility.topic.title.uppercased().height(withConstrainedWidth: 1000,
                                                                                                                    font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)!)/3)
    constraint.identifier = "widthAnchor"
    constraint.isActive = true
    
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
  
  //    override func prepareForReuse() {
  //        super.prepareForReuse()
  //
  //        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
  //        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
  //        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
  //    }
}

private extension TopicCompatibilityCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true

//    percentageLabel.text = "\(compatibility.percent)%"
    let attributedTitle = NSAttributedString(string: String(describing: compatibility.surveys.count.roundedWithAbbreviations),
                                             attributes: [
                                              .font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                                              .foregroundColor: compatibility.topic.tagColor
                                             ])
    rightButton.setAttributedTitle(attributedTitle, for: .normal)
    disclosureIndicator.tintColor = compatibility.topic.tagColor
    
    stack.place(inside: self,
                insets: .init(top: padding, left: 0, bottom: padding, right: 0),
                bottomPriority: .defaultLow)
  }
  
  func getProgressPath(in rect: CGRect, progress: Double, lineWidth: CGFloat) -> CGPath {
    let startAngle = -CGFloat.pi / 2
    foregroundCircle.lineWidth = lineWidth
    return UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY),
                        radius: rect.width/2 - lineWidth/2,
                        startAngle: startAngle,
                        endAngle: CGFloat.pi * 2 * progress / 100 + startAngle,
                        clockwise: true).cgPath
  }
//  @objc
//  func hintTapped() {
//    let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
//                                                          icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
//                                                          text: "userprofile_сompatibility_hint",
//                                                          tintColor: .clear,
//                                                          fontName: Fonts.Regular,
//                                                          textStyle: .headline,
//                                                          textAlignment: .natural),
//                           contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
//                           isModal: false,
//                           useContentViewHeight: true,
//                           shouldDismissAfter: 2)
//    banner.didDisappearPublisher
//      .sink { _ in banner.removeFromSuperview() }
//      .store(in: &self.subscriptions)
//  }
  
  @objc
  func disclose() {
    disclosurePublisher.send(compatibility)
  }
}


