//
//  SubcategoryTableViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubcategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    var category: SurveyCategory!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
