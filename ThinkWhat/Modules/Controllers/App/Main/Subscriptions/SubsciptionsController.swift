//
//  SubsciptionsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = SubsciptionsModel()
               
        self.controllerOutput = view as? SubsciptionsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "subscriptions".localized
//        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Properties
    var controllerOutput: SubsciptionsControllerOutput?
    var controllerInput: SubsciptionsControllerInput?
}

// MARK: - View Input
extension SubsciptionsController: SubsciptionsViewInput {
    // Implement methods
}

// MARK: - Model Output
extension SubsciptionsController: SubsciptionsModelOutput {
    // Implement methods
}
