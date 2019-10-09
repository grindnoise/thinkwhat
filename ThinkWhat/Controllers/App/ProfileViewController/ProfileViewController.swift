//
//  ProfileViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 04.10.2019.
//  Copyright © 2019 Pavel Bukharov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    
    private var circularImage: UIImage!
    private var isViewSetupCompleted = false
    private let settingsVC: ProfileSettingsTableViewController = {
        let storyboard = UIStoryboard(name: "App", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileSettingsTableViewController") as! ProfileSettingsTableViewController
        return vc
    } ()
//    public var state: ClientSettingsMode!
    internal lazy var apiManager: APIManagerProtocol = self.initializeServerAPI()
    private var locale: String      = "en-US"
    private lazy var serverAPI:     APIManagerProtocol = initializeServerAPI()
    private var selectedImage:      UIImage?
    private var imagePicker         = UIImagePickerController()
    private var isKeyboardShown     = false
    
    private let normalAttrs         = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Light", size: 17),
                                       NSAttributedString.Key.foregroundColor: K_COLOR_RED,
                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
    private var semiboldAttrs       = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Semibold", size: 17),
                                       NSAttributedString.Key.foregroundColor: UIColor.black,
                                       NSAttributedString.Key.backgroundColor: UIColor.clear]
    
    //    deinit {
    //        NotificationCenter.default.removeObserver(self)
    //    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    override func viewDidLayoutSubviews() {
        container.setNeedsLayout()
        container.layoutIfNeeded()
        if !isViewSetupCompleted {
            self.userImage.image = circularImage
            self.isViewSetupCompleted = true
        }
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationItem.backBarButtonItem                    = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        
        DispatchQueue.main.async {
            var image = UIImage()
            if AppData.shared.userProfile.imagePath != nil {
                if let imageFromAppData = loadImageFromPath(path: AppData.shared.userProfile.imagePath) {
                    image = imageFromAppData
                }
            } else {
                image = UIImage(named: "default_avatar")!
            }
            self.circularImage     = image.circularImage(size: self.userImage.frame.size)
            self.usernameTF.text   = AppData.shared.user.username
//            self.phoneTF.text      = appData.phone
        }
        
        DispatchQueue.main.async {
            print(AppData.shared.user.firstName)
            self.usernameTF.text = AppData.shared.user.firstName// + " \(AppData.shared.user.lastName)"
            print(AppData.shared.userProfile.birthDate)
            print(AppData.shared.userProfile.gender)
            print(AppData.shared.user.firstName)
            print(AppData.shared.user.ID)
            self.genderTF.text = "\(yearsBetweenDate(startDate: AppData.shared.userProfile.birthDate, endDate: Date())), \(AppData.shared.userProfile.gender.rawValue)"
        }

        
        DispatchQueue.main.async {
            self.addChild(self.settingsVC)
            self.settingsVC.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.width, height: self.container.frame.height)
            self.settingsVC.view.addEquallyTo(to: self.container)
            self.settingsVC.didMove(toParent: self)
            self.imagePicker.delegate = self
        }
    }
    
    private func setupGestures() {
        let touch = UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.hideKeyboard))
        touch.cancelsTouchesInView = false
        view.addGestureRecognizer(touch)
        let touch2 = UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.setUserImage(sender:)))
        self.userImage.addGestureRecognizer(touch2)
    }
    
    @objc private func hideKeyboard() {
        if isKeyboardShown {
            view.endEditing(true)
        }
    }
    
    @objc private func setUserImage(sender: UITapGestureRecognizer) {
        imagePicker.allowsEditing = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)//UIAlertController(title: "Выберите источник", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //let titleAttrString = NSMutableAttributedString(string: "Выберите источник", attributes: semiboldAttrs)
        //alert.setValue(titleAttrString, forKey: "attributedTitle")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC: ProfileSettingsTableViewController = segue.destination as? ProfileSettingsTableViewController {
//            destinationVC.state = state
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
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
                AppData.shared.userProfile.imagePath = imageURL.path
                if let image = loadImageFromPath(path: AppData.shared.userProfile.imagePath) {
                    circularImage = image.circularImage(size: self.userImage.frame.size)
                    self.userImage.image = circularImage
                    //                    isImageChanged = true
                }
                self.apiManager.updateUserProfile(data: ["image" : image]) {
                    json, error in
                    if error != nil {
                        showAlert(type: .Ok, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Ошибка при загрузке изображения")
                    }
                    if json != nil {
                        showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Загружено")
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
}

extension ProfileViewController: UITextFieldDelegate {

}

extension ProfileViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).apiManager
    }
}

extension ProfileViewController: StorageInitializationProtocol {
    func initializeStorageManager() -> FileStorageProtocol {
        return ((self.navigationController as! NavigationControllerPreloaded).parent as! TabBarController).storeManager
    }
}


