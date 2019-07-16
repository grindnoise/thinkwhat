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
    @IBOutlet weak var instButton:                  InstagramButtonView!
    @IBOutlet weak var fbButton:                    FacebookButtonView!
    private var buttons:                            [ParentLoginButton] = []
    private var selectedAuth:                       Int = 0
    private var fbLoggedIn                          = false
    private var apiManager:                         APIManager!
    private var storeManager:                       FileStorage!
    private var isViewSetupCompleted                = false
    private var vk_sdkInstance:                     VKSdk!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupViews()
        apiManager      = (self.navigationController as! AuthNavigationController).apiManagerProtocol as? APIManager
        storeManager    = (self.navigationController as! AuthNavigationController).storeManagerProtocol as? FileStorage
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
            self.buttons = [self.vkButton, self.instButton, self.fbButton]
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            for button in self.buttons {
                let tap = UITapGestureRecognizer(target: self, action: #selector(AuthViewController.handleTap(gesture:)))
                button.addGestureRecognizer(tap)
            }
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self,
                                           selector: #selector(AuthViewController.handleTokenState),
                                           name: kNotificationTokenReceived,
                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(AuthViewController.handleTokenState),
                                           name: kNotificationTokenError,
                                           object: nil)
            //            notificationCenter.addObserver(self,
            //                                           selector: #selector(AuthViewController.handleTokenStateConnectionError),
            //                                           name: kNotificationTokenConnectionError,
            //                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(AuthViewController.handleReachabilitySignal),
                                           name: kNotificationApiNotReachable,
                                           object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
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
            if selectedIndex == 2 {
                (view as! InstagramButtonView).state = .enabled
            } else if selectedIndex == 1 {
                (view as! VKButtonView).state = .enabled
            } else if selectedIndex == 3 {
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
                } else if button is InstagramButtonView {
                    (button as! InstagramButtonView).state = .disabled
                }
            }
        }
        delay(seconds: 0.03) {
            let authCase = self.getAuthCase()
            switch authCase {
            case .Facebook:
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
            case .Google:
                DispatchQueue.main.async {
                    VKSdk.forceLogout()
                }
                DispatchQueue.main.async {
                    self.apiManager.logout() {
                        state in
                        tokenState = state
                    }
                }
                
                
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
        case 1:
            return .VK
        case 2:
            return .Google
        case 3:
            return .Facebook
        default:
            fatalError("\(selectedAuth) selectedAuth not found")
        }
    }
    
    @objc private func handleTokenState() {
        if tokenState == .Received {
            let auth = getAuthCase()
            switch auth {
            case .Facebook:
                print("df")
                self.apiManager.getFacebookID() {
                    id in
                    if id.isEmpty {
                        FBManager.getUserData() {
                            response in
                            if response != nil {
                                var fbData = response!.dictionaryObject!
                                if let pictureData = JSON(fbData.removeValue(forKey: "picture")) as? JSON {
                                    if let is_silhouette = pictureData["data"]["is_silhouette"].bool {
                                        if !is_silhouette {
                                            if let pictureURL = URL(string: pictureData["data"]["url"].string!) as? URL {
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
                                                            self.storeManager.storeImage(type: .Profile, image: image, fileName: nil, fileFormat: NSData(data: data).fileFormat, surveyID: nil)
                                                            fbData["image"] = image
                                                        }
                                                    }
                                                }
                                            } else {
                                                print(pictureData["data"]["url"].error!)
                                            }
                                        }
                                    }
                                }
                                self.apiManager.updateUserProfile(data: fbData) {
                                    if $0 {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            case .VK:
                print("VK")
            default:
                print("handleTokenStateReceived")
            }
        } else if tokenState == .Error {
            print("authorization error")
        } else if tokenState == .ConnectionError && apiReachability == .Reachable {
            print("connection error")
        }
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == kSegueSocialAuth {
    //            if let destinationVC = segue.destination as? SocialAuthViewController {
    //                destinationVC.authVariant = getAuthMethod()
    //            }
    //        } else if segue.identifier == kSegueTerms {
    //            if let destinationVC = segue.destination as? TermsOfUseViewController {
    //                destinationVC.isBackButtonHidden = false
    //                destinationVC.isStackViewHidden  = true
    //            }
    //        }
    //    }
}


extension AuthViewController: VKSdkDelegate, VKSdkUIDelegate {
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let error = result.error {
            //TODO Error popup
            print(error.localizedDescription)
            return
        }
        
        switch result.state {
        case .authorized:
            apiManager.login(.VK, username: nil, password: nil, token: result.token.accessToken) {
                _tokenState in
                tokenState = _tokenState
            }
        default:
            print("Default")
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("FAIL")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        if (self.presentedViewController != nil) {
            self.dismiss(animated: true, completion: {
                self.present(controller, animated: true, completion: {
                })
            })
        } else {
            self.present(controller, animated: true, completion: {
            })
        }
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        
    }
    
    
    func vkSdkAccessTokenUpdated(newToken:VKAccessToken?, oldToken:VKAccessToken?) -> Void {
        
    }
    
    func vkSdkAuthorizationStateUpdated(with result:VKAuthorizationResult) -> Void {
        print(result.state.rawValue)
    }
    
}
extension AuthViewController: ApiReachability {
    func handleReachabilitySignal() {
        let alertController = UIAlertController(title: "Alert", message: "API not reachable", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("You've pressed default")
        }
        alertController.addAction(action1)
        present(alertController, animated: true)
    }
}


















