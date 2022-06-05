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
        
        func next() -> Stage? {
            return Stage(rawValue: (self.rawValue + 1))
        }
    }
    
    enum Option: String {
        case Null = "", Ordinary = "default_option", Anon = "anon_option", Private = "private_option"
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
        guard stage == .Topic else { return }
        controllerOutput?.onNextStage(.Topic)
    }

    // MARK: - Properties
    var controllerOutput: PollCreationControllerOutput?
    var controllerInput: PollCreationControllerInput?
    var stage: Stage = .Topic
    private var maximumStage: Stage = .Topic {
        didSet {
            if oldValue.rawValue >= maximumStage.rawValue {
                maximumStage = oldValue
            }
        }
    }
}

// MARK: - View Input
extension PollCreationController: PollCreationViewInput {
    func onStageCompleted() {
        guard let next = stage.next() else { return }
        stage = next
        Task {
//            try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
            await MainActor.run {
                controllerOutput?.onNextStage(stage)
            }
        }
    }
}

// MARK: - Model Output
extension PollCreationController: PollCreationModelOutput {
    // Implement methods
}
