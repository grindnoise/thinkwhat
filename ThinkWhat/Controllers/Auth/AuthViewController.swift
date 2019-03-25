//
//  AuthViewController.swift
//  Burb
//
//  Created by Pavel Bukharov on 24.03.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var vkButton:                    VKButtonView!
    @IBOutlet weak var instButton:                  InstagramButtonView!
    @IBOutlet weak var fbButton:                    FacebookButtonView!
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
        
        delay(seconds: 0.05) {
            if self.getAuthMethod() == .Mail {
                self.performSegue(withIdentifier: kSegueMailAuth, sender: nil)
            } else {
                self.performSegue(withIdentifier: kSegueSocialAuth, sender: nil)
            }
        }
    }

    private func getAuthMethod() -> AuthVariant {
        switch selectedAuth {
        case 1:
            return .VK
        case 2:
            return .Instagram
        case 3:
            return .Mail
        case 4:
            return .OK
        default:
            fatalError("\(selectedAuth) selectedAuth not found")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueSocialAuth {
            if let destinationVC = segue.destination as? SocialAuthViewController {
                destinationVC.authVariant = getAuthMethod()
            }
        } else if segue.identifier == kSegueTerms {
            if let destinationVC = segue.destination as? TermsOfUseViewController {
                destinationVC.isBackButtonHidden = false
                destinationVC.isStackViewHidden  = true
            }
        }
    }
}



















