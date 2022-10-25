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
    public var surveysPublisher = CurrentValueSubject<Survey.SurveyCategory?, Never>(nil)
    public var imagePublisher = CurrentValueSubject<Bool?, Never>(nil)
    
    
    
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
        instance.previewPublisher.sink { [weak self] in
            guard let self = self,
                  let image = $0
            else { return }
            
            print("previewPublisher")
            //            self.previewPublisher.send(image)
        }.store(in: &subscriptions)
        
        return instance
    }()
    private lazy var username: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .left
        instance.numberOfLines = 2
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
        
        return instance
    }()
    private lazy var info: UILabel = {
        let instance = UILabel()
        instance.textAlignment = .left
        instance.numberOfLines = 1
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline)
        
        return instance
    }()
    private lazy var socialMediaStack: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.distribution = .fillEqually
        
        return instance
    }()
    private lazy var subscriptionButton: UIButton = {
        let instance = UIButton()
        instance.addTarget(self, action: #selector(self.toggleSubscription), for: .touchUpInside)
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
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
            config.buttonSize = .mini
            config.contentInsets.leading = 0
            config.contentInsets.top = 0
            config.contentInsets.bottom = 0
            config.imagePlacement = .trailing
            config.imagePadding = 4.0
            config.imageColorTransformer = UIConfigurationColorTransformer { _ in return .systemRed }
            config.image = UIImage(systemName: "hand.raised.slash.fill",
                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            instance.configuration = config
        } else {
            instance.semanticContentAttribute = .forceRightToLeft
            instance.setImage(UIImage(systemName: "hand.raised.slash.fill",
                                      withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                              for: .normal)
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
        instance.spacing = 2
        
        return instance
    }()
    private lazy var stack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [
            avatar,
            verticalStack
        ])
        instance.axis = .horizontal
        instance.spacing = padding

        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: instance.topAnchor),
            avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            avatar.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            avatar.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/3)
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
        
        if #unavailable(iOS 15), !userprofile.isNil {
            let attrString = NSMutableAttributedString(string: (userprofile.subscribedAt ? "unsubscribe" : "subscribe").localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                                                 forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: self.userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
                                                       ])
            subscriptionButton.setAttributedTitle(attrString, for: .normal)
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        urlPublisher = CurrentValueSubject<URL?, Never>(nil)
        surveysPublisher = CurrentValueSubject<Survey.SurveyCategory?, Never>(nil)
        imagePublisher = CurrentValueSubject<Bool?, Never>(nil)
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
        
        let constraint = stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        constraint.priority = .defaultLow
        constraint.identifier = "bottomAnchor"
        constraint.isActive = true
    }
    
    @MainActor
    func setTasks() {
        //Subscription events
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.System.ImageUploadStart) {
                guard let self = self,
                      let dict = notification.object as? [Userprofile: UIImage],
                      let userprofile = dict.keys.first,
                      let image = dict.values.first,
                      userprofile.isCurrent
                else { return }

                delayAsync(delay: 0.15) {
                    self.avatar.imageUploadStarted(image)
                }
            }
        })
    }
    
    @MainActor
    func updateUI() {
        func setupSocialMediaStack() {
            //FB
            if !userprofile.facebookURL.isNil {
                let instance = FacebookLogo()
                instance.accessibilityIdentifier = SocialMedia.Facebook.rawValue
                instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
                instance.isOpaque = false
                instance.isUserInteractionEnabled = true
                instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.urlTapped(recognizer:))))
                
                socialMediaStack.addArrangedSubview(instance)
            }
            //Instagram
            if !userprofile.instagramURL.isNil {
                let instance = InstagramLogo()
                instance.accessibilityIdentifier = SocialMedia.Instagram.rawValue
                instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
                instance.isOpaque = false
                instance.isUserInteractionEnabled = true
                instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.urlTapped(recognizer:))))
                
                socialMediaStack.addArrangedSubview(instance)
            }
            //Tiktok
            if !userprofile.tiktokURL.isNil {
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
                                                                                                 forTextStyle: .title3)!)).isActive = true
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
        } else {
            let attrString = NSMutableAttributedString(string: (userprofile.subscribedAt ? "unsubscribe" : "subscribe").localized.uppercased(),
                                                       attributes: [
                                                        .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                                                 forTextStyle: .subheadline) as Any,
                                                        .foregroundColor: self.userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
                                                       ])
        subscriptionButton.setAttributedTitle(attrString, for: .normal)
        subscriptionButton.imageView?.tintColor = self.userprofile.subscribedAt ? UIColor.systemRed : self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_TABBAR
                }
        
        //Social network
        if userprofile.hasSocialMedia {
            setupSocialMediaStack()
            verticalStack.addArrangedSubview(socialMediaStack)
        }
        
        //Subscription
        verticalStack.addArrangedSubview(subscriptionButton)
        
        //Stats
        
        //Bottom spacer
        let spacer = UIView()
        spacer.backgroundColor = .clear
        verticalStack.addArrangedSubview(spacer)
    }
    
    @objc
    func toggleSubscription() {
        subscriptionButton.isUserInteractionEnabled = false
        
        if #available(iOS 15, *), !subscriptionButton.configuration.isNil {
            subscriptionButton.configuration!.showsActivityIndicator = true
            
            delayAsync(delay: 2) { [weak self] in
                guard let self = self else { return }
                
                self.subscriptionButton.configuration!.title = "subscribe".localized.uppercased()
                self.subscriptionButton.configuration!.showsActivityIndicator = false
                self.subscriptionButton.configuration!.image = UIImage(systemName: "hand.point.left.fill")
            }
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
        
        delayAsync(delay: 2) { [weak self] in
            guard let self = self,
                  let imageView = self.subscriptionButton.imageView,
                  let indicator = imageView.getSubview(type: UIActivityIndicatorView.self, identifier: "indicator")
            else { return }
            
            indicator.removeFromSuperview()
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
                guard let self = self else { return }
                
                indicator.alpha = 0
                let attrString = NSMutableAttributedString(string: "subscribe".localized.uppercased(),
                                                           attributes: [
                                                            .font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue,
                                                                                     forTextStyle: .subheadline) as Any,
                                                            .foregroundColor: K_COLOR_TABBAR
                                                           ])
                self.subscriptionButton.setAttributedTitle(attrString, for: .normal)
                self.subscriptionButton.setImage(UIImage(systemName: "hand.point.left.fill"), for: .normal)
                self.subscriptionButton.imageView?.tintColor = K_COLOR_TABBAR
            }
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
