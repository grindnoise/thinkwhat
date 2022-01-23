//
//  MailAuthViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class MailAuthViewController: UIViewController {
    
    @IBOutlet weak var continueButton:      UIButton!
    @IBOutlet weak var loginTF:             UnderlinedSignTextField!
    @IBOutlet weak var pwdTF:               UnderlinedSignTextField!
    @IBOutlet weak var loadingView:         UIView!
    @IBOutlet weak var loadingIndicator:    LoadingIndicator!
    @IBAction func signupTapped(_ sender: UIButton) {
        hideKeyboard()
        if formIsReady {
            isLoadingViewVisible = true
            performSignin()
        } else {
            showAlert(type: .Warning, buttons: [["Хорошо": [CustomAlertView.ButtonType.Ok: {self.isLoadingViewVisible = false}]]], text: "Введите логип/пароль")
        }
    }
    @IBAction func editingChanged(_ sender: UITextField) {
        if sender === pwdTF {
            if pwdTF.text!.count < 6 {
                pwdTF.showSign(state: .PasswordIsShort)
                isPwdFilled = false
            } else {
                isPwdFilled = true
            }
        } else if sender === loginTF {
            if loginTF.text!.isEmpty {
                loginTF.showSign(state: .UsernameNotFilled)
                isLoginFilled = false
            } else {
                isLoginFilled = true
            }
        }
    }
    
    private var isLoadingViewVisible    = false {
        didSet {
            if oldValue != isLoadingViewVisible {
                UIView.animate(withDuration: 0.2, animations: {
                    let alpha: CGFloat = self.isLoadingViewVisible ? 0.9 : 0
                    self.loadingView.alpha = alpha
                }) { completed in
                    if self.isLoadingViewVisible {
                        self.loadingIndicator.addEnableAnimation()
                    } else {
                        self.loadingIndicator.removeAllAnimations()
                    }
                }
            }
        }
    }
    private var textFields              = [UnderlinedTextField]()
    private var formIsReady             = false {
        didSet {
            if formIsReady != oldValue {
                if formIsReady {
                    UIView.animate(withDuration: 0.2) {
                        self.continueButton.backgroundColor = K_COLOR_RED
                    }
                } else {
                    UIView.animate(withDuration: 0.2) {
                        self.continueButton.backgroundColor = K_COLOR_GRAY
                    }
                }
            }
        }
    }
    private var isViewSetupCompleted    = false
    private var isLoginFilled = false {
        didSet {
            if isLoginFilled {
                loginTF.hideSign()
                if isPwdFilled && isLoginFilled {
                    formIsReady = true
                }
            } else {
                formIsReady = false
            }
        }
    }
    private var isPwdFilled = false {
        didSet {
            if isPwdFilled {
                pwdTF.hideSign()
                if isPwdFilled && isLoginFilled {
                    formIsReady = true
                }
            } else {
                formIsReady = false
            }
            
        }
    }
    
//    internal lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
        textFields = [loginTF, pwdTF]
        for tf in textFields {
            tf.delegate = self
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MailAuthViewController.handleSuccessfulLogin), name: Notifications.OAuth.TokenReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MailAuthViewController.handleWrongCredentials), name: Notifications.OAuth.TokenWrongCredentials, object: nil)
//        NotificationCenter.default.addObserver(self,
//                                       selector: #selector(AuthViewController.handleReachabilitySignal),
//                                       name: kNotificationApiNotReachable,
//                                       object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.isViewSetupCompleted = true
            self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
            self.loginTF.rightView!.alpha = 0
        }
        loadingView.alpha = 0
        loadingIndicator.removeAllAnimations()
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
//            self.navigationController?.navigationBar.titleTextAttributes =
//                [NSAttributedString.Key.foregroundColor: UIColor.red]
//            self.navigationController?.title                         = "Авторизация"
            self.title                         = "Авторизация"
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.continueButton.backgroundColor = self.formIsReady ? K_COLOR_RED : K_COLOR_GRAY
        }
    }
    
    private func setupGestures() {
        DispatchQueue.main.async {
            let touch = UITapGestureRecognizer(target:self, action:#selector(MailAuthViewController.hideKeyboard))
            self.view.addGestureRecognizer(touch)
        }
    }

    
    private func performSignin() {
//        apiManager.getEmailVerified() {
//            _isEmailVerified, error in
//            if error != nil {
//                self.simpleAlert(error!.localizedDescription)
//            } else if let isEmailVerified = _isEmailVerified {
//                switch isEmailVerified {
//                case true:
//                    self.apiManager.login(.Username, username: self.loginTF.text!, password: self.pwdTF.text!, token: nil) {
//                        state in
//                        tokenState = state
//                    }
//                case false:
//                    self.performSegue(withIdentifier: kSegueMailValidationFromSignin, sender: nil)
//                }
//            }
//        }
        API.shared.loginViaMail(username: self.loginTF.text ?? "", password: self.pwdTF.text ?? "") { result in
            switch result {
            case .success:
                NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
            case .failure(let error):
                NotificationCenter.default.post(name: Notifications.OAuth.TokenWrongCredentials, object: nil)
                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
            }
        }
    }
    
    @objc fileprivate func handleWrongCredentials() {
        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: {self.isLoadingViewVisible = false}]]], text: "Неверный логип/пароль")
    }
    
    @objc fileprivate func handleSuccessfulLogin() {
            API.shared.getUserData() { resut in
                switch resut {
                case .success(let json):
                    AppData.shared.importUserData(json)
                    if AppData.shared.profile.isEmailVerified! {
                            self.performSegue(withIdentifier: Segues.Auth.ProfileFromAuth, sender: nil)
                    } else {
                        API.shared.getEmailConfirmationCode() { resut in
                            switch resut {
                            case .success(let json):
                                EmailResponse.shared.importJson(json)
                                self.performSegue(withIdentifier: Segues.Auth.MailValidationFromSignin, sender: nil)
                            case .failure(let error):
                                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: {self.isLoadingViewVisible = false}]]], text: error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error):
                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: {self.isLoadingViewVisible = false}]]], text: error.localizedDescription)
                }
            }
            
//            apiManager.getEmailVerified() {
//                _isEmailVerified, error in
//                if error != nil {
//                    print(error!.localizedDescription)
//                    self.simpleAlert(error!.localizedDescription)
//                } else {
//                    if let isEmailVerified = _isEmailVerified {
//                        switch isEmailVerified {
//                        case true:
//                            self.performSegue(withIdentifier: kSegueAppFromMailSignin, sender: nil)
//                        case false:
//                            self.apiManager.getEmailConfirmationCode() {
//                                json, error in
//                                if error != nil {
//                                    self.simpleAlert(error!.localizedDescription)
//                                }
//                                if json != nil {
//                                    EmailResponse.shared.importJson(json!)
//                                    self.performSegue(withIdentifier: kSegueMailValidationFromSignin, sender: nil)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        }
    }
    
//    private func simpleAlert(_ message: String) {
//        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
//        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
//            self.isLoadingViewVisible = false
//        }
//        alertController.addAction(action1)
//        present(alertController, animated: true)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



extension MailAuthViewController: UITextFieldDelegate {
//    private func initializeServerAPI() -> APIManagerProtocol{
//        return (self.navigationController as! AuthNavigationController).apiManager
//    }
    
    private func findFirstResponder() -> UITextField? {
        
        for textField in textFields {
            if textField.isFirstResponder {
                return textField
            }
        }
        return nil
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === loginTF {
            pwdTF.becomeFirstResponder()
        } else {
//            textField.resignFirstResponder()
            signupTapped(continueButton)
        }
        return true
    }
}

//extension MailAuthViewController: ApiReachability {
//    func handleReachabilitySignal() {
//        showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: {self.isLoadingViewVisible = false}]], text: "Сервер недоступен")
//    }
//}
