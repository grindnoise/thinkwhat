//
//  TermsOfUseViewController.swift
//  Burb
//
//  Created by Eugene on 12.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class TermsOfUseViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    enum TermsRoute {
        case Profile, App
    }
    
    var termsRoute: TermsRoute!                         = .App
    var isBackButtonHidden                              = true
    var isStackViewHidden                               = false
    var stackViewHeightConstraintDefaultValue: CGFloat  = 0
    var isFirstLaunch                                   = true
    var username                                        = ""
    @IBOutlet weak var spinner:         LoadingIndicator!
    @IBOutlet weak var webView:         UIWebView!
    @IBOutlet weak var stackView:       UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            if termsRoute == .App {
                
                
                
                //performSegue(withIdentifier: kSegueAppFromTerms, sender: nil)
            }
            //performSegue(withIdentifier: segueRoleSelection, sender: nil)
        } else {
            if let authVC = navigationController?.viewControllers[0] as? AuthViewController {
                self.navigationController?.viewControllers = [authVC]
//                self.dismiss(animated: true, completion: {})
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.title                                                      = "Соглашение"
        self.navigationItem.setHidesBackButton(isBackButtonHidden, animated: false)
        webView.delegate                                                = self
//        performURLRequest()
        spinner.addUntitled1Animation()
    }
    
    private func setupViews() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFirstLaunch {
            view.setNeedsLayout()
            stackViewHeightConstraintDefaultValue = stackViewHeightConstraint.multiplier
            isFirstLaunch = false
        }
        if isStackViewHidden {
            print(stackView.frame.height)
            let newConstraint           = stackViewHeightConstraint.setMultiplier(0, duration: 0)
            stackViewHeightConstraint   = newConstraint
            stackView.alpha             = 0
            print(stackView.frame.height)
        } else {
            let newConstraint           = stackViewHeightConstraint.setMultiplier(stackViewHeightConstraintDefaultValue, duration: 0)
            stackViewHeightConstraint   = newConstraint
            stackView.alpha             = 1
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.spinner.layer.opacity = 0
        }) { _ in
            self.spinner.removeAllAnimations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies ?? [] {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    func performURLRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        webView.loadRequest(urlRequest)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == segueRoleSelection {
//            if let destinationVC = segue.destination as? RoleViewController {
//                destinationVC.phoneNumber = phoneNumber
//                destinationVC.phoneNumberFormatted = phoneNumberFormatted
//                destinationVC.username = username
//            }
//        }
//    }
}
