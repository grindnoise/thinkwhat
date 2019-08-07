////
////  ConfirmViewController.swift
////  Burb
////
////  Created by Eugene on 13.06.2018.
////  Copyright © 2018 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class ValidationViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
//
//    @IBOutlet weak var validationCodeTextField: UITextField!
////    @IBOutlet weak var retryCodeTextView: UITextView!
//    @IBOutlet weak var retryTimer: UILabel!
//    @IBOutlet weak var retryTimerButton: UIButton!
//    @IBAction func retryTapped(_ sender: UIButton) {
//        //MARK: TODO: add server request
//        isTimerVisible = true
//    }
//
//    private var seconds: Int            = 600
//    private var secondsRetry: Int       = 30
//    private var timer                   = Timer()
//    private var isTimerRunning          = false
//    private var appIsGoingBackground    = false
//    private var validationCode: Int!    = 0000 {
//        didSet {
////            if validationCode == 7777 {
////                performSegue(withIdentifier: segueTermsOfUse, sender: nil)
////            }
//            if oldValue != validationCode {
//                if let response = emailResponse {
//                    if !hasSMSPasscodeExpired() {
//                        if validationCode == response.confirmation_code {
//                            //TODO: Check if user already exists
//                            performSegue(withIdentifier: segueTermsOfUse, sender: nil)
//                        } else {
////                            showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Неверный код подтверждения")
//                        }
//                    } else {
////                        showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Срок действия кода СМС подтверждения истек, попробуйте заново")
//                    }
//                }
//            }
//        }
//    }
//    private var isTimerVisible = false {
//        didSet {
//            if oldValue != isTimerVisible {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.retryTimer.alpha       = self.isTimerVisible == true ? 1 : 0
//                    self.retryTimerButton.alpha = self.isTimerVisible == true ? 0 : 1
//                }, completion: {
//                    _ in
//                    if self.isTimerVisible { self.runTimer() }
//                })
//            }
//        }
//    }
//    var phoneNumber:                    String!
//    var phoneNumberFormatted:           String!
//    var username                        = ""
//
////    private let normalAttrs     = [NSAttributedStringKey.font : UIFont(name: "OpenSans-Light", size: 11),
////                                   NSAttributedStringKey.foregroundColor: K_COLOR_GRAY,
////                                   NSAttributedStringKey.backgroundColor: UIColor.clear]
////    private let actionAttrs     = [NSAttributedStringKey.font : UIFont(name: "OpenSans-Light", size: 11),
////                                   NSAttributedStringKey.foregroundColor: K_COLOR_RED,
////                                   NSAttributedStringKey.backgroundColor: UIColor.clear]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        validationCodeTextField.delegate    = self
//        self.title                          = "Подтверждение"
//        setupViews()
//        setupGestures()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        appIsGoingBackground = false
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        isTimerVisible       = true
//    }
//
//    private func setupGestures() {
//        NotificationCenter.default.addObserver(self, selector: #selector(PhoneValidationViewController.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: UIApplication.shared)
//        NotificationCenter.default.addObserver(self, selector: #selector(PhoneValidationViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
//        let touch = UITapGestureRecognizer(target:self, action:#selector(PhoneValidationViewController.hideKeyboard))
//        view.addGestureRecognizer(touch)
////        let tap = UITapGestureRecognizer(target:self, action:#selector(PhoneValidationViewController.retrySMSValidationCode(gesture:)))
////        retryCodeTextView.addGestureRecognizer(tap)
//    }
//
//    private func setupViews() {
//        DispatchQueue.main.async {
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            self.navigationController?.navigationBar.shadowImage     = UIImage()
//            self.navigationController?.navigationBar.isTranslucent   = false
//            self.navigationController?.isNavigationBarHidden         = false
//            self.navigationController?.navigationBar.barTintColor    = .white
//            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
////            let attrString = NSMutableAttributedString(string: "Если Вы не получили SMS, пожалуйста, ", attributes: self.normalAttrs)
////            attrString.append(NSAttributedString(string: "попробуйте снова", attributes: self.actionAttrs))
////            self.retryCodeTextView.attributedText = attrString as NSAttributedString
////            self.retryCodeTextView.textContainerInset = .zero
////            self.retryCodeTextView.contentInset = UIEdgeInsetsMake(0, -5, 0, 0)
//            self.validationCodeTextField.keyboardType = .numberPad
//        }
//    }
//
//    //MARKS: - Handlers
//    @objc private func applicationWillResignActive(notification: NSNotification) {
//        appIsGoingBackground = true
//        view.endEditing(true)
//    }
//
//    @objc private func applicationDidBecomeActive(notification: NSNotification) {
//        appIsGoingBackground = false
//    }
//
//    @objc private func hideKeyboard() {
//        view.endEditing(true)
//    }
//
//    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        if (validationCodeTextField.defaultTextAttributes.updateValue(10.0, forKey: NSAttributedStringKey.kern.rawValue) != nil) {
//            let maxLength = 4
//            let currentString: NSString = validationCodeTextField.text! as NSString
//            let newString: String = currentString.replacingCharacters(in: range, with: string)
//            validationCode = newString.count == 4 ? Int(newString) : validationCode
//
//            return newString.count <= maxLength
//        }
//        return true
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
//        validationCode = textField.text?.count == 4 ? Int(textField.text!) : validationCode
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == segueTermsOfUse {
//            if let destinationVC = segue.destination as? TermsOfUseViewController {
//                destinationVC.isBackButtonHidden    = true
//                destinationVC.isStackViewHidden     = false
//                destinationVC.phoneNumber           = phoneNumber
//                destinationVC.phoneNumberFormatted  = phoneNumberFormatted
//                destinationVC.username              = username
//            }
//        }
//    }
//
//    @objc private func runTimer() {
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(PhoneValidationViewController.updateTimer)), userInfo: nil, repeats: true)
//    }
//
//    @objc private func updateTimer() {
//        secondsRetry    -= 1
//        retryTimer.text = timeString(time: TimeInterval(secondsRetry))
//        if secondsRetry == 0 {
//            timer.invalidate()
//            isTimerVisible = false
//            secondsRetry = 30
//        }
//    }
//
//    func timeString(time:TimeInterval) -> String {
//        //let hours = Int(time) / 3600
//        let minutes = Int(time) / 60 % 60
//        let seconds = Int(time) % 60
//        return String(format: "Повторный запрос кода %02i:%02i"/*:%02i", hours*/, minutes, seconds)
//    }
//}
