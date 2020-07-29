//
//  UserSubscriptionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.07.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserSubscriptionCell: UITableViewCell {

    
    @IBOutlet weak var claimSwitch: UISwitch!
    @IBAction func claimSwitched(_ sender: UISwitch) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
