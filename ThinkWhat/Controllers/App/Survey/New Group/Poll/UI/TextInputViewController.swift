//
//  TextInputViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.02.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//

import UIKit

class TextInputViewController: UIViewController {
    enum TitleType: String {
        case Title          = "Титул"
        case Description    = "Подробности"
        case Question       = "Вопрос"
        case Answer         = "Ответ"
        case Null           = ""
    }
    
    deinit {
        print("***TextInputViewController deinit***")
    }

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.accessibilityIdentifier = accessibilityIdentifier
            textView.delegate = self
            textView.text = textContent
            textView.font = font
            textView.textColor = textColor
            textView.tintColor = textColor
            if textCentered {
                textView.showsVerticalScrollIndicator = false
                textView.bounces = false
                textView.textAlignment = .center
                adjustContentSize()
            }
//            if type == .Question {
//                needsParagraphSpace = true
//            }
//            self.text.becomeFirstResponder()
//            delay(seconds: 0.01) {
//                self.text.resignFirstResponder()
//            }
        }
    }
    @IBOutlet weak var hideKBIcon: HideKeyboardIcon! {
        didSet {
            hideKBIcon.color = color
            let touch = UITapGestureRecognizer(target:self, action: #selector(TextViewController.toggleKeyboard))
            hideKBIcon.addGestureRecognizer(touch)
        }
    }
//    @IBOutlet var backgroundView: UIView! {
//        didSet {
//            backgroundView.addShadow(shadowColor: UIColor.lightGray.withAlphaComponent(0.3).cgColor, shadowOffset: .zero, shadowOpacity: 1, shadowRadius: 6)
//            backgroundView.layer.masksToBounds = false
//        }
//    }
    @IBOutlet weak var frameView: UIView! {
        didSet {
            frameView.cornerRadius = cornerRadius
            frameView.backgroundColor = color.withAlphaComponent(0.3)
        }
    }
    @IBOutlet weak var frameHeight: NSLayoutConstraint!
    @IBOutlet weak var frameToStackHeight: NSLayoutConstraint!
    @IBOutlet weak var okButton: UIButton! {
        didSet {
            okButton.setTitleColor(color, for: .normal)
        }
    }
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    @IBAction func okTapped(_ sender: Any) {
        if textView.text.count - (needsParagraphSpace ? 1 : 0) < minCharacters {
            UIView.animate(withDuration: 0, animations: {self.view.endEditing(true)}, completion: {
                _ in
                Banner.shared.contentType = .Warning
                if let content = Banner.shared.content as? Warning {
                    content.level = .Warning
                    content.text = "Поле \(self.type.rawValue) должен содержать не менее \(self.minCharacters) знаков"
                }
                Banner.shared.present(shouldDismissAfter: 2, delegate: self)
            })
        } else {
            //            delegate?.callbackReceived(text)
            navigationController?.popViewController(animated: true)
        }
    }
    var type: TitleType = .Null
    var color: UIColor = .gray
//    var titleString = ""
    var textContent = "" {
        didSet {
            if textContent.contains("\t") {
                needsParagraphSpace = true
            } else {
                needsParagraphSpace = false
            }
        }
    }
    var delegate: CallbackDelegate?
    var maxCharacters = 0
    var minCharacters = 0
    var font: UIFont?
    var textColor: UIColor?
    var textCentered = false
    var cornerRadius: CGFloat = 0
    var needsScaleAnim = false
    private var _textView: UITextView? {
        didSet {
            textView.text = _textView!.text
        }
    }
    private var needsParagraphSpace = false

    var isInputEnabled = true
    var accessibilityIdentifier = ""
    private var firstAppearance = true
    private var closure: ((String) -> ())?
    var keyboardHeight: CGFloat = 0 {
        didSet {
            if !firstAppearance {
                hideKBIcon.transform = hideKBIcon.transform.isIdentity ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
            }
//            if oldValue != keyboardHeight {
//                let height = view.frame.height - keyboardHeight - frameToStackHeight.constant - hideKBIcon.frame.height - 20
//                UIView.animate(withDuration: 0.2) {
//                    self.view.setNeedsLayout()
//                    self.frameHeight.constant = height
//                    self.view.layoutIfNeeded()
//                }
//            }
        }
    }
    private var boldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 19),
                                   NSAttributedString.Key.foregroundColor: UIColor.black,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    private var lightAttrs      = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 17),
                                   NSAttributedString.Key.foregroundColor: UIColor.black,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITextView.appearance().tintColor = .black
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = false
            nc.duration = 0.35
            nc.transitionStyle = .Icon
            navigationItem.setHidesBackButton(true, animated: false)
        }
        setTitle()
        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardWillHide(_:)),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        view.subviews.map {$0.isUserInteractionEnabled = false}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delay(seconds: 0.1) { self.textView.becomeFirstResponder() }
//        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
//            self.text.becomeFirstResponder()
////            self.view.setNeedsLayout()
//            let height = self.view.frame.height - self.keyboardHeight - self.frameToStackHeight.constant - self.hideKBIcon.frame.height - 20
//            self.frameHeight.constant = height
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        accessibilityIdentifier = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        delay(seconds: 0.5) {
            self.firstAppearance = false
            self.view.subviews.map {$0.isUserInteractionEnabled = true}
        }
//        if type == .Description, AppData.shared.system.newPollTutorialRequired {
//            Banner.shared.contentType = .Warning
//            if let content = Banner.shared.content as? Warning {
//                content.level = .Info
//                content.text = "Поле не обязательно для заполнения"
//            }
//            Banner.shared.present(shouldDismissAfter: 1, delegate: self)
//        }
        delay(seconds: 1.5) {
        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    private func setTitle() {
        let navTitle = UILabel()
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: type.rawValue + " (", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: "\(textView.text.count - (needsParagraphSpace ? 1 : 0))/\(maxCharacters)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .gray, backgroundColor: .clear)))
        attrString.append(NSAttributedString(string: ")", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        navTitle.attributedText = attrString
        navigationItem.titleView = navTitle
    }
    
    private func adjustContentSize() {
        let space = textView.bounds.size.height - textView.contentSize.height
        let inset = max(0, space/2)
        textView.contentInset = UIEdgeInsets(top: inset, left: textView.contentInset.left, bottom: inset, right: textView.contentInset.right)
    }
    
    @objc func toggleKeyboard() {
        if textView.isFirstResponder {
            view.endEditing(true)
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if keyboardHeight == 0, let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
            }
        }
        
        if !firstAppearance {
            let height = view.frame.height - keyboardHeight - frameToStackHeight.constant - hideKBIcon.frame.height - 20
            UIView.animate(withDuration: 0.2) {
                self.view.setNeedsLayout()
                self.frameHeight.constant = height
                self.view.layoutIfNeeded()
            }
        }
    }
    
//    @objc func keyboardDidShow(_ notification: Notification) {
//        if firstAppearance {
////            frameView.alpha = 1
//            firstAppearance = false
//        }
//    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
//        if keyboardHeight
        UIView.animate(withDuration: 0.4) {
            self.view.setNeedsLayout()
            self.frameHeight.constant += self.keyboardHeight
            self.view.layoutIfNeeded()
            self.keyboardHeight = 0
        }
    }
}

extension TextInputViewController: CallbackDelegate {
    func callbackReceived(_ sender: Any) {
        if let identifier = sender as? String {
            if identifier == Banner.bannerWillAppearSignal {
                view.endEditing(true)
            } else if identifier == Banner.bannerDidDisappearSignal {
                textView.becomeFirstResponder()
            }
        }
    }
}

extension TextInputViewController: UITextViewDelegate {
    //    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    //        checkTextViewEdited(beganEditing: true, textView: text, placeholder: placeholder)
    //        return true
    //    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !isInputEnabled {
            return false
        }
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 16 characters
        return updatedText.count - (needsParagraphSpace ? 1 : 0) <= maxCharacters
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textCentered {
            adjustContentSize()
        }
        if needsParagraphSpace, !textView.text.contains("\t") {
            textView.text.insert("\t", at: textView.text.startIndex)
        }
        setTitle()
    }
}







//
//class KeyboardService: NSObject {
//    static var serviceSingleton = KeyboardService()
//    var measuredSize: CGRect = CGRect.zero
//
//    @objc class func keyboardHeight() -> CGFloat {
//        let keyboardSize = KeyboardService.keyboardSize()
//        return keyboardSize.size.height
//    }
//
//    @objc class func keyboardSize() -> CGRect {
//        return serviceSingleton.measuredSize
//    }
//
//    private func observeKeyboardNotifications() {
//        let center = NotificationCenter.default
//        center.addObserver(self, selector: #selector(self.keyboardChange), name: UIResponder.keyboardDidShowNotification, object: nil)
//    }
//
//    private func observeKeyboard() {
//        let field = UITextField()
//        UIApplication.shared.windows.first?.addSubview(field)
//        field.becomeFirstResponder()
//        field.resignFirstResponder()
//        field.removeFromSuperview()
//    }
//
//    @objc private func keyboardChange(_ notification: Notification) {
//        guard measuredSize == CGRect.zero, let info = notification.userInfo,
//            let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
//            else { return }
//
//        measuredSize = value.cgRectValue
//    }
//
//    override init() {
//        super.init()
//        observeKeyboardNotifications()
//        observeKeyboard()
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}

//
//  TextInputViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.02.2021.
//  Copyright © 2021 Pavel Bukharov. All rights reserved.
//
//
//import UIKit
//
//class TextInputViewController: UIViewController {
//    enum TitleType: String {
//        case Title          = "Титул"
//        case Description    = "Подробности"
//        case Question       = "Вопрос"
//        case Answer         = "Ответ"
//        case Null           = ""
//    }
//
//    deinit {
//        print("***TextInputViewController deinit***")
//    }
//
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
//            //            self.text.becomeFirstResponder()
//            //            delay(seconds: 0.01) {
//            //                self.text.resignFirstResponder()
//            //            }
//        }
//    }
//    @IBOutlet weak var hideKBIcon: HideKeyboardIcon! {
//        didSet {
//            hideKBIcon.color = color
//            let touch = UITapGestureRecognizer(target:self, action: #selector(TextViewController.toggleKeyboard))
//            hideKBIcon.addGestureRecognizer(touch)
//        }
//    }
//    //    @IBOutlet var backgroundView: UIView! {
//    //        didSet {
//    //            backgroundView.addShadow(shadowColor: UIColor.lightGray.withAlphaComponent(0.3).cgColor, shadowOffset: .zero, shadowOpacity: 1, shadowRadius: 6)
//    //            backgroundView.layer.masksToBounds = false
//    //        }
//    //    }
//    @IBOutlet weak var frameView: UIView! {
//        didSet {
//            frameView.cornerRadius = cornerRadius
//            frameView.backgroundColor = color.withAlphaComponent(0.3)
//            //            frameView.layer.masksToBounds = true
//            //            frameView.addShadow(shadowColor: UIColor.lightGray.withAlphaComponent(0.5).cgColor, shadowOffset: .zero, shadowOpacity: 1, shadowRadius: 5)
//        }
//    }
//    @IBOutlet weak var frameHeight: NSLayoutConstraint!
//    @IBOutlet weak var frameToStackHeight: NSLayoutConstraint!
//    @IBOutlet weak var okButton: UIButton! {
//        didSet {
//            okButton.setTitleColor(color, for: .normal)
//        }
//    }
//    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
//    @IBAction func okTapped(_ sender: Any) {
//        if text.text.count - (needsParagraphSpace ? 1 : 0) < minCharacters {
//            UIView.animate(withDuration: 0, animations: {self.view.endEditing(true)}, completion: {
//                _ in
//                Banner.shared.contentType = .Warning
//                if let content = Banner.shared.content as? Warning {
//                    content.level = .Warning
//                    content.text = "Поле \(self.type.rawValue) должен содержать не менее \(self.minCharacters) знаков"
//                }
//                Banner.shared.present(shouldDismissAfter: 2, delegate: self)
//            })
//        } else {
//            //            delegate?.callbackReceived(text)
//            navigationController?.popViewController(animated: true)
//        }
//    }
//    var type: TitleType = .Null
//    var color: UIColor = .gray
//    //    var titleString = ""
//    var textContent = "" {
//        didSet {
//            if textContent.contains("\t") {
//                needsParagraphSpace = true
//            } else {
//                needsParagraphSpace = false
//            }
//        }
//    }
//    var delegate: CallbackDelegate?
//    var maxCharacters = 0
//    var minCharacters = 0
//    var font: UIFont?
//    var textColor: UIColor?
//    var textCentered = false
//    var cornerRadius: CGFloat = 0
//    var needsScaleAnim = false
//    private var textView: UITextView? {
//        didSet {
//            text.text = textView!.text
//        }
//    }
//    private var needsParagraphSpace = false
//
//    var accessibilityIdentifier = ""
//    private var firstAppearance = true
//    private var closure: ((String) -> ())?
//    var keyboardHeight: CGFloat = 0 {
//        didSet {
//            if !firstAppearance {
//                hideKBIcon.transform = hideKBIcon.transform.isIdentity ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
//            }
//            if oldValue != keyboardHeight {
//                let height = view.frame.height - keyboardHeight - frameToStackHeight.constant - hideKBIcon.frame.height - 20
//                UIView.animate(withDuration: 0.2) {
//                    self.view.setNeedsLayout()
//                    self.frameHeight.constant = height
//                    self.view.layoutIfNeeded()
//                }
//            }
//        }
//    }
//    private var boldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 19),
//                                   NSAttributedString.Key.foregroundColor: UIColor.black,
//                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
//    private var lightAttrs      = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 17),
//                                   NSAttributedString.Key.foregroundColor: UIColor.black,
//                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let nc = navigationController as? NavigationControllerPreloaded {
//            nc.isShadowed = false
//            nc.duration = 0.35
//            nc.transitionStyle = .Icon
//            navigationItem.setHidesBackButton(true, animated: false)
//        }
//        setTitle()
//        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardWillShow(_:)),
//                                               name: UIResponder.keyboardWillShowNotification, object: nil)
//        //        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(TextInputViewController.keyboardWillHide(_:)),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
//        view.subviews.map {$0.isUserInteractionEnabled = false}
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        delay(seconds: 0.1) { self.text.becomeFirstResponder() }
//        //        self.text.becomeFirstResponder()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        accessibilityIdentifier = ""
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        view.subviews.map {$0.isUserInteractionEnabled = true}
//        //        if type == .Description, AppData.shared.system.newPollTutorialRequired {
//        //            Banner.shared.contentType = .Warning
//        //            if let content = Banner.shared.content as? Warning {
//        //                content.level = .Info
//        //                content.text = "Поле не обязательно для заполнения"
//        //            }
//        //            Banner.shared.present(shouldDismissAfter: 1, delegate: self)
//        //        }
//    }
//
//    private func setTitle() {
//        let navTitle = UILabel()
//        navTitle.numberOfLines = 2
//        navTitle.textAlignment = .center
//        let attrString = NSMutableAttributedString()
//        attrString.append(NSAttributedString(string: type.rawValue + " (", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
//        attrString.append(NSAttributedString(string: "\(text.text.count - (needsParagraphSpace ? 1 : 0))/\(maxCharacters)", attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: 17), foregroundColor: .gray, backgroundColor: .clear)))
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
//            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
//                keyboardHeight = keyboardSize.height
//                print("Keyboard anim duration is \(duration)")
//                if firstAppearance {
//                    firstAppearance = false
//                }
//            }
//        }
//    }
//
//    //    @objc func keyboardDidShow(_ notification: Notification) {
//    //        if firstAppearance {
//    ////            frameView.alpha = 1
//    //            firstAppearance = false
//    //        }
//    //    }
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
//extension TextInputViewController: CallbackDelegate {
//    func callbackReceived(_ sender: AnyObject) {
//        if let identifier = sender as? String {
//            if identifier == Banner.bannerWillAppearSignal {
//                view.endEditing(true)
//            } else if identifier == Banner.bannerDidDisappearSignal {
//                text.becomeFirstResponder()
//            }
//        }
//    }
//}
//
//extension TextInputViewController: UITextViewDelegate {
//    //    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//    //        checkTextViewEdited(beganEditing: true, textView: text, placeholder: placeholder)
//    //        return true
//    //    }
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
//        return updatedText.count - (needsParagraphSpace ? 1 : 0) <= maxCharacters
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        if textCentered {
//            adjustContentSize()
//        }
//        if needsParagraphSpace, !textView.text.contains("\t") {
//            textView.text.insert("\t", at: textView.text.startIndex)
//        }
//        setTitle()
//    }
//
//    //
//    //    fileprivate func checkTextViewEdited(beganEditing: Bool, textView: UITextView, placeholder: String) {
//    //        if beganEditing {
//    //            if textView.text == placeholder {
//    //                textView.text = ""
//    //                textView.textAlignment = .natural
//    //            }
//    //        } else {
//    //            if textView.text.isEmpty {
//    //                textView.text = placeholder
//    //                textView.textAlignment = .center
//    //            }
//    //        }
//    //    }
//}
//
//
//
//
//
//
//
////
////class KeyboardService: NSObject {
////    static var serviceSingleton = KeyboardService()
////    var measuredSize: CGRect = CGRect.zero
////
////    @objc class func keyboardHeight() -> CGFloat {
////        let keyboardSize = KeyboardService.keyboardSize()
////        return keyboardSize.size.height
////    }
////
////    @objc class func keyboardSize() -> CGRect {
////        return serviceSingleton.measuredSize
////    }
////
////    private func observeKeyboardNotifications() {
////        let center = NotificationCenter.default
////        center.addObserver(self, selector: #selector(self.keyboardChange), name: UIResponder.keyboardDidShowNotification, object: nil)
////    }
////
////    private func observeKeyboard() {
////        let field = UITextField()
////        UIApplication.shared.windows.first?.addSubview(field)
////        field.becomeFirstResponder()
////        field.resignFirstResponder()
////        field.removeFromSuperview()
////    }
////
////    @objc private func keyboardChange(_ notification: Notification) {
////        guard measuredSize == CGRect.zero, let info = notification.userInfo,
////            let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
////            else { return }
////
////        measuredSize = value.cgRectValue
////    }
////
////    override init() {
////        super.init()
////        observeKeyboardNotifications()
////        observeKeyboard()
////    }
////
////    deinit {
////        NotificationCenter.default.removeObserver(self)
////    }
////}
