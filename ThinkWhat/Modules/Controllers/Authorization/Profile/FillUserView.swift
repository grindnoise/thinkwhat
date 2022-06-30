//
//  FillUserView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class FillUserView: UIView {
    
    deinit {
        print("FillUserView deinit")
    }
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var _scrollView: UIScrollView! {
        didSet {
            _scrollView.delegate = self
        }
    }
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var avatar: Avatar! {
        didSet {
            avatar.delegate = self
            guard let path = UserDefaults.Profile.imagePath,
                  let url = URL(string: path),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                      return
            }
            avatar.image = image
        }
    }
    @IBOutlet weak var firstNameTF: UnderlinedSignTextField! {
        didSet {
            firstNameTF.placeholder = #keyPath(FillUserView.firstNameTF).localized
            firstNameTF.text = UserDefaults.Profile.firstName
            setupTextField(textField: firstNameTF)
        }
    }
    @IBOutlet weak var lastNameTF: UnderlinedTextField! {
        didSet {
            lastNameTF.placeholder = #keyPath(FillUserView.lastNameTF).localized
            lastNameTF.text = UserDefaults.Profile.lastName
            setupTextField(textField: lastNameTF)
        }
    }
    @IBOutlet weak var birthDateTF: UnderlinedSignTextField! {
        didSet {
            birthDateTF.placeholder = #keyPath(FillUserView.birthDateTF).localized
            setupTextField(textField: birthDateTF)
            guard let date = UserDefaults.Profile.birthDate else { return }
            birthDateTF.text = dateFormatter.string(from: date)
        }
    }
    @IBOutlet weak var cityTF: UnderlinedSearchTextField! {
        didSet {
            if let cityName = UserDefaults.Profile.city {
                cityTF.text! = cityName
            }
            cityTF.placeholder = #keyPath(FillUserView.cityTF).localized
            textFields.append(cityTF)
//            let tfWarningColor = UIColor { traitCollection in
//                switch traitCollection.userInterfaceStyle {
//                case .dark:
//                    return UIColor.systemYellow
//                default:
//                    return K_COLOR_RED
//                }
//            }
            let color: UIColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemBlue
                default:
                    return K_COLOR_RED
                }
            }
            cityTF.indicator.color = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .label
                default:
                    return K_COLOR_RED
                }
            }
            cityTF.theme.font = UIFont(name: StringAttributes.Fonts.Style.Regular, size: 17)!
            cityTF.theme.bgColor = .secondarySystemBackground
            cityTF.theme.borderColor = .tertiarySystemBackground
            cityTF.theme.fontColor = .secondaryLabel
            cityTF.theme.subtitleFontColor = .tertiaryLabel
            cityTF.theme.cellHeight = 50
            cityTF.itemSelectionHandler = {item, itemPosition in
                self.cityTF.text = item[itemPosition].title
                guard let _city = item[itemPosition].attachment as? City else { return }
                self.city = _city
            }
            cityTF.delegate = self
            cityTF.tintColor = color
            cityTF.lineWidth = 1.5
            cityTF.activeLineWidth = 1.5
            cityTF.line.layer.strokeColor = color.cgColor
//            guard let underligned = textField as? UnderlinedSignTextField else { return }
//            cityTF.color = tfWarningColor
//            setupTextField(textField: cityTF)
        }
    }
    @IBOutlet weak var genderControl: UISegmentedControl! {
        didSet {
            genderControl.setTitle(Gender.Male.rawValue.localized, forSegmentAt: 0)
            genderControl.setTitle(Gender.Female.rawValue.localized, forSegmentAt: 1)
            genderControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: StringAttributes.FontStyle.Regular.rawValue,
                                                                                      size: 17.0)!],
                                                 for: .normal)
            genderControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                                 for: .selected)
            genderControl.selectedSegmentTintColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .systemBlue
                default:
                    return K_COLOR_RED
                }
            }
            genderControl.selectedSegmentIndex = UserDefaults.Profile.gender == .Female ? 1 : 0
        }
    }
    @IBOutlet weak var hyperlinkTF: UnderlinedSignTextField! {
        didSet {
            hyperlinkTF.placeholder = #keyPath(FillUserView.hyperlinkTF).localized
            setupTextField(textField: hyperlinkTF)
            hyperlinkTF.placeholder = "paste_link".localized
        }
    }
    @IBOutlet weak var facebookLogo: FacebookLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(FillUserView.onProviderTapped(recognizer:)))
            facebookLogo.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var instagramLogo: InstagramLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(FillUserView.onProviderTapped(recognizer:)))
            instagramLogo.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var tikTokLogo: TikTokLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(FillUserView.onProviderTapped(recognizer:)))
            tikTokLogo.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var vkLogo: VKLogo! {
        didSet {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(FillUserView.onProviderTapped(recognizer:)))
            vkLogo.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var hyperlinkActionButton: UIButton! {
        didSet {
            hyperlinkActionButton.setTitle(#keyPath(FillUserView.continueButton).localized, for: .normal)
            hyperlinkActionButton.alpha = 0
        }
    }
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var continueButton:  UIButton! {
        didSet {
            continueButton.setTitle(#keyPath(FillUserView.continueButton).localized, for: .normal)
        }
    }
    
    // MARK: - IB actions
    @IBAction func genderChanged(_ sender: Any) {
        
    }
    @IBAction func touchUpInside(_ sender: Any) {
        hideKeyboard()
    }
    @IBAction func hyperlinkActionButtonTapped(_ sender: Any) {
        
    }
    @IBAction func textFieldEdited(_ sender: UITextField) {
        if sender == hyperlinkTF, !hyperlinkTF.text.isNil, hyperlinkTF.text!.isEmpty {
            hyperlinkTF.hideSign()
        } else if sender == cityTF, let name = cityTF.text, name.count >= 4 {
            cityTF.showLoadingIndicator()
            cityTF.isUserInteractionEnabled = false
            viewInput?.onCitySearch(name)
        }
    }
    @IBAction func continueTapped(_ sender: Any) {
        checkFields()
        guard isCorrect else {
            UIView.animate(withDuration: 0.12, delay: 0, options: []) {
                self.continueButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                UIView.animate(withDuration: 0.12) {
                    self.continueButton.transform = .identity
                }
            }
            return
        }
        guard let image = avatar.image,
              let firstName = firstNameTF.text,
              let lastName = lastNameTF.text,
              !birthDateTF.text.isNil else {
                  fatalError()
              }
        continueButton.setTitle("", for: .normal)
        let indicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                              size: CGSize(width: continueButton.frame.height,
                                                                           height: continueButton.frame.height)))
        indicator.alpha = 0
        indicator.layoutCentered(in: continueButton)
        indicator.startAnimating()
        indicator.color = .white
        UIView.animate(withDuration: 0.2) { indicator.alpha = 1 }
        isUserInteractionEnabled = false
        viewInput?.updateUserprofile(image: isImageChanged ? image : nil,
                                     firstName: firstName,
                                     lastName: lastName,
                                     gender: genderControl.selectedSegmentIndex == 0 ? .Male : .Female,
                                     birthDate: birthDateTF.text!,
                                     city: city,
                                     vkID: nil,
                                     vkURL: links[SocialMedia.VK],
                                     facebookID: nil,
                                     facebookURL: links[SocialMedia.Facebook])
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
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        setupUI()
        if Self.self is KeyboardScrollable.Type {
            perform(Selector("subscribeForKeyboardNotifications"))
        }
        if let fb = UserDefaults.Profile.facebookURL?.absoluteString {
            links[SocialMedia.Facebook] = fb
        }
        if let ig = UserDefaults.Profile.instagramURL?.absoluteString {
            links[SocialMedia.Instagram] = ig
        }
        if let vk = UserDefaults.Profile.vkURL?.absoluteString {
            links[SocialMedia.VK] = vk
        }
        if let tt = UserDefaults.Profile.tiktokURL?.absoluteString {
            links[SocialMedia.TikTok] = tt
        }
    }
    
    override func layoutSubviews() {
        if !continueButton.isNil { continueButton.cornerRadius = continueButton.frame.height/2.25 }
        if !avatar.isNil { avatar.layoutIfNeeded() }
        if !hyperlinkActionButton.isNil { hyperlinkActionButton.cornerRadius = hyperlinkActionButton.frame.height/2.25 }
    }
    
    
    
    // MARK: - Properties
    weak var viewInput: FillUserViewInput?
    private var isCorrect = false
    private var isNameFilled = false {
        didSet {
            if isNameFilled {
                firstNameTF.hideSign()
                if isNameFilled && isBirthDateFilled {
                    isCorrect = true
                }
            } else {
                isCorrect = false
            }
        }
    }
    private let datePicker = UIDatePicker()
    private var isBirthDateFilled = false {
        didSet {
            if isBirthDateFilled {
                birthDateTF.hideSign()
                if isNameFilled && isBirthDateFilled {
                    isCorrect = true
                }
            } else {
                isCorrect = false
            }
        }
    }
    private var isImageChanged = false
    ///Distance in points between `hyperlinkTF` and `hyperlinkActionButton`
    private var distance: CGFloat = .zero
    ///Used to validate `hyperlinkTF.text` designated by provider
    private var social: SocialMedia?
    private var links = [SocialMedia: String]()
    private var city: City? {
        didSet {
            guard !city.isNil else { return }
            viewInput?.onCitySelected(city!)
        }
    }
    
    ///`KeyboardScrollable` protocol properties
    internal var textFields: [UITextField] = [UITextField]()
    internal var keyboardHeight: CGFloat = .zero
    internal var activeTextField: UITextField?
    
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
extension FillUserView: FillUserControllerOutput {
    func onUpdateProfileCompleteWithError() {
        isUserInteractionEnabled = true
        guard !continueButton.isNil, let indicator = continueButton.subviews.filter({ $0.isKind(of: UIActivityIndicatorView.self)}).first as? UIActivityIndicatorView else { return }
        UIView.animate(withDuration: 0.2) {
            indicator.alpha = 0
        } completion: { _ in
            self.isUserInteractionEnabled = true
            indicator.removeFromSuperview()
            self.continueButton.setTitle(#keyPath(FillUserView.continueButton).localized, for: .normal)
        }
    }
    
    func onAvatarChange(_ image : UIImage) {
        isImageChanged = true
        avatar.image = image
    }
    
    func onCityFetchResults(_ cities: [City]) {
        let items: [SearchTextFieldItem] = cities.map { return SearchTextFieldItem(title: $0.name,
                                                                                   subtitle: "\(String(describing: $0.regionName)), \(String(describing: $0.countryName))",
                                                                                   image: nil,
                                                                                   attachment: $0)}
        cityTF.filterItems(items)
        cityTF.stopLoadingIndicator()
        cityTF.isUserInteractionEnabled = true
    }
    
    func onDidLayout() {
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        if #available(iOS 14, *)  {
            datePicker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(handleDateSelected), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.backgroundColor   = .systemBackground
        datePicker.tintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        birthDateTF.inputView = datePicker
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
        toolBar.backgroundColor = .systemBackground
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.superview?.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(FillUserView.handleDateChange))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [space, doneButton]
        toolBar.barStyle = .default
        birthDateTF.inputAccessoryView = toolBar
        let tenYearsAgo = Calendar.current.date(byAdding: DateComponents(year: -10), to: Date())
        datePicker.maximumDate = tenYearsAgo
    }
}

// MARK: - UI Setup
extension FillUserView {
    private func setupUI() {
        continueButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        hyperlinkActionButton.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return K_COLOR_RED
            }
        }
        let touch = UITapGestureRecognizer(target:self, action:#selector(FillUserView.hideKeyboard))
        self.addGestureRecognizer(touch)
        guard let countryCode = UserDefaults.App.countryByIP else { return }
        if countryCode == "RU" {
            facebookLogo.removeFromSuperview()
            instagramLogo.removeFromSuperview()
        }

    }
    
    private func setupTextField(textField: UnderlinedTextField) {
        textFields.append(textField)
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
        textField.lineWidth = 1.5
        textField.activeLineWidth = 1.5
        textField.line.layer.strokeColor = color.cgColor
        guard let underligned = textField as? UnderlinedSignTextField else { return }
        underligned.color = tfWarningColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var tfWarningColor = K_COLOR_RED
        var destinationColor: UIColor!
        let textFields: [UnderlinedTextField] = [firstNameTF, lastNameTF, birthDateTF]//, cityTF]
        switch traitCollection.userInterfaceStyle {
        case .dark:
            destinationColor = UIColor.systemBlue
            tfWarningColor = .systemYellow
        default:
            destinationColor = K_COLOR_RED
        }
        textFields.forEach {
            $0.line.layer.strokeColor = destinationColor.cgColor
            $0.tintColor = destinationColor
            guard let underligned = $0 as? UnderlinedSignTextField else { return }
            underligned.color = tfWarningColor
        }
        cityTF.line.layer.strokeColor = destinationColor.cgColor
        cityTF.tintColor = destinationColor
    }
    
    private func onHyperlinkInteraction(constraint: NSLayoutConstraint, distance: CGFloat) {
        if distance < 0 {
            continueButton.alpha = 0
            hyperlinkActionButton.alpha = 1
        }
        UIView.transition(with: hyperlinkActionButton, duration: 0.15, options: .curveLinear) {
            constraint.constant += distance
            self.hyperlinkActionButton.setTitle(distance > 0 ? #keyPath(FillUserView.continueButton).localized : "save".localized, for: .normal)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: {  _ in
            if distance > 0 {
                self.continueButton.alpha = 1
                self.hyperlinkActionButton.alpha = 0
            }
        }
    }
        
    @objc
    private func onProviderTapped(recognizer: UITapGestureRecognizer) {
        self.hyperlinkTF.becomeFirstResponder()
        Task {
            await MainActor.run {
                guard let senderView = recognizer.view else { return }
                var logo: UIView!
                if senderView == facebookLogo {
                    social = SocialMedia.Facebook
                    logo = FacebookLogo(frame: CGRect(origin: senderView.superview!.convert(senderView.frame.origin, to: scrollContentView), size: senderView.frame.size))
                } else if senderView == instagramLogo {
                    social = SocialMedia.Instagram
                    logo = InstagramLogo(frame: CGRect(origin: senderView.superview!.convert(senderView.frame.origin, to: scrollContentView), size: senderView.frame.size))
                } else if senderView == vkLogo {
                    social = SocialMedia.VK
                    logo = VKLogo(frame: CGRect(origin: senderView.superview!.convert(senderView.frame.origin, to: scrollContentView), size: senderView.frame.size))
                } else if senderView == tikTokLogo {
                    social = SocialMedia.TikTok
                    logo = TikTokLogo(frame: CGRect(origin: senderView.superview!.convert(senderView.frame.origin, to: scrollContentView), size: senderView.frame.size))
                }
                guard !logo.isNil, !social.isNil else { return }
                hyperlinkTF.text = links.filter({ $0.key == social }).values.first ?? ""
                hyperlinkTF.customRightView = senderView.copyView()!
                logo.isOpaque = false
                senderView.alpha = 0
                scrollContentView.addSubview(logo)
                
                guard !hyperlinkTF.rightView.isNil else { return }
                hyperlinkTF.rightView!.alpha = 0
                let destinationOrigin = hyperlinkTF.rightView!.superview!.convert(hyperlinkTF.rightView!.frame.origin, to: scrollContentView)
                let destinationSize = hyperlinkTF.rightView!.frame.size
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                    self.logoStackView.alpha = 0
                } completion: { _ in }
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    logo.frame.origin = destinationOrigin
                    logo.frame.size = destinationSize
                    self.hyperlinkTF.alpha = 1
                } completion: { _ in
                    self.hyperlinkTF.rightView!.alpha = 1
                    logo.removeFromSuperview()
                }
            }
        }
    }
    
    @objc
    private func handleDateChange() {
        birthDateTF.resignFirstResponder()
    }
    
    @objc
    private func handleDateSelected() {
        birthDateTF.text = dateFormatter.string(from: datePicker.date)
    }
}

// MARK: - Text fields handling
extension FillUserView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        onTextFieldActivated(textField)
        if textField == hyperlinkTF {
            Task {
                await MainActor.run {
                    hyperlinkActionButton.getAllConstraints().forEach {
                        guard $0.identifier == "centerY" else { return }
                        distance = (hyperlinkTF.superview!.convert(hyperlinkTF.center, to: scrollContentView).y + hyperlinkTF.frame.height) - hyperlinkActionButton.superview!.convert(hyperlinkActionButton.center, to: scrollContentView).y + 20
                        onHyperlinkInteraction(constraint: $0, distance: distance)
                    }
                }
                //                let modifiedConstraint: NSLayoutConstraint = hyperlinkActionButton.getAllConstraints().filter({ $0.identifier == "top" }).first ?? {
                //                    let constraint = hyperlinkActionButton.topAnchor.constraint(equalTo: textField.bottomAnchor,
                //                                                                                constant: 20)
                //                    constraint.identifier = "top"
//                    return constraint
//                }()
//                onHyperlinkActivated(originalConstraint: $0, modifiedConstraint: modifiedConstraint)
            }
        } else {
            if hyperlinkTF.isFirstResponder {
                return false
            }
        }
        return true
    }
    
    
    @objc
    private func hideKeyboard() {
        if hyperlinkTF.isFirstResponder {
            ///Validate social media URL
            guard let text = hyperlinkTF.text, !social.isNil else {
                viewInput?.onHyperlinkError()
                return
            }
            do {
                if !text.isEmpty {
                    try viewInput?.validateHyperlink(socialMedia: social!, hyperlink: text)
                }
                links[social!] = text
                hyperlinkTF.hideSign()
                print(links)
                
                var logo: UIView!
                guard let destinationLogo = logoStackView.arrangedSubviews.filter({ $0.alpha == 0 }).first,
                      let initialLogo = hyperlinkTF.customRightView else {
#if DEBUG
                          fatalError()
#endif
                          return
                      }
                if initialLogo.isKind(of: FacebookLogo.self) {
                    logo = FacebookLogo(frame: CGRect(origin: initialLogo.superview!.convert(initialLogo.frame.origin, to: scrollContentView), size: initialLogo.frame.size))
                } else if initialLogo.isKind(of: InstagramLogo.self) {
                    logo = InstagramLogo(frame: CGRect(origin: initialLogo.superview!.convert(initialLogo.frame.origin, to: scrollContentView), size: initialLogo.frame.size))
                } else if initialLogo.isKind(of: VKLogo.self) {
                    logo = VKLogo(frame: CGRect(origin: initialLogo.superview!.convert(initialLogo.frame.origin, to: scrollContentView), size: initialLogo.frame.size))
                } else if initialLogo.isKind(of: TikTokLogo.self) {
                    logo = TikTokLogo(frame: CGRect(origin: initialLogo.superview!.convert(initialLogo.frame.origin, to: scrollContentView), size: initialLogo.frame.size))
                }
                guard !logo.isNil else { return }
                logo.isOpaque = false
                initialLogo.alpha = 0
                scrollContentView.addSubview(logo)
                hyperlinkTF.customRightView = nil
                
                let destinationOrigin = destinationLogo.superview!.convert(destinationLogo.frame.origin, to: scrollContentView)
                let destinationSize = destinationLogo.frame.size
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                    logo.frame.origin = destinationOrigin
                    logo.frame.size = destinationSize
                    self.logoStackView.alpha = 1
                    self.hyperlinkTF.alpha = 0
                    self.hyperlinkActionButton.getAllConstraints().forEach {
                        guard $0.identifier == "centerY" else { return }
                        self.onHyperlinkInteraction(constraint: $0, distance: -self.distance)
                    }
                } completion: { _ in
                    destinationLogo.alpha = 1
                    self.hyperlinkTF.rightView!.alpha = 0
                    self.social = nil
                    logo.removeFromSuperview()
                }
                endEditing(true)
            } catch {
                hyperlinkTF.showSign(state: .InvalidHyperlink)
            }
        } else {
            endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === firstNameTF {
            lastNameTF.becomeFirstResponder()
        } else if textField === lastNameTF {
            birthDateTF.becomeFirstResponder()
        } else if textField == hyperlinkTF {
            hideKeyboard()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tf = textField as? UnderlinedSignTextField else { return }
        tf.hideSign()
//        checkTextField(textField)
    }
    
    private func checkFields() {
        if firstNameTF.text!.isEmpty {
            isNameFilled = false
            firstNameTF.showSign(state: .UsernameIsShort)
        } else if firstNameTF.text!.count <= 2 {
            isNameFilled = false
            firstNameTF.showSign(state: .UsernameNotFilled)
        } else {
            isNameFilled = true
        }
        
        if birthDateTF.text!.isEmpty {
            isBirthDateFilled = false
            birthDateTF.showSign(state: .BirthDateIsEmpty)
        } else {
            isBirthDateFilled = true
        }
//        guard let textField = sender as? UnderlinedSignTextField else { return }
//        if textField === firstNameTF {
//            if textField.text!.isEmpty {
//                isNameFilled = false
//                firstNameTF.hideSign()
//            } else if textField.text!.count < 2 {
//                textField.showSign(state: .UsernameIsShort)
//                isNameFilled = false
//            } else {
//                isNameFilled = true
//            }
//        } else if textField === birthDateTF {
//            if textField.text!.isEmpty {
//                textField.showSign(state: .BirthDateIsEmpty)
//                isBirthDateFilled = false
//            } else {
//                firstNameTF.hideSign()
//                isBirthDateFilled = true
//            }
//        }
    }
}

extension FillUserView: KeyboardScrollable {
    var scrollView: UIScrollView {
        get {
            return _scrollView
        }
    }
    
    func findFirstResponder() -> UITextField? {
        return textFields.filter({ $0.isFirstResponder }).first
    }
    
    @objc
    func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func onTextFieldActivated(_ textField: UITextField) {
        activeTextField = textField
        guard let tf = textField as? UnderlinedSignTextField else { return }
        tf.hideSign()
    }
    
    func setScreenInsets(zero: Bool = false) {
        scrollView.isScrollEnabled = true
        if zero {
            scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        } else {
            guard !activeTextField.isNil else { return }
            let tfCoordinate = CGPoint(x: .zero, y: activeTextField!.frame.maxY)
            let convertedPoint = convert(tfCoordinate, from: activeTextField!.superview)
            if convertedPoint.y >= (frame.height - keyboardHeight) {
                let bottomInset = max(convertedPoint.y - keyboardHeight - hyperlinkActionButton.frame.height, keyboardHeight + hyperlinkActionButton.frame.height + 8)// + 28
                scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: abs(bottomInset), right: 0.0)
            }
        }
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if keyboardHeight.isZero {
            guard let userInfo = notification.userInfo,
                  let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
            keyboardHeight = keyboardSize.height
        }
        setScreenInsets()
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        setScreenInsets(zero: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = false
    }
}

extension FillUserView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if (sender as AnyObject).isKind(of: Avatar.self) {
            viewInput?.onImageTap()
        }
    }
}
