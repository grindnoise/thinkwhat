//
//  YoutubeBanner.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.08.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class YoutubeBanner: UIView, BannerContent {
    var foldable = false
    var minHeigth: CGFloat {
        return topView.frame.height
    }
    var maxHeigth: CGFloat {
        return topView.frame.height
    }

    weak var delegate: CallbackDelegate?
    deinit {
        print("Warning banner deinit")
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var icon: YoutubeLogo!

    @IBOutlet weak var playButton: UIButton!
    @IBAction func playEmbedded(_ sender: Any) {
        Banner.shared.dismiss() {
            _ in
            self.delegate?.callbackReceived(YoutubePlayOption.Embedded as AnyObject)
            AppData.shared.system.youtubePlayOption = self.defaultSwitch.isOn ? YoutubePlayOption.Embedded : AppData.shared.system.youtubePlayOption
        }
    }
    @IBOutlet weak var openButton: UIButton!
    @IBAction func openYoutubeApp(_ sender: Any) {
        Banner.shared.dismiss() {
            _ in
            self.delegate?.callbackReceived(YoutubePlayOption.App as AnyObject)
            AppData.shared.system.youtubePlayOption = self.defaultSwitch.isOn ? YoutubePlayOption.App : AppData.shared.system.youtubePlayOption
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
        Bundle.main.loadNibNamed("YoutubeBanner", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        self.backgroundColor = .clear
    }
}
