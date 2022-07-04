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
    var url: URL? {
        didSet {
            guard !url.isNil, let id = url?.absoluteString.youtubeID else { return }
            playerView.load(withVideoId: id)
        }
    }
    
    // MARK: - Private Properties
    private lazy var playerView: WKYTPlayerView = {
        let instance = WKYTPlayerView()
        instance.backgroundColor = .secondarySystemBackground
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
    
    // MARK: - Public Properties
    public weak var callbackDelegate: CallbackObservable?
    
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
        contentView.addSubview(playerView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            playerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95),
            playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9/16),
        ])
        let constraint = playerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setObservers() {
        observers.append(playerView.observe(\WKYTPlayerView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = max(value.height, value.width) * 0.05
        })
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//    }
    
    private func openYotubeApp() {
        guard let id = url?.absoluteString.youtubeID else { return }
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
