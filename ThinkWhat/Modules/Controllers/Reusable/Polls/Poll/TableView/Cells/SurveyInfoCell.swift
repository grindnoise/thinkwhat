//
//  SurveyInfoCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.04.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyInfoCell: UITableViewCell {

    var circularImage: UIImage!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
