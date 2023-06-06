//
//  TitleCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TitleCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    private var isSetupComplete = false
    private weak var delegate: CallbackObservable?
    private var survey: Survey!
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, survey _survey: Survey) {
        guard !isSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        delegate = callbackDelegate
        survey = _survey
        label.text = survey.title
        isSetupComplete = true
    }
}
