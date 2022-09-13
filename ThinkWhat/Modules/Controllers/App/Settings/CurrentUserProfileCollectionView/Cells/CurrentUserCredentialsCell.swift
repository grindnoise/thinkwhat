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
            avatar.isEditable = true
            setupLabels()
            setupButtons()
        }
    }
    //Publishers
    public let namePublisher = CurrentValueSubject<[String: String]?, Never>(nil)
    public let datePublisher = CurrentValueSubject<Date?, Never>(nil)
    public let genderPublisher = CurrentValueSubject<Gender?, Never>(nil)
    public let imagePublisher = CurrentValueSubject<Bool?, Never>(nil)
    
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
    private lazy var genderButton: UIButton = {
       let instance = UIButton()
        
        instance.showsMenuAsPrimaryAction = true
        instance.menu = prepareMenu()
        if #available(iOS 15, *) {
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
            let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ])
            instance.setAttributedTitle(attrString, for: .normal)
            instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            instance.titleEdgeInsets.left = 2
//            instance.titleEdgeInsets.right = 8
            instance.titleEdgeInsets.top = 2
            instance.titleEdgeInsets.bottom = 2
            instance.setImage(UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            instance.imageView?.contentMode = .scaleAspectFit
            instance.imageEdgeInsets.left = 10
            instance.imageEdgeInsets.top = 2
            instance.imageEdgeInsets.bottom = 2
            instance.imageEdgeInsets.right = 2
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = .secondarySystemBackground

            let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            view.cornerRadius = newValue.height * 0.15
        })
        return instance
    }()
    private lazy var ageButton: UIButton = {
       let instance = UIButton()
        
        instance.addTarget(self, action: #selector(self.editAge), for: .touchUpInside)
        if #available(iOS 15, *) {
            let attrString = AttributedString("TEST", attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label
            ]))
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .medium
            config.attributedTitle = attrString
            config.image = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
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
            let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ])
            instance.setAttributedTitle(attrString, for: .normal)
            instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            instance.titleEdgeInsets.left = 2
//            instance.titleEdgeInsets.right = 8
            instance.titleEdgeInsets.top = 2
            instance.titleEdgeInsets.bottom = 2
            instance.setImage(UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
            instance.imageView?.contentMode = .scaleAspectFit
            instance.imageEdgeInsets.left = 10
            instance.imageEdgeInsets.top = 2
            instance.imageEdgeInsets.bottom = 2
            instance.imageEdgeInsets.right = 2
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = .secondarySystemBackground

            let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            view.cornerRadius = newValue.height * 0.15
        })
        return instance
    }()
//    private lazy var imageButton: UIButton = {
//       let instance = UIButton()
//
//        if #available(iOS 15, *) {
//            var config = UIButton.Configuration.plain()
//            config.image = UIImage(systemName: "pencil.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
//            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                guard let self = self else { return .systemGray }
//
//                return self.traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            }
//            config.buttonSize = .large
//
//            instance.configuration = config
//        } else {
//            let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
//                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
//                NSAttributedString.Key.foregroundColor: UIColor.label,
//            ])
//            instance.setAttributedTitle(attrString, for: .normal)
//            instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            instance.titleEdgeInsets.left = 2
////            instance.titleEdgeInsets.right = 8
//            instance.titleEdgeInsets.top = 2
//            instance.titleEdgeInsets.bottom = 2
//            instance.setImage(UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
//            instance.imageView?.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//            instance.imageView?.contentMode = .scaleAspectFit
//            instance.imageEdgeInsets.left = 10
//            instance.imageEdgeInsets.top = 2
//            instance.imageEdgeInsets.bottom = 2
//            instance.imageEdgeInsets.right = 2
//            instance.semanticContentAttribute = .forceRightToLeft
//            instance.backgroundColor = .secondarySystemBackground
//
//            let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
//            constraint.identifier = "width"
//            constraint.isActive = true
//        }
//
//        observers.append(instance.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
//            guard let self = self,
//                  let newValue = change.newValue
//            else { return }
//
//            view.cornerRadius = newValue.height * 0.15
//        })
//        return instance
//    }()
    private lazy var avatar: Avatar = {
        let instance = Avatar(isShadowed: true)
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        instance.clipsToBounds = false
        
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
    private lazy var verticalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [userView, username, horizontalStack])// genderButton, ageButton])
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
        ])
        
        return instance
    }()
    private lazy var horizontalStack: UIStackView = {
        let instance = UIStackView(arrangedSubviews: [genderButton, ageButton])
        instance.axis = .horizontal
//        instance.alignment = .center
        instance.clipsToBounds = false
        instance.spacing = 4
        instance.distribution = .fillProportionally
        
//        userView.translatesAutoresizingMaskIntoConstraints = false
//        username.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            userView.widthAnchor.constraint(equalTo: instance.widthAnchor),
//            userView.heightAnchor.constraint(equalToConstant: 200),
//            username.widthAnchor.constraint(equalTo: instance.widthAnchor),
//        ])
        
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
                    
                self.setupButtons(animated: true)
            }
        })
        
        //Birth date change
        tasks.append( Task {@MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.GenderChanged) {
                guard let self = self,
                      let instance = notification.object as? Userprofile,
                      instance.isCurrent
                else { return }
                    
                self.setupButtons(animated: true)
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
//        } else if v === age {
//            let _ = ageTextField.becomeFirstResponder()
//            guard let date = Userprofiles.shared.current?.birthDate else { return }
//            datePicker.date = date
        }
        Fade.shared.present()
    }
    
    @objc
    private func editAge() {
        Fade.shared.present()
        let _ = ageTextField.becomeFirstResponder()
        guard let date = Userprofiles.shared.current?.birthDate else { return }
        datePicker.date = date
    }
    
    @objc
    private func editImage() {
        
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
        
//        if animated {
//            UIView.transition(with: age, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
//                guard let self = self else { return }
//
//                self.age.text = String(describing: userprofile.age)
//            } completion: { _ in }
//        } else {
//            age.text = String(describing: userprofile.age)
//        }
        
        
//        gender.text = userprofile.gender.rawValue.localized.lowercased() + ","
        
        guard let constraint_1 = username.getConstraint(identifier: "height")
//              let constraint_2 = gender.getConstraint(identifier: "width"),
//              let constraint_3 = age.getConstraint(identifier: "width")
        else { return }
        
        setNeedsLayout()
        constraint_1.constant = username.text!.height(withConstrainedWidth: username.bounds.width, font: username.font)
//        constraint_2.constant = gender.text!.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
//        constraint_3.constant = age.text!.width(withConstrainedHeight: 100, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)!)
        layoutIfNeeded()
    }
    
    private func setupButtons(animated: Bool = false) {
        guard let userprofile = Userprofiles.shared.current else { return }
        
        if #available(iOS 15, *) {
            if !genderButton.configuration.isNil {
                let attrString = AttributedString(userprofile.gender.rawValue.localized.capitalized, attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.label
                ]))
                if animated {
                    UIView.transition(with: genderButton, duration: 0.1, options: .transitionCrossDissolve) {
                        self.genderButton.configuration!.attributedTitle = attrString
                    }
                }else {
                    genderButton.configuration!.attributedTitle = attrString
                }
            }
        } else {
        let attrString = NSMutableAttributedString(string: userprofile.gender.rawValue.localized.capitalized, attributes: [
            NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.label,
        ])
            genderButton.setAttributedTitle(attrString, for: .normal)
            
            guard let constraint = genderButton.getConstraint(identifier: "width"),
                  let userprofile = Userprofiles.shared.current
            else { return }
            
            self.setNeedsLayout()
            constraint.constant = userprofile.gender.rawValue.localized.capitalized.width(withConstrainedHeight: genderButton.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline)!) + genderButton.imageEdgeInsets.left + genderButton.imageEdgeInsets.right + (genderButton.imageView?.bounds.width ?? 0) + genderButton.titleEdgeInsets.left*4
            self.layoutIfNeeded()
        }
        
        if #available(iOS 15, *) {
            if !ageButton.configuration.isNil {
                let attrString = AttributedString("age".localized + ": " + String(describing: userprofile.age), attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor.label
                ]))
                if animated {
                    UIView.transition(with: ageButton, duration: 0.1, options: .transitionCrossDissolve) {
                        self.ageButton.configuration!.attributedTitle = attrString
                    }
                }else {
                    ageButton.configuration!.attributedTitle = attrString
                }
            }
        } else {
            let attrString = NSMutableAttributedString(string: "age".localized + ": " + String(describing: userprofile.age), attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.label,
            ])
            ageButton.setAttributedTitle(attrString, for: .normal)
            
            guard let constraint = ageButton.getConstraint(identifier: "width"),
                  let userprofile = Userprofiles.shared.current
            else { return }
            
            self.setNeedsLayout()
            constraint.constant = ("age".localized + ": " + String(describing: userprofile.age)).width(withConstrainedHeight: ageButton.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .subheadline)!) + ageButton.imageEdgeInsets.left + ageButton.imageEdgeInsets.right + (ageButton.imageView?.bounds.width ?? 0) + ageButton.titleEdgeInsets.left*4
            self.layoutIfNeeded()
        }
    }
    
    @objc
    private func dateSelected() {
        ageTextField.resignFirstResponder()
        Fade.shared.dismiss()
        datePublisher.send(datePicker.date)
    }
    
    private func prepareMenu() -> UIMenu {
        var actions: [UIAction]!
        
        let male: UIAction = .init(title: Gender.Male.rawValue.localized.capitalized, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.genderPublisher.send(Gender.Male)
        })
        
        let female: UIAction = .init(title: Gender.Female.rawValue.localized.capitalized, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .init(), state: .off, handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.genderPublisher.send(Gender.Female)
        })

        
        actions = [male, female]
        
        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: actions)
    }
    
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
//        age.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .title3)
        
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
