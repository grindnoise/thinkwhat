//
//  CostCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CostCollectionView: UICollectionView {
  
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CostItem>
  typealias Source = UICollectionViewDiffableDataSource<Section, CostItem>
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private let presentPublisher = PassthroughSubject<Void, Never>()
  public var isPresented = false
  
  enum Section: Int { case Balance, Expense, Total }
  
  private var source: Source!
  public var dataItems: [CostItem]
  
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
  
  init(dataItems: [CostItem]) {
    self.dataItems = dataItems
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = section == 2
      if #available(iOS 14.5, *) {
        layoutConfig.separatorConfiguration.bottomSeparatorVisibility = .visible
        layoutConfig.separatorConfiguration.topSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 1.5, trailing: 0)
        layoutConfig.separatorConfiguration.bottomSeparatorVisibility = .hidden
      }
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
      return sectionLayout
    }
    
    let balanceCellRegistration = UICollectionView.CellRegistration<CostCell, CostItem> { [unowned self] cell, indexPath, item in
      cell.item = item
      cell.isPresented = self.isPresented
      self.presentPublisher
        .sink { cell.present() }
        .store(in: &self.subscriptions)
      var bgConfig = UIBackgroundConfiguration.listPlainCell()
      bgConfig.backgroundColor = .clear
      cell.backgroundConfiguration = bgConfig
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let expenseCellRegistration = UICollectionView.CellRegistration<CostCell, CostItem> { [unowned self] cell, indexPath, item in
      cell.item = item
      cell.isPresented = self.isPresented
      self.presentPublisher
        .sink { cell.present() }
        .store(in: &self.subscriptions)
      
      var bgConfig = UIBackgroundConfiguration.listPlainCell()
      bgConfig.backgroundColor = .clear
      cell.backgroundConfiguration = bgConfig
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let totalCellRegistration = UICollectionView.CellRegistration<CostCell, CostItem> { [unowned self] cell, indexPath, item in
      cell.item = item
      cell.isPresented = self.isPresented
      self.presentPublisher
        .sink { cell.present() }
        .store(in: &self.subscriptions)
      
      var bgConfig = UIBackgroundConfiguration.listPlainCell()
      bgConfig.backgroundColor = .clear
      cell.backgroundConfiguration = bgConfig
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    source = UICollectionViewDiffableDataSource<Section, CostItem>(collectionView: self) { (collectionView, indexPath, item) -> UICollectionViewCell? in
      guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
      
      switch section {
      case .Balance:
        return collectionView.dequeueConfiguredReusableCell(using: balanceCellRegistration,
                                                                for: indexPath,
                                                                item: item)
      case .Expense:
        return collectionView.dequeueConfiguredReusableCell(using: expenseCellRegistration,
                                                                for: indexPath,
                                                                item: item)
      case .Total:
        return collectionView.dequeueConfiguredReusableCell(using: totalCellRegistration,
                                                                for: indexPath,
                                                                item: item)
      }
    }
    
    setDataSource(dataItems)
  }
  
  public func setDataSource(_ instances: [CostItem]) {
    dataItems = instances
    var snapshot = Snapshot()
    snapshot.appendSections([
      .Balance,
      .Expense,
      .Total
    ])
    snapshot.appendItems(dataItems.filter { $0.type == .Balance }, toSection: .Balance)
    snapshot.appendItems(dataItems.filter { $0.type == .Expense }, toSection: .Expense)
    snapshot.appendItems(dataItems.filter { $0.type == .Total }, toSection: .Total)
    source.apply(snapshot, animatingDifferences: true)
  }
  
  public func present(completion: Closure?) {
    UIView.animate(withDuration: 0.2, animations: { [weak self] in
      guard let self = self else { return }
      
      self.alpha = 1
    }) { _ in completion?() }
    
    presentPublisher.send()
    presentPublisher.send(completion: .finished)
    isPresented = true
  }
}


//class CostCollectionView: UICollectionView {
//
//  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CostItem>
//  typealias Source = UICollectionViewDiffableDataSource<Section, CostItem>
//
//  enum Section { case main }
//
//  private var source: Source!
//  public var dataItems: [CostItem]
//
//  init(dataItems: [CostItem]) {
//    self.dataItems = dataItems
//
//    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
//
//    setupUI()
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  private func setupUI() {
//    backgroundColor = .clear
//
//    let layoutConfig: UICollectionLayoutListConfiguration = {
//      var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//      config.showsSeparators = false
//      config.backgroundColor = .clear
//      config.headerMode = .supplementary
//      config.footerMode = .supplementary
//      return config
//    }()
//    collectionViewLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
//
//
//
//    let cellRegistration = UICollectionView.CellRegistration<CostCell, CostItem> { cell, indexPath, item in
//      cell.item = item
//      var bgConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
//      bgConfig.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//      cell.backgroundConfiguration = bgConfig
//      cell.automaticallyUpdatesBackgroundConfiguration = false
//    }
//
//    source = UICollectionViewDiffableDataSource<Section, CostItem>(collectionView: self) { (collectionView, indexPath, item) -> UICollectionViewCell? in
//
//      let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
//                                                              for: indexPath,
//                                                              item: item)
//      return cell
//    }
//
//    let headerRegistration = UICollectionView.SupplementaryRegistration<CostHeaderFooter>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, _, _ in
//      guard let balance = Userprofiles.shared.current?.balance else { return }
//
//      headerView.mode = .Header
//      headerView.intValue = balance
//    }
//
//    let footerRegistration = UICollectionView.SupplementaryRegistration<CostHeaderFooter>(elementKind: UICollectionView.elementKindSectionFooter) { footerView, _, _ in
//      guard let balance = Userprofiles.shared.current?.balance else { return }
//
//      footerView.mode = .Footer
//      footerView.intValue = self.dataItems.reduce(into: 0) { $0 += $1.cost }
//      footerView.isNegative = balance < footerView.intValue
//    }
//
//
//    source.supplementaryViewProvider = { [weak self] (supplementaryView, elementKind, indexPath) in
//      guard let self = self else { return UICollectionReusableView() }
//
//      if elementKind == UICollectionView.elementKindSectionHeader {
//        return self.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
//      } else if elementKind == UICollectionView.elementKindSectionFooter {
//        return self.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
//      }
//      return UICollectionReusableView()
//    }
//
//    var snapshot = Snapshot()
//    snapshot.appendSections([.main])
//    snapshot.appendItems(dataItems, toSection: .main)
//    snapshot.reloadItems(dataItems)
//    source.apply(snapshot, animatingDifferences: false)
//  }
//
//  public func update(_ instances: [CostItem]) {
//    dataItems = instances
//    var snap = Snapshot()
//    snap.appendSections([.main])
//    snap.appendItems(dataItems, toSection: .main)
//    snap.reloadItems(dataItems)
//    source.apply(snap)
//  }
//}
//
//class CostCell: UICollectionViewListCell {
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  var item: CostItem!
//  var callback: Closure?
//
//  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//    var config = UIBackgroundConfiguration.listGroupedHeaderFooter()
//    config.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    backgroundConfiguration = config
//  }
//
//  override func updateConfiguration(using state: UICellConfigurationState) {
//    automaticallyUpdatesBackgroundConfiguration = false
//    var newConfiguration = CostCellConfiguration().updated(for: state)
//    newConfiguration.item = item
//
//    contentConfiguration = newConfiguration
//  }
//}
//
//struct CostCellConfiguration: UIContentConfiguration, Hashable {
//
//  var item: CostItem!
//
//  func makeContentView() -> UIView & UIContentView {
//    return CostContentView(configuration: self)
//  }
//
//  func updated(for state: UIConfigurationState) -> Self {
//    guard state is UICellConfigurationState else {
//      return self
//    }
//    let updatedConfiguration = self
//    return updatedConfiguration
//  }
//}
//
//class CostContentView: UIView, UIContentView {
//
//  // MARK: - Private properties
//  private var currentConfiguration: CostCellConfiguration!
//  private var observers: [NSKeyValueObservation] = []
//  var configuration: UIContentConfiguration {
//    get {
//      currentConfiguration
//    }
//    set {
//      guard let newConfiguration = newValue as? CostCellConfiguration else {
//        return
//      }
//      apply(configuration: newConfiguration)
//    }
//  }
//
//  //UI
//  private let itemLabel: UILabel = {
//    let label = UILabel()
//    label.textAlignment = .left
//    return label
//  }()
//  private let costLabel: UILabel = {
//    let label = UILabel()
//    label.textAlignment = .right
//    return label
//  }()
//  private lazy var stackView: UIStackView = {
//    let rootStack = UIStackView(arrangedSubviews: [itemLabel, costLabel])
//    rootStack.alignment = .fill
//    rootStack.distribution = .fillProportionally
//    return rootStack
//  }()
//
//  // MARK: - Initialization
//  init(configuration: CostCellConfiguration) {
//    super.init(frame: .zero)
//    setObservers()
//    commonInit()
//    apply(configuration: configuration)
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  private func commonInit() {
//    addSubview(stackView)
//    stackView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
//      stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//      stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//      //            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
//      stackView.heightAnchor.constraint(equalToConstant: 40),
//    ])
//    let c = stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
//    c.priority = .defaultLow
//    c.isActive = true
//    backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//  }
//
//  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//    backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    setText()
//  }
//
//
//  // MARK: - Private methods
//  private func setObservers() {
//    observers.append(itemLabel.observe(\UILabel.bounds, options: .new) { [weak self] (_, change) in
//      guard let self = self else { return }
//      //            print(change)
//      self.setText()
//    })
//  }
//
//  private func setText() {
//    let fontSize = itemLabel.bounds.height * 0.4
//    let titleString = NSMutableAttributedString()
//    titleString.append(NSAttributedString(string: currentConfiguration.item.title.localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//    itemLabel.attributedText = titleString
//
//    let costString = NSMutableAttributedString()
//    costString.append(NSAttributedString(string: "-\(currentConfiguration.item.cost)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .systemRed, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//    costLabel.attributedText = costString
//
//  }
//
//  private func apply(configuration: CostCellConfiguration) {
//    guard currentConfiguration != configuration else { return }
//    currentConfiguration = configuration
//    itemLabel.text = configuration.item.title
//    costLabel.text = String(describing: configuration.item.cost)
//    //        setText()
//  }
//}
//
//class CostHeaderFooter: UICollectionReusableView {
//
//  enum Mode { case Header, Footer }
//
//  // MARK: - Public properties
//  public var intValue: Int = 0 {
//    didSet {
//      setText()
//    }
//  }
//  var mode = Mode.Header {
//    didSet {
//      guard oldValue != mode else { return }
//      setText()
//    }
//  }
//  var isNegative = false {
//    didSet {
//      setText()
//    }
//  }
//
//  // MARK: - Private properties
//  private var observers: [NSKeyValueObservation] = []
//
//  //UI
//  private let itemLabel: UILabel = {
//    let label = UILabel()
//    label.textAlignment = .left
//    return label
//  }()
//  private let balanceLabel: UILabel = {
//    let label = UILabel()
//    label.textAlignment = .right
//    return label
//  }()
//  private lazy var stackView: UIStackView = {
//    let rootStack = UIStackView(arrangedSubviews: [itemLabel, balanceLabel])
//    rootStack.alignment = .fill
//    rootStack.distribution = .fillProportionally
//    return rootStack
//  }()
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    commonInit()
//  }
//
//  init(balance: Int) {
//    super.init(frame: .zero)
//    self.intValue = balance
//    commonInit()
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("Not implemented")
//  }
//
//  // MARK: - Private methods
//  private func setObservers() {
//    observers.append(itemLabel.observe(\UILabel.bounds, options: .new) { [weak self] (_, _) in
//      guard let self = self else { return }
//      self.setText()
//    })
//  }
//
//  private func setText() {
//    let fontSize = itemLabel.bounds.height * 0.4
//    let titleString = NSMutableAttributedString()
//    titleString.append(NSAttributedString(string: (mode == .Header ? "balance".localized : "total_bill".localized) + ":", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//    itemLabel.attributedText = titleString
//
//    let balanceString = NSMutableAttributedString()
//    balanceString.append(NSAttributedString(string: String(describing: intValue), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: mode == .Header ? .systemGreen : isNegative ? .systemRed : .systemGreen, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//    balanceLabel.attributedText = balanceString
//
//  }
//
//  private func commonInit() {
//    setObservers()
//    addSubview(stackView)
//    stackView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
//      stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//      stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//      //            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
//      stackView.heightAnchor.constraint(equalToConstant: 60),
//    ])
//    let c = stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
//    c.priority = .defaultLow
//    c.isActive = true
//  }
//}
