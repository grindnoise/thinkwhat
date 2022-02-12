//
//  ConditionsViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class ConditionsViewController: UIViewController {
    
    deinit {
        print("ConditionsViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = ConditionsModel()
        
        self.controllerOutput = view as? AgreementView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        title = NSLocalizedString("terms_of_use", comment: "")
        controllerInput?.getTermsConditionsURL()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ///User refused to accept terms & conditions -> log out
        if isMovingFromParent {
            UserDefaults.clear()
        }
    }
    
    // MARK: - Properties
    var controllerOutput: ConditionsControllerOutput?
    var controllerInput: ConditionsControllerInput?
}

// MARK: - View Input
extension ConditionsViewController: ConditionsViewInput {
    func onAcceptTappedWithSuccess() {
        // TODO: - Next scene
        print("onAcceptTappedWithSuccess")
    }
    
    func onAcceptTappedWithError() {
        let alert = UIAlertController(title: NSLocalizedString("should_read_agreement_title",comment: ""),
                                      message: NSLocalizedString("should_read_agreement_message", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                      style: .default))
        present(alert, animated: true)
    }
    
    func onAcceptTappedWhileLoading() {
        let alert = UIAlertController(title: NSLocalizedString("should_read_agreement_title",comment: ""),
                                      message: NSLocalizedString("wait_for_agreement", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                      style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Model Output
extension ConditionsViewController: ConditionsModelOutput {
    func onTermsConditionsURLReceived(_ url: URL) {
        controllerOutput?.getTermsConditionsURL(url)
    }
}
