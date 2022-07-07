//
//  YoutubeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.07.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class YoutubeCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var item: Survey! {
        didSet {
            guard !item.isNil, let url = item.url, let id = url.absoluteString.youtubeID else { return }
            color = item.topic.tagColor
            playerView.load(withVideoId: id)
        }
    }
    public weak var callbackDelegate: CallbackObservable?
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Private Properties
    private let disclosureLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .secondaryLabel
        instance.text = "media".localized.uppercased()
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .footnote)
        return instance
    }()
    private let disclosureIndicator: UIImageView = {
        let disclosureIndicator = UIImageView()
        disclosureIndicator.image = UIImage(systemName: "chevron.down")
        disclosureIndicator.tintColor = .secondaryLabel
        disclosureIndicator.widthAnchor.constraint(equalTo: disclosureIndicator.heightAnchor, multiplier: 1/1).isActive = true
        disclosureIndicator.contentMode = .center
        disclosureIndicator.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        return disclosureIndicator
    }()
    private let icon: UIView = {
        let instance = UIView()
        instance.backgroundColor = .clear
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        let imageView = UIImageView(image: UIImage(systemName: "video.fill"))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .center
        imageView.addEquallyTo(to: instance)
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [icon, disclosureLabel, disclosureIndicator])
        instance.alignment = .center
        instance.axis = .horizontal
        instance.distribution = .fillProportionally
        let constraint = instance.heightAnchor.constraint(equalToConstant: 40)
        constraint.identifier = "height"
        constraint.isActive = true
        return instance
    }()
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView(arrangedSubviews: [horizontalStack, playerView])
        verticalStack.axis = .vertical
        verticalStack.spacing = padding
        return verticalStack
    }()
    private lazy var playerView: WKYTPlayerView = {
        let instance = WKYTPlayerView()
        instance.backgroundColor = .secondarySystemBackground
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 9/16).isActive = true
        instance.delegate = self
        return instance
    }()
    private var observers: [NSKeyValueObservation] = []
    private let padding: CGFloat = 0
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
    // Constraints
    private var closedConstraint: NSLayoutConstraint!
    private var openConstraint: NSLayoutConstraint!
    private var color: UIColor = .secondaryLabel {
        didSet {
            playerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
            disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
            disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
            guard let imageView = icon.get(all: UIImageView.self).first else { return }
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setObservers()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
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
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalStack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
//            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9/16),
        ])
//        let constraint = playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
//        constraint.priority = .defaultLow
//        constraint.isActive = true
//
        setNeedsLayout()
        layoutIfNeeded()
        
        closedConstraint =
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        openConstraint =
        playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        openConstraint?.priority = .defaultLow
        updateAppearance()
    }
    
    private func updateAppearance() {
        closedConstraint?.isActive = isSelected
        openConstraint?.isActive = !isSelected

        UIView.animate(withDuration: 0.3) {
            let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.999 )
            self.disclosureIndicator.transform = !self.isSelected ? upsideDown :.identity
        }
    }
    
    private func setObservers() {
        observers.append(playerView.observe(\WKYTPlayerView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = max(value.height, value.width) * 0.05
        })
//        observers.append(disclosureLabel.observe(\InsetLabel.bounds, options: .new) { [weak self] view, change in
//            guard let self = self, let newValue = change.newValue else { return }
//            view.insets = UIEdgeInsets(top: view.insets.top, left: self.playerView.cornerRadius, bottom: view.insets.bottom, right: view.insets.right)
////            view.font = UIFont(name: Fonts.Regular, size: newValue.height * 0.3)
//        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        playerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : color.withAlphaComponent(0.1)
        disclosureLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
        disclosureIndicator.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
        if let imageView = icon.get(all: UIImageView.self).first {
            imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color
        }
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        disclosureLabel.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue,
                                                 forTextStyle: .footnote)
        guard let constraint = horizontalStack.getAllConstraints().filter({$0.identifier == "height"}).first else { return }
        setNeedsLayout()
        constraint.constant = max(disclosureLabel.text!.height(withConstrainedWidth: disclosureLabel.bounds.width, font: disclosureLabel.font), 40)
        layoutIfNeeded()
    }
    
    private func openYotubeApp() {
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
//    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
//        print("ready")
//        UIView.animate(withDuration: 0.3, animations: {
//            self.loadingIndicator.alpha = 0
//        }) {
//            _ in
//            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//                self.playerView.alpha = 1
//            })
//        }
//    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        guard state == .buffering else { return }
        guard !sideAppPreference.isNil || !tempAppPreference.isNil else {
            playerView.stopVideo()
            let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self)
            let content = SideApp(app: .Youtube, callbackDelegate: banner)
            banner.present(content: content, isModal: true)
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

extension YoutubeCell: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}

    func onBannerWillDisappear(_ sender: Any) {}

    func onBannerDidAppear(_ sender: Any) {}

    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}
