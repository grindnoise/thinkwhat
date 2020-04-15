//
//  MailRegistrationViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MailRegistrationViewController: UIViewController {

    @IBOutlet weak var continueButton:      UIButton!
    @IBOutlet weak var mailTF:              UnderlinedSignTextField!
    @IBOutlet weak var loginTF:             UnderlinedSignTextField!
    @IBOutlet weak var pwdTF:               UnderlinedSignTextField!
    @IBOutlet weak var loadingView:         UIView!
    @IBOutlet weak var loadingIndicator:    LoadingIndicator!
    
    @IBAction func signupTapped(_ sender: UIButton) {
        if formIsReady {
            isLoadingViewVisible = true
            performSignup()
        }
    }
    @IBAction func editingChanged(_ sender: UITextField) {
        checkTextField(sender: sender)
    }
//    private var timeElapsed: Double        = 2.0
//    private var timer                   = Timer()
//    private var timerIsRunning          = false
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
    private var isViewSetupCompleted    = false
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
    private var isMailFilled = false {
        didSet {
            if isMailFilled {
                mailTF.showSign(state: .Approved)
                if isPwdFilled && isMailFilled && isLoginFilled {
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
                pwdTF.showSign(state: .Approved)
                if isPwdFilled && isMailFilled && isLoginFilled {
                    formIsReady = true
                }
            } else {
                formIsReady = false
            }

        }
    }
    private var isLoginFilled = false {
        didSet {
            if isLoginFilled {
                loginTF.showSign(state: .Approved)
                if isPwdFilled && isMailFilled && isLoginFilled {
                    formIsReady = true
                }
            } else {
                formIsReady = false
            }
        }
    }
    fileprivate lazy var apiManager: APIManagerProtocol! = initializeServerAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [loginTF, pwdTF, mailTF]
        for tf in textFields {
            tf.delegate = self
        }
        setupViews()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.isViewSetupCompleted = true
            self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
            self.mailTF.rightView!.alpha = 0
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
            self.title                                               = "Регистрация"
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.continueButton.backgroundColor = self.isMailFilled ? K_COLOR_RED : K_COLOR_GRAY
        }
    }
    
    private func setupGestures() {
        DispatchQueue.main.async {
            let touch = UITapGestureRecognizer(target:self, action:#selector(MailRegistrationViewController.hideKeyboard))
            self.view.addGestureRecognizer(touch)
        }
    }
    
    private func simpleAlert(_ message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            self.isLoadingViewVisible = false
        }
        alertController.addAction(action1)
        present(alertController, animated: true)
    }
    
    private func performSignup() {
        self.apiManager.signUp(email: mailTF.text!, password: pwdTF.text!, username: loginTF.text!) {
            error in
            if error != nil {
                self.simpleAlert(error!.localizedDescription)
            } else {
                self.apiManager.getEmailConfirmationCode() {
                    json, error in
                    if error != nil {
                        self.simpleAlert(error!.localizedDescription)
                    }
                    if json != nil {
                        EmailResponse.shared.importJson(json!)
                        self.performSegue(withIdentifier: kSegueMailValidationFromSignup, sender: nil)
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    @objc private func runTimer() {
//        if !timerIsRunning {
//            timer = Timer.scheduledTimer(timeInterval: 2, target: self,   selector: (#selector(MailRegistrationViewController.updateTimer)), userInfo: nil, repeats: false)
//            timerIsRunning = true
//        }
//    }
//
//    @objc private func updateTimer() {
////        timeElapsed    -= 0.1
////        if timeElapsed <= 0.1 {
////            self.timerIsRunning = false
////            timer.invalidate()
////            timeElapsed = 2
//            apiManager.checkUsernameEmailAvailability(email: "", username: loginTF.text!) {
//                exists, error in
//                self.timerIsRunning = false
//                if error != nil {
//                    self.simpleAlert(error!.localizedDescription)
//                }
//                if exists != nil {
//                    if exists! {
//                        self.loginTF.showSign(state: .UsernameExists)
//                        self.isLoginFilled = false
//                    } else {
//                        if self.loginTF.text!.count >= 4 {
//                            self.isLoginFilled = true
//                        }
//                    }
//                }
//                //            }
//        }
//    }
}

extension MailRegistrationViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol{
        return (self.navigationController as! AuthNavigationController).apiManager
    }
}

extension MailRegistrationViewController: UITextFieldDelegate {
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
            mailTF.becomeFirstResponder()
        } else if textField === mailTF {
            pwdTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if formIsReady {
                performSignup()
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextField(sender: textField)
//        if !textField.text!.isEmpty {
//            if textField === mailTF {
//                if isValidEmail(mailTF.text!) {
//                    apiManager.checkUsernameEmailAvailability(email: textField.text!, username: "") {
//                        exists, error in
//                        if error != nil {
//                            self.simpleAlert(error!.localizedDescription)
//                        }
//                        if exists != nil {
//                            if exists! {
//                                self.mailTF.showSign(state: .EmailExists)
//                                self.isMailFilled = false
//                            } else {
//                                self.isMailFilled = true
//                            }
//                        }
//                    }
//                } else  {
//                    mailTF.showSign(state: .EmailIsIncorrect)
//                }
//            } else if textField === loginTF {
//                apiManager.checkUsernameEmailAvailability(email: "", username: textField.text!) {
//                    exists, error in
//                    if error != nil {
//                        self.simpleAlert(error!.localizedDescription)
//                    }
//                    if exists != nil {
//                        if exists! {
//                            self.loginTF.showSign(state: .UsernameExists)
//                            self.isLoginFilled = false
//                        } else {
//                            self.isLoginFilled = true
//                        }
//                    }
//                }
//            }
//        }
    }
    
    private func checkTextField(sender: UITextField) {
        if sender === pwdTF {
            if pwdTF.text!.isEmpty {
                isPwdFilled = false
                pwdTF.hideSign()
            } else if pwdTF.text!.count < 6 {
                pwdTF.showSign(state: .PasswordIsShort)
                isPwdFilled = false
            } else {
                isPwdFilled = true
            }
        } else if sender === loginTF {
            if !sender.text!.isEmpty && sender.text!.count < 4 {
                loginTF.showSign(state: .UsernameIsShort)
                isLoginFilled = false
            } else if sender.text!.count >= 4 {
                //                    runTimer()
                apiManager.isUsernameEmailAvailable(email: "", username: sender.text!) {
                    exists, error in
                    if error != nil {
                        self.simpleAlert(error!.localizedDescription)
                    }
                    if exists != nil {
                        if exists! {
                            self.loginTF.showSign(state: .UsernameExists)
                            self.isLoginFilled = false
                        } else {
                            if self.loginTF.text!.count >= 4 {
                                self.isLoginFilled = true
                            }
                        }
                    }
                }
            } else {
                isLoginFilled = true
                loginTF.hideSign()
            }
        } else if sender === mailTF {
            if sender.text!.isEmpty {
                mailTF.hideSign()
                isMailFilled = false
            } else if isValidEmail(sender.text!) {
                apiManager.isUsernameEmailAvailable(email: sender.text!, username: "") {
                    exists, error in
                    if error != nil {
                        self.simpleAlert(error!.localizedDescription)
                    }
                    if exists != nil {
                        if exists! {
                            self.mailTF.showSign(state: .EmailExists)
                            self.isMailFilled = false
                        } else {
                            self.isMailFilled = true
                        }
                    }
                }
            } else {
                isMailFilled = false
                mailTF.showSign(state: .EmailIsIncorrect)
            }
        }
    }
}
