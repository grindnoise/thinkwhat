//
//  SurveyAnswerCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 23.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class SurveyAnswerCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView! {
        didSet {
            if answer != nil {
                textView.text = answer?.values.first!
            }
        }
    }
    @IBOutlet weak var checkBox: CheckBox!
    var answer: [Int: String]? {
        didSet {
            if answer != nil, textView != nil, textView.text.isEmpty {
                textView.text = answer?.values.first!
            }
        }
    }
    var isChecked = false {
        didSet {
            if oldValue != isChecked, checkBox != nil {
                checkBox.isOn = isChecked
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
