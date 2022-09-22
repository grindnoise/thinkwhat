//
//  StatisticsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 14.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class StatisticsCell: UITableViewCell {
    
    

    @IBOutlet weak var progressCircle: ProgressCircle! {
        didSet {
            progressCircle.clipsToBounds = false
        }
    }
    @IBOutlet weak var completionLabel: ArcLabel! {
        didSet {
            completionLabel.text = "progress".localized
        }
    }
    @IBOutlet weak var votersLabel: UILabel!
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.setTitle("support_poll".localized.uppercased(), for: .normal)
            btn.accessibilityIdentifier = "support"
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
        progressCircle.setupUI(foregroundColor: color, progress: _progress, lineWidthFactor: 0.1)
        btn.cornerRadius = btn.frame.height / 2.25
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        let fontSize = completionLabel.frame.height * 0.08
        completionLabel.font = StringAttributes.font(name: StringAttributes.FontStyle.Semibold.rawValue, size: fontSize)
        completionLabel.textColor = .secondaryLabel
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "voted".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: completionLabel.frame.height * 0.1), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n\(voters.roundedWithAbbreviations)/".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: completionLabel.frame.height * 0.12), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\(total.roundedWithAbbreviations)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: completionLabel.frame.height * 0.12), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n" + "people_voted".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: completionLabel.frame.height * 0.1), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        votersLabel.attributedText = attributedText
//        votersLabel.sizeToFit()
        isSetupComplete = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
}
