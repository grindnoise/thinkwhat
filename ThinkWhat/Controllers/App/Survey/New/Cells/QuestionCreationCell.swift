//
//  QuestionCreationCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class QuestionCreationCell: UITableViewCell {

    let questionPlaceholder = "Введите текст Вашего опроса"
    @IBOutlet weak var question: UITextView! {
        didSet {
            question.text = questionPlaceholder
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
