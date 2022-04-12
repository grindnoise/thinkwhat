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
    
    init(text _text: String, imageContent _imageContent: UIView, color _color: UIColor) {
        self.text = _text
        self.color = _color
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
            imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            imageContent.addEquallyTo(to: imageContainer)
        }
    }
    @IBOutlet weak var label: UILabel! {
        didSet {
            let paragraph = NSMutableParagraphStyle()
            if #available(iOS 15.0, *) {
                paragraph.usesDefaultHyphenation = true
            } else {
                paragraph.hyphenationFactor = 1
            }
            paragraph.alignment = .center
            let string = text
            let attributedText = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
            attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 16), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
            label.attributedText = attributedText
            guard label.numberOfTotatLines > 1 else { return }
            label.textAlignment = .left
        }
    }
//    @IBOutlet weak var textView: UITextView! {
//        didSet {
//            let paragraph = NSMutableParagraphStyle()
//            if #available(iOS 15.0, *) {
//                paragraph.usesDefaultHyphenation = true
//            } else {
//                paragraph.hyphenationFactor = 1
//            }
//            paragraph.alignment = .center
//            let string = "\t" + text
//            let attributedText = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
//            attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 15), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
//            textView.attributedText = attributedText
//            textView.centerVertically()
//
//////            let string = text
//////            let attributedText = NSMutableAttributedString(string: string)
//////            attributedText.addAttributes(StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 15), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
//////            textView.attributedText = attributedText
////            textView.text = text
////            imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
//        }
//    }
    
    // MARK: - IB Outlets
    private let text: String
    private let imageContent: UIView
    private let color: UIColor
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
}
