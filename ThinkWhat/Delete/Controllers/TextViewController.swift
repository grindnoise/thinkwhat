////
////  TextViewController.swift
////  ThinkWhat
////
////  Created by Pavel Bukharov on 11.12.2020.
////  Copyright © 2020 Pavel Bukharov. All rights reserved.
////
//
//import UIKit
//
//class TextViewController: UIViewController {
//
//    @IBOutlet weak var frameView: BorderedView!
//    @IBOutlet weak var text: UITextView! {
//        didSet {
//            text.accessibilityIdentifier = accessibilityIdentifier
//            text.delegate = self
//            text.text = textContent
//            text.font = font
//            text.textColor = textColor
//            text.tintColor = textColor
//            if textCentered {
//                text.showsVerticalScrollIndicator = false
//                text.bounces = false
//                text.textAlignment = .center
//                adjustContentSize()
//            }
//            delay(seconds: 0.05) {
//                self.text.becomeFirstResponder()
//            }
//        }
//    }
//    @IBOutlet weak var stackView: UIStackView!
//    @IBOutlet weak var hideKBIcon: HideKeyboardIcon! {
//        didSet {
//            let touch = UITapGestureRecognizer(target:self, action: #selector(TextViewController.toggleKeyboard))
//            hideKBIcon.addGestureRecognizer(touch)
//        }
//    }
//    @IBOutlet weak var frameHeight: NSLayoutConstraint!
//    @IBOutlet weak var frameToStackHeight: NSLayoutConstraint!
//    @IBAction func okTapped(_ sender: Any) {
//        if text.text.isEmpty {
//            UIView.animate(withDuration: 0, animations: {self.view.endEditing(true)}, completion: {
//                _ in
//                showAlert(type: .Warning, buttons: [["Отмена": [.Cancel: {self.navigationController?.popViewController(animated: true)}]], ["Ввести текст": [.Ok: {self.text.becomeFirstResponder()}]]], text: "Введите текст или нажмите Отмена")
//            })
//        } else {
////            delegate?.callbackReceived(text)
//            navigationController?.popViewController(animated: true)
//        }
//    }
//    @IBAction func cancelTapped(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
//    var titleString = ""
//    var textContent = ""
//    var delegate: CallbackObservable?
//    var charactersLimit = 0
//    var font: UIFont?
//    var textColor: UIColor?
//    var textCentered = false
//    private var textView: UITextView? {
//        didSet {
//            text.text = textView!.text
//        }
//    }
//    //    fileprivate var title = ""
////    var placeholder = ""
//    var accessibilityIdentifier = ""
//    private var firstAppearance = true
//    private var closure: ((String) -> ())?
//    private var keyboardHeight: CGFloat = 0 {
//        didSet {
//            if !firstAppearance {
//                hideKBIcon.transform = hideKBIcon.transform.isIdentity ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
//            }
//            if oldValue != keyboardHeight {
//                let height = view.frame.height - keyboardHeight - frameToStackHeight.constant - stackView.frame.height - 20
//                UIView.animate(withDuration: 0.2) {
//                    self.view.setNeedsLayout()
//                    self.frameHeight.constant = height
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
//    }
//    private var boldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 19),
//                                       NSAttributedString.Key.foregroundColor: UIColor.black,
//                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
//    private var lightAttrs      = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 17),
//                                       NSAttributedString.Key.foregroundColor: UIColor.black,
//                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(TextViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(TextViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        setupViews()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        setTitle()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.transitionStyle = .Blur
//            nc.duration = 0.2
//            nc.isShadowed = true
////            if !nc.viewControllers.isEmpty, let previousVC = nc.viewControllers[nc.viewControllers.count - 1] as? CreateNewSurveyViewController,  previousVC.isNavigationBarHidden {
////                nc.setNavigationBarHidden(true, animated: true)
////            }
//        }
//    }
//
//    private func setupViews() {
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage     = UIImage()
//
//        self.navigationItem.setHidesBackButton(true, animated: false)
//        self.navigationController?.navigationBar.isTranslucent   = false
//        self.navigationController?.isNavigationBarHidden         = false
//        self.navigationController?.navigationBar.barTintColor    = .white
//        self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.isShadowed = false
//        }
//    }
//
//    private func setTitle() {
//        let navTitle = UILabel()
//        navTitle.numberOfLines = 2
//        navTitle.textAlignment = .center
//        let attrString = NSMutableAttributedString()
//        attrString.append(NSAttributedString(string: titleString + " (", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
//        attrString.append(NSAttributedString(string: "\(text.text.count)/\(charactersLimit)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .gray, backgroundColor: .clear)))
//        attrString.append(NSAttributedString(string: ")", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
//        navTitle.attributedText = attrString
//        navigationItem.titleView = navTitle
//    }
//
//    private func adjustContentSize() {
//        let space = text.bounds.size.height - text.contentSize.height
//        let inset = max(0, space/2)
//        text.contentInset = UIEdgeInsets(top: inset, left: text.contentInset.left, bottom: inset, right: text.contentInset.right)
//    }
//
//    @objc func toggleKeyboard() {
//        if text.isFirstResponder {
//            view.endEditing(true)
//        } else {
//            text.becomeFirstResponder()
//        }
//    }
//
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if let userInfo = notification.userInfo {
//            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                keyboardHeight = keyboardSize.height
//                if firstAppearance {
//                    firstAppearance = false
//                }
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(_ notification: Notification) {
//        UIView.animate(withDuration: 0.4) {
//            self.view.setNeedsLayout()
//            self.frameHeight.constant += self.keyboardHeight
//            self.view.layoutIfNeeded()
//            self.keyboardHeight = 0
//        }
//    }
//}
//
//extension TextViewController: UITextViewDelegate {
////    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
////        checkTextViewEdited(beganEditing: true, textView: text, placeholder: placeholder)
////        return true
////    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        // get the current text, or use an empty string if that failed
//        let currentText = textView.text ?? ""
//
//        // attempt to read the range they are trying to change, or exit if we can't
//        guard let stringRange = Range(range, in: currentText) else { return false }
//
//        // add their new text to the existing text
//        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
//
//        // make sure the result is under 16 characters
//        return updatedText.count <= charactersLimit
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        if textCentered {
//            adjustContentSize()
//        }
//        setTitle()
//    }
////
////    fileprivate func checkTextViewEdited(beganEditing: Bool, textView: UITextView, placeholder: String) {
////        if beganEditing {
////            if textView.text == placeholder {
////                textView.text = ""
////                textView.textAlignment = .natural
////            }
////        } else {
////            if textView.text.isEmpty {
////                textView.text = placeholder
////                textView.textAlignment = .center
////            }
////        }
////    }
//}
