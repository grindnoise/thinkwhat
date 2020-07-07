//
//  SurveyVoteViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyVoteCell: UITableViewCell {

    
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.layer.cornerRadius = btn.frame.height / 2
        }
    }
    @IBAction func btnTapped(_ sender: Any) {
        delegate?.callbackReceived(self as AnyObject)
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

}
