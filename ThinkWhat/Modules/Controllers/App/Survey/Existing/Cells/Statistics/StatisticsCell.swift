//
//  StatisticsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class StatisticsCell: UITableViewCell {
    
    

    @IBOutlet weak var progressCircle: ProgressCircle!
    @IBOutlet weak var completionLabel: UILabel! {
        didSet {
            completionLabel.text = "poll_complete_at".localized
        }
    }
    @IBOutlet weak var votedLabel: UILabel! {
        didSet {
            votedLabel.text = "voted".localized
        }
    }
    @IBOutlet weak var votersLabel: UILabel!
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBAction func btnTapped(_ sender: Any) {
        
    }
    
    private var isSetupComplete = false
    private var color: UIColor = K_COLOR_RED
    private weak var delegate: CallbackObservable?
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, color _color: UIColor, progress _progress: CGFloat, voters: Int, total: Int) {
        guard !isSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        delegate = callbackDelegate
        color = _color
        progressCircle.setupUI(foregroundColor: color, progress: _progress)
        btn.cornerRadius = btn.frame.height / 2.25
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        let fontSize = completionLabel.frame.height * 0.15 * 1.5
        completionLabel.font = StringAttributes.font(name: StringAttributes.FontStyle.Semibold.rawValue, size: fontSize)
        votedLabel.font = StringAttributes.font(name: StringAttributes.FontStyle.Semibold.rawValue, size: fontSize)
        //        votersLabel.font = StringAttributes.font(name: StringAttributes.FontStyle.Bold.rawValue, size: completionLabel.frame.height * 0.15 * 2)
        //        votersLabel.text = "\(voters)/\(total)"
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(voters)/".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: completionLabel.frame.height * 0.3), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\(total)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: completionLabel.frame.height * 0.3), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        votersLabel.attributedText = attributedText
//        votersLabel.sizeToFit()
        isSetupComplete = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
}
