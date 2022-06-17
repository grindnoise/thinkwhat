//
//  ChoiceEditingPopup.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 16.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ChoiceEditingPopup: UIView {
    enum Mode {
        case Create, Edit
    }
    
    // MARK: - Initialization
    init(callbackDelegate: CallbackObservable, item: ChoiceItem? = nil, index: Int = 0, forceEditing: Bool = false) {
        super.init(frame: .zero)
        self.item = item
        self.index = index
        self.mode = item.isNil ? .Create : .Edit
        self.forceEditing = forceEditing
        self.callbackDelegate = callbackDelegate
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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
        if forceEditing {
            delay(seconds: 0.2) {
                self.textView.becomeFirstResponder()
            }
        }
    }
    
    private func setObservers() {
        observers.append(background.observe(\UIView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self, let value = change.newValue else { return }
            self.background.cornerRadius = value.width * 0.05
        }))
        observers.append(textView.observe(\UITextView.bounds, options: .new, changeHandler: { [weak self] (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let self = self else { return }
            self.textView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: self.textView.bounds.width * 0.075)
        }))

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupUI() {
        setText()
        if mode == .Create {
            buttonsStackView.removeArrangedSubview(delete)
            buttonsStackView.removeArrangedSubview(confirm)
            delete.alpha = 0
            confirm.alpha = 0
        }
    }
    
    private func setText() {
        let fontSize: CGFloat = title.bounds.height * 0.4
        
        let topicTitleString = NSMutableAttributedString()
        topicTitleString.append(NSAttributedString(string: mode == .Create ? "new_choice".localized : "edit_choice".localized + " #\(index)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = topicTitleString

        textView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let v = recognizer.view {
            if v === confirm {
                if mode == .Create { item = ChoiceItem(text: textView.text) }
                callbackDelegate?.callbackReceived(item as Any)
            } else if v === cancel {
                callbackDelegate?.callbackReceived("exit" as Any)
            } else if v === delete {
                item?.shouldBeDeleted = true
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
        cancel.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        confirm.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
    }
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var background: UIView! {
        didSet {
            background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = item?.text ?? ""
            textView.delegate = self
        }
    }
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cancel: UIImageView! {
        didSet {
            cancel.isUserInteractionEnabled = true
            cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            cancel.tintColor =  traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
        }
    }
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
    
    private var mode: ImageSelectionPopup.Mode = .Create {
        didSet {
        }
    }
    private weak var callbackDelegate: CallbackObservable?
    private var item: ChoiceItem? {
        didSet {
            guard oldValue != item else { return }
            if !item.isNil {
                buttonsStackView.addArrangedSubview(confirm)
                confirm.alpha = 1
            }
        }
    }
    private var forceEditing = false {
        didSet {
            mode = .Create
        }
    }
    private var isTextFieldEditingEnabled = true
    private var index = 0
    private var observers: [NSKeyValueObservation] = []
    private var offsetY:    CGFloat = 0
    private var kbHeight:   CGFloat!
    private var isMovedUp:  Bool?
}

extension ChoiceEditingPopup: UITextViewDelegate {
    private func setOffset(_ up: Bool) {
        var distance: CGFloat = 0
        distance = (up ? -offsetY : offsetY)
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.y += distance
            if up {
                self.isMovedUp = true
            } else {
                self.isMovedUp = false
            }
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if (isMovedUp == nil) || isMovedUp == false {
                    kbHeight = keyboardSize.height
                    if textViewIsAboveKeyBoard() {
                        self.setOffset(true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isMovedUp != nil {
            if isMovedUp! {
                setOffset(false)
            }
        }
    }
    
    private func textViewIsAboveKeyBoard() -> Bool {
        guard let superview = superview else { return false }
        let tfPoint = CGPoint(x: textView.frame.minX, y: textView!.frame.maxY)// * 1.5)
        let convertedPoint = superview.superview!.superview!.convert(tfPoint, from: textView.superview)
        if convertedPoint.y >= (superview.superview!.superview!.frame.height - kbHeight) {
            offsetY = -(superview.superview!.superview!.frame.height - kbHeight - convertedPoint.y)// - buttonsStackView.bounds.height/2)
            return true
        }
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard isTextFieldEditingEnabled else { return false }

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
                
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= ModelProperties.shared.surveyAnswerTitleMaxLength, !updatedText.isEmpty {
            if !buttonsStackView.arrangedSubviews.contains(confirm) {
                buttonsStackView.addArrangedSubview(confirm)
                confirm.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.2) {
                    self.confirm.transform = .identity
                    self.confirm.alpha = 1
                }
            }
            item?.text = updatedText
            return true
        } else if updatedText.isEmpty {
            UIView.animate(withDuration: 0.2, animations: {
                self.confirm.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.confirm.alpha = 0
            }) { _ in
                self.buttonsStackView.removeArrangedSubview(self.confirm)
            }
            item?.text = updatedText
            return true
        } else {
            
        }
        return false
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let minCharacters = ModelProperties.shared.surveyAnswerTitleMinLength
        
        if textView.text.count < minCharacters {
            showBanner(bannerDelegate: self,
                       text: AppError.minimumCharactersExceeded(minValue: minCharacters).localizedDescription,
                       imageContent: ImageSigns.exclamationMark,
                       shouldDismissAfter: 0.5,
                       accessibilityIdentifier: "isTextFieldEditingEnabled")
            isTextFieldEditingEnabled = false
            return false
        }
        return true
    }
}

extension ChoiceEditingPopup: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            if banner.accessibilityIdentifier == "isTextFieldEditingEnabled" {
                isTextFieldEditingEnabled = true
            }
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }

}
