//
//  TextEditingView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.01.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class TextEditingView: UIView, CAAnimationDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var frameView: BorderedView!
    @IBOutlet      var lightBlurView: UIVisualEffectView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var hideKBIcon: HideKeyboardIcon!
    @IBOutlet weak var frameHeight: NSLayoutConstraint!
    @IBOutlet weak var frameToStackHeight: NSLayoutConstraint!
    @IBAction func okTapped(_ sender: Any) {
        if text.text.isEmpty {
            UIView.animate(withDuration: 0, animations: {self.endEditing(true)}, completion: {
                _ in
                showAlert(type: .Warning, buttons: [["Отмена": [.Cancel: {self.dismiss(save: false)}]], ["Ввести текст": [.Ok: {self.text.becomeFirstResponder()}]]], text: "Введите текст или нажмите Отмена")
            })
        } else {
            dismiss(save: true)
        }
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(save: false)
    }
//    fileprivate var _stringVariablePointer: AnyObject?//UnsafeMutablePointer<String>?
    var delegate: NewSurveyViewController?
    fileprivate var charactersLimit = 0
    fileprivate var textView: UITextView? {
        didSet {
            text.text = textView!.text
            setTitle()
        }
    }
//    fileprivate var title = ""
    fileprivate var placeholder = ""
    fileprivate var firstAppearance = true
    fileprivate var closure: ((String) -> ())?
    fileprivate var keyboardHeight: CGFloat = 0 {
        didSet {
            if !firstAppearance {
                hideKBIcon.transform = hideKBIcon.transform.isIdentity ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
            }
            if oldValue != keyboardHeight {
                let height = self.frame.height - keyboardHeight - label.frame.height - frameToStackHeight.constant - stackView.frame.height
                UIView.animate(withDuration: 0.2) {
                    self.setNeedsLayout()
                    self.frameHeight.constant = height
                    self.layoutIfNeeded()
                }
            }
        }
    }
    fileprivate var boldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 19),
                                       NSAttributedString.Key.foregroundColor: UIColor.black,
                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
    fileprivate var lightAttrs      = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 17),
                                       NSAttributedString.Key.foregroundColor: UIColor.black,
                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
    fileprivate var constantTitle: NSMutableAttributedString!
    
    init(frame: CGRect, delegate: NewSurveyViewController?) {
        super.init(frame: frame)
        self.commonInit()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TextEditingView", owner: self, options: nil)
        guard let content = contentView else {
            return
        }
        frameView.backgroundColor = .white
        frameView.borderWidth = 1.5
        frameView.borderColor = K_COLOR_GRAY
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        NotificationCenter.default.addObserver(self, selector: #selector(TextEditingView.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TextEditingView.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let touch = UITapGestureRecognizer(target:self, action: #selector(TextEditingView.toggleKeyboard))
        hideKBIcon.addGestureRecognizer(touch)
        self.addSubview(content)
    }

    public func present(title _title: String, textView _textView: UITextView, placeholder _placeholder: String, charactersLimit _charactersLimit: Int, closure _closure: @escaping(String) -> ()) {
//        if _textView != nil {
//            text.text = _textView!.text
//            textView = _textView
//        }
        charactersLimit = _charactersLimit
//        title = _title
        constantTitle = NSMutableAttributedString(string: _title, attributes: boldAttrs)
        textView = _textView
//        text.delegate = self
        text.delegate = self
//        label.text = title
//        title = _title
        closure = _closure
        placeholder = _placeholder
        firstAppearance = true
        hideKBIcon.transform = .identity
        layer.zPosition = 100
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)

        contentView.alpha = 1
        stackView.alpha = 1
        lightBlurView.alpha = 0
        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        frameView.layer.opacity = 1
        
        delegate?.statusBarHidden = true
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.lightBlurView.alpha = 1
        }, completion: nil)
        
        let scaleAnim       = CASpringAnimation(keyPath: "transform.scale")//CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        groupAnim.delegate = self
        
        //Slight scale/fade animation
        scaleAnim.fromValue = 0.7
        scaleAnim.toValue   = 1.0
        scaleAnim.duration  = 0.9
        scaleAnim.damping   = 14
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 0
        fadeAnim.toValue    = 1
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 1.3
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        frameView.layer.add(scaleAnim, forKey: nil)
        frameView.layer.opacity = Float(1)
        frameView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        text.becomeFirstResponder()
    }
    
    public func dismiss(save: Bool) {
        if textView != nil, let tableView = delegate?.tableView {
            if save {
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    self.textView?.text = self.text.text
                    tableView.endUpdates()
                }
            }
        }
        
        endEditing(true)
        
        //Slight scale/fade animation
        let scaleAnim       = CABasicAnimation(keyPath: "transform.scale")
        let fadeAnim        = CABasicAnimation(keyPath: "opacity")
        let groupAnim       = CAAnimationGroup()
        
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue   = 0.7
        scaleAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        fadeAnim.fromValue  = 1
        fadeAnim.toValue    = 0
        
        groupAnim.animations        = [scaleAnim, fadeAnim]
        groupAnim.duration          = 0.2
        groupAnim.timingFunction    = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        frameView.layer.add(groupAnim, forKey: nil)
        frameView.layer.opacity = Float(0)
        frameView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
        
//        delay(seconds: 0.1) {
            self.delegate?.statusBarHidden = false
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.stackView.alpha = 0
                self.lightBlurView.alpha = 0
                if self.closure != nil {
                    self.closure!(self.text.text)
                }
            }, completion: {
                _ in
                self.removeFromSuperview()
            })
//        }
    }
    
    @objc func toggleKeyboard() {
        if text.isFirstResponder {
            endEditing(true)
        } else {
            text.becomeFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
                if firstAppearance {
                    firstAppearance = false
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.setNeedsLayout()
            self.frameHeight.constant += self.keyboardHeight
            self.layoutIfNeeded()
            self.keyboardHeight = 0
        }
    }
    
    deinit {
        print("TextEditingView deinit")
    }
}

extension TextEditingView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        checkTextViewEdited(beganEditing: true, textView: text, placeholder: placeholder)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        setTitle()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 16 characters
        return updatedText.count <= charactersLimit
    }
    
    fileprivate func checkTextViewEdited(beganEditing: Bool, textView: UITextView, placeholder: String) {
        if beganEditing {
            if textView.text == placeholder {
                textView.text = ""
                textView.textAlignment = .natural
                setTitle(true)
            }
        } else {
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textAlignment = .center
            }
        }
    }
    
    fileprivate func setTitle(_ isInitial: Bool = false) {
        let charactersCount       = isInitial ? " (0/\(charactersLimit))" : " (\(text.text.length)/\(charactersLimit))"
        let charactersCountString = NSMutableAttributedString(string: charactersCount, attributes: lightAttrs)
        let labelTitle = NSMutableAttributedString(attributedString: constantTitle)
        labelTitle.append(charactersCountString)
        label.attributedText = labelTitle
    }
}
