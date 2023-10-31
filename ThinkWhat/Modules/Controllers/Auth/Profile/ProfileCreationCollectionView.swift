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
  
  // MARK: - Public properties
  ///**Publishers
  public let usernameEditingPublisher = PassthroughSubject<String, Never>() // While editing
  public let usernamePublisher = PassthroughSubject<String, Never>() // Editing complete
  public let birthDatePublisher = PassthroughSubject<Date, Never>()
  public let genderPublisher = PassthroughSubject<Enums.User.Gender, Never>()
  public let localePublisher = PassthroughSubject<Void, Never>() // Use just to send event, get values from container
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  private var source: UICollectionViewDiffableDataSource<Section, Int>!
  ///**Logic**
  private var usernameState: Enums.User.UsernameState = .correct {
    didSet {
      guard oldValue != usernameState else { return }
      
      usernameCallbackPublisher.send(usernameState)
    }
  }
  private var genderState: Enums.User.Gender {
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
  private var usernameCallbackPublisher = PassthroughSubject<Enums.User.UsernameState, Never>()
  ///**Data**
  private let userprofile: Userprofile
  private let locales: [LanguageItem]
  ///**Publishers
  private let localesHeightPublisher = PassthroughSubject<CGFloat, Never>() // Use to set locales height constraint
  
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
  init(userprofile: Userprofile, locales: [LanguageItem]) {
    self.userprofile = userprofile
    self.genderState = userprofile.gender
    self.birthDateState = userprofile.birthDate
    self.locales = locales
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
  }
  
  init() { fatalError("init(coder:) has not been implemented") }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) { fatalError("init(coder:) has not been implemented") }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: - Public methods
  public func setUsernameState(_ state: Enums.User.UsernameState) {
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
    // Disable bouncing
    bounces = false

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
      cell.insets = .init(top: Constants.UI.padding, left: Constants.UI.padding*2, bottom: Constants.UI.padding*2, right: Constants.UI.padding*2)
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
          
          Notifications.UIEvents.enqueueBannerPublisher.send(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: color),
                                                                             text: text),
                                              contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                              isModal: false,
                                              useContentViewHeight: true,
                                              shouldPresent: false,
                                              shouldDismissAfter: 2))
        }
        .store(in: &self.subscriptions)
      
      // Validate username
      cell.editingEndedPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.usernameEditingPublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      // Editing ended
      cell.editingEndedPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          
          self.usernamePublisher.send($0)
        }
        .store(in: &self.subscriptions)
      
      // Callbacks
      self.usernameCallbackPublisher
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
    }
    
    // Gender
    let genderCellRegistration = UICollectionView.CellRegistration<UserSettingsGenderCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      // UI setup
      cell.insets = .init(top: Constants.UI.padding, left: Constants.UI.padding*2, bottom: Constants.UI.padding*2, right: Constants.UI.padding*2)
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
          
          Notifications.UIEvents.enqueueBannerPublisher.send(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: .systemRed),
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
    
    // Birth date
    let birthDateCellRegistration = UICollectionView.CellRegistration<UserSettingsBirthDateCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      // UI setup
      cell.insets = .init(top: Constants.UI.padding, left: Constants.UI.padding*2, bottom: Constants.UI.padding*2, right: Constants.UI.padding*2)
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
          
          Notifications.UIEvents.enqueueBannerPublisher.send(NewBanner(contentView: TextBannerContent(icon: Icon.init(category: .Logo, scaleMultiplicator: 1.5, iconColor: .systemRed),
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
    
    // Content languages
    let localesCellRegistration = UICollectionView.CellRegistration<UserSettingsLocalesCell, AnyHashable> { [weak self] cell, indexPath, item in
      guard let self = self else { return }
      
      // UI setup
      cell.insets = .init(top: Constants.UI.padding, left: Constants.UI.padding*2, bottom: Constants.UI.padding*2, right: Constants.UI.padding*2)
      cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
      cell.automaticallyUpdatesBackgroundConfiguration = false
      
      // Data setup
      cell.locales = self.locales
      
      // Listeners
      // Get height for cell
      cell.requestBoundsPublisher
        .sink { [unowned self] in self.calcLocalesHeight() }
        .store(in: &subscriptions)
      
      // Update collection view
      cell.boundsPublisher
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] in self.source.refresh(animatingDifferences: $0) }
        .store(in: &self.subscriptions)
      
      // Selection event
      cell.selectionPublisher
        .sink { self.localePublisher.send() }
        .store(in: &subscriptions)
      
      // Set cell height
      self.localesHeightPublisher
        .filter { !$0.isZero }
        .sink { cell.setHeight($0) }
        .store(in: &subscriptions)
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
        return collectionView.dequeueConfiguredReusableCell(using: localesCellRegistration,
                                                            for: indexPath,
                                                            item: itemIdentifier)
      case nil:
        return UICollectionViewCell()
      }
    })
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.username,
                             .gender,
                             .birthDate,
                             .locales])
    snapshot.appendItems([0], toSection: .username)
    snapshot.appendItems([1], toSection: .gender)
    snapshot.appendItems([2], toSection: .birthDate)
    snapshot.appendItems([3], toSection: .locales)
    source.apply(snapshot, animatingDifferences: false)
  }
  
  private func calcLocalesHeight() {
    guard let usernameCell = cellForItem(at: .init(row: 0, section: Section.username.rawValue)),
          let genderCell = cellForItem(at: .init(row: 0, section: Section.gender.rawValue)),
          let birthdateCell = cellForItem(at: .init(row: 0, section: Section.birthDate.rawValue))
    else { return }
    
    localesHeightPublisher.send(bounds.height - (usernameCell.bounds.height
                                                 + genderCell.bounds.height
                                                 + birthdateCell.bounds.height
                                                 + Constants.UI.padding*2))
  }
}

//extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//    }
//}

