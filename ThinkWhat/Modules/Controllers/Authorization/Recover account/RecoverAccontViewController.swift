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
            let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
            ImageSigns.envelope.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : .systemGreen
            banner.present(subview: PlainBannerContent(text: "success".localized, imageContent: ImageSigns.envelope, color: .systemGreen), isModal: false, shouldDismissAfter: 1.5)
        case .failure(let error):
            var errorDescription = ""
            if error.localizedDescription.contains("find an account associated with that email") {
                errorDescription = "email_not_found"
            }
            let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
            banner.present(subview: PlainBannerContent(text: "errorDescription".localized, imageContent: ImageSigns.envelope, color: .systemRed), isModal: false, shouldDismissAfter: 1.5)
        }
    }
}

extension RecoverAccontViewController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        guard let banner = sender as? Banner else { return }
        banner.removeFromSuperview()
    }
}

