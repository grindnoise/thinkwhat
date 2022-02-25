//
//  RecoverView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class RecoverView: UIView {
    
    deinit {
        print("RecoverView deinit")
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mailTF: UnderlinedSignTextField! {
        didSet {
            mailTF.placeholder = #keyPath(RecoverView.mailTF).localized
            setTextFieldColors(textField: mailTF)
        }
    }
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.setTitle(#keyPath(RecoverView.sendButton).localized, for: .normal)
        }
    }
    
    // MARK: - IB actions
    @IBAction func recoverTapped(_ sender: Any) {
        mailTF.resignFirstResponder()
        checkTextField(sender: mailTF)
        if isEmailFilled {
            // TODO: - Send link
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib()
                    else { fatalError("View could not load from nib") }
                addSubview(contentView)

        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
    }
    
    override func layoutSubviews() {
        guard sendButton != nil else { return }
        sendButton.cornerRadius = sendButton.frame.height/2.25
    }
    
    // MARK: - Properties
    weak var viewInput: RecoverViewInput?
    private var isEmailFilled = false
    override var frame: CGRect {
        didSet {
            layoutSubviews()
        }
    }
    override var bounds: CGRect {
        didSet {
            layoutSubviews()
        }
    }
}

// MARK: - Controller Output
extension RecoverView: RecoverControllerOutput {
    
    // Implement methods
    
}

// MARK: - UI Setup
extension RecoverView {
    private func setupUI() {
        sendButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        let touch = UITapGestureRecognizer(target:self, action:#selector(RecoverView.hideKeyboard))
        self.addGestureRecognizer(touch)
    }
    
    private func setTextFieldColors(textField: UnderlinedSignTextField) {
        let tfWarningColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemYellow
            default:
                return K_COLOR_RED
            }
        }
        let color: UIColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        textField.delegate = self
        textField.tintColor = color
        textField.line.layer.strokeColor = color.cgColor
        textField.color = tfWarningColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var tfWarningColor = K_COLOR_RED
        var destinationColor: UIColor!
        switch traitCollection.userInterfaceStyle {
        case .dark:
            destinationColor = UIColor.systemBlue
            tfWarningColor = .systemYellow
        default:
            destinationColor = K_COLOR_RED
//            tfWarningColor = K_COLOR_RED
        }
        mailTF.line.layer.strokeColor = destinationColor.cgColor
        mailTF.lineWidth = 1.5
        mailTF.activeLineWidth = 1.5
        mailTF.tintColor = destinationColor
        mailTF.color = tfWarningColor
        mailTF.keyboardType = .asciiCapable
    }
}

// MARK: - Text fields delegate
extension RecoverView: UITextFieldDelegate {
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTextField(sender: textField)
    }
    
    private func checkTextField(sender: UITextField) {
        guard let textField = sender as? UnderlinedSignTextField else { return }
        if !textField.text!.isValidEmail {
            textField.showSign(state: .EmailIsIncorrect)
            isEmailFilled = false
        } else {
            textField.hideSign()
            isEmailFilled = true
        }
    }
}

