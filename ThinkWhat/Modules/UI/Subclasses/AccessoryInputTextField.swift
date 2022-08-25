//
//  FlexibleTextView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.08.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol AccessoryInputTextFieldDelegate: AnyObject {
    func onSendEvent(_: String)
}

final class AccessoryInputTextField: UITextField {
    
    override var text: String? {
        didSet {
            guard let text = text,
                  text.isEmpty
            else { return }
            
            textView.text = ""
        }
    }
    
    // MARK: - Public properties
    public var placeholderText: String
    public var textViewFont: UIFont
    public var staticText: String = "" {
        didSet {
            textView.staticText = staticText
        }
    }
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private let minLength: Int
    private let maxLength: Int
    private weak var customDelegate: AccessoryInputTextFieldDelegate?
    //UI
    private lazy var accessoryInputView: ZeroSizedIntrisicContentView = {
        let instance = ZeroSizedIntrisicContentView()
        instance.autoresizingMask = .flexibleHeight
        
        instance.addSubview(textView)
        instance.addSubview(sendButton)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
        sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: 0),
            textView.topAnchor.constraint(equalTo: instance.topAnchor,constant: 8),
            textView.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor, constant: -8),
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
            sendButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
//            sendButton.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor, constant: -8),
        ])
        
        return instance
    }()
    private lazy var sendButton: UIButton = {
        let instance = UIButton(type: .system)
        instance.isEnabled = true
        instance.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(font: textViewFont, scale: .large)), for: .normal)
        instance.tintColor = .systemBlue
        instance.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        instance.addTarget(self, action: #selector(self.handleSend), for: .touchUpInside)
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true

        return instance
    }()
    private lazy var textView: FlexibleTextView = {
        let instance = FlexibleTextView(minLength: minLength, maxLength: maxLength)
        instance.placeholder = "add_comment".localized
        instance.accessibilityIdentifier = "textView"
        instance.font = textViewFont
        instance.maxHeight = 80
        instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
        
        observers.append(instance.observe(\FlexibleTextView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        
        return instance
    }()
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    init(placeholder: String = "", font: UIFont, delegate: AccessoryInputTextFieldDelegate, minLength: Int = .zero, maxLength: Int = .max) {
        self.maxLength = maxLength
        self.minLength = minLength
        self.customDelegate = delegate
        self.placeholderText = placeholder
        self.textViewFont = font
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        let instance = UIInputView(frame: .zero, inputViewStyle: .keyboard)
        instance.allowsSelfSizing = true
        inputAccessoryView = instance
        instance.addSubview(accessoryInputView)
        accessoryInputView.translatesAutoresizingMaskIntoConstraints = false
        instance.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            accessoryInputView.leadingAnchor.constraint(equalTo: instance.leadingAnchor),
            accessoryInputView.trailingAnchor.constraint(equalTo: instance.trailingAnchor),
            accessoryInputView.bottomAnchor.constraint(equalTo: instance.bottomAnchor),
            instance.topAnchor.constraint(equalTo: accessoryInputView.topAnchor)
        ])
    }
    
    @objc
    private func handleSend() {
        textView.resignFirstResponder()
        customDelegate?.onSendEvent(textView.text)
    }
    
    // MARK: - Public methods
//    public func forceResignFirstResponder() {
//        textView.resignFirstResponder()
//    }
    
    // MARK: - Overriden methods
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        textView.becomeFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        textView.resignFirstResponder()
        return true
    }
}

class FlexibleTextView: UITextView {
    // limit the height of expansion per intrinsicContentSize
    
    private let minLength: Int
    private let maxLength: Int
    
    fileprivate var staticText: String = "" {
        didSet {
            guard !staticText.isEmpty else {
                text = ""
                placeholderTextView.isHidden = !text.isEmpty
                attributedText = NSAttributedString(string: "test", attributes: [
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.label,
                    NSAttributedString.Key.backgroundColor: UIColor.clear
                    ])
                attributedText = NSAttributedString(string: "", attributes: [
                    NSAttributedString.Key.font: font as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.label,
                    NSAttributedString.Key.backgroundColor: UIColor.clear
                    ])
                return
            }
            text = ""
            placeholderTextView.isHidden = true
            attributedText =  NSAttributedString(string: staticText, attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.backgroundColor: UIColor.systemGray2
            ])
            let attrString = NSMutableAttributedString()
            attrString.append(NSAttributedString(string: staticText, attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Semibold, forTextStyle: .body) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.backgroundColor: UIColor.systemGray2
            ]))
            staticText += " "
            attrString.append(NSAttributedString(string: " ", attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
                NSAttributedString.Key.backgroundColor: UIColor.clear
                ]))
            attributedText = attrString
        }
    }
    var maxHeight: CGFloat = 0.0
    private let placeholderTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.gray
        return tv
    }()
    var placeholder: String? {
        get {
            return placeholderTextView.text
        }
        set {
            placeholderTextView.text = newValue
        }
    }
    
    init(minLength: Int, maxLength: Int) {
        self.minLength = minLength
        self.maxLength = maxLength
        super.init(frame: .zero, textContainer: nil)
        delegate = self
        isScrollEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)
        placeholderTextView.font = font
        placeholderTextView.addEquallyTo(to: self)
    }
    
//    override init(frame: CGRect, textContainer: NSTextContainer?) {
//        super.init(frame: frame, textContainer: textContainer)
//        delegate = self
//        isScrollEnabled = false
//        autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)
//        placeholderTextView.font = font
//        placeholderTextView.addEquallyTo(to: self)
////        addSubview(placeholderTextView)
////
////        NSLayoutConstraint.activate([
////            placeholderTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
////            placeholderTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
////            placeholderTextView.topAnchor.constraint(equalTo: topAnchor),
////            placeholderTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
////        ])
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var text: String! {
        didSet {
            invalidateIntrinsicContentSize()
            placeholderTextView.isHidden = !text.isEmpty
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderTextView.font = font
            invalidateIntrinsicContentSize()
        }
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            placeholderTextView.contentInset = contentInset
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        if size.height == UIView.noIntrinsicMetric {
            // force layout
            layoutManager.glyphRange(for: textContainer)
            size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
        }
        
        if maxHeight > 0.0 && size.height > maxHeight {
            size.height = maxHeight
            
            if !isScrollEnabled {
                isScrollEnabled = true
            }
        } else if isScrollEnabled {
            isScrollEnabled = false
        }
        
        return size
    }
    
    @objc private func textDidChange(_ note: Notification) {
        // needed incase isScrollEnabled is set to true which stops automatically calling invalidateIntrinsicContentSize()
        invalidateIntrinsicContentSize()
        placeholderTextView.isHidden = !text.isEmpty
    }
    
    
}

extension FlexibleTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !staticText.isEmpty else { return true }
        
        let minCharacters = staticText.count

        if range.location < minCharacters { return false }
        
        if text.count + minCharacters < minCharacters {
            return false
        }
        return true
    }
}

class ZeroSizedIntrisicContentView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
