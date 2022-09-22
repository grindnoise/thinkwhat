//
//  AnswerHeaderCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class AnswerHeaderCell: UITableViewHeaderFooterView {

    weak var delegate: CallbackObservable?
    @IBOutlet weak var icon: ManTalikngIcon! {
        didSet {
            let touch = UITapGestureRecognizer(target:self, action:#selector(self.callback))
            touch.cancelsTouchesInView = false
            icon.addGestureRecognizer(touch)
        }
    }
    
    @objc fileprivate func callback() {
        delegate?.callbackReceived(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
