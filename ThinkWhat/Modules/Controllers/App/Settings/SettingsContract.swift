//
//  SettingsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

/// *View* sends user actions to the *Controller*.
///
/// **Controller** conforms to this protocol
protocol SettingsViewInput: AnyObject {
  
  var controllerOutput: SettingsControllerOutput? { get set }
  var controllerInput: SettingsControllerInput? { get set }
  
  func updateUsername(_: [String: String])
  func updateBirthDate(_: Date)
  func updateDescription(_: String)
  func updateGender(_: Gender)
  func updateCity(_ : City)
  func updateFacebook(_ : String)
  func updateInstagram(_ : String)
  func updateTiktok(_ : String)
  func openCamera()
  func openGallery()
  func openURL(_ : URL)
  func fetchCity(userprofile: Userprofile, string: String)
  func onTopicSelected(_: Topic)
  func onPublicationsSelected()
  func onSubscribersSelected()
  func onSubscriptionsSelected()
  func onWatchingSelected()
  func updateAppSettings(_: [AppSettings: Any])
  func onContentLanguageTap()
  func showLicense()
  func showTerms()
  func feedback()
  func manageAccount(_: AccountManagementCell.Mode)
  func sendVerificationCode(_: String)
}

protocol SettingsControllerInput: AnyObject {
  
  var modelOutput: SettingsModelOutput? { get set }
  
  func updateUserprofile(parameters: [String: Any], image: UIImage?)
  func fetchCity(userprofile: Userprofile, string: String)
  func saveCity(_: City, completion: @escaping (Bool) -> ())
  func updateAppSettings(_: [AppSettings: Any])
  func sendVerificationCode(to: String, completion: @escaping (Result<[String : Any], Error>) -> ())
  //    func updateUserData()
}

protocol SettingsModelOutput: AnyObject {
  
  //    var surveyCategory: Survey.SurveyCategory { get }
  
  func onError(_: Error)
}

/// *Controller* returns a UI-representable result to the *View*
///
/// **View** conforms to this protocol
protocol SettingsControllerOutput: AnyObject {
  var viewInput: (SettingsViewInput & TintColorable)? { get set }
  
  func onError(_: Error)
  func onAppSettings()
  func onUserSettings()
}
