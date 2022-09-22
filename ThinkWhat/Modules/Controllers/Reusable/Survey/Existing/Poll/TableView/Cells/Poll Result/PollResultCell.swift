//
//  PollResultCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollResultCell: UITableViewCell {

    deinit {
        print("PollResultCell deinit")
    }
    
    enum Mode {
        case None, Anon, Default
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.autoresizingMask = [.flexibleHeight]
            guard !answer.isNil, !textView.isNil else { return }
            setText()
        }
    }
    @IBOutlet weak var container: UIView! {
        didSet {
            container.layer.masksToBounds = false
        }
    }
    var isViewSetupComplete = false
    public var answer: Answer!
    public var userChoice: Bool = false
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
    
//    override var frame: CGRect {
//        didSet {
//            guard !textView.isNil, !answer.isNil else { return }
//            setText()
//        }
//    }
    
//    override func layoutSubviews() {
//        guard !textView.isNil, !answer.isNil else { return }
//        setText()
//    }
    
    override var bounds: CGRect {
        didSet {
            guard !textView.isNil, !answer.isNil else { return }
            setText()
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
    
    public func setupUI(width _width: CGFloat, height _height: CGFloat) {
        guard !isViewSetupComplete else { return }
        layer.masksToBounds = false
        frame.size = CGSize(width: _width, height: _height)
        setNeedsLayout()
        layoutIfNeeded()
        container.backgroundColor = .clear
        isViewSetupComplete = true
    }
    
    public func setText() {
        let textContent = "\(answer.order + 1). \(answer.description)"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0
        paragraphStyle.lineSpacing = 5
        let attributedString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStyle])
        attributedString.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: userChoice ? StringAttributes.Fonts.Style.Semibold : StringAttributes.Fonts.Style.Regular, size: container.frame.height * 0.4), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: textContent.fullRange())
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        print(textView.frame)
    }
}
