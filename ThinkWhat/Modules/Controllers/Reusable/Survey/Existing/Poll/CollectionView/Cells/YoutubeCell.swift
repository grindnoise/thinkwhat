//
//  YoutubeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import Combine

class YoutubeCell: UICollectionViewCell {
    
    // MARK: - Overriden properties
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Public Properties
    public var item: Survey! {
        didSet {
            guard !item.isNil, let url = item.url, let id = url.absoluteString.youtubeID else { return }
            color = item.topic.tagColor
            playerView.load(withVideoId: id)
        }
    }
    public weak var callbackDelegate: CallbackObservable?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private lazy var disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .caption1)
        instance.text = "media".localized.uppercased()
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
        constraint.identifier = "width"
        constraint.isActive = true
        
        return instance
    }()
    private lazy var disclosureIndicator: UIImageView = {
        let instance = UIImageView()
        instance.image = UIImage(systemName: "chevron.down")
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.tintColor = .secondaryLabel
        instance.contentMode = .center
        instance.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        
        return instance
    }()
    private lazy var icon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "video.fill",
                                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: "1".height(withConstrainedWidth: 100,
                                                                                                                        font: disclosureLabel.font)*0.75)))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1/1).isActive = true

        return imageView
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        instance.alignment = .center
        instance.spacing = 4
        instance.axis = .horizontal
        instance.alignment = .center
        let constraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: contentView.bounds.width,
                                                                                         font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                                                                                 forTextStyle: .caption1)!))
        constraint.identifier = "height"
        constraint.isActive = true
        
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let opaque = UIView()
        opaque.backgroundColor = .clear
        opaque.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.leadingAnchor.constraint(equalTo: opaque.leadingAnchor, constant: padding).isActive = true
        horizontalStack.topAnchor.constraint(equalTo: opaque.topAnchor).isActive = true
        horizontalStack.bottomAnchor.constraint(equalTo: opaque.bottomAnchor).isActive = true
        
        let verticalStack = UIStackView(arrangedSubviews: [opaque, playerView])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    // Constraints
    private var closedConstraint: NSLayoutConstraint!
    private var openConstraint: NSLayoutConstraint!
    private lazy var loadingIndicator: LoadingIndicator = {
        let instance = LoadingIndicator(frame: .zero)
        playerView.addSubview(instance)
        instance.translatesAutoresizingMaskIntoConstraints = false
        instance.color = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        NSLayoutConstraint.activate([
            instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1),
            instance.topAnchor.constraint(equalTo: playerView.topAnchor),
            instance.bottomAnchor.constraint(equalTo: playerView.bottomAnchor),
            instance.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
        ])
        instance.addEnableAnimation()
        return instance
    }()
    private lazy var playerView: WKYTPlayerView = {
        let instance = WKYTPlayerView()
        instance.backgroundColor = .secondarySystemBackground
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
        instance.publisher(for: \.bounds)
            .filter { $0 != .zero }
            .sink { instance.cornerRadius = $0.width*0.025 }
            .store(in: &subscriptions)
        instance.delegate = self
        
        return instance
    }()
    private let padding: CGFloat = 8
    private var tempAppPreference: SideAppPreference?
    private var sideAppPreference: SideAppPreference? {
        if UserDefaults.App.youtubePlay == nil {
            return nil
        } else {
            return UserDefaults.App.youtubePlay
        }
    }
    private var isYoutubeInstalled: Bool {
        let appName = "youtube"
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        return UIApplication.shared.canOpenURL(appUrl! as URL)
    }
    private var color = UIColor.systemGray
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        verticalStack.get(all: UIView.self).filter({ $0.accessibilityIdentifier == "shadow" }).forEach {
            $0.layer.shadowOpacity = self.traitCollection.userInterfaceStyle == .dark ? 0 : 1
        }
//        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .systemBackground
        playerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .clear : color.withAlphaComponent(0.2)
//        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        if let imageView = icon.get(all: UIImageView.self).first {
//            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .caption1)
        guard let constraint = horizontalStack.getConstraint(identifier: "height"),
              let constraint_2 = disclosureLabel.getConstraint(identifier: "width")
        else { return }
        setNeedsLayout()
        constraint.constant = "test".height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font)
        constraint_2.constant = disclosureLabel.text!.width(withConstrainedHeight: 100, font: disclosureLabel.font)
        layoutIfNeeded()
    }
}
    
    // MARK: - Private
private extension YoutubeCell {
    @MainActor
    func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        
        setNeedsLayout()
        layoutIfNeeded()
        
        closedConstraint = horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint.priority = .defaultLow
        
        openConstraint = playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        openConstraint.priority = .defaultLow
        
        updateAppearance(animated: false)
    }
    
    /// Updates the views to reflect changes in selection
    func updateAppearance(animated: Bool = true) {
        closedConstraint.isActive = isSelected
        openConstraint.isActive = !isSelected

        guard animated else {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: isSelected ? .curveEaseOut : .curveEaseIn) {
            let upsideDown = CGAffineTransform(rotationAngle: -.pi/2 )
            self.disclosureIndicator.transform = self.isSelected ? upsideDown : .identity
        }
    }
    
    func openYotubeApp() {
        guard let url = item.url, let id = url.absoluteString.youtubeID else { return }
        let appScheme = "youtube://watch?v=\(id)"
        if let appUrl = URL(string: appScheme) {
            UIApplication.shared.open(appUrl)
        }
    }
}

extension YoutubeCell: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let preference = sender as? SideAppPreference {
            if preference == .App {
                tempAppPreference = .App
                openYotubeApp()
                playerView.stopVideo()
            } else {
                playerView.playVideo()
                tempAppPreference = .Embedded
            }
        }
    }
}

extension YoutubeCell: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        print("ready")
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingIndicator.alpha = 0
        }) {
            _ in
            self.loadingIndicator.removeAllAnimations()
            self.loadingIndicator.removeFromSuperview()
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        guard state == .buffering else { return }
        
        guard !sideAppPreference.isNil || !tempAppPreference.isNil else {
            playerView.stopVideo()
            let banner = Banner(frame: UIScreen.main.bounds,
                                fadeBackground: true)
            
            let content = SideApp(app: .Youtube)
            banner.present(content: content, isModal: true)
            banner.didDisappearPublisher
                .sink { _ in banner.removeFromSuperview() }
                .store(in: &self.subscriptions)
            
            return
        }
        
        if !sideAppPreference.isNil {
            switch sideAppPreference {
            case .App:
                guard isYoutubeInstalled else { playerView.playVideo(); return }
                openYotubeApp()
                playerView.stopVideo()
            default:
                playerView.playVideo()
            }
        } else if !tempAppPreference.isNil {
            switch tempAppPreference {
            case .App:
                guard isYoutubeInstalled else { playerView.playVideo(); return }
                openYotubeApp()
                playerView.stopVideo()
            default:
                playerView.playVideo()
            }
        }
    }
}

//extension YoutubeCell: BannerObservable {
//    func onBannerWillAppear(_ sender: Any) {}
//
//    func onBannerWillDisappear(_ sender: Any) {}
//
//    func onBannerDidAppear(_ sender: Any) {}
//
//    func onBannerDidDisappear(_ sender: Any) {
//        if let banner = sender as? Banner {
//            banner.removeFromSuperview()
//        } else if let popup = sender as? Popup {
//            popup.removeFromSuperview()
//        }
//    }
//}
