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
    case Balance = "balance"
    case DateJoined = "userprofile_is_in_community"
    case Publications = "userprofile_publications_created"
    case Votes = "userprofile_votes_received"
    case Completed = "completed"//"userprofile_completed_surveys"
    case CommentsReceived = "userprofile_comments_received"
    case CommentsPosted = "userprofile_comments_posted"
    case Subscribers = "userprofile_subscribers"
    case Subscriptions = "userprofile_subscriptions"
  }
  
  // MARK: - Public properties
  public var mode: Mode!
  public weak var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      setupUI()
      setTasks()
    }
  }
  //Publishers
  public let buttonPublisher = PassthroughSubject<Bool, Never>()
  //UI
  public var color = UIColor.systemBlue {
    didSet {
      updateUI()
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 10
  private lazy var stack: UIStackView = {
    let opaque = UIView.opaque()
    let instance = UIStackView(arrangedSubviews: [
      leftLabel,
      opaque,
      rightButton,
    ])
    instance.axis = .horizontal
    instance.spacing = padding/2
    instance.layer.masksToBounds = false
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: 100,
                                                                    font: leftLabel.font)).isActive  = true
    
    return instance
  }()
  private lazy var leftLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .label
    instance.font = UIFont.scaledFont(fontName: Fonts.Rubik.Regular,
                                      forTextStyle: .body)
    
    return instance
  }()
//  private lazy var rightLabel: UILabel = {
//    let instance = UILabel()
//    instance.textColor = .label
//    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .body)
//
//    return instance
//  }()
  private lazy var rightButton: UIButton = {
    let instance = UIButton()
    instance.imageEdgeInsets.left = padding/4
//    instance.imageEdgeInsets.right = padding/2
    instance.semanticContentAttribute = .forceRightToLeft
    instance.adjustsImageWhenHighlighted = false
    instance.layer.masksToBounds = false
    instance.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
//    instance.setAttributedTitle(NSAttributedString(string: String(describing: compatibility.surveys.count), attributes: [
//      .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body)!,
//      .foregroundColor: compatibility.topic.tagColor
//    ]), for: .normal)
    instance.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    instance.setImage(UIImage(systemName: ("chevron.right"), withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
    instance.imageView?.tintColor = .clear
    
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
    guard let mode = mode else { return }
    
    leftLabel.text = mode.rawValue.localized
    
    updateUI()
    
    stack.place(inside: contentView,
                bottomPriority: .defaultLow)
  }
  
  func updateUI() {
    guard let mode = mode,
          let userprofile = userprofile
    else { return }
    
    switch mode {
    case .Balance:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.balance),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                                .foregroundColor: userprofile.publicationsTotal.isZero ? UIColor.label : color
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = true
      rightButton.imageView?.tintColor = color
    case .DateJoined:
      let fullComponents = Date.dateComponents(from: userprofile.dateJoined, to: Date())
      //
      //      let formatter = DateComponentsFormatter()
      //      formatter.unitsStyle = .full
      //      formatter.includesApproximationPhrase = true
      //      formatter.includesTimeRemainingPhrase = true
      //      formatter.allowedUnits = [.year]
      //      formatter.string(from: years)
      
      var components: DateComponents!
      
      if let years = fullComponents.year, years > 0 {
        components = Calendar.current.dateComponents([.year], from: userprofile.dateJoined, to: Date())
      } else if let months = fullComponents.month, months > 0 {
        components = Calendar.current.dateComponents([.month], from: userprofile.dateJoined, to: Date())
      } else if let days = fullComponents.day, days >= 0 {
        components = Calendar.current.dateComponents([.day], from: userprofile.dateJoined, to: Date())
      }

      guard let text = DateComponentsFormatter.localizedString(from: components, unitsStyle: .full) else { return }
      
      let attributedTitle = NSAttributedString(string: text,
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = false
    case .Publications:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.publicationsTotal),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                                .foregroundColor: userprofile.publicationsTotal.isZero ? UIColor.label : color
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = userprofile.publicationsTotal.isZero ? false : true
      rightButton.imageView?.tintColor = color
    case .Votes:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.votesReceivedTotal.roundedWithAbbreviations),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = false
    case .Completed:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.completeTotal),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = false
    case .CommentsReceived:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.commentsReceivedTotal),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = false
    case .CommentsPosted:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.commentsTotal.roundedWithAbbreviations),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
//                                                .foregroundColor: userprofile.commentsTotal.isZero ? UIColor.label : color
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = userprofile.commentsTotal.isZero ? false : true
//      disclosureIndicator.alpha = userprofile.commentsTotal.isZero ? 0 : 1
    case .Subscribers:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.subscribersTotal.roundedWithAbbreviations),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                                .foregroundColor: userprofile.subscribersTotal.isZero ? UIColor.label : color
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = userprofile.subscribersTotal.isZero ? false : true
      rightButton.imageView?.tintColor =  !userprofile.subscribersTotal.isZero ? color : .clear
    case .Subscriptions:
      let attributedTitle = NSAttributedString(string: String(describing: userprofile.subscriptionsTotal.roundedWithAbbreviations),
                                               attributes: [
                                                .font: UIFont.scaledFont(fontName: Fonts.Rubik.Regular, forTextStyle: .body) as Any,
                                                .foregroundColor: userprofile.subscriptionsTotal.isZero ? UIColor.label : color
                                               ])
      rightButton.setAttributedTitle(attributedTitle, for: .normal)
      rightButton.isUserInteractionEnabled = userprofile.subscriptionsTotal.isZero ? false : true
      rightButton.imageView?.tintColor =  !userprofile.subscriptionsTotal.isZero ? color : .clear
    }
  }
  
  @objc
  func handleTap() {
    buttonPublisher.send(true)
  }
  
  func setTasks() {
    guard let userprofile = userprofile else { return }
    
    userprofile.$subscriptionsTotal
      .filter { [unowned self] _ in self.mode == .Subscriptions }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.updateUI() }
      .store(in: &subscriptions)
    
    userprofile.$subscribersTotal
      .filter { [unowned self] _ in self.mode == .Subscribers }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.updateUI() }
      .store(in: &subscriptions)
    
    userprofile.$publicationsTotal
      .filter { [unowned self] _ in self.mode == .Publications }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.updateUI() }
      .store(in: &subscriptions)
    
    userprofile.$votesReceivedTotal
      .filter { [unowned self] _ in self.mode == .Votes }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.updateUI() }
      .store(in: &subscriptions)
    
    userprofile.$commentsReceivedTotal
      .filter { [unowned self] _ in self.mode == .CommentsReceived }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in self.updateUI() }
      .store(in: &subscriptions)
    
//    userprofile.$favoritesTotal
//      .receive(on: DispatchQueue.main)
//      .sink { [unowned self] _ in self.updateUI() }
//      .store(in: &subscriptions)
  }
}


