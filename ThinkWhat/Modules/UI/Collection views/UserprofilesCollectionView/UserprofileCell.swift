//
//  UserprofileCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserprofileCell: UICollectionViewCell {
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard let userprofile = userprofile else { return }
            
            avatar.userprofile = userprofile
            label.text = userprofile.firstNameSingleWord
        }
    }
    //UI
    public private(set) lazy var avatar: Avatar = {
        let instance = Avatar(isShadowed: true)
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.tapPublisher
            .sink { [unowned self] in
                guard let instance = $0 else { return }
                
                self.userPublisher.send(instance)
            }
            .store(in: &subscriptions)
        
        instance.selectionPublisher
            .sink { [unowned self] in
                guard let instance = $0 else { return }
                
                self.selectionPublisher.send(instance)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    //Publishers
    public var userPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
    public var selectionPublisher = CurrentValueSubject<[Userprofile: Bool]?, Never>(nil)
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private lazy var label: UILabel = {
       let instance = UILabel()
        instance.font = UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .subheadline)
        instance.numberOfLines = 2
        instance.textAlignment = .center
        
        return instance
    }()
    private lazy var avatarContainer: UIView = {
       let instance = UIView()
        instance.backgroundColor = .clear
        instance.addSubview(avatar)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: instance.topAnchor),
            avatar.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            avatar.centerXAnchor.constraint(equalTo: instance.centerXAnchor)
        ])
        
        return instance
    }()
    private lazy var stack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [avatarContainer, label])
        instance.axis = .vertical
        instance.spacing = 4
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 0.2).isActive = true
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userPublisher = CurrentValueSubject<Userprofile?, Never>(nil)
        selectionPublisher = CurrentValueSubject<[Userprofile: Bool]?, Never>(nil)
    }
}

private extension UserprofileCell {
    
    func setupUI() {
        contentView.backgroundColor = .clear
        clipsToBounds = false
        
        contentView.addSubview(stack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
//        contentView.isContextMenuInteractionEnabled = true
//                addInteraction(UIContextMenuInteraction(delegate: self))
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

//extension UserprofileCell: UIContextMenuInteractionDelegate {
//
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//
//        return UIContextMenuConfiguration(
//            identifier: nil,
//            previewProvider: makeRatePreview) { [weak self] _ in
//                guard let self = self else { return nil }
//
//                return self.prepareMenu()
//            }
//    }
//
//    func makeRatePreview() -> UIViewController {
//      let viewController = UIViewController()
//
//      // 1
//      let imageView = UIImageView(image: UIImage(named: "rating_star"))
//      viewController.view = imageView
//
//      // 2
//      imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//      imageView.translatesAutoresizingMaskIntoConstraints = false
//
//      // 3
//      viewController.preferredContentSize = imageView.frame.size
//
//      return viewController
//    }
//
//    func prepareMenu() -> UIMenu {
//        var actions: [UIAction]!
//
//        let camera: UIAction = .init(title: "camera".localized.capitalized,
//                                     image: UIImage(systemName: "camera.fill"),
//                                     identifier: nil,
//                                     discoverabilityTitle: nil,
//                                     attributes: .init(),
//                                     state: .off,
//                                     handler: { [weak self] _ in
//            guard let self = self else { return }
//
//            //                self.cameraPublisher.send(true)
//        })
//
//        let photos: UIAction = .init(title: "photo_album".localized.capitalized, image: UIImage(systemName: "photo"), identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
//            guard let self = self else { return }
//
//            //                self.galleryPublisher.send(true)
//        })
//
//        actions = [photos, camera]
//
//
//        return UIMenu(title: "change_avatar".localized, image: nil, identifier: nil, options: .init(), children: actions)
//    }
//}
//
