//
//  SettingsCellHeader.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 15.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class SettingsCellHeader: UICollectionReusableView {
    
    enum Mode: String {
        case City = "cityTF"
        case SocialMedia = "social_media"
        case Interests = "interests"
        case Stats = "stats"
        case Management = "account_management"
        case Notifications = "notifications"
    }
    
    
    
    // MARK: - Public properties
    public var mode: Mode! {
        didSet {
            guard let mode = mode else { return }
            
            headerLabel.text = mode.rawValue.localized.uppercased()
            
            guard let constraint = headerLabel.getConstraint(identifier: "width") else { return }
            
            constraint.constant = headerLabel.text!.width(withConstrainedHeight: 100, font: headerLabel.font)
        }
    }
    public var isBadgeEnabled = false {
        didSet {
            guard oldValue != isBadgeEnabled else { return }
            
//            badge.transform = oldValue ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, animations: { [weak self] in
                guard let self = self else { return }
                
                self.badge.transform = self.isBadgeEnabled ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.badge.alpha = self.isBadgeEnabled ? 1 : 0
            }) { _ in }
        }
    }
    public var isHelpEnabled = false {
        didSet {
            guard oldValue != isHelpEnabled else { return }
            
            self.help.alpha = isHelpEnabled ? 1 : 0
        }
    }
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 8
    private lazy var headerLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = ""//title.localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .footnote)
        
        let widthConstraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
        widthConstraint.identifier = "width"
        widthConstraint.isActive = true
        
        let heightConstraint = instance.heightAnchor.constraint(equalToConstant: instance.text!.height(withConstrainedWidth: 1000, font: instance.font))
        heightConstraint.identifier = "height"
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { [weak self] rect in
                guard let self = self,
                      let constraint = instance.getConstraint(identifier: "height")
                else { return }
                
                self.setNeedsLayout()
                constraint.constant = instance.text!.height(withConstrainedWidth: 1000, font: instance.font)
                self.layoutIfNeeded()
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var badge: UIImageView = {
        let instance = UIImageView()
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.contentMode = .center
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        instance.transform = isBadgeEnabled ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
        instance.alpha = isBadgeEnabled ? 1 : 0
        
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "circlebadge.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.5))!)
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var help: UIImageView = {
        let instance = UIImageView()
        instance.backgroundColor = .clear
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        instance.contentMode = .center
        instance.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.alpha = isHelpEnabled ? 1 : 0
        instance.isUserInteractionEnabled = true
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.helpTap)))
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.setImage(UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: rect.height*0.75, weight: .semibold))!)
            }
            .store(in: &subscriptions)

        return instance
    }()
    private lazy var headerContainer: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        
        let horizontalStack = UIStackView(arrangedSubviews: [headerLabel, badge])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 0
        
        instance.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
        ])
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
       let instance = UIStackView(arrangedSubviews: [headerContainer, help])
        instance.axis = .horizontal
        
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
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        clipsToBounds = true
        
        addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
//
//        let constraint = genderButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.identifier = "bottomAnchor"
//        constraint.isActive = true
    }
    
    private func setTasks() {
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FacebookURL) {
                guard let self = self,
                      self.mode == .SocialMedia,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.isBadgeEnabled = false
            }
        })
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.InstagramURL) {
                guard let self = self,
                      self.mode == .SocialMedia,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.isBadgeEnabled = false
            }
        })
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.TikTokURL) {
                guard let self = self,
                      self.mode == .SocialMedia,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.isBadgeEnabled = false
            }
        })
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NoSocialURL) {
                guard let self = self,
                      self.mode == .SocialMedia,
                      let userprofile = notification.object as? Userprofile,
                      userprofile.isCurrent
                else { return }
                
                self.isBadgeEnabled = true
            }
        })
    }
    
    @objc
    private func helpTap() {
        var text = ""
        switch mode {
        case .SocialMedia:
            text = "social_media_help"
        case .Interests:
            text = "interests_help"
        default:
            print("")
        }
        
        let banner = Popup(callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.5)
        banner.present(content: PopupContent(parent: banner,
                                             systemImage: "lightbulb.circle.fill",
                                             text: text.localized,
                                             buttonTitle: "ok",
                                             fixedSize: false,
                                             spacing: 24))
    }
    
    
    
    // MARK: - Overridden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        badge.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        help.tintColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
}

extension SettingsCellHeader: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}
