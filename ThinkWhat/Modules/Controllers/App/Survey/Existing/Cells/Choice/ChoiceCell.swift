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
    @IBOutlet weak var textView: UITextView! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(ChoiceCell.handleTap(recognizer:)))
            textView.addGestureRecognizer(recognizer)
        }
    }
    
    private var _answer: Answer!
    private weak var delegate: CallbackObservable?
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
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.callbackReceived(index as AnyObject)
        }
    }
    
    public func setupUI(delegate callbackDelegate: CallbackObservable, answer __answer: Answer) {
        setNeedsLayout()
        layoutIfNeeded()
        _answer = __answer
        delegate = callbackDelegate
        let textContent = answer.description.contains("\t") ? answer.description : "\t" + answer.description
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        paragraphStyle.lineSpacing = 5
        let attributedString = NSMutableAttributedString(string: textContent,
                                                         attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
        attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: setTextColor(), backgroundColor: .clear) as [NSAttributedString.Key : Any], range: textContent.fullRange())
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
    }
    
    private func setTextColor() -> UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return self.isChecked ? .white : .systemGray
            default:
                return self.isChecked ? .black : .systemGray
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
}
