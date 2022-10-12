//
//  FeedbackViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    // MARK: - Properties
    var controllerOutput: FeedbackControllerOutput?
    var controllerInput: FeedbackControllerInput?
    
    
    
    // MARK: - Destructor
    deinit {
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = FeedbackView()
        let model = FeedbackModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        title = "feedback".localized

        setRightBarButton()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}

private extension FeedbackViewController {
    func setRightBarButton() {
        
        let button = UIBarButtonItem(image: UIImage(systemName: "questionmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(self.handleTap))
        
        navigationItem.setRightBarButton(button, animated: true)
    }
    
    @objc
    func handleTap() {
        view.endEditing(true)
        let banner = Popup(callbackDelegate: nil, bannerDelegate: self, heightScaleFactor: 0.5)
        banner.present(content: PopupContent(parent: banner,
                                             systemImage: "envelope.fill",
                                             text: "feedback_hint".localized,
                                             buttonTitle: "ok",
                                             fixedSize: false,
                                             spacing: 24))
    }
}

extension FeedbackViewController: FeedbackViewInput {
    func sendFeedback(_ description: String) {
        controllerInput?.sendFeedback(description)
    }
}

extension FeedbackViewController: FeedbackModelOutput {}

extension FeedbackViewController: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            banner.removeFromSuperview()
        } else if let banner = sender as? Popup {
            banner.removeFromSuperview()
        }
    }
}
