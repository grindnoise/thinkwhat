//
//  _LoginView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class LoginView: UIView {
    deinit {
        print("LoginView deinit")
    }
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loginTF: UnderlinedSignTextField! {
        didSet {
            setTextFieldColors(textField: loginTF)
        }
    }
    @IBOutlet weak var passwordTF: UnderlinedSignTextField! {
        didSet {
            setTextFieldColors(textField: passwordTF)
        }
    }
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(NSLocalizedString("log_in", comment: ""), for: .normal)
        }
    }
    @IBAction func loginTapped(_ sender: Any) {
        [loginTF, passwordTF].forEach { self.checkTextField(sender: $0!); $0?.resignFirstResponder() }
        guard isCorrect else { viewInput?.onIncorrectFields(); return }
        isUserInteractionEnabled = false
        viewInput?.onLogin(username: loginTF.text!, password: passwordTF.text!)
        loginButton.setTitle("", for: .normal)
        let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                              size: CGSize(width: loginButton.frame.height,
                                                                           height: loginButton.frame.height)))
        indicator.alpha = 0
        indicator.layoutCentered(in: loginButton)
        indicator.startAnimating()
        indicator.color = .white
        UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
    }
    @IBOutlet weak var forgotLabel: UILabel! {
        didSet {
            forgotLabel.text = NSLocalizedString("recover_label", comment: "")
        }
    }
    @IBOutlet weak var recoverButton: UIButton! {
        didSet {
            self.recoverButton.setTitle(NSLocalizedString("recover_button", comment: ""), for: .normal)
        }
    }
    @IBAction func recoverTapped(_ sender: Any) {
        viewInput?.onRecoverTapped()
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
        guard loginButton != nil else { return }
        loginButton.cornerRadius = loginButton.frame.height/2.25
    }
    
    // MARK: - Properties
    weak var viewInput: LoginViewInput?
    private var isCorrect = false
    private var isPwdFilled = false {
        didSet {
            isCorrect = isPwdFilled
        }
    }
    private var isLoginFilled = false {
        didSet {
            isCorrect = isLoginFilled
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
}

// MARK: - Controller Output
extension LoginView: LoginControllerOutput {
    func onError(_ error: Error) {
        isUserInteractionEnabled = true
        guard !loginButton.isNil, let indicator = loginButton.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self)}).first as? UIActivityIndicatorView else { return }
        UIView.animate(withDuration: 0.2) {
            indicator.alpha = 0
        } completion: { _ in
            indicator.removeFromSuperview()
            self.loginButton.setTitle(NSLocalizedString("log_in", comment: ""), for: .normal)
        }
    }
    
    func onSuccess() {
        isUserInteractionEnabled = true
        guard !loginButton.isNil, let indicator = loginButton.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self)}).first as? UIActivityIndicatorView else { return }
        UIView.animate(withDuration: 0.2) {
            indicator.alpha = 0
        } completion: { _ in
            indicator.removeFromSuperview()
            self.loginButton.setTitle(NSLocalizedString("provider_authorization_success", comment: ""), for: .normal)
            Task {
                try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
                await MainActor.run {
                    self.viewInput?.onNextScene()
                }
            }
        }
    }
}

// MARK: - UI Setup
extension LoginView {
    private func setupUI() {
        loginButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        recoverButton.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        let touch = UITapGestureRecognizer(target:self, action:#selector(LoginView.hideKeyboard))
        self.addGestureRecognizer(touch)
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
        var tfWarningColor = K_COLOR_RED
        var destinationColor: UIColor!
        let textFields: [UnderlinedSignTextField] = [passwordTF, loginTF]
        switch traitCollection.userInterfaceStyle {
        case .dark:
            destinationColor = UIColor.systemBlue
            tfWarningColor = .systemYellow
        default:
            destinationColor = K_COLOR_RED
//            tfWarningColor = K_COLOR_RED
        }
        textFields.forEach {
            $0.line.layer.strokeColor = destinationColor.cgColor
            $0.tintColor = destinationColor
            $0.color = tfWarningColor
            $0.keyboardType = .asciiCapable
        }
    }
}

// MARK: - Text fields delegate
extension LoginView: UITextFieldDelegate {
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === loginTF {
            passwordTF.becomeFirstResponder()
        } else if textField === passwordTF {

        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextField(sender: textField)
    }
    
    private func checkTextField(sender: UITextField) {
        guard let textField = sender as? UnderlinedSignTextField else { return }
        if textField === passwordTF {
            if textField.text!.isEmpty {
                isPwdFilled = false
                textField.hideSign()
            } else if textField.text!.count < 6 {
                textField.showSign(state: .PasswordIsShort)
                isPwdFilled = false
            } else {
                textField.hideSign()
                isPwdFilled = true
            }
        } else if textField === loginTF {
            if textField.text!.isEmpty {
                isLoginFilled = false
                textField.hideSign()
            } else if textField.text!.count < 4 {
                textField.showSign(state: .UsernameIsShort)
                isLoginFilled = false
//            } else if textField.text!.contains("@"), !textField.text!.isValidEmail {
//                loginTF.showSign(state: .EmailIsIncorrect)
//                isLoginFilled = false
            } else {
                textField.hideSign()
                isLoginFilled = true
            }
        }
    }
}
