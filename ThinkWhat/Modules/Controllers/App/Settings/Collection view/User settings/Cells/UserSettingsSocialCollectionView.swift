//
//  UserSettingsSocialCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.02.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserSettingsSocialCollectionView: UICollectionView {
  
  enum Section: Int, CaseIterable {
    case Instagram, TikTok, Facebook, Twitter
  }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>
  
  
  // MARK: - Public properties
  public var userprofile: Userprofile! {
    didSet {
      guard !userprofile.isNil else { return }
      
      setupUI()
    }
  }
  ///`Publishers`
  public var openURLPublisher = PassthroughSubject<URL, Never>()
  public var facebookPublisher = PassthroughSubject<String, Never>()
  public var instagramPublisher = PassthroughSubject<String, Never>()
  public var tiktokPublisher = PassthroughSubject<String, Never>()
  public var googlePublisher = PassthroughSubject<String, Never>()
  public var twitterPublisher = PassthroughSubject<String, Never>()
  
  public let colorPublisher = CurrentValueSubject<UIColor?, Never>(nil)
  //UI
  public var color: UIColor = .label {
    didSet {
      colorPublisher.send(color)
    }
  }
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  ///`Collection`
  private var source: Source!
  ///`UI`
  private let padding: CGFloat = 8
  
  
  
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
  init(color: UIColor) {
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    self.color = color
  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension UserSettingsSocialCollectionView {
  @MainActor
  func setupUI() {
    clipsToBounds = false
    collectionViewLayout = UICollectionViewCompositionalLayout{ [unowned self] section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
      sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: self.padding, leading: 0, bottom: self.padding, trailing: 0)
      return sectionLayout
    }
    
    let cellRegistration = UICollectionView.CellRegistration<UserSettingsSocialMediaCell, AnyHashable> { [unowned self] cell, indexPath, item in
      guard let mode = Section(rawValue: indexPath.section) else { return }
      
      var config = UIBackgroundConfiguration.listPlainCell()
      config.backgroundColor = .clear
      cell.backgroundConfiguration = config
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.color = self.color
      switch mode {
      case .TikTok:
        cell.mode = .TikTok
      case .Instagram:
        cell.mode = .Instagram
      case .Facebook:
        cell.mode = .Facebook
      case .Twitter:
        cell.mode = .Twitter
      }
      cell.openURLPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.openURLPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      cell.urlStringPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          switch cell.mode {
          case .TikTok:
            self.tiktokPublisher.send($0)
          case .Instagram:
            self.instagramPublisher.send($0)
          case .Facebook:
            self.facebookPublisher.send($0)
          default:
//            cell.mode = .Twitter
#if DEBUG
            print("")
#endif
          }
        }
        .store(in: &self.subscriptions)
      
      self.colorPublisher
        .filter { !$0.isNil }
        .sink { cell.color = $0! }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self) {
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                          for: indexPath,
                                                          item: identifier)
    }
    
    var snapshot = Snapshot()
    snapshot.appendSections([
      .Instagram,
      .TikTok,
      .Facebook
    ])
    snapshot.appendItems([0], toSection: .Instagram)
    snapshot.appendItems([1], toSection: .TikTok)
    snapshot.appendItems([2], toSection: .Facebook)
    source.apply(snapshot, animatingDifferences: false)
  }
}
