//
//  UserprofilesView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofilesView: UIView {
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    public weak var viewInput: UserprofilesViewInput? {
        didSet {
            guard let viewInput = viewInput else { return }
            
            
            collectionView.userprofile = viewInput.userprofile
            collectionView.mode = viewInput.mode
        }
    }
    var gridItemSizePublisher = CurrentValueSubject<UserprofilesController.GridItemSize?, Never>(nil)
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private lazy var collectionView: UserprofilesCollectionView = {
        let instance = UserprofilesCollectionView()
        
        //Pagination #1
        let paginationPublisher = instance.paginationPublisher
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
        
        paginationPublisher
            .sink { [unowned self] in
                guard !$0.isNil,
                      let viewInput = self.viewInput,
                      let userprofile = viewInput.userprofile
                else { return }
                
                self.viewInput?.loadUsers(for: userprofile, mode: viewInput.mode)
            }
            .store(in: &subscriptions)
        
        gridItemSizePublisher.subscribe(instance.gridItemSizePublisher).store(in: &subscriptions)
        
        instance.userPublisher
            .sink { [unowned self] in
                guard let instance = $0 else { return }
                
                self.viewInput?.onUserprofileTap(instance)
            }
            .store(in: &subscriptions)
        
        instance.selectionPublisher
            .sink { [unowned self] in
                guard let instances = $0 else { return }

                print(instances)
            }
            .store(in: &subscriptions)

        
        instance.refreshPublisher
            .sink { [unowned self] in
                guard !$0.isNil,
                      let viewInput = self.viewInput,
                      let userprofile = viewInput.userprofile
                else { return }
                
                self.viewInput?.loadUsers(for: userprofile, mode: viewInput.mode)
            }
            .store(in: &subscriptions)
        //Subscribe
        instance.subscribePublisher
            .sink { [unowned self] in
                guard let userprofiles = $0 else { return }
                
                self.viewInput?.subscribe(at: userprofiles)
            }
            .store(in: &subscriptions)
        
        //Unsubscribe
        instance.unsubscribePublisher
            .sink { [unowned self] in
                guard let userprofiles = $0 else { return }
                
                self.viewInput?.unsubscribe(from: userprofiles)
            }
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

private extension UserprofilesView {
    
    func setupUI() {
        collectionView.addEquallyTo(to: self)
    }
    
    func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: <# notification #>) {
//                guard let self = self else { return }
//
//
//            }
//        })
    }
}

extension UserprofilesView: UserprofilesControllerOutput {
    func editingMode() {
        collectionView.editingMode(true)
    }
    
    func filter() {
        collectionView.filter()
    }
}
