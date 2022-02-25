//
//  FillUserContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 18.02.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol FillUserViewInput: class {
    
    var controllerOutput: FillUserControllerOutput? { get set }
    var controllerInput: FillUserControllerInput? { get set }
    
    func validateHyperlink(socialMedia: SocialMedia, hyperlink: String) throws
    func onCitySearch(_ : String)
    func onImageTap()
    func onHyperlinkError()
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol FillUserControllerInput: class {
    
    var modelOutput: FillUserModelOutput? { get set }
    func validateHyperlink(socialMedia: SocialMedia, hyperlink: String) throws
    func fetchCity(_: String) async
    func saveData()
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol FillUserModelOutput: class {
    func onFetchCityComplete(_: [City])
    func onFetchCityError(_: Error)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol FillUserControllerOutput: class {
    var viewInput: FillUserViewInput? { get set }
    func onDidLayout()
    func onCityFetchResults(_:[City])
    func onAvatarChange(_: UIImage)
}
