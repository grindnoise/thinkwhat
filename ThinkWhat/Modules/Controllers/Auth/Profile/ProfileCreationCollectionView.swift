//
//  ProfileCreationCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.10.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ProfileCreationCollectionView: UICollectionView {
  typealias Source = UICollectionViewDiffableDataSource<Section, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>
  
  enum Section: Int, CaseIterable { case username, gender, birthDate, locales }
  enum UsernameState { case correct, waiting, busy, error, empty, short }
  enum GenderState { case filled, empty }
  
  // MARK: - Public properties
  ///**Publishers
  public let usernamePublisher = PassthroughSubject<String, Never>()
  public let birthDatePublisher = PassthroughSubject<Date, Never>()
  public let genderPublisher = PassthroughSubject<Enums.Gender, Never>()
  public var localesPublisher = PassthroughSubject<[String], Never>()
  public var bannerPublisher = PassthroughSubject<NewBanner, Never>()
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: UICollectionViewDiffableDataSource<Section, Int>!
  ///**Logic**
  private var usernameState: UsernameState = .correct {
    didSet {
      guard oldValue != usernameState else { return }
      
      usernameStatePublisher.send(usernameState)
    }
  }
  private var genderState: Enums.Gender {
    didSet {
      guard oldValue != genderState else { return }
      
      genderPublisher.send(genderState)
    }
  }
  private var birthDateState: Date {
    didSet {
      guard oldValue != birthDateState else { return }
      
      birthDatePublisher.send(birthDateState)
    }
  }
  //  private var usernameLoadingPublisher = PassthroughSubject<Void, Never>()
  //  private var usernameBusyPublisher = PassthroughSubject<Void, Never>()
  //  private var usernameCorrectPublisher = PassthroughSubject<Void, Never>()
  //  private var usernameErrorPublisher = PassthroughSubject<Void, Never>()
  private var usernameStatePublisher = PassthroughSubject<UsernameState, Never>()
  private let userprofile: Userprofile
  
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
  init(userprofile: Userprofile) {
    self.userprofile = userprofile
    self.genderState = userprofile.gender
    self.birthDateState = userprofile.birthDate ?? "01.01.1900".toDate()
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  init() { fatalError("init(coder:) has not been implemented") }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) { fatalError("init(coder:) has not been implemented") }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: - Public methods
  public func setUsernameState(_ state: UsernameState) {
    self.usernameState = state
  }
  
//  public func setUsernameWaiting() {
//    usernameLoadingPublisher.send()
//  }
//  
//  public func setUsernameBusy() {
//    usernameBusyPublisher.send()
//  }
//  
//  public func setUsernameCorrect() {
//    usernameCorrectPublisher.send()
//  }
//  
//  public func setUsernameError() {
//    usernameErrorPublisher.send()
//  }
  
  // MARK: - Private methods
  private func setupUI() {
    collectionViewLayout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection in
      var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
      configuration.backgroundColor = .clear
      configuration.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
//      sectionLayout.contentInsets = .uniform(size: Constants.UI.padding)
      if section == 0 {
        sectionLayout.contentInsets.top = Constants.UI.padding
      } else if section == Section.allCases.count - 1 {
        sectionLayout.contentInsets.bottom = Constants.UI.padding
      }
      
      return sectionLayout
    }
    
    // Prepare cells
    // Username
    let usernameCellRegistration = UICollectionView.CellRegistration<UserSettingsUsernameCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      // UI setup
      cell.insets = .uniform(size: Constants.UI.padding*2)
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
      cell.automaticallyUpdatesBackgroundConfiguration = false
      cell.setSign(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, color: .systemGreen, enabled: true, animated: true)
      
      // Set username
      cell.username = self.userprofile.username
      
      // Add editing listener
      cell.signTapPublisher
        .filter { [unowned self] in self.usernameState != .correct && self.usernameState != .waiting }
        .sink { [weak self] in
          guard let self = self else { return }
          
          var color = UIColor.gray
          var text = ""
          
          switch self.usernameState {
          case .correct:
            color = .systemGreen
            text = "username_is_correct".localized
          case .waiting:
            return
          case .busy:
            color = .systemRed
            text = "username_is_busy".localized
          case .error:
            color = .systemRed
            text = AppError.server.localizedDescription
          case .empty:
            color = .systemRed
            text = "username_is_empty".localized
          case .short:
            color = .systemRed
            text = "username_is_short".localized + String(describing: Constants.Validators.usernameMinLenth)
          }
          
          self.bannerPublisher.send(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                                             text: text),
                                              contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                              isModal: false,
                                              useContentViewHeight: true,
                                              shouldPresent: false,
                                              shouldDismissAfter: 2))
        }
        .store(in: &self.subscriptions)
      
      cell.editingPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.usernamePublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      // Callbacks
      self.usernameStatePublisher
        .receive(on: DispatchQueue.main)
        .throttle(for: .seconds(0.3), scheduler: DispatchQueue.main, latest: true)
        .sink {
          switch $0 {
          case .correct: cell.setSign(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, color: .systemGreen, enabled: true, animated: true)
          case .waiting: cell.setLoading(enabled: true, animated: true)
          case .error: cell.clear()
          case .empty, .busy, .short: cell.setSign(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, color: .systemRed, enabled: true, animated: true)
          }
        }
        .store(in: &self.subscriptions)
      
//      self.usernameBusyPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { cell.setSign(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, enabled: true, animated: true) }
//        .store(in: &self.subscriptions)
//      
//      self.usernameLoadingPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { cell.setLoading(enabled: true, animated: true) }
//        .store(in: &self.subscriptions)
//      
//      self.usernameCorrectPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { cell.setSign(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))!, enabled: true, animated: true) }
//        .store(in: &self.subscriptions)
//      
//      self.usernameErrorPublisher
//        .receive(on: DispatchQueue.main)
//        .sink { cell.clear() }
//        .store(in: &self.subscriptions)
    }
    
    // Gender
    let genderCellRegistration = UICollectionView.CellRegistration<UserSettingsGenderCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      // UI setup
      cell.insets = .uniform(size: Constants.UI.padding*2)
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      // Data setup
      cell.gender = self.genderState
      
      // Add editing listener
      cell.signTapPublisher
        .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
        .filter { [unowned self] _ in self.genderState == .Unassigned}
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.bannerPublisher.send(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: .systemRed),
                                                                             text: "new_profile_gender_caution".localized),
                                              contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                              isModal: false,
                                              useContentViewHeight: true,
                                              shouldPresent: false,
                                              shouldDismissAfter: 2))
        }
        .store(in: &self.subscriptions)
      
      cell.genderPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
        
          self.genderState = $0
        }
        .store(in: &self.subscriptions)
    }
    
    // Gender
    let birthDateCellRegistration = UICollectionView.CellRegistration<UserSettingsBirthDateCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      // UI setup
      cell.insets = .uniform(size: Constants.UI.padding*2)
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      // Data setup
      cell.birthDate = self.birthDateState
      
      // Add editing listener
      cell.signTapPublisher
        .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
//        .filter { [unowned self] _ in self.genderState == .Unassigned}
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.bannerPublisher.send(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: .systemRed),
                                                                             text: "new_profile_gender_caution".localized),
                                              contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                              isModal: false,
                                              useContentViewHeight: true,
                                              shouldPresent: false,
                                              shouldDismissAfter: 2))
        }
        .store(in: &self.subscriptions)
      
      cell.datePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
          guard let self = self else { return }
        
          self.birthDateState = $0
        }
        .store(in: &self.subscriptions)
    }
    
    source = Source(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
      let section = Section(rawValue: indexPath.section)
      
      switch section {
      case .username:
        return collectionView.dequeueConfiguredReusableCell(using: usernameCellRegistration,
                                                            for: indexPath,
                                                            item: itemIdentifier)
      case .gender:
        return collectionView.dequeueConfiguredReusableCell(using: genderCellRegistration,
                                                            for: indexPath,
                                                            item: itemIdentifier)
      case .birthDate:
        return collectionView.dequeueConfiguredReusableCell(using: birthDateCellRegistration,
                                                            for: indexPath,
                                                            item: itemIdentifier)
      case .locales:
        return UICollectionViewCell()
      case nil:
        return UICollectionViewCell()
      }
    })
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.username,
                             .gender,
                             .birthDate])
    snapshot.appendItems([0], toSection: .username)
    snapshot.appendItems([1], toSection: .gender)
    snapshot.appendItems([2], toSection: .birthDate)
//    snapshot.appendItems([1], toSection: .Info)
//    if mode == .Default {
//      snapshot.appendItems([2], toSection: .Stats)
//      snapshot.appendItems([3], toSection: .Management)
//    }
//    
    source.apply(snapshot, animatingDifferences: false)
  }
}

//extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//    }
//}

