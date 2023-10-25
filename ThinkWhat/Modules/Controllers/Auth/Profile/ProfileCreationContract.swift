//
//  ProfileCreationContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol ProfileCreationViewInput: AnyObject {
  var controllerOutput: ProfileCreationControllerOutput? { get set }
  var controllerInput: ProfileCreationControllerInput? { get set }
  var userprofile: Userprofile { get }
  
//  func updateUsername(_: [String: String])
//  func updateBirthDate(_: Date)
//  func updateDescription(_: String)
//  func updateGender(_: Enums.Gender)
//  func updateCity(_ : City)
//  func updateFacebook(_ : String)
//  func updateInstagram(_ : String)
//  func updateTiktok(_ : String)
  func checkUsernameAvailability(_: String)
  func setUsername(_: String)
  func setGender(_: Enums.Gender)
  func openApp()
  func openCamera()
  func openGallery()
  func showBanner(_: NewBanner)
//  func openURL(_ : URL)
//  func fetchCity(userprofile: Userprofile, string: String)
}

protocol ProfileCreationControllerInput: AnyObject {
  var modelOutput: ProfileCreationModelOutput? { get set }
  
  func checkUsernameAvailability(_: String)
//  func updateUserprofile(parameters: [String: Any], image: UIImage?)
//  func fetchCity(userprofile: Userprofile, string: String)
//  func saveCity(_: City, completion: @escaping (Bool) -> ())
//  func setLocales()
}

protocol ProfileCreationModelOutput: AnyObject {
  func usernameAvailabilityCallback(_: Result<Bool, Error>)
  func usernameLoadingCallback()
}

protocol ProfileCreationControllerOutput: AnyObject {
  var viewInput: (UIViewController & ProfileCreationViewInput)? { get set }
  
  func usernameAvailabilityCallback(_: Result<Bool, Error>)
  func usernameLoadingCallback()
}
