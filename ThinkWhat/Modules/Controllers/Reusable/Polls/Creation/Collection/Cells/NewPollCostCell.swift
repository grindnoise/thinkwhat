//
//  NewPollCostCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.03.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class NewPollCostCell: UICollectionViewCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var stage: NewPollController.Stage!
  public var stageGlobal: NewPollController.Stage!
  public var costItems: [CostItem]! {
    didSet {
      guard !costItems.isNil else { return }
      
      setupUI()
    }
  }
  public var topicColor: UIColor = .systemGray
  ///**Publishers**
  @Published public var removedImage: NewPollImage?
  public private(set) var stageCompletePublisher = PassthroughSubject<Void, Never>()
  public private(set) var animationCompletePublisher = PassthroughSubject<Void, Never>()
  @Published public private(set) var stageAnimationFinished: NewPollController.Stage!
  @Published public var isKeyboardOnScreen: Bool!
  @Published public var isMovingToParent: Bool!
  public private(set) var addImagePublisher = PassthroughSubject<Void, Never>()
  public private(set) var boundsPublisher = PassthroughSubject<Bool, Never>()
  ///**UI**
  @Published public var color = UIColor.systemGray4 {
    didSet {
      guard oldValue != color else { return }
      
      UIView.animate(withDuration: 0.4) { [weak self] in
        guard let self = self else { return }
        
        self.imageView.tintColor = self.color
      }
    }
  }
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var collectionView: CostCollectionView = {
    let instance = CostCollectionView(dataItems: costItems)
    let constraint = instance.heightAnchor.constraint(equalToConstant: 1)
    constraint.isActive = true
    
    setNeedsLayout()
    instance.publisher(for: \.contentSize)
      .filter { $0 != .zero && constraint.constant != $0.height }
      .sink { [weak self] in
        guard let self = self else { return }
        
        constraint.constant = max(1, $0.height)
        self.layoutIfNeeded()
        self.boundsPublisher.send(true)
      }
      .store(in: &subscriptions)
    
    
    return instance
  }()
  private lazy var imageView: UIImageView = {
    let instance = UIImageView(image: stage.numImage)
    instance.heightAnchor.constraint(equalTo: instance.widthAnchor).isActive = true
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
    instance.tintColor = color
    instance.contentMode = .scaleAspectFit
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.textColor = .secondaryLabel
    instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .caption2)
    instance.text = stage.title.uppercased()
//    instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100,
//                                                                    font: instance.font)).isActive = true
//
    return instance
  }()
  private lazy var stageStack: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [imageView, label])
    instance.spacing = 4
    instance.axis = .horizontal
    instance.alignment = .center
    instance.heightAnchor.constraint(equalToConstant: "TEST".height(withConstrainedWidth: contentView.bounds.width,
                                                                    font: label.font)*1.5).isActive = true
//    label.heightAnchor.constraint(equalTo: instance.heightAnchor).isActive = true
    
    return instance
  }()
    
  
  
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Overriden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    boundsPublisher = PassthroughSubject<Bool, Never>()
    addImagePublisher = PassthroughSubject<Void, Never>()
//    topicPublisher = PassthroughSubject<Topic, Never>()
    animationCompletePublisher = PassthroughSubject<Void, Never>()
  }
  
  
  
  // MARK: - Public methods
  public func update(_ instances: [CostItem]) {
    collectionView.update(instances)
  }
}

// MARK: - Private
private extension NewPollCostCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stageStack.placeTopLeading(inside: self,
                               leadingInset: 8,
                               topInset: -2)
    addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: stageStack.bottomAnchor, constant: padding*2),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding*5),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding*2),
    ])
    
    let constraint = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding*4)
    constraint.isActive = true
    constraint.priority = .defaultLow
  }
}

extension NewPollCostCell: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag, let completion = anim.value(forKey: "completion") as? Closure else { return }
    
    completion()
  }
}



