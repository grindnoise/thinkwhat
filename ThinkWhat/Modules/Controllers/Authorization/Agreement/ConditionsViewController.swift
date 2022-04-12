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
    func onAccept() {
        navigationController?
            .pushViewController(FillProfileViewController(),
                                animated: true)
    }
    
    func onRefuse() {
        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
        banner.present(subview: PlainBannerContent(text: "should_read_agreement_message".localized, imageContent: ImageSigns.envelope, color: .systemOrange), isModal: false, shouldDismissAfter: 1.5)
    }
    
    func onTapWhileLoading() {
        let banner = Banner(frame: UIScreen.main.bounds, callbackDelegate: nil, bannerDelegate: self)
        banner.present(subview: PlainBannerContent(text: "wait_for_agreement".localized, imageContent: ImageSigns.envelope, color: .systemOrange), isModal: false, shouldDismissAfter: 1.5)
    }
}

// MARK: - Model Output
extension ConditionsViewController: ConditionsModelOutput {
    func onTermsConditionsURLReceived(_ url: URL) {
        controllerOutput?.getTermsConditionsURL(url)
    }
}

extension ConditionsViewController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        guard let banner = sender as? Banner else { return }
        banner.removeFromSuperview()
    }
}
