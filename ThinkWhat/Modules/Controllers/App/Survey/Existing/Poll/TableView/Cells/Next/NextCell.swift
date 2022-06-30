//
//  NextCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class NextCell: UITableViewCell {

    weak var callbackDelegate: CallbackObservable?
    
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.setTitle("next".localized.uppercased(), for: .normal)
            btn.accessibilityIdentifier = "next"
        }
    }
    @IBAction func btnTapped(_ sender: Any) {
        callbackDelegate?.callbackReceived(btn)
    }
}
