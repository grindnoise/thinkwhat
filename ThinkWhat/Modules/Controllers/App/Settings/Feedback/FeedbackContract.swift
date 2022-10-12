//
//  FeedbackContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 12.10.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol FeedbackViewInput: AnyObject {
    
    var controllerOutput: FeedbackControllerOutput? { get set }
    var controllerInput: FeedbackControllerInput? { get set }
    
    func sendFeedback(_: String)
}

protocol FeedbackControllerInput: AnyObject {
    
    var modelOutput: FeedbackModelOutput? { get set }
    
    func sendFeedback(_: String)
}

protocol FeedbackModelOutput: AnyObject {
    
}

protocol FeedbackControllerOutput: AnyObject {
    var viewInput: (UIViewController & FeedbackViewInput)? { get set }
    
    
}
