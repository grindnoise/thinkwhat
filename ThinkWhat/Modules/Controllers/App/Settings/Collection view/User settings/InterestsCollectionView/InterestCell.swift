//
//  InterestCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class InterestCell: UICollectionViewCell {
  
  // MARK: - Public properties
  public weak var item: Topic! {
    didSet {
      guard !item.isNil else { return }
      
      setupUI()
    }
  }
  //Publishers
  public let interestPublisher = PassthroughSubject<Topic, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  //UI
  private lazy var topicIcon: Icon = {
    let instance = Icon(category: item.iconCategory)
    instance.iconColor = .white
    instance.isRounded = false
    instance.clipsToBounds = false
    instance.scaleMultiplicator = 1.85
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
    
    return instance
  }()
  private lazy var topicTitle: InsetLabel = {
    let instance = InsetLabel()
    instance.font = UIFont(name: Fonts.Bold, size: 14)
    instance.text = item.title.uppercased()
    instance.textColor = .white
    instance.isUserInteractionEnabled = true
    instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
    instance.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    return instance
  }()
  private lazy var topicView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      topicIcon,
      topicTitle
    ])
    instance.backgroundColor = item.tagColor
    instance.axis = .horizontal
    instance.spacing = 2
    instance.publisher(for: \.bounds)
      .receive(on: DispatchQueue.main)
      .filter { $0 != .zero}
      .sink { instance.cornerRadius = $0.height/2.25 }
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
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Private methods
  private func setupUI() {
    topicView.place(inside: contentView,
                    insets: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 4))
  }
  
  @objc
  private func handleTap() {
    
    guard let item = item else { return }
    
    interestPublisher.send(item)
  }
  
//  override func prepareForReuse() {
//    super.prepareForReuse()
//
//    interestPublisher = CurrentValueSubject<Topic?, Never>(nil)
//  }
}
