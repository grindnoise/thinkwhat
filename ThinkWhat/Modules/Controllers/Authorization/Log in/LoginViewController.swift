//
//  LoginViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    deinit {
        print("LoginViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = LoginModel()
        
        self.controllerOutput = view as? LoginView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        title = NSLocalizedString("log_in_title", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ///User refused to accept terms & conditions -> log out
        if isMovingFromParent {
            UserDefaults.clear()
        }
    }
    
    // MARK: - Properties
    var controllerOutput: LoginControllerOutput?
    var controllerInput: LoginControllerInput?

}

extension LoginViewController: LoginViewInput {
    func onRecoverTapped() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?
            .pushViewController(RecoverAccontViewController(),
                                animated: true)
    }
    
    func onNextScene() {
        ///Check if profile view controller should be presented to fill necessary fields
        
    }
    
    func onIncorrectFields() {
        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
        banner.present(subview: PlainBannerContent(text: "check_fields".localized, imageContent: ImageSigns.envelope, color: .systemRed), isModal: false, shouldDismissAfter: 1.5)
    }
    
    func onLogin(username: String, password: String) {
        controllerInput?.performLogin(username: username, password: password)
    }
}

extension LoginViewController: LoginModelOutput {
    func onError(_ error: Error) {
        Task {
            await MainActor.run {
                controllerOutput?.onError(error)
            }
            try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
            await MainActor.run {
                let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
                banner.present(subview: PlainBannerContent(text: "log_in_error".localized, imageContent: ImageSigns.envelope, color: .systemRed), isModal: false, shouldDismissAfter: 1.5)
            }
        }
    }
    
    func onSuccess() {
        Task {
            await MainActor.run {
                controllerOutput?.onSuccess()
            }
        }
    }
}

extension LoginViewController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        guard let banner = sender as? Banner else { return }
        banner.removeFromSuperview()
    }
}
