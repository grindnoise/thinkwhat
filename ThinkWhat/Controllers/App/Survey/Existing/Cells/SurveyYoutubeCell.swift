//
//  SurveyYoutubeCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 17.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class SurveyYoutubeCell: UITableViewCell {

    fileprivate var isVideoLoaded = false
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var icon: FilmIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.callback))
            touch.cancelsTouchesInView = false
            icon.addGestureRecognizer(touch)
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.signalReceived(self)
    }
    weak var delegate: ButtonDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadVideo(url: String) {
        if !isVideoLoaded {
            isVideoLoaded = true
            if let id = url.youtubeID {
                playerView.load(withVideoId: id)
            }
                //self.playerView.load(withVideoId: "LSebnSTh3Ks", playerVars: ["playsinline" : 1])
        }
    }
}
