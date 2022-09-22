//
//  HyperlinkCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class HyperlinkCell: UITableViewCell {

    private weak var delegate: CallbackObservable?
    private var isSetupComplete = false
    
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.callbackReceived(self)
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable) {
        if !isSetupComplete {
            setNeedsLayout()
            layoutIfNeeded()
            let categoryString = NSMutableAttributedString()
            categoryString.append(NSAttributedString(string: "more_info".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: 17), foregroundColor: .systemBlue, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
            button.setAttributedTitle(categoryString, for: .normal)
            delegate = callbackDelegate
            isSetupComplete = true
        }
    }
}
