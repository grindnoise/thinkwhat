//
//  PlainBannerContent.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 01.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PlainBannerContent: UIView {
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIView! {
        didSet {
            imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : color
            imageContent.addEquallyTo(to: imageContainer)
            guard imageContent.isKind(of: UIImageView.self) else { return }
            (imageContent as! UIImageView).contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Properties
    private let text: String
    private var imageContent: UIView!
    private let color: UIColor
    private let textColor: UIColor
    private var observers: [NSKeyValueObservation] = []
    
    deinit {
        print("PlainBannerContent deinit")
    }
    
    // MARK: - Initialization
    init(text _text: String, imageContent _imageContent: UIView, color _color: UIColor, textColor: UIColor = .label) {
        self.text = _text
        self.color = _color
        self.imageContent = _imageContent
        self.textColor = textColor
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        backgroundColor = .clear
        bounds = UIScreen.main.bounds
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
        observers.append(label.observe(\UILabel.bounds) { [weak self] (label, change) in
            guard let self = self else { return }
            let paragraph = NSMutableParagraphStyle()
            if #available(iOS 15.0, *) {
                paragraph.usesDefaultHyphenation = true
            } else {
                paragraph.hyphenationFactor = 1
            }
            paragraph.alignment = .center
            let string = self.text
            let attributedText = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle : paragraph])
            attributedText.addAttributes(StringAttributes.getAttributes(font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .title3)!, foregroundColor: self.traitCollection.userInterfaceStyle == .dark ? .label : self.textColor, backgroundColor: .clear) as [NSAttributedString.Key : Any], range: string.fullRange())
            label.attributedText = attributedText
            guard label.numberOfTotatLines > 1 else { return }
            label.textAlignment = .left
        })
    }
    
    // MARK: - Overridden
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : color
    }
}
