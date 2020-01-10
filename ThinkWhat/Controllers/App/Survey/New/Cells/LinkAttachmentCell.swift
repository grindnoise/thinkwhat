//
//  LinkAttachmentCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class LinkAttachmentCell: UITableViewCell {

    @IBOutlet weak var link: UITextField!
    @IBOutlet weak var youtube: YoutubeIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(LinkAttachmentCell.buttonTapped))
            touch.cancelsTouchesInView = false
            youtube.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var wiki: WikiIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(LinkAttachmentCell.buttonTapped))
            touch.cancelsTouchesInView = false
            wiki.addGestureRecognizer(touch)
        }
    }
    var delegate: CellButtonDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc fileprivate func buttonTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, recognizer.view != nil {
            delegate?.cellSubviewTapped(recognizer.view!)
        }
    }

}
