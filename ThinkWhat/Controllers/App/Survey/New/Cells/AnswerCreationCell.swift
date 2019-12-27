//
//  AnswerCreationCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class AnswerCreationCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    let placeholder = "Введите вариант ответа.."
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = placeholder
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
