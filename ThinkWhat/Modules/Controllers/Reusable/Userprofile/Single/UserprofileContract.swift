//
//  UserprofileContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol UserprofileViewInput: AnyObject {
    
    var controllerOutput: UserprofileControllerOutput? { get set }
    var controllerInput: UserprofileControllerInput? { get set }
    var userprofile: Userprofile { get }
    
    func unsubscribe()
    func subscribe()
    func openImage(_: UIImage)
    func openURL(_: URL)
    func onTopicSelected(_: Topic)
}

protocol UserprofileControllerInput: AnyObject {
    
    var modelOutput: UserprofileModelOutput? { get set }
    
    func switchNotifications(userprofile: Userprofile, notify: Bool)
    func unsubscribe(from: Userprofile)
    func subscribe(to: Userprofile)
}

protocol UserprofileModelOutput: AnyObject {
    // Model output methods here
}

protocol UserprofileControllerOutput: AnyObject {
    var viewInput: UserprofileViewInput? { get set }
    
    // Controller output methods here
}
