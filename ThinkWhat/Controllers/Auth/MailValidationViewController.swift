//
//  MailValidationViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 02.08.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class MailValidationViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var validationCodeTextField: UITextField!
    @IBOutlet weak var retryCodeTextView: UITextView!
    
//    private var appIsGoingBackground = false
    private var validationCode: Int! = 0000 {
        didSet {
            if oldValue != validationCode {
                if let response = emailResponse {
                    if response.expiresIn < Date() {
                        if validationCode == response.confirmation_code {
//                            performSegue(withIdentifier: segueTermsOfUse, sender: nil)
                        } else {
                            simpleAlert("Неверный код подтверждения")
//                            showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Неверный код подтверждения")
                        }
                    } else {
                        simpleAlert("Срок действия кода подтверждения истек, попробуйте заново")
//                        showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Срок действия кода подтверждения истек, попробуйте заново")
                    }
                }
            }
        }
    }
    var phoneNumber:                    String!
    var phoneNumberFormatted:           String!
    var username                        = ""
    
    private let normalAttrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_GRAY,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    private let actionAttrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 11),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validationCodeTextField.delegate    = self
        self.title                          = "Подтверждение"
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MailValidationViewController.applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        let touch = UITapGestureRecognizer(target:self, action:#selector(MailValidationViewController.hideKeyboard))
        view.addGestureRecognizer(touch)
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            let attrString = NSMutableAttributedString(string: "Если Вы не получили SMS, пожалуйста, ", attributes: self.normalAttrs)
            attrString.append(NSAttributedString(string: "попробуйте снова", attributes: self.actionAttrs))
            self.retryCodeTextView.attributedText = attrString as NSAttributedString
            self.retryCodeTextView.textContainerInset = .zero
            self.retryCodeTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            self.validationCodeTextField.keyboardType = .numberPad
        }
    }
    
    //MARKS: - Handlers
    @objc private func applicationWillResignActive(notification: NSNotification) {
        view.endEditing(true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (validationCodeTextField.defaultTextAttributes.updateValue(10.0, forKey: NSAttributedString.Key(rawValue: NSAttributedString.Key.kern.rawValue)) != nil) {
            let maxLength = 4
            let currentString: NSString = validationCodeTextField.text! as NSString
            let newString: String = currentString.replacingCharacters(in: range, with: string)
            validationCode = newString.count == 4 ? Int(newString) : validationCode
            
            return newString.count <= maxLength
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        validationCode = textField.text?.count == 4 ? Int(textField.text!) : validationCode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == segueTermsOfUse {
//            if let destinationVC = segue.destination as? TermsOfUseViewController {
//                destinationVC.isBackButtonHidden    = true
//                destinationVC.isStackViewHidden     = false
//                destinationVC.phoneNumber           = phoneNumber
//                destinationVC.phoneNumberFormatted  = phoneNumberFormatted
//                destinationVC.username              = username
//            }
//        }
    }
    
    private func simpleAlert(_ message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("You've pressed default")
        }
        alertController.addAction(action1)
        present(alertController, animated: true)
    }
    
}

