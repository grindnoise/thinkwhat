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
    func onIncorrectFields() {
        let alert = UIAlertController(title: NSLocalizedString("warning",comment: ""),
                                      message: NSLocalizedString("check_fields", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                      style: .default))
        present(alert, animated: true)
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
            let alert = UIAlertController(title: NSLocalizedString("error",comment: ""),
                                          message: NSLocalizedString("log_in_error", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                          style: .default))
            try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
            await MainActor.run {
                present(alert, animated: true)
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
