//
//  AuthViewController.swift
//  Burb
//
//  Created by Pavel Bukharov on 24.03.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import VK_ios_sdk
import SwiftyJSON
import Alamofire
import simd

class AuthViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var vkButton:                    VKButtonView!
    @IBOutlet weak var mailButton:                  MailButtonView!
    @IBOutlet weak var fbButton:                    FacebookButtonView!
    private var buttons:                            [LoginButton] = []
    private var selectedAuth:                       Int = 0
    private var fbLoggedIn                          = false
    private var isViewSetupCompleted                = false
    private var vk_sdkInstance:                     VKSdk!
//    private lazy var apiManager:   APIManagerProtocol = self.initializeServerAPI()
    private lazy var storeManager: FileStorageProtocol = self.initializeStorageManager()
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupViews()
        //        appDelegate.window?.rootViewController = self
        vk_sdkInstance  = VKSdk.initialize(withAppId: VK_IDS.APP_ID)
        vk_sdkInstance.register(self as VKSdkDelegate)
        vk_sdkInstance.uiDelegate = self as VKSdkUIDelegate
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationController?.navigationBar.tintColor       = .black
            self.buttons = [self.fbButton, self.vkButton, self.mailButton]
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            for button in self.buttons {
                let tap = UITapGestureRecognizer(target: self, action: #selector(AuthViewController.handleTap(gesture:)))
                button.addGestureRecognizer(tap)
            }
            
            
            
            //            notificationCenter.addObserver(self,
            //                                           selector: #selector(AuthViewController.handleTokenStateConnectionError),
            //                                           name: kNotificationTokenConnectionError,
            //                                           object: nil)
            //            notificationCenter.addObserver(self,
            //                                           selector: #selector(AuthViewController.handleReachabilitySignal),
            //                                           name: kNotificationApiNotReachable,
            //                                           object: nil)
        }
        
    }
    
//    func setupProviderLoginView() {
//        let authorizationButton = ASAuthorizationAppleIDButton()
//        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
//        self.loginProviderStackView.addArrangedSubview(authorizationButton)
//    }
//
//    @objc func handleAuthorizationAppleIDButtonPress() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(AuthViewController.getUserDataFromProvider),
                                       name: Notifications.OAuth.TokenReceived,
                                       object: nil)
//        notificationCenter.addObserver(self,
//                                       selector: #selector(AuthViewController.handleTokenState),
//                                       name: Notifications.OAuth.TokenConnectionError,
//                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(AuthViewController.getUserDataFromProvider),
                                       name: Notifications.OAuth.TokenError,
                                       object: nil)
        if !isViewSetupCompleted {
            //            self.phoneButton.layer.cornerRadius = self.phoneButton.frame.height / 2
            //            self.isViewSetupCompleted = true
            //            self.phoneButtonTmp.backgroundColor = K_COLOR_RED
            //            self.phoneButton.backgroundColor = K_COLOR_RED
        }
        for button in buttons {
            button.state = .disabled
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        selectedAuth = 1
//        delay(seconds: 2) { self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil) }
//    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AuthViewController.showTermsOfUse(gesture:)))
        termsOfUseButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func showTermsOfUse(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            performSegue(withIdentifier: Segues.Auth.Terms, sender: nil)
        }
    }
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        var selectedIndex = 0
        if let view = gesture.view {
            selectedIndex = view.tag
            if selectedIndex == 3 {
                (view as! MailButtonView).state = .enabled
            } else if selectedIndex == 2 {
                (view as! VKButtonView).state = .enabled
            } else if selectedIndex == 1 {
                (view as! FacebookButtonView).state = .enabled
            }
            //            } else if selectedIndex == 4 {
            //                (view as! VKButton).state = .enabled
            //            }
            
            selectedAuth = selectedIndex
            for button in buttons {
                if button.tag == selectedIndex {
                    continue
                }
                if button is VKButtonView {
                    (button as! VKButtonView).state = .disabled
                } else if button is MailButtonView {
                    (button as! MailButtonView).state = .disabled
                }
            }
        }
        delay(seconds: 0.03) {
            let authCase = self.getAuthCase()
            switch authCase {
            case .Facebook:
                //                self.isLoadingViewVisible = true
                //                showAlert(type: .Loading, buttons: nil, text: "Вход в систему..")
                if AccessToken.current == nil || AccessToken.current!.expirationDate < Date() {
                    FBManager.performLogin(viewController: self) { success in
                        if success {
                            delay(seconds: 0.2) {
                                showAlert(type: .Loading, buttons: [nil], text: "Вход в систему..")
                            }
                            guard let token = AccessToken.current?.tokenString else { fatalError() }
                            API.shared.loginViaProvider(provider: .Facebook, token: token) { result in
                                switch result {
                                case .success:
                                    NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
                                case .failure(let error):
                                    
                                    NotificationCenter.default.post(name: Notifications.OAuth.TokenError, object: nil)
                                }
                            }
                        } else {
                            //TODO: - Throw alert
                            //showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Facebook login ERROR")
                            fatalError("Facebook login ERROR")
                        }
                    }
                } else {
                    guard let token = AccessToken.current?.tokenString else { fatalError() }
                    API.shared.loginViaProvider(provider: .Facebook, token: token) { result in
                        switch result {
                        case .success:
                            NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
                        case .failure(let error):
                            print(error)
                            NotificationCenter.default.post(name: Notifications.OAuth.TokenError, object: nil)
                        }
                    }
                }
            case .VK:
                let scope = ["email"]
                VKSdk.wakeUpSession(scope) {
                    state, error in
                    if error != nil {
                        print(error.debugDescription)
                    }
//                    print(state.rawValue)
                    if state != VKAuthorizationState.authorized {
                        VKSdk.authorize(scope)
                    } else {
                        delay(seconds: 0.2) {
                            showAlert(type: .Loading, buttons: [nil], text: "Вход в систему..")
                        }
                        guard let token = VKSdk.accessToken()?.accessToken else { fatalError() }
                        API.shared.loginViaProvider(provider: .VK, token: token) { result in
                            switch result {
                            case .success:
                                NotificationCenter.default.post(name: Notifications.OAuth.TokenReceived, object: nil)
                            case .failure(let error):
                                print(error)
                                NotificationCenter.default.post(name: Notifications.OAuth.TokenError, object: nil)
                            }
                        }
                    }
                }
            case .Mail:
                self.performSegue(withIdentifier: Segues.Auth.MailAuth, sender: nil)
                
                
                //                DispatchQueue.main.async {
                //                    VKSdk.forceLogout()
                //                }
                //                DispatchQueue.main.async {
                //                    self.apiManager.logout() {
                //                        state in
                //                        tokenState = state
                //                    }
                //                }
                
                
                //                if AccessToken.current != nil {
                //                    FBManager.performLogout()
                //                }
                //                self.apiManager.logout() {
                //                    state in
                //                    tokenState = state
                //                }
            default:
                print("")
            }
        }
    }
    
    
    private func getAuthCase() -> AuthProvider {
        switch selectedAuth {
        case 2:
            return .VK
        case 3:
            return .Mail
        case 1:
            return .Facebook
        default:
            fatalError("\(selectedAuth) selectedAuth not found")
        }
    }
    
    @objc private func getUserDataFromProvider() {
        var imagePath: String?
        API.shared.getUserData { result in
            switch result {
            case .success(let json):
                AppData.shared.profile.id = json["id"].int
                let auth = self.getAuthCase()
                API.shared.getProfileNeedsSocialUpdate { resultNeedsSocialUpdate in
                    switch resultNeedsSocialUpdate {
                    case .success(let needsUpdateFromSocialMedia):
                        if needsUpdateFromSocialMedia {
                            switch auth {
                            case .Facebook:
                                FBManager.getUserData() {
                                    response in
                                    guard var json = response,
                                          var fbData = json.dictionaryObject,
                                          let pictureData = JSON(fbData.removeValue(forKey: "picture") as Any) as? JSON,
                                          let is_silhouette = pictureData["data"]["is_silhouette"].bool else {
                                              AppData.shared.eraseData()
                                              hideAlert()
                                              return }
                                    if !is_silhouette {
                                        guard let pictureURL = URL(string: pictureData["data"]["url"].string!) else {
                                                  AppData.shared.eraseData()
                                                  hideAlert()
                                                  return }
                                        API.shared.downloadFile(url: pictureURL) { progress in
                                            print("Downloading FB avatar: \(progress)")
                                        } completion: { pictureDownload in
                                            switch pictureDownload {
                                            case .success(let data):
                                                guard let image = UIImage(data: data) else {
                                                    AppData.shared.eraseData()
                                                    hideAlert()
                                                    return
                                                }
                                                var fileFormat: FileFormat = FileFormat.Unknown
                                                if image.png != nil {
                                                    fileFormat = .PNG
                                                } else if image.jpeg != nil {
                                                    fileFormat = .JPEG
                                                }
                                                imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: fileFormat, surveyID: nil)
                                                fbData["image"] = image
                                                API.shared.updateUserprofile(data: FBManager.prepareUserData(fbData)) { uploadProgress in
                                                    print(uploadProgress)
                                                } completion: { result in
                                                    switch result {
                                                    case .success(let json):
                                                        AppData.shared.importUserData(json, imagePath)
                                                        self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
                                                    case .failure(let error):
                                                        AppData.shared.eraseData()
                                                        hideAlert()
                                                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                                                    }
                                                }
                                            case .failure(let error):
                                                AppData.shared.eraseData()
                                                hideAlert()
                                                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                                            }
                                        }
                                    }
                                }
                            case .VK:
                                print("")
//                                VKManager.getUserData() { vkResult in
//                                    switch vkResult {
//                                    case .success(let vkJson):
//                                        guard var vkData = json.dictionaryObject?["response"] else { return }
//                                        guard let vkImage = json.dictionaryObject?.removeValue(forKey: "picture") as? JSON else { return }
//
//
//
//                                        
//                                        if let array = vkJson.dictionaryObject!["response"] {
//                                            if array is Array<[String: Any]> {
//                                                let dict = array as! Array<[String: Any]>
//                                                var vkData = [String: Any]()
//                                                if dict.count != 0 { vkData = dict.first! }
//                                                if let pictureKey = dict.first?.keys.filter( { $0.lowercased().contains("photo")} ).first, let value = vkData[pictureKey] as? String {
//                                                    if let pictureURL = URL(string: value) {
//                                                        AF.request(pictureURL).responseData { response in
//                                                            switch response.result {
//                                                            case .success(let data):
//                                                                if let image = UIImage(data: data) {
//                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
//                                                                    vkData["image"] = image
//                                                                    vkData.removeValue(forKey: pictureKey)
//                                                                    let data = VKManager.prepareUserData(vkData)
//                                                                    API.shared.updateUserProfile(data: data) {
//                                                                        response, error in
//                                                                        if error != nil {
//                                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                                        }
//                                                                        if response != nil {
//                                                                            AppData.shared.importUserData(response!, imagePath)
//                                                                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                                        }
//                                                                    }
//                                                                }
//                                                            case .failure(let error):
//                                                                print(error.localizedDescription)
//                                                            }
//                                                        }
//                                                    }
//                                                } else {
//                                                    API.shared.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
//                                                        response, error in
//                                                        if error != nil {
//                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                        }
//                                                        if response != nil {
//                                                            AppData.shared.importUserData(response!)
//                                                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    case .failure(let vkError):
//                                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: vkError.localizedDescription)
//                                    }
//                                }
                            default:
                                print("")
                            }
                        } else {
                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
                        }
                    case .failure(let error):
                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
                    }
                }
            case .failure(let error):
                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
            }
        }
    }
                        

//
//
//                                                        AF.request(pictureURL).responseData { response in
//                                                            switch response.result {
//                                                            case .success(let data):
//                                                                if let image = UIImage(data: data) {
//                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
//                                                                    fbData["image"] = image
//                                                                    let data = FBManager.prepareUserData(fbData)
//                                                                    API.shared.updateUserprofile(data: data, uploadProgress: { progress in
//                                                                        print(progress)
//                                                                    }) { result in
//                                                                        switch result {
//
//                                                                        }
//
//                                                                            AppData.shared.importUserData(json!, imagePath)
//                                                                            DispatchQueue.main.async {
//                                                                                self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                                            }
//                                                                        }
//                                                                    }
//                                                                }
//                                                            case .failure(let error):
//                                                                print(error.localizedDescription)
//                                                            }
//                                                        }
//                                                    } else {
//                                                        print(pictureData["data"]["url"].error!)
//                                                    }
//                                                }
//                                            }
//                                        } else {
//                                            API.shared.updateUserProfile(data: FBManager.prepareUserData(fbData)) {
//                                                json, error in
//                                                if error != nil {
//                                                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                }
//                                                if json != nil {
//                                                    AppData.shared.importUserData(json!)
//                                                    self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//
//                            case .VK:
//                                API.shared.getProfileNeedsUpdate() {
//                                    if $1 != nil {
//                                        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: $1!.localizedDescription)
//                                    } else if $0 == true {
//                                        VKManager.getUserData() {
//                                            response, error in
//                                            if error != nil {
//                                                print(error!.localizedDescription)
//                                                return
//                                            }
//
//                                            if response != nil {
//                                                if let array = response!.dictionaryObject!["response"] {
//                                                    if array is Array<[String: Any]> {
//                                                        let dict = array as! Array<[String: Any]>
//                                                        var vkData = [String: Any]()
//                                                        if dict.count != 0 { vkData = dict.first! }
//                                                        if let pictureKey = dict.first?.keys.filter( { $0.lowercased().contains("photo")} ).first, let value = vkData[pictureKey] as? String {
//                                                            if let pictureURL = URL(string: value) {
//                                                                AF.request(pictureURL).responseData { response in
//                                                                    switch response.result {
//                                                                    case .success(let data):
//                                                                        if let image = UIImage(data: data) {
//                                                                            imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
//                                                                            vkData["image"] = image
//                                                                            vkData.removeValue(forKey: pictureKey)
//                                                                            let data = VKManager.prepareUserData(vkData)
//                                                                            API.shared.updateUserProfile(data: data) {
//                                                                                response, error in
//                                                                                if error != nil {
//                                                                                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                                                }
//                                                                                if response != nil {
//                                                                                    AppData.shared.importUserData(response!, imagePath)
//                                                                                    self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                                                }
//                                                                            }
//                                                                        }
//                                                                    case .failure(let error):
//                                                                        print(error.localizedDescription)
//                                                                    }
//                                                                }
//                                                            }
//                                                        } else {
//                                                            API.shared.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
//                                                                response, error in
//                                                                if error != nil {
//                                                                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                                }
//                                                                if response != nil {
//                                                                    AppData.shared.importUserData(response!)
//                                                                    self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                                }
//                                                            }
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            default:
//                                print("handleTokenStateReceived")
//                            }
//                        }
//
//
//
//                        case .failure(let error):
//                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: {
//                                for btn in self.buttons {
//                                    btn.state = .disabled
//                                    hideAlert()
//                                }
//                                AppData.shared.eraseData()
//                            }]]], text: error.localizedDescription)
//                        }
//                    }
//
//                case .failure(let error):
//                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
//                }
//
//
//
////                json, error in
////                if error != nil {
////                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error!.localizedDescription)
////                } else if json != nil {
////                    print(json!)
////                    AppData.shared.profile.id = (json!.dictionaryObject as! [String: Any])["id"] as! Int
////                    assert(AppData.shared.profile.id! != nil, "AuthViewController.handleTokenState error (AppData.shared.userprofile.id == nil)")
////                    let auth = self.getAuthCase()
////                    switch auth {
////                    case .Facebook:
////                        API.shared.getProfileNeedsUpdate() {
////                            if $1 != nil {
////                                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: $1!.localizedDescription)
////                            } else if $0 == true {
////                                FBManager.getUserData() {
////                                    response in
////                                    if response != nil {
////                                        var fbData = response!.dictionaryObject!
////                                        if let pictureData = JSON(fbData.removeValue(forKey: "picture") as Any) as? JSON {
////                                            if let is_silhouette = pictureData["data"]["is_silhouette"].bool {
////                                                if !is_silhouette {
////                                                    if let pictureURL = URL(string: pictureData["data"]["url"].string!) {
////                                                        AF.request(pictureURL).responseData { response in
////                                                            switch response.result {
////                                                            case .success(let data):
////                                                                if let image = UIImage(data: data) {
////                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
////                                                                    fbData["image"] = image
////                                                                    let data = FBManager.prepareUserData(fbData)
////                                                                    API.shared.updateUserProfile(data: data) {
////                                                                        json, error in
////                                                                        if error != nil {
////                                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
////                                                                        }
////                                                                        if json != nil {
////                                                                            AppData.shared.importUserData(json!, imagePath)
////                                                                            DispatchQueue.main.async {
////                                                                                self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
////                                                                            }
////                                                                        }
////                                                                    }
////                                                                }
////                                                            case .failure(let error):
////                                                                print(error.localizedDescription)
////                                                            }
////                                                        }
////                                                    } else {
////                                                        print(pictureData["data"]["url"].error!)
////                                                    }
////                                                }
////                                            }
////                                        } else {
////                                            API.shared.updateUserProfile(data: FBManager.prepareUserData(fbData)) {
////                                                json, error in
////                                                if error != nil {
////                                                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
////                                                }
////                                                if json != nil {
////                                                    AppData.shared.importUserData(json!)
////                                                    self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
////                                                }
////                                            }
////                                        }
////                                    }
////                                }
////                            }
////                        }
////                    case .VK:
////                        API.shared.getProfileNeedsUpdate() {
////                            if $1 != nil {
////                                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: $1!.localizedDescription)
////                            } else if $0 == true {
////                                VKManager.getUserData() {
////                                    response, error in
////                                    if error != nil {
////                                        print(error!.localizedDescription)
////                                        return
////                                    }
////
////                                    if response != nil {
////                                        if let array = response!.dictionaryObject!["response"] {
////                                            if array is Array<[String: Any]> {
////                                                let dict = array as! Array<[String: Any]>
////                                                var vkData = [String: Any]()
////                                                if dict.count != 0 { vkData = dict.first! }
////                                                if let pictureKey = dict.first?.keys.filter( { $0.lowercased().contains("photo")} ).first, let value = vkData[pictureKey] as? String {
////                                                    if let pictureURL = URL(string: value) {
////                                                        AF.request(pictureURL).responseData { response in
////                                                            switch response.result {
////                                                            case .success(let data):
////                                                                if let image = UIImage(data: data) {
////                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
////                                                                    vkData["image"] = image
////                                                                    vkData.removeValue(forKey: pictureKey)
////                                                                    let data = VKManager.prepareUserData(vkData)
////                                                                    API.shared.updateUserProfile(data: data) {
////                                                                        response, error in
////                                                                        if error != nil {
////                                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
////                                                                        }
////                                                                        if response != nil {
////                                                                            AppData.shared.importUserData(response!, imagePath)
////                                                                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
////                                                                        }
////                                                                    }
////                                                                }
////                                                            case .failure(let error):
////                                                                print(error.localizedDescription)
////                                                            }
////                                                        }
////                                                    }
////                                                } else {
////                                                    API.shared.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
////                                                        response, error in
////                                                        if error != nil {
////                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
////                                                        }
////                                                        if response != nil {
////                                                            AppData.shared.importUserData(response!)
////                                                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
////                                                        }
////                                                    }
////                                                }
////                                            }
////                                        }
////                                    }
////                                }
////                            }
////                        }
////                    default:
////                        print("handleTokenStateReceived")
////                    }
////                }
//            }
//    }
    
//    @objc private func handleTokenState() {
//        if tokenState == .Received {
//            var imagePath: String?
//            API.shared.getUserData() {
//                json, error in
//                if error != nil {
//                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error!.localizedDescription)
//                } else if json != nil {
//                    print(json!)
//                    AppData.shared.profile.id = (json!.dictionaryObject as! [String: Any])["id"] as! Int
//                    assert(AppData.shared.profile.id! != nil, "AuthViewController.handleTokenState error (AppData.shared.userprofile.id == nil)")
//                    let auth = self.getAuthCase()
//                    switch auth {
//                    case .Facebook:
//                        API.shared.getProfileNeedsUpdate() {
//                            if $1 != nil {
//                                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: $1!.localizedDescription)
//                            } else if $0 == true {
//                                FBManager.getUserData() {
//                                    response in
//                                    if response != nil {
//                                        var fbData = response!.dictionaryObject!
//                                        if let pictureData = JSON(fbData.removeValue(forKey: "picture") as Any) as? JSON {
//                                            if let is_silhouette = pictureData["data"]["is_silhouette"].bool {
//                                                if !is_silhouette {
//                                                    if let pictureURL = URL(string: pictureData["data"]["url"].string!) {
//                                                        AF.request(pictureURL).responseData { response in
//                                                            switch response.result {
//                                                            case .success(let data):
//                                                                if let image = UIImage(data: data) {
//                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
//                                                                    fbData["image"] = image
//                                                                    let data = FBManager.prepareUserData(fbData)
//                                                                    API.shared.updateUserProfile(data: data) {
//                                                                        json, error in
//                                                                        if error != nil {
//                                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                                        }
//                                                                        if json != nil {
//                                                                            AppData.shared.importUserData(json!, imagePath)
//                                                                            DispatchQueue.main.async {
//                                                                                self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                                            }
//                                                                        }
//                                                                    }
//                                                                }
//                                                            case .failure(let error):
//                                                                print(error.localizedDescription)
//                                                            }
//                                                        }
//                                                    } else {
//                                                        print(pictureData["data"]["url"].error!)
//                                                    }
//                                                }
//                                            }
//                                        } else {
//                                            API.shared.updateUserProfile(data: FBManager.prepareUserData(fbData)) {
//                                                json, error in
//                                                if error != nil {
//                                                    showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                }
//                                                if json != nil {
//                                                    AppData.shared.importUserData(json!)
//                                                    self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    case .VK:
//                        API.shared.getProfileNeedsUpdate() {
//                            if $1 != nil {
//                                showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: $1!.localizedDescription)
//                            } else if $0 == true {
//                                VKManager.getUserData() {
//                                    response, error in
//                                    if error != nil {
//                                        print(error!.localizedDescription)
//                                        return
//                                    }
//
//                                    if response != nil {
//                                        if let array = response!.dictionaryObject!["response"] {
//                                            if array is Array<[String: Any]> {
//                                                let dict = array as! Array<[String: Any]>
//                                                var vkData = [String: Any]()
//                                                if dict.count != 0 { vkData = dict.first! }
//                                                if let pictureKey = dict.first?.keys.filter( { $0.lowercased().contains("photo")} ).first, let value = vkData[pictureKey] as? String {
//                                                    if let pictureURL = URL(string: value) {
//                                                        AF.request(pictureURL).responseData { response in
//                                                            switch response.result {
//                                                            case .success(let data):
//                                                                if let image = UIImage(data: data) {
//                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
//                                                                    vkData["image"] = image
//                                                                    vkData.removeValue(forKey: pictureKey)
//                                                                    let data = VKManager.prepareUserData(vkData)
//                                                                    API.shared.updateUserProfile(data: data) {
//                                                                        response, error in
//                                                                        if error != nil {
//                                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                                        }
//                                                                        if response != nil {
//                                                                            AppData.shared.importUserData(response!, imagePath)
//                                                                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                                        }
//                                                                    }
//                                                                }
//                                                            case .failure(let error):
//                                                                print(error.localizedDescription)
//                                                            }
//                                                        }
//                                                    }
//                                                } else {
//                                                    API.shared.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
//                                                        response, error in
//                                                        if error != nil {
//                                                            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() }; AppData.shared.eraseData() }]]], text: error!.localizedDescription)
//                                                        }
//                                                        if response != nil {
//                                                            AppData.shared.importUserData(response!)
//                                                            self.performSegue(withIdentifier: Segues.Auth.TermsFromStartScreen, sender: nil)
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    default:
//                        print("handleTokenStateReceived")
//                    }
//                }
//            }
//        } else if tokenState == .ConnectionError {
//            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; hideAlert() } }]]], text: "Ошибка соединения с сервером, повторите позже")
//        } else if tokenState == .Error {
//            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: {hideAlert()}]]], text: "Ошибка сервера, повторите позже")
//        } else if tokenState == .ConnectionError && apiReachability == .Reachable {
//            print("connection error")
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //            isLoadingViewVisible = false
        //            showAlert(type: .Loading, buttons: nil, text: "Вход в систему..")
        hideAlert()
        if segue.identifier == Segues.Auth.TermsFromStartScreen {
            if let destinationVC = segue.destination as? TermsOfUseViewController {
                destinationVC.isBackButtonHidden = false
                destinationVC.isStackViewHidden  = false
                if getAuthCase() == .Facebook || getAuthCase() == .VK {
//                    destinationVC.launchApp = false
                    destinationVC.isBackButtonHidden = true
                }
            }
        } else if segue.identifier == Segues.Auth.Terms {
            if let destinationVC = segue.destination as? TermsOfUseViewController {
                destinationVC.isBackButtonHidden = false
                destinationVC.isStackViewHidden  = true
            }
        }
    }
}


extension AuthViewController: VKSdkDelegate, VKSdkUIDelegate {
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let error = result.error {
            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: error.localizedDescription)
            return
        }
        
        print("******VK Auth State = \(result.state.rawValue)********")
//        if result.state != .error {
//            API.shared.login(.VK, username: nil, password: nil, token: result.token.accessToken) {
//                _tokenState in
//                tokenState = _tokenState
//            }
//        } else {
//            showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "******VK Auth Failed State = \(result.state.rawValue)********")
//        }
        //        switch result.state {
        //        case .authorized:
        //            apiManager.login(.VK, username: nil, password: nil, token: result.token.accessToken) {
        //                _tokenState in
        //                tokenState = _tokenState
        //            }
        //        default:
        //            simpleAlert("******VK Auth Failed State = \(result.state.rawValue)********")
        //        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        showAlert(type: .Warning, buttons: [["Закрыть": [CustomAlertView.ButtonType.Ok: nil]]], text: "vkSdkUserAuthorizationFailed")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        //        showAlert(type: .Loading, buttons: nil, text: "Вход в систему..")
        if (self.presentedViewController != nil) {
            self.dismiss(animated: true, completion: {
                self.present(controller, animated: true) {
                }
            })
        } else {
            self.present(controller, animated: true)
        }
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        
    }
    
    
    func vkSdkAccessTokenUpdated(newToken:VKAccessToken?, oldToken:VKAccessToken?) -> Void {
        
    }
    
    func vkSdkAuthorizationStateUpdated(with result:VKAuthorizationResult) -> Void {
        //print(result.state.rawValue)
    }
    
    func vkSdkDidDismiss(_ controller: UIViewController!) {
        showAlert(type: .Loading, buttons: [nil], text: "Вход в систему..")
    }
    
}


//extension AuthViewController: ApiReachability {
//    func handleReachabilitySignal() {
////        simpleAlert("API not reachable")
//        showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "Сервер недоступен")
//    }
//
//    private func simpleAlert(_ message: String) {
//        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
//        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
//            print("You've pressed default")
//        }
//        alertController.addAction(action1)
//        present(alertController, animated: true)
//    }
//}

//extension AuthViewController: ServerInitializationProtocol {
//    func initializeServerAPI() -> APIManagerProtocol {
//        return (self.navigationController as! AuthNavigationController).apiManager
//    }
//}

extension AuthViewController: StorageInitializationProtocol {
    func initializeStorageManager() -> FileStorageProtocol {
        return (self.navigationController as! AuthNavigationController).storeManager
    }
}

















