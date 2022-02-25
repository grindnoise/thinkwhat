//
//  WelcomeView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 24.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import L10n_swift

class WelcomeView: UIView {
    
    // MARK: - IB Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var logo: Icon! {
        didSet {
            logo.iconColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemBlue
                default:
                    return K_COLOR_RED
                }
            }
            logo.scaleMultiplicator = 1.2
            logo.backgroundColor = .clear
            logo.category = .Eye
        }
    }
    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = #keyPath(WelcomeView.welcomeLabel).localized
            welcomeLabel.textColor = .label
        }
    }
    @IBOutlet weak var getStartedButton: UIButton! {
        didSet {
            getStartedButton.backgroundColor = K_COLOR_RED
            getStartedButton.setTitle(#keyPath(WelcomeView.getStartedButton).localized, for: .normal)
        }
    }
    
    // MARK: - IB actions
    @IBAction func getStartedTapped(_ sender: Any) {
        controller?.onGetStartedTap()
    }
   
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib()
                    else { fatalError("View could not load from nib") }
                addSubview(contentView)

        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
        if Self.self is Localizable.Type {
            perform(Selector("subscribe"))
        }
    }
    
    override func layoutSubviews() {
        guard getStartedButton != nil else { return }
        getStartedButton.cornerRadius = getStartedButton.frame.height/2.25
    }

    // MARK: - Properties
    weak var controller: WelcomeViewInput?
    private var initialLanguage = L10n.shared.language
    private var selectedLanguage = L10n.shared.language
    private var blurEffectView: UIVisualEffectView?
    private var toolbarPicker: ToolbarPickerView?
    override var frame: CGRect {
        didSet {
            layoutSubviews()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            layoutSubviews()
        }
    }
}

// MARK: - UI Setup
extension WelcomeView {
    private func setupUI() {
        getStartedButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var logoAnimation: CAAnimation!
        var initialColor: CGColor!
        var destinationColor: CGColor!
        switch traitCollection.userInterfaceStyle {
        case .dark:
            initialColor = UIColor.black.cgColor
            destinationColor = UIColor.systemBlue.cgColor
        default:
            destinationColor = UIColor.black.cgColor
            initialColor = UIColor.systemBlue.cgColor
        }
        logoAnimation = Animations.get(property: .FillColor,
                                       fromValue: initialColor,
                                       toValue: destinationColor,
                                       duration: 0.3,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: nil,
                                       isRemovedOnCompletion: false)
        logo.icon.add(logoAnimation, forKey: nil)
        (logo.icon as! CAShapeLayer).fillColor = K_COLOR_RED.cgColor
    }
    
    private func dismissLanguages() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.blurEffectView?.effect = nil
            self.toolbarPicker?.alpha = 0
        }) { _ in
            self.blurEffectView?.removeFromSuperview()
            self.toolbarPicker?.removeFromSuperview()
            self.controller?.onLanguagesListPresented()
        }
    }
    
    private func presentLanguages() {
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        blurEffectView?.effect = nil
        blurEffectView?.addEquallyTo(to: self)
        
        toolbarPicker = ToolbarPickerView()
        toolbarPicker?.picker.delegate = self
        toolbarPicker?.picker.dataSource = self
        toolbarPicker?.toolbarDelegate = self
        toolbarPicker?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolbarPicker!)
        toolbarPicker?.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        toolbarPicker?.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        toolbarPicker?.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        toolbarPicker?.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.blurEffectView?.effect = UIBlurEffect(style: .prominent)
            self.toolbarPicker?.alpha = 1
        }) { [weak self] _ in
            guard !self.isNil else { return }
            self!.controller?.onLanguagesListPresented()
            guard let currentLanguageIndex: Int = L10n.supportedLanguages.index(of: L10n.shared.language) else { return }
            self!.toolbarPicker?.picker.selectRow(currentLanguageIndex, inComponent: 0, animated: true)
        }
    }
}

extension WelcomeView: WelcomeControllerOutput {
    func onLanguageTapped() {
        presentLanguages()
    }
}

extension WelcomeView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        L10n.supportedLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        return NSAttributedString(string: Locale(identifier: L10n.supportedLanguages[row]).localizedString(forLanguageCode: L10n.supportedLanguages[row])!.capitalized,
                                  attributes: [NSAttributedString.Key.font: UIFont(name: StringAttributes.FontStyle.Regular.rawValue, size: 17.0)!])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLanguage = L10n.supportedLanguages[row]
        Bundle.setLanguageAndPublish(selectedLanguage, in: Bundle(for: Self.self))
        toolbarPicker?.toolbar.items?.forEach { button in
            button.title = (button.style == .done ? "select" : "cancel").localized
            controller?.onLanguageChanged(selectedLanguage)
        }
    }
}

extension WelcomeView: ToolbarPickerViewDelegate {
    func didTapDone() {
        controller?.onLanguageChangeAccepted(selectedLanguage)
        dismissLanguages()
    }
    
    func didTapCancel() {
        Bundle.setLanguageAndPublish(initialLanguage, in: Bundle(for: Self.self))
//        controller?.onLanguageChangeAccepted(initialLanguage)
        controller?.onLanguageChanged(initialLanguage)
        dismissLanguages()
    }
}

extension WelcomeView: Localizable {
    @objc
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(onLanguageChange), name: Notifications.UI.LanguageChanged, object: nil)
    }

    @objc
    func onLanguageChange() {
        getStartedButton.setTitle(#keyPath(WelcomeView.getStartedButton).localized, for: .normal)
        welcomeLabel.text = #keyPath(WelcomeView.welcomeLabel).localized//"welcome".localized
    }
}

class ToolbarPickerView: UIView {

    public private(set) var toolbar: UIToolbar!
    public private(set) var picker: UIPickerView!
    public weak var toolbarDelegate: ToolbarPickerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = true
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .label
        toolBar.backgroundColor = .clear
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.superview?.backgroundColor = .clear
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolBar)
        toolBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let doneButton = UIBarButtonItem(title: NSLocalizedString("select", comment: ""), style: .done, target: self, action: #selector(doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(cancelTapped))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolbar = toolBar
        
        picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isUserInteractionEnabled = true
        addSubview(picker)
        picker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
//        picker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toolBar.items?.forEach { button in
            button.tintColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .systemBlue
                default:
                    return .label
                }
            }
        }
    }
    
    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone()
    }

    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel()
    }
}
