//
//  SubsciptionsViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class SubsciptionsViewController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = SubsciptionsView()
        let model = SubsciptionsModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
    }

    // MARK: - Properties
    var controllerOutput: SubsciptionsControllerOutput?
    var controllerInput: SubsciptionsControllerInput?
}

// MARK: - View Input
extension SubsciptionsViewController: SubsciptionsViewInput {
    // Implement methods
}

// MARK: - Model Output
extension SubsciptionsViewController: SubsciptionsModelOutput {
    // Implement methods
}
