//
//  MailAuthViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class MailAuthViewController: UIViewController {
    
    @IBOutlet weak var continueButton:  UIButton!
    @IBOutlet weak var loginTF:         UnderlinedSignTextField!
    @IBOutlet weak var pwdTF:           UnderlinedSignTextField!
    @IBAction func signupTapped(_ sender: UIButton) {
        if formIsReady {
            performSignin()
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
    
    internal lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
        textFields = [loginTF, pwdTF]
        for tf in textFields {
            tf.delegate = self
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MailAuthViewController.handleTokenState), name: kNotificationTokenReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MailAuthViewController.handleTokenState), name: kNotificationTokenWrongCredentials, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.isViewSetupCompleted = true
            self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
            self.loginTF.rightView!.alpha = 0
        }
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
        self.apiManager.login(.Username, username: self.loginTF.text!, password: self.pwdTF.text!, token: nil) {
            state in
            tokenState = state
        }
    }
    
    @objc fileprivate func handleTokenState() {
        if tokenState == .WrongCredentials {
            delay(seconds: 1) {
                self.simpleAlert("Wrong credentials")
            }
//            simpleAlert("Wrong credentials")
        } else {
            apiManager.getEmailVerified() {
                _isEmailVerified, error in
                if error != nil {
                    print(error!.localizedDescription)
                    self.simpleAlert("dfd")//error!.localizedDescription)
                } else {
                    if let isEmailVerified = _isEmailVerified {
                        switch isEmailVerified {
                        case true:
                            self.performSegue(withIdentifier: kSegueAppFromMailSignin, sender: nil)
                        case false:
                            self.performSegue(withIdentifier: kSegueMailValidationFromSignin, sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func simpleAlert(_ message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("You've pressed default")
        }
        alertController.addAction(action1)
        present(alertController, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MailAuthViewController: UITextFieldDelegate {
    private func initializeServerAPI() -> APIManagerProtocol{
        return (self.navigationController as! AuthNavigationController).apiManagerProtocol
    }
    
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
            textField.resignFirstResponder()
            performSignin()
        }
        return true
    }
}
