//
//  AnswersCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.12.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import TinyConstraints

class AnswersCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public var item: Survey! {
    didSet {
      guard let item = item else { return }
      
      collectionView.item = item
    }
  }
  //Publishers
  public let selectionPublisher = PassthroughSubject<Answer, Never>()
  public let deselectionPublisher = PassthroughSubject<Bool, Never>()
  public let isVotingPublisher = PassthroughSubject<Bool, Never>()
  public let updatePublisher = PassthroughSubject<Bool, Never>()
  public let votersPublisher = PassthroughSubject<Answer, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private let padding: CGFloat = 8
  private lazy var horizontalStack: UIStackView = {
    let headerLabel: UILabel = {
      let instance = UILabel()
      instance.textColor = Colors.cellHeader
      instance.text = "poll_view_voting".localized.uppercased()
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
    
    let headerImage: UIImageView = {
      let instance = UIImageView(image: UIImage(systemName: "hand.point.right.fill",
                                                withConfiguration: UIImage.SymbolConfiguration(scale: .medium)))
      instance.tintColor = Colors.cellHeader
      instance.contentMode = .scaleAspectFit
  //    instance.widthAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
      instance.heightAnchor.constraint(equalToConstant: "T".height(withConstrainedWidth: 100, font: headerLabel.font)).isActive = true
      
      return instance
    }()
    
    
    let instance = UIStackView(arrangedSubviews: [headerImage,
                                                  headerLabel,
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
  private lazy var collectionView: AnswersCollectionView = {
    let instance = AnswersCollectionView()
    let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
    constraint.isActive = true
    
    setNeedsLayout()
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && constraint.constant != $0.height }
      .sink { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = $0.height
        self.layoutIfNeeded()
      }
      .store(in: &subscriptions)
    instance.selectionPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.selectionPublisher.send($0)
      }
      .store(in: &subscriptions)
    instance.deselectionPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.deselectionPublisher.send($0)
      }
      .store(in: &subscriptions)
    instance.updatePublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.updatePublisher.send($0)
      }
      .store(in: &subscriptions)
    instance.votersPublisher
      .sink { [weak self] in
        guard let self = self else { return }
        
        self.votersPublisher.send($0)
      }
      .store(in: &subscriptions)
    isVotingPublisher
      .sink { instance.isVotingPublisher.send($0) }
      .store(in: &subscriptions)
    
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
    super.init(frame: frame)
    
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

private extension AnswersCell {
  @MainActor
  func setupUI() {
    backgroundColor = .systemBackground
    contentView.addSubview(collectionView)
    collectionView.edgesToSuperview(insets: .uniform(Constants.UI.padding), priority: .defaultLow)
//    contentView.addSubviews([horizontalStack, collectionView])
//    
//    horizontalStack.topToSuperview(offset: Constants.UI.padding)
//    horizontalStack.leadingToSuperview(offset: Constants.UI.padding)
//    horizontalStack.trailingToSuperview(offset: Constants.UI.padding)
//    
//    collectionView.topToBottom(of: horizontalStack, offset: Constants.UI.padding)
//    collectionView.leadingToSuperview(offset: Constants.UI.padding)
//    collectionView.trailingToSuperview(offset: Constants.UI.padding)
//    collectionView.bottomToSuperview(offset: Constants.UI.padding, priority: .defaultLow)
//    collectionView.place(inside: contentView,
//                         insets: .uniform(size: padding),//UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding),
//                         bottomPriority: .defaultLow)
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
}
