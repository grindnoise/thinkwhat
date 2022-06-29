//
//  PollCreationContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol PollCreationViewInput: AnyObject {
    
    var controllerOutput: PollCreationControllerOutput? { get set }
    var controllerInput: PollCreationControllerInput? { get set }
    var stage: PollCreationController.Stage { get }
    var balance: Int { get }
    var willMoveToParent: Bool { get }
    
    func onStageCompleted()
    func onURLTapped(_: URL?)
    func post(_: [String: Any])
    func onContinue()
    func readPasteboard()
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol PollCreationControllerInput: AnyObject {
    
    var modelOutput: PollCreationModelOutput? { get set }
    var balance: Int { get }
    
    func post(_: [String: Any])
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol PollCreationModelOutput: AnyObject {
    // Model output methods here
    func onSuccess()
    func onError(_: Error)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol PollCreationControllerOutput: AnyObject {
    var viewInput: (PollCreationViewInput & UIViewController)? { get set }
    var costItems: [CostItem] { get set }
    var balance: Int { get }
    var completed: Bool { get set }
    
    func onNextStage(_: PollCreationController.Stage)
    func onDeinit()
    func post()
    func onSuccess()
    func onError(_: Error)
    func onURLCopiedToPasteBoard(_: URL)
    func onImageCopiedToPasteBoard(_: UIImage)
}
