//
//  TopicsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = TopicsModel()
               
        self.controllerOutput = view as? TopicsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        title = "topics".localized
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Properties
    var controllerOutput: TopicsControllerOutput?
    var controllerInput: TopicsControllerInput?
}

// MARK: - View Input
extension TopicsController: TopicsViewInput {
    // Implement methods
}

// MARK: - Model Output
extension TopicsController: TopicsModelOutput {
    // Implement methods
}
