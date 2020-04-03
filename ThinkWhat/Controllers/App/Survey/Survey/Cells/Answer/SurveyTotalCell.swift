//
//  SurveyTotalCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyTotalCell: UITableViewCell {

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.textColor = .gray
        }
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
