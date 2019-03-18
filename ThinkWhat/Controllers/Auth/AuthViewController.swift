//
//  AuthViewController.swift
//  Burb
//
//  Created by Pavel Bukharov on 24.03.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var phoneButtonTmp: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var vkButton:                    VKButton!
    @IBOutlet weak var instButton:                  InstagramButton!
    @IBOutlet weak var fbButton:                    VKButton!
    @IBOutlet weak var okButton:                    VKButton!
    private var buttons:                            [ParentLoginButton] = []
    private var selectedAuth:                       Int = 0
    
    private var isViewSetupCompleted = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupViews()
    }
    
    @IBAction func signupViaPhoneButton(_ sender: UIButton) {
       performSegue(withIdentifier: segueSignup, sender: self)
     //   let signupVC = storyboard?.instantiateViewController(withIdentifier: "signupVC")
     //  navigationController?.pushViewController(signupVC!, animated: true)
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
            self.navigationController?.navigationBar.tintColor       = .black
            self.buttons = [self.vkButton, self.instButton, self.fbButton, self.okButton]
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
            self.phoneButton.layer.cornerRadius = self.phoneButton.frame.height / 2
            self.isViewSetupCompleted = true
            self.phoneButtonTmp.backgroundColor = K_COLOR_RED
            self.phoneButton.backgroundColor = K_COLOR_RED
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
            performSegue(withIdentifier: segueTermsFromAuth, sender: nil)
        }
    }
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        var selectedIndex = 0
        if let view = gesture.view {
            selectedIndex = view.tag
            if selectedIndex == 1 {
                (view as! InstagramButton).state = .enabled
            } else if selectedIndex == 2 {
                (view as! VKButton).state = .enabled
            } else if selectedIndex == 3 {
                (view as! VKButton).state = .enabled
            } else if selectedIndex == 4 {
                (view as! VKButton).state = .enabled
            }

            selectedAuth = selectedIndex
            for button in buttons {
                if button.tag == selectedIndex {
                    continue
                }
                if button is VKButton {
                    (button as! VKButton).state = .disabled
                } else if button is InstagramButton {
                    (button as! InstagramButton).state = .disabled
                }
            }
        }
        //delay(seconds: 0.05) {
            self.performSegue(withIdentifier: segueSocialAuth, sender: nil)
        //}
    }
    
    private func getAuthMethod() -> AuthVariant {
        switch selectedAuth {
        case 1:
            return .Instagram
        case 2:
            return .VK
        case 3:
            return .Facebook
        case 4:
            return .OK
        default:
            fatalError("\(selectedAuth) selectedAuth not found")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueSocialAuth {
            if let destinationVC = segue.destination as? SocialAuthViewController {
                destinationVC.authVariant = getAuthMethod()
            }
        } else if segue.identifier == segueTermsFromAuth {
            if let destinationVC = segue.destination as? TermsOfUseViewController {
                destinationVC.isBackButtonHidden = false
                destinationVC.isStackViewHidden  = true
            }
        }
    }
}



















