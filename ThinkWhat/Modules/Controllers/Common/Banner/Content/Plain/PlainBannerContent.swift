//
//  PlainBannerContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PlainBannerContent: UIView {
    
    deinit {
        print("PlainBannerContent deinit")
    }
    
    init(text _text: String, imageContent _imageContent: UIView) {
        self.text = _text
        self.imageContent = _imageContent
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initialization
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor = .clear
        bounds = UIScreen.main.bounds
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIView! {
        didSet {
            imageContent.addEquallyTo(to: imageContainer)
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            let paragraph = NSMutableParagraphStyle()
            if #available(iOS 15.0, *) {
                paragraph.usesDefaultHyphenation = true
            } else {
                paragraph.hyphenationFactor = 1
            }
            let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
            attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 15), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: text.fullRange())
            textView.attributedText = attributedText
        }
    }
    
    // MARK: - IB Outlets
    private let text: String
    private let imageContent: UIView
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        switch traitCollection.userInterfaceStyle {
//        case .dark:
//
//        default:
//
//        }
//    }
}
