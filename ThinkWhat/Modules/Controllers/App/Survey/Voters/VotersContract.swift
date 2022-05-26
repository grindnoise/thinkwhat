//
//  VotersContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 19.04.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol VotersViewInput: class {
    
    var controllerOutput: VotersControllerOutput? { get set }
    var controllerInput: VotersControllerInput? { get set }
    var answer: Answer { get }
    var indexPath: IndexPath { get }
    var color: UIColor { get }
    
    func setFilterEnabled(_: Bool)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol VotersControllerInput: class {
    var modelOutput: VotersModelOutput? { get set }
    
    func loadData()
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol VotersModelOutput: class {
    var answer: Answer { get }
    
    func onDataLoaded(_: Result<[Userprofile], Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol VotersControllerOutput: class {
    var viewInput: VotersViewInput? { get set }
    var answer: Answer { get }
    var indexPath: IndexPath { get }
    
    func onFilterTapped()
    func onDataLoaded(_: Result<[Userprofile], Error>)
}
