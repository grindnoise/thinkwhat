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

class AuthViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var vkButton:                    VKButtonView!
    @IBOutlet weak var mailButton:                  MailButtonView!
    @IBOutlet weak var fbButton:                    FacebookButtonView!
    @IBOutlet weak var loadingView:         UIView!
    @IBOutlet weak var loadingIndicator:    LoadingIndicator!
    private var buttons:                            [ParentLoginButton] = []
    private var selectedAuth:                       Int = 0
    private var fbLoggedIn                          = false
    private var isViewSetupCompleted                = false
    private var vk_sdkInstance:                     VKSdk!
    private lazy var apiManager:   APIManagerProtocol = self.initializeServerAPI()
    private lazy var storeManager: FileStorageProtocol = self.initializeStorageManager()
    
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    private var isLoadingViewVisible    = false {
        didSet {
            if oldValue != isLoadingViewVisible {
                UIView.animate(withDuration: 0.2, animations: {
                    let alpha: CGFloat = self.isLoadingViewVisible ? 0.9 : 0
                    self.loadingView.alpha = alpha
                }) { completed in
                    if self.isLoadingViewVisible {
                        self.loadingIndicator.addUntitled1Animation()
                    } else {
                        self.loadingIndicator.removeAllAnimations()
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupViews()
        vk_sdkInstance  = VKSdk.initialize(withAppId: VK_IDS.APP_ID)
        vk_sdkInstance.register(self as VKSdkDelegate)
        vk_sdkInstance.uiDelegate = self as VKSdkUIDelegate
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(AuthViewController.handleTokenState),
                                       name: kNotificationTokenReceived,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(AuthViewController.handleTokenState),
                                       name: kNotificationTokenConnectionError,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(AuthViewController.handleTokenState),
                                       name: kNotificationTokenError,
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
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AuthViewController.showTermsOfUse(gesture:)))
        termsOfUseButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func showTermsOfUse(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            performSegue(withIdentifier: kSegueTerms, sender: nil)
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
                self.isLoadingViewVisible = true
                if AccessToken.current == nil {
                    FBManager.performLogin(viewController: self) {
                        (success) in
                        if success {
                            self.apiManager.login(.Facebook, username: nil, password: nil, token: AccessToken.current?.tokenString) {
                                state in
                                tokenState = state
                            }
                        } else {
                            //TODO Error handling
                            print("ERROR")
                        }
                    }
                } else {
                    if AccessToken.current!.expirationDate < Date() {
                        FBManager.performLogin(viewController: self) {
                            (success) in
                            if success {
                                self.apiManager.login(.Facebook, username: nil, password: nil, token: AccessToken.current?.tokenString) {
                                    state in
                                    tokenState = state
                                }
                            } else {
                                //TODO Error handling
                            }
                        }
                    } else {
                        self.apiManager.login(.Facebook, username: nil, password: nil, token: AccessToken.current?.tokenString) {//logInViaSocialMedia(authToken: (AccessToken.current?.tokenString)!, socialMedia: .Facebook) {
                            state in
                            tokenState = state
                        }
                    }
                }
            case .VK:
                self.isLoadingViewVisible = true
                let scope = ["email"]
                VKSdk.wakeUpSession(scope) {
                    state, error in
                    if error != nil {
                        print(error.debugDescription)
                    }
                    print(state.rawValue)
                    if state != VKAuthorizationState.authorized {
                        VKSdk.authorize(scope)
                    } else {
                        self.apiManager.login(.VK, username: nil, password: nil, token: VKSdk.accessToken()?.accessToken) {
                            _tokenState in
                            tokenState = _tokenState
                        }
                    }
                }
            case .Mail:
                self.performSegue(withIdentifier: kSegueMailAuth, sender: nil)
                
                
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
    
    
    private func getAuthCase() -> AuthVariant {
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
    
    @objc private func handleTokenState() {
        if tokenState == .Received {
            var imagePath: URL?
            apiManager.getUserData() {
                json, error in
                if error != nil {
                    showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                } else if json != nil {
                    print(json!)
                    AppData.shared.userProfile.ID = String(describing: (json!.dictionaryObject  as! [String: Any])["id"] as! Int)
                    assert(AppData.shared.userProfile.ID != nil || !AppData.shared.userProfile.ID.isEmpty)
                    let auth = self.getAuthCase()
                    switch auth {
                    case .Facebook:
                        self.apiManager.getProfileNeedsUpdate() {
                            if $0 {
                                FBManager.getUserData() {
                                    response in
                                    if response != nil {
                                        var fbData = response!.dictionaryObject!
                                        if let pictureData = JSON(fbData.removeValue(forKey: "picture")) as? JSON {
                                            if let is_silhouette = pictureData["data"]["is_silhouette"].bool {
                                                if !is_silhouette {
                                                    if let pictureURL = URL(string: pictureData["data"]["url"].string!) {
                                                        Alamofire.request(pictureURL).responseData {
                                                            response in
                                                            if response.result.isFailure {
                                                                print(response.result.debugDescription)
                                                            }
                                                            if let error = response.result.error as? AFError {
                                                                print(error.localizedDescription)
                                                            }
                                                            if let data = response.result.value {
                                                                if let image = UIImage(data: data) {
                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
                                                                    fbData["image"] = image
                                                                    let data = FBManager.prepareUserData(fbData)
                                                                    self.apiManager.updateUserProfile(data: data) {
                                                                        json, error in
                                                                        if error != nil {
                                                                            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                                                                        }
                                                                        if json != nil {
                                                                            AppData.shared.importUserData(json!, imagePath)
                                                                            self.performSegue(withIdentifier: kSegueTermsFromStartScreen, sender: nil)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        print(pictureData["data"]["url"].error!)
                                                    }
                                                }
                                            }
                                        } else {
                                            self.apiManager.updateUserProfile(data: FBManager.prepareUserData(fbData)) {
                                                json, error in
                                                if error != nil {
                                                    showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                                                }
                                                if json != nil {
                                                    AppData.shared.importUserData(json!)
                                                    self.performSegue(withIdentifier: kSegueTermsFromStartScreen, sender: nil)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    case .VK:
                        self.apiManager.getProfileNeedsUpdate() {
                            if $0 {
                                VKManager.getUserData() {
                                    response, error in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                        return
                                    }
                                    
                                    if response != nil {
                                        if let array = response!.dictionaryObject!["response"] {
                                            if array is Array<[String: Any]> {
                                                let dict = array as! Array<[String: Any]>
                                                var vkData = [String: Any]()
                                                if dict.count != 0 { vkData = dict.first! }
                                                if let pictureKey = dict.first?.keys.filter( { $0.lowercased().contains("photo")} ).first, let value = vkData[pictureKey] as? String {
                                                    if let pictureURL = URL(string: value) {
                                                        Alamofire.request(pictureURL).responseData {
                                                            response in
                                                            if response.result.isFailure {
                                                                print(response.result.debugDescription)
                                                            }
                                                            if let error = response.result.error as? AFError {
                                                                print(error.localizedDescription)
                                                            }
                                                            if let imgData = response.result.value {
                                                                if let image = UIImage(data: imgData) {
                                                                    imagePath = self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: imgData).fileFormat, surveyID: nil)
                                                                    vkData["image"] = image
                                                                    vkData.removeValue(forKey: pictureKey)
                                                                    self.apiManager.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
                                                                        response, error in
                                                                        if error != nil {
                                                                            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                                                                        }
                                                                        if response != nil {
                                                                            AppData.shared.importUserData(response!, imagePath)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    self.apiManager.updateUserProfile(data: VKManager.prepareUserData(vkData)) {
                                                        response, error in
                                                        if error != nil {
                                                            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error!.localizedDescription)
                                                        }
                                                        if response != nil {
                                                            AppData.shared.importUserData(response!)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    default:
                        print("handleTokenStateReceived")
                    }
                }
            }
        } else if tokenState == .ConnectionError {
            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: { for btn in self.buttons { btn.state = .disabled; self.isLoadingViewVisible = false } }]], text: "Ошибка соединения с сервером, повторите позже")
        } else if tokenState == .Error {
            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: {self.isLoadingViewVisible = false}]], text: "Ошибка сервера, повторите позже")
        } else if tokenState == .ConnectionError && apiReachability == .Reachable {
            print("connection error")
        }
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            isLoadingViewVisible = false
            if segue.identifier == kSegueTermsFromStartScreen {
                if let destinationVC = segue.destination as? TermsOfUseViewController {
                    destinationVC.isBackButtonHidden = false
                    destinationVC.isStackViewHidden  = false
                    if getAuthCase() == .Facebook || getAuthCase() == .VK {
                        destinationVC.launchApp = false
                        destinationVC.isBackButtonHidden = true
                    }
                }
            } else if segue.identifier == kSegueTerms {
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
            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: error.localizedDescription)
            return
        }
        
        print("******VK Auth State = \(result.state.rawValue)********")
        if result.state != .error {
            apiManager.login(.VK, username: nil, password: nil, token: result.token.accessToken) {
                _tokenState in
                tokenState = _tokenState
            }
        } else {
            showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "******VK Auth Failed State = \(result.state.rawValue)********")
        }
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
        showAlert(type: .Warning, buttons: ["Ок": [CustomAlertView.ButtonType.Ok: nil]], text: "vkSdkUserAuthorizationFailed")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        if (self.presentedViewController != nil) {
            self.dismiss(animated: true, completion: {
                self.present(controller, animated: true, completion: {
                })
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

extension AuthViewController: ServerInitializationProtocol {
    func initializeServerAPI() -> APIManagerProtocol {
        return (self.navigationController as! AuthNavigationController).apiManager
    }
}

extension AuthViewController: StorageInitializationProtocol {
    func initializeStorageManager() -> FileStorageProtocol {
        return (self.navigationController as! AuthNavigationController).storeManager
    }
}

















