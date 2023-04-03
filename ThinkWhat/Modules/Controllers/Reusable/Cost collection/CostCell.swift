//
//  CostCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CostCell: UICollectionViewListCell {
  
  // MARK: - Public properties
  ///**Logic**
  public var item: CostItem! {
    didSet {
      guard !item.isNil else { return }
      
      setupUI()
      item.$cost
        .sink { [unowned self] value in self.value.text = (self.item.type == .Expense ? "-" : "") + value.formattedWithSeparator }
        .store(in: &subscriptions)
      item.$isNegative
        .filter { [unowned self] _ in self.item.type == .Total }
        .sink { [unowned self] in self.value.textColor = $0 ? .systemRed : .systemGreen }
        .store(in: &subscriptions)
    }
  }
  public var isPresented = false {
    didSet {
      guard isPresented else { return }
      
      
    }
  }
  ///**Publishers**
  public private(set) var boundsPublisher = PassthroughSubject<CGRect, Never>()
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///**UI**
  private let padding: CGFloat = 8
  private lazy var stackView: UIStackView = {
    let instance = UIStackView(arrangedSubviews: [
      label,
      UIView.opaque(),
      value
    ])
    instance.axis = .horizontal
    
    return instance
  }()
  private lazy var label: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: item.type == .Expense ? Fonts.Regular : Fonts.Bold , forTextStyle: .body)
    instance.textColor = .secondaryLabel
    instance.text = item.title
    
    return instance
  }()
  private lazy var value: UILabel = {
    let instance = UILabel()
    instance.font = UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body)
    instance.textColor = item.type == .Expense ? .systemRed : .secondaryLabel
    instance.text = (item.type == .Expense ? "-" : "") + item.cost.formattedWithSeparator
    
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
  override func updateConstraints() {
      super.updateConstraints()
    
    separatorLayoutGuide.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
    separatorLayoutGuide.trailingAnchor.constraint(equalTo: value.trailingAnchor).isActive = true
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
//    topicPublisher = PassthroughSubject<Topic, Never>()
  }
  
  // MARK: - Public methods
  func present(seconds: Double = .zero) {
    UIView.animate(withDuration: 0.2) { [weak self] in
      guard let self = self else { return }
      
      self.label.textColor = .label
      
      switch item.type {
      case .Balance:
        self.value.textColor = .label//systemGreen
      case .Expense:
        self.value.textColor = .systemRed
      case .Total:
        self.value.textColor = item.isNegative ? .systemRed : .systemGreen
      }
    }
  }
}

// MARK: - Private
private extension CostCell {
  @MainActor
  func setupUI() {
    backgroundColor = .clear
    stackView.place(inside: contentView,
                    insets: .uniform(size: padding))
  }
}
