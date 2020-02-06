//
//  SubcategorySelectionTableViewCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 06.02.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubcategorySelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var markSign: ValidSign!
    var category: SurveyCategory!
    var isMarked = false {
        didSet {
            if isMarked != oldValue {
                UIView.animate(withDuration: 0.05) {
                    self.markSign.alpha             = self.isMarked ? 1 : 0
                }
            }
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
