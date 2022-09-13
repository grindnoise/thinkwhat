//
//  CurrentUserCredentialsCell.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 07.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class CurrentUserCredentialsCell: UICollectionViewCell {
 
    // MARK: - Public properties
    public weak var userprofile: Userprofile! {
        didSet {
            guard let userprofile = userprofile else { return }
            
            avatar.userprofile = userprofile
            setupLabels()
            setupButtons()
        }
    }
    //Publishers
    public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    public let datePublisher = CurrentValueSubject<Date?, Never>(nil)
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private let padding: CGFloat = 20
    private lazy var username: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textAlignment = .center
        instance.numberOfLines = 2
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.edit(recognizer:))))
        
        let constraint = instance.heightAnchor.constraint(equalToConstant: 100)
        constraint.identifier = "height"
        constraint.isActive = true
        
//        instance.publisher(for: \.contentSize, options: .new)
//            .sink { [unowned self] size in
//                guard let constraint = instance.getConstraint(identifier: "height") else { return }
//
//                self.setNeedsLayout()
//                constraint.constant = size.height// * 1.5
//                self.layoutIfNeeded()
//                let space = constraint.constant - size.height
//                let inset = max(0, space/2)
//                instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
//            }
//            .store(in: &subscriptions)
        
        return instance
    }()
//    private lazy var gender: UILabel = {
//        let instance = UILabel()
//        instance.isUserInteractionEnabled = true
//        instance.textAlignment = .right
//        instance.numberOfLines = 2
//        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
//        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.edit(recognizer:))))
//        instance.textColor = .secondaryLabel
//
//        let heightConstraint = instance.heightAnchor.constraint(equalToConstant: "test".height(withConstrainedWidth: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!))
//        heightConstraint.identifier = "height"
//        heightConstraint.isActive = true
//
//        let widthConstraint = instance.widthAnchor.constraint(equalToConstant: "test".width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!))
//        widthConstraint.identifier = "width"
//        widthConstraint.isActive = true
//
////        instance.publisher(for: \.contentSize, options: .new)
////            .sink { [unowned self] size in
////                guard let constraint = instance.getConstraint(identifier: "height") else { return }
////
////                self.setNeedsLayout()
////                constraint.constant = size.height// * 1.5
////                self.layoutIfNeeded()
////                let space = constraint.constant - size.height
////                let inset = max(0, space/2)
////                instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
////            }
////            .store(in: &subscriptions)
//
//        return instance
//    }()
    private lazy var genderButton: UIButton = {
       let instance = UIButton()
        
//        instance.addTarget(self, action: #selector(self.send), for: .touchUpInside)
        instance.showsMenuAsPrimaryAction = true
        if #available(iOS 15, *) {
//            Userprofiles.shared.current?.gender.rawValue.localized
            let attrString = AttributedString("TEST", attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]))
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .medium
            config.attributedTitle = attrString
            config.image = UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets.leading = 8
            config.contentInsets.trailing = 4
            config.contentInsets.top = 2
            config.contentInsets.bottom = 2
            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
                guard let self = self else { return .systemGray }

                return self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            }
            config.buttonSize = .large
            config.baseBackgroundColor = .secondarySystemBackground
            config.baseForegroundColor = .label

            instance.configuration = config
        } else {
//            let attrString = NSMutableAttributedString(string: "test", attributes: [
//                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3) as Any,
//                NSAttributedString.Key.foregroundColor: UIColor.white
//            ])
////            instance.titleEdgeInsets.left = 20
////            instance.titleEdgeInsets.right = 20
//            instance.setImage(UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
//            instance.imageView?.tintColor = .white
//            instance.imageEdgeInsets.left = 4
////            instance.imageEdgeInsets.right = 8
//            instance.setAttributedTitle(attrString, for: .normal)
//            instance.semanticContentAttribute = .forceRightToLeft
//            instance.backgroundColor = .secondaryLabel//traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemRed
//
//            let constraint = instance.widthAnchor.constraint(equalToConstant: "test".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!))
//            constraint.identifier = "width"
//            constraint.isActive = true
        }
        
//        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
//            guard let self = self,
//                  let newValue = change.newValue
//            else { return }
//
//            guard let constraint = view.getConstraint(identifier: "width") else { return }
//            self.setNeedsLayout()
//            constraint.constant = self.state.rawValue.localized.uppercased().width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title2)!) + 40 + (view.imageView?.bounds.width ?? 0) + 60
//            self.layoutIfNeeded()
//        })
        return instance
    }()
    private lazy var age: UILabel = {
        let instance = UILabel()
        instance.isUserInteractionEnabled = true
        instance.textAlignment = .left
        instance.numberOfLines = 2
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
        instance.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.edit(recognizer:))))
        instance.textColor = .secondaryLabel
        
        let widthConstraint = instance.widthAnchor.constraint(equalToConstant: "test".width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!))
        widthConstraint.identifier = "width"
        widthConstraint.isActive = true
        
//        let constraint = instance.widthAnchor.constraint(equalToConstant: 100)
//        constraint.identifier = "widthAnchor"
//        constraint.isActive = true
        
//        instance.publisher(for: \.contentSize, options: .new)
//            .sink { [unowned self] size in
//                guard let constraint = instance.getConstraint(identifier: "height") else { return }
//
//                self.setNeedsLayout()
//                constraint.constant = size.height// * 1.5
//                self.layoutIfNeeded()
//                let space = constraint.constant - size.height
//                let inset = max(0, space/2)
//                instance.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
//            }
//            .store(in: &subscriptions)
        
        return instance
    }()
    private lazy var avatar: Avatar = {
        let instance = Avatar(isShadowed: true)
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        return instance
    }()
    private lazy var userView: UIView = {
        let instance = UIView()
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "userView"
        instance.addSubview(avatar)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: instance.topAnchor, constant: 4),
            avatar.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            avatar.bottomAnchor.constraint(equalTo: instance.bottomAnchor, constant: -4),
        ])
        
        return instance
    }()
//    private lazy var genderAgeView: UIView = {
//        let instance = UIView()
//        instance.isUserInteractionEnabled = true
//        instance.clipsToBounds = false
//        instance.backgroundColor = .clear
//        instance.accessibilityIdentifier = "genderAgeView"
//
//        let horizontalStack = UIStackView(arrangedSubviews: [genderButton, age])//gender
//        horizontalStack.axis = .horizontal
//        horizontalStack.alignment = .center
//        horizontalStack.clipsToBounds = false
//        horizontalStack.isUserInteractionEnabled = true
//        horizontalStack.spacing = 4
//
//        horizontalStack.heightAnchor.constraint(equalTo: genderButton.heightAnchor).isActive = true
////        horizontalStack.heightAnchor.constraint(equalTo: gender.heightAnchor).isActive = true
//
//        instance.addSubview(horizontalStack)
//
//        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            horizontalStack.topAnchor.constraint(equalTo: instance.topAnchor),
//            horizontalStack.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
//            instance.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor)
//        ])
//
//        return instance
//    }()
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [userView, username, genderButton])
        instance.axis = .vertical
        instance.alignment = .center
        instance.clipsToBounds = false
        instance.spacing = 4
        
        userView.translatesAutoresizingMaskIntoConstraints = false
        username.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userView.widthAnchor.constraint(equalTo: instance.widthAnchor),
            userView.heightAnchor.constraint(equalToConstant: 200),
            username.widthAnchor.constraint(equalTo: instance.widthAnchor),
//            genderAgeView.widthAnchor.constraint(equalTo: instance.widthAnchor),
//            repliesView.widthAnchor.constraint(equalTo: instance.widthAnchor),
        ])
        
        return instance
    }()
    private lazy var credentialsTextField: UsernameInputTextField = {
        let instance = UsernameInputTextField(font: UIFont.scaledFont(fontName: Fonts.Regular, forTextStyle: .body)!, delegate: self)
        addSubview(instance)
        
        return instance
    }()
    private lazy var ageTextField: UITextField = {
        let instance = UITextField(frame: .zero)
        instance.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        toolBar.backgroundColor = .tertiarySystemBackground
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.superview?.backgroundColor = .tertiarySystemBackground
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(self.dateSelected))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [space, doneButton]
        toolBar.barStyle = .default
        instance.inputAccessoryView = toolBar
        let tenYearsAgo = Calendar.current.date(byAdding: DateComponents(year: -10), to: Date())
        datePicker.maximumDate = tenYearsAgo
        
        addSubview(instance)
        
        return instance
    }()
    private lazy var datePicker: UIDatePicker = {
        let instance = UIDatePicker()
        instance.date = Date()
        instance.datePickerMode = .date
        instance.locale = .current
        instance.preferredDatePickerStyle = .inline
//        instance.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        instance.datePickerMode = .date
        instance.backgroundColor = .tertiarySystemBackground
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        return instance
    }()
//    private lazy var genderTextField: UITextField = {
//        let instance = UITextField(frame: .zero)
//        instance.inputView = genderPicker
//
//        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
//        toolBar.isTranslucent = true
//        toolBar.tintColor = UIColor { traitCollection in
//            switch traitCollection.userInterfaceStyle {
//            case .dark:
//                return UIColor.systemBlue
//            default:
//                return K_COLOR_RED
//            }
//        }
//        toolBar.backgroundColor = .tertiarySystemBackground
//        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//        toolBar.superview?.backgroundColor = .tertiarySystemBackground
//        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(self.genderSelected))
//        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        toolBar.items = [space, doneButton]
//        toolBar.barStyle = .default
//        instance.inputAccessoryView = toolBar
//
//        addSubview(instance)
//
//        return instance
//    }()
//    private lazy var genderPicker: UIPickerView = {
//       let instance = UIPickerView()
//        instance.delegate = self
//        instance.dataSource = self
//        instance.backgroundColor = .tertiarySystemBackground
//        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//
//        return instance
//    }()
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTasks()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
        
        let constraint = genderButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        constraint.priority = .defaultLow
        constraint.identifier = "bottomAnchor"
        constraint.isActive = true
    }
    
    private func setTasks() {
        //Hide keyboard
        tasks.append( Task {@MainActor [weak self] in
            for await _ in NotificationCenter.default.notifications(for: Notifications.System.HideKeyboard) {
                guard let self = self else { return }
                
                if self.ageTextField.isFirstResponder {
                    let _ = self.ageTextField.resignFirstResponder()
                } else {
                    let _ = self.credentialsTextField.resignFirstResponder()
                }
            }
        })
        
        //First name change
        tasks.append( Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.FirstNameChanged) {
                guard let self = self,
                      let instance = notification.object as? Userprofile,
                      instance.isCurrent
                else { return }
                
                self.setupLabels(animated: true)
            }
        })

        //Last name change
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.LastNameChanged) {
                guard let self = self,
                      let instance = notification.object as? Userprofile,
                      instance.isCurrent
                else { return }
                    
                self.setupLabels(animated: true)
            }
        })
        
        //Birth date change
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.BirthDateChanged) {
                guard let self = self,
                      let instance = notification.object as? Userprofile,
                      instance.isCurrent
                else { return }
                    
                self.setupLabels(animated: true)
            }
        })
    }
    
    @objc
    private func edit(recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        
        if v === username {
            let _ = credentialsTextField.becomeFirstResponder()
//        } else if v === gender {
//            genderTextField.becomeFirstResponder()
        } else if v === age {
            let _ = ageTextField.becomeFirstResponder()
            guard let date = Userprofiles.shared.current?.birthDate else { return }
            datePicker.date = date
        }
        Fade.shared.present()
    }
    
    private func setupLabels(animated: Bool = false) {
        guard let userprofile = Userprofiles.shared.current else { return }
        
        if !userprofile.firstNameSingleWord.isEmpty {
            if animated {
                UIView.transition(with: username, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
                    guard let self = self else { return }
                    
                    self.username.text = userprofile.firstNameSingleWord
                } completion: { _ in }
            } else {
                username.text = userprofile.firstNameSingleWord
            }
        }
        
        if !userprofile.lastNameSingleWord.isEmpty {
            if animated {
                UIView.transition(with: username, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
                    guard let self = self else { return }
                    
                    self.username.text! += self.username.text!.isEmpty ? self.userprofile.lastNameSingleWord : " " + userprofile.lastNameSingleWord
                } completion: { _ in }
            } else {
                username.text! += username.text!.isEmpty ? userprofile.lastNameSingleWord : " " + userprofile.lastNameSingleWord
            }
        }
        
        if animated {
            UIView.transition(with: age, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
                guard let self = self else { return }
                
                self.age.text = String(describing: userprofile.age)
            } completion: { _ in }
        } else {
            age.text = String(describing: userprofile.age)
        }
        
        
//        gender.text = userprofile.gender.rawValue.localized.lowercased() + ","
        
        guard let constraint_1 = username.getConstraint(identifier: "height"),
//              let constraint_2 = gender.getConstraint(identifier: "width"),
              let constraint_3 = age.getConstraint(identifier: "width")
        else { return }
        
        setNeedsLayout()
        constraint_1.constant = username.text!.height(withConstrainedWidth: username.bounds.width, font: username.font)
//        constraint_2.constant = gender.text!.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
        constraint_3.constant = age.text!.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
        layoutIfNeeded()
    }
    
    private func setupButtons(animated: Bool = false) {
        guard let userprofile = Userprofiles.shared.current else { return }
        
        if #available(iOS 15, *) {
            if !genderButton.configuration.isNil {
                let attrString = AttributedString(userprofile.gender.rawValue.localized.capitalized, attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
                ]))
                UIView.transition(with: genderButton, duration: 0.1, options: .transitionCrossDissolve) {
                    self.genderButton.configuration!.attributedTitle = attrString
                }
            }
        } else {
//            actionButton.setImage(UIImage(), for: .normal)
//            actionButton.setAttributedTitle(nil, for: .normal)
//            let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
//                                                                  size: CGSize(width: actionButton.frame.height,
//                                                                               height: actionButton.frame.height)))
//            indicator.alpha = 0
//            indicator.layoutCentered(in: actionButton)
//            indicator.startAnimating()
//            indicator.color = .white
//            indicator.accessibilityIdentifier = "indicator"
//            UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
//
//            //        delayAsync(delay: 2) { [weak self] in
//            ////            self?.onSuccessCallback()
//            //            self?.onFailureCallback()
//            //        }
        }
    }
    
    @objc
    private func dateSelected() {
        ageTextField.resignFirstResponder()
        Fade.shared.dismiss()
        datePublisher.send(datePicker.date)
    }
    
//    @objc
//    private func genderSelected() {
//        genderTextField.resignFirstResponder()
//        Fade.shared.dismiss()
////        datePublisher.send(datePicker.date)
//    }
    
    // MARK: - Overriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        datePicker.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        
        //Set dynamic font size
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        
        guard let constraint_1 = username.getConstraint(identifier: "height"),
//              let constraint_2 = gender.getConstraint(identifier: "height"),
              !username.text.isNil
        else { return }
        
        username.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title1)
//        gender.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
        age.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
        
        setNeedsLayout()
        constraint_1.constant = username.text!.height(withConstrainedWidth: username.bounds.width, font: username.font)
//        constraint_2.constant = "test".height(withConstrainedWidth: gender.bounds.width, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
        layoutIfNeeded()
    }
}

// MARK: - UsernameInputTextFieldDelegate
extension CurrentUserCredentialsCell: UsernameInputTextFieldDelegate {
    func onSendEvent(_ credentials: [String: String]) {
        let _ = credentialsTextField.resignFirstResponder()
        Fade.shared.dismiss()
        guard !credentials.isEmpty else { return }
        
        namePublisher.send(credentials)
    }
}

//extension CurrentUserCredentialsCell: UIPickerViewDataSource, UIPickerViewDelegate {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        2
//    }
//
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        return NSAttributedString(string: Gender.allCases[row].rawValue.localized.lowercased(),
//                                  attributes: [
//                                      NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .headline) as Any,
//                                      NSAttributedString.Key.foregroundColor: UIColor.label
//                                  ])
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
////        toolbarPicker?.toolbar.items?.forEach { button in
////            button.title = (button.style == .done ? "select" : "cancel").localized
////            controller?.onLanguageChanged(selectedLanguage)
////        }
//    }
//}

