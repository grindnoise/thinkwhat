//
//  SurveyResultCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyResultCell: UITableViewCell {
    
    var percent: Int = 0 {
        didSet {
            label.percent = CGFloat(percent) / 100
            percentLabel.text = "\(percent)%"
        }
    }
    @IBOutlet weak var label: PercentageLabel!
    @IBOutlet weak var percentLabel: UILabel! {
        didSet {
            percentLabel.textColor = K_COLOR_RED
        }
    }
}
