//
//  AuthViewController.swift
//  Burb
//
//  Created by Pavel Bukharov on 24.03.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AuthViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var vkButton:                    VKButtonView!
    @IBOutlet weak var instButton:                  InstagramButtonView!
    @IBOutlet weak var fbButton:                    FacebookButtonView!
    private var buttons:                            [ParentLoginButton] = []
    private var selectedAuth:                       Int = 0
    private var fbLoggedIn                          = false
    private var serverAPI:                          APIServer!
    private var isViewSetupCompleted                = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupViews()
        serverAPI = (self.navigationController as! AuthNavigationController).serverAPI as! APIServer
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
                if FBSDKAccessToken.current() == nil {
                    FBManager.performLogin(viewController: self) {
                        (success) in
                        if success {
                            self.serverAPI.logInViaSocialMedia(authToken: (FBSDKAccessToken.current()?.tokenString)!, socialMedia: .Facebook) {
                                state in
                                tokenState = state
                            }
                        } else {
                            //TODO Error handling
                        }
                    }
                } else {
                    self.serverAPI.logInViaSocialMedia(authToken: (FBSDKAccessToken.current()?.tokenString)!, socialMedia: .Facebook) {
                        state in
                        tokenState = state
                    }
                }
                if tokenState == .Received {
                    self.serverAPI.getFacebookID() {
                        id in
                        if id == nil {
                            FBManager.getUserData()
                        }
                    }
                }
            case .Instagram:
                if FBSDKAccessToken.current() != nil {
                    FBManager.performLogout()
                }
                (self.navigationController as! AuthNavigationController).serverAPI.logOut() {
                    state in
                    tokenState = state
                }
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
            return .Instagram
        case 3:
            return .Facebook
        case 4:
            return .OK
        default:
            fatalError("\(selectedAuth) selectedAuth not found")
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



















