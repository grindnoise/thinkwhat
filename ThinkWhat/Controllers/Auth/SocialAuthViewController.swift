//
//  SocialAuthViewController.swift
//  Burb
//
//  Created by Pavel Bukharov on 18.07.2018.
//  Copyright © 2018 Pavel Bukharov. All rights reserved.
//

import UIKit

class SocialAuthViewController: UIViewController, UIWebViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var spinner:         LoadingIndicator!
    @IBOutlet weak var loginWebView:    UIWebView!
    open           var authVariant:     AuthVariant                 = .Undefined
    open           var navTitle:        UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage     = UIImage()
            self.navigationController?.navigationBar.isTranslucent   = false
            self.navigationController?.isNavigationBarHidden         = false
            self.navigationController?.navigationBar.barTintColor    = .white
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        loginWebView.delegate                                           = self
        unSignedRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(SocialAuthViewController.handleSuccessTokenNotification), name: kNotificationSuccessToken, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spinner.addUntitled1Animation()
        if authVariant == .Instagram {
            navTitle                                            = InstagramLogo(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            navTitle.isOpaque                                   = false
            navTitle.alpha                                      = 0
            navigationItem.titleView                            = navTitle
        } else if authVariant == .VK {
            navTitle                                            = VKLogo(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            navTitle.isOpaque                                   = false
            navTitle.alpha                                      = 0
            navigationItem.titleView                            = navTitle
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let cookieStorage = HTTPCookieStorage.shared
        for cookie in cookieStorage.cookies ?? [] {
            cookieStorage.deleteCookie(cookie)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        if authVariant == .Instagram {
            
            let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
            let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
            loginWebView.loadRequest(urlRequest)
            
        }
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: String(requestURLString[range.upperBound...]))//requestURLString.substring(from: range.upperBound))
            return false;
            
        }
        
        return true
        
    }
    
    func handleAuth(authToken: String)  {
        
        (navigationController as! AuthNavigationController).serverAPI.logInViaSocialMedia(authToken: authToken, socialMedia: .Instagram) {
            receivedToken in
            tokenStatus = receivedToken
            if tokenStatus == .Received {
                (self.navigationController as! AuthNavigationController).serverAPI.pullUserData("", completion: { (json) in
                    print(json)
                })
            }
        }
        
        switch authVariant {
        case .Instagram:
            KeychainService.saveInstagramAccessToken(token: (authToken as NSString))
        case .Facebook:
            KeychainService.saveFacebookAccessToken(token: (authToken as NSString))
        case .VK:
            KeychainService.saveVKAccessToken(token: (authToken as NSString))
        default:
            print("Google")
            //KeychainService.saveGoogleAccessToken(token: (authToken as NSString))
        }
        print("\(authVariant) authentication token == ", authToken)
        appData.session = .authorized
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.spinner.layer.opacity = 0
        }) {_ in
            self.spinner.removeAllAnimations()
        }
    }
    
    @objc fileprivate func handleSuccessTokenNotification() {
        if (self.isViewLoaded && (self.view.window != nil)) {

            
            
            UIView.transition(with: self.view.window!, duration: 0.4, options: [.allowAnimatedContent, UIView.AnimationOptions.transitionCrossDissolve], animations: {
                //TODO: Определить дальнейшие переходы - если пользователя нет, тогда делать переход на заполнение данных и выбор роли, если есть - в саму программу
                //UIApplication.shared.keyWindow?.rootViewController = containerVC
                /*}, completion: {
                 _ in
                 dismissAlert()
                 })*/
            })
        }
    }
    
}
