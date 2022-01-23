//
//  UserSurveysCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.07.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class UserSurveysCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var icon: SurveysIcon!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
