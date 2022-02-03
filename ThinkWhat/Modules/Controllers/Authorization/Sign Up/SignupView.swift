//
//  SignupView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SignupView: UIView {
    
    deinit {
        print("SignupView deinit")
    }
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
            logo.scaleMultiplicator = 1
            logo.backgroundColor = .clear
            logo.category = .Eye
        }
    }
    @IBOutlet weak var textFieldsStackView: UIStackView!
    @IBOutlet weak var signupButton: UIButton! {
        didSet {
            signupButton.setTitle(NSLocalizedString("sign_up", comment: ""), for: .normal)
        }
    }
    @IBAction func signupTapped(_ sender: Any) {
        guard isCorrect, !isPerformingChecks, let username = usernameTF.text, let email = mailTF.text, let password = passwordTF.text else {
            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "Проверьте корректность заполненных полей")
            return
        }
        signupButton.setTitle("", for: .normal)
        let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                              size: CGSize(width: signupButton.frame.height,
                                                                           height: signupButton.frame.height)))
        indicator.alpha = 0
        indicator.layoutCentered(in: signupButton)
        indicator.startAnimating()
        indicator.color = .white
        UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        isUserInteractionEnabled = false
        viewInput?.onCaptchaValidation { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.viewInput?.onSignup(username: username, email: email, password: password) { [weak self] result in
                    guard let self = self else { return }
                    self.isUserInteractionEnabled = false
                    UIView.animate(withDuration: 0.2,
                                   delay: 0,
                                   options: [.curveEaseInOut]) {
                        indicator.alpha = 0
                    } completion: { _ in
                        indicator.stopAnimating()
                        indicator.removeFromSuperview()
                        self.isUserInteractionEnabled = true
                        switch result  {
                        case .success:
                            self.signupButton.setTitle(NSLocalizedString("success", comment: ""), for: .normal)
                        case .failure(let error):
                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                self.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: [.curveEaseInOut]) {
                    indicator.alpha = 0
                } completion: { _ in
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    self.signupButton.setTitle(NSLocalizedString("sign_up", comment: ""), for: .normal)
                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                }
            }
        }
    }
    @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var signupButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameTF: UnderlinedSignTextField! {
        didSet {
            setTextFieldColors(textField: usernameTF)
        }
    }
    @IBOutlet weak var mailTF: UnderlinedSignTextField! {
        didSet {
            setTextFieldColors(textField: mailTF)
        }
    }
    @IBOutlet weak var passwordTF: UnderlinedSignTextField! {
        didSet {
            setTextFieldColors(textField: passwordTF)
        }
    }
    @IBOutlet weak var providerLabel: UILabel! {
        didSet {
            providerLabel.text = NSLocalizedString("continue_with_provider", comment: "").uppercased()
        }
    }
    @IBOutlet weak var providerStackView: UIStackView!
    @IBOutlet weak var providerStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var providerStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebook: FacebookLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(SignupView.onFacebookTap))
            facebook.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var vk: VKLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(SignupView.onVKTap))
            vk.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var haveAccountLabel: UILabel! {
        didSet {
            haveAccountLabel.text = NSLocalizedString("already_registered", comment: "")
        }
    }
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        }
    }
    @IBAction func loginTapped(_ sender: Any) {
        authorize(provider: .Mail)
    }
    @IBOutlet weak var loginButonTopConstraint: NSLayoutConstraint!
    
    private var isPerformingChecks = false {
        didSet {
            
        }
    }
    private var isCorrect = false
    private var isMailFilled = false {
        didSet {
            if isMailFilled {
                mailTF.showSign(state: .Approved)
                if isPwdFilled && isMailFilled && isLoginFilled {
                    isCorrect = true
                }
            } else {
                isCorrect = false
            }
        }
    }
    private var isPwdFilled = false {
        didSet {
            if isPwdFilled {
                passwordTF.showSign(state: .Approved)
                if isPwdFilled && isMailFilled && isLoginFilled {
                    isCorrect = true
                }
            } else {
                isCorrect = false
            }

        }
    }
    private var isLoginFilled = false {
        didSet {
            if isLoginFilled {
                usernameTF.showSign(state: .Approved)
                if isPwdFilled && isMailFilled && isLoginFilled {
                    isCorrect = true
                }
            } else {
                isCorrect = false
            }
        }
    }
    
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
    }
    
    override func layoutSubviews() {
        guard signupButton != nil else { return }
        signupButton.cornerRadius = signupButton.frame.height/2.25
        signupButtonTopConstraint.constant = signupButton.frame.height/2
//        signupButtonBottomConstraint.constant = signupButton.frame.height/2
//        providerStackViewBottomConstraint.constant = haveAccountLabel.frame.height
//        providerStackViewTopConstraint.constant = providerLabel.frame.height
    }
    
    // MARK: - Properties
    weak var viewInput: SignupViewInput?
}

// MARK: - Controller Output
extension SignupView: SignupControllerOutput {}

// MARK: - UI Setup
extension SignupView {
    private func setupUI() {
        signupButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        
        loginButton.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        let touch = UITapGestureRecognizer(target:self, action:#selector(SignupView.hideKeyboard))
        self.addGestureRecognizer(touch)
//        usernameTF.isShowingSpinner = true
    }
    
    private func setTextFieldColors(textField: UnderlinedSignTextField) {
        let tfWarningColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemYellow
            default:
                return K_COLOR_RED
            }
        }
        let color: UIColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        textField.delegate = self
        textField.tintColor = color
        textField.line.layer.strokeColor = color.cgColor
        textField.color = tfWarningColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var logoAnimation: CAAnimation!
        var initialColor: UIColor!
        var destinationColor: UIColor!
        var tfWarningColor = K_COLOR_RED
        let textFields: [UnderlinedSignTextField] = textFieldsStackView.arrangedSubviews.compactMap{ view in
            guard let tf = view as? UnderlinedSignTextField else { return nil }
            return tf
        }
        switch traitCollection.userInterfaceStyle {
        case .dark:
            initialColor = UIColor.black
            destinationColor = UIColor.systemBlue
            tfWarningColor = .systemYellow
        default:
            initialColor = UIColor.systemBlue
            destinationColor = K_COLOR_RED
//            tfWarningColor = K_COLOR_RED
        }
        textFields.forEach {
            $0.line.layer.strokeColor = destinationColor.cgColor
            $0.tintColor = destinationColor
            $0.color = tfWarningColor
            $0.keyboardType = .asciiCapable
        }
        logoAnimation = Animations.get(property: .FillColor,
                                       fromValue: initialColor.cgColor,
                                       toValue: destinationColor.cgColor,
                                       duration: 0.3,
                                       timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                       delegate: nil,
                                       isRemovedOnCompletion: false)
        logo.icon.add(logoAnimation, forKey: nil)
        (logo.icon as! CAShapeLayer).fillColor = destinationColor.cgColor
    }
}

// MARK: - Text fields handling
extension SignupView: UITextFieldDelegate {
//    private func findFirstResponder() -> UITextField? {
//        return textFieldsStackView.arrangedSubviews.filter{ view in
//            guard let tf = view as? UnderlinedSignTextField else { return false }
//            guard tf.isFirstResponder else { return false }
//            return true
//        }.first as? UITextField
//    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTF {
            mailTF.becomeFirstResponder()
        } else if textField === mailTF {
            passwordTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if isCorrect {
//                viewInput?.onSignupTap()
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextField(sender: textField)
    }
    
    private func checkTextField(sender: UITextField) {
        guard let textField = sender as? UnderlinedSignTextField else { return }
        if textField === passwordTF {
            if passwordTF.text!.isEmpty {
                isPwdFilled = false
                passwordTF.hideSign()
            } else if passwordTF.text!.count < 6 {
                passwordTF.showSign(state: .PasswordIsShort)
                isPwdFilled = false
            } else {
                isPwdFilled = true
            }
        } else if textField === usernameTF {
            if !textField.text!.isEmpty && textField.text!.count < 4 {
                usernameTF.showSign(state: .UsernameIsShort)
                isLoginFilled = false
            } else if textField.text!.count >= 4 {
                isPerformingChecks = true
                textField.isShowingSpinner = true
                viewInput?.checkCredentials(username: textField.text!, email: "") { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let exists):
                        if !exists {
                            if self.usernameTF.text!.count >= 4 {
                                self.isLoginFilled = true
                            }
                        } else {
                            self.usernameTF.showSign(state: .UsernameExists)
                            self.isLoginFilled = false
                        }
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                    self.isPerformingChecks = false
                    textField.isShowingSpinner = false
                }
            } else if textField.text!.isEmpty {
                usernameTF.hideSign()
            } else {
                isLoginFilled = true
                usernameTF.hideSign()
            }
        } else if textField === mailTF {
            if textField.text!.isEmpty {
                mailTF.hideSign()
                isMailFilled = false
            } else if textField.text!.isValidEmail {
                isPerformingChecks = true
                textField.isShowingSpinner = true
                viewInput?.checkCredentials(username: "", email: textField.text!) {  [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let exists):
                        if !exists {
                            self.isMailFilled = true
                        } else {
                            self.mailTF.showSign(state: .EmailExists)
                            self.isMailFilled = false
                        }
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                    self.isPerformingChecks = false
                    textField.isShowingSpinner = false
                }
            } else {
                isMailFilled = false
                mailTF.showSign(state: .EmailIsIncorrect)
            }
        }
    }
    
    @objc
    private func onFacebookTap() {
        authorize(provider: .VK)
    }
    
    @objc
    private func onVKTap() {
        authorize(provider: .VK)
    }
    
    private func authorize(provider: AuthProvider) {
        isUserInteractionEnabled = false
        Task {
            do {
                try await viewInput?.onProviderAuth(provider: provider)
                isUserInteractionEnabled = true
            } catch let error {
                isUserInteractionEnabled = true
#if DEBUG
                fatalError(error.localizedDescription)
#endif
            }
        }
    }
}

