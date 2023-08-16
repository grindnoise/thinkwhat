//
//  UsersFilterCollectionView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UsersFilterCollectionView: UICollectionView {
  
  enum Section: Int {
    case Age, Gender
  }
  
  typealias Source = UICollectionViewDiffableDataSource<Section, Int>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>
  
  // MARK: - Overridden properties
  
  
  
  // MARK: - Public properties
  //Publishers
  public var minAgePublisher = CurrentValueSubject<Int?, Never>(nil)
  public var maxAgePublisher = CurrentValueSubject<Int?, Never>(nil)
  public var buttonTitlePublisher = CurrentValueSubject<String?, Never>(nil)
  
  //Logic
  public private(set) var filtered: [Userprofile] = []
  public private(set) var selectedMinAge: Int
  public private(set) var selectedMaxAge: Int
  public private(set) var selectedGender: Enums.Gender
  
  
  
  // MARK: - Private properties
  private var observers: [NSKeyValueObservation] = []
  private var subscriptions = Set<AnyCancellable>()
  private var tasks: [Task<Void, Never>?] = []
  
  //Collection view
  private var source: UICollectionViewDiffableDataSource<Section, Int>!
  //UI
  private let color: UIColor
  //Logic
  private var userprofiles: [Userprofile] = []
  private let minAge = 18
  private let maxAge = 99
  
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
  init(userprofiles: [Userprofile],
       color: UIColor = Colors.System.Red.rawValue,
       filtered: [Userprofile] = [],
       selectedMinAge: Int,
       selectedMaxAge: Int,
       selectedGender: Enums.Gender) {//?, filters: [String : AnyObject]?) {
    self.color = color
    self.userprofiles = userprofiles
    self.selectedMinAge = selectedMinAge
    self.selectedMaxAge = selectedMaxAge
    self.selectedGender = selectedGender
    
    super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    setupUI()
    setTasks()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Public methods
  
  
  
  // MARK: - Overridden methods
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
  }
}

private extension UsersFilterCollectionView {
  
  func setupUI() {
    collectionViewLayout = UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
      
      var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
      layoutConfig.backgroundColor = .clear
      layoutConfig.showsSeparators = false
      
      let sectionLayout = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: env)
      guard let section = Section(rawValue: section) else {
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return sectionLayout
      }
      
      switch section {
      case .Age:
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
      case .Gender:
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0)
      }
      
      return sectionLayout
    }
    
    let ageCellRegistration = UICollectionView.CellRegistration<UsersFilterAgeCell, AnyHashable> { [unowned self] cell, indexPath, item in
      
      cell.selectedMinAge = self.selectedMinAge
      cell.selectedMaxAge = self.selectedMaxAge
      cell.color = self.color
      cell.agePublisher
        .sink { [unowned self] in
          guard let dict = $0,
                let min = dict.keys.first,
                let max = dict.values.first
          else { return }
          
          self.selectedMinAge = min
          self.selectedMaxAge = max
          self.fetchData()
        }
        .store(in: &self.subscriptions)
    }
    
    let genderCellRegistration = UICollectionView.CellRegistration<UsersFilterGenderCell, AnyHashable> { [unowned self] cell, indexPath, item in
      
      cell.selectedGender = self.selectedGender
      cell.color = self.color
      cell.genderPublisher
        .sink { [unowned self] in
          guard let gender = $0 else { return }
          
          self.selectedGender = gender
          self.fetchData()
        }
        .store(in: &self.subscriptions)
    }
    
    source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) {
      (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
      guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
      
      if section == .Age {
        return collectionView.dequeueConfiguredReusableCell(using: ageCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      } else if section == .Gender {
        return collectionView.dequeueConfiguredReusableCell(using: genderCellRegistration,
                                                            for: indexPath,
                                                            item: identifier)
      }
      return UICollectionViewCell()
    }
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.Age, .Gender])
    snapshot.appendItems([0], toSection: .Age)
    snapshot.appendItems([1], toSection: .Gender)
    source.apply(snapshot, animatingDifferences: false)
    fetchData()
  }
  
  func setTasks() {}
  
  func fetchData() {
    if selectedGender != .Unassigned {
      filtered = userprofiles.filter({Int(selectedMinAge)...Int(selectedMaxAge) ~= $0.age}).filter({$0.gender == selectedGender})
      //            filter({ $0.age >= Int(selectedMinAge)}).filter({$0.age <= Int(selectedMaxAge)}).filter({$0.gender == selectedGender})
    } else {
      filtered = userprofiles.filter({Int(selectedMinAge)...Int(selectedMaxAge) ~= $0.age})
    }
    
    buttonTitlePublisher.send("show".localized.uppercased() + " \(String(describing: filtered.count))")
  }
}

