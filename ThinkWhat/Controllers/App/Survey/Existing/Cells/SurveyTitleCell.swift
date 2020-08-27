//
//  SurveyTitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyTitleCell: UITableViewCell {

    @IBOutlet weak var icon: SurveyCategoryIcon!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var join: UIView!
    @IBOutlet weak var join_2: UIView!
    var survey: ShortSurvey! {
        didSet {
            icon.tagColor = survey.category?.parent?.tagColor
            icon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: survey.category!.ID) ?? .Null
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
