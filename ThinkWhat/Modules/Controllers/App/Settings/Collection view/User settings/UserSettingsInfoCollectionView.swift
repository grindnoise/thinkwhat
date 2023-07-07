//
//  UserSettingsInfoCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsInfoCollectionView: UICollectionView {
  
  enum Section: Int, CaseIterable {
    case About, City, Email, SocialMedia, Interests
  }
  
  
  
  // MARK: - Public properties
  ///**Publishers**
  public let topicPublisher = PassthroughSubject<Topic, Never>()
  public let citySelectionPublisher = PassthroughSubject<City, Never>()
  public let cityFetchPublisher = CurrentValueSubject<String?, Never>(nil)
  public let openURLPublisher = PassthroughSubject<URL, Never>()
  public let facebookPublisher = PassthroughSubject<String, Never>()
  public let instagramPublisher = PassthroughSubject<String, Never>()
  public let tiktokPublisher = PassthroughSubject<String, Never>()
  public let googlePublisher = PassthroughSubject<String, Never>()
  public let twitterPublisher = PassthroughSubject<String, Never>()
  @Published public private(set) var scrollPublisher: CGPoint?
  ///**UI**
  public var color: UIColor = Colors.System.Red.rawValue {
    didSet {
      colorPublisher.send(color)
    }
  }
  ///**Logic**
  public private(set) var isAnimationEnabled = false
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: UICollectionViewDiffableDataSource<Section, Int>!
  ///**Logic**
  public var mode: UserSettingsCollectionView.Mode = .Default
  private var userprofile: Userprofile
//  private let mode: EditingMode
  ///**UI**
  private let padding: CGFloat = 8
  private var cellPadding = UIEdgeInsets.uniform(size: 16) //{ self.userprofile.isCurrent ? .uniform(size: padding*2) : .init(top: self.padding, left: self.padding*2, bottom: .zero, right: self.padding*2) }
  ///**Publishers**
  private var colorPublisher = CurrentValueSubject<UIColor?, Never>(nil)
  @Published public private(set) var userprofileDescription: String?
  @Published public private(set) var email: String?
  
  
  
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
  init(userprofile: Userprofile,
       mode: UserSettingsCollectionView.Mode = .Default) {
    self.mode = mode
    self.userprofile = userprofile
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  init() { fatalError("init() has not been implemented") }
//    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout()) { }
//
//    setupUI()
//  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) { fatalError("init(frame:, collectionViewLayout:) has not been implemented")  }
//    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
//
//    setupUI()
//  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  
  // MARK: - Private methods
  private func setupUI() {
    //        delegate = sel
    collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: section == Section.allCases.count-1 ? self.padding : 0, trailing: 0)
      return sectionLayout
    }
    
    let aboutCellRegistration = UICollectionView.CellRegistration<UserInfoCell, AnyHashable> { [unowned self] cell, indexPath, item in
      //      guard let userprofile = Userprofiles.shared.current else { return }
      
      //      cell.padding = self.padding
      cell.insets = self.cellPadding
      cell.userprofile = self.userprofile
      //      cell.publisher(for: \.bounds)
      //        .receive(on: DispatchQueue.main)
      //        .sink { _ in
      //          self.source.refresh() }
      //        .store(in: &self.subscriptions)
      cell.$boundsPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in
          self.isAnimationEnabled = $0!
          self.source.refresh(animatingDifferences: $0!)
        }
        .store(in: &self.subscriptions)
      cell.$scrollPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in self.scrollPublisher = cell.convert($0!, to: self) }
        .store(in: &self.subscriptions)
      cell.descriptionPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] in self.userprofileDescription = $0 }
        .store(in: &self.self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let cityCellRegistration = UICollectionView.CellRegistration<UserSettingsCityCell, AnyHashable> { [unowned self] cell, _, item in
      
      //      self.userprofile.isCurrent ? { cell.padding = self.padding }() : { cell.insets = .init(top: self.padding, left: self.padding*2, bottom: .zero, right: self.padding*2) }()
      cell.insets = self.cellPadding
      cell.userprofile = self.userprofile
      cell.color = self.color
      ///Fetch
      cell.cityFetchPublisher
        .filter { !$0.isNil }
        .sink { [unowned self] in self.cityFetchPublisher.send($0!) }
        .store(in: &self.subscriptions)
      ///Selection
      cell.citySelectionPublisher
        .sink { [unowned self] in self.citySelectionPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.$scrollPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in self.scrollPublisher = cell.convert($0!, to: self) }
        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let emailCellRegistration = UICollectionView.CellRegistration<UserSettingsEmailCell, AnyHashable> { [unowned self] cell, _, item in
      cell.insets = self.cellPadding
      cell.userprofile = self.userprofile
      cell.color = self.color
      cell.$scrollPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in self.scrollPublisher = cell.convert($0!, to: self) }
        .store(in: &self.subscriptions)
      cell.emailPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] in self.email = $0 }
        .store(in: &self.self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    let interestsCellRegistration = UICollectionView.CellRegistration<UserInterestsCell, AnyHashable> { [unowned self] cell, _, _ in
      cell.insets = self.cellPadding
      cell.userprofile = self.userprofile
      cell.color = self.color
      //      cell.padding = .zero
      cell.topicPublisher
        .sink { [unowned self] in self.topicPublisher.send($0) }
        .store(in: &self.subscriptions)
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
    }
    
    let socialCellRegistration = UICollectionView.CellRegistration<UserSettingsSocialHeaderCell, AnyHashable> { [unowned self] cell, indexPath, item in
      //      cell.keyboardWillAppear
      //        .sink { [unowned self] _ in
      //          //                    self.scrollToItem(at: indexPath, at: .top, animated: true)
      //        }
      //        .store(in: &self.subscriptions)
      cell.padding = .zero
      //Facebook
      cell.facebookPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] in self.facebookPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.instagramPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] in self.instagramPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.tiktokPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] in self.tiktokPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.openURLPublisher
        .eraseToAnyPublisher()
        .sink { [unowned self] in self.openURLPublisher.send($0) }
        .store(in: &self.subscriptions)
      cell.$scrollPublisher
        .eraseToAnyPublisher()
        .filter { !$0.isNil }
        .sink { [unowned self] in self.scrollPublisher = cell.convert($0!, to: self) }
        .store(in: &self.subscriptions)
      
      
      var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
      backgroundConfig.backgroundColor = .clear
      cell.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
      cell.backgroundConfiguration = backgroundConfig
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
      
      guard let userprofile = Userprofiles.shared.current else { return }
      
      cell.userprofile = userprofile
      cell.color = self.color
    }
    
    source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { collectionView, indexPath, identifier -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      if section == .City {
        return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .SocialMedia {
        return collectionView.dequeueConfiguredReusableCell(using: socialCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Interests {
        return collectionView.dequeueConfiguredReusableCell(using: interestsCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .About {
        return collectionView.dequeueConfiguredReusableCell(using: aboutCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Email {
        return collectionView.dequeueConfiguredReusableCell(using: emailCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      
      return UICollectionViewCell()
    }
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.About])
    snapshot.appendSections([.City])
    if userprofile.isCurrent, mode != .Creation {
      snapshot.appendSections([.Email])
    }
    snapshot.appendSections([.SocialMedia])
    if !userprofile.preferences.isEmpty {
      snapshot.appendSections([.Interests])
    }
    
    snapshot.appendItems([0], toSection: .About)
    snapshot.appendItems([1], toSection: .City)
    if userprofile.isCurrent, mode != .Creation {
      snapshot.appendItems([2], toSection: .Email)
//      snapshot.appendItems([3], toSection: .SocialMedia)
    }
    snapshot.appendItems([3], toSection: .SocialMedia)
    if mode != .Creation && !userprofile.preferences.isEmpty {
      snapshot.appendItems([4], toSection: .Interests)
    }
    source.apply(snapshot, animatingDifferences: false)
  }
}

//extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//    }
//}

