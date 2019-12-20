//
//  PrivacySelectionCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class PrivacySelectionCell: UITableViewCell {

    @IBOutlet weak var isOn: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
