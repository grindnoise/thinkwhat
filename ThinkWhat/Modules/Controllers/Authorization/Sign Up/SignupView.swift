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
        if isCorrect {
            viewInput?.onSignupTap()
        } else {
            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "Проверьте корректность заполненных полей")
        }
    }
    @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signupButtonBottomConstraint: NSLayoutConstraint!
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
    @IBOutlet weak var facebook: FacebookLogo!
    @IBOutlet weak var vk: VKLogo!
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
        viewInput?.onLoginTap()
    }
    @IBOutlet weak var loginButonTopConstraint: NSLayoutConstraint!
    
    private var isCorrect = false {
        didSet {
            if isCorrect != oldValue {
                if isCorrect {
                    UIView.animate(withDuration: 0.2) {
                        self.signupButton.backgroundColor = K_COLOR_RED
                    }
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.signupButton.backgroundColor = K_COLOR_GRAY
                    }
                }
            }
        }
    }
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
        signupButtonBottomConstraint.constant = signupButton.frame.height/2
//        providerStackViewBottomConstraint.constant = haveAccountLabel.frame.height
//        providerStackViewTopConstraint.constant = providerLabel.frame.height
    }
    
    // MARK: - Properties
    weak var viewInput: SignupViewInput?
}

// MARK: - Controller Output
extension SignupView: SignupControllerOutput {
    func onSignupFailure(error: Error) {
        
    }
    
    func onSignupSuccess() {
        
    }
}

// MARK: - UI Setup
extension SignupView {
    private func setupUI() {
        signupButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                if self.isCorrect {
                    return UIColor.systemBlue
                }
                return K_COLOR_GRAY
            default:
                if self.isCorrect {
                    return K_COLOR_RED
                }
                return K_COLOR_GRAY
            }
        }
        loginButton.tintColor = signupButton.backgroundColor
        let touch = UITapGestureRecognizer(target:self, action:#selector(SignupView.hideKeyboard))
        self.addGestureRecognizer(touch)
    }
    
    private func setTextFieldColors(textField: UnderlinedSignTextField) {
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
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var logoAnimation: CAAnimation!
        var initialColor: UIColor!
        var destinationColor: UIColor!
        let textFields: [UnderlinedTextField] = textFieldsStackView.arrangedSubviews.compactMap{ view in
            guard let tf = view as? UnderlinedSignTextField else { return nil }
            return tf
        }
        switch traitCollection.userInterfaceStyle {
        case .dark:
            initialColor = UIColor.black
            destinationColor = UIColor.systemBlue
        default:
            initialColor = UIColor.systemBlue
            destinationColor = K_COLOR_RED
        }
        textFields.forEach {
            $0.line.layer.strokeColor = destinationColor.cgColor
            $0.tintColor = destinationColor
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
                viewInput?.onSignupTap()
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextField(sender: textField)
    }
    
    private func checkTextField(sender: UITextField) {
        if sender === passwordTF {
            if passwordTF.text!.isEmpty {
                isPwdFilled = false
                passwordTF.hideSign()
            } else if passwordTF.text!.count < 6 {
                passwordTF.showSign(state: .PasswordIsShort)
                isPwdFilled = false
            } else {
                isPwdFilled = true
            }
        } else if sender === usernameTF {
            if !sender.text!.isEmpty && sender.text!.count < 4 {
                usernameTF.showSign(state: .UsernameIsShort)
                isLoginFilled = false
            } else if sender.text!.count >= 4 {
                //                    runTimer()
                API.shared.isUsernameEmailAvailable(email: "", username: sender.text!) { result in
                    switch result {
                    case .success(let exists):
                        if !exists {
                            if self.usernameTF.text!.count >= 4 {
                                self.isLoginFilled = true
                            }
                            self.isLoginFilled = true
                        } else {
                            self.usernameTF.showSign(state: .UsernameExists)
                            self.isLoginFilled = false
                        }
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                }
            } else {
                isLoginFilled = true
                usernameTF.hideSign()
            }
        } else if sender === mailTF {
            if sender.text!.isEmpty {
                mailTF.hideSign()
                isMailFilled = false
            } else if sender.text!.isValidEmail {
                API.shared.isUsernameEmailAvailable(email: sender.text!, username: "") { result in
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
                }
            } else {
                isMailFilled = false
                mailTF.showSign(state: .EmailIsIncorrect)
            }
        }
    }
}

