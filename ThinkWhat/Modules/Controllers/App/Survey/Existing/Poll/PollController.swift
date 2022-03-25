//
//  PollController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 25.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = PollModel()
               
        self.controllerOutput = view as? PollView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
    }

    // MARK: - Properties
    var controllerOutput: PollControllerOutput?
    var controllerInput: PollControllerInput?
}

// MARK: - View Input
extension PollController: PollViewInput {
    // Implement methods
}

// MARK: - Model Output
extension PollController: PollModelOutput {
    // Implement methods
}
