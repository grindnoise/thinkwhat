//
//  RecoverAccontViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 13.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class RecoverAccontViewController: UIViewController {
    deinit {
        print("RecoverAccontViewController deinit")
    }
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = RecoverView()
        let model = RecoverModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        title = NSLocalizedString("recover_title", comment: "")
    }

    // MARK: - Properties
    var controllerOutput: RecoverControllerOutput?
    var controllerInput: RecoverControllerInput?
}

// MARK: - View Input
extension RecoverAccontViewController: RecoverViewInput {
    func sendEmail(_ email: String) {
        controllerInput?.sendEmail(email)
    }
}

// MARK: - Model Output
extension RecoverAccontViewController: RecoverModelOutput {
    func onEmailSent(_ result: Result<Bool, Error>) {
        Task {
            await MainActor.run {
                controllerOutput?.onEmailSent()
            }
        }
        switch result {
        case .success:
            let alert = UIAlertController(title: NSLocalizedString("success",comment: ""),
                                          message: NSLocalizedString("email_sent", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                          style: .default))
            present(alert, animated: true)
        case .failure(let error):
            var errorDescription = ""
            if error.localizedDescription.contains("find an account associated with that email") {
                errorDescription = "email_not_found"
            }
            let alert = UIAlertController(title: NSLocalizedString("warning",comment: ""),
                                          message: NSLocalizedString(errorDescription, comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                          style: .default))
            present(alert, animated: true)
        }
    }
}

