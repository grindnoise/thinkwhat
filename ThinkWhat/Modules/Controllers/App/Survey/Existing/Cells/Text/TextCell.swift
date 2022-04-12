//
//  TextCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 28.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    private var isSetupComplete = false
    private weak var delegate: CallbackObservable?
    private var survey: Survey!
    
    @IBOutlet weak var textView: UITextView!
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, survey _survey: Survey, isQuestion: Bool = false) {
        guard !isSetupComplete else { return }
        setNeedsLayout()
        layoutIfNeeded()
        delegate = callbackDelegate
        survey = _survey
        
        let paragraph = NSMutableParagraphStyle()
        
        if #available(iOS 15.0, *) {
            paragraph.usesDefaultHyphenation = true
        } else {
            paragraph.hyphenationFactor = 1
        }
        
        let attributedText = NSMutableAttributedString(string: isQuestion ? survey.question : survey.description, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
        if isQuestion {
            attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.SemiboldItalic, size: 17), foregroundColor: .systemGray, backgroundColor: .clear), range: survey.question.fullRange())
        } else {
            attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .label, backgroundColor: .clear), range: survey.description.fullRange())
        }
        
        textView.attributedText = attributedText
        textView.textContainerInset = UIEdgeInsets(top: isQuestion ? 40 : textView.textContainerInset.left,
                                                   left: textView.textContainerInset.left,
                                                   bottom: isQuestion ? 40 : textView.textContainerInset.left,
                                                   right: textView.textContainerInset.right)
        isSetupComplete = true
    }
}
