//
//  TermsContract.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.04.2023.
//  Copyright © 2023 Pavel Bukharov. All rights reserved.
//

import UIKit

protocol TermsViewInput: AnyObject {
  
  var controllerOutput: TermsControllerOutput? { get set }
  var controllerInput: TermsControllerInput? { get set }
  
  func onAccept()
}

protocol TermsControllerInput: AnyObject {
  
  var modelOutput: TermsModelOutput? { get set }
  
  func getTermsConditionsURL()
}

protocol TermsModelOutput: AnyObject {
  func onTermsConditionsURLReceived(_: URL)
}

protocol TermsControllerOutput: AnyObject {
  var viewInput: TermsViewInput? { get set }
  
  func getTermsConditionsURL(_: URL)
}
