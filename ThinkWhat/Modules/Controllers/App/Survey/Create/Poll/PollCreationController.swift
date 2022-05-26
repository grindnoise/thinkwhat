//
//  PollCreationController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCreationController: UIViewController {

    deinit {
        print("PollCreationController deinit")
    }

    //Sequence of stages to post new survey
    enum Stage: Int, CaseIterable {
        case Topic, Options, Title, Description, Question, Hyperlink, Images, Choices, Comments, Limits, Hot, Ready
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let model = PollCreationModel()
               
        self.controllerOutput = view as? PollCreationView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controllerOutput?.onNextStage(.Topic)
    }

    // MARK: - Properties
    var controllerOutput: PollCreationControllerOutput?
    var controllerInput: PollCreationControllerInput?
    var stage: Stage = .Title
}

// MARK: - View Input
extension PollCreationController: PollCreationViewInput {
    // Implement methods
}

// MARK: - Model Output
extension PollCreationController: PollCreationModelOutput {
    // Implement methods
}
