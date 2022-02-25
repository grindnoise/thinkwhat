//
//  FillProfileViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Alamofire

class FillProfileViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let model = FillUserModel()
               
        self.controllerOutput = view as? FillUserView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "profile_fill".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isViewLayedOut else { return }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        controllerOutput?.onDidLayout()
    }

    // MARK: - Properties
    var controllerOutput: FillUserControllerOutput?
    var controllerInput: FillUserControllerInput?
    private var isViewLayedOut = false
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()
}

// MARK: - View Input
extension FillProfileViewController: FillUserViewInput {
    func onImageTap() {
            imagePicker.allowsEditing = true
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)//UIAlertController(title: "Выберите источник", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            //let titleAttrString = NSMutableAttributedString(string: "Выберите источник", attributes: semiboldAttrs)
            //alert.setValue(titleAttrString, forKey: "attributedTitle")
        let photo = UIAlertAction(title: "photo_album".localized, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction) in
                self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            })
        photo.setValue(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return UIColor.label
            }
        }, forKey: "titleTextColor")
            alert.addAction(photo)
        let camera = UIAlertAction(title: "camera".localized, style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction) in
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            camera.setValue(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.systemBlue
                default:
                    return UIColor.label
                }
            }, forKey: "titleTextColor")
            alert.addAction(camera)
        let cancel = UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.destructive, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
    }
    
    func onCitySearch(_ name: String) {
        Task {
            await controllerInput?.fetchCity(name)
        }
    }
    
    func validateHyperlink(socialMedia: SocialMedia, hyperlink: String) throws {
        do {
            try controllerInput?.validateHyperlink(socialMedia: socialMedia, hyperlink: hyperlink)
        } catch {
            throw error
        }
    }
    
    func onHyperlinkError() {
        let alert = UIAlertController(title: NSLocalizedString("warning",comment: ""),
                                      message: NSLocalizedString("check_fields", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                      style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Model Output
extension FillProfileViewController: FillUserModelOutput {
    func onFetchCityComplete(_ cities: [City]) {
        Task {
            await MainActor.run {
                controllerOutput?.onCityFetchResults(cities)
            }
        }
    }
    
    func onFetchCityError(_: Error) {
        
    }
}

extension FillProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origImage = info[.editedImage] as? UIImage {
            let resizedImage = origImage.resized(to: CGSize(width: 200, height: 200))
            let imageData = resizedImage.jpegData(compressionQuality: 0.4)
            
            controllerOutput?.onAvatarChange(UIImage(data: imageData!)!)
            
            guard let  url = URL(string: API_URLS.BASE)?.appendingPathComponent(API_URLS.PROFILES + String(describing: UserDefaults.Profile.id) + "/") else { return }
            let multipartFormData = MultipartFormData()
            multipartFormData.append(imageData!, withName: "image", fileName: "\(String(describing: UserDefaults.Profile.id)).\(FileFormat.JPEG.rawValue)", mimeType: "jpg/png")
            
            API.shared.uploadMultipartFormData(url: url, method: .patch, multipartDataForm: multipartFormData) { progress in
                print(progress)
            } completion: { result in
                switch result {
                case .success:
                    do {
                        UserDefaults.Profile.imagePath = try FileIOController.write(data: imageData!, toPath: .Profiles, ofType: .Images, id: String(UserDefaults.Profile.id!), toDocumentNamed: "profile\(NSData(data: imageData!).fileFormat)").absoluteString
                    } catch {
                        showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "Ошибка при загрузке изображения: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    showAlert(type: .Ok, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "Ошибка при загрузке изображения: \(error.localizedDescription)")
                }
            }
            dismiss(animated: true)
        }
    }
}
