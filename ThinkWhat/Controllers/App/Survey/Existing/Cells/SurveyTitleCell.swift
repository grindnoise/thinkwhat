//
//  SurveyTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyTitleCell: UITableViewCell {

    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var icon: SurveyCategoryIcon!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var join: UIView!
    @IBOutlet weak var join_2: UIView!
    var survey: SurveyRef! {
        didSet {
            icon.backgroundColor = survey.category.parent?.tagColor
            icon.category = SurveyCategoryIcon.Category(rawValue: survey.category.ID) ?? .Null
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
