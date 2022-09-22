//
//  YoutubeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class _YoutubeCell: UITableViewCell, WKYTPlayerViewDelegate, CallbackObservable {

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
    private var videoID = ""
    private weak var delegate: CallbackObservable?
    private var isSetupComplete = false
    private var loadingIndicator: LoadingIndicator!
    private var isVideoLoaded = false
    private var banner: Banner?
    private var color = K_COLOR_RED

    @IBOutlet weak var playerView: WKYTPlayerView! {
        didSet {
            playerView.alpha = 0
            playerView.delegate = self
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: contentView.frame.height, height: contentView.frame.height)), color: color)
            loadingIndicator.layer.masksToBounds = false
            loadingIndicator.layoutCentered(in: contentView, multiplier: 0.2)//addEquallyTo(to: tableView)
            loadingIndicator.addEnableAnimation()
        }
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, videoID id: String, color: UIColor = K_COLOR_RED) {
        if !isSetupComplete {
            setNeedsLayout()
            layoutIfNeeded()
            videoID = id
            delegate = callbackDelegate
            isSetupComplete = true
            playerView.cornerRadius = playerView.frame.width * 0.05
            loadingIndicator.color = color
            loadVideo()
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.callbackReceived(self)
    }
    
    private func loadVideo() {
        if !isVideoLoaded {
            isVideoLoaded = true
            playerView.load(withVideoId: videoID)
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        print("ready")
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingIndicator.alpha = 0
        }) {
            _ in
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                self.playerView.alpha = 1
            })
        }
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state == .buffering {
            if sideAppPreference != nil {
                if sideAppPreference! == .Embedded {
                    playerView.playVideo()
                } else {
                    if isYoutubeInstalled {
                        playInYotubeApp()
                        playerView.stopVideo()
                    }
                }
            } else if isYoutubeInstalled, tempAppPreference == nil {
                playerView.pauseVideo()
                playerView.stopVideo()
                banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, fadeBackground: true)
                banner?.present(content: SideApp(app: .Youtube, callbackDelegate: self), isModal: true)
            } else {
                if tempAppPreference == .Embedded {
                    playerView.playVideo()
                } else {
                    if isYoutubeInstalled {
                        playInYotubeApp()
                        playerView.stopVideo()
                    } else {
                        playerView.playVideo()
                    }
                }
            }
        }
    }
    
    private func playInYotubeApp() {
        let appScheme = "youtube://watch?v=\(videoID)"
        if let appUrl = URL(string: appScheme) {
            UIApplication.shared.open(appUrl)
        }
    }

    func callbackReceived(_ sender: Any) {
        if sender is SideApp {
            banner?.dismiss()
        }
    }
}

extension _YoutubeCell: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}

    func onBannerWillDisappear(_ sender: Any) {}

    func onBannerDidAppear(_ sender: Any) {}

    func onBannerDidDisappear(_ sender: Any) {
        switch UserDefaults.App.youtubePlay {
        case .App:
            tempAppPreference = .App
            playInYotubeApp()
            playerView.stopVideo()
        default:
            playerView.playVideo()
            tempAppPreference = .Embedded
        }
        banner?.removeFromSuperview()
    }
}
