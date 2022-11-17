//
//  ChoiceResultCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 30.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceResultCell: UITableViewCell {
    enum Mode {
        case None, Anon, Stock
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            if answer != nil {
                let textContent = answer.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .black, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            }
        }
    }
    @IBOutlet weak var container: UIView! {
        didSet {
            container.layer.masksToBounds = false
        }
    }
    var isViewSetupComplete = false
    var answer: Answer! {
        didSet {
            if textView != nil {
                let textContent = answer.description
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.hyphenationFactor = 1.0
                paragraphStyle.lineSpacing = 5
                let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
                attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 14), foregroundColor: .black, backgroundColor: .clear), range: textContent.fullRange())
                textView.attributedText = attributedString
                textView.textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
            }
        }
    }
    private var resultIndicator: ResultIndicator? {
        didSet {
            if resultIndicator != nil {
                resultIndicator!.addEquallyTo(to: container)
//                resultIndicator!.updateUI()
            } else if oldValue != nil {
                oldValue?.removeFromSuperview()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        container.subviews.forEach({ $0.removeFromSuperview() })
    }

    func setResultIndicator(_ _resultIndicator: ResultIndicator) {
        resultIndicator = _resultIndicator
    }

    func getResultIndicator() -> ResultIndicator? {
        return resultIndicator
    }
}

class SurveyVoteCell: UITableViewCell {
    @IBOutlet weak var claimIcon: Icon! {
        didSet {
            claimIcon.backgroundColor = .clear
            claimIcon.isRounded = false
            claimIcon.iconColor = Colors.System.Red.rawValue//Colors.Tags.OrangeSoda
            claimIcon.scaleMultiplicator = 1.35
            claimIcon.category = .Caution
        }
    }
    @IBOutlet weak var claimButton: UIButton! {
        didSet {
//            claimButton.setTitleColor(Colors.Tags.OrangeSoda, for: .normal)
        }
    }
    @IBAction func claimTapped(_ sender: Any) {
        delegate?.callbackReceived("claim" as AnyObject)
    }
    @IBOutlet weak var btn: UIButton!
    @IBAction func btnTapped(_ sender: Any) {
        delegate?.callbackReceived("vote" as AnyObject)
    }
    weak var delegate: CallbackObservable?
}
