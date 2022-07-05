//
//  YoutubeBanner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class SideApp: UIView, BannerContent {
    var app: ThirdPartyApp = .Null {
        didSet {
            if oldValue != app {
                if icon != nil {
                    icon.subviews.forEach({ $0.removeFromSuperview() })
                    let _icon = app.getIcon()
                    _icon.isOpaque = false
                    _icon.addEquallyTo(to: icon)
                }
                if openButton != nil {
                    openButton.setTitle("Открыть в приложении \(app.rawValue)", for: .normal)
                }
            }
        }
    }
    var foldable = false
    var minHeigth: CGFloat {
        return topView.frame.height
    }
    var maxHeigth: CGFloat {
        return topView.frame.height
    }

    weak var delegate: CallbackObservable?
    deinit {
        print("Warning banner deinit")
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var icon: UIView!

    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.setTitle("play_youtube".localized, for: .normal)
        }
    }
    @IBAction func playEmbedded(_ sender: Any) {
        if defaultSwitch.isOn {
            switch app {
            case .TikTok:
                UserDefaults.App.tiktokPlay = .Embedded
            case .Youtube:
                UserDefaults.App.youtubePlay = .Embedded
            case .Null:
                print("")
            }
        }
        self.delegate?.callbackReceived(SideAppPreference.Embedded)
//        if localhost {
//        UserDefaults.App.youtubePlay = nil
//        }
    }
    @IBOutlet weak var openButton: UIButton! {
        didSet {
            var title = ""
            if app == .Youtube {
                title = "open_youtube".localized
            } else if app == .TikTok {
                title = "open_tiktok".localized
            }
            openButton.setTitle(title, for: .normal)
        }
    }
    @IBAction func openYoutubeApp(_ sender: Any) {
        if defaultSwitch.isOn {
            switch app {
            case .TikTok:
                UserDefaults.App.tiktokPlay = .App
            case .Youtube:
                UserDefaults.App.youtubePlay = .App
            case .Null:
                print("")
            }
        }
        self.delegate?.callbackReceived(SideAppPreference.App)
//        if localhost {
//        UserDefaults.App.youtubePlay = nil
//        }
    }
    
    @IBAction func onChange(_ sender: UISwitch) {
        print(sender.isOn)
    }
    @IBOutlet weak var defaultSwitch: UISwitch! {
        didSet {
            defaultSwitch.onTintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = "remember".localized
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    init(app _app: ThirdPartyApp, callbackDelegate _callbackDelegate: CallbackObservable? = nil) {
        super.init(frame: .zero)
        self.app = _app
        self.delegate = _callbackDelegate
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    init(width: CGFloat) {
        let _frame = CGRect(origin: .zero, size: CGSize(width: width, height: width))///frameRatio))
        super.init(frame: _frame)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SideApp", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
        guard !icon.isNil else { return }
        switch app {
        case .TikTok:
            let v = TikTokLogo(frame: icon.frame)
            v.isOpaque = false
            v.addEquallyTo(to: icon)
        case .Youtube:
            let v = YoutubeLogo(frame: icon.frame)
            v.isOpaque = false
            v.addEquallyTo(to: icon)
        case .Null:
            print("")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            self.defaultSwitch.onTintColor = .systemBlue
        default:
            self.defaultSwitch.onTintColor = .systemGreen
        }
    }
}
