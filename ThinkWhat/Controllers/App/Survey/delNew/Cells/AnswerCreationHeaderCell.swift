//
//  AnswerCreationHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.12.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class AnswerCreationHeaderCell: UITableViewCell {


    @IBOutlet weak var addButton: PlusIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(AnswerCreationHeaderCell.addTapped))
            touch.cancelsTouchesInView = false
            addButton.addGestureRecognizer(touch)
        }
    }
    weak var delegate: CallbackDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc fileprivate func addTapped(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended, recognizer.view != nil {
            delegate?.callbackReceived(recognizer.view!)
        }
    }
}
