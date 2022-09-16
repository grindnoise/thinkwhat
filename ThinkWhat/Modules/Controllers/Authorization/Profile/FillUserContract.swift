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
protocol FillUserViewInput: AnyObject {
    
    var controllerOutput: FillUserControllerOutput? { get set }
    var controllerInput: FillUserControllerInput? { get set }
    
    func validateHyperlink(socialMedia: SocialMedia, hyperlink: String) throws
    func onCitySearch(_ : String)
    func onCitySelected(_ : City)
    func onImageTap()
    func onHyperlinkError()
    func updateUserprofile(image: UIImage?, firstName: String, lastName: String, gender: Gender, birthDate: String?, city: City?, vkID: String?, vkURL: String?, facebookID: String?, facebookURL: String?)
}

/// *Controller* tells the *Model* what to do based on the input
///
/// **Model** conforms to this protocol
protocol FillUserControllerInput: AnyObject {
    
    var modelOutput: FillUserModelOutput? { get set }
    func validateHyperlink(socialMedia: SocialMedia, hyperlink: String) throws
    func fetchCity(_: String) async
    func updateUserprofile(image: UIImage?, firstName: String, lastName: String, gender: Gender, birthDate: String?, city: City?, vkID: String?, vkURL: String?, facebookID: String?, facebookURL: String?)
    func saveCity(_: City)
}

/// *Model* returns the result to the *Controller*
///
/// **Controller** conforms to this protocol
protocol FillUserModelOutput: AnyObject {
    func onFetchCityComplete(_: [City])
    func onFetchCityError(_: Error)
    func onUpdateProfileComplete(_: Result<Bool,Error>)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol FillUserControllerOutput: AnyObject {
    var viewInput: FillUserViewInput? { get set }
    func onDidLayout()
    func onCityFetchResults(_:[City])
    func onAvatarChange(_: UIImage)
    func onUpdateProfileCompleteWithError()
}
