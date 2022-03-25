//
//  PollViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollViewController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = PollView()
        let model = PollModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
    }

    // MARK: - Properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
}

// MARK: - View Input
extension PollViewController: PollViewInput {
    // Implement methods
}

// MARK: - Model Output
extension PollViewController: PollModelOutput {
    // Implement methods
}
