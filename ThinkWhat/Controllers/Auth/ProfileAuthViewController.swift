//
//  ProfileViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 20.09.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProfileAuthViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userImage:       UIImageView!
    @IBOutlet weak var continueButton:  UIButton!
    @IBOutlet weak var stackView:       UIStackView!
    @IBOutlet weak var first_nameTF:    UnderlinedTextField!
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
        if first_nameTF.text!.isEmpty {
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
                showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Выберите изображение и заполните поля:\n\(errorText)")
            } else {
                showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Выберите изображение")
            }
        } else {
            if !errorText.isEmpty {
                showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Не заполнены поля:\n\(errorText)")
            } else {
                var userProfile = [String: Any]()
                var owner       = [String: Any]()
                if first_nameTF.text! != AppData.shared.user.firstName {
                    owner[DjangoVariables.User.firstName] = first_nameTF.text!
                }
                if Date(dateString: birthDateTF.text!) != AppData.shared.userProfile.birthDate {
                    userProfile[DjangoVariables.UserProfile.birthDate] = birthDateTF.text!
                }
                if Gender(rawValue: genderTF.text!) != AppData.shared.userProfile.gender {
                    userProfile[DjangoVariables.UserProfile.gender] = genderTF.text!
                }
                if !owner.isEmpty {
                    userProfile["owner"] = owner
                }
                print(userProfile)
                apiManager.updateUserProfile(data: userProfile) {
                    json, error in
                    if error != nil {
                        showAlert(type: .WrongCredentials, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                    }
                    if json != nil {
                        AppData.shared.importUserData(json!)
                        self.performSegue(withIdentifier: kSegueAppFromProfile, sender: nil)
                    }
                }
            }
        }
    }
    fileprivate var isImageChanged = false {
        didSet {
            if isImageChanged {
                var fieldsFilled = true
                for tf in textFields {
                    if tf.text!.isEmpty {
                        fieldsFilled = false
                    }
                }
                if fieldsFilled {UIView.animate(withDuration: 0.2) {self.continueButton.backgroundColor = K_COLOR_RED}}
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
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        setupViews()
        setupGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileAuthViewController.applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileAuthViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileAuthViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        textFields = [first_nameTF, genderTF, birthDateTF]
        for tf in textFields {
            tf.delegate = self
        }
        self.navigationItem.setHidesBackButton(true, animated: false)
        first_nameTF.text         = username
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            self.continueButton.backgroundColor = self.username.count == 0 ? K_COLOR_GRAY : K_COLOR_RED
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
        if !isViewSetupCompleted {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            DispatchQueue.main.async {
                if let imagePath = AppData.shared.userProfile.imagePath {
                    if let image = loadImageFromPath(path: imagePath) {
                        self.circularImage = image.circularImage(size: self.userImage.frame.size)
                        self.userImage.image = self.circularImage
                    }
                } else {
                    let pic = UIImage(named: "default_avatar")!
                    self.circularImage = pic.circularImage(size: self.userImage.frame.size)
                    self.userImage.image = self.circularImage
                }
                if let birthDate = AppData.shared.userProfile.birthDate {
                    self.birthDateTF.text = self.dateFormatter.string(for: birthDate)
                }
                if let gender = AppData.shared.userProfile.gender {
                    self.genderTF.text = gender.rawValue
                }
            }
//            let pic = UIImage(named: "default_avatar")!
//            circularImage = pic.circularImage(size: self.userImage.frame.size)
//            self.userImage.image = circularImage
            self.isViewSetupCompleted = true
            self.continueButton.layer.cornerRadius = self.continueButton.frame.height / 2
            self.continueButton.backgroundColor = K_COLOR_GRAY
        }
        first_nameTF.text = AppData.shared.user.firstName
        birthDateTF.text = dateFormatter.string(for: AppData.shared.userProfile.birthDate)
        genderTF.text = AppData.shared.userProfile.gender.rawValue
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
            let ageToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
            ageToolBar.barStyle = .default
            ageToolBar.tintColor = UIColor.black
            ageToolBar.barTintColor = .white//"4A84BA".hexColor
            ageToolBar.isTranslucent = false
            let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(ProfileAuthViewController.handleDoneButtonTap))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ageToolBar.items = [space, doneButton]
            ageToolBar.barStyle = .default
            birthDateTF.inputAccessoryView            = ageToolBar
            datePicker.addTarget(self, action: #selector(ProfileAuthViewController.handleDateChange), for: .valueChanged)
            birthDateTF.inputView    = datePicker
            let today = Date()
            var tenYears = DateComponents()
            tenYears.year = -10
            let tenYearsAgo = Calendar.current.date(byAdding: tenYears, to: today)
            datePicker.maximumDate = tenYearsAgo
            
        }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        self.dismiss(animated: false, completion: nil)
//        if let image = info[.editedImage] as? UIImage {
//            fullImage = image
//        }
        if let image = info[.editedImage] as? UIImage {
            let imageData = image.jpegData(compressionQuality: 0.8)//UIImageJPEGRepresentation(image, 0.5)!//UIImagePNGRepresentation(image)!
            let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageURL = docDir.appendingPathComponent("profileImage.jpeg")
            try! imageData!.write(to: imageURL)

            if UIImage(contentsOfFile: imageURL.path) != nil {
                let imagePath = imageURL.path
                
                self.apiManager.updateUserProfile(data: ["image" : image]) {
                    json, error in
                    if error != nil {
                        showAlert(type: .Ok, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Ошибка при загрузке изображения")
                    }
                    if json != nil {
                        showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: {self.isImageChanged = true}]], text: "Загружено")
                        AppData.shared.userProfile.imagePath = imageURL.absoluteString
                        if let image = loadImageFromPath(path: AppData.shared.userProfile.imagePath) {
                            self.circularImage = image.circularImage(size: self.userImage.frame.size)
                            self.userImage.image = self.circularImage
                        }
                    }
                }
                
                //NotificationCenter.default.post(name: updateUserImageNotification, object: nil)
            } else {
                let alert = UIAlertController(title: "Ошибка", message: "Изображение не может быть обработано, выберите другое", preferredStyle: UIAlertController.Style.actionSheet)
                alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.destructive, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
                if tf.inputView == datePicker {
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


