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
  
  func updateUsername(_: [String: String])
  func updateBirthDate(_: Date)
  func updateDescription(_: String)
  func updateGender(_: Gender)
  func updateCity(_ : City)
  func updateFacebook(_ : String)
  func updateInstagram(_ : String)
  func updateTiktok(_ : String)
  func openApp()
  func openCamera()
  func openGallery()
  func openURL(_ : URL)
  func fetchCity(userprofile: Userprofile, string: String)
}

protocol ProfileCreationControllerInput: AnyObject {
  var modelOutput: ProfileCreationModelOutput? { get set }
  
  func updateUserprofile(parameters: [String: Any], image: UIImage?)
  func fetchCity(userprofile: Userprofile, string: String)
  func saveCity(_: City, completion: @escaping (Bool) -> ())
}

protocol ProfileCreationModelOutput: AnyObject {
  
}

protocol ProfileCreationControllerOutput: AnyObject {
  var viewInput: (UIViewController & ProfileCreationViewInput)? { get set }
}
