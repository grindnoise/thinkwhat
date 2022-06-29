//
//  VoteMessage.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class VoteMessage: UIView {

    deinit {
        print("VoteMessage deinit")
    }
    
    init(imageContent _imageContent: UIView, color _color: UIColor, callbackDelegate _callbackDelegate: CallbackObservable) {
        self.callbackDelegate = _callbackDelegate
        self.imageContent = _imageContent
        self.color = _color
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
        attributedText.append(NSAttributedString(string: "congratulations".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.08), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "most_popular_choice".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: frame.width * 0.06), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.05), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "extra_points".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.06), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "2", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.07), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .systemBlue : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        attributedText.append(NSAttributedString(string: "points".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold, size: frame.width * 0.06), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
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
            btn.accessibilityIdentifier = "vote"
            btn.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            btn.setTitle("results".localized.uppercased(), for: .normal)
        }
    }
    @IBAction func btnTapped(_ sender: UIButton) {
        callbackDelegate?.callbackReceived(self)
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
    private weak var callbackDelegate: CallbackObservable?
    private let color: UIColor
}
