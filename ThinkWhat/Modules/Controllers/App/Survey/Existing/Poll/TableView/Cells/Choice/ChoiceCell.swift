//
//  ChoiceCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 29.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceCell: UITableViewCell {

    deinit {
        print("ChoiceCell deinit")
    }
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    private var _answer: Answer!
    var answer: Answer {
        return _answer
    }
    var isChecked = false {
        didSet {
            if oldValue != isChecked, checkBox != nil {
                checkBox.isOn = isChecked
                UIView.transition(with: textView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.textView.textColor = self.setTextColor()
                })
            }
        }
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, answer __answer: Answer) {
        setNeedsLayout()
        layoutIfNeeded()
        _answer = __answer
        let textContent = answer.description.contains("\t") ? answer.description : "\t" + answer.description
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        paragraphStyle.lineSpacing = 5
        let attributedString = NSMutableAttributedString(string: textContent,
                                                         attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
        attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: setTextColor(), backgroundColor: .clear) as [NSAttributedString.Key : Any], range: textContent.fullRange())
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
        checkBox.innerColor = answer.survey?.topic.tagColor ?? K_COLOR_RED
    }
    
    private func setTextColor() -> UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return self.isChecked ? .white : .systemGray
            default:
                return self.isChecked ? .black : .darkGray
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let textContent = answer.description.contains("\t") ? answer.description : "\t" + answer.description
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        paragraphStyle.lineSpacing = 5
        let attributedString = NSMutableAttributedString(string: textContent,
                                                         attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
        attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: setTextColor(), backgroundColor: .clear) as [NSAttributedString.Key : Any], range: textContent.fullRange())
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 3,
                                                   left: textView.textContainerInset.left,
                                                   bottom: 3,
                                                   right: textView.textContainerInset.right)
    }
    
    override func prepareForReuse() {
        guard !checkBox.isNil else { return }
        isChecked = false
        checkBox.removeAllAnimations()
    }
}
