//
//  GetStartedViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.01.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.hidesBackButton = true
        welcomeView = self.view as? WelcomeView
        welcomeView?.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isViewLayedOut {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    

    // MARK: - Properties
    var welcomeView: WelcomeControllerOutput? {
        didSet {
            self.view = welcomeView as? UIView
        }
    }
    var isViewLayedOut = false
}

// MARK: - View Input
extension GetStartedViewController: WelcomeViewInput {
    func onGetStartedTap() {
        let controller = SignupViewController()
//        let view = SignupView()
//
//        controller.controllerOutput = view
//        controller.controllerOutput?.viewInput = controller
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Auth
            nav.duration = 0.5
        }
        
        navigationController?
            .pushViewController(controller, animated: true)
    }
}

