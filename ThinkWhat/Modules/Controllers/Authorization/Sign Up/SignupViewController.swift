//
//  SignupViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    deinit {
        print("SignupViewController deinit")
    }
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
        let model = SignupModel()
               
        self.controllerOutput = view as? SignupView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
    }

    // MARK: - Properties
    var controllerOutput: SignupControllerOutput?
    var controllerInput: SignupControllerInput?
}

// MARK: - View Input
extension SignupViewController: SignupViewInput {
    func onFacebookTap() {
        
    }
    
    func onVkTap() {
        
    }
    
    func onLoginTap() {
        print("onLoginTap")
    }
    
    func onSignupTap() {
        print("onSignupTap")
    }
    
    
}

// MARK: - Model Output
extension SignupViewController: SignupModelOutput {
    // Implement methods
}
