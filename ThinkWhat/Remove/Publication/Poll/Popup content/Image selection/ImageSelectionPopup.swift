//
//  ImageSelectionPopup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ImageSelectionPopup: UIView, UINavigationControllerDelegate {
    
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable, item: ImageItem, index: Int = 0) {
        super.init(frame: .zero)
        self.index = index
        self.item = item
        self.callbackDelegate = callbackDelegate
        commonInit()
    }
    
    override init(frame: CGRect) {
        fatalError()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setObservers()
        setupUI()
    }
    
    private func setObservers() {
        observers.append(imageView.observe(\UIImageView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.imageView.cornerRadius = value.width * 0.05
        }))
        observers.append(textView.observe(\UITextView.bounds, options: .new) { [weak self] view, change in
            guard !self.isNil, let newValue = change.newValue else { return }
            view.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: newValue.width * 0.05)
        })
        observers.append(textViewBg.observe(\UIView.bounds, options: .new) { [weak self] view, change in
            guard !self.isNil, !change.newValue.isNil else { return }
            view.cornerRadius = change.newValue!.width * 0.05
        })
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func setupUI() {
        setText()
    }
    
    private func setText() {
        let fontSize_1: CGFloat = title.bounds.height * 0.3
        
        let topicTitleString = NSMutableAttributedString()
        topicTitleString.append(NSAttributedString(string: "image".localized + " #\(index)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize_1), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = topicTitleString
        
        let descrAttrString = NSMutableAttributedString()
        descrAttrString.append(NSAttributedString(string: "caption".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: descriptionLabel.bounds.width * 0.04), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        descriptionLabel.attributedText = descrAttrString
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let v = recognizer.view {
            if v === confirm {
                item.title = textView.text
                callbackDelegate?.callbackReceived(item as Any)
            } else if v === delete {
                item.shouldBeDeleted = true
                callbackDelegate?.callbackReceived(item as Any)
            }
        }
    }
    
    @objc private func keyboardDidHide() {
        if let recognizer = gestureRecognizers?.filter({ $0.accessibilityValue == "hideKeyboard" }).first {
            gestureRecognizers?.remove(object: recognizer)
        }
    }
    
    @objc private func keyboardDidShow() {
        guard gestureRecognizers.isNil || gestureRecognizers!.filter({ $0.accessibilityValue == "hideKeyboard" }).isEmpty else { return }
        let touch = UITapGestureRecognizer(target:self, action: #selector(self.hideKeyboard))
        touch.accessibilityValue = "hideKeyboard"
        self.addGestureRecognizer(touch)
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        confirm.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        textView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    }
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
            imageView.image = item.image
        }
    }
    @IBOutlet weak var descriptionLabel: InsetLabel! {
        didSet {
            descriptionLabel.insets = UIEdgeInsets(top: 10,
                                                   left: 10,
                                                   bottom: 10,
                                                   right: 10)
        }
    }
    @IBOutlet weak var previewStackView: UIStackView!
    @IBOutlet weak var textViewBg: UIView! {
        didSet {
            textViewBg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            textView.text = item.title
            textView.delegate = self
        }
    }
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var delete: UIImageView! {
        didSet {
            delete.isUserInteractionEnabled = true
            delete.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            delete.tintColor = .systemRed
        }
    }

    private weak var callbackDelegate: CallbackObservable?
    private var item: ImageItem! {
        didSet {
            guard item.image.isNil else {
                imageView.image = item.image
                buttonsStackView.addArrangedSubview(confirm)
                confirm.alpha = 1
                previewStackView.alpha = 1
                return
            }
        }
    }
    private var index = 0
    private var observers: [NSKeyValueObservation] = []
}

extension ImageSelectionPopup: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
                
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= ModelProperties.shared.surveyMediaTitleMaxLength
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        item.title = textView.text
    }
}
