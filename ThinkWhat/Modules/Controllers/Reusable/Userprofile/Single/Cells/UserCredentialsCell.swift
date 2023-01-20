//
//  UserCredentialsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class UserCredentialsCell: UICollectionViewListCell {
    
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard !userprofile.isNil else { return }
            
            updateUI()
        }
    }
    //Publishers
    public var urlPublisher = CurrentValueSubject<URL?, Never>(nil)
    public var subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
    public var imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding : CGFloat = 16
    private lazy var avatar: Avatar = {
        let instance = Avatar(isShadowed: true)
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.clipsToBounds = false
        
        instance.buttonBgDarkColor = .secondarySystemBackground
        instance.tapPublisher.sink { [weak self] in
            guard let self = self else { return }
            
          self.imagePublisher.send($0.image)
        }.store(in: &subscriptions)
        
        return instance
    }()
    private lazy var username: InsetLabel = {
        let instance = InsetLabel()
        instance.insets.top = -4
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
        instance.adjustsFontSizeToFitWidth = true
        
        return instance
    }()
    private lazy var info: InsetLabel = {
        let instance = InsetLabel()
//        instance.insets = .uniform(size: 2)
        instance.insets.left = 2
        instance.insets.right = 2
        instance.insets.top = -2
        instance.insets.bottom = 2
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.textColor = .secondaryLabel
        instance.adjustsFontSizeToFitWidth = true
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
        
        return instance
    }()
    private lazy var socialMediaStack: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.distribution = .fillEqually
        instance.accessibilityIdentifier = "socialMediaStack"
        
        return instance
    }()
    private lazy var subscriptionButton: UIButton = {
        let instance = UIButton()
        instance.accessibilityIdentifier = "subscriptionButton"
        instance.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [unowned self] incoming in
                var outgoing = incoming
                if self.userprofile.subscribedAt {
                    outgoing.foregroundColor = UIColor.systemRed
                } else {
                    outgoing.foregroundColor = self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
                }
                outgoing.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)
                
                return outgoing
            }
            config.cornerStyle = .small
            config.buttonSize = .mini
            config.contentInsets.leading = 4
            config.contentInsets.top = 0
            config.contentInsets.bottom = 0
            config.contentInsets.trailing = 4
            config.imagePlacement = .trailing
            config.imagePadding = 4.0
            config.imageColorTransformer = UIConfigurationColorTransformer { [unowned self] _ in
                return self.userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
            }
            instance.configuration = config
        } else {
            instance.semanticContentAttribute = .forceRightToLeft
            instance.tintColor = .systemRed
            instance.imageEdgeInsets.left = 4.0
        }
        
        return instance
    }()
    private lazy var statsStack: UIStackView = {
        //Left side
        let publicationsLabel = UILabel()
        publicationsLabel.text = "publications".localized.lowercased()
        publicationsLabel.font = UIFont.scaledFont(fontName: Fonts.Semibold,
                                                   forTextStyle: .caption1)
        let publicationsButton = UIButton()
        publicationsButton.accessibilityIdentifier = "publicationsButton"
        publicationsButton.tintColor = .systemBlue
        publicationsButton.setAttributedTitle(NSAttributedString(string: "32",
                                                                 attributes: [
                                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold,
                                                                                             forTextStyle: .caption1) as Any,
                                                                    .foregroundColor: UIColor.systemBlue as Any
                                                                 ]),
                                              for: .normal)
        
        let publicationsStack = UIStackView(arrangedSubviews: [
            publicationsLabel,
            publicationsButton
        ])
        publicationsStack.contentMode = .center
        
        //Right side
        let subscribersLabel = UILabel()
        subscribersLabel.text = "subscribers".localized.lowercased()
        subscribersLabel.font = UIFont.scaledFont(fontName: Fonts.Semibold,
                                                  forTextStyle: .caption1)
        let subscribersButton = UIButton()
        subscribersButton.accessibilityIdentifier = "subscribersButton"
        subscribersButton.tintColor = .systemBlue
        subscribersButton.setAttributedTitle(NSAttributedString(string: "141",
                                                                attributes: [
                                                                    .font: UIFont.scaledFont(fontName: Fonts.Semibold,
                                                                                             forTextStyle: .caption1) as Any,
                                                                    .foregroundColor: UIColor.systemBlue as Any
                                                                ]),
                                             for: .normal)
        
        let subscribersStack = UIStackView(arrangedSubviews: [
            subscribersLabel,
            subscribersButton
        ])
        subscribersStack.axis = .vertical
        subscribersStack.contentMode = .center
        
        let instance = UIStackView(arrangedSubviews: [
            publicationsStack,
            subscribersStack
        ])
        instance.axis = .horizontal
        
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            username,
            info,
        ])
        instance.axis = .vertical
        instance.alignment = .leading
        instance.spacing = 4
        
        return instance
    }()
    private lazy var stack: UIStackView = {
        let opaque = UIView()
        opaque.backgroundColor = .clear
        opaque.addSubview(verticalStack)
        
        let instance = UIStackView(arrangedSubviews: [
            avatar,
            opaque
        ])
        instance.axis = .horizontal
        instance.spacing = padding
        instance.clipsToBounds = false
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: instance.topAnchor),
            avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/3),
            verticalStack.leadingAnchor.constraint(equalTo: opaque.leadingAnchor),
            verticalStack.centerYAnchor.constraint(equalTo: opaque.centerYAnchor),
        ])
        
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
    
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateUI()
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
        subscriptionPublisher = CurrentValueSubject<Bool?, Never>(nil)
        imagePublisher = CurrentValueSubject<UIImage?, Never>(nil)
    }
}

private extension UserCredentialsCell {
    @MainActor
    func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(stack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        
        let constraint = stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        constraint.priority = .defaultLow
        constraint.identifier = "bottomAnchor"
        constraint.isActive = true
    }
    
    @MainActor
    func setTasks() {
        //Subscription events
        //Subscribed at added
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
                guard let self = self,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let userprofile = dict.values.first,
                      self.userprofile == userprofile
                else { return }
                
                self.toggleSubscription()
            }
        })
        
        //Subscribed at removed
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
                guard let self = self,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let userprofile = dict.values.first,
                      self.userprofile == userprofile
                else { return }
                
                self.toggleSubscription()
            }
        })
        
        //Subscription api error
        tasks.append(Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionOperationFailure) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      self.userprofile == userprofile
                else { return }
                
                self.toggleSubscription(error: true)
            }
        })
    }
    
    @MainActor
    func updateUI() {
        func setupSocialMediaStack() {
            //FB
            if !userprofile.facebookURL.isNil, socialMediaStack.arrangedSubviews.filter({ $0.accessibilityIdentifier == SocialMedia.Facebook.rawValue }).isEmpty {
                let instance = FacebookLogo()
                instance.accessibilityIdentifier = SocialMedia.Facebook.rawValue
                instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
                instance.isOpaque = false
                instance.isUserInteractionEnabled = true
                instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.urlTapped(recognizer:))))
                
                socialMediaStack.addArrangedSubview(instance)
            }
            //Instagram
            if !userprofile.instagramURL.isNil, socialMediaStack.arrangedSubviews.filter({ $0.accessibilityIdentifier == SocialMedia.Instagram.rawValue }).isEmpty {
                let instance = InstagramLogo()
                instance.accessibilityIdentifier = SocialMedia.Instagram.rawValue
                instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
                instance.isOpaque = false
                instance.isUserInteractionEnabled = true
                instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.urlTapped(recognizer:))))
                
                socialMediaStack.addArrangedSubview(instance)
            }
            //Tiktok
            if !userprofile.tiktokURL.isNil, socialMediaStack.arrangedSubviews.filter({ $0.accessibilityIdentifier == SocialMedia.TikTok.rawValue }).isEmpty {
                let instance = TikTokLogo()
                instance.accessibilityIdentifier = SocialMedia.TikTok.rawValue
                instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
                instance.isOpaque = false
                instance.isUserInteractionEnabled = true
                instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.urlTapped(recognizer:))))
                
                socialMediaStack.addArrangedSubview(instance)
            }
            
            guard let first = socialMediaStack.arrangedSubviews.first else { return }
            
            first.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: .greatestFiniteMagnitude,
                                                                         font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                                                                 forTextStyle: .title2)!)).isActive = true
        }
        
        username.text = userprofile.name
        avatar.userprofile = userprofile
        info.text = "\(userprofile.gender.rawValue.localized.lowercased()), \(userprofile.age), \(userprofile.cityTitle)"
        
        if #available(iOS 15, *) {
            subscriptionButton.configuration?.title = (userprofile.subscribedAt ? "unsubscribe" : "subscribe").localized.uppercased()
            subscriptionButton.configuration?.activityIndicatorColorTransformer = UIConfigurationColorTransformer { [unowned self] _ in
                guard let userprofile = self.userprofile else { return UIColor.systemBlue }
                
                return !userprofile.subscribedAt ? .systemBlue : .systemRed
            }
            subscriptionButton.configuration?.image = UIImage(systemName: userprofile.subscribedAt ? "hand.raised.slash.fill" : "hand.point.left.fill",
                                                              withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            if userprofile.subscribedAt {
                subscriptionButton.configuration?.baseBackgroundColor = .systemRed.withAlphaComponent(0.15)
            } else {
                subscriptionButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue.withAlphaComponent(0.15) : K_COLOR_TABBAR.withAlphaComponent(0.15)
            }
        } else {
            let attrString = NSMutableAttributedString(string: (userprofile.subscribedAt ? "unsubscribe" : "subscribe").localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                                                 forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: self.userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
                                                       ])
            subscriptionButton.setImage(UIImage(systemName: userprofile.subscribedAt ? "hand.raised.slash.fill" : "hand.point.left.fill",
                                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                        for: .normal)
            subscriptionButton.setAttributedTitle(attrString, for: .normal)
            subscriptionButton.imageView?.tintColor = self.userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
            if userprofile.subscribedAt {
                subscriptionButton.backgroundColor = .systemRed.withAlphaComponent(0.15)
            } else {
                subscriptionButton.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue.withAlphaComponent(0.15) : K_COLOR_TABBAR.withAlphaComponent(0.15)
            }
        }
        
        //Social network
        if userprofile.hasSocialMedia {
            setupSocialMediaStack()
            
            
            
            verticalStack.addArrangedSubview(socialMediaStack)
        }
        
        //Subscription
        guard !verticalStack.arrangedSubviews.contains(subscriptionButton) else { return }
        
        verticalStack.addArrangedSubview(subscriptionButton)
        
//        //Bottom spacer
//        guard verticalStack.arrangedSubviews.filter({ $0.accessibilityIdentifier == "spacer" }).isEmpty else { return }
//
//        let spacer = UIView()
//        spacer.accessibilityIdentifier = "spacer"
//        spacer.backgroundColor = .clear
//        verticalStack.addArrangedSubview(spacer)
    }
    
    @MainActor
    func toggleSubscription(error: Bool = false) {
        subscriptionButton.isUserInteractionEnabled = true
        
        if #available(iOS 15, *) {
            subscriptionButton.configuration?.showsActivityIndicator = false
            
            guard !error else { return }
            
            subscriptionButton.configuration?.title = (userprofile.subscribedAt ? "unsubscribe" : "subscribe").localized.uppercased()
            subscriptionButton.configuration?.image = UIImage(systemName: userprofile.subscribedAt ? "hand.raised.slash.fill" : "hand.point.left.fill")
            if userprofile.subscribedAt {
                subscriptionButton.configuration?.baseBackgroundColor = .systemRed.withAlphaComponent(0.15)
            } else {
                subscriptionButton.configuration?.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue.withAlphaComponent(0.15) : K_COLOR_TABBAR.withAlphaComponent(0.15)
            }
        } else {
            guard let imageView = subscriptionButton.imageView,
                  let indicator = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator")
            else { return }
            
            let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                                   delay: 0,
                                                                   animations: { [weak self] in
                guard let self = self else { return }
                
                indicator.alpha = 0
                imageView.tintColor = self.userprofile.subscribedAt ? K_COLOR_RED : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
                self.subscriptionButton.backgroundColor = self.userprofile.subscribedAt ? .systemRed.withAlphaComponent(0.15) : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue.withAlphaComponent(0.15) : K_COLOR_TABBAR.withAlphaComponent(0.15)
            }) { _ in
                indicator.removeFromSuperview()
            }
            
            guard !error else { return }
            
            let attrString = NSMutableAttributedString(string: (self.userprofile.subscribedAt ? "unsubscribe" : "subscribe").localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                                                 forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: self.userprofile.subscribedAt ? .systemRed : K_COLOR_TABBAR
                                                       ])
            self.subscriptionButton.setAttributedTitle(attrString, for: .normal)
            self.subscriptionButton.setImage(UIImage(systemName: userprofile.subscribedAt ? "hand.raised.slash.fill" : "hand.point.left.fill"),
                                             for: .normal)
            self.subscriptionButton.imageView?.tintColor = K_COLOR_TABBAR
        }
    }
    
    @objc
    func buttonTapped() {
        subscriptionButton.isUserInteractionEnabled = false
        subscriptionPublisher.send(!userprofile.subscribedAt)
        
        if #available(iOS 15, *), !subscriptionButton.configuration.isNil {
            subscriptionButton.configuration!.showsActivityIndicator = true
        } else {
            guard let imageView = subscriptionButton.imageView else { return }
            
            imageView.clipsToBounds = false
            let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                  size: CGSize(width: imageView.bounds.height,
                                                                               height: imageView.bounds.height)))
            indicator.layoutCentered(in: imageView)
            indicator.color = userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
            indicator.startAnimating()
            indicator.accessibilityIdentifier = "indicator"
            
            UIView.animate(withDuration: 0.2) {
                indicator.alpha = 1
                imageView.tintColor = .clear
            }
        }
    }
    
    @objc
    func urlTapped(recognizer: UITapGestureRecognizer) {
        guard let sender = recognizer.view else { return }
        
        if sender is FacebookLogo, let url = userprofile.facebookURL {
            urlPublisher.send(url)
        } else if sender is InstagramLogo, let url = userprofile.instagramURL {
            urlPublisher.send(url)
        } else if sender is TikTokLogo, let url = userprofile.tiktokURL {
            urlPublisher.send(url)
        }
    }
}
