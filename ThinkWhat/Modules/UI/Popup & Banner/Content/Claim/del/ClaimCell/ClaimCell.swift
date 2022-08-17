//
//  ClaimCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ClaimCell: UITableViewCell {

    deinit {
        print("ClaimCell deinit")
    }
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    private var _claim: Claim!
    var claim: Claim {
        return _claim
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
    
    public func setupUI(claim __claim: Claim, color: UIColor) {
        setNeedsLayout()
        layoutIfNeeded()
        _claim = __claim
        let textContent = claim.description.contains("\t") ? claim.description : "\t" + claim.description
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        paragraphStyle.lineSpacing = 5
        let attributedString = NSMutableAttributedString(string: textContent,
                                                         attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
        attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: setTextColor(), backgroundColor: .clear) as [NSAttributedString.Key : Any], range: textContent.fullRange())
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 3, left: textView.textContainerInset.left, bottom: 3, right: textView.textContainerInset.right)
        checkBox.innerColor = color
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
        let textContent = claim.description.contains("\t") ? claim.description : "\t" + claim.description
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
