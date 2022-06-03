//
//  InsetLabel.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 20) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
