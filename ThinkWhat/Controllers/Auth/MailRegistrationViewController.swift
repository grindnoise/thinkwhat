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

    @IBOutlet weak var continueButton:  UIButton!
    @IBOutlet weak var mailTF:          UnderlinedSignTextField!
    @IBOutlet weak var loginTF:         UnderlinedSignTextField!
    @IBOutlet weak var pwdTF:           UnderlinedSignTextField!
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textField.text!.isEmpty {
            if textField === mailTF {
                if isValidEmail(mailTF.text!) {
                    apiManager.checkUsernameEmailAvailability(email: textField.text!, username: "") {
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
                } else  {
                    mailTF.showSign(state: .EmailIsIncorrect)
                }
            } else if textField === loginTF {
                apiManager.checkUsernameEmailAvailability(email: "", username: textField.text!) {
                    exists, error in
                    if error != nil {
                        self.simpleAlert(error!.localizedDescription)
                    }
                    if exists != nil {
                        if exists! {
                            self.loginTF.showSign(state: .UsernameExists)
                            self.isLoginFilled = false
                        } else {
                            self.isLoginFilled = true
                        }
                    }
                }
            } else {
                if pwdTF.text!.count < 6 {
                    pwdTF.showSign(state: .PasswordIsShort)
                    isPwdFilled = false
                } else {
                    isPwdFilled = true
                }
            }
        }
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        performSignup()
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
    private var apiManager: APIManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [loginTF, pwdTF, mailTF]
        for tf in textFields {
            tf.delegate = self
        }
        apiManager      = (self.navigationController as! AuthNavigationController).apiManagerProtocol as? APIManager
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
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
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
            print("You've pressed default")
        }
        alertController.addAction(action1)
        present(alertController, animated: true)
    }
    
    private func performSignup() {
        if formIsReady {
            apiManager.getEmailConfirmationCode(email: mailTF.text!, username: loginTF.text!) {
                json, error in
                if error != nil {
                    self.simpleAlert(error!.localizedDescription)
                }
                if json != nil {
                    do {
                        emailResponse = EmailResponse(json: json!)
                        AppData.shared.system.emailResponseConfirmationCode = emailResponse?.confirmation_code
                        
                        self.simpleAlert("\(emailResponse!.confirmation_code)")
                    } catch let error {
                        self.simpleAlert(error.localizedDescription)
                    }
                    
                    
//                    if let emailResponse = EmailResponse(json: json!) {
//                    if let dict = json!.dictionaryValue as? [String: Any] {
//                        print(type(of: dict["confirmation_code"]))
//                        AppData.shared.system.emailResponseConfirmationCode = emailResponse
//                        AppData.shared.system.emailResponseExpirationDate   = dict["expires_in"] is NSNull ? Date(dateTimeString: "01.01.0001") : Date(dateTimeString:dict["expires_in"] as! String)
//                        self.simpleAlert("\(emailResponse?.confirmation_code)")
//                    }
                }
            }
//            self.apiManager.signUp(email: mailTF.text!, password: pwdTF.text!, username: loginTF.text!) {
//                succes in
////                tokenState = state
//            }
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
            performSignup()
        }
        return true
    }
}
