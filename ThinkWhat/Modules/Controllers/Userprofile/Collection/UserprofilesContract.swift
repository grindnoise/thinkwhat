//
//  UserprofilesContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol UserprofilesViewInput: AnyObject {
    
    var controllerOutput: UserprofilesControllerOutput? { get set }
    var controllerInput: UserprofilesControllerInput? { get set }
  var mode: Enums.UserprofilesViewMode { get }
    var userprofile: Userprofile? { get }
    var answer: Answer? { get }
    
    func onUserprofileTap(_: Userprofile)
  func loadUsers(for: Userprofile, mode: Enums.UserprofilesViewMode)
    func loadVoters(for: Answer)
    func subscribe(at: [Userprofile])
    func unsubscribe(from: [Userprofile])
//    func removeSubscribers(_: [Userprofile])
    func onSelection(_: [Userprofile])
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol UserprofilesControllerInput: AnyObject {
    
    var modelOutput: UserprofilesModelOutput? { get set }
    
  func loadUsers(for: Userprofile, mode: Enums.UserprofilesViewMode)
    func loadVoters(for: Answer)
    func subscribe(at: [Userprofile])
    func unsubscribe(from: [Userprofile])
//    func removeSubscribers(_: [Userprofile])
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol UserprofilesModelOutput: AnyObject {
    // Model output methods here
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol UserprofilesControllerOutput: AnyObject {
    var viewInput: (UserprofilesViewInput & TintColorable)? { get set }
    var gridItemSizePublisher: CurrentValueSubject<UserprofilesController.GridItemSize?, Never> { get }
    
    func filter()
    func setEditingMode(_: Bool)
}
