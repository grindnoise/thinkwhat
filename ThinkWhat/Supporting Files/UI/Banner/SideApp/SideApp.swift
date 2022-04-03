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

    @IBOutlet weak var playButton: UIButton!
    @IBAction func playEmbedded(_ sender: Any) {
        delBanner.shared.dismiss() {
            _ in
            self.delegate?.callbackReceived(SideAppPreference.Embedded as AnyObject)
            if self.app == .Youtube {
                UserDefaults.App.youtubePlay = self.defaultSwitch.isOn ? SideAppPreference.Embedded : UserDefaults.App.youtubePlay
            } else if self.app == .TikTok {
                UserDefaults.App.tiktokPlay = self.defaultSwitch.isOn ? SideAppPreference.Embedded : UserDefaults.App.tiktokPlay
            }
        }
    }
    @IBOutlet weak var openButton: UIButton!
    @IBAction func openYoutubeApp(_ sender: Any) {
        delBanner.shared.dismiss() {
            _ in
            self.delegate?.callbackReceived(SideAppPreference.App as AnyObject)
            if self.app == .Youtube {
                UserDefaults.App.youtubePlay = self.defaultSwitch.isOn ? SideAppPreference.Embedded : UserDefaults.App.youtubePlay
            } else if self.app == .TikTok {
                UserDefaults.App.tiktokPlay = self.defaultSwitch.isOn ? SideAppPreference.Embedded : UserDefaults.App.tiktokPlay
            }
        }
    }
    @IBAction func setDefault(_ sender: Any) {
        //TODO
    }
    @IBOutlet weak var defaultSwitch: UISwitch! {
        didSet {
            defaultSwitch.onTintColor = K_COLOR_RED
        }
    }
    @IBOutlet weak var valueChanged: UIView!
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
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
    }
}
