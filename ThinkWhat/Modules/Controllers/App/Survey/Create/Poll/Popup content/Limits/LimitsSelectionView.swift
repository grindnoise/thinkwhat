//
//  LimitsSelection.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.06.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class LimitsSelectionView: UIView {
    
    // MARK: - Initialization
    init(value: Int, callbackDelegate: CallbackObservable) {
        super.init(frame: .zero)
        self.callbackDelegate = callbackDelegate
        self.value = value
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
    }
    
    private func setupUI() {
        setText()
    }
    
    private func setObservers() {
        observers.append(textField.observe(\UITextField.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.textField.cornerRadius = self.textField.frame.height / 2
            self.textField.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Bold,
                                                           size: self.textField.frame.height * 0.6)
//            let placeholder = NSMutableAttributedString()
//            placeholder.append(NSAttributedString(string: "voters_limit_description".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: self.textField.frame.height * 0.2), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
//            self.textField.attributedPlaceholder = placeholder
        })
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func setText() {
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: "voters_limit".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: title.bounds.height * 0.4), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        title.attributedText = titleString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        textField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        textField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            guard let v = recognizer.view else { return }
            if v == confirm {
                callbackDelegate?.callbackReceived(Int(textField.text!) as Any)
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
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var confirm: UIImageView! {
        didSet {
            confirm.isUserInteractionEnabled = true
            confirm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
            confirm.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        }
    }
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.text = "\(value)"
            textField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            textField.delegate = self
            textField.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .label
//            textField.placeholder = "voters_limit_description".localized
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Properties
    private var value = 0
    private weak var callbackDelegate: CallbackObservable?
    private var observers: [NSKeyValueObservation] = []
    private var isTextFieldEditingEnabled = true
}

extension LimitsSelectionView: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        guard !text.isEmpty else {
            showBanner(bannerDelegate: self,
                       text: AppError.invalidURL.localizedDescription,
                       imageContent: ImageSigns.exclamationMark,
                       shouldDismissAfter: 0.5,
                       accessibilityIdentifier: "isTextFieldEditingEnabled")
            isTextFieldEditingEnabled = false
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTextFieldEditingEnabled else { return false }
        return true
    }
}

extension LimitsSelectionView: BannerObservable {
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
