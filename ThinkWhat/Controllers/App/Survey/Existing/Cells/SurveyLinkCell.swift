//
//  SurveyLinkCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyLinkCell: UITableViewCell {
    
    @IBAction func linkTapped(_ sender: Any) {
        delegate?.callbackReceived(sender as AnyObject)
    }
    @IBOutlet weak var linkButton: UIButton!
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
