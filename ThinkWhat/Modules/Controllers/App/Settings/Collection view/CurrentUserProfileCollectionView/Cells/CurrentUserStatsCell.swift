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
            guard !userprofile.isNil else { return }
            
            setText()
            setColors()
        }
    }
    //Publishers
    public var publicationsPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var subscribersPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var subscriptionsPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var watchingPublisher = CurrentValueSubject<Bool?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    
    //UI
    private let padding: CGFloat = 8
    
    //Balance
    private lazy var balanceTitle: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "balance".localized.capitalized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      instance.getConstraint(identifier: "height").isNil,
                      let text = instance.text
                else { return }
                
                let constraint = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
                constraint.identifier = "height"
                constraint.isActive = true
            }
            .store(in: &subscriptions)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var balanceCount: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "0"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var balanceButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        instance.addTarget(self, action: #selector(self.handleButtonTap(_:)), for: .touchUpInside)
        
        return instance
    }()
    
    private lazy var balanceView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [balanceTitle, balanceCount, balanceButton])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
    
    //Complete
    private lazy var completeTitle: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "completed".localized.capitalized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var completeCount: UILabel = {
        let instance = UILabel()
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "0"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        
        return instance
    }()
    
    private lazy var completeButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.alpha = 0
        
        return instance
    }()
    
    private lazy var completeView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [completeTitle, completeCount, completeButton])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
    
    //My publications
    private lazy var publicationsTitle: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "publications".localized.capitalized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      instance.getConstraint(identifier: "height").isNil,
                      let text = instance.text
                else { return }
                
                let constraint = instance.heightAnchor.constraint(equalToConstant: text.height(withConstrainedWidth: 300, font: instance.font) + 10)
                constraint.identifier = "height"
                constraint.isActive = true
            }
            .store(in: &subscriptions)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    private lazy var publicationsCount: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "0"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
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
        instance.addTarget(self, action: #selector(self.handleButtonTap(_:)), for: .touchUpInside)
        
        return instance
    }()
    private lazy var publicationsView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [publicationsTitle, publicationsCount, publicationsButton])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
    
    //My subscribers
    private lazy var subscribersTitle: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "subscribers".localized.capitalized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var subscribersCount: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "0"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var subscribersButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        instance.addTarget(self, action: #selector(self.handleButtonTap(_:)), for: .touchUpInside)
        
        return instance
    }()
    
    private lazy var subscribersView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [subscribersTitle, subscribersCount, subscribersButton])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
    
    //Watching
    private lazy var watchingTitle: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "watching".localized.capitalized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var watchingCount: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "0"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var watchingButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        instance.addTarget(self, action: #selector(self.handleButtonTap(_:)), for: .touchUpInside)
        
        return instance
    }()
    
    private lazy var watchingView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [watchingTitle, watchingCount, watchingButton])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
    
    //My subscriptions
    private lazy var subscriptionsTitle: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "subscriptions".localized.capitalized
        instance.textAlignment = .left
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var subscriptionsCount: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        instance.text = "0"
        instance.textAlignment = .right
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .headline)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        return instance
    }()
    
    private lazy var subscriptionsButton: UIButton = {
        let instance = UIButton()
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.imageView?.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5)), for: .normal)
            }
            .store(in: &subscriptions)
        instance.addTarget(self, action: #selector(self.handleButtonTap(_:)), for: .touchUpInside)
        
        return instance
    }()
    
    private lazy var subscriptionsView: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [subscriptionsTitle, subscriptionsCount, subscriptionsButton])
        instance.axis = .horizontal
        instance.spacing = 0
        
        return instance
    }()
    
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            balanceView,
            publicationsView,
            completeView,
            watchingView,
            subscribersView,
            subscriptionsView,
        ])
        
        instance.axis = .vertical
        instance.spacing = 10
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
        
        setColors()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Reset publishers
        publicationsPublisher = CurrentValueSubject<Bool?, Never>(nil)
        subscribersPublisher = CurrentValueSubject<Bool?, Never>(nil)
        subscriptionsPublisher = CurrentValueSubject<Bool?, Never>(nil)
        watchingPublisher = CurrentValueSubject<Bool?, Never>(nil)
    }
}

private extension CurrentUserStatsCell {
    
    func setTasks() {
        //Balance
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.Balance) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.setText()
            }
        })
        
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.PublicationsTotal) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.setText()
            }
        })
        
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.CompleteTotal) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.setText()
            }
        })
        
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscribersTotal) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.setText()
            }
        })
        
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FavoritesTotal) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.setText()
            }
        })
        
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsTotal) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.setText()
            }
        })
    }
    
    func setColors() {
        guard let userprofile = userprofile else { return }
        
        balanceTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        balanceCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        balanceButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        publicationsTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        publicationsCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        publicationsButton.tintColor = userprofile.publicationsTotal == 0 ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        completeTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        completeCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        
        subscribersTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        subscribersCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        subscribersButton.tintColor = userprofile.subscribersTotal == 0 ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        subscriptionsTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        subscriptionsCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        subscriptionsButton.tintColor = userprofile.subscriptionsTotal == 0 ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        watchingTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        watchingCount.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .darkGray
        watchingButton.tintColor = userprofile.favoritesTotal == 0 ? .secondaryLabel : traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    func setupUI() {
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
    
    func setText() {
        balanceCount.text = String(describing: userprofile.balance)
        completeCount.text = String(describing: userprofile.completeTotal)
        publicationsCount.text = String(describing: userprofile.publicationsTotal)
        subscribersCount.text = String(describing: userprofile.subscribersTotal)
        subscriptionsCount.text = String(describing: userprofile.subscriptionsTotal)
        watchingCount.text = String(describing: userprofile.favoritesTotal)
    }
    
    @objc
    func handleButtonTap(_ sender: UIButton) {
        guard let superview = sender.superview else { return }
        
        determineTransition(superview)
    }
    
    @objc
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let sender = recognizer.view,
              let superview = sender.superview
        else { return }
        
        determineTransition(superview)
    }
    
    func determineTransition(_ sender: UIView) {
        
        if sender === publicationsView {
            publicationsPublisher.send(true)
        } else if sender === subscribersView {
            subscribersPublisher.send(true)
        } else if sender === subscriptionsView {
            subscriptionsPublisher.send(true)
        } else if sender === balanceView {
            print("balanceView")
        } else if sender === watchingView {
            watchingPublisher.send(true)
        }
    }
}
