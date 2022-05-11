//
//  Confirm.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class Confirm: UIView, CallbackCallable {
    
    deinit {
#if DEBUG
        print("Confirm deinit")
#endif
    }
    
    init(imageContent _imageContent: UIView, text _text: String, buttonTitle _buttonTitle: String, identifier: String = "", color _color: UIColor = K_COLOR_RED) {
        self.text = _text
        self.color = _color
        self.imageContent = _imageContent
        self.buttonTitle = _buttonTitle
        super.init(frame: CGRect.zero)
        self.accessibilityIdentifier = identifier
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        guard let imageView = imageContainer.subviews.filter({$0 is UIImageView}).first as? UIImageView else { return }
        imageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
    private func setupUI() {
        guard !label.isNil else { return }
//        let paragraph = NSMutableParagraphStyle()
//        if #available(iOS 15.0, *) {
//            paragraph.usesDefaultHyphenation = true
//        } else {
//            paragraph.hyphenationFactor = 1
//        }
//        paragraph.alignment = .center
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: text.localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.06), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        label.attributedText = attributedText
    }
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageContainer: UIView! {
        didSet {
            imageContent.addEquallyTo(to: imageContainer)
            imageContent.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.accessibilityIdentifier = accessibilityIdentifier
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            btn.setTitle(buttonTitle.localized.uppercased(), for: .normal)
        }
    }
    @IBAction func btnTapped(_ sender: UIButton) {
        callbackDelegate?.callbackReceived(sender)
    }
    @IBOutlet weak var cancel: UIButton! {
        didSet {
            cancel.accessibilityIdentifier = "cancel"
            cancel.setTitle("cancel".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
        callbackDelegate?.callbackReceived(sender)
    }
    @IBOutlet weak var label: UILabel!
    
    override var frame: CGRect {
        didSet {
            setupUI()
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
        }
    }
    override var bounds: CGRect {
        didSet {
            setupUI()
            guard !btn.isNil else { return }
            btn.cornerRadius = btn.frame.height / 2.25
        }
    }
    private let imageContent: UIView
    private let text: String
    private let buttonTitle: String
    private let color: UIColor
    internal weak var callbackDelegate: CallbackObservable?
}
