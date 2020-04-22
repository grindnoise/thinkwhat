//
//  ProfileViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.09.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProfileAuthViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userImage:       UIImageView!
    @IBOutlet weak var continueButton:  UIButton!
    @IBOutlet weak var stackView:       UIStackView!
    @IBOutlet weak var firstNameTF:    UnderlinedTextField!
//    @IBOutlet weak var last_nameTF:     UnderlinedTextField!
    @IBOutlet weak var birthDateTF:     UnderlinedTextField!
    @IBOutlet weak var genderTF:        UnderlinedTextField!
    
    @IBAction func textFieldEdited(_ sender: UnderlinedTextField) {
        if sender.text!.isEmpty {
            UIView.animate(withDuration: 0.2) {self.continueButton.backgroundColor = K_COLOR_GRAY}
        } else {
            var fieldsFilled = true
            if isImageChanged {
                for tf in textFields {
                    if sender != tf {
                        if tf.text!.isEmpty {
                            fieldsFilled = false
                        }
                    }
                }
            }
            if fieldsFilled {UIView.animate(withDuration: 0.2) {self.continueButton.backgroundColor = K_COLOR_RED}}
        }
//        continueButton.backgroundColor = sender.text!.count == 0 ? K_COLOR_GRAY : K_COLOR_RED
    }
    @IBAction func continueTapped(_ sender: UIButton) {
        var errorText = ""
        if firstNameTF.text!.isEmpty {
            errorText += "- имя\n"
        }
        if birthDateTF.text!.isEmpty {
            errorText += "- возраст\n"
        }
        if genderTF.text!.isEmpty {
            errorText += "- пол\n"
        }
        if !isImageChanged {
            if !errorText.isEmpty {
                showAlert(type: .WrongCredentials, buttons: [["Ясно": [CustomAlertView.ButtonType.Ok: nil]]], text: "Выберите изображение и заполните поля:\n\(errorText)")
            } else {
                showAlert(type: .WrongCredentials, buttons: [["Ясно": [CustomAlertView.ButtonType.Ok: nil]]], text: "Выберите изображение")
            }
        } else {
            if !errorText.isEmpty {
                showAlert(type: .WrongCredentials, buttons: [["Ясно": [CustomAlertView.ButtonType.Ok: nil]]], text: "Не заполнены поля:\n\(errorText)")
            } else {
                var userProfile = [String: Any]()
                var owner       = [String: Any]()
                
                var lastName = ""
                let separated = firstNameTF.text!.split(separator: " ")
                separated.enumerated().map {
                    (index, value) in
                    if index == 0 {
                        if String(value) != AppData.shared.user.firstName {
                            owner[DjangoVariables.User.firstName] = String(value)
                        }
                    } else {
                        lastName += lastName.isEmpty ? String(value) : " \(String(value))"
                    }
                }
                
                if lastName != AppData.shared.user.lastName {
                    owner[DjangoVariables.User.lastName] = lastName
                    
                }
                
                if Date(dateString: birthDateTF.text!) != AppData.shared.userProfile.birthDate {
                    userProfile[DjangoVariables.UserProfile.birthDate] = birthDateTF.text!
                }
                if Gender(rawValue: dataModel[genderTF.text!]!) != AppData.shared.userProfile.gender {
                    userProfile[DjangoVariables.UserProfile.gender] = dataModel[genderTF.text!]//allKeys(forValue: genderTF.text!).first!
                }
                if !owner.isEmpty {
                    userProfile["owner"] = owner
                }
                if userProfile.isEmpty {
                    performSegue(withIdentifier: Segues.Auth.AppFromProfile, sender: nil)
                } else {
                    showAlert(type: .Loading, buttons: [nil], text: "Вход в систему..")
                    apiManager.updateUserProfile(data: userProfile) {
                        json, error in
                        if error != nil {
                            showAlert(type: .WrongCredentials, buttons: [["Хорошо": [CustomAlertView.ButtonType.Ok: nil]]], text: error!.localizedDescription)
                        }
                        if json != nil {
                            AppData.shared.importUserData(json!)
                            hideAlert()
                            self.performSegue(withIdentifier: Segues.Auth.AppFromProfile, sender: nil)
                        }
                    }
                }
            }
        }
    }
    fileprivate var isImageChanged = false {
        didSet {
            if isImageChanged {
                UIView.animate(withDuration: 0.2) {self.continueButton.backgroundColor = self.checkFieldsFilled()}
            }
        }
    }
    private var isViewReady             = false
    private var circularImage:          UIImage!
    private var isViewSetupCompleted    = false
    private var selectedImage:          UIImage?
    private var imagePicker             = UIImagePickerController()
    var phoneNumber:                    String!
    var username                        = ""
    var paragraphStyle: NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
    private lazy var apiManager:   APIManagerProtocol = self.initializeServerAPI()
    private lazy var storeManager: FileStorageProtocol = self.initializeStorageManager()
    private let normalAttrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 17),
                                   NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                   NSAttributedString.Key.backgroundColor: UIColor.clear]
    private var semiboldAttrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 17),
                                     NSAttributedString.Key.foregroundColor: UIColor.black,
                                     NSAttributedString.Key.backgroundColor: UIColor.clear]//,
    //                                   .paragraphStyle: paragraphStyle]
    private var kbHeight:           CGFloat!
    private var isMovedUp:          Bool?
    private var textFields          = [UnderlinedTextField]()
    private var offsetY:            CGFloat                     = 0
    private let datePicker          = UIDatePicker()
    private let genderPicker        = UIPickerView()
    private let dataModel = ["мужской": "Male", "женский": "Female"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        setupDelegates()
        setupViews()
        setupGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileAuthViewController.applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileAuthViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileAuthViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        firstNameTF.text         = username
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupDelegates() {
        textFields = [firstNameTF, genderTF, birthDateTF]
        for tf in textFields {
            tf.delegate = self
        }
    }
    
    private func setupViews() {
        semiboldAttrs     = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 17),
                             NSAttributedString.Key.foregroundColor: K_COLOR_GRAY,
                             NSAttributedString.Key.backgroundColor: UIColor.clear,
                             NSAttributedString.Key.paragraphStyle:  paragraphStyle]
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            //            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
    }
    
    private func setupGestures() {
        DispatchQueue.main.async {
            let touch = UITapGestureRecognizer(target:self, action:#selector(ProfileAuthViewController.hideKeyboard))
            self.view.addGestureRecognizer(touch)
            let touch2 = UITapGestureRecognizer(target:self, action:#selector(ProfileAuthViewController.setUserImage(sender:)))
            self.userImage.addGestureRecognizer(touch2)
            self.imagePicker.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            if let imagePath = AppData.shared.userProfile.imagePath {
                if let image = loadImageFromPath(path: imagePath) {
                    circularImage = image.circularImage(size: userImage.frame.size, frameColor: K_COLOR_RED)
                    userImage.image = circularImage
                    isImageChanged = true
                }
            } else {
                let pic = UIImage(named: "default_avatar")!
                circularImage = pic.circularImage(size: userImage.frame.size, frameColor: K_COLOR_RED)
                userImage.image = circularImage
            }
            if let firstName = AppData.shared.user.firstName {
                firstNameTF.text = firstName
            }
            if let lastName = AppData.shared.user.lastName {
                firstNameTF.text = "\(String(describing: firstNameTF.text!)) \(lastName)"
            }
            if let birthDate = AppData.shared.userProfile.birthDate {
                let strDate = dateFormatter.string(for: birthDate)
                birthDateTF.text = strDate == "01.01.0001" ? "" : strDate
            }
            if let gender = AppData.shared.userProfile.gender {
                genderTF.text = dataModel.allKeys(forValue: gender.rawValue).first
            }
//            let pic = UIImage(named: "default_avatar")!
//            circularImage = pic.circularImage(size: self.userImage.frame.size)
//            self.userImage.image = circularImage
            isViewSetupCompleted = true
            continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
        }
        continueButton.backgroundColor = self.checkFieldsFilled()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UIView.animate(withDuration: 0.2) {self.continueButton.backgroundColor = self.checkFieldsFilled()}
    }
    
    override func viewDidLayoutSubviews() {
        if !isViewReady {
            view.setNeedsLayout()
//            let yPoint = view.convert(CGPoint(x: userImage.frame.maxX, y: userImage.frame.maxY), to: view).y
//            let height = (view.frame.height - yPoint - stackView.frame.height - continueButton.frame.height) / 3
//            topConstraint_1.constant = height
//            topConstraint_2.constant = height
//            view.setNeedsLayout()
            isViewReady = true
            datePicker.datePickerMode    = .date
            datePicker.backgroundColor   = .white//"4A84BA".hexColor
            datePicker.setValue(K_COLOR_GRAY, forKeyPath: "textColor")
            if let pickerView = datePicker.subviews.first {
                
                for subview in pickerView.subviews {
                    
                    if subview.frame.height <= 10 {
                        
                        subview.backgroundColor = UIColor.white
                        subview.tintColor = UIColor.white
                        subview.layer.borderColor = K_COLOR_GRAY.cgColor
                        subview.layer.borderWidth = 0.5
                    }
                }
                datePicker.setValue(K_COLOR_GRAY, forKey: "textColor")
            }
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
            toolBar.barStyle = .default
            toolBar.tintColor = K_COLOR_RED//UIColor.black
            toolBar.barTintColor = .white//"4A84BA".hexColor
            toolBar.isTranslucent = false
            let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(ProfileAuthViewController.handleDoneButtonTap))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolBar.items = [space, doneButton]
            toolBar.barStyle = .default
            birthDateTF.inputAccessoryView            = toolBar
            datePicker.addTarget(self, action: #selector(ProfileAuthViewController.handleDateChange), for: .valueChanged)
            birthDateTF.inputView    = datePicker
            let today = Date()
            var tenYears = DateComponents()
            tenYears.year = -10
            let tenYearsAgo = Calendar.current.date(byAdding: tenYears, to: today)
            datePicker.maximumDate = tenYearsAgo
            
            genderTF.inputView = genderPicker
            genderTF.inputAccessoryView = toolBar
            genderPicker.backgroundColor   = .white//"4A84BA".hexColor
            genderPicker.setValue(K_COLOR_GRAY, forKeyPath: "textColor")
            genderPicker.delegate   = self
            genderPicker.dataSource = self 
        }
    }
    
    @objc fileprivate func handleGenderTap(gesture: UITapGestureRecognizer) {
        
        if gesture.state == .ended {
            let rowHeight = genderPicker.rowSize(forComponent: 0).height
            let selectedRowFrame: CGRect = self.genderPicker.bounds.insetBy(dx: 0.0, dy: (self.genderPicker.frame.height - rowHeight) / 2.0 )
            let userTappedOnSelectedRow = (selectedRowFrame.contains(gesture.location(in: genderPicker)))
            
            
            if (userTappedOnSelectedRow) {
                let selectedRow = genderPicker.selectedRow(inComponent: 0)
                genderTF.text = Array(dataModel)[selectedRow].key
                genderTF.resignFirstResponder()
            }
            
        }
    }
    private func checkFieldsFilled() -> UIColor {
        var color = K_COLOR_RED
        for tf in textFields {
            if tf.text!.isEmpty {
                color = K_COLOR_GRAY
            }
        }
        return color
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func setUserImage(sender: UITapGestureRecognizer) {
        imagePicker.allowsEditing = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        //        let titleAttrString = NSMutableAttributedString(string: "Выберите источник", attributes: semiboldAttrs)
        //        alert.setValue(titleAttrString, forKey: "attributedTitle")
        let photo = UIAlertAction(title: "Фотоальбом", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        photo.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(photo)
        let camera = UIAlertAction(title: "Камера", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction) in
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        camera.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(camera)
        let cancel = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.destructive, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField === firstNameTF {
            birthDateTF.becomeFirstResponder()
        }
        
        return true
    }
    
    private func findFirstResponder() -> UITextField? {
        
        for textField in textFields {
            if textField.isFirstResponder {
                return textField
            }
        }
        return nil
    }
    
    func textFieldIsAboveKeyBoard(_ textField: UITextField?) -> Bool {
        
        var activeTextField: UITextField?
        if textField != nil {
            activeTextField = textField
        } else {
            activeTextField = findFirstResponder()
        }
        
        if (activeTextField != nil) {
            
            let tfPoint = CGPoint(x: activeTextField!.frame.minX, y: activeTextField!.frame.maxY * 1.5)
            let convertedPoint = view.convert(tfPoint, from: activeTextField?.superview)
            
            
            if convertedPoint.y <= (view.frame.height - kbHeight) {
                return true
            } else {
                offsetY = -(view.frame.height - kbHeight - convertedPoint.y) + 15 //+ (activeTextField?.bounds.height)! / 2
            }
        }
        
        return false
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if (isMovedUp == nil) || isMovedUp == false {
                    kbHeight = keyboardSize.height
                    if !textFieldIsAboveKeyBoard(nil) {
                        self.moveTextField(true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isMovedUp != nil {
            if isMovedUp! {
                self.moveTextField(false)
            }
        }
    }
    
    @objc private func applicationWillResignActive(notification: NSNotification) {
        view.endEditing(true)
        if isMovedUp != nil {
            if isMovedUp! {
                moveTextField(false)
            }
        }
    }
    
    @objc private func handleDateChange() {
        birthDateTF.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc private func handleDoneButtonTap() {
        
        for tf in textFields {
            if tf.isFirstResponder {
                if tf.inputView == genderPicker {
                    genderTF.text = Array(dataModel)[genderPicker.selectedRow(inComponent: 0)].key
                } else if tf.inputView == datePicker {
                    birthDateTF.text = dateFormatter.string(from: datePicker.date)
                }
                tf.resignFirstResponder()
                break
            }
        }
    }
    
    private func moveTextField(_ up: Bool) {
        let movement = (up ? -offsetY : offsetY)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y += movement
            if up {
                self.isMovedUp = true
            } else {
                self.isMovedUp = false
            }
        })
    }
}

extension ProfileAuthViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return (self.navigationController as! AuthNavigationController).apiManager
    }
}

extension ProfileAuthViewController: StorageInitializationProtocol {
    func initializeStorageManager() -> FileStorageProtocol {
        return (self.navigationController as! AuthNavigationController).storeManager
    }
}

extension ProfileAuthViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPicker {
            return Array(dataModel)[row].key
        }
        else {
            return "1"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == genderPicker {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPicker {
            return dataModel.count
        } else {
            return 10
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if pickerView == genderPicker {
            let string = Array(dataModel)[row].key
            
            return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: K_COLOR_GRAY])
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPicker {
            genderTF.text = Array(dataModel)[row].key
        }
    }
}

extension ProfileAuthViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let resizedImage = origImage.resized(to: CGSize(width: 200, height: 200))
            let imageData = resizedImage.jpegData(compressionQuality: 0.4)
            let image = UIImage(data: imageData!)
            
            self.apiManager.updateUserProfile(data: ["image" : image]) {
                json, error in
                if error != nil {
                    showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "Ошибка при загрузке изображения: \(error!.localizedDescription)")
                }
                if json != nil {
                    AppData.shared.userProfile.imagePath = self.storeManager.storeImage(type: .Profile, image: image!, fileName: nil, fileFormat: NSData(data: image!.jpeg!).fileFormat, surveyID: nil)
                    showAlert(type: .Warning, buttons: [["Готово": [CustomAlertView.ButtonType.Ok: {
                        self.isImageChanged = true
                        self.circularImage = image!.circularImage(size: self.userImage.frame.size, frameColor: K_COLOR_RED)
                        animateImageChange(imageView: self.userImage, fromImage: self.userImage.image!, toImage: self.circularImage, duration: 0.2)
                        }]]], text: "Загружено")
                }
            }
        }
        dismiss(animated: true)
    }
}

