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
    @IBOutlet weak var youtube: YoutubeLogo! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(LinkAttachmentCell.buttonTapped))
            touch.cancelsTouchesInView = false
            youtube.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var ig: InstagramLogo! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(LinkAttachmentCell.buttonTapped))
            touch.cancelsTouchesInView = false
            ig.addGestureRecognizer(touch)
        }
    }
    @IBOutlet weak var wiki: WikiLogo! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(LinkAttachmentCell.buttonTapped))
            touch.cancelsTouchesInView = false
            ig.addGestureRecognizer(touch)
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
