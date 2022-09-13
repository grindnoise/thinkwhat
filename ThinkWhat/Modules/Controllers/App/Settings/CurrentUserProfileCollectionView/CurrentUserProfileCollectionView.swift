//
//  CurrentUserProfileView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserProfileCollectionView: UICollectionView {
    
    enum Section: Int {
        case Credentials
    }
    
    // MARK: - Public properties
    //Publishers
    public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    public let datePublisher = CurrentValueSubject<Date?, Never>(nil)
    public let genderPublisher = CurrentValueSubject<Gender?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    private var source: UICollectionViewDiffableDataSource<Section, Int>!
    
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
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        delegate = self
        
        collectionViewLayout = UICollectionViewCompositionalLayout{ section, environment -> NSCollectionLayoutSection in
            let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            
            let layout = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            
            return layout
        }
        
        let credentialsCellRegistration = UICollectionView.CellRegistration<CurrentUserCredentialsCell, AnyHashable> { [unowned self] cell, indexPath, item in
            
            //Name
            cell.namePublisher.sink { [weak self] in
                guard let self = self,
                      let dict = $0
                else { return }
                
                self.namePublisher.send(dict)
            }.store(in: &self.subscriptions)
            
            //Birth date
            cell.datePublisher.sink { [weak self] in
                guard let self = self,
                      let date = $0
                else { return }
                
                self.datePublisher.send(date)
            }.store(in: &self.subscriptions)
            
            //Gender
            cell.genderPublisher.sink { [weak self] in
                guard let self = self,
                      let gender = $0
                else { return }
                
                self.genderPublisher.send(gender)
            }.store(in: &self.subscriptions)
            
            guard let userprofile = Userprofiles.shared.current,
                  cell.userprofile.isNil
            else { return }
            
            cell.userprofile = userprofile
        }
        
        source = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self) { [unowned self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            guard let section = Section(rawValue: identifier) else { return UICollectionViewCell() }
            if section == .Credentials {
                return collectionView.dequeueConfiguredReusableCell(using: credentialsCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            }

            return UICollectionViewCell()
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.Credentials,])
        snapshot.appendItems([0], toSection: .Credentials)
        source.apply(snapshot, animatingDifferences: false)
    }
}

extension CurrentUserProfileCollectionView: UICollectionViewDelegate {
    
}
