//
//  UsernameInputTextField.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

protocol UsernameInputTextFieldDelegate: AnyObject {
    func onSendEvent(_: [String: String])
}

final class UsernameInputTextField: UITextField {
    
    // MARK: - Public properties
    public var textViewFont: UIFont
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    private weak var customDelegate: UsernameInputTextFieldDelegate?
    //UI
    private lazy var accessoryInputView: ZeroSizedIntrisicContentView = {
        let instance = ZeroSizedIntrisicContentView()
        instance.autoresizingMask = .flexibleHeight
        
//        let verticalStack = UIStackView(arrangedSubviews: [firstnameTextView, lastnameTextView])
//        verticalStack.spacing = 4
//        verticalStack.axis = .vertical
////        verticalStack.distribution = .fillEqually
//
//        let horizontalStack = UIStackView(arrangedSubviews: [verticalStack, doneButton])
//        horizontalStack.spacing = 4
//        horizontalStack.axis = .horizontal
//
//        horizontalStack.publisher(for: \.bounds, options: .new).sink { rect in
//            print(rect.size)
//        }.store(in: &subscriptions)
//
//        instance.addSubview(horizontalStack)
//        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//        doneButton.translatesAutoresizingMaskIntoConstraints = false
//        lastnameTextView.translatesAutoresizingMaskIntoConstraints = false
////        verticalStack.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.vertical)
////        verticalStack.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.vertical)
////
//        NSLayoutConstraint.activate([
//            horizontalStack.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
//            horizontalStack.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
//            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor, constant: 8),
////            horizontalStack.heightAnchor.constraint(equalToConstant: firstnameTextView.bounds.height*2 + horizontalStack.spacing),
////            instance.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 8),
////            lastnameTextView.heightAnchor.constraint(equalTo: firstnameTextView.heightAnchor),
//            doneButton.widthAnchor.constraint(equalTo: horizontalStack.widthAnchor, multiplier: 0.1)
//        ])
//
//
//        let constraint = instance.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 8)
////        constraint.priority = .defaultLow
//        constraint.isActive = true
        
        
//        instance.addSubview(horizontalStack)
        instance.addSubview(lastnameTextView)
        instance.addSubview(doneButton)
        instance.addSubview(firstnameTextView)

        firstnameTextView.translatesAutoresizingMaskIntoConstraints = false
        lastnameTextView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
        doneButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)

        NSLayoutConstraint.activate([
            firstnameTextView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
            firstnameTextView.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: 0),
            firstnameTextView.topAnchor.constraint(equalTo: instance.topAnchor,constant: 16),
            lastnameTextView.leadingAnchor.constraint(equalTo: instance.leadingAnchor, constant: 8),
            lastnameTextView.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: 0),
            lastnameTextView.topAnchor.constraint(equalTo: firstnameTextView.bottomAnchor,constant: 8),
            lastnameTextView.bottomAnchor.constraint(equalTo: instance.layoutMarginsGuide.bottomAnchor),//, constant: -8),
            doneButton.leadingAnchor.constraint(equalTo: lastnameTextView.trailingAnchor, constant: 0),
            doneButton.trailingAnchor.constraint(equalTo: instance.trailingAnchor, constant: -8),
            doneButton.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
            doneButton.widthAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 0.1)
        ])
        
        return instance
    }()
    private lazy var doneButton: UIButton = {
        let instance = UIButton(type: .system)
        instance.isEnabled = true
//        instance.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(font: textViewFont, scale: .large)), for: .normal)
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        instance.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        instance.addTarget(self, action: #selector(self.handleSend), for: .touchUpInside)
        instance.heightAnchor.constraint(equalTo: instance.widthAnchor, multiplier: 1/1).isActive = true
        
        instance.publisher(for: \.bounds, options: .new).sink { size in
            print(size)
            instance.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: size.height, weight: .semibold)), for: .normal)
        }.store(in: &subscriptions)

        return instance
    }()
    private lazy var lastnameTextView: FlexibleTextView = {
        let instance = FlexibleTextView(minLength: 0, maxLength: 30)
        instance.textContentType = .name
        instance.autocorrectionType = .no
        instance.spellCheckingType = .no
        instance.placeholder = "lastNameTF".localized
        instance.accessibilityIdentifier = "lastnameTextView"
        if let userprofile = Userprofiles.shared.current {
            instance.text = userprofile.lastName
        }
        instance.font = textViewFont
        instance.maxHeight = 80
        instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
//        instance.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        observers.append(instance.observe(\FlexibleTextView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.width * 0.05
        })
        
        return instance
    }()
    private lazy var firstnameTextView: FlexibleTextView = {
        let instance = FlexibleTextView(minLength: 2, maxLength: 30)
        instance.textContentType = .name
        instance.autocorrectionType = .no
        instance.spellCheckingType = .no
        instance.placeholder = "firstNameTF".localized
        instance.accessibilityIdentifier = "firstnameTextView"
        if let userprofile = Userprofiles.shared.current {
            instance.text = userprofile.firstName
        }
        instance.font = textViewFont
        instance.maxHeight = 80
        instance.contentInset = UIEdgeInsets(top: instance.contentInset.top, left: 8, bottom: instance.contentInset.bottom, right: 8)
//        instance.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        observers.append(instance.observe(\FlexibleTextView.bounds, options: .new) { view, change in
            guard let value = change.newValue else { return }
            view.cornerRadius = value.height/2
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
    
    init(font: UIFont, delegate: UsernameInputTextFieldDelegate) {
        self.customDelegate = delegate
        self.textViewFont = font
        super.init(frame: .zero)
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.textContentType = .name
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
//        autocapitalizationType = .none
//        autocorrectionType = .no
//        spellCheckingType = .no
        
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
        guard firstnameTextView.text.count >= 2 else {
          let banner = NewBanner(contentView: TextBannerContent(image: UIImage(systemName: "exclamationmark.triangle.fill")!,
                                                                text: "minimum_characters_needed".localized + "\(2)",
                                                                tintColor: .systemOrange),
                                 contentPadding: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8),
                                 isModal: false,
                                 useContentViewHeight: true,
                                 shouldDismissAfter: 2)
          banner.didDisappearPublisher
            .sink { _ in banner.removeFromSuperview() }
            .store(in: &self.subscriptions)
            return
        }
        
        let _ = resignFirstResponder()
        customDelegate?.onSendEvent([firstnameTextView.text: lastnameTextView.text])
    }
    
    // MARK: - Public methods
//    public func forceResignFirstResponder() {
//        textView.resignFirstResponder()
//    }
    
    // MARK: - Overriden methods
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
//        if !lastnameTextView.isFirstResponder && !firstnameTextView.isFirstResponder {
            firstnameTextView.becomeFirstResponder()
//        }
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        if lastnameTextView.isFirstResponder {
            lastnameTextView.resignFirstResponder()
        } else if firstnameTextView.isFirstResponder {
            firstnameTextView.resignFirstResponder()
        }
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        doneButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
}

// MARK: - BannerObservable
extension UsernameInputTextField: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}
