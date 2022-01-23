//
//  SurveyYoutubeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class SurveyYoutubeCell: UITableViewCell, WKYTPlayerViewDelegate {

    fileprivate var loadingIndicator: LoadingIndicator!
    fileprivate var isVideoLoaded = false
    @IBOutlet weak var subv: UIView! {
        didSet {
            loadingIndicator = LoadingIndicator(frame: CGRect(origin: .zero, size: CGSize(width: subv.frame.height, height: subv.frame.height)))
            loadingIndicator.layoutCentered(in: subv, multiplier: 0.6)//addEquallyTo(to: tableView)
            loadingIndicator.addEnableAnimation()
        }
    }
    @IBOutlet weak var playerView: WKYTPlayerView! {
        didSet {
            playerView.alpha = 0
            playerView.delegate = self
        }
    }
    @IBOutlet weak var icon: FilmIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.callback))
            touch.cancelsTouchesInView = false
            icon.addGestureRecognizer(touch)
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.callbackReceived(self)
    }
    weak var delegate: CallbackDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadVideo(url: URL) {
        if !isVideoLoaded {
            isVideoLoaded = true
            if let id = url.absoluteString.youtubeID {
                playerView.load(withVideoId: id)
            }
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
}
