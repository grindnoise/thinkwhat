//
//  CurrentUserInterestsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserInterestsCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            
            collectionView.userprofile = userprofile
        }
    }
    //Publishers
    public var interestPublisher = CurrentValueSubject<Topic?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 8
    private lazy var collectionView: InterestsCollectionView = {
        let instance = InterestsCollectionView()
        instance.backgroundColor = .clear
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
        constraint.priority = .defaultHigh
        constraint.identifier = "height"
        constraint.isActive = true
        
        instance.publisher(for: \.contentSize, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      let constraint = instance.getConstraint(identifier: "height")
                else { return }
                
                self.setNeedsLayout()
                constraint.constant = rect.height
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)

        instance.interestPublisher
            .sink { [weak self] in
                guard let self = self,
                      let topic = $0
                else { return }
                
                self.interestPublisher.send(topic)
            }
            .store(in: &subscriptions)
        
//        let stack = UIStackView(arrangedSubviews: [tiktokIcon, tiktokTextField, tiktokButton])
//        stack.axis = .horizontal
//        stack.spacing = 8
//
//        instance.addSubview(stack)
//        stack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            stack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 0),
//            stack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -0),
//            stack.topAnchor.constraint(equalTo: instance.topAnchor),
//            stack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
//        ])
        
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
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        clipsToBounds = false
        
        contentView.addSubview(collectionView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding*2),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    private func setTasks() {
//        tasks.append( Task {@MainActor [weak self] in
//            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FacebookURL) {
//                guard let self = self,
//                      let userprofile = notification.object as? Userprofile,
//                      userprofile.isCurrent
//                else { return }
//
//                self.isBadgeEnabled = false
//            }
//        })
    }
    
    // MARK: - Public methods
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        interestPublisher = CurrentValueSubject<Topic?, Never>(nil)
    }
}

