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
    
    // MARK: - IB outlets
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
            signupButton.setTitle(#keyPath(SignupView.signupButton).localized, for: .normal)
        }
    }
    @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var signupButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameTF: UnderlinedSignTextField! {
        didSet {
            usernameTF.placeholder = #keyPath(SignupView.usernameTF).localized
            setupTextField(textField: usernameTF)
        }
    }
    @IBOutlet weak var mailTF: UnderlinedSignTextField! {
        didSet {
            mailTF.placeholder = #keyPath(SignupView.mailTF).localized
            setupTextField(textField: mailTF)
        }
    }
    @IBOutlet weak var passwordTF: UnderlinedSignTextField! {
        didSet {
            passwordTF.placeholder = #keyPath(SignupView.passwordTF).localized
            setupTextField(textField: passwordTF)
        }
    }
    @IBOutlet weak var providerLabel: UILabel! {
        didSet {
            providerLabel.text = #keyPath(SignupView.providerLabel).localized.uppercased()
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
    @IBOutlet weak var google: GoogleLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(SignupView.onGoogleTap))
            google.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var haveAccountLabel: UILabel! {
        didSet {
            haveAccountLabel.text = #keyPath(SignupView.haveAccountLabel).localized
        }
    }
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.setTitle(#keyPath(SignupView.loginButton).localized, for: .normal)
        }
    }
    @IBOutlet weak var loginButonTopConstraint: NSLayoutConstraint!
    
    // MARK: - IB actions
    @IBAction func signupTapped(_ sender: Any) {
        textFieldsStackView.arrangedSubviews.filter { $0.isKind(of: UnderlinedSignTextField.self)}.forEach { ($0 as! UnderlinedSignTextField).resignFirstResponder() }
        guard isCorrect, !isPerformingChecks, let username = usernameTF.text, let email = mailTF.text, let password = passwordTF.text else {
            fatalError()
//            showAlert(type: .Warning, buttons: [[NSLocalizedString("ok", comment: ""): [CustomAlertView.ButtonType.Ok: nil]]], text: NSLocalizedString("check_fields", comment: ""))
//            return
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
//        viewInput?.onCaptchaValidation { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
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
                            delayAsync(delay: 0.5) {
                                self.viewInput?.onSignupSuccess()
                            }
                        case .failure(let error):
//                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                            fatalError()
                        }
                    }
                }
//            case .failure(let error):
//                self.isUserInteractionEnabled = true
//                UIView.animate(withDuration: 0.2,
//                               delay: 0,
//                               options: [.curveEaseInOut]) {
//                    indicator.alpha = 0
//                } completion: { _ in
//                    indicator.stopAnimating()
//                    indicator.removeFromSuperview()
//                    self.signupButton.setTitle(#keyPath(SignupView.signupButton).localized, for: .normal)
//                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
//                }
//            }
//        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewInput?.onLogin()
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
    private var isAnimationStopped = false
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
    private var blurEffectView: UIVisualEffectView?
    private var providerProgressIndicator: UIView? {
        didSet {
            providerProgressIndicator?.isOpaque = false
        }
    }
    private var progressLabel: UIStackView?
    private var bounceAnim: CABasicAnimation?
    
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
extension SignupView: SignupControllerOutput {
    func onDidDisappear() {
//        removeBlur()
    }
}

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
        
        guard let countryCode = UserDefaults.App.countryByIP else { return }
        if countryCode == "RU" {
            facebook.removeFromSuperview()
        }
    }
    
    private func setupTextField(textField: UnderlinedSignTextField) {
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
        textField.lineWidth = 1.5
        textField.activeLineWidth = 1.5
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
    
    private func bounce() {
        if bounceAnim == nil {
            bounceAnim = CABasicAnimation(keyPath: "transform.scale")
            bounceAnim?.fromValue = 1
            bounceAnim?.toValue = CATransform3DMakeScale(1.05, 1.05, 1)
            bounceAnim?.duration = 0.75
            bounceAnim?.isRemovedOnCompletion = true
            bounceAnim?.autoreverses = true
            bounceAnim?.delegate = self
        }
        if bounceAnim != nil {
            providerProgressIndicator!.layer.add(bounceAnim!, forKey: nil)
        }
    }
    
    private func removeBlur() {
        providerProgressIndicator?.layer.removeAllAnimations()
        providerProgressIndicator?.removeFromSuperview()
        progressLabel?.removeFromSuperview()
        blurEffectView?.removeFromSuperview()
    }
    
    private func blur(provider: AuthProvider) {
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        blurEffectView?.effect = nil
        blurEffectView?.addEquallyTo(to: self)
        switch provider {
        case .VK:
            providerProgressIndicator = VKLogo(frame: CGRect(origin: vk.superview!.convert(vk.frame.origin, to: self),
                                                             size: vk.frame.size))
            addSubview(providerProgressIndicator!)
            vk.alpha = 0
        case .Facebook:
            providerProgressIndicator = FacebookLogo(frame: CGRect(origin: facebook.superview!.convert(facebook.frame.origin, to: self),
                                                             size: facebook.frame.size))
            addSubview(providerProgressIndicator!)
            facebook.alpha = 0
        default:
            providerProgressIndicator = GoogleLogo(frame: CGRect(origin: google.superview!.convert(google.frame.origin, to: self),
                                                             size: google.frame.size))
            addSubview(providerProgressIndicator!)
            google.alpha = 0
        }
        let destinationSize = CGSize(width: 0.4 * frame.width,
                                     height: 0.4 * frame.width)
        let destinationOrigin = CGPoint(x: bounds.midX - destinationSize.width/2,
                                        y: bounds.midY - destinationSize.width/2)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.blurEffectView?.effect = UIBlurEffect(style: .prominent)
            self.providerProgressIndicator?.frame.size   = destinationSize
            self.providerProgressIndicator?.frame.origin = destinationOrigin
        }) { _ in
            self.bounce()
            self.progressLabel = UIStackView()
//            self.progressLabel?.alignment = .center
            self.progressLabel?.axis = .vertical
            self.progressLabel?.spacing = 8
            self.addSubview(self.progressLabel!)
            let spinner = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                size: CGSize(width: 30, height: 30)))
            spinner.color = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            }
            spinner.startAnimating()
            let label = UILabel()
            label.font = UIFont(name: StringAttributes.Fonts.Style.Regular, size: 17)
            label.minimumScaleFactor = 0.1
            label.text = NSLocalizedString("provider_authorization_progress", comment: "")
            label.textAlignment = .center
            label.textColor = .label
            self.progressLabel?.addArrangedSubview(label)
            self.progressLabel?.addArrangedSubview(spinner)
            self.progressLabel?.frame.size = CGSize(width: self.providerProgressIndicator!.bounds.width, height: 50)
            self.progressLabel?.frame.origin = CGPoint(x: self.bounds.midX - self.progressLabel!.bounds.width/2,
                                                       y: self.providerProgressIndicator!.frame.maxY)
            DispatchQueue.main.async {
                self.authorize(provider: provider)
            }
        }
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
    //2334
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
                        showBanner(bannerDelegate: self, text: "", content: PlainBannerContent(text: error.localizedDescription.localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, dismissAfter: 1)
                        
//                        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
//                        banner.present(content: PlainBannerContent(text: error.localizedDescription.localized, imageContent: ImageSigns.exclamationMark, color: .systemRed), isModal: false, dismissAfter: 10.5)
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
                        fatalError()
//                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
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
        blur(provider: .Facebook)
//        authorize(provider: .Facebook)
    }
    
    @objc
    private func onVKTap() {
        blur(provider: .VK)
//        authorize(provider: .VK)
    }
    
    @objc
    private func onGoogleTap() {
        blur(provider: .Google)
//        authorize(provider: .Google)
    }
    
    private func authorize(provider: AuthProvider) {
        @Sendable @MainActor func onExit() {
            var destinationSize: CGSize!
            var destinationOrigin: CGPoint!
            var destinationLogo: UIView!
            switch provider {
            case .VK:
                destinationSize     = vk.bounds.size
                destinationOrigin   = vk.superview!.convert(vk.frame.origin, to: self)
                destinationLogo     = vk
            case .Facebook:
                destinationSize     = facebook.bounds.size
                destinationOrigin   = facebook.superview!.convert(facebook.frame.origin, to: self)
                destinationLogo     = facebook
            case .Google:
                destinationSize     = google.bounds.size
                destinationOrigin   = google.superview!.convert(google.frame.origin, to: self)
                destinationLogo     = google
            default:
                fatalError("Not implemented")
            }
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 1, options: [.curveEaseInOut], animations: {
                self.progressLabel?.alpha = 0
            }) { _ in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.blurEffectView?.effect = nil
                    self.providerProgressIndicator?.frame.size   = destinationSize
                    self.providerProgressIndicator?.frame.origin = destinationOrigin
                }) { _ in
                    destinationLogo.alpha = 1
                    self.removeBlur()
                }
            }
        }
        
        isUserInteractionEnabled = false
        Task {
            do {
                try await viewInput?.onProviderAuth(provider: provider, timeout: 6)
                isAnimationStopped = true
                isUserInteractionEnabled = true
                guard let label = progressLabel?.subviews.filter({ $0.isKind(of: UILabel.self) }).first as? UILabel,
                      let spinner = progressLabel?.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self) }).first as? UIActivityIndicatorView else { return }
                UIView.transition(with: label, duration: 0.2, options: [.transitionCrossDissolve]) {
                    label.text = "provider_authorization_success".localized
                    spinner.alpha = 0
                } completion: { [weak self] _ in
                    guard `self` == self else { return }
                    sleep(1)
                    self!.viewInput?.onSignupSuccess()
                    onExit()
                }
            } catch let error {
                isUserInteractionEnabled = true
                isAnimationStopped = true
                guard let label = progressLabel?.subviews.filter({ $0.isKind(of: UILabel.self) }).first as? UILabel,
                      let spinner = progressLabel?.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self) }).first as? UIActivityIndicatorView else { return }
                UIView.transition(with: label, duration: 0.2, options: [.transitionCrossDissolve]) {
                    label.text = "provider_authorization_failure".localized
                    spinner.alpha = 0
                } completion: { _ in onExit() }
#if DEBUG
                print(error.localizedDescription)
#endif
            }
        }
    }
}

extension SignupView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard !isAnimationStopped else { return }
        providerProgressIndicator?.layer.removeAllAnimations()
        bounce()
    }
}

extension SignupView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        guard let banner = sender as? Banner else { return }
        banner.removeFromSuperview()
    }
}
