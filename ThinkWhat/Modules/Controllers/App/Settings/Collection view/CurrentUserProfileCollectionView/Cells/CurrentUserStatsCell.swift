//
//  CurrentUserStatsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserStatsCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard let userprofile = userprofile else { return }
            
            publicationsCount.text = String(describing: userprofile.publicationsTotal)
        }
    }
    //Publishers
    public let interestPublisher = CurrentValueSubject<Topic?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 8
    private lazy var publicationsTitle: UILabel = {
        let instance = UILabel()
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .darkGray
//        instance.insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        instance.text = "my_publications".localized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: instance.font))
        constraint.identifier = "height"
        constraint.isActive = true
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      let constraint = instance.getConstraint(identifier: "height"),
                      let text = instance.text
                else { return }
                
                self.setNeedsLayout()
                constraint.constant = text.height(withConstrainedWidth: 300, font: instance.font) + 10
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var publicationsCount: UILabel = {
        let instance = UILabel()
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .darkGray
        instance.text = "234"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        //        instance.addTarget(self, action: #selector(self.handleIO(_:)), for: .editingChanged)
        
        return instance
    }()
    private lazy var publicationsButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var publicationsView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [publicationsTitle, publicationsCount, publicationsButton])
//        instance.translatesAutoresizingMaskIntoConstraints = false
//        instance.heightAnchor.constraint(equalTo: publicationsTitle.heightAnchor).isActive = true
        instance.axis = .horizontal
        instance.spacing = 8
        
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [publicationsView, ])
        instance.axis = .vertical
        instance.spacing = 8
        instance.distribution = .fillEqually
        
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
    
    // MARK: - Public methods
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        publicationsButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        publicationsTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .darkGray
        publicationsCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .darkGray
    }
}

private extension CurrentUserStatsCell {
    
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
    
    private func setupUI() {
        contentView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground.withAlphaComponent(0.35) : .secondarySystemBackground.withAlphaComponent(0.7)
        clipsToBounds = false
        
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding*2),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
        
        let constraint = verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    @objc
    private func handleTap(_ button: UIButton) {
        print("Tap")
    }
}
