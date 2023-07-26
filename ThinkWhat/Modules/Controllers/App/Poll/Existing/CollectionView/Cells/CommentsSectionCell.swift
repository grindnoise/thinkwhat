//
//  CommentsSectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 08.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CommentsSectionCell: UICollectionViewCell {
  
  // MARK: - Overridden properties
  override var isSelected: Bool {
    didSet {
      guard let item = item,
            item.isCommentingAllowed
      else { return }
      
      updateAppearance()
    }
  }
  
  
  // MARK: - Public Properties
  var item: Survey! {
    didSet {
      guard let item = item else { return }
      collectionView.survey = item
      disclosureIndicator.alpha = item.isCommentingAllowed ? 1 : 0
      
      if item.isCommentingAllowed {
        headerLabel.text = "comments".localized.uppercased() + " (\(String(describing: item.commentsTotal)))"
      } else {
        headerLabel.text = "comments_disabled".localized.uppercased()
        closedConstraint.isActive = true
        openConstraint.isActive = false
      }
      
      item.reference.commentsTotalPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] count in
          guard let self = self else { return }
          
          self.headerLabel.text = "comments".localized.uppercased() + " (\(String(describing: count)))"
          guard let constraint = self.headerLabel.getConstraint(identifier: "width") else { return }
          self.horizontalStack.setNeedsLayout()
          constraint.constant = self.headerLabel.text!.width(withConstrainedHeight: 100, font: self.headerLabel.font)
          self.horizontalStack.layoutIfNeeded()
        }
        .store(in: &subscriptions)
    }
  }
  //Publishers
  public var updateStatsPublisher = PassthroughSubject<[Comment], Never>()
  public var commentPublisher = PassthroughSubject<String, Never>()
  public var anonCommentPublisher = PassthroughSubject<[String: String], Never>()
  public var replyPublisher = PassthroughSubject<[Comment: String], Never>()
  public var anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
  public var claimPublisher = PassthroughSubject<Comment, Never>()
  public var deletePublisher = PassthroughSubject<Comment, Never>()
  public var threadPublisher = PassthroughSubject<Comment, Never>()
  public var paginationPublisher = PassthroughSubject<[Comment], Never>()
  public var boundsPublisher = PassthroughSubject<Bool, Never>()
  //Publishers
//  public let commentSubject = CurrentValueSubject<String?, Never>(nil)
//  public let anonCommentSubject = CurrentValueSubject<[String: String]?, Never>(nil)
//  public let replySubject = CurrentValueSubject<[Comment: String]?, Never>(nil)
//  public let anonReplySubject = CurrentValueSubject<[Comment: [String: String]]?, Never>(nil)
//  public let claimSubject = CurrentValueSubject<Comment?, Never>(nil)
//  public let deleteSubject = CurrentValueSubject<Comment?, Never>(nil)
//  public let commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
//  public let commentsRequestSubject = CurrentValueSubject<[Comment], Never>([])
  
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var headerImage: UIImageView = {
    let instance = UIImageView(image: UIImage(systemName: "bubble.right.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
    instance.tintColor = Colors.cellHeader
    instance.contentMode = .scaleAspectFit
    instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
    
    return instance
  }()
  private lazy var headerLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = Colors.cellHeader
    instance.text = "comments".localized.uppercased()
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
    let verticalStack = UIStackView(arrangedSubviews: [
      horizontalStack,
      collectionView
    ])
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    return verticalStack
  }()
  private lazy var collectionView: CommentsCollectionView = {
    let instance = CommentsCollectionView(rootComment: nil)
    instance.isScrollEnabled = true
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 1)
    constraint.identifier = "height"
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize,
                                       options: .new) { [weak self] view, change in
      guard let self = self,
            let value = change.newValue,
            value != .zero,
            value.height != constraint.constant
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = value.height//min(value.height, UIScreen.main.bounds.height*0.75)
      self.layoutIfNeeded()
      self.boundsPublisher.send(true)
    })
    
    instance.claimPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.claimPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.commentPublisher
      .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.commentPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.replyPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.replyPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.anonCommentPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.anonCommentPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.anonReplyPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.anonReplyPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    //Delete comment
    instance.deletePublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.deletePublisher.send($0)
      }
      .store(in: &self.subscriptions)
    
    instance.paginationPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.paginationPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.threadPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.threadPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.updateStatsPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.updateStatsPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    return instance
  }()
  private lazy var container: UIView = {
    let instance = UIView()
    instance.isUserInteractionEnabled = true
    instance.backgroundColor = .clear
    instance.heightAnchor.constraint(equalToConstant: 400).isActive = true
    collectionView.addEquallyTo(to: instance)
    
    return instance
  }()
  // Constraints
  private var closedConstraint: NSLayoutConstraint!
  private var openConstraint: NSLayoutConstraint!
  
  
  
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
    
    setTasks()
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    threadPublisher = PassthroughSubject<Comment, Never>()
    updateStatsPublisher = PassthroughSubject<[Comment], Never>()
    commentPublisher = PassthroughSubject<String, Never>()
    anonCommentPublisher = PassthroughSubject<[String: String], Never>()
    replyPublisher = PassthroughSubject<[Comment: String], Never>()
    anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
    claimPublisher = PassthroughSubject<Comment, Never>()
    deletePublisher = PassthroughSubject<Comment, Never>()
    paginationPublisher = PassthroughSubject<[Comment], Never>()
    boundsPublisher = PassthroughSubject<Bool, Never>()
  }
  
  // MARK: - Private methods
  private func setupUI() {
    backgroundColor = .clear
    clipsToBounds = true
    
    contentView.addSubview(verticalStack)
    //    contentView.translatesAutoresizingMaskIntoConstraints = false
    verticalStack.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
//      contentView.topAnchor.constraint(equalTo: topAnchor),
//      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding*2),
      verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
    ])
    
    //    setNeedsLayout()
    //    layoutIfNeeded()
    
    closedConstraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    closedConstraint.priority = .defaultLow
    
    openConstraint = collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    openConstraint.priority = .defaultLow
    
    updateAppearance(animated: false)
  }
  
  /// Updates the views to reflect changes in selection
  private func updateAppearance(animated: Bool = true) {
    closedConstraint.isActive = !isSelected
    openConstraint.isActive = isSelected
    
    guard animated else {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
      self.disclosureIndicator.transform = !self.isSelected ? upsideDown : .identity
      return
    }
    UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
      let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
      self.disclosureIndicator.transform = !self.isSelected ? upsideDown : .identity
    }
  }
  
  private func setTasks() {
//    tasks.append(Task { @MainActor [weak self] in
//      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.CommentsTotal) {
//        guard let self = self,
//              let item = self.item,
//              let object = notification.object as? SurveyReference,
//              item.reference == object
//        else { return }
//
//        self.disclosureLabel.text = "comments".localized.uppercased() + " (\(String(describing: item.commentsTotal)))"
//        guard let constraint = self.disclosureLabel.getConstraint(identifier: "width") else { return }
//        self.setNeedsLayout()
//        constraint.constant = self.disclosureLabel.text!.width(withConstrainedHeight: 100, font: self.disclosureLabel.font)
//        self.layoutIfNeeded()
//      }
//    })
  }
  
  
  
  // MARK: - Overriden methods
  //  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
  //    super.traitCollectionDidChange(previousTraitCollection)
  //
  //    //Set dynamic font size
  //    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
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
  //  }
}

// MARK: - CallbackObservable
extension CommentsSectionCell: CallbackObservable {
  func callbackReceived(_ sender: Any) {
    
  }
}
