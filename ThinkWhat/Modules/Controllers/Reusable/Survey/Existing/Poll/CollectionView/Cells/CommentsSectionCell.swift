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
      guard !item.isNil else { return }
      collectionView.survey = item
      disclosureIndicator.alpha = item.isCommentingAllowed ? 1 : 0
      
      if item.isCommentingAllowed {
        disclosureLabel.text = "comments".localized.uppercased() + " (\(String(describing: item.commentsTotal)))"
      } else {
        disclosureLabel.text = "comments_disabled".localized.uppercased()
        closedConstraint.isActive = true
        openConstraint.isActive = false
      }
      //      let constraint = collectionView.heightAnchor.constraint(equalToConstant: 1)
      //      constraint.priority = .defaultHigh
      //      constraint.identifier = "height"
      //      constraint.isActive = true
      //
      //      if let labelConstraint = disclosureLabel.getConstraint(identifier: "width") {
      //        labelConstraint.constant = disclosureLabel.text!.width(withConstrainedHeight: disclosureLabel.bounds.height, font: disclosureLabel.font)
      //      }
      //
      //      setNeedsLayout()
      //      layoutIfNeeded()
    }
  }
  //Publishers
  public var commentPublisher = PassthroughSubject<String, Never>()
  public var anonCommentPublisher = PassthroughSubject<[String: String], Never>()
  public var replyPublisher = PassthroughSubject<[Comment: String], Never>()
  public var anonReplyPublisher = PassthroughSubject<[Comment: [String: String]], Never>()
  public var claimPublisher = PassthroughSubject<Comment, Never>()
  public var deletePublisher = PassthroughSubject<Comment, Never>()
  public var threadPublisher = PassthroughSubject<Comment, Never>()
  public var paginationPublisher = PassthroughSubject<[Comment], Never>()
  //Publishers
//  public let commentSubject = CurrentValueSubject<String?, Never>(nil)
//  public let anonCommentSubject = CurrentValueSubject<[String: String]?, Never>(nil)
//  public let replySubject = CurrentValueSubject<[Comment: String]?, Never>(nil)
//  public let anonReplySubject = CurrentValueSubject<[Comment: [String: String]]?, Never>(nil)
//  public let claimSubject = CurrentValueSubject<Comment?, Never>(nil)
//  public let deleteSubject = CurrentValueSubject<Comment?, Never>(nil)
//  public let commentThreadSubject = CurrentValueSubject<Comment?, Never>(nil)
//  public let commentsRequestSubject = CurrentValueSubject<[Comment], Never>([])
  public var lastPostedComment: Comment? {
    didSet {
      collectionView.lastPostedComment = lastPostedComment
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  // Stacks
  private lazy var disclosureLabel: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
    instance.text = "comments".localized.uppercased()
    
//    let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
//    constraint.identifier = "width"
//    constraint.isActive = true
    
    return instance
  }()
  private lazy var disclosureIndicator: UIImageView = {
    let instance = UIImageView()
    instance.image = UIImage(systemName: "chevron.down")
    instance.tintColor = .secondaryLabel
    instance.contentMode = .center
    instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
    
    return instance
  }()
  private lazy var icon: UIView = {
    let imageView = UIImageView(image: UIImage(systemName: "bubble.right.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: "1".height(withConstrainedWidth: 100,
                                                                                                                    font: disclosureLabel.font)*0.75)))
    imageView.tintColor = .secondaryLabel
    imageView.contentMode = .center
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/1).isActive = true
    
    return imageView
  }()
  private lazy var horizontalStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      icon,
      disclosureLabel,
      disclosureIndicator
    ])
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
    
    let verticalStack = UIStackView(arrangedSubviews: [
      opaque,
      collectionView
    ])
    verticalStack.axis = .vertical
    verticalStack.spacing = padding
    return verticalStack
  }()
  private lazy var collectionView: CommentsCollectionView = {
    let instance = CommentsCollectionView(rootComment: nil)
    
    let constraint = instance.heightAnchor.constraint(equalToConstant: 1)
//    constraint.priority = .required
    constraint.identifier = "height"
    constraint.isActive = true
    
    observers.append(instance.observe(\.contentSize,
                                       options: .new) { [weak self] view, change in
      guard let self = self,
//            let constraint = self.collectionView.getAllConstraints().filter({ $0.identifier == "height" }).first,
            let value = change.newValue,
            value != .zero,
            value.height != constraint.constant
      else { return }
      
      self.setNeedsLayout()
      constraint.constant = value.height
      self.layoutIfNeeded()
      //            self.boundsListener?.onBoundsChanged(view.frame)
    })
    
    instance.claimPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.claimPublisher.send($0)
      }
      .store(in: &subscriptions)
    
    instance.commentPublisher
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
    tasks.append(Task { @MainActor [weak self] in
      for await notification in NotificationCenter.default.notifications(for: Notifications.Surveys.CommentsTotal) {
        guard let self = self,
              let item = self.item,
              let object = notification.object as? SurveyReference,
              item.reference == object
        else { return }
        
        self.disclosureLabel.text = "comments".localized.uppercased() + " (\(String(describing: item.commentsTotal)))"
        guard let constraint = self.disclosureLabel.getConstraint(identifier: "width") else { return }
        self.setNeedsLayout()
        constraint.constant = self.disclosureLabel.text!.width(withConstrainedHeight: 100, font: self.disclosureLabel.font)
        self.layoutIfNeeded()
      }
    })
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
