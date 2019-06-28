//
//  MailRegistrationViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class MailRegistrationViewController: UIViewController {

    @IBOutlet weak var continueButton:  UIButton!
    @IBOutlet weak var mailTF:          UnderlinedSignTextField!
    @IBOutlet weak var loginTF:         UnderlinedTextField!
    @IBOutlet weak var pwdTF:           UnderlinedTextField!
    
    @IBAction func textFieldChanged(_ sender: Any) {
        isMailFilled = isValidEmail(mailTF.text!) ? true : false
    }
    @IBAction func signupTapped(_ sender: UIButton) {
        
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
    private var isMailFilled            = false {
        didSet {
            if isMailFilled {
                UIView.animate(withDuration: 0.2) {
                    self.mailTF.rightView!.alpha = 1
                }
                if isPwdFilled && isMailFilled && isLoginFilled {
                    formIsReady = true
                }
            }else {
                UIView.animate(withDuration: 0.2) {
                    self.mailTF.rightView!.alpha = 0
                }
            }
        }
    }
    private var isPwdFilled             = false {
        didSet {
            if isPwdFilled && isMailFilled && isLoginFilled {
                formIsReady = true
            }
        }
    }
    private var isLoginFilled             = false {
        didSet {
            if isPwdFilled && isMailFilled && isLoginFilled {
                formIsReady = true
            }
        }
    }
    internal lazy var serverAPI: APIServerProtocol = self.initializeServerAPI()
    
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
    
    private func performSignup() {
        if formIsReady {
//            serverAPI.
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
    private func initializeServerAPI() -> APIServerProtocol{
        return (self.navigationController as! AuthNavigationController).serverAPI
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
